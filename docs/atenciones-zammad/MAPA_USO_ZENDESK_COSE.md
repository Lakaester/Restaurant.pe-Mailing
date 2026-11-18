# MAPA DE USO ZENDESK → COSE

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con los IDs y tipos de campos observados en Zendesk.
**Modo:** solo lectura.

---

## 1. Principio

> **La conversación pertenece al motor de tickets; la operación pertenece a COSE.**

Hoy la conversación está en Zendesk. En la arquitectura objetivo estará en Zammad. COSE conserva la operación: dominio, categoría, calificación, auditoría, QyD, LocalBI y TicketBI.

---

## 2. Mapa funcional

| Funcionalidad | Zendesk | COSE: módulo/endpoint | ¿COSE la usa? | Equivalencia Zammad | ¿Dónde debe vivir? | Prioridad |
|---|---|---|---|---|---|---|
| Bandeja de tickets | Search API `type:ticket status<closed` | `ZendeskInboxService`, `GET /api/zendesk/inbox` | Sí | `/tickets/search` | Zammad (datos) + BFF (contrato) | P0 |
| Detalle de ticket | `GET /tickets/{id}.json` | `AtencionCompletaService`, `GET /api/zendesk/completa/:id` | Sí | `GET /tickets/:id` | Zammad | P0 |
| Comentarios | `GET /tickets/{id}/comments.json` | `ZendeskTicketService` | Sí | `GET /ticket_articles/by_ticket/:id` | Zammad | P0 |
| Respuesta pública | `PUT /tickets/{id}.json` con `comment.public=true` | `ZendeskActionsService.reply`, `reply-resolve` | Sí | `POST /ticket_articles` (email) o `PUT /tickets/:id` + article | Zammad | P0 |
| Nota interna | `comment.public=false` | `internal-note` | Sí | `POST /ticket_articles` (`note`, `internal=true`) | Zammad | P0 |
| Cambio de estado | `PUT /tickets/{id}.json {status}` | `POST /status` | Sí | `PUT /tickets/:id {state_id}` | Zammad | P0 |
| Asignación | `PUT /tickets/{id}.json {assignee_id}` | `POST /assign` | Sí | `PUT /tickets/:id {owner_id}` | Zammad | P0 |
| Cambio de grupo | No implementado en UI | — | No | `PUT /tickets/:id {group_id}` | Zammad + BFF | P1 |
| Prioridad | `priority` | Se muestra; no se edita en UI | Parcial | `PUT /tickets/:id {priority_id}` | Zammad | P1 |
| Categoría/subcategoría | Custom field `38744095836311` (solo subcategoría) | `categorize`, `CategoryModal` | Sí | `categoria_subcategoria` (path completo) | Zammad (dato) + COSE (regla) | P1 |
| Dominio | Custom field `40769061038615` | `updateDomain`, `VincularDominioModal` | Sí | `dominio` | Zammad (dato) + COSE (normalización) | P1 |
| País | Custom field `1500005211481` | Se lee | Sí | Atributo personalizado (si se requiere) | Zammad/COSE | P2 |
| Adjuntos | `comment.attachments`, `uploads.json` | `AttachmentRenderer`, base64 | Sí | `attachments` / `UploadCache` | Zammad | P1 |
| Historial de conversación | Comentarios | `ConversationPanel` | Sí | Artículos | Zammad | P0 |
| Historial de cliente | `GET /tickets?requester_id=` | `ZendeskCustomerService`, `/history/:id` | Sí | `/tickets/search` | Zammad/BFF | P1 |
| Relación padre/hijo | `via.source`, `followup_ids` | `ticketPadreId`, `followupIds` | Sí (QyD) | `message_id`/`in_reply_to` | Zammad | P1 |
| Búsqueda | Search API | `searchTickets` | Sí | `/tickets/search` | Zammad | P1 |
| Filtros | Query syntax | Filtros locales | Sí | `condition` | Zammad | P1 |
| Vistas de Zendesk | Views | No usadas | No | Overviews | Zammad | P2 |
| SLA operativo | No verificado | No aplicado en Atenciones | No | `Sla` | Zammad (decisión) | P0 |
| SLA analítico | Datos de tickets | `/dashboard/sla` | Sí | Datos de Zammad/BI | COSE BI | P1 |
| Reportes de volumen | Datos de tickets | `/dashboard/zendesk` | Sí | Datos de Zammad/BI | COSE BI | P1 |
| CSAT | No verificado | No implementado | No | No nativo (desarrollo) | COSE/Zammad (decisión) | P1 |
| QyD | Categoría + datos del ticket | `crearCasoDesdeCategoria` | Sí | No aplica | COSE | P1 |
| LocalBI | No | `PanelOperativo`, `localbiService` | Sí | No aplica | COSE | — |
| TicketBI | No | `ticketbiService` | Sí | No aplica | COSE | — |
| Auditoría operativa | No | `atencion_auditoria` | Sí | No aplica | COSE | P1 |
| Cliente/organización | `requester_id`, `organization_id` | `CustomerMemory`, `contacto_dominio` | Parcial | `User`/`Organization` | Zammad + COSE | P1 |
| Canales WhatsApp/Meta | No confirmado | `MetaService` | Parcial | Driver WhatsApp | COSE/Zammad (decisión) | P1 |

### 2.1 Campos de Zendesk observados y su equivalente

Evidencia: captura `Objetos y reglas → Tickets → Campos` del 14/11/2026. Los IDs se conservan para el mapeo técnico.

| Campo Zendesk | ID | Tipo | ¿COSE lo usa? | Equivalente Zammad | Observación |
|---|---|---:|---|---|---|
| Agente asignado | 360055496673 | Desplegable | Sí (indirecto) | `owner_id` | — |
| Asunto | 360055496553 | Texto | Sí | `title` | — |
| Categoría de Soporte | 38744095836311 | Desplegable | Sí (solo subcategoría) | `categoria_subcategoria` (`tree_select`) | Zendesk no guarda la categoría padre; Zammad guarda el path completo |
| Descripción | 360055496573 | Multilíneas | Sí | `Ticket::Article` (primer artículo) | Zammad no tiene “descripción” de ticket separada |
| Dominio | 40769061038615 | Texto | Sí | `dominio` | Atributo personalizado |
| Grupo | 360055496653 | Desplegable | Sí (indirecto) | `group_id` | — |
| Grupo de canales | 40450627571351 | Desplegable | No | Sin equivalente directo | Evaluar si se requiere |
| ID de correo electrónico de varios destinatarios | 41121515402903 | Texto | No | Sin equivalente directo | Relacionado con “varios destinatarios” desactivado |
| Nivel de resolución | 40450627572631 | Desplegable | No | Sin atributo actual | Crear solo si el negocio lo exige |
| PAÍS | 1500005211481 | Desplegable | Sí | Sin atributo actual | Crear atributo o mantener en COSE |
| Ticket status | 9191755491095 | Desplegable | Sí | `state_id` | — |
| Tipo de resolución | 36134434290711 | Desplegable | No | Sin atributo actual | Crear solo si el negocio lo exige |

**Diferencia clave:** COSE usa hoy `Dominio`, `PAÍS` y `Categoría de Soporte`; los demás campos existen en Zendesk pero no se consumen en el flujo de Atenciones. No se deben crear atributos en Zammad “por si acaso”.

**Categoría/subcategoría:** Zendesk usa un campo desplegable (`38744095836311`) y COSE envía solo la subcategoría. Zammad usa un `tree_select` (`categoria_subcategoria`) que almacena `CATEGORÍA::subcategoría`. El catálogo verificado es **13 categorías / 65 subcategorías**, no 15/80.

**Dirección de correo:** `clientes@restaurant.pe` es la única visible en la captura. El buzón exclusivo de Soporte Especializado no se observó y sigue pendiente.

---

## 3. Qué es conversación y qué es operación

| Dato | Origen actual | Origen objetivo |
|---|---|---|
| Ticket, asunto, descripción | Zendesk | Zammad |
| Estado, prioridad, tipo | Zendesk | Zammad |
| Comentarios, HTML, adjuntos | Zendesk | Zammad |
| Solicitante, email, teléfono | Zendesk | Zammad |
| Dominio y país explícitos | Custom fields Zendesk | Atributos Zammad |
| Relación padre/hijo | Zendesk (`via`, `followup_ids`) | Zammad (`message_id`/hilo) |
| Dominio identificado en la atención | COSE (snapshot) | COSE |
| Categoría/subcategoría operativa | COSE + subcategoría en Zendesk | Zammad (path completo) + COSE |
| Calificación 1–5 | COSE | COSE |
| Asesor operativo (auditoría) | COSE | COSE |
| Auditoría de acciones | COSE | COSE |
| Unidad de negocio, local, NPS | LocalBI | LocalBI |
| Catálogos de Desarrollo | TicketBI | TicketBI |

---

## 4. Dependencias directas de Zendesk en COSE

| Dependencia | Archivo | Riesgo |
|---|---|---|
| Cliente HTTP Zendesk | `ZendeskClient.ts` | Reemplazar por BFF |
| IDs de custom fields | `40769061038615`, `1500005211481`, `38744095836311` | No existen en Zammad; mapear a atributos |
| `via.channel` / `via.source` | `ZendeskTicketService`, `AtencionCompletaService` | Zammad no tiene `via`; derivar de artículos |
| `tags[0]` como subcategoría | `WorkspaceArea.handleResolve` | No funciona en Zammad; usar `categoria_subcategoria` |
| `content_url` de adjuntos | `AttachmentRenderer` | Zammad requiere endpoint autenticado |
| `assignee_id` / `requester_id` | Servicios y DTOs | Mapear a `owner_id` / `customer_id` |
| `status` de Zendesk | UI y servicios | Mapear a estados Zammad |
| `searchTickets` query syntax | `ZendeskInboxService` | Reescribir con DSL de Zammad |
| Uploads por token | `ZendeskActionsService` | Cambiar a `attachments`/`form_id` |

---

## 5. Funcionalidades de COSE que no dependen de Zendesk

Estas deben permanecer en COSE y no migrarse:

- Panel operativo (dominio, clasificación, calificación, auditoría).
- Quejas y Devoluciones.
- LocalBI (unidad, locales, actividad, NPS).
- TicketBI (tickets a Desarrollo).
- Motor de notificaciones propio.
- Motor de automatización propio.
- Dashboards BI sobre `v_unificado_norm`.
- Autenticación y permisos de COSE.

### 5.1 Trazabilidad de fuentes

| Fuente | Tipo | Fecha | Uso |
|---|---|---|---|
| Código de COSE | Evidencia técnica | 14/11/2026 | Endpoints, campos usados, flujos |
| Captura `Tickets → Campos` | Evidencia visual | 14/11/2026 | 12 campos, IDs y tipos |
| Captura `Tickets → Formularios` | Evidencia visual | 14/11/2026 | 1 formulario con 9 campos |
| Captura `Canales → Correo` | Evidencia visual | 14/11/2026 | `clientes@restaurant.pe` |
| Documentos previos | Evidencia documental | 13–14/11/2026 | Arquitectura y mapeo |

---

## 6. Conclusión

El mapa confirma que COSE usa Zendesk para **conversación y estado del ticket**, y mantiene en su propia base la **operación**. La migración a Zammad debe:

1. Mover la conversación y el ticket a Zammad.
2. Mantener la operación en COSE.
3. Adaptar los contratos con un BFF.
4. Resolver las dependencias de custom fields, `via`, `tags[0]` y adjuntos.
5. Asegurar que el BI siga recibiendo datos.

**Aportación de la evidencia administrativa:** ya se conocen los 12 campos de Zendesk con ID y tipo. COSE solo consume tres campos personalizados (`Categoría de Soporte`, `Dominio`, `PAÍS`); los demás no deben replicarse sin decisión. La categoría sigue siendo la diferencia más delicada: Zendesk guarda solo la subcategoría y Zammad guarda el path completo de 13/65.
