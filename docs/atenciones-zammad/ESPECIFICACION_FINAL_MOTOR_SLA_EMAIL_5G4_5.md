# ESPECIFICACIÓN FINAL DEL MOTOR SLA — EXCLUSIVAMENTE EMAIL — 5G.4.5

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.5 — Cierre funcional
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Estado:** especificación definitiva para autorizar la fase 0. **Nada implementado.**
**Reemplaza en lo operativo a:** `ARQUITECTURA_MOTOR_SLA_EMAIL_5G4_4.md`, `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` y `REGLAS_MEDICION_Y_CUMPLIMIENTO_SLA_5G3.md`. No los sobrescribe.

---

## 1. Objetivo y no objetivos

### 1.1 Objetivo

Medir, con evidencia verificable, dos compromisos por ticket de correo:

1. **Primera respuesta** en estrictamente menos de 24 h.
2. **Resolución** según la política de su combinación categoría/subcategoría (27 políticas, 24–120 h).

Sin escribir nada en Zammad.

### 1.2 No objetivos

| No es objetivo | Motivo |
|---|---|
| Gestionar WhatsApp, WHATMETA o WHATICKET | Fuera de alcance |
| Usar el motor SLA nativo de Zammad | Cero políticas nativas, por diseño |
| Medir productividad por agente | No es un compromiso con el cliente |
| Medir satisfacción | No hay dato fiable |
| Clasificar tickets con IA | La clasificación es un dato del ticket |
| Reemplazar Zammad | Zammad sigue siendo la fuente de hechos |
| Emitir facturación | Otro dominio |

---

## 2. Fuentes de datos

### 2.1 Endpoints (solo lectura)

| Uso | Endpoint | Filtro |
|---|---|---|
| Tickets modificados | `GET /api/v1/tickets/search` | `updated_at:>=<desde>`, orden `updated_at asc, id asc`, 200/página |
| Ticket individual | `GET /api/v1/tickets/{id}` | — |
| Artículos del ticket | `GET /api/v1/ticket_articles/by_ticket/{id}` | — |
| Historial del ticket | `GET /api/v1/ticket_history/{id}` | — |
| Catálogos | `GET /api/v1/ticket_states`, `/groups`, `/users` | Caché de larga duración |

**No se usan:** escrituras, webhooks, triggers, GraphQL de mutación, ni acceso directo a la base de Zammad.

### 2.2 Campos utilizados

| Entidad | Campo | Uso |
|---|---|---|
| Ticket | `id`, `number` | Identidad |
| Ticket | `created_at` | Inicio del compromiso |
| Ticket | `updated_at` | Detección incremental |
| Ticket | `state_id`, `state` | Ciclos |
| Ticket | `close_at`, `last_close_at` | Cierre 1 y cierres posteriores |
| Ticket | `group_id` | Alcance |
| Ticket | `sla_category`, `sla_subcategory` | Clasificación (campos a definir en fase 2) |
| Artículo | `id`, `ticket_id` | Identidad |
| Artículo | `sender`, `type`, `internal` | Candidato a primera respuesta |
| Artículo | `created_at`, `updated_at` | Fallback de fecha |
| Artículo | `preferences.delivery_status` | `success` / `fail` / ausente |
| Artículo | `preferences.delivery_status_date` | Fecha de respuesta |
| Artículo | `preferences.delivery_retry` | Definitividad del fallo |
| Historial | `attribute`, `value_to`, `created_at` | Transiciones de estado y clasificación |

**Nunca se leen:** cuerpo del artículo, adjuntos, datos del cliente, teléfono, dirección de correo del contacto.

### 2.3 Qué prueba la confirmación de envío

`delivery_status = success` prueba que el servidor de salida aceptó el mensaje. **No** prueba entrega en buzón ni lectura. Esta distinción es parte de la definición de la métrica y debe aparecer en todo reporte.

---

## 3. Catálogo de eventos

| Evento | Obligatorio | Origen | Disparador |
|---|---|---|---|
| `ticket.created` | Sí | sondeo | Primera observación |
| `ticket.classified` | Sí | sondeo / historial | Ambos campos de clasificación no vacíos |
| `ticket.reclassified` | Sí | sondeo / historial | Cambio posterior; **no** altera el compromiso |
| `ticket.state_changed` | Sí | sondeo / historial | Cambio de `state_id` |
| `ticket.closed` | Sí | sondeo | Transición a tipo `closed` |
| `ticket.reopened` | Sí | sondeo / historial | Transición desde `closed` a no cerrado |
| `ticket.merged` | Sí | sondeo | Transición a tipo `merged` |
| `ticket.deleted` | Sí | reconciliación | 404 sobre ticket conocido |
| `article.created` | Sí | sondeo | Artículo nuevo |
| `article.delivery_confirmed` | Sí | sondeo | `delivery_status = success` |
| `article.delivery_failed` | Sí | sondeo | `fail` con `delivery_retry > 3` |
| `article.delivery_retry_pending` | No | sondeo | `fail` con reintentos disponibles |
| `commitment.assigned` | Sí | motor | Clasificación con política |
| `cycle.opened` | Sí | motor | Ciclo 1 o reapertura |
| `cycle.closed` | Sí | motor | Cierre o exclusión |

**Envoltorio:**

```json
{
  "event_id": "uuid",
  "event_type": "article.delivery_confirmed",
  "event_version": 1,
  "ticket_id": 123,
  "entity_id": 456,
  "occurred_at": "2026-11-16T12:00:00Z",
  "source": "poll | reconcile | manual",
  "payload": { }
}
```

**Clave de idempotencia:**

```
sha256('zammad' | event_type | ticket_id | entity_id | occurred_at_utc)
```

**Regla:** inserción del evento y aplicación de la transición en **la misma transacción**. Si el evento ya existe, se ignora sin error.

---

## 4. Modelo de datos (9 tablas)

### 4.1 `sla_policy_version`

Catálogo de 27 políticas Email + 1 respaldo, versionado e inmutable al publicar.

| Columna | Tipo | Nulo | Nota |
|---|---|---|---|
| `id` | uuid | No | PK |
| `policy_key` | text | No | `20-MAIL-<CAT>-<SUB>` o `99-FALLBACK` |
| `version` | integer | No | Desde 1 |
| `matrix_version` | text | No | `5G.4.5` |
| `channel` | text | No | `CHECK (channel = 'email')` |
| `category` | text | No | Categoría **oficial** (matriz) |
| `subcategory` | text | No | Subcategoría oficial |
| `first_response_minutes` | integer | No | `1440` |
| `resolution_minutes` | integer | Sí | `NULL` = sin evidencia |
| `provisional` | boolean | No | `true` solo en `99-FALLBACK` |
| `status` | text | No | `draft`, `active`, `inactive`, `pending` |
| `sample_size` | integer | Sí | n de la matriz |
| `p75_minutes` | numeric(10,2) | Sí | Referencia |
| `confidence` | text | Sí | `ALTA`, `MEDIA`, `BAJA`, `INSUFICIENTE` |
| `valid_from` | timestamptz | No | — |
| `valid_to` | timestamptz | Sí | `NULL` = vigente |
| `created_by` | text | No | Responsable |
| `created_at` | timestamptz | No | — |
| `reason` | text | No | Obligatorio |

**Restricciones:** `UNIQUE (policy_key, version)`; `CHECK (status <> 'active' OR resolution_minutes IS NOT NULL)`; `UNIQUE (channel, category, subcategory) WHERE valid_to IS NULL AND status = 'active'`; `CHECK (valid_to IS NULL OR valid_to > valid_from)`.

**Carga inicial:** 27 filas `active` con `resolution_minutes` de la matriz, 3 filas `pending` con `resolution_minutes = NULL`, 1 fila `99-FALLBACK` `active` con 2.160 y `provisional = true`.

### 4.2 `sla_commitment`

Snapshot inmutable por ticket.

| Columna | Tipo | Nulo | Nota |
|---|---|---|---|
| `id` | uuid | No | PK |
| `ticket_id` | integer | No | Único |
| `ticket_number` | text | No | — |
| `policy_version_id` | uuid | Sí | FK; `NULL` sin política |
| `assignment_status` | text | No | `assigned`, `no_policy`, `pending_classification`, `historical`, `non_email` |
| `policy_key` | text | Sí | Copia |
| `policy_version` | integer | Sí | Copia |
| `channel` | text | Sí | `CHECK (channel = 'email')` |
| `category` | text | Sí | Snapshot |
| `subcategory` | text | Sí | Snapshot |
| `first_response_minutes` | integer | Sí | `1440` |
| `resolution_minutes` | integer | Sí | Snapshot |
| `provisional` | boolean | No | Snapshot |
| `started_at` | timestamptz | Sí | `created_at` |
| `classified_at` | timestamptz | Sí | Momento de clasificación |
| `assigned_at` | timestamptz | Sí | Momento de asignación |
| `first_response_due_at` | timestamptz | Sí | `started_at + 1440 min` |
| `resolution_due_at` | timestamptz | Sí | `started_at + resolution_minutes` |
| `first_response_at` | timestamptz | Sí | — |
| `first_response_article_id` | integer | Sí | — |
| `first_response_source` | text | Sí | `delivery_status_date`, `updated_at_fallback` |
| `first_response_outcome` | text | Sí | `met`, `missed`, `pending`, `not_applicable` |
| `reclassified_count` | integer | No | Contador |
| `late_classification` | boolean | No | Nacido vencido |
| `activation_at` | timestamptz | No | Corte de histórico |
| `last_seen_state` | text | Sí | — |
| `last_seen_updated_at` | timestamptz | Sí | — |
| `created_at` | timestamptz | No | — |

**Restricciones:** `UNIQUE (ticket_id)`; `CHECK (assignment_status <> 'assigned' OR (policy_key IS NOT NULL AND resolution_minutes IS NOT NULL AND started_at IS NOT NULL))`; `CHECK (first_response_minutes = 1440)`.

**Inmutabilidad (aplicación):** `policy_key`, `policy_version`, `channel`, `category`, `subcategory`, `first_response_minutes`, `resolution_minutes`, `provisional`, `started_at`, `classified_at`, `first_response_due_at`, `resolution_due_at` solo se escriben al asignar. Cualquier cambio exige `sla_audit` con motivo y aprobación (CON-04).

### 4.3 `sla_cycle`

| Columna | Tipo | Nulo | Nota |
|---|---|---|---|
| `id` | uuid | No | PK |
| `commitment_id` | uuid | No | FK |
| `cycle_number` | integer | No | 1..N |
| `opened_at` | timestamptz | No | `created_at` o reapertura |
| `due_at` | timestamptz | Sí | Inmutable |
| `closed_at` | timestamptz | Sí | Cierre o exclusión |
| `outcome` | text | No | `open`, `met`, `missed`, `excluded`, `missed_at_birth` |
| `exclusion_reason` | text | Sí | `merged`, `ticket_deleted` |
| `reopen_hint` | text | Sí | `delivery_failure` (anotación) |
| `opened_by_event_id` | uuid | Sí | — |
| `closed_by_event_id` | uuid | Sí | — |
| `closed_by_actor_id` | integer | Sí | — |
| `overdue_at_cutoff` | boolean | No | Marca de reporte |

**Restricciones:** `UNIQUE (commitment_id, cycle_number)`; `CHECK ((outcome = 'open') = (closed_at IS NULL))`; `CHECK (outcome <> 'excluded' OR exclusion_reason IS NOT NULL)`; `UNIQUE (commitment_id) WHERE outcome = 'open'`.

### 4.4 `sla_event`

| Columna | Tipo | Nulo |
|---|---|---|
| `id` | uuid | No |
| `idempotency_key` | text | No |
| `event_type` | text | No |
| `event_version` | integer | No |
| `ticket_id` | integer | No |
| `article_id` | integer | Sí |
| `occurred_at` | timestamptz | No |
| `received_at` | timestamptz | No |
| `source` | text | No |
| `payload` | jsonb | No |
| `status` | text | No |
| `status_reason` | text | Sí |
| `attempts` | integer | No |
| `applied_at` | timestamptz | Sí |

**Restricciones:** `UNIQUE (idempotency_key)`; `CHECK (status IN ('pending','applied','ignored','failed'))`.

**Payload:** solo metadatos. **Prohibido** incluir cuerpo de correo, asunto completo, direcciones o datos personales.

### 4.5 `sla_article_delivery`

| Columna | Tipo | Nulo | Nota |
|---|---|---|---|
| `article_id` | integer | No | PK |
| `ticket_id` | integer | No | — |
| `channel` | text | No | `CHECK (channel = 'email')` |
| `is_public_agent` | boolean | No | Candidato |
| `delivery_state` | text | No | `sin_estado`, `aceptado`, `fallido_provisional`, `fallido_definitivo` |
| `accepted_at` | timestamptz | Sí | — |
| `accepted_at_source` | text | Sí | `delivery_status_date`, `updated_at` |
| `failed_at` | timestamptz | Sí | — |
| `failure_message` | text | Sí | Truncado a 500 caracteres |
| `retry_count` | integer | No | — |
| `last_article_updated_at` | timestamptz | Sí | — |
| `created_at` | timestamptz | No | — |

**Restricciones:** `CHECK (delivery_state IN ('sin_estado','aceptado','fallido_provisional','fallido_definitivo'))`; `CHECK (delivery_state <> 'aceptado' OR accepted_at IS NOT NULL)`.

**Se eliminaron respecto de 5G.4.3:** `delivered_at`, `read_at`, `external_message_id`.

### 4.6 `sla_alert`

| Columna | Tipo | Nulo |
|---|---|---|
| `id` | uuid | No |
| `commitment_id` | uuid | No |
| `cycle_number` | integer | No |
| `metric` | text | No |
| `threshold_pct` | integer | No |
| `due_at` | timestamptz | No |
| `triggered_at` | timestamptz | No |
| `channel` | text | No |
| `status` | text | No |
| `sent_at` | timestamptz | Sí |

**Restricciones:** `UNIQUE (commitment_id, cycle_number, metric, threshold_pct)`; `CHECK (threshold_pct IN (75, 90))`.

### 4.7 `sla_audit`

| Columna | Tipo | Nulo |
|---|---|---|
| `id` | uuid | No |
| `entity_type` | text | No |
| `entity_id` | text | No |
| `action` | text | No |
| `actor_type` | text | No |
| `actor_id` | text | No |
| `old_value` | jsonb | Sí |
| `new_value` | jsonb | Sí |
| `reason` | text | Sí |
| `request_id` | text | Sí |
| `created_at` | timestamptz | No |

**Restricciones:** `CHECK (action NOT IN ('correct','publish','deactivate') OR reason IS NOT NULL)`. Tabla de solo inserción.

### 4.8 `sla_divergence`

| Columna | Tipo | Nulo |
|---|---|---|
| `id` | uuid | No |
| `ticket_id` | integer | No |
| `commitment_id` | uuid | Sí |
| `kind` | text | No |
| `detected_at` | timestamptz | No |
| `detail` | jsonb | No |
| `resolved_at` | timestamptz | Sí |
| `resolution` | text | Sí |

**Tipos permitidos:** `missing_close`, `missing_reopen`, `policy_mismatch`, `orphan_ticket`, `delivery_unresolved`, `late_classification`, `merged_ticket`, `non_email_ticket`, `delivery_date_missing`.

### 4.9 `sla_sync_run`

| Columna | Tipo | Nulo |
|---|---|---|
| `id` | uuid | No |
| `kind` | text | No |
| `window_from` | timestamptz | No |
| `window_to` | timestamptz | No |
| `watermark_before` | timestamptz | Sí |
| `watermark_after` | timestamptz | Sí |
| `tickets_read` | integer | No |
| `events_created` | integer | No |
| `status` | text | No |
| `error` | text | Sí |
| `started_at` | timestamptz | No |
| `finished_at` | timestamptz | Sí |

**Regla:** el watermark efectivo es el `watermark_after` del último run `ok` de tipo `incremental`. Un run `failed` **no** avanza el watermark.

---

## 5. Índices

| Consulta | Índice |
|---|---|
| Política aplicable | `(channel, category, subcategory) WHERE status='active' AND valid_to IS NULL` |
| Primera respuesta pendiente | `(first_response_due_at) WHERE first_response_at IS NULL` |
| Resolución vencida | `(resolution_due_at) WHERE assignment_status='assigned'` |
| Eventos pendientes | `(status, received_at) WHERE status='pending'` |
| Ciclo abierto | `(commitment_id) WHERE outcome='open'` |
| Entregas sin confirmar | `(delivery_state) WHERE delivery_state IN ('sin_estado','fallido_provisional')` |
| Divergencias abiertas | `(detected_at) WHERE resolved_at IS NULL` |
| Reconstrucción por ticket | `(ticket_id, occurred_at)` |

---

## 6. Reglas de cálculo

### 6.1 Asignación del compromiso

```
al detectar clasificación completa:
    política = buscar(channel='email', category, subcategory, vigente)
    si política existe y resolution_minutes IS NOT NULL:
        assignment_status = 'assigned'
        started_at        = ticket.created_at
        first_response_due_at = started_at + 1440 min
        resolution_due_at     = started_at + resolution_minutes
        provisional       = política.provisional
    si política existe y resolution_minutes IS NULL:
        assignment_status = 'no_policy' (insufficient_evidence)
    si no existe política y subcategoría fuera de catálogo:
        usar 99-FALLBACK (2160 min, provisional = true)
    si no hay clasificación:
        assignment_status = 'pending_classification'
    si created_at < activation_at:
        assignment_status = 'historical'
```

**Congelamiento:** a partir de este momento, ningún cambio de categoría, política, calendario o prioridad altera el compromiso. Un cambio de categoría incrementa `reclassified_count` y se registra en `sla_audit`.

### 6.2 Primera respuesta

```
candidatos = artículos(internal=false, sender='Agent', type='email',
                       delivery_status='success', created_at >= ticket.created_at)
si hay candidatos:
    elegido = min por (delivery_status_date | updated_at, article_id)
    outcome = (fecha - started_at) < 86.400 s ? 'met' : 'missed'
si no y now > first_response_due_at:
    outcome = 'missed'
si no:
    outcome = 'pending'
```

### 6.3 Resolución

```
cierre = primer estado de tipo 'closed' del ciclo
met    = closed_at <= due_at
missed = closed_at >  due_at
```

`pending close`, `merged` y `deleted` no cierran (§ ciclos).

### 6.4 Cumplimiento

| Indicador | Fórmula |
|---|---|
| Primera respuesta | `met / (met + missed)` |
| Resolución oficial | `C1.met / (C1.met + C1.missed)` |
| Reaperturas | `C2..N.met / (C2..N.met + C2..N.missed)` |
| Cartera tardía | `missed_at_birth / late_classification` |
| Cobertura | `assigned / tickets Email del período` |

**Meta global:** ≥ 80 % en primera respuesta y en resolución oficial.

---

## 7. Sondeo

| Ámbito | Cadencia | Justificación |
|---|---|---|
| Tickets abiertos del grupo | **5 minutos** | Latencia 0,35 % sobre 24 h |
| Primera respuesta pendiente con vencimiento < 4 h | **2 minutos** | Ventana crítica de alerta |
| Reconciliación incremental | 15 minutos | Recupera eventos perdidos |
| Reconciliación completa | Diaria | Cambios tardíos y artículos sin confirmar |

**Por qué no 1 minuto:** el motor mide con marcas de Zammad, no con la hora de detección. La cadencia solo afecta la latencia de alerta, no el valor medido. 1 minuto multiplicaría por 5 la carga sin cambiar ningún resultado.

**Consulta incremental:**

```
desde = watermark_efectivo - 15 min
tickets = search(updated_at >= desde, orden updated_at asc, id asc, 200/página)
para cada ticket:
    artículos = by_ticket(id)
    si state_id, close_at o last_close_at cambiaron:
        historial = history(id)
    emitir eventos (idempotentes)
watermark = max(updated_at) solo si el ciclo terminó sin error
```

### 7.1 Detección de la confirmación de envío

| Paso | Hecho verificado | Referencia |
|---:|---|---|
| 1 | El job guarda `success` + fecha | `ticket_article_communicate_email_job.rb` 103-108 |
| 2 | El guardado del artículo dispara `after_commit :ticket_touch` | `ticket/article.rb` 49 |
| 3 | `ticket.touch` actualiza `updated_at` del ticket | idem 472-474 |
| 4 | El sondeo por `updated_at` lo encuentra | — |
| 5 | El webhook **no** lo ve: los updates de artículo se descartan | `lib/transaction_dispatcher.rb` 148-150 |

**Conclusión:** el sondeo es la única vía verificada. La prueba F0-06 de `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` debe confirmarlo con un envío real.

---

## 8. Alertas

| Métrica | 75 % | 90 % | Vencimiento |
|---|---:|---:|---:|
| Primera respuesta (24 h) | 18 h | 21,6 h | 24 h |
| Resolución 24 h | 18 h | 21,6 h | 24 h |
| Resolución 36 h | 27 h | 32,4 h | 36 h |
| Resolución 48 h | 36 h | 43,2 h | 48 h |
| Resolución 72 h | 54 h | 64,8 h | 72 h |
| Resolución 96 h | 72 h | 86,4 h | 96 h |
| Resolución 120 h | 90 h | 108 h | 120 h |

Una alerta por compromiso, ciclo, métrica y umbral. La emite el motor; no depende de workers de Zammad.

---

## 9. Auditoría

| Qué se audita | Cuándo |
|---|---|
| Publicación de política | Al activar una versión |
| Desactivación | Al retirar una política |
| Corrección de compromiso | Cualquier cambio posterior a la asignación |
| Corrección de ciclo | Ajuste de `closed_at` u `outcome` |
| Carga de matriz | Al importar una versión nueva |
| Asignación y cierre | Trazabilidad mínima (actor `service`) |

**Regla:** sin `reason` no se permite `correct`, `publish` ni `deactivate`. La tabla es de solo inserción.

---

## 10. Reconciliación

| Tipo | Frecuencia | Alcance | Qué corrige |
|---|---|---|---|
| Incremental | 15 min | `updated_at >= watermark − 15 min` | Eventos no observados |
| Diaria | 1/día | Abiertos + cerrados de 90 días + artículos sin confirmar de 24 h | Huecos y marcas faltantes |
| Semanal | 1/semana | Integridad: `close_at` vs historial, ciclos huérfanos, políticas | Divergencias estructurales |

**Regla:** la reconciliación **nunca** modifica `started_at`, `due_at`, `policy_key` ni ningún campo del snapshot. Solo agrega hechos y registra divergencias. La única excepción es una corrección auditada con aprobación.

---

## 11. Reportes

Niveles (DP-E-09, cerrado):

| Nivel | Contenido |
|---|---|
| Global | Cumplimiento de primera respuesta y resolución, meta 80 % |
| Por categoría | 9 categorías oficiales |
| Por subcategoría | 27 combinaciones con SLA + 3 sin evidencia (marcadas) |
| Por política | Incluye `provisional` para distinguir el respaldo |

**Todo reporte incluye obligatoriamente:**

1. denominador y numerador;
2. excluidos por motivo;
3. volumen fuera de catálogo y su peso;
4. marca `provisional` cuando aplique;
5. nota "envío aceptado ≠ entregado".

**Prohibido:** publicar un porcentaje sin su denominador.

---

## 12. Seguridad y permisos

### 12.1 Diseño verificado

| Control | Implementación |
|---|---|
| Credencial | Token de API ligado a un usuario técnico |
| Permiso de lectura | `groups_users.access = 'read'` en el grupo de soporte |
| Escritura de tickets | Bloqueada por `TicketPolicy#update?` (exige `change`/`full`) |
| Creación de artículos | Bloqueada por `Ticket::ArticlePolicy#create?` → `follow_up?` → `update?` |
| Borrado | Solo admin (`TicketPolicy#destroy?`) |
| Administración | Sin permiso `admin` |
| Cliente HTTP | Allowlist de método: solo `GET` |

**Verificado en código:** `app/policies/ticket_policy.rb` (show → `read`; update → `change_access?`; destroy → admin), `app/policies/ticket/article_policy.rb` (create → `follow_up?`), `app/models/concerns/has_groups.rb` 81-112 (`access` puede ser `read`).

### 12.2 Regla

La integración **no** puede modificar tickets, artículos, usuarios ni configuración, aunque quisiera. No es una convención: es una restricción de permisos verificable.

### 12.3 Datos personales

| Dato | Tratamiento |
|---|---|
| Cuerpo del correo | **No se almacena** |
| Adjuntos | **No se almacenan** |
| Dirección del cliente | **No se almacena** |
| Teléfono | **No se almacena** |
| Nombre del agente | Solo `id` |
| Mensaje de error de envío | Truncado a 500 caracteres, sin datos del destinatario |

---

## 13. Persistencia y recuperación (DP-07)

| Escenario | Comportamiento |
|---|---|
| Caída del BFF | Al reiniciar, retoma desde el watermark del último `sla_sync_run` `ok`; reprocesa 15 min de solape |
| Caída de Zammad | El sondeo falla, el run queda `failed` y el watermark **no avanza**; al volver, recupera el hueco |
| Pérdida de conectividad | Igual que caída de Zammad; reintentos con backoff exponencial |
| Evento duplicado | `idempotency_key` lo descarta |
| Evento fuera de orden | Se aplica por `occurred_at`; si contradice un hecho ya aplicado, se registra divergencia y se resuelve con la regla de precedencia (más antiguo gana para `first_response_at`; más reciente gana para estado) |
| Sondeo atrasado | El solape de 15 min y la reconciliación diaria lo cubren |
| Base del BFF caída | El motor no puede operar; al volver, reconstruye desde el último snapshot. **No** se pierde el histórico porque vive en la base del BFF, no en memoria |

**Diseño de persistencia:**

1. PostgreSQL del BFF con escritura síncrona antes de confirmar el evento.
2. `sla_event` como registro de verdad; las proyecciones (`sla_commitment`, `sla_cycle`) se pueden reconstruir.
3. Respaldo diario de la base del BFF.
4. El snapshot es inmutable, por lo que una reconstrucción no cambia compromisos ya asignados.

**Estado:** cerrado en diseño. La aprobación de infraestructura (motor, respaldo, monitoreo) queda para la autorización de implementación.

---

## 14. Retención

| Tabla | Retención |
|---|---|
| `sla_event` (applied/ignored) | 2 años |
| `sla_event` (failed) | Hasta resolución |
| `sla_commitment`, `sla_cycle` | Permanente |
| `sla_policy_version` | Permanente |
| `sla_audit` | 5 años |
| `sla_alert` | 1 año |
| `sla_divergence` | Permanente hasta resolver; después 2 años |
| `sla_sync_run` | 1 año |
| `sla_article_delivery` | Igual que el artículo, sin cuerpos |

---

## 15. Criterios de aceptación

Se detallan en `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md`. Resumen:

| Bloque | Pruebas | Bloqueante |
|---|---:|---|
| Línea base y no modificación | F0-01 a F0-05 | Sí |
| Detección de envío y cierre | F0-06 a F0-09 | Sí |
| Reproducibilidad de la matriz | F0-10, F0-11 | Sí |
| Recuperación e idempotencia | F0-12 a F0-14 | Sí |
| Seguridad y datos | F0-15, F0-16 | Sí |

**Ninguna fase posterior se autoriza si una prueba bloqueante falla.**

---

## 16. Riesgos residuales

| ID | Riesgo | Nivel | Mitigación |
|---|---|---|---|
| R-01 | `success` se interpreta como entregado | Alto | Nota obligatoria en reportes |
| R-02 | Fallo transitorio tratado como definitivo | Medio | Solo tras `delivery_retry > 3` |
| R-03 | Reaperturas por fallo de correo inflan indicadores | Medio | `reopen_hint` y desagregación |
| R-04 | `pending close` vence sin acción | Medio | Alertas 75/90 % |
| R-05 | Categoría COSE ≠ categoría oficial (10 filas) | Alto | Clasificar con la matriz |
| R-06 | 32,5 % fuera de catálogo con respaldo 36 h | Alto | Medido; revisar catálogo (DP-04) |
| R-07 | 3 combinaciones sin SLA | Medio | Excluidas con motivo |
| R-08 | Clasificación tardía | Medio | Indicador separado |
| R-09 | La confirmación no eleva `updated_at` | Bajo (código lo garantiza) | F0-06 |
| R-10 | Paginación por desplazamiento | Medio | Orden estable + solape |
| R-11 | Rebote asíncrono no reflejado | Medio | Límite del canal; documentado |

---

## 17. Decisiones incorporadas

| ID | Estado |
|---|---|
| DP-E-01 Matriz oficial | Cerrada |
| DP-E-02 Respaldo solo fuera de catálogo | Cerrada |
| DP-E-03 Cadencia 5 min + banda 2 min | Cerrada |
| DP-E-04 Primera respuesta `< 24 h` | Cerrada |
| DP-E-05 `merged` excluido | Cerrada |
| DP-E-06 `fail` definitivo tras 3 reintentos | Cerrada |
| DP-E-07 3 combinaciones sin SLA | Cerrada |
| DP-E-08 Volumen fuera de catálogo | Cerrada (1.016 / 32,51 %) |
| DP-E-09 Reporte global + categoría | Cerrada |
| DP-E-10 Mantener `channel` con `CHECK ('email')` | Cerrada |
| DP-E-11 Clasificación tardía separada | Cerrada |
| DP-E-12 Sin cuerpos de correo | Cerrada |
| REA-02 a REA-06 | Cerradas |
| DP-07 Persistencia | Cerrada en diseño |
| **DP-04 Responsable del catálogo** | **ABIERTA** |

---

## 18. Confirmación

Especificación documental. No se creó ninguna tabla, índice, restricción, evento, credencial, servicio ni política. No se modificó Zammad, Zendesk ni COSE. No se inició ningún worker.
