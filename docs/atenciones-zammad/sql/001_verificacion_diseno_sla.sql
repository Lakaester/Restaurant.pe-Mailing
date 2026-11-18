-- ============================================================================
-- EPIC-SLA-01 · VERIFICACION ESTRUCTURAL DEL DISENO 001
--
-- ARCHIVO DE DISENO. NO EJECUTADO.
--
-- Solo lectura. Comprueba que el DDL aplicado tiene exactamente las tablas,
-- restricciones, claves foraneas e indices que declara el diseno, y que no
-- existen triggers ni datos.
--
-- Uso previsto: despues de aplicar 001_diseno_esquema_sla.sql sobre
-- `restaurant_bi_test`, y ANTES de la carga inicial de politicas.
--
-- No escribe, no crea, no altera y no borra nada.
-- ============================================================================

BEGIN TRANSACTION READ ONLY;

DO $$
BEGIN
  IF current_database() <> 'restaurant_bi_test' THEN
    RAISE EXCEPTION
      'Verificacion SLA bloqueada: se esperaba restaurant_bi_test y la conexion apunta a "%".',
      current_database();
  END IF;
END
$$;

-- ============================================================================
-- 1. Tablas esperadas
-- ============================================================================
WITH esperadas (tabla) AS (
    VALUES
      ('sla_policy_version'),
      ('sla_commitment'),
      ('sla_cycle'),
      ('sla_event'),
      ('sla_article_delivery'),
      ('sla_alert'),
      ('sla_audit'),
      ('sla_divergence'),
      ('sla_sync_run')
), reales AS (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
      AND table_name LIKE 'sla\_%'
)
SELECT
    '1. tablas'                                   AS bloque,
    e.tabla                                       AS objeto,
    'existe'                                      AS esperado,
    CASE WHEN r.table_name IS NULL THEN 'AUSENTE' ELSE 'OK' END AS obtenido,
    CASE WHEN r.table_name IS NULL THEN 'REVISAR' ELSE 'OK' END AS estado
FROM esperadas e
LEFT JOIN reales r ON r.table_name = e.tabla
ORDER BY e.tabla;

WITH reales AS (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
      AND table_name LIKE 'sla\_%'
)
SELECT
    '1. tablas'                                   AS bloque,
    'tablas sla_* no previstas'                   AS objeto,
    '0'                                           AS esperado,
    count(*)::text                                AS obtenido,
    CASE WHEN count(*) = 0 THEN 'OK' ELSE 'REVISAR' END AS estado
FROM reales
WHERE table_name NOT IN (
    'sla_policy_version', 'sla_commitment', 'sla_cycle', 'sla_event',
    'sla_article_delivery', 'sla_alert', 'sla_audit', 'sla_divergence',
    'sla_sync_run'
);

-- ============================================================================
-- 2. Restricciones CHECK (100 esperadas)
-- ============================================================================
WITH esperadas (tabla, restriccion) AS (
    VALUES
      -- sla_policy_version (22)
      ('sla_policy_version', 'sla_policy_version_channel_ck'),
      ('sla_policy_version', 'sla_policy_version_class_ck'),
      ('sla_policy_version', 'sla_policy_version_status_ck'),
      ('sla_policy_version', 'sla_policy_version_confidence_ck'),
      ('sla_policy_version', 'sla_policy_version_fr_ck'),
      ('sla_policy_version', 'sla_policy_version_fr_required_ck'),
      ('sla_policy_version', 'sla_policy_version_resolution_ck'),
      ('sla_policy_version', 'sla_policy_version_sample_ck'),
      ('sla_policy_version', 'sla_policy_version_provisional_ck'),
      ('sla_policy_version', 'sla_policy_version_matrix_ck'),
      ('sla_policy_version', 'sla_policy_version_insufficient_ck'),
      ('sla_policy_version', 'sla_policy_version_excluded_ck'),
      ('sla_policy_version', 'sla_policy_version_active_ck'),
      ('sla_policy_version', 'sla_policy_version_fallback_key_ck'),
      ('sla_policy_version', 'sla_policy_version_named_key_ck'),
      ('sla_policy_version', 'sla_policy_version_key_format_ck'),
      ('sla_policy_version', 'sla_policy_version_resolution_ladder_ck'),
      ('sla_policy_version', 'sla_policy_version_fallback_minutes_ck'),
      ('sla_policy_version', 'sla_policy_version_excluded_fr_ck'),
      ('sla_policy_version', 'sla_policy_version_matrix_evidence_ck'),
      ('sla_policy_version', 'sla_policy_version_insufficient_evidence_ck'),
      ('sla_policy_version', 'sla_policy_version_validity_ck'),
      -- sla_commitment (24)
      ('sla_commitment', 'sla_commitment_status_ck'),
      ('sla_commitment', 'sla_commitment_class_ck'),
      ('sla_commitment', 'sla_commitment_channel_ck'),
      ('sla_commitment', 'sla_commitment_fr_ck'),
      ('sla_commitment', 'sla_commitment_outcome_ck'),
      ('sla_commitment', 'sla_commitment_source_ck'),
      ('sla_commitment', 'sla_commitment_policy_pair_ck'),
      ('sla_commitment', 'sla_commitment_provisional_ck'),
      ('sla_commitment', 'sla_commitment_assigned_ck'),
      ('sla_commitment', 'sla_commitment_assigned_class_ck'),
      ('sla_commitment', 'sla_commitment_dues_ck'),
      ('sla_commitment', 'sla_commitment_first_due_presence_ck'),
      ('sla_commitment', 'sla_commitment_no_policy_ck'),
      ('sla_commitment', 'sla_commitment_excluded_ck'),
      ('sla_commitment', 'sla_commitment_pending_ck'),
      ('sla_commitment', 'sla_commitment_historical_ck'),
      ('sla_commitment', 'sla_commitment_non_email_ck'),
      ('sla_commitment', 'sla_commitment_due_order_ck'),
      ('sla_commitment', 'sla_commitment_first_due_ck'),
      ('sla_commitment', 'sla_commitment_fr_met_ck'),
      ('sla_commitment', 'sla_commitment_fr_pending_ck'),
      ('sla_commitment', 'sla_commitment_fr_after_start_ck'),
      ('sla_commitment', 'sla_commitment_reclassified_ck'),
      ('sla_commitment', 'sla_commitment_late_ck'),
      -- sla_cycle (15)
      ('sla_cycle', 'sla_cycle_number_ck'),
      ('sla_cycle', 'sla_cycle_outcome_ck'),
      ('sla_cycle', 'sla_cycle_exclusion_ck'),
      ('sla_cycle', 'sla_cycle_reopen_hint_ck'),
      ('sla_cycle', 'sla_cycle_open_closed_ck'),
      ('sla_cycle', 'sla_cycle_final_closed_ck'),
      ('sla_cycle', 'sla_cycle_met_ck'),
      ('sla_cycle', 'sla_cycle_missed_ck'),
      ('sla_cycle', 'sla_cycle_excluded_reason_ck'),
      ('sla_cycle', 'sla_cycle_closed_order_ck'),
      ('sla_cycle', 'sla_cycle_due_order_ck'),
      ('sla_cycle', 'sla_cycle_missed_at_birth_ck'),
      ('sla_cycle', 'sla_cycle_open_needs_due_ck'),
      ('sla_cycle', 'sla_cycle_missed_at_birth_due_ck'),
      ('sla_cycle', 'sla_cycle_closed_actor_ck'),
      -- sla_event (9)
      ('sla_event', 'sla_event_key_len_ck'),
      ('sla_event', 'sla_event_key_hex_ck'),
      ('sla_event', 'sla_event_type_ck'),
      ('sla_event', 'sla_event_source_ck'),
      ('sla_event', 'sla_event_status_ck'),
      ('sla_event', 'sla_event_applied_ck'),
      ('sla_event', 'sla_event_attempts_ck'),
      ('sla_event', 'sla_event_version_ck'),
      ('sla_event', 'sla_event_reason_ck'),
      -- sla_article_delivery (10)
      ('sla_article_delivery', 'sla_article_delivery_channel_ck'),
      ('sla_article_delivery', 'sla_article_delivery_state_ck'),
      ('sla_article_delivery', 'sla_article_delivery_source_ck'),
      ('sla_article_delivery', 'sla_article_delivery_accepted_ck'),
      ('sla_article_delivery', 'sla_article_delivery_accepted_source_ck'),
      ('sla_article_delivery', 'sla_article_delivery_failed_at_ck'),
      ('sla_article_delivery', 'sla_article_delivery_definitivo_ck'),
      ('sla_article_delivery', 'sla_article_delivery_provisional_ck'),
      ('sla_article_delivery', 'sla_article_delivery_message_len_ck'),
      ('sla_article_delivery', 'sla_article_delivery_retry_ck'),
      -- sla_alert (5)
      ('sla_alert', 'sla_alert_metric_ck'),
      ('sla_alert', 'sla_alert_threshold_ck'),
      ('sla_alert', 'sla_alert_channel_ck'),
      ('sla_alert', 'sla_alert_status_ck'),
      ('sla_alert', 'sla_alert_sent_ck'),
      -- sla_audit (5)
      ('sla_audit', 'sla_audit_entity_ck'),
      ('sla_audit', 'sla_audit_action_ck'),
      ('sla_audit', 'sla_audit_actor_ck'),
      ('sla_audit', 'sla_audit_reason_ck'),
      ('sla_audit', 'sla_audit_reclassify_values_ck'),
      -- sla_divergence (2)
      ('sla_divergence', 'sla_divergence_kind_ck'),
      ('sla_divergence', 'sla_divergence_resolution_ck'),
      -- sla_sync_run (8)
      ('sla_sync_run', 'sla_sync_run_kind_ck'),
      ('sla_sync_run', 'sla_sync_run_status_ck'),
      ('sla_sync_run', 'sla_sync_run_window_ck'),
      ('sla_sync_run', 'sla_sync_run_ok_ck'),
      ('sla_sync_run', 'sla_sync_run_watermark_ck'),
      ('sla_sync_run', 'sla_sync_run_finished_ck'),
      ('sla_sync_run', 'sla_sync_run_error_ck'),
      ('sla_sync_run', 'sla_sync_run_counters_ck')
), reales AS (
    SELECT c.relname AS tabla, con.conname AS restriccion
    FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'c'
      AND c.relname LIKE 'sla\_%'
)
SELECT
    '2. checks'                                   AS bloque,
    e.tabla || ' / ' || e.restriccion             AS objeto,
    'existe'                                      AS esperado,
    CASE WHEN r.restriccion IS NULL THEN 'AUSENTE' ELSE 'OK' END AS obtenido,
    CASE WHEN r.restriccion IS NULL THEN 'REVISAR' ELSE 'OK' END AS estado
FROM esperadas e
LEFT JOIN reales r
       ON r.tabla = e.tabla
      AND r.restriccion = e.restriccion
ORDER BY e.tabla, e.restriccion;

WITH reales AS (
    SELECT con.conname
    FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'c'
      AND c.relname LIKE 'sla\_%'
)
SELECT
    '2. checks'                                   AS bloque,
    'checks no previstos'                         AS objeto,
    '0'                                           AS esperado,
    count(*)::text                                AS obtenido,
    CASE WHEN count(*) = 0 THEN 'OK' ELSE 'REVISAR' END AS estado
FROM reales
WHERE conname NOT LIKE 'sla\_%\_ck';

-- ============================================================================
-- 3. Claves foraneas (4 esperadas)
-- ============================================================================
WITH esperadas (restriccion, origen, destino) AS (
    VALUES
      ('sla_commitment_policy_fk', 'sla_commitment', 'sla_policy_version'),
      ('sla_cycle_commitment_fk',  'sla_cycle',      'sla_commitment'),
      ('sla_alert_cycle_fk',       'sla_alert',      'sla_cycle'),
      ('sla_divergence_commitment_fk', 'sla_divergence', 'sla_commitment')
), reales AS (
    SELECT con.conname AS restriccion
    FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'f'
      AND c.relname LIKE 'sla\_%'
)
SELECT
    '3. claves foraneas'                          AS bloque,
    e.restriccion                                 AS objeto,
    e.origen || ' -> ' || e.destino               AS esperado,
    CASE WHEN r.restriccion IS NULL THEN 'AUSENTE' ELSE 'OK' END AS obtenido,
    CASE WHEN r.restriccion IS NULL THEN 'REVISAR' ELSE 'OK' END AS estado
FROM esperadas e
LEFT JOIN reales r ON r.restriccion = e.restriccion
ORDER BY e.restriccion;

WITH reales AS (
    SELECT count(*) AS n
    FROM pg_constraint con
    JOIN pg_class c ON c.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'f'
      AND c.relname LIKE 'sla\_%'
)
SELECT
    '3. claves foraneas'                          AS bloque,
    'total de claves foraneas'                    AS objeto,
    '4'                                           AS esperado,
    n::text                                       AS obtenido,
    CASE WHEN n = 4 THEN 'OK' ELSE 'REVISAR' END  AS estado
FROM reales;

-- ============================================================================
-- 4. Indices (24 con nombre propio)
-- ============================================================================
WITH esperadas (tabla, indice) AS (
    VALUES
      ('sla_policy_version', 'sla_policy_version_vigente_uq'),
      ('sla_policy_version', 'sla_policy_version_lookup_idx'),
      ('sla_policy_version', 'sla_policy_version_status_idx'),
      ('sla_commitment', 'sla_commitment_status_idx'),
      ('sla_commitment', 'sla_commitment_resolution_due_idx'),
      ('sla_commitment', 'sla_commitment_first_response_due_idx'),
      ('sla_commitment', 'sla_commitment_started_idx'),
      ('sla_cycle', 'sla_cycle_open_uq'),
      ('sla_cycle', 'sla_cycle_commitment_idx'),
      ('sla_cycle', 'sla_cycle_due_idx'),
      ('sla_cycle', 'sla_cycle_closed_idx'),
      ('sla_event', 'sla_event_pending_idx'),
      ('sla_event', 'sla_event_ticket_idx'),
      ('sla_event', 'sla_event_type_idx'),
      ('sla_event', 'sla_event_occurred_idx'),
      ('sla_article_delivery', 'sla_article_delivery_ticket_idx'),
      ('sla_article_delivery', 'sla_article_delivery_pending_idx'),
      ('sla_alert', 'sla_alert_pending_idx'),
      ('sla_audit', 'sla_audit_entity_idx'),
      ('sla_audit', 'sla_audit_created_idx'),
      ('sla_divergence', 'sla_divergence_open_uq'),
      ('sla_divergence', 'sla_divergence_open_idx'),
      ('sla_sync_run', 'sla_sync_run_kind_idx'),
      ('sla_sync_run', 'sla_sync_run_started_idx')
), reales AS (
    SELECT tablename AS tabla, indexname AS indice, indexdef
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename LIKE 'sla\_%'
)
SELECT
    '4. indices'                                  AS bloque,
    e.tabla || ' / ' || e.indice                  AS objeto,
    'existe'                                      AS esperado,
    CASE WHEN r.indice IS NULL THEN 'AUSENTE' ELSE 'OK' END AS obtenido,
    CASE WHEN r.indice IS NULL THEN 'REVISAR' ELSE 'OK' END AS estado
FROM esperadas e
LEFT JOIN reales r
       ON r.tabla = e.tabla
      AND r.indice = e.indice
ORDER BY e.tabla, e.indice;

-- Los tres indices parciales deben conservar su predicado.
WITH parciales (indice, fragmento) AS (
    VALUES
      ('sla_policy_version_vigente_uq', 'WHERE'),
      ('sla_cycle_open_uq',             'closed_at IS NULL'),
      ('sla_divergence_open_uq',        'resolved_at IS NULL')
)
SELECT
    '4. indices'                                  AS bloque,
    p.indice                                      AS objeto,
    'definicion contiene: ' || p.fragmento        AS esperado,
    CASE WHEN i.indexdef ILIKE '%' || p.fragmento || '%' THEN 'OK' ELSE 'NO' END AS obtenido,
    CASE
      WHEN i.indexname IS NULL THEN 'REVISAR'
      WHEN i.indexdef ILIKE '%' || p.fragmento || '%' THEN 'OK'
      ELSE 'REVISAR'
    END                                           AS estado
FROM parciales p
LEFT JOIN pg_indexes i
       ON i.schemaname = 'public'
      AND i.indexname = p.indice
ORDER BY p.indice;

-- ============================================================================
-- 5. Sin triggers
-- ============================================================================
SELECT
    '5. triggers'                                 AS bloque,
    'triggers sobre tablas sla_*'                 AS objeto,
    '0'                                           AS esperado,
    count(*)::text                                AS obtenido,
    CASE WHEN count(*) = 0 THEN 'OK' ELSE 'REVISAR' END AS estado
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname LIKE 'sla\_%'
  AND NOT t.tgisinternal;

-- ============================================================================
-- 6. Tablas vacias antes de la carga inicial
-- ============================================================================
SELECT
    '6. datos'                                    AS bloque,
    'filas en ' || c.relname                     AS objeto,
    '0'                                           AS esperado,
    (xpath('/row/n/text()',
       query_to_xml(
         format('SELECT count(*) AS n FROM public.%I', c.relname),
         false, true, ''
       )
    ))[1]::text                                   AS obtenido,
    CASE
      WHEN (xpath('/row/n/text()',
              query_to_xml(
                format('SELECT count(*) AS n FROM public.%I', c.relname),
                false, true, ''
              )
           ))[1]::text = '0' THEN 'OK'
      ELSE 'REVISAR'
    END                                           AS estado
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname LIKE 'sla\_%'
ORDER BY c.relname;

-- ============================================================================
-- 7. Privilegios de sla_audit (append-only)
-- ============================================================================
SELECT
    '7. privilegios'                              AS bloque,
    coalesce(g.grantee, '(sin privilegios registrados)') AS objeto,
    'cope_test_runtime sin UPDATE ni DELETE'      AS esperado,
    coalesce(string_agg(g.privilege_type, ', ' ORDER BY g.privilege_type), '(ninguno)') AS obtenido,
    CASE
      WHEN g.grantee = 'cope_test_runtime'
       AND g.privilege_type IN ('UPDATE', 'DELETE') THEN 'REVISAR'
      ELSE 'OK'
    END                                           AS estado
FROM information_schema.role_table_grants g
WHERE g.table_schema = 'public'
  AND g.table_name = 'sla_audit'
GROUP BY g.grantee;

-- ============================================================================
-- 8. Funcion requerida
-- ============================================================================
SELECT
    '8. funcion'                                  AS bloque,
    'gen_random_uuid()'                           AS objeto,
    'disponible'                                  AS esperado,
    CASE WHEN gen_random_uuid() IS NOT NULL THEN 'OK' ELSE 'NO' END AS obtenido,
    CASE WHEN gen_random_uuid() IS NOT NULL THEN 'OK' ELSE 'REVISAR' END AS estado;

COMMIT;

-- ============================================================================
-- FIN DE LA VERIFICACION. No se ejecuto.
-- ============================================================================
