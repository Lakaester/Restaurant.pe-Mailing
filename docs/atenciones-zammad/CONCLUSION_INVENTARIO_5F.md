# CONCLUSIÓN DEL INVENTARIO 5F — ZENDESK

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con evidencia administrativa del Centro de administración de Zendesk.
**Modo:** solo lectura.

---

## 1. Resumen ejecutivo

El inventario de Zendesk quedó **parcial consolidado**. No hubo acceso directo autorizado, pero el 14/11/2026 se incorporaron capturas del Centro de administración que confirman:

- **10 integrantes** visibles.
- **3 grupos**: Administrador (2), Costumer Support (10, predeterminado), DEV Team Follow Up (3).
- **2 roles de sistema**: Administrador (5), Colaborador (0).
- Menú de canales: Text, Facebook, X, Talk, Email, Web Widget, SDK móvil.
- **`clientes@restaurant.pe`** como única dirección visible.
- **11 preferencias** globales de correo.
- **1 formulario** con 9 campos.
- **12 campos** de ticket con ID y tipo.
- **4 estados** visibles: Nuevo, Abierto, Pendiente, Resuelto.
- **6 disparadores** visibles y **2 automatizaciones** visibles.

Sigue sin verificarse: condiciones/acciones/estado de disparadores y automatizaciones, SLA policies, CSAT, informes nativos/Explore, canales activos distintos de correo, integraciones, seguridad, retención y volumen.

**Conclusión:** no se puede declarar paridad funcional ni reemplazo de Zendesk con la evidencia actual. Zammad cubre el núcleo de tickets y correo, pero faltan decisiones y datos de Zendesk.

### 1.1 Trazabilidad de fuentes

| Fuente | Tipo | Fecha |
|---|---|---|
| Código de COSE | Evidencia técnica | 14/11/2026 |
| Documentos previos | Evidencia documental | 13–14/11/2026 |
| Zammad 7.2.3 local | Evidencia técnica | 14/11/2026 |
| Respuestas del negocio | Evidencia verbal | 14/11/2026 |
| Capturas del Centro de administración | Evidencia visual | 14/11/2026 |

---

## 2. Capacidades realmente utilizadas

### 2.1 Verificadas por código de COSE

- Bandeja por búsqueda (`type:ticket status<closed`).
- Detalle de ticket y comentarios.
- Respuesta pública y nota interna.
- Asignación de agente.
- Cambio de estado.
- Categoría/subcategoría (solo subcategoría en Zendesk).
- Dominio y país (custom fields).
- Adjuntos (subida por token, descarga por `content_url`).
- Historial de conversación y timeline de cliente.
- Relación padre/hijo (`via.source`, `followup_ids`).
- Búsqueda y filtros locales.
- Dashboards BI de volumen, primera respuesta, resolución y SLA.
- Auditoría operativa en COSE.
- QyD, LocalBI y TicketBI como lógica propia de COSE.

### 2.2 Confirmadas por el negocio

- Agentes ilimitados.
- Roles administrador, supervisor y asesor.
- Canal correo.
- SLA “Soporte en Línea” con horario L–V 09:00–23:00 y S–D 09:00–20:00, editable.
- Informes de volumen y SLA en quintiles (por aclarar).
- CSAT deseable.

### 2.3 Confirmadas por capturas administrativas (14/11/2026)

- 10 integrantes visibles.
- 3 grupos y grupo predeterminado.
- 2 roles de sistema.
- 7 opciones de canal en el menú.
- `clientes@restaurant.pe` como dirección visible.
- 11 preferencias globales de correo.
- 1 formulario con 9 campos.
- 12 campos de ticket con ID y tipo.
- 4 estados visibles.
- 11 preferencias de comportamiento de tickets.
- 6 disparadores visibles y 2 automatizaciones visibles.

### 2.4 No verificadas

- Condiciones, acciones y estado de disparadores y automatizaciones.
- Macros y reglas de asignación/prioridad/escalamiento.
- SLA policies de Zendesk.
- Vistas de Soporte Especializado.
- Informes nativos/Explore y definición de “quintiles”.
- CSAT activo.
- Canales activos distintos de correo y volumen por canal.
- Ubicación del buzón exclusivo de Soporte Especializado.
- Integraciones, webhooks y seguridad.
- Volumen e histórico.

---

## 3. Qué consume COSE de Zendesk

| Consumo | Endpoint/servicio | Criticidad |
|---|---|---|
| Bandeja | `ZendeskInboxService` → search | P0 |
| Detalle + comentarios | `AtencionCompletaService` | P0 |
| Respuesta | `ZendeskActionsService.reply` | P0 |
| Nota interna | `internal-note` | P0 |
| Asignación | `assign` | P0 |
| Estado | `status` | P0 |
| Categoría | `categorize` (custom field) | P1 |
| Dominio | `updateDomain` (custom field) | P1 |
| Adjuntos | `uploads.json` / `content_url` | P1 |
| Historial | `ZendeskCustomerService` | P1 |
| Datos para BI | `v_unificado_norm` | P1 |

---

## 4. Funcionalidades indispensables para el primer lanzamiento

1. Recepción y respuesta de correo.
2. Ticket, conversación e historial.
3. Asignación de agente.
4. Estados y prioridades equivalentes.
5. Categoría/subcategoría.
6. Dominio.
7. Adjuntos.
8. Auditoría.
9. SLA operativo y reporte de cumplimiento.
10. Continuidad del BI.

**CSAT** es deseable, pero no bloquea el primer lanzamiento si se planifica como fase posterior.

---

## 5. Funcionalidades que no es necesario replicar

| Funcionalidad | Motivo |
|---|---|
| Vistas de Zendesk | COSE no las usa; usa search |
| Informes nativos de Zendesk | COSE ya tiene BI propio |
| Canales no usados (chat, redes, Talk) | Sin evidencia de uso |
| ITSM avanzado (problemas/incidentes/cambios) | No evidenciado |
| Marketing/social | Fuera del alcance de Soporte Especializado |

**Precaución:** “no evidenciado” no es lo mismo que “no usado”. Se confirma con el administrador antes de descartar.

---

## 6. Qué tiene Zammad actualmente

| Capacidad | Estado real |
|---|---|
| Tickets y artículos | `VERIFICADO_ACTIVO` (2 tickets, 5 artículos) |
| Correo Gmail | `VERIFICADO_ACTIVO` (piloto) |
| Grupos y permisos | `VERIFICADO_ACTIVO` (3 grupos) |
| Atributos `dominio` y `categoria_subcategoria` | `VERIFICADO_ACTIVO` (13/65) |
| Overviews | 13 (3 personalizadas) |
| Triggers | 3 definidos, **0 activos** |
| Macros | 1 |
| SLA | **0** |
| Calendario | 1, `America/Los_Angeles`, L–V 09:00–17:00 (incorrecto) |
| Feriados | Vacío |
| Webhooks | 0 |
| Reportes | `Report.enabled? = false` |
| CSAT | **No se encontró encuesta nativa** |
| Base de conocimiento | Modelo existe, sin contenido |
| Importador de Zendesk | Existe en código; no probado con export real |
| Elasticsearch | Desactivado |
| Worker | Detenido |

---

## 7. Qué se configura y qué requiere desarrollo

### 7.1 Configuración

- Calendario `America/Lima` con L–V 09:00–23:00 y S–D 09:00–20:00.
- Feriados.
- Políticas SLA (primera respuesta, resolución).
- Triggers/macros aprobados (solo tras inventario).
- Overviews equivalentes a las vistas usadas.
- SMTP.
- HTTPS y `fqdn`.
- Backups automáticos.
- Worker supervisado.
- Elasticsearch (si el volumen lo exige).

### 7.2 Desarrollo

- Recepción de correo por UID con deduplicación (si se elige esa estrategia).
- Mapeo de estados/prioridades (`solved`, `hold`, `urgent`).
- CSAT (encuesta y almacenamiento).
- Continuidad del BI (`v_unificado_norm` desde Zammad o ETL).
- BFF COSE ↔ Zammad.
- Migración histórica desde Zendesk.
- Rate limiting en BFF/proxy.
- Adaptación de adjuntos y HTML.

---

## 8. Dependencias externas

| Dependencia | Responsable | Impacto |
|---|---|---|
| Subdominio y HTTPS | TI | P0 |
| SMTP | TI | P0 |
| Backups | TI | P0 |
| Google OAuth (buzón dedicado) | TI/Google | P0 |
| Acceso/exportaciones de Zendesk | Administrador Zendesk | P0 |
| WhatsApp/Meta (si aplica) | Proveedor | P1 |
| Legal AGPL-3.0 | Legal | P1 |
| Elasticsearch (si aplica) | TI | P2 |

---

## 9. Qué impide iniciar un piloto real

1. Buzón definitivo no conectado (solo piloto personal); `clientes@restaurant.pe` es la única dirección visible y el buzón exclusivo de Soporte Especializado no se localizó.
2. Worker detenido.
3. Sin HTTPS/subdominio.
4. Sin backups automáticos.
5. Sin SMTP.
6. Inventario de Zendesk **incompleto**: faltan condiciones/acciones/estado de los 6 disparadores y las 2 automatizaciones, SLA, vistas, informes, canales activos y volumen.
7. Sin mapeo de estados/prioridades.
8. Sin plan de continuidad del BI.
9. Sin decisión de migración histórica.
10. Sin BFF.

---

## 10. Recomendación para la Etapa 5G

**No iniciar el BFF ni la migración todavía.** La 5G debe cerrar primero:

1. **Completar el inventario de Zendesk**: condiciones/acciones/estado de los 6 disparadores y las 2 automatizaciones, macros, SLA, vistas, informes, canales activos y volumen.
2. **Localizar el buzón exclusivo de Soporte Especializado** y su grupo; `clientes@restaurant.pe` no es suficiente evidencia.
3. **Decisión de alcance del piloto:** solo correo, o correo + WhatsApp.
4. **Configuración de Zammad:** calendario `America/Lima`, SLA, overviews, SMTP, worker, HTTPS, backups.
5. **Decisión de CSAT:** nativo/desarrollo/fase posterior.
6. **Plan de continuidad del BI.**
7. **Plan de migración histórica** (importar vs empezar limpio).
8. **Mapeo de estados/prioridades/categorías** (13/65, `categoria_subcategoria`).
9. **Diseño del BFF** (lectura primero, escritura después).

**Criterio de salida de 5G:** matriz de paridad cerrada, P0 resueltos o con plan aprobado, y piloto definido con criterios de aceptación.

---

## 11. Respuesta a las preguntas de la etapa

| Pregunta | Respuesta |
|---|---|
| ¿Qué funcionalidades usa realmente Soporte Especializado? | Correo, tickets, comentarios, asignación, estado, categoría, dominio, adjuntos, historial y reportes de volumen/SLA. |
| ¿Qué consume COSE? | Bandeja, detalle, respuesta, nota, asignación, estado, categoría, dominio, adjuntos, historial y datos para BI. |
| ¿Qué es indispensable? | Correo, ticket/conversación, asignación, estado, categoría, dominio, adjuntos, auditoría, SLA y BI. |
| ¿Qué no hace falta replicar? | Vistas de Zendesk, informes nativos (si se mantiene BI), canales no usados e ITSM avanzado. |
| ¿Qué tiene Zendesk? | 10 integrantes visibles, 3 grupos, 2 roles, 7 opciones de canal, `clientes@restaurant.pe`, 1 formulario, 12 campos, 4 estados visibles, 6 disparadores y 2 automatizaciones visibles. |
| ¿Qué tiene Zammad? | Núcleo de tickets/correo, grupos, atributos, overviews; sin SLA, sin CSAT, sin reportes activos. |
| ¿Qué se configura? | Calendario, SLA, triggers/macros, overviews, SMTP, HTTPS, backups, worker. |
| ¿Qué requiere desarrollo? | Recepción UID, mapeo de estados, CSAT, BI, BFF, migración, rate limit, adjuntos. |
| ¿Qué dependencias externas hay? | TI, Google, SMTP, Zendesk admin, Meta, legal. |
| ¿Qué impide el piloto? | Buzón dedicado no localizado, worker, HTTPS, backups, SMTP, inventario Zendesk incompleto, mapeo y BI. |
| ¿Qué falta para reemplazar sin perder operación? | Cerrar P0, completar triggers/automatizaciones/SLA/informes, configurar Zammad, adaptar contratos y migrar con trazabilidad. |

---

## 12. Conclusión final

**Zammad puede ser la plataforma propia de soporte en el núcleo de tickets y correo.** No puede declararse reemplazo completo de Zendesk todavía, porque el inventario de Zendesk sigue incompleto (condiciones/acciones/estado de disparadores y automatizaciones, SLA, informes, canales activos, volumen) y porque Zammad aún no tiene SLA, calendario correcto, reportes activos ni CSAT.

**Aportación de la 5F.1:** la evidencia administrativa confirma presencia de equipo, grupos, roles, canales, correo, formulario, campos, estados, disparadores y automatizaciones. También aclara que `clientes@restaurant.pe` es la única dirección visible y que el buzón exclusivo de Soporte Especializado sigue sin localizarse.

**Siguiente paso:** completar la información de `PENDIENTES_ADMINISTRADOR_ZENDESK.md`, cerrar las decisiones P0 y definir el alcance del piloto. Después se podrá diseñar el BFF y la migración con evidencia.
