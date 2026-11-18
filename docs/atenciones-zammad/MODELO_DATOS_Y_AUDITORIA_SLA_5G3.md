# MODELO DE DATOS Y AUDITORÍA — SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No se creó ninguna tabla.**

---

## 1. Principio

Se distinguen tres capas:

1. **Configuración nativa de Zammad:** tabla `slas`.
2. **Catálogo y versionado de la matriz:** tablas propias o archivos versionados.
3. **Snapshot por ticket:** atributos o tabla propia para congelar el SLA y registrar reclasificaciones/reaperturas.

No se duplica el motor de tickets. Zammad sigue siendo la fuente de verdad.

---

## 2. Modelo nativo verificado

### 2.1 `slas`

| Columna | Tipo | Nulo | Observación |
|---|---|---|---|
| `id` | serial | no | — |
| `calendar_id` | integer | **no** | Obligatorio |
| `name` | string(150) | validado | Único, case-insensitive |
| `first_response_time` | integer | sí | Minutos |
| `response_time` | integer | sí | No se usará |
| `update_time` | integer | sí | No se usará |
| `solution_time` | integer | sí | Minutos |
| `condition` | text | sí | Selector serializado |
| `data` | text | sí | UI |
| `created_by_id` | integer | no | — |
| `updated_by_id` | integer | no | — |
| `created_at` | timestamp | no | — |
| `updated_at` | timestamp | no | — |

**VERIFICADO en `db/schema.rb` y `app/models/sla.rb`.**

### 2.2 `calendars`

| Columna | Uso |
|---|---|
| `name` | `SLA 24x7` propuesto |
| `timezone` | `America/Lima` |
| `business_hours` | 00:00–23:59 todos los días |
| `public_holidays` | `{}` |
| `default` | `false` |

**PROPUESTA.** No se creó.

### 2.3 `ticket_states`

| Columna | Uso |
|---|---|
| `ignore_escalation` | Pausa el reloj |
| `state_type_id` | `closed` para resolución |

**VERIFICADO:** columna booleana, default `false`. Valores actuales: `pending reminder=true`, `pending close=true`, `closed=true`, `merged=true`.

---

## 3. Catálogo de políticas

### 3.1 Propósito

Mantener la matriz de 65 combinaciones como fuente de verdad, independiente de los registros `slas`. Permite versionar, comparar y regenerar políticas.

### 3.2 Tabla propuesta `sla_policy_catalog`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid | PK |
| `policy_key` | text | Clave única, ej. `20-MAIL-SOFTWARE-ERROR_WEB` |
| `channel` | text | `whatsapp` / `correo` |
| `category` | text | Categoría oficial |
| `subcategory` | text | Subcategoría oficial |
| `first_response_minutes` | integer | 15 / 1440 |
| `resolution_minutes` | integer | NULL si pendiente |
| `confidence` | text | ALTA / MEDIA / BAJA / INSUFICIENTE |
| `sample_size` | integer | n |
| `p75_minutes` | numeric | P75 |
| `source_window_start` | date | 2026-04-01 |
| `source_window_end` | date | 2026-10-31 |
| `status` | text | active / inactive / pending |
| `provisional` | boolean | Respaldo provisional |
| `version` | integer | Versión de matriz |
| `created_at` | timestamp | — |
| `updated_at` | timestamp | — |

### 3.3 Tabla propuesta `sla_policy_versions`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid | PK |
| `policy_key` | text | FK lógica |
| `version` | integer | — |
| `resolution_minutes` | integer | Valor |
| `changed_by` | text | Usuario |
| `changed_at` | timestamp | — |
| `reason` | text | Motivo |
| `source` | text | Matriz / manual |

**PROPUESTA.** No se creó.

---

## 4. Snapshot por ticket

### 4.1 Problema

El motor nativo recalcula el SLA cuando cambia la categoría. Para congelar el SLA inicial se necesita un snapshot.

### 4.2 Opción A — atributos de ticket

Agregar atributos:

| Atributo | Tipo | Uso |
|---|---|---|
| `sla_policy_key` | input | Clave de la política congelada |
| `sla_started_at` | datetime | `created_at` |
| `sla_first_response_due_at` | datetime | Cálculo |
| `sla_resolution_due_at` | datetime | Cálculo |
| `sla_first_response_at` | datetime | Marca real |
| `sla_first_closed_at` | datetime | Primer cierre |
| `sla_reopen_count` | integer | Reaperturas |
| `sla_reclassified_at` | datetime | Última reclasificación |
| `sla_reclassified_from` | input | Clave anterior |
| `sla_reclassified_to` | input | Clave nueva |

**PROPUESTA.** Requiere crear atributos (no autorizado en esta etapa).

### 4.3 Opción B — tabla `sla_ticket_snapshot`

| Columna | Tipo | Descripción |
|---|---|---|
| `ticket_id` | integer | FK |
| `policy_key` | text | Política congelada |
| `started_at` | timestamp | `created_at` |
| `first_response_due_at` | timestamp | — |
| `resolution_due_at` | timestamp | — |
| `first_response_at` | timestamp | — |
| `first_closed_at` | timestamp | — |
| `reopen_count` | integer | — |
| `last_reclassified_at` | timestamp | — |
| `last_reclassified_from` | text | — |
| `last_reclassified_to` | text | — |
| `created_at` | timestamp | — |
| `updated_at` | timestamp | — |

**PROPUESTA.** Requiere crear tabla (no autorizado).

### 4.4 Recomendación

Opción A para el piloto (menos infraestructura); Opción B si se necesita historial completo de reclasificaciones y reaperturas.

---

## 5. Auditoría

### 5.1 Nativa

**VERIFICADO:** `Sla` incluye `HasAuditLogs`.

**PENDIENTE:** confirmar si guarda:

- Usuario.
- Fecha.
- Valor anterior.
- Valor nuevo.
- Campo.

Si no los guarda, se necesita una tabla propia.

### 5.2 Tabla propuesta `sla_policy_audit`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid | PK |
| `policy_key` | text | Política |
| `action` | text | create / update / deactivate / reactivate |
| `field` | text | `first_response_minutes` / `resolution_minutes` |
| `old_value` | text | Anterior |
| `new_value` | text | Nuevo |
| `user` | text | Usuario |
| `reason` | text | Motivo |
| `created_at` | timestamp | — |
| `request_id` | text | Correlación |

**PROPUESTA.**

### 5.3 Auditoría de reclasificación

| Columna | Tipo | Descripción |
|---|---|---|
| `ticket_id` | integer | Ticket |
| `old_policy_key` | text | Anterior |
| `new_policy_key` | text | Nueva |
| `user` | text | Usuario |
| `created_at` | timestamp | — |
| `note` | text | Motivo |

**PROPUESTA.**

### 5.4 Auditoría de reapertura

| Columna | Tipo | Descripción |
|---|---|---|
| `ticket_id` | integer | Ticket |
| `closed_at` | timestamp | Primer cierre |
| `reopened_at` | timestamp | Reapertura |
| `user` | text | Usuario |
| `note` | text | Motivo |

**PROPUESTA.**

---

## 6. Alertas

### 6.1 Tabla propuesta `sla_alerts`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid | PK |
| `ticket_id` | integer | Ticket |
| `metric` | text | first_response / resolution |
| `threshold` | integer | 75 / 90 |
| `due_at` | timestamp | Vencimiento |
| `sent_at` | timestamp | Envío |
| `channel` | text | email / internal |
| `status` | text | pending / sent / failed |

**PROPUESTA.**

---

## 7. Datos de origen estadístico

Cada política debe guardar:

- Ventana: 2026-04-01 a 2026-10-31.
- n.
- P75.
- Confianza.
- Fecha de corte.
- Versión de la matriz.
- Método: P75 + escalera operativa.

**VERIFICADO en `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md`.**

---

## 8. Relación con COSE

COSE no almacena el SLA; lo consume. El BFF expone:

- `ticket_id`
- `channel`
- `category`
- `subcategory`
- `policy_key`
- `first_response_due_at`
- `first_response_at`
- `resolution_due_at`
- `first_closed_at`
- `status`
- `reopen_count`
- `history`

**PROPUESTA.** No se implementa.

---

## 9. Retención

| Dato | Retención propuesta |
|---|---|
| Snapshot por ticket | Mientras exista el ticket |
| Auditoría de políticas | 5 años |
| Alertas | 1 año |
| Versiones de matriz | Permanente |

**PENDIENTE** de aprobación.

---

## 10. Índices y rendimiento

Propuesta:

- `sla_policy_catalog(policy_key)` único.
- `sla_policy_catalog(channel, category, subcategory)` único.
- `sla_policy_audit(policy_key, created_at)`.
- `sla_ticket_snapshot(ticket_id)` único.
- `sla_alerts(status, due_at)`.

**PROPUESTA.** No se creó ningún índice.

---

## 11. Confirmación

No se creó ninguna tabla, atributo, índice ni registro. Todo es diseño.
