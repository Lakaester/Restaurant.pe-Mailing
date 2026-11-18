-- ============================================================================
-- EPIC-SLA-01 · DISENO DE ESQUEMA · 001
--
-- ARCHIVO DE DISENO. NO ES UNA MIGRACION APLICADA.
-- No se ha ejecutado contra ninguna base de datos.
--
-- Requiere revision y aprobacion del DBA y del responsable tecnico antes de
-- aplicarse, y solo sobre la base aislada `restaurant_bi_test`.
--
-- Base: PostgreSQL (probado en el entorno declarado: PostgreSQL 16).
-- Esquema: public. Prefijo de tablas: sla_.
--
-- NO hace:
--   - No toca Zammad ni sus tablas internas.
--   - No altera public.v_unificado_norm ni ninguna vista o tabla historica.
--   - No crea triggers.
--   - No inserta datos. La carga de las 38 politicas es un paso posterior.
--
-- Orden de creacion (respeta las dependencias):
--   1. sla_policy_version
--   2. sla_commitment
--   3. sla_cycle
--   4. sla_event
--   5. sla_article_delivery
--   6. sla_alert
--   7. sla_audit
--   8. sla_divergence
--   9. sla_sync_run
--
-- Ver DISENO_ESQUEMA_BD_SLA.md para el diccionario de datos y las reglas.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- GUARDA DE ENTORNO
-- Aborta si la conexion no apunta a la base de prueba. Es la ultima linea de
-- defensa, no la unica: el procedimiento M1-M8 verifica host, base y rol antes.
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  IF current_database() <> 'restaurant_bi_test' THEN
    RAISE EXCEPTION
      'Diseno SLA bloqueado: se esperaba la base restaurant_bi_test y la conexion apunta a "%".',
      current_database();
  END IF;

  IF current_user IN ('pgvector_user', 'postgres') THEN
    RAISE EXCEPTION
      'Diseno SLA bloqueado: el rol "%" es de produccion o administracion. Usar cope_test_migration.',
      current_user;
  END IF;
END
$$;

-- ============================================================================
-- 1. sla_policy_version
-- Catalogo versionado de politicas. Una fila inmutable por (policy_key, version).
-- Contiene 27 politicas de matriz, 3 sin evidencia, 1 respaldo provisional y
-- 7 exclusiones por DEC-05 = 38 filas en la carga inicial.
-- ============================================================================
CREATE TABLE sla_policy_version (
    id                      uuid            NOT NULL DEFAULT gen_random_uuid(),

    -- Clave estable: '20-MAIL-<CATEGORIA>-<SUBCATEGORIA>' normalizada sin tildes,
    -- o '99-FALLBACK'. Ver DISENO_ESQUEMA_BD_SLA.md §C.1.
    policy_key              text            NOT NULL,
    version                 integer         NOT NULL,
    policy_class            text            NOT NULL,

    matrix_version          text            NOT NULL,
    channel                 text            NOT NULL,

    -- Etiquetas oficiales del catalogo, tal como aparecen en CategoryData.ts.
    category                text            NOT NULL,
    subcategory             text            NOT NULL,

    -- Solo primera respuesta de correo: 1.440 min (24 h). NULL en exclusiones.
    first_response_minutes  integer,
    -- NULL = sin evidencia (no se mide resolucion).
    resolution_minutes      integer,
    provisional             boolean         NOT NULL DEFAULT false,

    status                  text            NOT NULL,
    sample_size             integer,
    p75_minutes             numeric(10,2),
    confidence              text,

    valid_from              timestamptz     NOT NULL,
    valid_to                timestamptz,
    created_by              text            NOT NULL,
    created_at              timestamptz     NOT NULL DEFAULT now(),
    reason                  text            NOT NULL,

    CONSTRAINT sla_policy_version_pk PRIMARY KEY (id),
    CONSTRAINT sla_policy_version_key_version_uq UNIQUE (policy_key, version),

    CONSTRAINT sla_policy_version_channel_ck
        CHECK (channel = 'email'),

    CONSTRAINT sla_policy_version_class_ck
        CHECK (policy_class IN ('matrix', 'insufficient_evidence', 'fallback', 'excluded_non_service')),

    CONSTRAINT sla_policy_version_status_ck
        CHECK (status IN ('draft', 'active', 'inactive', 'pending')),

    CONSTRAINT sla_policy_version_confidence_ck
        CHECK (confidence IS NULL OR confidence IN ('ALTA', 'MEDIA', 'BAJA', 'INSUFICIENTE')),

    CONSTRAINT sla_policy_version_fr_ck
        CHECK (first_response_minutes IS NULL OR first_response_minutes = 1440),

    CONSTRAINT sla_policy_version_fr_required_ck
        CHECK (policy_class = 'excluded_non_service' OR first_response_minutes IS NOT NULL),

    CONSTRAINT sla_policy_version_resolution_ck
        CHECK (resolution_minutes IS NULL OR resolution_minutes > 0),

    CONSTRAINT sla_policy_version_sample_ck
        CHECK (sample_size IS NULL OR sample_size >= 0),

    CONSTRAINT sla_policy_version_provisional_ck
        CHECK (provisional = (policy_class = 'fallback')),

    CONSTRAINT sla_policy_version_matrix_ck
        CHECK (policy_class <> 'matrix' OR resolution_minutes IS NOT NULL),

    CONSTRAINT sla_policy_version_insufficient_ck
        CHECK (policy_class <> 'insufficient_evidence'
               OR (resolution_minutes IS NULL AND status = 'pending')),

    CONSTRAINT sla_policy_version_excluded_ck
        CHECK (policy_class <> 'excluded_non_service'
               OR (resolution_minutes IS NULL AND status = 'inactive')),

    CONSTRAINT sla_policy_version_active_ck
        CHECK (status <> 'active' OR resolution_minutes IS NOT NULL),

    CONSTRAINT sla_policy_version_fallback_key_ck
        CHECK (policy_class <> 'fallback' OR (policy_key = '99-FALLBACK' AND category = '*' AND subcategory = '*')),

    CONSTRAINT sla_policy_version_named_key_ck
        CHECK (policy_class = 'fallback' OR (category <> '*' AND subcategory <> '*')),

    -- Formato de la clave oficial (EPIC §6.8).
    CONSTRAINT sla_policy_version_key_format_ck
        CHECK (policy_key = '99-FALLBACK' OR policy_key LIKE '20-MAIL-%'),

    -- La escalera de redondeo es la oficial (EPIC §6.1). Un valor fuera de ella
    -- exige una version nueva de la matriz, no una excepcion silenciosa.
    CONSTRAINT sla_policy_version_resolution_ladder_ck
        CHECK (resolution_minutes IS NULL OR resolution_minutes IN (
            15, 30, 45, 60, 90, 120, 180, 240, 360, 480, 720,
            1440, 2160, 2880, 4320, 5760, 7200
        )),

    CONSTRAINT sla_policy_version_fallback_minutes_ck
        CHECK (policy_class <> 'fallback' OR resolution_minutes = 2160),

    -- DEC-05: las exclusiones no tienen primera respuesta comprometida.
    CONSTRAINT sla_policy_version_excluded_fr_ck
        CHECK (policy_class <> 'excluded_non_service' OR first_response_minutes IS NULL),

    -- Evidencia minima de la matriz (EPIC §6.1 y §6.3).
    CONSTRAINT sla_policy_version_matrix_evidence_ck
        CHECK (policy_class <> 'matrix' OR (
            sample_size IS NOT NULL AND sample_size >= 10 AND
            p75_minutes IS NOT NULL AND confidence IS NOT NULL
        )),

    CONSTRAINT sla_policy_version_insufficient_evidence_ck
        CHECK (policy_class <> 'insufficient_evidence' OR (
            sample_size IS NOT NULL AND sample_size < 10
        )),

    CONSTRAINT sla_policy_version_validity_ck
        CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE sla_policy_version IS
  'Catalogo versionado de politicas SLA de correo. Inmutable al publicar: un cambio crea una version nueva.';

COMMENT ON COLUMN sla_policy_version.policy_key IS
  '20-MAIL-<CATEGORIA>-<SUBCATEGORIA> normalizada (mayusculas, sin tildes, separadores a guion bajo) o 99-FALLBACK.';

COMMENT ON COLUMN sla_policy_version.policy_class IS
  'matrix = 27 combinaciones con P75; insufficient_evidence = 3 con n<10 sin SLA; fallback = respaldo 36 h; excluded_non_service = 7 casos DEC-05.';

COMMENT ON COLUMN sla_policy_version.resolution_minutes IS
  'Minutos calendario desde created_at. NULL = sin evidencia; nunca 0.';

COMMENT ON COLUMN sla_policy_version.provisional IS
  'true solo en 99-FALLBACK. Las 28 subcategorias de servicio fuera de matriz lo heredan al asignar.';

COMMENT ON COLUMN sla_policy_version.category IS
  'Etiqueta oficial del catalogo, con tildes. La normalizacion solo se aplica a policy_key.';

-- Una sola version vigente por combinacion.
CREATE UNIQUE INDEX sla_policy_version_vigente_uq
    ON sla_policy_version (channel, category, subcategory)
    WHERE valid_to IS NULL AND status = 'active';

CREATE INDEX sla_policy_version_lookup_idx
    ON sla_policy_version (channel, category, subcategory);

CREATE INDEX sla_policy_version_status_idx
    ON sla_policy_version (status);

-- ============================================================================
-- 2. sla_commitment
-- Un compromiso por ticket. Snapshot congelado en el momento de clasificar.
-- ============================================================================
CREATE TABLE sla_commitment (
    id                       uuid        NOT NULL DEFAULT gen_random_uuid(),

    -- Identificador externo de Zammad. Unico: un compromiso por ticket.
    ticket_id                integer     NOT NULL,
    ticket_number            text        NOT NULL,

    policy_version_id        uuid,
    assignment_status        text        NOT NULL,

    -- Copia congelada de la politica aplicada.
    policy_key               text,
    policy_version           integer,
    policy_class             text,
    channel                  text,
    category                 text,
    subcategory              text,
    first_response_minutes   integer,
    resolution_minutes       integer,
    provisional              boolean     NOT NULL DEFAULT false,

    -- Inicio del reloj: created_at del ticket. Calendario 24/7, sin pausas.
    started_at               timestamptz,
    classified_at            timestamptz,
    assigned_at              timestamptz,
    first_response_due_at    timestamptz,
    resolution_due_at        timestamptz,

    -- Primera respuesta efectiva: articulo publico de agente, email,
    -- delivery_status = success. accepted != entregado en buzon.
    first_response_at        timestamptz,
    first_response_article_id integer,
    first_response_source    text,
    first_response_outcome   text,

    reclassified_count       integer     NOT NULL DEFAULT 0,
    late_classification      boolean     NOT NULL DEFAULT false,

    -- Corte de historico vigente al crear el compromiso (BR-46).
    activation_at            timestamptz NOT NULL,

    last_seen_state          text,
    last_seen_updated_at     timestamptz,
    created_at               timestamptz NOT NULL DEFAULT now(),
    updated_at               timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT sla_commitment_pk PRIMARY KEY (id),
    CONSTRAINT sla_commitment_ticket_uq UNIQUE (ticket_id),

    CONSTRAINT sla_commitment_policy_fk
        FOREIGN KEY (policy_version_id) REFERENCES sla_policy_version (id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,

    CONSTRAINT sla_commitment_status_ck
        CHECK (assignment_status IN (
            'pending_classification', 'assigned', 'no_policy',
            'historical', 'non_email', 'excluded_non_service'
        )),

    CONSTRAINT sla_commitment_class_ck
        CHECK (policy_class IS NULL OR policy_class IN (
            'matrix', 'insufficient_evidence', 'fallback', 'excluded_non_service'
        )),

    CONSTRAINT sla_commitment_channel_ck
        CHECK (channel IS NULL OR channel = 'email'),

    CONSTRAINT sla_commitment_fr_ck
        CHECK (first_response_minutes IS NULL OR first_response_minutes = 1440),

    CONSTRAINT sla_commitment_outcome_ck
        CHECK (first_response_outcome IS NULL OR first_response_outcome IN (
            'met', 'missed', 'pending', 'not_applicable'
        )),

    CONSTRAINT sla_commitment_source_ck
        CHECK (first_response_source IS NULL OR first_response_source IN (
            'delivery_status_date', 'updated_at_fallback'
        )),

    -- Si hay clave de politica, debe existir la version referenciada.
    CONSTRAINT sla_commitment_policy_pair_ck
        CHECK (policy_key IS NULL OR policy_version_id IS NOT NULL),

    -- El respaldo provisional es exclusivo de 99-FALLBACK.
    CONSTRAINT sla_commitment_provisional_ck
        CHECK (policy_class IS NULL OR provisional = (policy_class = 'fallback')),

    -- Un compromiso asignado exige snapshot completo y vencimientos.
    CONSTRAINT sla_commitment_assigned_ck
        CHECK (assignment_status <> 'assigned' OR (
            policy_version_id IS NOT NULL AND
            policy_key IS NOT NULL AND
            policy_class IS NOT NULL AND
            first_response_minutes IS NOT NULL AND
            resolution_minutes IS NOT NULL AND
            started_at IS NOT NULL AND
            assigned_at IS NOT NULL AND
            classified_at IS NOT NULL AND
            first_response_due_at IS NOT NULL AND
            resolution_due_at IS NOT NULL
        )),

    CONSTRAINT sla_commitment_assigned_class_ck
        CHECK (assignment_status <> 'assigned' OR policy_class IN ('matrix', 'fallback')),

    -- Los vencimientos existen si y solo si el compromiso esta asignado.
    -- Garantiza que historical, non_email, pending, no_policy y excluded
    -- queden fuera de todo denominador tambien a nivel de dato.
    CONSTRAINT sla_commitment_dues_ck
        CHECK ((assignment_status = 'assigned') = (resolution_due_at IS NOT NULL)),

    CONSTRAINT sla_commitment_first_due_presence_ck
        CHECK ((assignment_status = 'assigned') = (first_response_due_at IS NOT NULL)),

    -- Sin politica: evidencia insuficiente, sin duracion ni vencimientos.
    CONSTRAINT sla_commitment_no_policy_ck
        CHECK (assignment_status <> 'no_policy' OR (
            policy_version_id IS NOT NULL AND
            policy_key IS NOT NULL AND
            policy_class = 'insufficient_evidence' AND
            resolution_minutes IS NULL AND
            first_response_minutes IS NULL
        )),

    -- Exclusion DEC-05: nunca SLA ni respaldo.
    CONSTRAINT sla_commitment_excluded_ck
        CHECK (assignment_status <> 'excluded_non_service' OR (
            policy_version_id IS NOT NULL AND
            policy_key IS NOT NULL AND
            policy_class = 'excluded_non_service' AND
            resolution_minutes IS NULL AND
            first_response_minutes IS NULL
        )),

    CONSTRAINT sla_commitment_pending_ck
        CHECK (assignment_status <> 'pending_classification' OR (
            policy_key IS NULL AND
            policy_version_id IS NULL AND
            policy_class IS NULL AND
            first_response_minutes IS NULL AND
            resolution_minutes IS NULL
        )),

    -- Historico: anterior a activation_at, fuera de denominadores.
    CONSTRAINT sla_commitment_historical_ck
        CHECK (assignment_status <> 'historical' OR (
            policy_key IS NULL AND
            policy_version_id IS NULL AND
            policy_class IS NULL AND
            first_response_minutes IS NULL AND
            resolution_minutes IS NULL
        )),

    -- No correo: fuera del motor.
    CONSTRAINT sla_commitment_non_email_ck
        CHECK (assignment_status <> 'non_email' OR (
            channel IS NULL AND
            policy_key IS NULL AND
            policy_version_id IS NULL AND
            policy_class IS NULL AND
            first_response_minutes IS NULL AND
            resolution_minutes IS NULL
        )),

    CONSTRAINT sla_commitment_due_order_ck
        CHECK (resolution_due_at IS NULL OR (started_at IS NOT NULL AND resolution_due_at >= started_at)),

    CONSTRAINT sla_commitment_first_due_ck
        CHECK (first_response_due_at IS NULL OR (
            started_at IS NOT NULL AND
            first_response_due_at = started_at + interval '1440 minutes'
        )),

    CONSTRAINT sla_commitment_fr_met_ck
        CHECK (first_response_outcome <> 'met' OR first_response_at IS NOT NULL),

    CONSTRAINT sla_commitment_fr_pending_ck
        CHECK (first_response_outcome <> 'pending' OR first_response_at IS NULL),

    -- La primera respuesta no puede ser anterior a la creacion del ticket.
    CONSTRAINT sla_commitment_fr_after_start_ck
        CHECK (first_response_at IS NULL OR (
            started_at IS NOT NULL AND first_response_at >= started_at
        )),

    CONSTRAINT sla_commitment_reclassified_ck
        CHECK (reclassified_count >= 0),

    -- BR-44: la clasificacion tardia se mide contra el vencimiento congelado.
    CONSTRAINT sla_commitment_late_ck
        CHECK (late_classification = false OR (
            classified_at IS NOT NULL AND
            started_at IS NOT NULL AND
            resolution_minutes IS NOT NULL AND
            classified_at > started_at + make_interval(mins => resolution_minutes)
        ))
);

COMMENT ON TABLE sla_commitment IS
  'Un registro por ticket. Las columnas de politica, duracion y vencimiento son un snapshot inmutable: no se recalculan al reclasificar ni al reabrir.';

COMMENT ON COLUMN sla_commitment.assignment_status IS
  'pending_classification antes de clasificar; assigned con politica; no_policy para las 3 sin evidencia; excluded_non_service para DEC-05; historical si created_at < activation_at; non_email si el ticket no es de correo.';

COMMENT ON COLUMN sla_commitment.late_classification IS
  'true si se clasifico despues de started_at + resolution_minutes. La condicion missed_at_birth se registra en el ciclo 1 (outcome = missed_at_birth).';

COMMENT ON COLUMN sla_commitment.first_response_at IS
  'Marca del primer articulo valido. Es aceptacion SMTP, no entrega en buzon. La fuente queda en first_response_source.';

COMMENT ON COLUMN sla_commitment.activation_at IS
  'Corte de historico vigente al crear el compromiso. Tickets anteriores quedan historical y fuera de todo denominador.';

CREATE INDEX sla_commitment_status_idx
    ON sla_commitment (assignment_status);

CREATE INDEX sla_commitment_resolution_due_idx
    ON sla_commitment (resolution_due_at)
    WHERE assignment_status = 'assigned';

CREATE INDEX sla_commitment_first_response_due_idx
    ON sla_commitment (first_response_due_at)
    WHERE assignment_status = 'assigned' AND first_response_at IS NULL;

CREATE INDEX sla_commitment_started_idx
    ON sla_commitment (started_at);

-- ============================================================================
-- 3. sla_cycle
-- Ciclos de resolucion. Ciclo 1 es la metrica oficial; 2..N son operativos.
-- ============================================================================
CREATE TABLE sla_cycle (
    id                  uuid        NOT NULL DEFAULT gen_random_uuid(),
    commitment_id       uuid        NOT NULL,
    cycle_number        integer     NOT NULL,

    opened_at           timestamptz NOT NULL,
    due_at              timestamptz,
    closed_at           timestamptz,
    outcome             text        NOT NULL,
    exclusion_reason    text,
    reopen_hint         text,

    -- Referencias logicas a sla_event: sin FK por la retencion de eventos (2 anos).
    opened_by_event_id  uuid,
    closed_by_event_id  uuid,
    closed_by_actor_id  integer,

    overdue_at_cutoff   boolean     NOT NULL DEFAULT false,
    created_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT sla_cycle_pk PRIMARY KEY (id),
    CONSTRAINT sla_cycle_number_uq UNIQUE (commitment_id, cycle_number),

    CONSTRAINT sla_cycle_commitment_fk
        FOREIGN KEY (commitment_id) REFERENCES sla_commitment (id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,

    CONSTRAINT sla_cycle_number_ck
        CHECK (cycle_number >= 1),

    CONSTRAINT sla_cycle_outcome_ck
        CHECK (outcome IN ('open', 'met', 'missed', 'excluded', 'missed_at_birth')),

    CONSTRAINT sla_cycle_exclusion_ck
        CHECK (exclusion_reason IS NULL OR exclusion_reason IN ('merged', 'ticket_deleted')),

    CONSTRAINT sla_cycle_reopen_hint_ck
        CHECK (reopen_hint IS NULL OR reopen_hint = 'delivery_failure'),

    -- Un ciclo `open` no tiene cierre. `missed_at_birth` puede estar abierto
    -- (todavia no cerro) o cerrado (ya cerro, pero nacio vencido).
    CONSTRAINT sla_cycle_open_closed_ck
        CHECK (outcome <> 'open' OR closed_at IS NULL),

    CONSTRAINT sla_cycle_final_closed_ck
        CHECK (outcome IN ('open', 'missed_at_birth') OR closed_at IS NOT NULL),

    -- BR-33: el borde de resolucion es inclusivo.
    CONSTRAINT sla_cycle_met_ck
        CHECK (outcome <> 'met' OR (
            closed_at IS NOT NULL AND due_at IS NOT NULL AND closed_at <= due_at
        )),

    CONSTRAINT sla_cycle_missed_ck
        CHECK (outcome <> 'missed' OR (
            closed_at IS NOT NULL AND due_at IS NOT NULL AND closed_at > due_at
        )),

    CONSTRAINT sla_cycle_excluded_reason_ck
        CHECK ((outcome = 'excluded') = (exclusion_reason IS NOT NULL)),

    CONSTRAINT sla_cycle_closed_order_ck
        CHECK (closed_at IS NULL OR closed_at >= opened_at),

    CONSTRAINT sla_cycle_due_order_ck
        CHECK (due_at IS NULL OR due_at >= opened_at),

    -- Nacido vencido solo puede ser el ciclo 1.
    CONSTRAINT sla_cycle_missed_at_birth_ck
        CHECK (outcome <> 'missed_at_birth' OR cycle_number = 1),

    CONSTRAINT sla_cycle_open_needs_due_ck
        CHECK (outcome <> 'open' OR due_at IS NOT NULL),

    CONSTRAINT sla_cycle_missed_at_birth_due_ck
        CHECK (outcome <> 'missed_at_birth' OR due_at IS NOT NULL),

    -- El actor de cierre solo tiene sentido si hubo cierre.
    CONSTRAINT sla_cycle_closed_actor_ck
        CHECK (closed_by_actor_id IS NULL OR closed_at IS NOT NULL)
);

COMMENT ON TABLE sla_cycle IS
  'Ciclos de resolucion por compromiso. El ciclo 1 mide desde created_at; cada reapertura abre un ciclo nuevo con la misma politica congelada.';

COMMENT ON COLUMN sla_cycle.opened_at IS
  'Ciclo 1: started_at del compromiso. Ciclo N: instante de la reapertura.';

COMMENT ON COLUMN sla_cycle.due_at IS
  'Inmutable. Ciclo 1: resolution_due_at. Ciclo N: opened_at + resolution_minutes (sujeto a REA-02).';

COMMENT ON COLUMN sla_cycle.outcome IS
  'open mientras el ciclo no cierra; met si closed_at <= due_at; missed si closed_at > due_at; excluded para merged o ticket eliminado; missed_at_birth si nacio vencido.';

-- Un solo ciclo sin cierre por compromiso: cubre `open` y `missed_at_birth`
-- todavia no cerrado. BR-40.
CREATE UNIQUE INDEX sla_cycle_open_uq
    ON sla_cycle (commitment_id)
    WHERE closed_at IS NULL;

CREATE INDEX sla_cycle_commitment_idx
    ON sla_cycle (commitment_id, cycle_number);

CREATE INDEX sla_cycle_due_idx
    ON sla_cycle (due_at)
    WHERE closed_at IS NULL;

CREATE INDEX sla_cycle_closed_idx
    ON sla_cycle (closed_at);

-- ============================================================================
-- 4. sla_event
-- Hechos idempotentes. Registro de verdad para reconstruir proyecciones.
-- ============================================================================
CREATE TABLE sla_event (
    id                uuid        NOT NULL DEFAULT gen_random_uuid(),

    -- sha256('zammad'|event_type|ticket_id|entity_id|occurred_at_utc)
    idempotency_key   text        NOT NULL,
    event_type        text        NOT NULL,
    event_version     integer     NOT NULL DEFAULT 1,

    ticket_id         integer     NOT NULL,
    article_id        integer,
    entity_id         text,

    occurred_at       timestamptz NOT NULL,
    received_at       timestamptz NOT NULL DEFAULT now(),

    source            text        NOT NULL,
    payload           jsonb       NOT NULL,

    status            text        NOT NULL DEFAULT 'pending',
    status_reason     text,
    attempts          integer     NOT NULL DEFAULT 0,
    applied_at        timestamptz,

    CONSTRAINT sla_event_pk PRIMARY KEY (id),
    CONSTRAINT sla_event_idempotency_uq UNIQUE (idempotency_key),

    CONSTRAINT sla_event_key_len_ck
        CHECK (char_length(idempotency_key) = 64),

    -- SHA-256 en hexadecimal minuscula (BR-61).
    CONSTRAINT sla_event_key_hex_ck
        CHECK (idempotency_key ~ '^[0-9a-f]{64}$'),

    CONSTRAINT sla_event_type_ck
        CHECK (event_type IN (
            'ticket.created', 'ticket.classified', 'ticket.reclassified',
            'ticket.state_changed', 'ticket.closed', 'ticket.reopened',
            'ticket.merged', 'ticket.deleted',
            'article.created', 'article.delivery_confirmed',
            'article.delivery_failed', 'article.delivery_retry_pending',
            'commitment.assigned', 'cycle.opened', 'cycle.closed'
        )),

    CONSTRAINT sla_event_source_ck
        CHECK (source IN ('poll', 'reconcile', 'manual')),

    CONSTRAINT sla_event_status_ck
        CHECK (status IN ('pending', 'applied', 'ignored', 'failed')),

    CONSTRAINT sla_event_applied_ck
        CHECK (status <> 'applied' OR applied_at IS NOT NULL),

    CONSTRAINT sla_event_attempts_ck
        CHECK (attempts >= 0),

    CONSTRAINT sla_event_version_ck
        CHECK (event_version >= 1),

    -- Un evento ignorado o fallido debe explicar por que.
    CONSTRAINT sla_event_reason_ck
        CHECK (status NOT IN ('ignored', 'failed') OR status_reason IS NOT NULL)
);

COMMENT ON TABLE sla_event IS
  'Hechos normalizados e idempotentes. La clave de idempotencia evita duplicados; el payload no contiene datos personales.';

COMMENT ON COLUMN sla_event.payload IS
  'Solo metadatos. Prohibido: cuerpo de correo, asunto completo, direcciones, telefonos o adjuntos.';

COMMENT ON COLUMN sla_event.source IS
  'poll = sondeo; reconcile = reconciliacion; manual = accion administrativa. No se usa webhook: Zammad no notifica actualizaciones de articulo.';

CREATE INDEX sla_event_pending_idx
    ON sla_event (status, received_at)
    WHERE status IN ('pending', 'failed');

CREATE INDEX sla_event_ticket_idx
    ON sla_event (ticket_id, occurred_at);

CREATE INDEX sla_event_type_idx
    ON sla_event (event_type, occurred_at);

CREATE INDEX sla_event_occurred_idx
    ON sla_event (occurred_at);

-- ============================================================================
-- 5. sla_article_delivery
-- Estado de entrega por articulo. Distingue aceptacion SMTP de fallo.
-- ============================================================================
CREATE TABLE sla_article_delivery (
    article_id              integer     NOT NULL,

    ticket_id               integer     NOT NULL,
    channel                 text        NOT NULL,
    is_public_agent         boolean     NOT NULL,

    delivery_state          text        NOT NULL,
    accepted_at             timestamptz,
    accepted_at_source      text,
    failed_at               timestamptz,
    failure_message         text,
    retry_count             integer     NOT NULL DEFAULT 0,

    last_article_updated_at timestamptz,
    created_at              timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT sla_article_delivery_pk PRIMARY KEY (article_id),

    CONSTRAINT sla_article_delivery_channel_ck
        CHECK (channel = 'email'),

    CONSTRAINT sla_article_delivery_state_ck
        CHECK (delivery_state IN ('sin_estado', 'aceptado', 'fallido_provisional', 'fallido_definitivo')),

    CONSTRAINT sla_article_delivery_source_ck
        CHECK (accepted_at_source IS NULL OR accepted_at_source IN ('delivery_status_date', 'updated_at')),

    CONSTRAINT sla_article_delivery_accepted_ck
        CHECK (delivery_state <> 'aceptado' OR accepted_at IS NOT NULL),

    -- Si hay marca de aceptacion, debe constar de donde salio.
    CONSTRAINT sla_article_delivery_accepted_source_ck
        CHECK (accepted_at IS NULL OR accepted_at_source IS NOT NULL),

    -- Un estado fallido debe tener la marca del ultimo fallo.
    CONSTRAINT sla_article_delivery_failed_at_ck
        CHECK (delivery_state NOT IN ('fallido_provisional', 'fallido_definitivo')
               OR failed_at IS NOT NULL),

    -- Regla R-02: solo es definitivo cuando Zammad ya agoto los reintentos.
    CONSTRAINT sla_article_delivery_definitivo_ck
        CHECK (delivery_state <> 'fallido_definitivo' OR retry_count > 3),

    CONSTRAINT sla_article_delivery_provisional_ck
        CHECK (delivery_state <> 'fallido_provisional' OR retry_count <= 3),

    CONSTRAINT sla_article_delivery_message_len_ck
        CHECK (failure_message IS NULL OR char_length(failure_message) <= 500),

    CONSTRAINT sla_article_delivery_retry_ck
        CHECK (retry_count >= 0)
);

COMMENT ON TABLE sla_article_delivery IS
  'Estado de entrega por articulo de correo. No existe entregado ni leido: el correo solo confirma aceptacion SMTP.';

COMMENT ON COLUMN sla_article_delivery.delivery_state IS
  'sin_estado = sin marca de envio; aceptado = delivery_status success (aceptacion SMTP, no entrega en buzon); fallido_provisional = retry_count <= 3; fallido_definitivo = retry_count > 3.';

COMMENT ON COLUMN sla_article_delivery.accepted_at_source IS
  'delivery_status_date si existe; updated_at como respaldo documentado.';

CREATE INDEX sla_article_delivery_ticket_idx
    ON sla_article_delivery (ticket_id);

CREATE INDEX sla_article_delivery_pending_idx
    ON sla_article_delivery (delivery_state)
    WHERE delivery_state IN ('sin_estado', 'fallido_provisional');

-- ============================================================================
-- 6. sla_alert
-- Una alerta por compromiso, ciclo, metrica y umbral.
-- ============================================================================
CREATE TABLE sla_alert (
    id              uuid        NOT NULL DEFAULT gen_random_uuid(),
    commitment_id   uuid        NOT NULL,
    cycle_number    integer     NOT NULL,

    metric          text        NOT NULL,
    threshold_pct   integer     NOT NULL,

    due_at          timestamptz NOT NULL,
    triggered_at    timestamptz NOT NULL DEFAULT now(),

    channel         text        NOT NULL,
    status          text        NOT NULL DEFAULT 'pending',
    sent_at         timestamptz,

    CONSTRAINT sla_alert_pk PRIMARY KEY (id),
    CONSTRAINT sla_alert_threshold_uq UNIQUE (commitment_id, cycle_number, metric, threshold_pct),

    CONSTRAINT sla_alert_cycle_fk
        FOREIGN KEY (commitment_id, cycle_number)
        REFERENCES sla_cycle (commitment_id, cycle_number)
        ON DELETE RESTRICT ON UPDATE RESTRICT,

    CONSTRAINT sla_alert_metric_ck
        CHECK (metric IN ('first_response', 'resolution')),

    -- 75 y 90 son los umbrales de riesgo; 100 es el aviso de vencimiento (BR-54).
    CONSTRAINT sla_alert_threshold_ck
        CHECK (threshold_pct IN (75, 90, 100)),

    -- No hay canal webhook: Zammad no notifica actualizaciones de articulo.
    CONSTRAINT sla_alert_channel_ck
        CHECK (channel IN ('internal', 'email')),

    CONSTRAINT sla_alert_status_ck
        CHECK (status IN ('pending', 'sent', 'failed')),

    CONSTRAINT sla_alert_sent_ck
        CHECK (status <> 'sent' OR sent_at IS NOT NULL)
);

COMMENT ON TABLE sla_alert IS
  'Alertas emitidas por el motor. Independientes de los workers de Zammad.';

COMMENT ON COLUMN sla_alert.threshold_pct IS
  '75 y 90 = umbrales de riesgo; 100 = vencimiento. Una fila por combinacion.';

CREATE INDEX sla_alert_pending_idx
    ON sla_alert (status, triggered_at)
    WHERE status = 'pending';

-- ============================================================================
-- 7. sla_audit
-- Auditoria append-only. Sin UPDATE ni DELETE por privilegios del rol runtime.
-- ============================================================================
CREATE TABLE sla_audit (
    id              uuid        NOT NULL DEFAULT gen_random_uuid(),

    entity_type     text        NOT NULL,
    entity_id       text        NOT NULL,
    action          text        NOT NULL,

    actor_type      text        NOT NULL,
    actor_id        text        NOT NULL,

    old_value       jsonb,
    new_value       jsonb,
    reason          text,
    request_id      text,
    created_at      timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT sla_audit_pk PRIMARY KEY (id),

    -- 'alert_config' se retiro: no existe tabla de configuracion de alertas en
    -- este esquema. Las 9 tablas del diseno son las unicas entidades auditables.
    CONSTRAINT sla_audit_entity_ck
        CHECK (entity_type IN (
            'policy_version', 'commitment', 'cycle', 'event',
            'article', 'alert', 'divergence', 'sync_run'
        )),

    CONSTRAINT sla_audit_action_ck
        CHECK (action IN (
            'create', 'publish', 'deactivate', 'correct',
            'assign', 'reclassify', 'open_cycle', 'close_cycle'
        )),

    CONSTRAINT sla_audit_actor_ck
        CHECK (actor_type IN ('human', 'service')),

    -- Motivo obligatorio en las acciones que alteran significado.
    CONSTRAINT sla_audit_reason_ck
        CHECK (action NOT IN ('correct', 'publish', 'deactivate', 'reclassify') OR reason IS NOT NULL),

    -- Una reclasificacion registra el valor anterior y el nuevo. Sin ambos no
    -- hay evidencia de que el cambio sea auditable.
    CONSTRAINT sla_audit_reclassify_values_ck
        CHECK (action <> 'reclassify' OR (old_value IS NOT NULL AND new_value IS NOT NULL))
);

COMMENT ON TABLE sla_audit IS
  'Auditoria de decisiones del motor. Solo insercion: el rol runtime no recibe UPDATE ni DELETE.';

COMMENT ON COLUMN sla_audit.action IS
  'reclassify registra la reclasificacion manual: valor anterior, valor nuevo, actor y motivo. Nunca modifica el compromiso congelado.';

CREATE INDEX sla_audit_entity_idx
    ON sla_audit (entity_type, entity_id, created_at);

CREATE INDEX sla_audit_created_idx
    ON sla_audit (created_at);

-- ============================================================================
-- 8. sla_divergence
-- Inconsistencias detectadas entre Zammad y el motor.
-- ============================================================================
CREATE TABLE sla_divergence (
    id              uuid        NOT NULL DEFAULT gen_random_uuid(),

    ticket_id       integer     NOT NULL,
    commitment_id   uuid,

    kind            text        NOT NULL,
    detail          jsonb       NOT NULL,

    detected_at     timestamptz NOT NULL DEFAULT now(),
    resolved_at     timestamptz,
    resolution      text,

    CONSTRAINT sla_divergence_pk PRIMARY KEY (id),

    CONSTRAINT sla_divergence_commitment_fk
        FOREIGN KEY (commitment_id) REFERENCES sla_commitment (id)
        ON DELETE SET NULL ON UPDATE RESTRICT,

    CONSTRAINT sla_divergence_kind_ck
        CHECK (kind IN (
            'missing_close', 'missing_reopen', 'policy_mismatch',
            'orphan_ticket', 'delivery_unresolved', 'late_classification',
            'merged_ticket', 'non_email_ticket', 'delivery_date_missing',
            'catalog_mirror_mismatch'
        )),

    CONSTRAINT sla_divergence_resolution_ck
        CHECK ((resolved_at IS NULL) = (resolution IS NULL))
);

COMMENT ON TABLE sla_divergence IS
  'Divergencias detectadas por reconciliacion o por clasificacion manual. Nunca se corrigen en silencio.';

COMMENT ON COLUMN sla_divergence.kind IS
  'catalog_mirror_mismatch registra que el espejo categoria_subcategoria de Zammad difiere del BFF (DT-01). Prevalece el BFF.';

-- Una sola divergencia abierta por ticket y tipo.
CREATE UNIQUE INDEX sla_divergence_open_uq
    ON sla_divergence (ticket_id, kind)
    WHERE resolved_at IS NULL;

CREATE INDEX sla_divergence_open_idx
    ON sla_divergence (detected_at)
    WHERE resolved_at IS NULL;

-- ============================================================================
-- 9. sla_sync_run
-- Evidencia de cada ciclo de sondeo o reconciliacion.
-- ============================================================================
CREATE TABLE sla_sync_run (
    id                uuid        NOT NULL DEFAULT gen_random_uuid(),

    kind              text        NOT NULL,
    window_from       timestamptz NOT NULL,
    window_to         timestamptz NOT NULL,

    watermark_before  timestamptz,
    watermark_after   timestamptz,

    tickets_read      integer     NOT NULL DEFAULT 0,
    events_created    integer     NOT NULL DEFAULT 0,

    status            text        NOT NULL DEFAULT 'running',
    error             text,

    started_at        timestamptz NOT NULL DEFAULT now(),
    finished_at       timestamptz,

    CONSTRAINT sla_sync_run_pk PRIMARY KEY (id),

    CONSTRAINT sla_sync_run_kind_ck
        CHECK (kind IN ('open_tickets', 'critical_window', 'incremental', 'daily', 'weekly_integrity')),

    CONSTRAINT sla_sync_run_status_ck
        CHECK (status IN ('running', 'ok', 'failed')),

    CONSTRAINT sla_sync_run_window_ck
        CHECK (window_to >= window_from),

    -- El watermark solo es exigible al sondeo incremental: los demas tipos
    -- leen ventanas cerradas o barridos completos y no lo consumen.
    CONSTRAINT sla_sync_run_ok_ck
        CHECK (status <> 'ok' OR kind <> 'incremental' OR watermark_after IS NOT NULL),

    CONSTRAINT sla_sync_run_watermark_ck
        CHECK (watermark_after IS NULL OR watermark_before IS NULL OR watermark_after >= watermark_before),

    CONSTRAINT sla_sync_run_finished_ck
        CHECK ((status = 'running') = (finished_at IS NULL)),

    CONSTRAINT sla_sync_run_error_ck
        CHECK (status <> 'failed' OR error IS NOT NULL),

    CONSTRAINT sla_sync_run_counters_ck
        CHECK (tickets_read >= 0 AND events_created >= 0)
);

COMMENT ON TABLE sla_sync_run IS
  'Evidencia de cada sondeo o reconciliacion. Un run failed no avanza el watermark.';

COMMENT ON COLUMN sla_sync_run.watermark_after IS
  'Watermark efectivo = watermark_after del ultimo run ok de tipo incremental.';

CREATE INDEX sla_sync_run_kind_idx
    ON sla_sync_run (kind, status, finished_at DESC);

CREATE INDEX sla_sync_run_started_idx
    ON sla_sync_run (started_at);

COMMIT;

-- ============================================================================
-- FIN DEL DISENO 001. No se ejecuto.
-- ============================================================================
