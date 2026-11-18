# CONTRATO DE EVENTOS DEL MOTOR SLA — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** diseño. **No se implementó ningún endpoint.**

---

## 1. Principios

1. Todo evento es **inmutable** y se identifica por una clave de idempotencia.
2. El contrato es **agnóstico a la fuente**: webhook, sondeo o reconciliación producen el mismo formato.
3. El evento describe **un hecho ocurrido en Zammad**, no una instrucción.
4. El motor SLA decide qué hacer; el evento no ordena recalcular.
5. El contrato tiene versión explícita.
6. Los eventos de entrega se marcan como **hechos de artículo**, no de ticket.

---

## 2. Envoltorio común

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `event_id` | uuid v4 | Sí | Identificador único del evento en el BFF |
| `event_type` | string | Sí | Tipo del catálogo (§4) |
| `event_version` | integer | Sí | Versión del contrato (inicial: 1) |
| `occurred_at` | timestamptz | Sí | Cuándo ocurrió en Zammad |
| `received_at` | timestamptz | Sí | Cuándo llegó al BFF |
| `source` | enum | Sí | `webhook`, `poll`, `reconcile`, `manual` |
| `ticket_id` | integer | Sí | Ticket afectado |
| `idempotency_key` | string | Sí | Clave única (§3) |
| `payload_version` | string | Sí | Versión del esquema de datos |
| `actor_id` | integer | No | Usuario que causó el hecho |
| `actor_type` | enum | No | `agent`, `customer`, `system`, `trigger`, `job` |
| `article_id` | integer | No | Artículo relacionado |
| `history_id` | integer | No | Registro de historial relacionado |
| `old_value` | jsonb | No | Valor anterior |
| `new_value` | jsonb | No | Valor nuevo |
| `changes` | jsonb | No | Conjunto de cambios |
| `zammad_delivery_id` | string | No | `X-Zammad-Delivery` si vino por webhook |
| `correlation_id` | string | No | Agrupa eventos de una misma transacción |

### 2.1 Regla de obligatoriedad por origen

| Origen | `event_id` | `zammad_delivery_id` | `history_id` | `article_id` |
|---|---|---|---|---|
| `webhook` | Generado por el BFF | **Sí** | No | Según evento |
| `poll` | Generado por el BFF | No | No | Según evento |
| `reconcile` | Generado por el BFF | No | **Sí** | Según evento |

---

## 3. Clave de idempotencia

```
idempotency_key = sha256(
  source_family + '|' + event_type + '|' + ticket_id + '|' +
  coalesce(article_id, history_id, '-') + '|' + occurred_at_iso8601
)
```

Donde `source_family` es `zammad` para cualquier origen, de modo que un evento visto por webhook y por reconciliación produzca la misma clave.

**Excepción:** los eventos de entrega usan `article_id` y el valor de estado, porque un artículo puede pasar por `success` y luego `fail`:

```
idempotency_key = sha256('zammad|article.delivery|' + article_id + '|' + delivery_state + '|' + occurred_at)
```

---

## 4. Catálogo de eventos

### 4.1 Obligatorios

| `event_type` | Cuándo se emite | Obligatorio |
|---|---|---|
| `ticket.created` | Alta del ticket | **Sí** |
| `ticket.state_changed` | Cambio de estado | **Sí** |
| `ticket.closed` | Transición a tipo `closed` | **Sí** |
| `ticket.reopened` | De `closed` a estado abierto | **Sí** |
| `article.created` | Nuevo artículo | **Sí** |
| `article.delivery_confirmed` | Envío exitoso confirmado | **Sí** |
| `article.delivery_failed` | Envío fallido | **Sí** |
| `ticket.classified` | Cambio de categoría o subcategoría | **Sí** |

### 4.2 Opcionales

| `event_type` | Cuándo se emite | Obligatorio |
|---|---|---|
| `ticket.assigned` | Cambio de propietario | No |
| `ticket.priority_changed` | Cambio de prioridad | No |
| `ticket.group_changed` | Cambio de grupo | No |
| `ticket.channel_detected` | Canal identificado en el alta | No |
| `ticket.merged` | Fusión con otro ticket | No |
| `article.internal_note` | Nota interna | No |

### 4.3 Eventos que no se emiten

| Situación | Motivo |
|---|---|
| Recalculo de escalamiento | No es un hecho del negocio |
| Cambio de `updated_at` | Ruido |
| Cambio de contadores | Ruido |
| Apertura de la ficha | No es un hecho persistente |

---

## 5. Especificación por evento

### 5.1 `ticket.created`

Obligatorios: `ticket_id`, `occurred_at`, `source`, `idempotency_key`.

Recomendados: `new_value.state`, `new_value.group_id`, `new_value.priority_id`, `new_value.channel`, `new_value.category`, `new_value.subcategory`.

```json
{
  "event_id": "0f4c2f7e-8a5f-4d0e-9b1c-3a2f5d6e7c80",
  "event_type": "ticket.created",
  "event_version": 1,
  "payload_version": "1.0",
  "occurred_at": "2026-11-16T10:00:00-05:00",
  "received_at": "2026-11-16T10:00:02-05:00",
  "source": "webhook",
  "ticket_id": 101,
  "idempotency_key": "a3f1...",
  "actor_type": "customer",
  "new_value": {
    "state": "new",
    "group_id": 2,
    "priority_id": 2,
    "channel": "whatsapp",
    "category": "SOPORTE",
    "subcategory": "ERROR_WEB"
  }
}
```

### 5.2 `ticket.state_changed`

Obligatorios: `old_value.state`, `new_value.state`, `occurred_at`.

```json
{
  "event_type": "ticket.state_changed",
  "ticket_id": 101,
  "old_value": { "state": "new" },
  "new_value": { "state": "open" },
  "actor_type": "agent",
  "actor_id": 5,
  "occurred_at": "2026-11-16T10:05:00-05:00",
  "source": "webhook"
}
```

### 5.3 `ticket.closed`

Obligatorios: `new_value.state`, `new_value.close_at`.

Regla: se emite **solo** en la primera transición a un estado de tipo `closed`. Si el ticket ya tenía `close_at`, el evento se marca `new_value.is_reclose = true` y **no** reinicia el primer ciclo.

### 5.4 `ticket.reopened`

Obligatorios: `old_value.state`, `new_value.state`, `old_value.close_at`.

Regla: se emite cuando el estado pasa de tipo `closed` a un estado abierto. No borra el cierre anterior.

### 5.5 `article.created`

Obligatorios: `article_id`, `new_value.internal`, `new_value.sender`, `new_value.type`, `new_value.created_at`.

Regla: el motor decide si es candidato a primera respuesta. Un artículo interno nunca lo es.

### 5.6 `article.delivery_confirmed`

Obligatorios: `article_id`, `new_value.delivery_status = 'success'`, `new_value.delivered_at`.

Opcionales: `new_value.external_message_id`, `new_value.channel`, `new_value.receipt_level`.

`receipt_level`:

| Valor | Significado | Disponible en |
|---|---|---|
| `accepted` | Aceptado por el servidor o proveedor | Correo y WhatsApp |
| `delivered` | Entregado al destinatario | WhatsApp |
| `read` | Leído | WhatsApp |

### 5.7 `article.delivery_failed`

Obligatorios: `article_id`, `new_value.delivery_status = 'fail'`, `new_value.failed_at`.

Opcionales: `new_value.error_message`, `new_value.retry_count`.

### 5.8 `ticket.classified`

Obligatorios: `old_value.category`, `old_value.subcategory`, `new_value.category`, `new_value.subcategory`.

Regla: si el ticket ya tiene compromiso, el evento **no** lo modifica; se registra como reclasificación.

---

## 6. Orden y versionado

| Aspecto | Regla |
|---|---|
| Orden de emisión | No garantizado |
| Orden de aplicación | Por `occurred_at`, con desempate por `event_id` |
| Eventos tardíos | Se aplican si son hechos; no retroceden estado |
| Cambio de esquema | Sube `event_version`; el BFF mantiene compatibilidad con la versión anterior |
| Campos nuevos | Opcionales y tolerados por el receptor |

---

## 7. Validación y respuestas

| Situación | Respuesta esperada |
|---|---|
| Evento válido y nuevo | `202 Accepted` |
| Evento duplicado | `200 OK` con `duplicate: true` |
| Evento inválido | `400 Bad Request` con detalle |
| Firma inválida | `401 Unauthorized` |
| Tipo desconocido | `202 Accepted` y se archiva sin procesar |
| Error interno | `500` para forzar reintento |

---

## 8. Seguridad

1. HMAC-SHA1 con `X-Hub-Signature` (compatible con `lib/user_agent.rb` 119-123).
2. Token de API adicional en cabecera propia para el sondeo.
3. Lista de IP permitidas, si el despliegue lo permite.
4. TLS obligatorio.
5. Sin datos sensibles en el payload: no se envían contraseñas, tokens ni cuerpos completos de correo salvo necesidad.

---

## 9. Resumen de obligatoriedad

| Campo | Obligatorio | Opcional |
|---|---|---|
| `event_id` | Sí | — |
| `ticket_id` | Sí | — |
| `event_type` | Sí | — |
| `occurred_at` | Sí | — |
| `received_at` | Sí | — |
| `source` | Sí | — |
| `idempotency_key` | Sí | — |
| `payload_version` | Sí | — |
| `article_id` | — | Sí |
| `actor_id` | — | Sí |
| `old_value` | — | Sí |
| `new_value` | — | Sí |
| `changes` | — | Sí |

---

## 10. Pendientes

| # | Pendiente |
|---:|---|
| 1 | Aprobar los ocho eventos obligatorios |
| 2 | Definir si `ticket.channel_detected` es obligatorio |
| 3 | Definir política de retención del payload |
| 4 | Definir si se envía el cuerpo del artículo o solo metadatos |

---

## 11. Confirmación

No se creó ningún endpoint, tabla ni esquema. Este documento es un contrato conceptual.
