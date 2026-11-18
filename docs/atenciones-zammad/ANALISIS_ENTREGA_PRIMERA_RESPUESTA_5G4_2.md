# ANÁLISIS DE ENTREGA Y PRIMERA RESPUESTA — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** auditoría de solo lectura. **No se modificó nada.**

---

## 1. Objetivo

Determinar cómo calcular una primera respuesta **efectivamente entregada**, distinguiendo entre:

- artículo creado;
- artículo público;
- artículo enviado;
- envío fallido;
- envío pendiente;
- recepción confirmada por el destinatario.

---

## 2. Regla nativa actual

**VERIFICADO (código).** `first_response_at` se fija en `app/models/ticket/article/has_ticket_contact_attributes_impact.rb` 59-82, cuando se cumplen cinco condiciones:

1. No está en modo importación.
2. El artículo no es interno.
3. El emisor es `Agent`.
4. El tipo de artículo es de comunicación (`type.communication`).
5. `ticket.first_response_at` está vacío.

La marca asignada es `created_at` del artículo:

```ruby
ticket.first_response_at = created_at
```

No se consulta ningún estado de envío. No se espera confirmación. No se verifica el destinatario.

**Consecuencia:** una respuesta que falla al enviarse cuenta como primera respuesta.

---

## 3. Correo electrónico

### 3.1 Flujo verificado

| Paso | Qué ocurre | Referencia |
|---|---|---|
| 1 | Se crea el artículo. `first_response_at` se fija aquí. | `has_ticket_contact_attributes_impact.rb` 79 |
| 2 | `after_create_commit` encola el envío. | `app/models/ticket/article/enqueue_communicate_email_job.rb` 8-30 |
| 3 | El job envía y registra el resultado. | `app/jobs/ticket_article_communicate_email_job.rb` 103-108 |
| 4 | Si falla, registra `delivery_status='fail'` y el mensaje. | `ticket_article_communicate_email_job.rb` 138-150 |
| 5 | Reintenta hasta 4 veces. | `ticket_article_communicate_email_job.rb` 4-6 |

### 3.2 Campos disponibles

**VERIFICADO (datos).** En `ticket_articles.preferences`:

| Campo | Significado | Ejemplo observado |
|---|---|---|
| `delivery_status` | `success` o `fail` | `success` |
| `delivery_status_date` | Momento del resultado | `2026-11-14 14:32:10 UTC` |
| `delivery_status_message` | Error, si aplica | `nil` |
| `delivery_retry` | Número de intentos | `1` |
| `delivery_channel_id` | Canal usado | `4` |
| `email_address_id` | Dirección de salida | `2` |

Identificador externo: `ticket_articles.message_id` (Message-ID RFC 5322). Ejemplo observado:

```
<20261114045755.7.cd8a24b2-b684-4b75-b093-82f73cb12f7e@localhost:3000>
```

### 3.3 Evidencia empírica

**VERIFICADO (datos).** Ticket 7:

| Artículo | Emisor | `delivery_status` | `delivery_status_date` |
|---:|---|---|---|
| 3 | Agent | `success` | 2026-11-14 14:32:10 UTC |
| 4 | Agent | **ausente** | — |

```
first_response_at = 2026-11-14 04:57:54.943 UTC
article 3 creado  = 2026-11-14 04:57:54.943 UTC
diferencia        = 0.000 s
envío confirmado  = 2026-11-14 14:32:10 UTC  (9 h 34 min después)
```

Conclusiones:

1. La marca de primera respuesta **no** refleja el envío.
2. Existe al menos un artículo público de agente **sin** estado de envío.
3. El estado de envío puede llegar horas después o no llegar.

### 3.4 ¿Hay confirmación de recepción?

**No.** Zammad registra el resultado del envío SMTP, no la recepción por el destinatario. No hay DSN, ni acuse de lectura, ni tracking de apertura.

| Nivel | Disponible en correo |
|---|---|
| Creado | Sí |
| Público | Sí |
| Enviado (SMTP aceptado) | Sí (`delivery_status=success`) |
| Entregado al buzón | **No** |
| Leído | **No** |

---

## 4. WhatsApp

### 4.1 Flujo verificado

| Paso | Qué ocurre | Referencia |
|---|---|---|
| 1 | Se crea el artículo `whatsapp message`. | `app/models/ticket/article/enqueue_communicate_whatsapp_job.rb` 8-25 |
| 2 | `after_create_commit` encola `CommunicateWhatsappJob`. | idem |
| 3 | El servicio de entrega obtiene el `message_id` del proveedor. | `app/services/service/ticket/article/type/whatsapp_message/deliver.rb` 24-31 |
| 4 | Se guarda `article.message_id` y `preferences['whatsapp']['message_id']`. | idem |
| 5 | Se registra `delivery_status='success'` en el artículo. | `app/services/service/ticket/article/type/base_deliver.rb` 58-64 |
| 6 | Los estados posteriores llegan por webhook del proveedor. | `lib/whatsapp/webhook/message/status.rb` 11-35 |
| 7 | Reintenta hasta 4 veces con espera de 120 s. | `app/jobs/communicate_whatsapp_job.rb` 5-7 |

### 4.2 Estados disponibles

**VERIFICADO (código).** Clases en `lib/whatsapp/webhook/message/status/`:

| Estado | Campo escrito | Referencia |
|---|---|---|
| `sent` | `preferences[:whatsapp][:timestamp_sent]` y `ticket.preferences[:whatsapp][:timestamp_outgoing]` | `sent.rb` 5-15 |
| `delivered` | `preferences[:whatsapp][:timestamp_delivered]` | `delivered.rb` 5-8 |
| `read` | `preferences[:whatsapp][:timestamp_read]` | `read.rb` 5-8 |
| `failed` | `delivery_status='fail'`, fecha y mensaje; crea artículo interno | `failed.rb` 15-31 |

Identificador externo: `ticket_articles.message_id`, asignado desde el proveedor.

### 4.3 Limitaciones

1. **Requiere canal WhatsApp configurado y webhook del proveedor activo.** No verificado en esta instalación.
2. **Los estados `delivered` y `read` solo actualizan el artículo**, y esas actualizaciones se descartan en el despachador (`lib/transaction_dispatcher.rb` 148-150). No generan evento.
3. **`sent` sí actualiza el ticket**, por lo que podría generar una transacción (INFERIDO, no probado).
4. **No hay evidencia de la cuenta del proveedor** en esta instalación: PENDIENTE.

### 4.4 Comparación correo vs WhatsApp

| Nivel | Correo | WhatsApp |
|---|---|---|
| Creado | Sí | Sí |
| Público | Sí | Sí |
| Aceptado por el proveedor | Sí (`success`) | Sí (`success` + `message_id`) |
| Entregado al destinatario | No | Sí (`timestamp_delivered`) |
| Leído | No | Sí (`timestamp_read`) |
| Fallo explícito | Sí (`fail`) | Sí (`fail`) |
| Identificador externo | Message-ID | `message_id` del proveedor |

**WhatsApp ofrece más información que el correo**, pero solo si el canal está operativo.

---

## 5. Definiciones propuestas

| Concepto | Definición operativa |
|---|---|
| Artículo creado | Existe fila en `ticket_articles` |
| Artículo público | `internal = false` |
| Artículo enviado | `preferences['delivery_status'] = 'success'` |
| Envío fallido | `preferences['delivery_status'] = 'fail'` |
| Envío pendiente | Sin `delivery_status` y con job aún no ejecutado o perdido |
| Recepción confirmada | WhatsApp: `timestamp_delivered` o `timestamp_read`. Correo: **no disponible** |

---

## 6. Cálculo propuesto de primera respuesta efectiva

Regla propuesta, expresada en pseudocódigo (no es implementación):

```
primera_respuesta_efectiva(ticket) =
  primer artículo A, ordenado por created_at ascendente, tal que:
    A.internal = false
    A.sender = 'Agent'
    A.type.communication = true
    A.preferences.delivery_status = 'success'
    (si el canal es WhatsApp) A.preferences.whatsapp.timestamp_delivered presente
```

Reglas complementarias:

1. Si el primer artículo candidato tiene `delivery_status = 'fail'`, **no cuenta**.
2. Si no tiene estado, **no cuenta todavía**; el ticket queda en estado `pendiente de confirmación`.
3. Si aparece un segundo artículo con envío exitoso, ese segundo artículo es la primera respuesta efectiva.
4. La marca temporal es `delivery_status_date` si existe; si no, `preferences.whatsapp.timestamp_delivered`.
5. Para correo, el cumplimiento se mide contra la aceptación SMTP, no contra la recepción.
6. El SLA no se considera cumplido por un artículo sin envío confirmado.

### 6.1 Diferencia con el requisito aprobado

El requisito de 5G.3 dice "una respuesta pública de un agente cuenta como primera respuesta". La propuesta 5G.4.2 lo endurece: cuenta **si y solo si se envió**. Esto debe aprobarse explícitamente, porque cambia el criterio de medición.

### 6.2 Efecto en el cálculo del SLA

```
vencimiento_primera_respuesta = created_at + first_response_time
cumplida = primera_respuesta_efectiva existe
           y primera_respuesta_efectiva.marca <= vencimiento_primera_respuesta
```

Si el envío se confirma después del vencimiento, el ticket es **incumplido** aunque el artículo se haya creado a tiempo. Es el comportamiento correcto según el requisito de "no contar un mensaje que nunca llegó".

---

## 7. Casos límite

| Caso | Tratamiento propuesto |
|---|---|
| Artículo creado, job nunca ejecutado (worker detenido) | Pendiente de confirmación; no cumple |
| Artículo con `fail` y reintento posterior exitoso | Cuenta el reintento, con su fecha |
| Artículo con `fail` definitivo y sin reintento | No cumple |
| Varios artículos públicos seguidos | Cuenta el primero con envío exitoso |
| Artículo de trigger con emisor `System` | No cuenta (no es `Agent`) |
| Artículo de agente interno | No cuenta (`internal = true`) |
| Nota interna | No cuenta |
| Correo aceptado por SMTP pero rebotado después | Cuenta como enviado; el rebote no se detecta |
| WhatsApp `sent` sin `delivered` | Envío aceptado; no hay recepción confirmada |
| Ticket sin ningún artículo de agente | Sin primera respuesta |

---

## 8. Criterios de aceptación

1. Un artículo con `delivery_status='fail'` no cuenta como primera respuesta.
2. Un artículo sin `delivery_status` no cuenta como cumplida, pero tampoco como incumplida hasta que se resuelva su estado.
3. Un artículo con envío exitoso cuenta con la fecha del envío.
4. El cálculo es reproducible a partir de datos persistidos en Zammad.
5. No se requiere modificar Zammad para obtener el dato.
6. El estado de la primera respuesta es auditable: se puede explicar por qué un ticket cumple o no.

---

## 9. Pendientes de verificación

| # | Pendiente | Cómo se verificaría |
|---:|---|---|
| 1 | Que la API exponga `preferences` del artículo a un token de solo lectura | Llamada GET a `/api/v1/ticket_articles/:id` |
| 2 | Que WhatsApp `sent` genere transacción | Prueba con canal configurado |
| 3 | Que `delivered`/`read` no generen transacción | Lectura de código ya lo indica; falta prueba |
| 4 | Comportamiento cuando el job falla definitivamente | Prueba con SMTP inválido |
| 5 | Existencia de canal WhatsApp en producción | Inventario de canales |

---

## 10. Confirmación

No se modificó ningún artículo, job, canal ni trigger. No se envió ningún mensaje. Solo se ejecutaron lecturas.
