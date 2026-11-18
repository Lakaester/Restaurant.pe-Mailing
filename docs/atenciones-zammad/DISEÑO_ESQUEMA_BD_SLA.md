# DISEÑO DEL ESQUEMA DE BASE DE DATOS DEL MOTOR SLA — EPIC-SLA-01

**Fecha:** 17/11/2026
**Repositorio del backend:** `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi`
**Rama:** `remediation/audit` · **HEAD:** `27b973a`
**Modulo previsto:** `backend/src/domain/sla/`
**Estado:** **DISENO REVISADO. No ejecutado.** No se creo ninguna tabla, indice, restriccion, rol ni base de datos. La revision integral del 17/11/2026 y el estado de cada decision estan en §K y §I.

Documentos de los que se deriva este diseno:

| Documento | Uso |
|---|---|
| `EPIC_IMPLEMENTACION_SLA_COSE.md` v1.1 | Reglas BR, criterios AC, modelo de 9 tablas (§7.3) |
| `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md` | Columnas, restricciones e indices de referencia |
| `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` | Modelo previo; se documentan sus diferencias |
| `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` | 30 combinaciones, 27 con SLA y 3 sin evidencia |
| `ACTA_ENTREGA_CIERRE_HITO_EPIC_SLA_01.md` | Decisiones DT-01, DT-02, DP-04, DEC-05 |
| `REGLAS_DEFINITIVAS_PRIMERA_RESPUESTA_EMAIL_5G4_5.md` | Primera respuesta `< 86.400 s` estricto |
| `PLAN_DESBLOQUEO_IMPLEMENTACION_SLA.md` | Procedimiento M1–M8 y condiciones de inicio |

---

## A. Modelo conceptual

### A.1 Entidades y responsabilidad

| # | Tabla | Responsabilidad unica | Cardinalidad |
|---:|---|---|---|
| 1 | `sla_policy_version` | Catalogo versionado e inmutable de politicas de correo | 1 → N compromisos |
| 2 | `sla_commitment` | Snapshot congelado por ticket: que se prometio y cuando vence | 1 → N ciclos |
| 3 | `sla_cycle` | Cada intento de resolucion: ciclo 1 oficial, 2..N reaperturas | N por compromiso |
| 4 | `sla_event` | Hechos idempotentes; registro de verdad reconstruible | N por ticket |
| 5 | `sla_article_delivery` | Estado de entrega por articulo de correo | 1 por articulo |
| 6 | `sla_alert` | Una alerta por compromiso, ciclo, metrica y umbral | N por ciclo |
| 7 | `sla_audit` | Auditoria append-only de decisiones | N por entidad |
| 8 | `sla_divergence` | Inconsistencias detectadas, con evidencia y resolucion | N por ticket |
| 9 | `sla_sync_run` | Evidencia de sondeo/reconciliacion y watermark | Independiente |

### A.2 Relaciones

```
sla_policy_version (1) ───< (N) sla_commitment (1) ───< (N) sla_cycle ───< (N) sla_alert
                                     │
                                     ├───< (N) sla_divergence
                                     └───< (N) sla_audit        (referencia generica)

sla_event ──────────► ticket_id / article_id     (logico, Zammad)
sla_article_delivery ► article_id                (logico, Zammad)
sla_sync_run         (independiente)
```

**Claves externas logicas:** `ticket_id`, `ticket_number`, `article_id` y `closed_by_actor_id` provienen de Zammad por REST. No hay FK a Zammad porque es otra base de datos y no se permite dependencia directa. La integridad de esos valores se garantiza por ingesta idempotente y por `sla_divergence`.

**Referencias logicas a proposito:** `sla_cycle.opened_by_event_id` y `closed_by_event_id` no llevan FK. Los eventos se conservan 2 anos y los ciclos son permanentes; una FK romperia la retencion o impediria el borrado de eventos.

### A.3 Que se obtiene por REST y que es propio del BFF

| Dato | Origen | Persistencia local |
|---|---|---|
| `ticket.created_at`, `number`, `state`, `group` | Zammad REST (GET) | Copia en `sla_commitment` como snapshot |
| Articulos (`internal`, `sender`, `type`, `delivery_status`, `delivery_status_date`, `delivery_retry`) | Zammad REST (GET) | Derivado en `sla_article_delivery` |
| Historial de estados (`close_at`, `last_close_at`) | Zammad REST (GET) | Hechos en `sla_event`; cierres en `sla_cycle` |
| Categoria y subcategoria oficial | **BFF** (clasificacion manual) | `sla_commitment.category`, `subcategory` |
| Politica y duracion comprometida | **BFF** (matriz aprobada) | `sla_policy_version` + snapshot |
| Vencimientos, outcomes, ciclos | **BFF** (calculo) | `sla_commitment`, `sla_cycle` |
| Alertas | **BFF** | `sla_alert` |
| Auditoria de decisiones | **BFF** | `sla_audit` |
| Divergencias | **BFF** (reconciliacion) | `sla_divergence` |
| Watermark y evidencia de sync | **BFF** | `sla_sync_run` |

**Nunca se persiste:** cuerpo de correo, asunto completo, adjuntos, direcciones, telefonos, tokens, cabeceras SMTP. Solo identificadores, marcas de tiempo y metadatos (BR-63).

### A.4 Flujo de datos

```
Zammad REST ──sondeo (5/15 min, 2 min en ventana critica)──► normalizacion
                                                                │
                                                    sla_event (idempotente)
                                                                │
                    ┌───────────────────────────────────────────┤
                    ▼                                           ▼
        clasificacion manual (BFF)                    deteccion de primera respuesta
                    │                                           │
        sla_policy_version (vigente)                  sla_article_delivery
                    │                                           │
                    └──────────► sla_commitment ◄───────────────┘
                                      │
                              sla_cycle (1..N)
                                      │
                        ┌─────────────┼─────────────┐
                        ▼             ▼             ▼
                   sla_alert    sla_divergence   sla_audit
                                      │
                                 metricas (consulta, sin escritura)
```

### A.5 Dependencias

| Dependencia | Estado |
|---|---|
| Base `restaurant_bi_test` | **Pendiente de DBA** (BLK-05) |
| Procedimiento M1–M8 aprobado | **Pendiente** (BLK-06) |
| Homologacion catalogo ↔ matriz | **Resuelta tecnicamente**: 65 filas, 27/3/28/7, 0 errores; ratificacion de Soporte pendiente |
| Decision REA-02 (vencimiento en reapertura) | **Pendiente**; las variantes A y B caben en el esquema, C no (§C.7) |
| Compromiso de no escribir en Zammad | Aprobado (solo GET) |

---

## B. Diccionario de datos

Convenciones comunes:

- Todos los instantes son `timestamptz` en UTC. Sin `timestamp` sin zona.
- Todos los `id` tecnicos son `uuid` con `gen_random_uuid()`.
- Los identificadores de Zammad son `integer` (los tickets y articulos son enteros en Zammad).
- Los minutos son `integer`; los estadisticos son `numeric(10,2)`.
- `created_at` existe en todas las tablas. `updated_at` solo donde hay mutacion legitima.

### B.1 `sla_policy_version`

**Proposito:** catalogo versionado. Una fila es inmutable una vez publicada; un cambio crea una version nueva.

| Columna | Tipo | Nulo | Default | Descripcion |
|---|---|---|---|---|
| `id` | uuid | No | `gen_random_uuid()` | PK |
| `policy_key` | text | No | — | `20-MAIL-<CAT>-<SUB>` normalizada o `99-FALLBACK` |
| `version` | integer | No | — | Desde 1 |
| `policy_class` | text | No | — | `matrix`, `insufficient_evidence`, `fallback`, `excluded_non_service` |
| `matrix_version` | text | No | — | Version de la matriz aplicada |
| `channel` | text | No | — | Siempre `email` |
| `category` | text | No | — | Etiqueta oficial del catalogo |
| `subcategory` | text | No | — | Etiqueta oficial del catalogo |
| `first_response_minutes` | integer | Si | — | 1.440; `NULL` solo en exclusiones |
| `resolution_minutes` | integer | Si | — | Duracion comprometida; `NULL` = sin evidencia |
| `provisional` | boolean | No | `false` | `true` solo en `99-FALLBACK` |
| `status` | text | No | — | `draft`, `active`, `inactive`, `pending` |
| `sample_size` | integer | Si | — | n de la matriz |
| `p75_minutes` | numeric(10,2) | Si | — | P75 de referencia |
| `confidence` | text | Si | — | `ALTA`, `MEDIA`, `BAJA`, `INSUFICIENTE` |
| `valid_from` | timestamptz | No | — | Inicio de vigencia |
| `valid_to` | timestamptz | Si | — | `NULL` = vigente |
| `created_by` | text | No | — | Responsable |
| `created_at` | timestamptz | No | `now()` | — |
| `reason` | text | No | — | Motivo del alta o cambio |

- **PK:** `id`. **FK:** ninguna.
- **Unicidad:** `(policy_key, version)`; indice unico parcial `(channel, category, subcategory)` donde `valid_to IS NULL AND status = 'active'`.
- **Restricciones:** `channel = 'email'`; `first_response_minutes = 1440` cuando no es nulo; `provisional = (policy_class = 'fallback')`; `matrix` exige `resolution_minutes`, `sample_size >= 10`, `p75_minutes` y `confidence`; `insufficient_evidence` exige `resolution_minutes IS NULL AND status = 'pending' AND sample_size < 10`; `excluded_non_service` exige `resolution_minutes IS NULL`, `status = 'inactive'` y primera respuesta nula; `99-FALLBACK` exige `category = '*'`, `subcategory = '*'` y 2.160 min; `policy_key` debe ser `99-FALLBACK` o empezar por `20-MAIL-`; `resolution_minutes` debe pertenecer a la escalera oficial de 17 valores; `valid_to > valid_from`.
- **Indices:** lookup por `(channel, category, subcategory)`; `(status)`.
- **Obligatorios:** todos salvo los marcados como nulos.
- **Auditables:** publicacion, desactivacion y correccion se registran en `sla_audit` con motivo.

### B.2 `sla_commitment`

**Proposito:** un compromiso por ticket, congelado en el momento de clasificar.

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `ticket_id` | integer | No | Ticket de Zammad; unico |
| `ticket_number` | text | No | Numero visible |
| `policy_version_id` | uuid | Si | FK a la politica aplicada |
| `assignment_status` | text | No | Estado del compromiso |
| `policy_key` | text | Si | Snapshot |
| `policy_version` | integer | Si | Snapshot |
| `policy_class` | text | Si | Snapshot |
| `channel` | text | Si | Snapshot; siempre `email` |
| `category` | text | Si | Snapshot |
| `subcategory` | text | Si | Snapshot |
| `first_response_minutes` | integer | Si | Snapshot; 1.440 |
| `resolution_minutes` | integer | Si | Snapshot |
| `provisional` | boolean | No | Snapshot |
| `started_at` | timestamptz | Si | `created_at` del ticket |
| `classified_at` | timestamptz | Si | Momento de clasificacion manual |
| `assigned_at` | timestamptz | Si | Momento de congelamiento |
| `first_response_due_at` | timestamptz | Si | `started_at + 1440 min` |
| `resolution_due_at` | timestamptz | Si | `started_at + resolution_minutes` |
| `first_response_at` | timestamptz | Si | Marca del primer articulo valido |
| `first_response_article_id` | integer | Si | Articulo que cumple |
| `first_response_source` | text | Si | `delivery_status_date` o `updated_at_fallback` |
| `first_response_outcome` | text | Si | `met`, `missed`, `pending`, `not_applicable` |
| `reclassified_count` | integer | No | Contador de reclasificaciones |
| `late_classification` | boolean | No | Clasificado despues de su plazo |
| `activation_at` | timestamptz | No | Corte de historico vigente |
| `last_seen_state` | text | Si | Ultimo estado observado |
| `last_seen_updated_at` | timestamptz | Si | Ultimo `updated_at` procesado |
| `created_at` | timestamptz | No | — |
| `updated_at` | timestamptz | No | Solo columnas mutables |

- **PK:** `id`. **FK:** `policy_version_id → sla_policy_version(id)` con `ON DELETE RESTRICT`.
- **Unicidad:** `ticket_id` unico: un compromiso por ticket.
- **Restricciones principales:** `assigned` exige política, versión, clase `matrix` o `fallback`, duración, inicio, clasificación y ambos vencimientos; `policy_key` exige `policy_version_id`; `provisional` solo si la clase es `fallback`; los vencimientos existen si y solo si `assignment_status = 'assigned'`; `no_policy` exige versión y clase `insufficient_evidence` con ambas duraciones nulas; `excluded_non_service` exige snapshot de exclusión, duración nula y primera respuesta nula; `pending_classification`, `historical` y `non_email` no llevan política, versión, clase ni duraciones; `first_response_due_at = started_at + interval '1440 minutes'`; `met` exige `first_response_at`, `pending` lo prohíbe y ninguna marca puede ser anterior a `started_at`; `late_classification = true` exige `classified_at > started_at + resolution_minutes`.
- **Indices:** `(assignment_status)`; `(resolution_due_at)` donde `assigned`; `(first_response_due_at)` donde `assigned AND first_response_at IS NULL`; `(started_at)`.
- **Obligatorios:** `ticket_id`, `ticket_number`, `assignment_status`, `provisional`, `activation_at`, `created_at`, `updated_at`.
- **Auditables:** reclasificacion, correccion de primera respuesta y cualquier cambio de snapshot.

### B.3 `sla_cycle`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `commitment_id` | uuid | No | FK al compromiso |
| `cycle_number` | integer | No | 1..N |
| `opened_at` | timestamptz | No | Inicio del ciclo |
| `due_at` | timestamptz | Si | Vencimiento inmutable del ciclo |
| `closed_at` | timestamptz | Si | Primer cierre valido |
| `outcome` | text | No | `open`, `met`, `missed`, `excluded`, `missed_at_birth` |
| `exclusion_reason` | text | Si | `merged`, `ticket_deleted` |
| `reopen_hint` | text | Si | `delivery_failure` |
| `opened_by_event_id` | uuid | Si | Referencia logica a `sla_event` |
| `closed_by_event_id` | uuid | Si | Referencia logica a `sla_event` |
| `closed_by_actor_id` | integer | Si | Usuario de Zammad que cerro |
| `overdue_at_cutoff` | boolean | No | Marca de reporte provisional |
| `created_at` | timestamptz | No | — |

- **PK:** `id`. **FK:** `commitment_id → sla_commitment(id)` con `ON DELETE RESTRICT`.
- **Unicidad:** `(commitment_id, cycle_number)`; índice único parcial `(commitment_id) WHERE closed_at IS NULL`.
- **Restricciones:** `outcome = 'open'` exige `closed_at IS NULL`; `met`, `missed` y `excluded` exigen `closed_at`; `missed_at_birth` puede estar abierto (sin cierre) o cerrado; `met` exige `closed_at <= due_at`; `missed` exige `closed_at > due_at`; `(outcome = 'excluded') = (exclusion_reason IS NOT NULL)`; `closed_at >= opened_at`; `due_at >= opened_at`; `missed_at_birth` solo en ciclo 1 y exige `due_at`; `open` exige `due_at`.
- **Interpretación de `excluded`:** `closed_at` registra el instante de la exclusión (fusión o borrado), no un cierre válido. Las métricas solo cuentan `met` y `missed`, por lo que una exclusión nunca suma resolución.
- **Indices:** `(commitment_id, cycle_number)`; `(due_at)` donde `closed_at IS NULL`; `(closed_at)`.

### B.4 `sla_event`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `idempotency_key` | text | No | `sha256('zammad'\|event_type\|ticket_id\|entity_id\|occurred_at)`; 64 caracteres |
| `event_type` | text | No | Uno de los 15 tipos del catalogo |
| `event_version` | integer | No | Version del contrato del evento |
| `ticket_id` | integer | No | Ticket |
| `article_id` | integer | Si | Articulo, si aplica |
| `entity_id` | text | Si | Entidad del hecho |
| `occurred_at` | timestamptz | No | En Zammad |
| `received_at` | timestamptz | No | En el BFF |
| `source` | text | No | `poll`, `reconcile`, `manual` |
| `payload` | jsonb | No | Metadatos normalizados |
| `status` | text | No | `pending`, `applied`, `ignored`, `failed` |
| `status_reason` | text | Si | Motivo de `ignored` o `failed` |
| `attempts` | integer | No | Intentos de aplicacion |
| `applied_at` | timestamptz | Si | — |

- **Unicidad:** `idempotency_key`; longitud exacta 64.
- **Restricciones:** tipos de evento acotados; `applied` exige `applied_at`.
- **Indices:** `(status, received_at)` donde pendiente o fallido; `(ticket_id, occurred_at)`; `(event_type, occurred_at)`; `(occurred_at)` para retencion.

### B.5 `sla_article_delivery`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `article_id` | integer | No | PK; articulo de Zammad |
| `ticket_id` | integer | No | Ticket |
| `channel` | text | No | Siempre `email` |
| `is_public_agent` | boolean | No | Candidato a primera respuesta |
| `delivery_state` | text | No | `sin_estado`, `aceptado`, `fallido_provisional`, `fallido_definitivo` |
| `accepted_at` | timestamptz | Si | Marca de aceptacion SMTP |
| `accepted_at_source` | text | Si | `delivery_status_date` o `updated_at` |
| `failed_at` | timestamptz | Si | Ultimo fallo |
| `failure_message` | text | Si | Truncado a 500 caracteres |
| `retry_count` | integer | No | `delivery_retry` |
| `last_article_updated_at` | timestamptz | Si | Ultimo `updated_at` leido |
| `created_at` | timestamptz | No | — |

- **PK:** `article_id`. **Sin FK** a compromiso: un articulo puede existir sin compromiso.
- **Restricciones:** `aceptado` exige `accepted_at`; `fallido_definitivo` exige `retry_count > 3`; `fallido_provisional` exige `retry_count <= 3`; `failure_message` de hasta 500 caracteres.
- **Indices:** `(ticket_id)`; `(delivery_state)` donde `sin_estado` o `fallido_provisional`.

### B.6 `sla_alert`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `commitment_id` | uuid | No | Compromiso |
| `cycle_number` | integer | No | Ciclo afectado |
| `metric` | text | No | `first_response`, `resolution` |
| `threshold_pct` | integer | No | 75, 90 o 100 (vencimiento) |
| `due_at` | timestamptz | No | Vencimiento al emitir |
| `triggered_at` | timestamptz | No | — |
| `channel` | text | No | `internal`, `email`, `webhook` |
| `status` | text | No | `pending`, `sent`, `failed` |
| `sent_at` | timestamptz | Si | — |

- **Unicidad:** `(commitment_id, cycle_number, metric, threshold_pct)`.
- **FK compuesta:** `(commitment_id, cycle_number) → sla_cycle(commitment_id, cycle_number)`. Impide alertas de ciclos inexistentes.
- **Indice:** `(status, triggered_at)` donde pendiente.

### B.7 `sla_audit`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `entity_type` | text | No | `policy_version`, `commitment`, `cycle`, `event`, `article`, `alert`, `divergence`, `sync_run` |
| `entity_id` | text | No | Identificador de la entidad |
| `action` | text | No | `create`, `publish`, `deactivate`, `correct`, `assign`, `reclassify`, `open_cycle`, `close_cycle` |
| `actor_type` | text | No | `human`, `service` |
| `actor_id` | text | No | Usuario o servicio |
| `old_value` | jsonb | Si | Valor anterior |
| `new_value` | jsonb | Si | Valor nuevo |
| `reason` | text | Si | Obligatorio en acciones que alteran significado |
| `request_id` | text | Si | Correlacion |
| `created_at` | timestamptz | No | — |

- **Restriccion:** `correct`, `publish`, `deactivate` y `reclassify` exigen `reason`; `reclassify` exige además `old_value` y `new_value`.
- **Solo insercion:** se garantiza por privilegios (`INSERT` y `SELECT` para el rol runtime), no por trigger.
- **Indices:** `(entity_type, entity_id, created_at)`; `(created_at)`.

### B.8 `sla_divergence`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `ticket_id` | integer | No | Ticket |
| `commitment_id` | uuid | Si | FK; `SET NULL` si el compromiso desaparece |
| `kind` | text | No | Tipo acotado (10 valores) |
| `detail` | jsonb | No | Evidencia |
| `detected_at` | timestamptz | No | — |
| `resolved_at` | timestamptz | Si | — |
| `resolution` | text | Si | Accion tomada |

- **Unicidad parcial:** `(ticket_id, kind)` donde `resolved_at IS NULL`. Evita duplicar la misma divergencia abierta.
- **Restriccion:** `(resolved_at IS NULL) = (resolution IS NULL)`.
- **Indice:** `(detected_at)` donde abierta.

### B.9 `sla_sync_run`

| Columna | Tipo | Nulo | Descripcion |
|---|---|---|---|
| `id` | uuid | No | PK |
| `kind` | text | No | `open_tickets`, `critical_window`, `incremental`, `daily`, `weekly_integrity` |
| `window_from` | timestamptz | No | Inicio de la ventana leida |
| `window_to` | timestamptz | No | Fin |
| `watermark_before` | timestamptz | Si | — |
| `watermark_after` | timestamptz | Si | Solo obligatorio si `status = 'ok' AND kind = 'incremental'` |
| `tickets_read` | integer | No | Contador |
| `events_created` | integer | No | Contador |
| `status` | text | No | `running`, `ok`, `failed` |
| `error` | text | Si | Obligatorio si `failed` |
| `started_at` | timestamptz | No | — |
| `finished_at` | timestamptz | Si | — |

- **Restricciones:** `status = 'running'` si y solo si `finished_at IS NULL`; un run `ok` de tipo `incremental` exige `watermark_after`; el watermark no retrocede; `failed` exige `error`.
- **Indice:** `(kind, status, finished_at DESC)`.

---

## C. Reglas de integridad

### C.1 Derivacion de `policy_key`

```
policy_key = '20-MAIL-' || normalizar(categoria) || '-' || normalizar(subcategoria)
normalizar(x) = MAYUSCULAS(sin tildes)(x), con espacios y separadores -> '_'
                y guiones bajos repetidos colapsados
```

Ejemplos verificados contra la especificacion:

| Categoria oficial | Subcategoria oficial | `policy_key` |
|---|---|---|
| SOFTWARE | Error web | `20-MAIL-SOFTWARE-ERROR_WEB` |
| FACTURACION ELECTRONICA | Ajustes FE | `20-MAIL-FACTURACION_ELECTRONICA-AJUSTES_FE` |
| FACTURACION ELECTRONICA | Cambio de razón social | `20-MAIL-FACTURACION_ELECTRONICA-CAMBIO_DE_RAZON_SOCIAL` |

**Decision de diseno justificada:** `category` y `subcategory` guardan la etiqueta oficial **con tildes**, tal como aparece en `CategoryData.ts`. La normalizacion solo se aplica a `policy_key`, porque la matriz oficial escribe `FACTURACION ELECTRONICA` y `CAPACITACION` sin tildes. Tratar ambas grafias como categorias distintas generaria claves divergentes para la misma combinacion.

Verificacion realizada el 17/11/2026 sobre el catalogo exportado: las 30 filas de la matriz encuentran **exactamente una** coincidencia por `(categoria, subcategoria)` al normalizar tildes. No hay filas sin correspondencia.

### C.2 Clasificacion de las 65 subcategorias

| Clase | Cantidad | Tratamiento en el esquema |
|---|---:|---|
| `matrix` | 27 | Fila `active` con `resolution_minutes` de la matriz |
| `insufficient_evidence` | 3 | Fila `pending` con `resolution_minutes NULL` → `assignment_status = 'no_policy'` |
| `fallback` | 28 | Sin fila propia: al asignar se usa `99-FALLBACK` (2.160 min, `provisional = true`) |
| `excluded_non_service` | 7 | Fila `inactive` con `resolution_minutes NULL` → `assignment_status = 'excluded_non_service'` |
| **Total** | **65** | 38 filas en `sla_policy_version` |

Las 3 sin evidencia: `Error FE por duplicidad`, `Solicitud de integracion sistemas contables`, `Error integracion`.

Las 7 excluidas por DEC-05: `SIN HOMOLOGAR / Sin dato`, `SIN HOMOLOGAR / Duplicado o spam`, `SIN HOMOLOGAR / No contestó`, `RECLAMO / Reclamo`, `QUEJA / Servicio`, `QUEJA / Producto`, `QUEJA / Otro`. Sin SLA, sin respaldo de 36 h y fuera de todo denominador.

### C.3 Un compromiso por ciclo y por ticket

- `sla_commitment.ticket_id` es unico: no puede haber dos compromisos para el mismo ticket.
- `sla_cycle(commitment_id, cycle_number)` es unico: cada ciclo tiene un numero distinto.
- Indice unico parcial `(commitment_id) WHERE closed_at IS NULL`: como maximo un ciclo sin cierre por compromiso, sea `open` o `missed_at_birth`.
- La secuencia N+1 se garantiza en la aplicacion: solo se abre un ciclo nuevo si el anterior esta cerrado. El esquema no puede imponerlo sin trigger, y no se crean triggers (regla del encargo).

### C.4 Inmutabilidad del compromiso asignado

Las columnas `policy_key`, `policy_version`, `policy_class`, `channel`, `category`, `subcategory`, `first_response_minutes`, `resolution_minutes`, `provisional`, `started_at`, `classified_at`, `assigned_at`, `first_response_due_at` y `resolution_due_at` solo se escriben al asignar.

**Mecanismo:** regla de aplicacion en el repositorio del motor + registro en `sla_audit` para cualquier correccion. **No se usan triggers** (prohibidos sobre tablas de negocio; y en este repositorio no hay convencion de triggers). La decision trigger vs aplicacion queda registrada en §I.

La reclasificacion **no** modifica esas columnas: incrementa `reclassified_count`, escribe `sla_audit` con `action = 'reclassify'` y motivo, y no toca el compromiso.

### C.5 Identificacion unica del ticket externo

`ticket_id` unico en `sla_commitment`, `article_id` PK en `sla_article_delivery`, y todos los hechos llevan `ticket_id` en `sla_event`. No hay FK a Zammad: la consistencia se comprueba por reconciliacion y se registra en `sla_divergence` (`orphan_ticket`).

### C.6 Eventos duplicados

`idempotency_key` es unico y de 64 caracteres (SHA-256 hexadecimal). La clave se calcula con `'zammad' | event_type | ticket_id | entity_id | occurred_at` en UTC. La insercion del evento y la transicion ocurren en la misma transaccion: si el evento ya existe, se ignora sin error (BR-61).

### C.7 Reaperturas

Una reapertura es la transicion de `closed` a un estado que no es `closed` ni `merged` (BR-36). Abre un ciclo N+1 con la **misma politica congelada** y `due_at = opened_at + resolution_minutes` (BR-38). El ciclo anterior debe estar cerrado. `reopen_hint = 'delivery_failure'` anota la reapertura por fallo definitivo de envio (BR-39).

**Dependencia:** REA-02 sigue sin aprobacion explicita en el EPIC. Hay que distinguir tres variantes:

| Variante | Que implica | Cabe en el DDL |
|---|---|---|
| A. Nuevo ciclo con vencimiento nuevo | `due_at = opened_at + resolution_minutes` | Si |
| B. Sin fila de ciclo para la reapertura | Se conserva el ciclo 1 | Si |
| C. Nuevo ciclo sin vencimiento | `due_at NULL` con `outcome = 'open'` | No: `sla_cycle_open_needs_due_ck` lo impide |

El EPIC describe A como regla. B no requiere cambios. C exigiria relajar una restriccion y no esta autorizada.

### C.8 Primer cierre valido

`closed_at` se escribe una sola vez, en el primer estado de tipo `closed` del ciclo. `pending close` no cierra. `merged` no cierra: el ciclo queda `outcome = 'excluded'` con `exclusion_reason = 'merged'`, y `closed_at` registra el instante de la exclusión, no un cierre válido. Un ticket eliminado se excluye con `exclusion_reason = 'ticket_deleted'` (BR-37 y BR-34). Las métricas de resolución solo cuentan `met` y `missed`; una exclusión nunca suma.

`met` si `closed_at <= due_at` (borde inclusivo, BR-33); `missed` si `closed_at > due_at`.

### C.9 Clasificacion tardia

`late_classification = true` cuando `classified_at > started_at + resolution_minutes`. El ciclo 1 queda `outcome = 'missed_at_birth'` (solo permitido en ciclo 1 por restriccion). `started_at` sigue siendo `created_at`, nunca la fecha de clasificacion (BR-44).

`missed_at_birth` **no** se duplica como columna del compromiso: su representacion inequivoca es `sla_cycle.outcome = 'missed_at_birth'` del ciclo 1. La cartera tardia se publica como indicador secundario (BR-45).

Tickets con `created_at < activation_at` quedan `historical`, sin vencimientos y fuera de todo denominador (BR-46).

### C.10 Primera respuesta valida

Condiciones acumulativas del articulo candidato: publico, `sender = Agent`, `type = email`, `delivery_status = success`, `created_at >= ticket.created_at`. Se elige el menor `delivery_status_date`; si falta, `updated_at`; si empatan, el menor `article_id`. `met` solo si la diferencia es **estrictamente** `< 86.400 s` (el instante exacto de 24 h no cumple, BR-23).

`first_response_source` registra que marca se uso. `sla_article_delivery.delivery_state = 'aceptado'` significa **aceptacion SMTP**, no entrega en buzon: el esquema no tiene `delivered_at` ni `read_at` para correo, porque no existen.

### C.11 Divergencias de sincronizacion

Se registran en `sla_divergence` con `kind` acotado y `detail` como evidencia. Una sola divergencia abierta por `(ticket_id, kind)`. `catalog_mirror_mismatch` cubre el caso DT-01: el espejo `categoria_subcategoria` de Zammad difiere del BFF y prevalece el BFF (BR-66).

Ninguna divergencia se corrige en silencio: la resolucion exige `resolution` y queda con fecha (BR-60 y §14.4 del EPIC).

### C.12 Separacion de historico y metricas activas

No hay tablas de metricas: los indicadores se calculan por consulta sobre datos inmutables.

| Indicador | Fuente |
|---|---|
| Primera respuesta | `sla_commitment.first_response_outcome` con `met`/`missed` |
| Resolucion oficial | `sla_cycle` donde `cycle_number = 1` y `outcome IN ('met','missed')` |
| Reaperturas | `sla_cycle` donde `cycle_number > 1` |
| Cartera tardia | `sla_commitment.late_classification` y ciclo 1 `missed_at_birth` |
| Cobertura | `assignment_status = 'assigned'` sobre tickets de correo del periodo |
| Excluidos | `no_policy`, `pending_classification`, `historical`, `non_email`, `excluded_non_service`, `excluded` por `merged` o `ticket_deleted` |

Esto satisface "calcular metricas sin modificar datos historicos": los reportes solo leen.

---

## D. SQL propuesto

| Archivo | Contenido |
|---|---|
| `docs/atenciones-zammad/sql/001_diseno_esquema_sla.sql` | DDL completo de las 9 tablas, restricciones, indices y comentarios |
| `docs/atenciones-zammad/sql/001_rollback_diseno_sla.sql` | Rollback propuesto, en orden inverso |

Caracteristicas del DDL:

1. **Guarda de entorno en ambos archivos:** aborta si `current_database() <> 'restaurant_bi_test'` o si el rol es `pgvector_user`/`postgres`.
2. **Transaccion unica** (`BEGIN`/`COMMIT`) para que un fallo no deje objetos a medias.
3. **Sin `IF NOT EXISTS`:** si una tabla ya existe, falla. Se prefiere el fallo a una aplicacion parcial silenciosa.
4. **Sin `CASCADE` en el rollback:** si aparece una dependencia inesperada, falla en lugar de arrastrar objetos ajenos.
5. **Sin triggers, sin funciones, sin extensiones.** No requiere `pgcrypto`: `gen_random_uuid()` es nativo desde PostgreSQL 13.
6. **Sin datos:** la carga de las 38 politicas es un paso posterior y separado.

---

## E. Rollback propuesto

`001_rollback_diseno_sla.sql` elimina las 9 tablas en orden inverso:

```
sla_sync_run → sla_divergence → sla_audit → sla_alert → sla_article_delivery
→ sla_event → sla_cycle → sla_commitment → sla_policy_version
```

Al final ejecuta una consulta que debe devolver 0 filas en `information_schema.tables` para `sla\_%`.

**No reversible:** el borrado destruye compromisos, ciclos y auditoria. La reversibilidad es estructural, no de datos. Antes de cualquier rollback se exige respaldo (paso R1/R2 del procedimiento de migracion).

---

## F. Revision de seguridad

### F.1 Permisos requeridos

| Rol | Uso | Privilegios propuestos |
|---|---|---|
| `cope_test_migration` | Crear y migrar objetos | `CREATE` sobre el esquema `public` de la base de prueba; sin `SUPERUSER`, sin `CREATEDB`, sin `CREATEROLE` |
| `cope_test_runtime` | Operar el motor | `SELECT, INSERT, UPDATE, DELETE` sobre las 9 tablas; **sin** `UPDATE` ni `DELETE` sobre `sla_audit`; sin DDL |
| `pgvector_user` | Produccion | **Nunca** se usa para esta migracion |

### F.2 Acceso minimo

- `sla_audit` es append-only por privilegios: `REVOKE UPDATE, DELETE` para el rol runtime.
- El motor no necesita `DELETE` sobre `sla_commitment`, `sla_cycle` ni `sla_policy_version`. Se recomienda otorgarlo solo donde la retencion lo justifique.
- Sin permisos sobre `public.v_unificado_norm` mas alla de `SELECT`, que ya existe para reportes.

### F.3 Separacion de entornos

| Entorno | Base | Rol | Uso |
|---|---|---|---|
| Desarrollo/pruebas | `restaurant_bi_test` | `cope_test_migration` / `cope_test_runtime` | Migraciones y pruebas |
| Produccion | `pgvector_db` en `<IP_BD_PRODUCCION>` | `pgvector_user` | **Prohibido** para este trabajo |

La guarda del DDL verifica base y rol. Aun asi, el procedimiento M1–M8 verifica host y base **antes** de abrir `psql`, porque una guarda en el archivo no protege contra un `DATABASE_URL` mal apuntado si alguien ejecuta otro SQL.

### F.4 Proteccion de secretos

- `backend/.env` existe y **no se leyo** en este trabajo.
- Las credenciales de prueba las define el DBA y se entregan por canal seguro.
- No se escriben cadenas de conexion en documentos, repositorio, logs ni URLs.

### F.5 Riesgos de escritura

| Riesgo | Mitigacion |
|---|---|
| Ejecutar el DDL sobre produccion | Guarda de base y rol + M1/M2 del procedimiento + lista negra de host |
| Borrar objetos ajenos | Sin `CASCADE`; nombres con prefijo `sla_`; rollback listado uno a uno |
| Reescribir historicos | Las tablas son nuevas; no se altera ninguna vista ni tabla existente |
| Corromper el compromiso congelado | Inmutabilidad por aplicacion + auditoria con motivo |
| Filtrar datos personales | `payload` solo metadatos; `failure_message` truncado a 500 caracteres |

### F.6 Respaldo y restauracion

| Paso | Accion |
|---|---|
| R1 | `pg_dump --schema-only` de `restaurant_bi_test` antes de cada migracion |
| R2 | Respaldo de datos sinteticos antes de cualquier operacion destructiva |
| R3 | Restauracion solo sobre `restaurant_bi_test` |
| R4 | Verificacion posterior con las consultas de identidad de entorno |

---

## G. Dependencias del DBA

Para habilitar la aplicacion del esquema se necesita:

1. Base `restaurant_bi_test` creada, independiente de `pgvector_db`.
2. Rol `cope_test_migration` con `CREATE` sobre el esquema `public` de esa base y sin privilegios globales.
3. Rol `cope_test_runtime` con DML sobre las tablas del modulo y sin DDL.
4. `REVOKE UPDATE, DELETE ON sla_audit` para el rol runtime.
5. Definicion del esquema por defecto (`public`) y del `search_path`.
6. Zona horaria del servidor en UTC, o confirmacion de que las columnas `timestamptz` se leen en UTC.
7. Confirmacion de la version de PostgreSQL (el diseno asume 13 o superior por `gen_random_uuid()`).
8. Politica de respaldo de la base de prueba.
9. Evidencia de las consultas de verificacion de §4.2 del plan de desbloqueo.

**Sin los puntos 1 a 3 no se puede aplicar nada.** Los puntos 4 a 9 son necesarios antes de la primera prueba de integracion.

---

## H. Revision critica del modelo

| # | Pregunta | Respuesta | Como se garantiza |
|---:|---|---|---|
| 1 | Evita duplicidad | **Si** | Un compromiso por `ticket_id`; un ciclo por `(commitment_id, cycle_number)`; un evento por `idempotency_key`; una alerta por umbral; una divergencia abierta por tipo; una politica vigente por combinacion |
| 2 | Reconstruye el estado SLA de un ticket | **Si** | `sla_event` es el registro de verdad; `sla_commitment` y `sla_cycle` son proyecciones; el watermark permite reprocesar |
| 3 | Identifica cada ciclo | **Si** | `cycle_number` + unicidad + indice de ciclo abierto |
| 4 | Conserva el compromiso original | **Si** | Snapshot por columnas; reclasificar no escribe el snapshot |
| 5 | Detecta eventos duplicados | **Si** | `idempotency_key` unico de 64 caracteres |
| 6 | Recupera sincronizaciones interrumpidas | **Si** | `sla_sync_run` con `watermark_after` solo si `ok`; solape de 15 min |
| 7 | Distingue primera respuesta de aceptacion SMTP | **Si, con matiz** | `first_response_at` + `first_response_source` distinguen la marca usada; `delivery_state = 'aceptado'` es aceptacion SMTP y **no** existe estado "entregado" para correo. No hay confirmacion de entrega en buzon y el modelo no la finge |
| 8 | Detecta el primer cierre | **Si** | `closed_at` unico por ciclo; `merged` y `ticket_deleted` van a `excluded` |
| 9 | Audita una reclasificacion | **Si** | `sla_audit` con `action = 'reclassify'`, valor anterior, nuevo, actor y motivo |
| 10 | Calcula metricas sin modificar historicos | **Si** | Consultas de solo lectura sobre tablas inmutables; sin tablas de metricas |

### H.1 Verificaciones tecnicas

| Verificacion | Resultado | Observacion |
|---|---|---|
| Claves y relaciones | Correctas | FK declaradas; referencias a Zammad y a eventos son logicas y estan documentadas |
| Indices | Suficientes para las consultas del EPIC | Cubren politica vigente, primera respuesta pendiente, resolucion vencida, eventos pendientes, ciclo abierto, entregas sin confirmar y divergencias abiertas |
| Unicidad | Completa | Parciales donde la regla lo exige (politica vigente, ciclo abierto, divergencia abierta) |
| Nulabilidad | Coherente con las reglas | Cada `assignment_status` tiene su `CHECK` |
| Precision de timestamps | Microsegundos | Suficiente: la regla se mide en segundos (86.400) |
| Zonas horarias | `timestamptz` en todo | Sin `timestamp` sin zona; calendario 24/7 no requiere zona local |
| Integridad referencial | Fuerte dentro del modulo | No hay FK a Zammad por diseno; se cubre con reconciliacion |
| Compatibilidad con Prisma 5 | Frontera explicita | Prisma no modela el esquema SLA; ver H.2 |
| Rollback | Propuesto y ordenado | Sin `CASCADE`; exige respaldo previo |

### H.2 Frontera con Prisma 5

**Decision:** Prisma **no posee** el esquema SLA. Las 9 tablas se crean y evolucionan solo por SQL manual. `backend/prisma/schema.prisma` contiene unicamente el modelo ancla `GenerateAnchor` y sigue asi.

| Elemento del DDL | Tratamiento |
|---|---|
| `uuid` + `gen_random_uuid()` | SQL manual; sin modelo Prisma |
| `timestamptz` | SQL manual; `DateTime` no se usa para estas tablas |
| `jsonb` | SQL manual |
| `numeric(10,2)` | SQL manual |
| `CHECK` e indices unicos parciales | Solo en SQL; Prisma 5 no los expresa |
| Acceso del motor | SQL tipado sobre el cliente Prisma existente |

**Reglas operativas:**

1. No ejecutar `prisma db pull` sobre una base que contenga las tablas SLA: sobrescribiria el esquema ancla y no reproduciria las restricciones.
2. No ejecutar `prisma migrate`, `prisma migrate dev` ni `prisma db push` sobre estas tablas: crearia un historial paralelo al SQL manual y no aplicaria los `CHECK`.
3. La fuente de verdad estructural es `sql/001_diseno_esquema_sla.sql` y su script de verificacion.
4. Si en el futuro se decide modelar el esquema en Prisma, sera una decision separada con su propio diseno; no se hace por omision.

**Riesgo residual:** sin tabla de control de migraciones, el estado aplicado es documental. Ver §I.10.

### H.3 Lo que la revision NO aprueba

El DDL tiene sintaxis verificable, pero **no se considera aprobado**. Quedan decisiones funcionales abiertas (§I) que pueden cambiar columnas o restricciones. Aprobarlo por sintaxis correcta seria exactamente lo que el encargo prohibe.

---

## I. Decisiones pendientes y discrepancias

| # | Tema | Situacion (17/11/2026) | Propuesta | Estado |
|---:|---|---|---|---|
| 1 | **REA-02** (vencimiento del ciclo de reapertura) | BR-38 fija `due_at = opened_at + resolution_minutes`; `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2 dice «Alternativa A aprobada» y `RESUMEN_EJECUTIVO_5G4_5.md` §3.1 la lista como cerrada. `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` sigue en **PENDIENTE**: es un registro anterior sin actualizar. A cabe sin cambios; B (ciclo sin plazo) no | Ratificar A con firma funcional (`DECISION_CICLOS_REAPERTURA_OBS_28.md`) | **Abierta**: falta firma, no analisis |
| 2 | **`policy_class`** | No existe en 5G.4.5; es necesaria para separar las 3 sin evidencia de las 7 excluidas | Mantener la columna | **Pendiente de confirmacion** (OBS-31 #1) |
| 3 | **`excluded_non_service`** en `assignment_status` | 5G.4.5 lista 5 estados; DEC-05 exige un sexto tratamiento | Mantener el sexto estado | **Pendiente de confirmacion** (OBS-31 #2) |
| 4 | **`threshold_pct = 100`** | 5G.4.5 permite 75 y 90; BR-54 exige alerta de vencimiento | Mantener 100 como vencimiento | **Pendiente de confirmacion** (OBS-31 #3) |
| 5 | **`source` de eventos** | 5G.4.5 linea 108 ya define `poll \| reconcile \| manual`; la linea 49 prohibe webhooks | Sin cambio: `poll`, `reconcile`, `manual` | **Descartada como discrepancia** (OBS-31 #4) |
| 6 | **`catalog_mirror_mismatch`** | BR-66 exige la divergencia; la lista de tipos de 5G.4.5 no la incluye | Mantener el tipo | **Pendiente de confirmacion** (OBS-31 #5) |
| 7 | **Marcas de politica del catalogo** | El mapa derivado ya existe: 65 filas, 27/3/28/7, verificado por generador | Ratificar con Soporte (DP-04) antes de la carga | **Resuelto tecnicamente; ratificacion pendiente** |
| 8 | **Modulo `backend/src/domain/sla/` existente** | Contiene un modelo de semaforo por canal sin consumidores ni pruebas | Coexistencia aislada; no borrar ni mover sin autorizacion | **Resuelto en diseno** (OBS-27) |
| 9 | **Inmutabilidad** | Trigger de base o regla de aplicacion | Aplicacion + `sla_audit`; sin triggers | **Decidido**: aplicacion |
| 10 | **Control de migraciones** | No existe tabla de control, ni en Prisma ni en el repositorio: 24 archivos SQL planos en `backend/prisma/migrations/` y 11 en `backend/sql/migrations/`. `prisma migrate` no se usa | Tabla `sla_schema_migration` con guarda de doble aplicacion (`PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §7) | **Recomendada**, no aprobada |
| 11 | **Homologacion de las 10 filas** | El EPIC advierte que 10 filas de la matriz difieren de la categoria COSE historica | No afecta al DDL; afecta a la lectura del historico | **Informativa** |
| 12 | **Clasificacion vigente** | El esquema congela `category`/`subcategory` y audita el cambio, pero no almacena la clasificacion actual (OBS-33). Derivar de eventos falla por retencion: `sla_event` guarda 2 anos y el compromiso es permanente | Tabla `sla_classification` con indice unico parcial `WHERE is_current` (§L.2) | **Recomendada B**; borrador escrito, no aplicado |
| 13 | **Canal de alerta** | Se elimino `webhook`; quedan `internal` y `email` | Confirmar el conjunto final (ficha D-12 del paquete) | **Pendiente de confirmacion** |
| 13 | **Canal de alerta** | Se elimino `webhook`; quedan `internal` y `email` | Confirmar el conjunto final | **Pendiente de confirmacion** |

---

## J. Confirmacion

- No se ejecuto SQL en ninguna base de datos.
- No se creo ninguna tabla, indice, restriccion, rol ni base.
- No se modifico `DATABASE_URL` ni se leyo `backend/.env`.
- No se conecto a produccion ni a la base empresarial.
- No se altero `public.v_unificado_norm` ni ninguna vista o tabla existente.
- No se crearon triggers.
- El DDL y el rollback son documentos de revision.

---

## K. Revision integral del 17/11/2026

### K.1 Inventario verificado

| Elemento | Cantidad |
|---|---:|
| Tablas | 9 |
| `CHECK` con nombre | 100 |
| Claves foraneas | 4 |
| Indices con nombre | 24 |
| Indices unicos parciales | 3 |
| Triggers | 0 |
| Sentencias de escritura de datos | 0 |
| `CASCADE` | 0 |

La lista exacta de restricciones e indices esta en `sql/001_verificacion_diseno_sla.sql`.

### K.2 Correcciones aplicadas al DDL

| Bloque | Correccion |
|---|---|
| Politica | Formato de `policy_key`; escalera de 17 valores; respaldo 2.160; exclusiones sin primera respuesta; evidencia minima de matriz y de insuficiencia |
| Compromiso | Par politica/version; `provisional` solo en respaldo; snapshot completo del asignado; clase asignada `matrix` o `fallback`; vencimientos si y solo si asignado; `no_policy` con clase de insuficiencia; snapshot de exclusion; estados sin politica estrictos; coherencia de primera respuesta; clasificacion tardia con vencimiento resuelto |
| Ciclo | `open` sin cierre; `missed_at_birth` abierto o cerrado; `met`/`missed` con borde inclusivo; `due_at` obligatorio en `open` y `missed_at_birth`; indice unico sobre `closed_at IS NULL` |
| Evento | SHA-256 hexadecimal; motivo obligatorio en `ignored` y `failed` |
| Articulo | Fuente de aceptacion; marca de fallo obligatoria |
| Alerta | Canal `webhook` eliminado |
| Auditoria | `alert_config` eliminado; `reclassify` exige valor anterior y nuevo |
| Sincronizacion | Watermark obligatorio solo en `incremental` |

### K.3 Decisiones que el DDL no puede cerrar

Ver §I. Las que bloquean la implementacion son: REA-02, las cuatro confirmaciones de OBS-31, el registro de migraciones y la clasificacion vigente (OBS-33).

### K.4 Verificacion posterior a una eventual aplicacion

`sql/001_verificacion_diseno_sla.sql` comprueba, en solo lectura, tablas, `CHECK`, `FK`, indices, predicados parciales, ausencia de triggers, tablas vacias, privilegios de `sla_audit` y `gen_random_uuid()`. **No se ejecuto**: no existe la base de prueba.

### K.5 Estado de aprobacion

El diseño esta **revisado y consolidado**, no aprobado. La aprobacion formal del esquema, la aplicacion del DDL y la implementacion del motor siguen sujetas a BLK-05, BLK-06 y a las decisiones de §I.

---

## L. Versión candidata para aprobación (17/11/2026)

Esta sección fija el estado de las decisiones que pueden cerrarse con documentación y las que necesitan firma. **No cambia el DDL.**

### L.1 Correspondencia con el paquete de aprobación

| Decisión | Documento | Estado |
|---|---|---|
| Ciclos 2..N (OBS-28) | `DECISION_CICLOS_REAPERTURA_OBS_28.md` | Recomendada A; falta firma funcional |
| 28 respaldos (OBS-30) | `MATRIZ_RATIFICACION_FALLBACK_SLA.md` | 28 filas preparadas; falta firma de Soporte |
| Cuatro confirmaciones (OBS-31) | `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §4 | Fichas preparadas; sin confirmar |
| Clasificación vigente (OBS-33) | `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §6 | Recomendada B; borrador escrito |
| Registro de migraciones | `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §7 | Recomendada tabla propia; cambia `001` |
| Frontera Prisma | §H.2 y paquete §8 | Documentada; controles propuestos |

### L.2 Clasificación vigente: por qué una tabla y no columnas ni eventos

| Criterio | Columnas en `sla_commitment` | Tabla `sla_classification` | Derivar de eventos |
|---|---|---|---|
| Consulta actual | Directa | Índice único parcial | JSONB, por ticket |
| Indexable por categoría | Sí | Sí | No sin índice de expresión |
| Compromiso inmutable | Se debilita | Se preserva | Se preserva |
| Retención | Permanente | Permanente | **2 años**: no cubre tickets antiguos |
| Coste | +2 columnas | +1 tabla, +1 FK, +2 índices, +3 CHECK | 0 |

La derivación desde eventos es posible hoy (`ticket.classified` y `ticket.reclassified` existen), pero la retención de `sla_event` (2 años) no cubre la vida del compromiso. Se recomienda la tabla; el borrador de DDL está en el paquete §6.3 y **no se aplica**.

### L.3 Coste acumulado si se aprueban L.2 y el registro de migraciones

| Elemento | Hoy | Solo registro | Registro + clasificación |
|---|---:|---:|---:|
| Tablas | 9 | 10 | 11 |
| `CHECK` con nombre | 100 | 104 | 107 |
| Claves foráneas | 4 | 4 | 5 |
| Índices con nombre | 24 | 24 | 26 |

Si se aprueba cualquiera de las dos, `DISEÑO_ESQUEMA_BD_SLA.md`, `001_diseno_esquema_sla.sql`, `001_rollback_diseno_sla.sql` y `001_verificacion_diseno_sla.sql` deben actualizarse **juntos** antes de aplicar nada, y el DBA debe revisar el archivo resultante.

### L.4 Qué no cambia esta versión

- No se aplicó ningún cambio al DDL, al rollback ni al script de verificación.
- No se convirtió ninguna propuesta en regla aprobada.
- Las cantidades 27 / 3 / 28 / 7 y los hashes del catálogo siguen intactos.
- El esquema sigue sin ejecutarse.
