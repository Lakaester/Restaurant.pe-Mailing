# CRITERIOS DE ACEPTACIÓN — FASE 0 — MOTOR SLA EMAIL — 5G.4.5

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.5
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Naturaleza:** definición de pruebas. **Ninguna prueba de escritura fue ejecutada.**
**Regla:** la fase 1 no se autoriza si falla una prueba bloqueante.

---

## 1. Propósito de la fase 0

Demostrar, **antes de construir el motor**, que:

1. la integración puede leer todo lo necesario;
2. **no puede escribir** en Zammad;
3. las marcas de tiempo en las que se basa la métrica existen y son fiables;
4. la matriz es reproducible;
5. el diseño sobrevive a duplicados, desorden y caídas.

**Fase 0 no crea el motor.** Crea evidencia.

---

## 2. Reglas de ejecución

| Regla | Detalle |
|---|---|
| Autorización | Cada prueba de escritura requiere autorización explícita |
| Usuarios | La prueba F0-02 requiere crear **un** usuario técnico; prohibido en esta etapa |
| Datos | Se usa un buzón de prueba controlado, nunca un cliente real |
| Evidencia | Cada prueba deja un archivo `F0-XX_<nombre>.json` o `.md` |
| Reversión | Toda escritura de prueba se revierte o se documenta |
| Registro | Se anota `antes` y `después` de cada contador |

### 2.1 Contadores de referencia (línea base actual)

Verificados al cierre de 5G.4.4 y reutilizables como línea base:

| Contador | Valor |
|---|---:|
| `sla_policies` (nativas) | 0 |
| `calendars` | 2 |
| `webhooks` | 0 |
| `triggers` | 3 |
| `triggers_active` | 0 |
| `tickets` | 2 |
| `articles` | 5 |
| `audit_logs` | 29 |
| `histories` | 44 |
| `users` | 6 |
| `knowledge_bases` | 0 |
| `mentions` | 0 |
| `jobs_escalation` | 0 |
| `schedulers` | 30 |

---

## 3. Bloque A — Línea base y no modificación

### F0-01 · Línea base íntegra

| Campo | Detalle |
|---|---|
| Objetivo | Fijar el estado exacto antes de cualquier prueba |
| Procedimiento | Ejecutar el inventario de contadores y guardar el resultado |
| Resultado esperado | Coincide con §2.1 |
| Evidencia | `F0-01_baseline.json` |
| Bloqueante | **Sí** |
| Estado | **Ejecutada (lectura)** |

### F0-02 · Credencial de solo lectura

| Campo | Detalle |
|---|---|
| Objetivo | Probar que la credencial de la integración no puede escribir |
| Precondición | Autorización para crear un usuario técnico con `groups_users.access = 'read'` en el grupo de soporte, y un token de API |
| Procedimiento | 1) Crear usuario y token. 2) `GET /api/v1/tickets` con el token. 3) Verificar que devuelve tickets del grupo. |
| Resultado esperado | Lectura correcta; `access = 'read'`; sin permiso `admin` |
| Evidencia | `F0-02_credential.json` (sin incluir el token) |
| Bloqueante | **Sí** |
| Estado | **Pendiente** (requiere autorización) |

**Fundamento verificado en código:** `HasGroups#group_access_uncached?` acepta `read`; `TicketPolicy#update?` exige `change`; `Ticket::ArticlePolicy#create?` exige `follow_up?` → `update?`.

### F0-03 · Prueba negativa de escritura

| Campo | Detalle |
|---|---|
| Objetivo | Demostrar que cada intento de escritura es rechazado |
| Precondición | F0-02 aprobada |
| Procedimiento | Ejecutar con el token técnico y registrar el código HTTP |

| # | Llamada | Esperado |
|---:|---|---|
| 1 | `PATCH /api/v1/tickets/{id}` con `{title:"x"}` | **403** |
| 2 | `POST /api/v1/ticket_articles` con `{ticket_id, body, type:"note"}` | **403** |
| 3 | `POST /api/v1/tickets` | **403** |
| 4 | `DELETE /api/v1/tickets/{id}` | **403** |
| 5 | `PUT /api/v1/tickets/{id}` | **403** |
| 6 | `POST /api/v1/users` | **403** |
| 7 | `PUT /api/v1/users/{id}` | **403** |
| 8 | `PUT /api/v1/settings/{key}` | **403** |
| 9 | `POST /api/v1/triggers` | **403** |
| 10 | `POST /api/v1/webhooks` | **403** |
| 11 | `POST /api/v1/slas` | **403** |

| Campo | Detalle |
|---|---|
| Resultado esperado | **11 de 11** con 403 (o 401). Ningún 2xx |
| Evidencia | `F0-03_negative_writes.json` con código y cuerpo de cada respuesta |
| Bloqueante | **Sí** — un solo 2xx invalida el diseño de solo lectura |
| Estado | **Pendiente** |

### F0-04 · Inmutabilidad de la configuración

| Campo | Detalle |
|---|---|
| Objetivo | Probar que no se puede alterar configuración |
| Procedimiento | `GET /api/v1/settings`, `GET /api/v1/calendars`, `GET /api/v1/slas` con el token técnico |
| Resultado esperado | **403** en los tres (sin permiso `admin`) |
| Evidencia | `F0-04_admin_endpoints.json` |
| Bloqueante | Sí |
| Estado | **Pendiente** |

### F0-05 · Superficie de lectura suficiente

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar que la API expone todo lo que el motor necesita |
| Procedimiento | Sobre un ticket con artículo de correo, leer y registrar presencia de los campos |

| Campo requerido | Origen | Presente |
|---|---|---|
| `ticket.created_at` | ticket | ☐ |
| `ticket.close_at` | ticket | ☐ |
| `ticket.last_close_at` | ticket | ☐ |
| `ticket.state_id` | ticket | ☐ |
| `article.sender` | artículo | ☐ |
| `article.type` | artículo | ☐ |
| `article.internal` | artículo | ☐ |
| `article.preferences.delivery_status` | artículo | ☐ |
| `article.preferences.delivery_status_date` | artículo | ☐ |
| `article.preferences.delivery_retry` | artículo | ☐ |
| `history.attribute` / `value_to` / `created_at` | historial | ☐ |

| Campo | Detalle |
|---|---|
| Resultado esperado | 11 de 11 presentes |
| Evidencia | `F0-05_api_surface.json` |
| Bloqueante | **Sí** |
| Estado | **Parcial**: los campos están verificados en código (`article/assets.rb` 47, `ticket.rb` 80-87); falta la comprobación empírica |

### F0-15 · Ninguna escritura durante el sondeo

| Campo | Detalle |
|---|---|
| Objetivo | Probar que un ciclo completo de lectura no modifica nada |
| Procedimiento | 1) Registrar `max(tickets.updated_at)`, `count(audit_logs)`, `count(histories)`, `count(articles)`. 2) Ejecutar 20 ciclos de sondeo. 3) Volver a medir. |
| Resultado esperado | Los cuatro valores **idénticos** |
| Evidencia | `F0-15_no_writes.json` |
| Bloqueante | **Sí** |
| Estado | **Pendiente** |

---

## 4. Bloque B — Detección de envío y cierre

### F0-06 · La confirmación eleva `updated_at`

| Campo | Detalle |
|---|---|
| Objetivo | Probar la base del sondeo: que el `touch` del artículo se propaga al ticket |
| Precondición | Buzón de prueba; autorización para enviar un correo |
| Procedimiento | 1) Crear ticket de prueba. 2) Registrar `ticket.updated_at`. 3) Enviar respuesta pública de agente. 4) Esperar `delivery_status = success`. 5) Volver a leer `ticket.updated_at`. |
| Resultado esperado | `updated_at` **posterior** al envío; `delivery_status_date` poblado; diferencia entre ambos < 5 s |
| Evidencia | `F0-06_touch.json` con las tres marcas |
| Bloqueante | **Sí** — si falla, el sondeo por `updated_at` no sirve y hay que rediseñar la detección |
| Estado | **Pendiente** |
| Fundamento | `ticket/article.rb` 49 (`after_commit :ticket_touch`) y 472-474 |

### F0-07 · Semántica de `close_at`

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar que `close_at` es el primer cierre y no se reescribe |
| Procedimiento | 1) Cerrar ticket de prueba; registrar `close_at` y `last_close_at`. 2) Reabrir. 3) Cerrar de nuevo. 4) Comparar. |
| Resultado esperado | `close_at` **idéntico** tras reabrir y cerrar; `last_close_at` **distinto** |
| Evidencia | `F0-07_close_at.json` |
| Bloqueante | **Sí** |
| Estado | **Pendiente** |
| Fundamento | `ticket/sets_close_time.rb` 14-32 |

### F0-08 · `pending close` no cierra

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el estado de tipo `pending action` no fija `close_at` |
| Procedimiento | Llevar un ticket a `pending close` y leer `close_at` |
| Resultado esperado | `close_at` **vacío** |
| Evidencia | `F0-08_pending_close.json` |
| Bloqueante | Sí |
| Estado | **Pendiente** |

### F0-09 · `merged` no cierra

| Campo | Detalle |
|---|---|
| Objetivo | Probar que una fusión no fija `close_at` |
| Procedimiento | Fusionar un ticket de prueba en otro; leer estado y `close_at` |
| Resultado esperado | Estado `merged`, tipo `merged`, `close_at` **vacío** |
| Evidencia | `F0-09_merged.json` |
| Bloqueante | Sí |
| Estado | **Pendiente** |

---

## 5. Bloque C — Reproducibilidad de la matriz

### F0-10 · Reproducción de las 30 filas

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar que la matriz se reproduce exactamente |
| Procedimiento | Ejecutar la consulta de validación sobre COSE |
| Resultado esperado | 30 filas; suma 2.109; 27 con SLA (2.087); 3 sin SLA (22) |
| Evidencia | `F0-10_matrix.json` |
| Bloqueante | **Sí** |
| Estado | **Ejecutada (lectura)** — resultado: 30/30 filas exactas, 2.109 / 2.087 / 22 |

### F0-11 · Reproducción del volumen fuera de catálogo

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar el 32,51 % |
| Procedimiento | Contar el complemento de las 30 etiquetas normalizadas |
| Resultado esperado | 3.125 total; 2.109 dentro; **1.016 fuera (32,51 %)** |
| Evidencia | `F0-11_out_of_catalog.json` |
| Bloqueante | Sí |
| Estado | **Ejecutada (lectura)** — resultado: 3.125 / 2.109 / 1.016, distribución por categoría verificada |

### F0-11b · Categoría oficial

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar que el motor clasifica con la matriz, no con COSE |
| Procedimiento | Comparar las 10 filas donde la categoría difiere |
| Resultado esperado | Las 10 diferencias documentadas en `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md` §8 |
| Evidencia | `F0-11b_category_mapping.md` |
| Bloqueante | **Sí** |
| Estado | **Ejecutada (lectura)** |

---

## 6. Bloque D — Recuperación e idempotencia

### F0-12 · Evento duplicado

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el mismo evento 100 veces produce una sola fila |
| Procedimiento | Insertar 100 veces el mismo evento calculando la misma clave |
| Resultado esperado | 1 fila en `sla_event`; 1 transición aplicada |
| Evidencia | `F0-12_duplicates.md` |
| Bloqueante | Sí |
| Estado | **Pendiente** (requiere base del BFF) |

### F0-13 · Eventos fuera de orden

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el orden de llegada no altera el resultado |
| Procedimiento | Aplicar los eventos de un ticket en orden normal y en orden inverso; comparar estado final |
| Resultado esperado | Mismo `first_response_at`, mismo `outcome`, mismo `closed_at` |
| Evidencia | `F0-13_out_of_order.md` |
| Bloqueante | Sí |
| Estado | **Pendiente** |

### F0-14 · Recuperación tras caída

| Campo | Detalle |
|---|---|
| Objetivo | Probar que una caída no pierde ni duplica |
| Procedimiento | 1) Iniciar un run. 2) Matar el proceso a mitad. 3) Reiniciar. 4) Verificar watermark y eventos. |
| Resultado esperado | El run queda `failed`; el watermark **no** avanza; al reiniciar se recupera el hueco sin duplicar |
| Evidencia | `F0-14_recovery.md` |
| Bloqueante | Sí |
| Estado | **Pendiente** |

---

## 7. Bloque E — Seguridad y datos personales

### F0-16 · Sin datos personales almacenados

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el motor no guarda cuerpos, direcciones ni adjuntos |
| Procedimiento | Inspeccionar el esquema y una muestra de `sla_event.payload` y `sla_article_delivery.failure_message` |
| Resultado esperado | Sin cuerpo, sin dirección, sin adjunto, sin teléfono; error truncado a 500 caracteres |
| Evidencia | `F0-16_no_pii.md` |
| Bloqueante | Sí |
| Estado | **Pendiente** |

---

## 8. Matriz de resultados

| ID | Prueba | Bloqueante | Estado |
|---|---|---:|---|
| F0-01 | Línea base | Sí | **Ejecutada** |
| F0-02 | Credencial de solo lectura | Sí | Pendiente |
| F0-03 | Prueba negativa de escritura (11 casos) | Sí | Pendiente |
| F0-04 | Inmutabilidad de configuración | Sí | Pendiente |
| F0-05 | Superficie de lectura | Sí | Parcial (código) |
| F0-06 | `updated_at` en la confirmación | Sí | Pendiente |
| F0-07 | `close_at` primer cierre | Sí | Pendiente |
| F0-08 | `pending close` no cierra | Sí | Pendiente |
| F0-09 | `merged` no cierra | Sí | Pendiente |
| F0-10 | 30 filas / 2.109 | Sí | **Ejecutada** |
| F0-11 | Fuera de catálogo 1.016 | Sí | **Ejecutada** |
| F0-11b | Categoría oficial | Sí | **Ejecutada** |
| F0-12 | Duplicados | Sí | Pendiente |
| F0-13 | Fuera de orden | Sí | Pendiente |
| F0-14 | Recuperación | Sí | Pendiente |
| F0-15 | Sin escrituras en el sondeo | Sí | Pendiente |
| F0-16 | Sin datos personales | Sí | Pendiente |

**4 de 17 ejecutadas** (las cuatro de solo lectura). **13 pendientes** de autorización.

---

## 9. Criterio de aprobación de la fase 0

| Condición | Exigencia |
|---|---|
| Pruebas bloqueantes | **17 / 17 aprobadas** |
| Escrituras rechazadas | **11 / 11** con 403 |
| Contadores | Idénticos a la línea base salvo los tickets de prueba declarados |
| Matriz | 30 filas, 2.109, 27/3/22 |
| Fuera de catálogo | 1.016 (32,51 %) |
| Datos personales | 0 cuerpos, 0 direcciones |

**Un solo fallo bloqueante detiene el proyecto.** No se "mitiga" una prueba fallida: se rediseña la parte afectada.

---

## 10. Qué falta antes de ejecutar

| Requisito | Responsable | Estado |
|---|---|---|
| Autorización de la fase 0 | Negocio | Pendiente |
| Creación del usuario técnico con acceso `read` | Administrador Zammad | Pendiente |
| Token de API | Administrador Zammad | Pendiente |
| Buzón de prueba | Infraestructura | Pendiente |
| Base del BFF para F0-12 a F0-14 | Infraestructura | Pendiente |
| Ventana sin uso para pruebas de escritura | Operaciones | Pendiente |

---

## 11. Confirmación

Documento de criterios. No se creó ningún usuario, token, tabla ni servicio. No se ejecutó ninguna prueba de escritura. No se modificó Zammad, Zendesk ni COSE.
