# MODELO DE DATOS DEFINITIVO DEL MOTOR SLA — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No se creó ninguna tabla.**

---

## 1. Revisión del modelo de 5G.4.2

El modelo anterior tenía **11 tablas**. Tras revisar responsabilidades, se reducen a **9**.

| Tabla 5G.4.2 | Decisión | Motivo |
|---|---|---|
| `sla_event` | **Se conserva** | Idempotencia y trazabilidad |
| `sla_ticket` | **Se elimina** | Su contenido pasa a `sla_commitment` (una fila por ticket) |
| `sla_commitment` | **Se conserva** | Snapshot inmutable |
| `sla_cycle` | **Se conserva** | Ciclos de resolución |
| `sla_reopen` | **Se elimina** | Una reapertura es el inicio de un ciclo; se deriva de `sla_cycle` |
| `sla_policy` | **Se fusiona** en `sla_policy_version` | Catálogo y versiones son lo mismo con un campo `status` |
| `sla_policy_version` | **Se conserva** | Fuente de políticas |
| `sla_policy_audit` | **Se fusiona** en `sla_audit` | Auditoría genérica |
| `sla_alert` | **Se conserva** | Alertas enviadas |
| `sla_reconciliation_run` | **Se renombra** a `sla_sync_run` | Cursor de sondeo y de reconciliación |
| `sla_divergence` | **Se conserva** | Divergencias |
| — | **Se añade** `sla_article_delivery` | Estado de entrega por artículo (necesario para la máquina de estados) |

**Resultado: 9 tablas.**

Justificación de la reducción:

- Una tabla por ticket para el estado del motor y otra para el compromiso duplicaban la misma clave.
- `sla_reopen` duplicaba `sla_cycle`.
- Separar catálogo y versiones no aporta nada si cada versión es una fila inmutable.

---

## 2. Diagrama de relaciones

```
sla_policy_version (1) ───< (N) sla_commitment (1) ───< (N) sla_cycle
                                      │
                                      ├───< (N) sla_alert
                                      └───< (N) sla_divergence

sla_event (N) ──► ticket_id (lógico, Zammad)
sla_article_delivery (N) ──► article_id (lógico, Zammad)
sla_sync_run (N)  (independiente)
sla_audit (N)     (referencia genérica: entity_type + entity_id)
```

Los identificadores de Zammad (`ticket_id`, `article_id`) son **lógicos**: no hay claves externas porque Zammad vive en otra base de datos.

---

## 3. Tablas

### 3.1 `sla_policy_version`

Catálogo de las 65 políticas y sus versiones. Cada fila es inmutable una vez publicada.

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `policy_key` | text | No | Clave estable, ej. `20-MAIL-SOFTWARE-ERROR_WEB` |
| `version` | integer | No | Versión de la política, desde 1 |
| `matrix_version` | text | No | Versión de la matriz (ej. `5G.2.1`) |
| `channel` | text | No | `whatsapp` / `correo` |
| `category` | text | No | Categoría oficial |
| `subcategory` | text | No | Subcategoría oficial |
| `first_response_minutes` | integer | No | 15 / 1440 / 90 / 2160 provisional |
| `resolution_minutes` | integer | Sí | `NULL` si la combinación no tiene evidencia |
| `provisional` | boolean | No | Respaldo provisional |
| `status` | text | No | `draft`, `active`, `inactive`, `pending` |
| `sample_size` | integer | Sí | n de la matriz |
| `p75_minutes` | numeric(10,2) | Sí | Referencia estadística |
| `confidence` | text | Sí | `ALTA`, `MEDIA`, `BAJA`, `INSUFICIENTE` |
| `valid_from` | timestamptz | No | Inicio de vigencia |
| `valid_to` | timestamptz | Sí | Fin de vigencia (`NULL` = vigente) |
| `created_by` | text | No | Responsable |
| `created_at` | timestamptz | No | — |
| `reason` | text | No | Motivo del cambio (obligatorio) |

**Restricciones:**

- PK `id`.
- Único `(policy_key, version)`.
- `CHECK (first_response_minutes > 0)`.
- `CHECK (resolution_minutes IS NULL OR resolution_minutes > 0)`.
- `CHECK (status <> 'active' OR resolution_minutes IS NOT NULL)`.
- `CHECK (valid_to IS NULL OR valid_to > valid_from)`.
- Índice único parcial: un solo `active` por `(channel, category, subcategory)` vigente: `UNIQUE (channel, category, subcategory) WHERE valid_to IS NULL AND status = 'active'`.

**Índices:** `(channel, category, subcategory)`, `(status)`.

**Nota:** las 5 combinaciones sin evidencia se guardan con `resolution_minutes NULL` y `status = 'pending'`, para que sean visibles y no se confundan con ausencia de dato.

---

### 3.2 `sla_commitment`

Compromiso por ticket. Snapshot inmutable tras la asignación.

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `ticket_id` | integer | No | Ticket de Zammad |
| `ticket_number` | text | No | Número visible |
| `policy_version_id` | uuid | Sí | FK a `sla_policy_version`; `NULL` si sin política |
| `assignment_status` | text | No | `assigned`, `no_policy`, `pending_classification` |
| `policy_key` | text | Sí | Copia del snapshot |
| `policy_version` | integer | Sí | Copia del snapshot |
| `channel` | text | Sí | Snapshot |
| `category` | text | Sí | Snapshot de categoría original |
| `subcategory` | text | Sí | Snapshot de subcategoría original |
| `first_response_minutes` | integer | Sí | Snapshot |
| `resolution_minutes` | integer | Sí | Snapshot |
| `provisional` | boolean | No | Snapshot |
| `started_at` | timestamptz | Sí | `created_at` del ticket |
| `assigned_at` | timestamptz | Sí | Momento de asignación |
| `first_response_due_at` | timestamptz | Sí | `started_at + first_response_minutes` |
| `resolution_due_at` | timestamptz | Sí | `started_at + resolution_minutes` |
| `first_response_at` | timestamptz | Sí | Primera respuesta efectiva (ver `ANALISIS_ENTREGA_PRIMERA_RESPUESTA_5G4_2.md`) |
| `first_response_article_id` | integer | Sí | Artículo que cumple |
| `first_response_outcome` | text | Sí | `met`, `missed`, `pending`, `not_applicable` |
| `reclassified_count` | integer | No | Contador de reclasificaciones (no modifica el compromiso) |
| `last_seen_state` | text | Sí | Último estado observado (para transiciones) |
| `last_seen_updated_at` | timestamptz | Sí | Último `updated_at` procesado |
| `created_at` | timestamptz | No | — |

**Restricciones:**

- PK `id`.
- `UNIQUE (ticket_id)`: un compromiso por ticket.
- `CHECK (assignment_status <> 'assigned' OR (policy_key IS NOT NULL AND resolution_minutes IS NOT NULL AND started_at IS NOT NULL AND assigned_at IS NOT NULL))`.
- `CHECK (resolution_due_at IS NULL OR resolution_due_at >= started_at)`.

**Inmutabilidad (reglas, no restricción SQL):** las columnas `policy_key`, `policy_version`, `channel`, `category`, `subcategory`, `first_response_minutes`, `resolution_minutes`, `started_at`, `assigned_at`, `first_response_due_at`, `resolution_due_at` solo se escriben al asignar. Un disparador (conceptual) rechaza actualizaciones de esas columnas. **Decisión pendiente:** si se implementa como trigger en PostgreSQL o como regla de aplicación.

**Índices:** `(assignment_status)`, `(resolution_due_at)` parcial donde `assignment_status = 'assigned'`, `(first_response_due_at)` parcial donde `first_response_at IS NULL`.

**Nota sobre "sin política":** un ticket sin política no cuenta en el denominador y no se considera incumplido (5G.3 §8).

---

### 3.3 `sla_cycle`

Ciclos de resolución por compromiso (REA-02).

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `commitment_id` | uuid | No | FK a `sla_commitment` |
| `cycle_number` | integer | No | 1, 2, 3… |
| `opened_at` | timestamptz | No | `started_at` en ciclo 1; fecha de reapertura después |
| `due_at` | timestamptz | Sí | Inmutable. Ciclo 1: `resolution_due_at`. Ciclo N: `opened_at + resolution_minutes` (si REA-02 se aprueba) |
| `closed_at` | timestamptz | Sí | Primer cierre del ciclo |
| `outcome` | text | No | `open`, `met`, `missed`, `not_applicable` |
| `opened_by_event_id` | uuid | Sí | Evento que abrió el ciclo |
| `closed_by_event_id` | uuid | Sí | Evento que cerró el ciclo |
| `closed_by_actor_id` | integer | Sí | Usuario que cerró |

**Restricciones:**

- PK `id`.
- `UNIQUE (commitment_id, cycle_number)`.
- `CHECK (cycle_number >= 1)`.
- `CHECK (closed_at IS NULL OR closed_at >= opened_at)`.
- `CHECK ((outcome = 'open') = (closed_at IS NULL))`.
- `CHECK (cycle_number = 1 OR opened_at IS NOT NULL)` (trivial, documenta la regla).

**Regla de integridad:** solo puede existir un ciclo `open` por compromiso. Índice único parcial: `UNIQUE (commitment_id) WHERE outcome = 'open'`.

**Regla de secuencia:** un ciclo N+1 solo se crea si el ciclo N está cerrado.

---

### 3.4 `sla_event`

Hechos recibidos y procesados. Base de la idempotencia.

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | `event_id` |
| `idempotency_key` | text | No | sha256, único |
| `event_type` | text | No | Catálogo de `CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md` |
| `event_version` | integer | No | 1 |
| `ticket_id` | integer | No | Ticket de Zammad |
| `article_id` | integer | Sí | Artículo |
| `occurred_at` | timestamptz | No | En Zammad |
| `received_at` | timestamptz | No | En el BFF |
| `source` | text | No | `poll`, `webhook`, `reconcile`, `manual` |
| `payload` | jsonb | No | Normalizado |
| `status` | text | No | `pending`, `applied`, `ignored`, `failed` |
| `status_reason` | text | Sí | Motivo de `ignored` o `failed` |
| `attempts` | integer | No | Intentos de aplicación |
| `applied_at` | timestamptz | Sí | — |

**Restricciones:**

- PK `id`.
- `UNIQUE (idempotency_key)`.
- `CHECK (status IN ('pending','applied','ignored','failed'))`.
- `CHECK (status <> 'applied' OR applied_at IS NOT NULL)`.

**Índices:** `(status, received_at)` para procesamiento; `(ticket_id, occurred_at)` para reconstrucción; `(event_type, occurred_at)` para reportes.

**Retención:** eventos `applied` y `ignored` por 2 años (DP-08); los `failed` se conservan hasta resolución.

---

### 3.5 `sla_article_delivery`

Estado de entrega por artículo. Necesario para la máquina de estados de entrega.

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `article_id` | integer | No | PK. Artículo de Zammad |
| `ticket_id` | integer | No | Ticket |
| `channel` | text | No | `whatsapp` / `correo` |
| `is_public_agent` | boolean | No | Candidato a primera respuesta |
| `delivery_state` | text | No | `sin_estado`, `aceptado`, `fallido`, `entregado`, `leido` |
| `accepted_at` | timestamptz | Sí | `delivery_status_date` si `success` |
| `delivered_at` | timestamptz | Sí | WhatsApp: `timestamp_delivered` |
| `read_at` | timestamptz | Sí | WhatsApp: `timestamp_read` |
| `failed_at` | timestamptz | Sí | Último fallo |
| `failure_message` | text | Sí | — |
| `retry_count` | integer | No | `delivery_retry` |
| `external_message_id` | text | Sí | `message_id` del proveedor o Message-ID |
| `last_article_updated_at` | timestamptz | Sí | Último `updated_at` leído |
| `created_at` | timestamptz | No | — |

**Restricciones:**

- PK `article_id`.
- `CHECK (delivery_state IN ('sin_estado','aceptado','fallido','entregado','leido'))`.
- `CHECK (delivery_state <> 'entregado' OR delivered_at IS NOT NULL)`.

**Índice:** `(ticket_id)`, `(delivery_state)` parcial donde `delivery_state IN ('sin_estado','fallido')`.

---

### 3.6 `sla_alert`

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `commitment_id` | uuid | No | FK |
| `cycle_number` | integer | No | Ciclo afectado |
| `metric` | text | No | `first_response`, `resolution` |
| `threshold_pct` | integer | No | 75 o 90 |
| `due_at` | timestamptz | No | Vencimiento al momento de la alerta |
| `triggered_at` | timestamptz | No | — |
| `channel` | text | No | `internal`, `email`, `webhook` |
| `status` | text | No | `pending`, `sent`, `failed` |
| `sent_at` | timestamptz | Sí | — |

**Restricciones:**

- `UNIQUE (commitment_id, cycle_number, metric, threshold_pct)`: una alerta por umbral.
- `CHECK (threshold_pct IN (75, 90))`.

---

### 3.7 `sla_audit`

Auditoría genérica de cambios administrativos y de decisiones del motor.

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `entity_type` | text | No | `policy_version`, `commitment`, `cycle`, `alert_config` |
| `entity_id` | text | No | Identificador de la entidad |
| `action` | text | No | `create`, `publish`, `deactivate`, `correct`, `assign`, `open_cycle`, `close_cycle` |
| `actor_type` | text | No | `human`, `service` |
| `actor_id` | text | No | Usuario de la capa administrativa o servicio |
| `old_value` | jsonb | Sí | — |
| `new_value` | jsonb | Sí | — |
| `reason` | text | Sí | Obligatorio para `correct` y `publish` |
| `request_id` | text | Sí | Correlación |
| `created_at` | timestamptz | No | — |

**Restricciones:**

- `CHECK (action NOT IN ('correct','publish') OR reason IS NOT NULL)`.
- Tabla **solo de inserción**: sin `UPDATE` ni `DELETE` a nivel de rol de base de datos.

**Nota:** esta auditoría no reemplaza a la de Zammad (`audit_logs`), que registra cambios en Zammad. Son complementarias.

---

### 3.8 `sla_divergence`

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `ticket_id` | integer | No | Ticket |
| `commitment_id` | uuid | Sí | FK |
| `kind` | text | No | `missing_close`, `missing_reopen`, `policy_mismatch`, `orphan_ticket`, `delivery_unresolved`, `missing_event` |
| `detected_at` | timestamptz | No | — |
| `detail` | jsonb | No | Evidencia |
| `resolved_at` | timestamptz | Sí | — |
| `resolution` | text | Sí | Acción tomada |

**Restricciones:** `CHECK (resolved_at IS NULL OR resolution IS NOT NULL)`.

**Índice:** `(resolved_at)` parcial donde `resolved_at IS NULL` para la bandeja de divergencias abiertas.

---

### 3.9 `sla_sync_run`

Cursor del sondeo y registro de ciclos de reconciliación.

| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| `id` | uuid | No | PK |
| `kind` | text | No | `incremental`, `daily` |
| `window_from` | timestamptz | No | Inicio de la ventana leída |
| `window_to` | timestamptz | No | Fin |
| `watermark_before` | timestamptz | Sí | — |
| `watermark_after` | timestamptz | Sí | Solo si `status = ok` |
| `tickets_read` | integer | No | — |
| `events_created` | integer | No | — |
| `status` | text | No | `running`, `ok`, `failed` |
| `error` | text | Sí | — |
| `started_at` | timestamptz | No | — |
| `finished_at` | timestamptz | Sí | — |

**Restricciones:**

- `CHECK (status <> 'ok' OR watermark_after IS NOT NULL)`.
- `CHECK (watermark_after IS NULL OR watermark_after >= watermark_before)`.

**Índice:** `(kind, status, finished_at DESC)`.

**Regla:** el watermark efectivo es el `watermark_after` del último run `ok` de tipo `incremental`.

---

## 4. Relación con las cinco exigencias del encargo

| Exigencia | Tabla(s) |
|---|---|
| Políticas y versiones | `sla_policy_version` |
| Snapshot por ticket | `sla_commitment` |
| Ciclos de resolución | `sla_cycle` |
| Eventos | `sla_event` |
| Entregas | `sla_article_delivery` |
| Auditoría | `sla_audit` |
| Alertas | `sla_alert` |
| Reconciliación | `sla_sync_run`, `sla_divergence` |
| Divergencias | `sla_divergence` |

---

## 5. Índices críticos

| Consulta | Índice |
|---|---|
| Buscar política aplicable | `sla_policy_version (channel, category, subcategory)` parcial vigente |
| Compromisos con primera respuesta pendiente | `sla_commitment (first_response_due_at) WHERE first_response_at IS NULL` |
| Compromisos con resolución vencida | `sla_commitment (resolution_due_at) WHERE assignment_status='assigned'` |
| Eventos pendientes | `sla_event (status, received_at) WHERE status='pending'` |
| Ciclos abiertos | `sla_cycle (commitment_id) WHERE outcome='open'` |
| Entregas sin estado final | `sla_article_delivery (delivery_state) WHERE delivery_state IN ('sin_estado','fallido')` |

---

## 6. Retención

| Tabla | Retención propuesta |
|---|---|
| `sla_event` (applied/ignored) | 2 años |
| `sla_event` (failed) | Hasta resolución |
| `sla_commitment`, `sla_cycle` | Permanente |
| `sla_policy_version` | Permanente |
| `sla_audit` | 5 años (5G.3) |
| `sla_alert` | 1 año |
| `sla_divergence` | Permanente hasta resolución, después 2 años |
| `sla_sync_run` | 1 año |
| `sla_article_delivery` | Igual que el artículo |

---

## 7. Pendientes

| # | Pendiente |
|---:|---|
| 1 | Decidir si la inmutabilidad de `sla_commitment` se implementa con trigger de base de datos o con regla de aplicación |
| 2 | Confirmar tipos de tiempo: `timestamptz` en UTC para todo |
| 3 | Confirmar motor de base de datos del BFF (PostgreSQL asumido) |
| 4 | Decidir si `sla_audit` vive en la misma base que el resto |

---

## 8. Confirmación

Modelo conceptual. No se creó ninguna tabla, índice, restricción ni función.
