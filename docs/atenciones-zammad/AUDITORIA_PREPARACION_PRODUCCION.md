# Auditoría de preparación para producción — MAILING / C.O.S.E.

**Proyecto:** MAILING (C.O.S.E.) sobre Zammad 7.2.3
**Fecha de la auditoría:** 14/11/2026
**Alcance:** auditoría de solo lectura. No se modificó configuración, canales, OAuth ni datos.

> Etiquetas usadas en este documento:
> **[HECHO]** verificado en el sistema · **[DECISIÓN]** aprobada por el responsable del proyecto · **[PROPUESTA]** pendiente de aprobación · **[RIESGO]** abierto.

---

## 1. Resumen ejecutivo

**[HECHO]** Zammad está validado como motor de tickets y correo para C.O.S.E.:

- Recepción de correo real desde Gmail.
- Creación del ticket en el grupo correcto.
- Respuesta manual con firma institucional por el canal Google.
- Seguimiento del cliente incorporado al mismo ticket.
- Sin respuestas automáticas.
- Atributos de clasificación operativos.
- Tema visual C.O.S.E. aplicado.

**[HECHO]** El sistema **no está listo para producción** sin cerrar los puntos de la sección 8.

---

## 2. Pruebas funcionales realizadas

| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| 1 | Recepción de correo nuevo | **OK** | Ticket 91007 creado en Soporte Especializado |
| 2 | Respuesta manual | **OK** | Artículo 3 enviado por canal Google, estado `success` |
| 3 | Seguimiento del cliente | **OK** | Artículo 5 añadido al ticket 91007, sin ticket nuevo |
| 4 | Atributos de clasificación | **OK** | `dominio` y `categoria_subcategoria` persisten y filtran |
| 5 | Vistas con columnas nuevas | **OK** | 6 vistas con 10 columnas |
| 6 | Tema C.O.S.E. | **OK** | CSS servido en las tres interfaces |
| 7 | Sin respuestas automáticas | **OK** | 0 triggers activos con `notification.email` |

---

## 3. Arquitectura de recepción (verificada)

**[HECHO]**

```
Gmail (vcastagnino@restaurant.pe)
  → IMAP + OAuth (keep_on_server=true)
  → Canal 4 (Google::Account), grupo 3
  → Channel::EmailParser#_process
  → Channel::Filter::IdentifyGroup  (usa channel.group_id)
  → Ticket + artículo tipo email, remitente Customer
  → marca el correo como leído (\Seen), no lo borra
```

| Aspecto | Comportamiento |
|---|---|
| Grupo del ticket | `channel.group_id` = 3 (Soporte Especializado) |
| Propietario | Sin asignar (`ticket_auto_assignment = false`) |
| Seguimientos | Por número de ticket en asunto/referencias |
| Duplicados | `Message-ID` + `already_imported?` |
| Mensaje original | `save_as_raw` + adjuntos en base de datos |
| `keep_on_server=true` | Solo no leídos; marca como leído; **no borra** |

---

## 4. Arquitectura de envío (verificada)

**[HECHO]**

```
Artículo (Agent, email)
  → after_create_commit
  → TicketArticleCommunicateEmailJob.perform_later  (trabajo en segundo plano)
  → channel.deliver (dirección del grupo → canal Google)
  → SMTP Gmail con OAuth
```

| Aspecto | Comportamiento |
|---|---|
| Remitente | Dirección del **grupo** (`vcastagnino@restaurant.pe`) |
| Nombre visible | `C.O.S.E Soporte` |
| Canal | 4 (Google::Account) |
| Hilo | `in_reply_to` + `references` |
| Asunto | `RE: Prueba [Ticket#91007]` |
| Firma | `C.O.S.E. \| Restaurant.pe` |
| Sin dirección en el grupo | Error: «This group has no email address configured» |

**[HECHO]** El envío **depende de un trabajo en segundo plano**. Sin worker, el correo queda en cola y no sale.

---

## 5. Cola de trabajos (clasificada)

**[HECHO]** Total 120 · fallidos 0 · bloqueados 0.

| Tipo | Cantidad | Puede enviar correo |
|---|---|---|
| `UserDeviceLogJob` | 54 | No |
| `TaskbarUpdateRelatedTasksJob` | 29 | No |
| `TransactionJob` | 13 | No |
| `CollectionUpdateJob` | 9 | No |
| `AvatarCreateJob` | 5 | No |
| `TicketUserTicketCounterJob` | 4 | No |
| `TaskbarUpdateTriggerSubscriptionsJob` | 2 | No |
| `ChecksKbClientVisibilityJob` | 1 | No |
| `TicketEscalationRebuildJob` | 1 | No |
| `NotificationMailerJob` | 1 | **Sí** (verificación de registro; fallaría por falta de MTA) |

**[HECHO]** El trabajo 104 (`TicketArticleCommunicateEmailJob`, artículo 4) fue **descartado** por decisión del responsable. El artículo 4 se conserva intacto.

---

## 6. Configuración actual

**[HECHO]**

| Parámetro | Valor |
|---|---|
| `fqdn` | `localhost:3000` |
| `http_type` | `http` |
| `product_name` | `C.O.S.E` |
| `organization` | `Restaurant.pe` |
| `locale_default` | `es-es` |
| `timezone_default` | `America/Lima` |
| `notification_sender` | `"C.O.S.E" <noreply@localhost>` |
| `es_url` (Elasticsearch) | vacío (búsqueda por base de datos) |
| Canales | 4 (1 activo Google, 1 activo notificación) |
| Grupos | 3 (Soporte Especializado con dirección y firma) |
| Triggers | 3, todos inactivos |
| Worker | **Detenido** |

---

## 7. Superficie de API para COSE

**[HECHO]**

| Recurso | Endpoint |
|---|---|
| REST tickets | `/api/v1/tickets`, `/tickets/search`, `/tickets/:id`, `/tickets/:id/articles` |
| REST selectores | `/api/v1/tickets/selector` |
| REST usuarios/grupos | `/api/v1/users`, `/organizations`, `/groups` |
| REST vistas | `/api/v1/overviews` |
| GraphQL | `/graphql` |
| WebSocket | `/ws` (6042) |

| Dato | Valor |
|---|---|
| `api_token_access` | `true` |
| `api_password_access` | `true` |
| CORS | **Deshabilitado** (`config/initializers/cors.rb` comentado) |
| Rate limiting de API | **No** (solo formularios y endpoints públicos) |

---

## 8. Limitaciones detectadas

**[RIESGO]** Los puntos siguientes impiden considerar el sistema listo para producción:

1. `fqdn = localhost:3000` — enlaces y OAuth inválidos fuera del equipo.
2. `http_type = http` — sin TLS.
3. Recepción dependiente del flag `\Seen`.
4. Notificaciones sin MTA.
5. API sin rate limiting propio.
6. CORS deshabilitado.
7. Elasticsearch desactivado.
8. Backups manuales, sin prueba de restauración.
9. Procesos sin supervisor (caen al reiniciar WSL).
10. Respuesta automática por correo > 10 MB (`postmaster_response`).

---

## 9. Conclusión

**[HECHO]** La funcionalidad está probada de extremo a extremo.

**[DECISIÓN]** El siguiente trabajo se concentra en integración, confiabilidad y operación, no en desarrollo desde cero.
