# AUDITORÍA DE EVENTOS DE ZAMMAD — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** auditoría de solo lectura. **No se modificó nada.**
**Código auditado:** `/home/acast/mailing` (Zammad 7.2.3)

---

## 1. Objetivo y método

Determinar qué mecanismos de Zammad permiten al futuro motor SLA propio detectar los trece eventos requeridos, con qué garantías y con qué limitaciones.

Método:

1. Lectura de código fuente con referencias a archivo y línea.
2. Consultas de solo lectura a la base de datos de la instalación.
3. Ninguna escritura, ningún webhook, ningún trigger, ningún worker iniciado.

Cada afirmación se clasifica así:

| Marca | Significado |
|---|---|
| **VERIFICADO (código)** | Leído en el código instalado |
| **VERIFICADO (datos)** | Observado en la base de la instalación |
| **INFERIDO** | Deducido del código, sin prueba de ejecución |
| **PENDIENTE** | Requiere prueba controlada |

---

## 2. Estado actual de la instalación

**VERIFICADO (datos):**

| Elemento | Valor |
|---|---:|
| SLA | 0 |
| Calendarios | 2 |
| Webhooks | **0** |
| Triggers totales | 3 |
| Triggers activos | **0** |
| Tickets | 2 |
| Artículos | 5 |
| Registros en `audit_logs` | 29 |
| Registros en `histories` | 44 |
| Worker | Detenido |

Triggers existentes, todos inactivos:

| ID | Nombre | Activador | Activo |
|---:|---|---|---|
| 1 | auto reply (on new tickets) | action | false |
| 2 | auto reply (on follow-up of tickets) | action | false |
| 3 | customer notification (on owner change) | action | false |

**Consecuencia:** hoy la instalación no emite ningún evento hacia el exterior. Cualquier mecanismo de captura requiere configuración nueva y autorización.

---

## 3. Mecanismos disponibles

### 3.1 Webhooks nativos

**VERIFICADO (código).**

Modelo `Webhook` (`app/models/webhook.rb`):

- Campos en `db/schema.rb` 1812-1824: `name`, `endpoint`, `http_method` (post/put/patch/delete), `signature_token`, `ssl_verify`, `basic_auth_username`, `basic_auth_password`, `bearer_token`, `customized_payload`, `custom_payload`, `pre_defined_webhook_type`, `active`.
- Secretos marcados como sensibles (`app/models/webhook.rb` 14).

Ejecución (`app/jobs/trigger_webhook_job.rb`):

| Aspecto | Comportamiento | Referencia |
|---|---|---|
| Disparo | Solo desde una acción de trigger `notification.webhook` | `app/models/ticket/perform_changes/action/notification_webhook.rb` 12-22 |
| Momento | Fase `after_commit` | `notification_webhook.rb` 6-8 |
| Reintentos | 5 intentos, espera `executions * 10s` | `trigger_webhook_job.rb` 7-10 |
| Condición de reintento | Solo si la respuesta HTTP no es exitosa | `trigger_webhook_job.rb` 36-38 |
| Error de resolución DNS | No reintenta; solo registra | `trigger_webhook_job.rb` 40-42 |
| Cabeceras | `X-Zammad-Trigger`, `X-Zammad-Delivery` (= `job_id`) | `trigger_webhook_job.rb` 99-102 |
| Firma | HMAC-SHA1 sobre el cuerpo: `X-Hub-Signature: sha1=...` | `lib/user_agent.rb` 119-123 |
| Autenticación adicional | Basic auth o bearer token | `trigger_webhook_job.rb` 83-90 |
| Payload por defecto | `{ ticket: ..., article: ... }` | `trigger_webhook_job.rb` 122-131 |
| Payload personalizado | Interpolación con `event.type`, `event.execution`, `event.changes`, `event.user_id` | `trigger_webhook_job.rb` 160-175 |
| Timeout | 30 s por defecto (`ZAMMAD_HTTP_WEBHOOK_READ_TIMEOUT`) | `trigger_webhook_job.rb` 83-88 |

Limitaciones verificadas:

1. **No hay `event_id` propio.** El único identificador de entrega es la cabecera `X-Zammad-Delivery`, que corresponde al `job_id` de ActiveJob.
2. **No hay garantía de orden.** Cada evento genera un job independiente que el worker ejecuta en paralelo.
3. **No hay garantía de entrega.** Si se agotan los 5 intentos, el evento se pierde sin registro persistente en Zammad.
4. **Requiere trigger activo y worker activo.** Hoy no hay ninguno de los dos.
5. **No captura cambios de artículo.** Ver §5.

### 3.2 Triggers

**VERIFICADO (código).**

- Activadores permitidos: solo `action` y `time` (`app/models/trigger.rb` 21).
- Los triggers de acción se evalúan en cada transacción de ticket (`app/models/transaction/trigger.rb` 25-55).
- Los triggers de tiempo se evalúan en `Transaction::TimeBasedTrigger` para `reminder_reached`, `escalation`, `escalation_warning` (`app/models/transaction/time_based_trigger.rb` 15-17).
- Orden de evaluación: por `LOWER(name)` (`app/models/transaction/trigger.rb` 45-50).
- Límite de recursión: `ticket_trigger_recursive_max_loop` (por defecto 10) (`app/models/ticket.rb` 508-513).

**Cobertura:** cualquier cambio de ticket o creación de artículo que guarde el ticket.

**Limitación:** el trigger no es un bus de eventos; es una regla con condición. Para capturar todo, habría que crear un trigger sin condiciones, lo que además ejecuta acciones sobre todos los tickets.

### 3.3 API REST

**VERIFICADO (código).**

Rutas relevantes (`config/routes/ticket.rb`):

| Endpoint | Método | Uso | Referencia |
|---|---|---|---|
| `/api/v1/tickets` | GET | Listado paginado | `tickets_controller.rb` 13-20 |
| `/api/v1/tickets/:id` | GET | Detalle | rutas |
| `/api/v1/tickets/search` | GET/POST | Búsqueda con `condition`, `sort_by`, `order_by` | `tickets_controller.rb` 453-455 |
| `/api/v1/ticket_articles/by_ticket/:id` | GET | Artículos del ticket | rutas |
| `/api/v1/ticket_history/:id` | GET | Historial del ticket | `tickets_controller.rb` 317-325 |
| `/api/v1/audit_logs` | GET | Auditoría | `config/routes/audit_log.rb` |

Parámetros de búsqueda (`app/controllers/application_controller/renders_models.rb` 122-165):

- `condition` (selector JSON), `sort_by`, `order_by`, `ids`, `query`, paginación.
- Orden por defecto: `updated_at desc` (`app/models/concerns/can_search.rb` 55-67).
- Límite de paginación: 200 (`renders_models.rb` 123).

Ventajas:

- No depende del worker de Zammad.
- Permite reconciliación por `updated_at`.
- Expone `preferences` del artículo, incluido `delivery_status` (`app/models/ticket/article/assets.rb` 47).

Limitaciones:

- Es sondeo: la latencia depende del intervalo.
- El listado `/tickets` no filtra por fecha; hay que usar `/tickets/search` con `condition`.
- No hay endpoint de "eventos"; el historial se reconstruye.

### 3.4 Historial de tickets

**VERIFICADO (código y datos).**

- Tabla `histories` (`db/schema.rb` 524-550): `history_attribute_id`, `o_id`, `value_from`, `value_to`, `created_by_id`, `created_at`, `sourceable_type`, `sourceable_id`.
- `Ticket#history_get` (`app/models/concerns/has_history.rb` 234-262`).
- Endpoint `/api/v1/ticket_history/:id`.

**VERIFICADO (datos)** en el ticket 7:

```
attribute=state  value_from=new  value_to=open  created_by_id=5
created_at=2026-11-14 04:57:55 UTC
```

Ventajas: es la fuente más fiable para reconstruir transiciones de estado, categoría, propietario y prioridad, con usuario y fecha.

Limitaciones:

- No registra `delivery_status` (no es un atributo historizado del ticket).
- Requiere una consulta por ticket para reconciliar.
- `sourceable_type` permite distinguir trigger, job o usuario, pero solo para `Job`, `Trigger`, `PostmasterFilter`, `AI::Agent` (`has_history.rb` 269-273).

### 3.5 Artículos y transacciones

**VERIFICADO (código).**

- `Ticket` incluye `HasTransactionDispatcher` con `after_create` y `after_update` (`app/models/concerns/has_transaction_dispatcher.rb` 6-10; `app/models/ticket.rb` 50).
- `Ticket::Article` también lo incluye (`app/models/ticket/article.rb` 32).
- El despachador convierte la creación de artículo en una actualización de ticket (`lib/transaction_dispatcher.rb` 143-152).
- **Las actualizaciones de artículo se descartan explícitamente** (`lib/transaction_dispatcher.rb` 148-150: `next if event[:type] == 'update'`).

Esta última línea es la limitación más importante de toda la auditoría. Se detalla en §5.

### 3.6 Jobs existentes

**VERIFICADO (código).**

| Job | Función | Referencia |
|---|---|---|
| `TransactionJob` | Ejecuta backends de transacción de forma asíncrona | `lib/transaction_dispatcher.rb` 68-72 |
| `TriggerWebhookJob` | Envía webhooks | `app/jobs/trigger_webhook_job.rb` |
| `TicketEscalationRebuildJob` | Recalcula escalamiento de tickets abiertos | `app/jobs/ticket_escalation_rebuild_job.rb` 6-16 |
| `TicketArticleCommunicateEmailJob` | Envía correo y registra `delivery_status` | `app/jobs/ticket_article_communicate_email_job.rb` |
| `CommunicateWhatsappJob` | Envía WhatsApp | `app/jobs/communicate_whatsapp_job.rb` |
| `ScheduledWhatsappReminderJob` | Recordatorios de WhatsApp | `app/jobs/scheduled_whatsapp_reminder_job.rb` |

Ninguno expone eventos al exterior. Todos requieren worker.

### 3.7 Notificaciones push (GraphQL / websocket)

**VERIFICADO (código).** Existe un servidor websocket (`config/routes/websocket_server.rb`) y suscripciones GraphQL para la interfaz.

**No recomendado** como bus de eventos: no tiene garantía de entrega, no está diseñado para consumidores servidor-a-servidor y no persiste eventos.

---

## 4. Cobertura de los trece eventos requeridos

Leyenda de cobertura:

- **SÍ**: el mecanismo lo entrega de forma directa.
- **PARCIAL**: se puede derivar, pero no llega como evento propio.
- **NO**: no lo entrega.

| # | Evento | Webhook + trigger | API REST | Historial | Transacción interna |
|---:|---|---|---|---|---|
| 1 | Creación de ticket | SÍ (`type=create`) | SÍ | SÍ | SÍ |
| 2 | Cambio de canal | NO directo (PARCIAL: se deriva del artículo) | PARCIAL | NO | PARCIAL |
| 3 | Creación de artículo | SÍ (simulada como update de ticket) | SÍ | PARCIAL | SÍ |
| 4 | Respuesta pública de agente | SÍ (artículo en payload) | SÍ | PARCIAL | SÍ |
| 5 | Confirmación de envío | **NO** | SÍ (lectura de `preferences`) | NO | **NO** |
| 6 | Fallo de envío | **NO** | SÍ (lectura de `preferences`) | NO | **NO** |
| 7 | Cambio de categoría | SÍ (update de ticket) | SÍ | SÍ | SÍ |
| 8 | Cambio de subcategoría | SÍ (update de ticket) | SÍ | SÍ | SÍ |
| 9 | Cambio de estado | SÍ | SÍ | SÍ | SÍ |
| 10 | Cierre | SÍ | SÍ | SÍ | SÍ |
| 11 | Reapertura | SÍ | SÍ | SÍ | SÍ |
| 12 | Reasignación | SÍ | SÍ | SÍ | SÍ |
| 13 | Cambio de prioridad | SÍ | SÍ | SÍ | SÍ |

**Conclusión de cobertura:** ningún mecanismo por sí solo cubre los trece eventos. Los eventos 5 y 6 (confirmación y fallo de envío) **solo** pueden obtenerse leyendo el artículo, porque Zammad descarta las actualizaciones de artículo antes de despachar transacciones.

---

## 5. Limitación crítica: la confirmación de envío no genera evento

**VERIFICADO (código).**

Cadena de hechos:

1. El job de correo actualiza `record.preferences['delivery_status']` y guarda el artículo (`app/jobs/ticket_article_communicate_email_job.rb` 103-108).
2. Ese guardado dispara `after_commit :ticket_touch` (`app/models/ticket/article.rb` 49, 472-474).
3. `ticket.touch` solo actualiza `updated_at`.
4. `updated_at` está en `transaction_ignore_changes_attributes` (`app/models/ticket.rb` 52).
5. El despachador descarta cualquier `update` de `Ticket::Article` (`lib/transaction_dispatcher.rb` 148-150).

Resultado: **no se genera transacción, no se evalúan triggers y no se envía webhook.** La confirmación de envío queda solo en el registro del artículo.

**Consecuencia para el motor propio:** la primera respuesta confirmada exige leer `ticket_articles.preferences` por API o por consulta directa, o instrumentar el artículo (lo que sería una modificación no autorizada).

---

## 6. Evidencia empírica del problema de primera respuesta

**VERIFICADO (datos).** En el ticket 7:

| Artículo | Tipo | Emisor | `delivery_status` | `delivery_status_date` |
|---:|---|---|---|---|
| 3 | email | Agent | `success` | 2026-11-14 14:32:10 UTC |
| 4 | email | Agent | **ausente** | — |

Y las marcas del ticket:

```
created_at         = 2026-11-14 04:44:13.945 UTC
first_response_at  = 2026-11-14 04:57:54.943 UTC
article 3 creado   = 2026-11-14 04:57:54.943 UTC
diferencia         = 0.000 s
```

Interpretación:

1. `first_response_at` es **exactamente** la hora de creación del artículo, no la de envío.
2. El envío se confirmó **9 h 34 min después** de la marca de primera respuesta.
3. El artículo 4 es una respuesta pública de agente **sin estado de envío**, y aun así existe.

Esto confirma el riesgo señalado en 5G.4.1: el motor nativo puede registrar una primera respuesta que nunca llegó al cliente.

---

## 7. Latencia, garantías y orden por mecanismo

| Criterio | Webhook + trigger | API REST (sondeo) |
|---|---|---|
| Latencia | Segundos (depende del worker) | Intervalo de sondeo |
| Garantía de entrega | No (5 intentos y se descarta) | Alta (se reintenta en el siguiente ciclo) |
| Reintentos | 5, con espera creciente | Infinitos por diseño |
| Identificador único | `X-Zammad-Delivery` (job_id) | `id` del registro + `updated_at` |
| Duplicados | Posibles (reintentos, múltiples triggers) | Posibles (solapamiento de ventanas) |
| Orden | No garantizado | Reconstruible por `created_at` / `id` |
| Autenticación | HMAC-SHA1, basic, bearer | Token de API |
| Dependencia de worker | **Sí** | **No** |
| Cobertura de envío | **No** | **Sí** |

---

## 8. Auditoría y persistencia

### 8.1 Estructura real de `audit_logs`

**VERIFICADO (código).** `db/schema.rb` 160-175:

| Columna | Tipo | Uso |
|---|---|---|
| `user_id` | integer | Usuario que ejecutó el cambio |
| `user_fullname` | string(255) | Nombre desnormalizado |
| `action_type` | string(100) | `create`, `update`, `destroy` |
| `auditable_type` / `auditable_id` | string / integer | Objeto afectado |
| `auditable_name` | string(255) | Nombre del objeto |
| `value_from` | jsonb | Estado anterior |
| `value_to` | jsonb | Estado nuevo |
| `source_ip` | string(50) | Origen, si aplica |
| `preferences` | jsonb | Metadatos, incluido `changed_attributes` |
| `created_at` / `updated_at` | timestamp(3) | Fecha |

### 8.2 Qué registra `HasAuditLogs`

**VERIFICADO (código).** `app/models/concerns/has_audit_logs.rb`:

| Acción | Qué guarda | Referencia |
|---|---|---|
| Crear | `value_from = {}`, `value_to` = snapshot completo | 42-46 |
| Actualizar | `changed_attributes` + `value_from`/`value_to` por atributo | 57-71 |
| Destruir | `value_from` = snapshot, `value_to = {}` | 82-86 |
| Atributos ignorados | `id`, `created_at`, `updated_at`, `created_by_id`, `updated_by_id`, `note` | 6 |
| Usuario | `UserInfo.current_user_id` | 150 |
| Supresión | No registra si `AuditLog.suspended?` | 140 |
| Requisito | Solo si `system_init_done` | 141 |

### 8.3 Evidencia empírica

**VERIFICADO (datos).**

| Registro | Objeto | Acción | Usuario | Observación |
|---:|---|---|---|---|
| 29 | Calendar 2 | create | **`nil`** | `value_from={}`, `value_to` con `name`, `timezone`, `default`, `business_hours`, `ical_url` |
| 1 | User 5 | update | `1` / `-` | `changed_attributes=["password","roles"]`; valores enmascarados `**********` |

Conclusiones:

1. **La auditoría nativa sí guarda valor anterior y nuevo.**
2. **Sí guarda el usuario cuando existe contexto.**
3. **Los cambios automáticos o de consola quedan sin usuario** (`user_id=nil`). Esto afecta a cualquier cambio hecho por script, migración o job sin contexto.
4. Los valores sensibles se enmascaran.

### 8.4 Auditoría de `Sla`

**VERIFICADO (código).** `Sla` no define `audit_log_attributes_tracked` ni `audit_log_attributes_ignored` (ambos vacíos). Por tanto se auditan todas las columnas no ignoradas globalmente:

```
calendar_id, name, first_response_time, response_time, update_time,
solution_time, condition, created_by_id, updated_by_id
```

**Limitación:** la auditoría no dice **por qué** cambió un valor. El motivo debe registrarse en la capa propia.

**Limitación adicional:** los tickets **no** usan `audit_logs`; usan `histories`. No hay auditoría de `delivery_status`.

### 8.5 Orden de `as_batches` y `reorder` en la selección de SLA

**VERIFICADO (código).**

`Sla.for_ticket` (`app/models/sla.rb` 30-40) usa:

```ruby
all.reorder(:name, :created_at).as_batches(size: 10)
```

`as_batches` (`config/initializers/active_record_as_batches.rb` 23-58):

```ruby
def get_records(query)
  query.offset(@offset).limit(@size).all
end
```

`as_batches` **no reordena**: solo añade `OFFSET` y `LIMIT` a la relación existente. El `ORDER BY name, created_at` se conserva en cada lote.

Conclusión: **la precedencia alfabética funciona como se diseñó en 5G.3.**

| Comportamiento | Resultado |
|---|---|
| Gana la primera política con condición que coincide | Confirmado |
| Las políticas sin condición se guardan como `fallback` | Confirmado |
| Si hay varias sin condición, gana la **última** en orden alfabético | Confirmado |
| El orden se mantiene entre lotes | Confirmado |

**Riesgo residual:** la paginación por `OFFSET` es sensible a cambios concurrentes en la tabla `slas`. Durante la evaluación de un ticket, si se crea o elimina una política, el orden podría variar. Es improbable en operación normal y no afecta al diseño del BFF, que no usa `Sla.for_ticket`.

### 8.6 Implicación para el motor propio

| Dato | Disponible | Fuente |
|---|---|---|
| Cambios de política con anterior/nuevo | Sí | `audit_logs` |
| Usuario del cambio de política | Sí, si hay contexto | `audit_logs.user_id` |
| Motivo del cambio | **No** | Debe añadirse en el BFF |
| Cambios de ticket | Sí | `histories` |
| Estado de envío | **No auditado** | Solo `ticket_articles.preferences` |
| Precedencia de políticas | No aplica | El BFF usa coincidencia exacta |

---

## 9. Riesgos detectados

| Riesgo | Nivel | Evidencia |
|---|---|---|
| Webhook no captura confirmación de envío | **Alto** | `lib/transaction_dispatcher.rb` 148-150 |
| Webhook depende de worker y trigger activos | Alto | Estado actual: 0 webhooks, 0 triggers activos |
| Pérdida de eventos tras 5 intentos | Alto | `trigger_webhook_job.rb` 7-10 |
| Sin orden garantizado | Medio | Jobs independientes |
| Recalculo de escalamiento genera updates espurios | Medio | `app/models/ticket/escalation.rb` 7, 29-46 |
| Cambios automáticos sin usuario en auditoría | Medio | `audit_logs` id 29: `user_id=nil` |
| Sondeo con ventana mal elegida pierde cambios | Medio | Diseño del BFF |

---

## 10. Conclusiones

1. **Ningún mecanismo nativo cubre los trece eventos.**
2. **Los webhooks son útiles para eventos de ticket, no para eventos de entrega.**
3. **La API REST es el único mecanismo que permite verificar la entrega** sin modificar Zammad.
4. **La combinación recomendada es híbrida:** webhook para baja latencia y sondeo para corrección y para entrega.
5. **El historial es la mejor fuente de verdad para transiciones de estado y clasificación.**
6. **Ninguna de estas opciones está activa hoy.**

La estrategia concreta se detalla en `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md`.

---

## 11. Confirmación

No se creó ningún webhook, trigger, SLA, calendario, atributo ni tabla. No se inició ningún worker. No se envió ningún mensaje. Solo se ejecutaron lecturas de código y consultas de solo lectura.
