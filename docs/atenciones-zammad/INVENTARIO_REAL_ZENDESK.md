# INVENTARIO REAL DE ZENDESK — Restaurant.pe

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con evidencia administrativa del Centro de administración de Zendesk.
**Modo:** solo lectura. No se modificó Zendesk, COSE ni Zammad.
**Alcance:** instancia de Zendesk usada por Soporte Especializado y funcionalidades consumidas por COSE.

---

## 0. Resumen ejecutivo

Este documento inventaría lo que **realmente se sabe** de la instancia de Zendesk. La conclusión principal es que el inventario **sigue siendo parcial**, pero ya no parte de cero: la Etapa 5F.1 incorporó capturas del Centro de administración de Zendesk tomadas por Victor el 14/11/2026.

Lo que está confirmado:

- Plan con **agentes ilimitados**; roles de sistema **Administrador** y **Colaborador** (fuente: negocio + captura de roles).
- **10 integrantes** visibles en el equipo; **3 grupos** (Administrador 2, Costumer Support 10, DEV Team Follow Up 3); Costumer Support es el grupo predeterminado (fuente: capturas del 14/11/2026).
- Canal de atención: **correo electrónico** (fuente: negocio, COSE y dirección `clientes@restaurant.pe` visible).
- SLA de **Soporte en Línea** con horario **lunes a viernes 09:00–23:00** y **sábados y domingos 09:00–20:00**, editable (fuente: negocio). La configuración SLA dentro de Zendesk **no se observó** en las capturas.
- **6 disparadores** visibles en la categoría inicial y **2 automatizaciones** visibles en la pestaña Activas (fuente: capturas del 14/11/2026). No se inspeccionaron condiciones, acciones ni estado activo/inactivo.
- **1 formulario** de ticket observado con 9 campos; **12 campos de ticket** con ID y tipo; **4 estados** visibles (Nuevo, Abierto, Pendiente, Resuelto), lista incompleta.
- Los informes que usa la jefatura son **volumen y cumplimiento de SLA en quintiles**, entre otros (fuente: negocio). No se observaron informes en las capturas.
- **CSAT**: se desea implementar; no se confirmó si está activo en Zendesk.

Lo que sigue pendiente se marca como `PENDIENTE_DE_ACCESO` o `PENDIENTE_DE_VALIDACION`. No se completan vacíos con suposiciones.

---

## 1. Estado de acceso a Zendesk

| Mecanismo | Disponibilidad | Uso en esta etapa |
|---|---|---|
| Acceso administrativo por navegador | No proporcionado en esta sesión | No utilizado |
| API con credenciales de COSE | Existe configuración en el backend de COSE, pero **no fue autorizada** para esta auditoría | **No se usó**; no se leyeron ni reutilizaron credenciales |
| Exportaciones del administrador | No entregadas | No disponibles |
| Capturas del Centro de administración | **Sí, 14/11/2026** | Utilizadas como evidencia visual; no se navegó Zendesk |
| Respuestas directas del negocio | Sí, parciales (14/11/2026) | Utilizadas y marcadas como fuente “negocio” |

**Decisión:** no se realizaron llamadas a endpoints productivos de Zendesk, no se buscaron credenciales y no se intentó evadir autenticación.

**Consecuencia:** este inventario es **parcial**. Las áreas sin evidencia se marcan explícitamente.

---

## 2. Fuentes y método

1. Código de COSE (`restaurant-bi`): módulo Atenciones, cliente Zendesk, servicios, DTOs, dashboards.
2. Documentación previa:
   - `AUDITORIA_MODULO_ATENCIONES_COSE.md`
   - `FLUJO_CORREO_COSE.md`
   - `MAPEO_COSE_ZAMMAD.md`
   - `ARQUITECTURA_ATENCIONES_ZAMMAD.md`
   - `PLAN_IMPLEMENTACION_ATENCIONES.md`
   - Documentos de `mailing/docs/atenciones-zammad/` (5C/5C.2).
3. Zammad 7.2.3 local (`/home/acast/mailing`), solo lectura de código y base.
4. Respuestas del negocio del 14/11/2026.

**No existen** los documentos `GAP_ANALYSIS_ZENDESK_ZAMMAD.md`, `MATRIZ_PARIDAD_FUNCIONAL.md`, `BRECHAS_CRITICAS_ZAMMAD.md` ni `PENDIENTES_VALIDACION_ZENDESK.md`. Se registra el hecho; no se inventó su contenido.

### 2.1 Nota de consistencia documental

`MAPEO_COSE_ZAMMAD.md` (documento previo de COSE) afirma que el catálogo tiene **15 categorías y ~80 subcategorías**. La verificación de la Etapa 5D sobre `CategoryData.ts` y sobre el `data_option` de Zammad dio **13 categorías y 65 subcategorías**, coincidentes entre sí. Se registra la discrepancia; prevalece la evidencia verificada, no el documento previo.

Asimismo, `MAPEO_COSE_ZAMMAD.md` propone atributos separados `categoria` y `subcategoria`. La instalación actual de Zammad usa **un solo atributo `categoria_subcategoria`** (`tree_select`, path `CATEGORÍA::subcategoría`). El inventario se basa en lo implementado, no en la propuesta previa.

### 2.2 Trazabilidad de fuentes

| Fuente | Tipo | Fecha | Uso en este documento |
|---|---|---|---|
| Código de COSE | Evidencia técnica | 14/11/2026 | Endpoints, custom fields, flujos, SLA BI |
| Documentos previos de COSE | Evidencia documental | 13–14/11/2026 | Arquitectura, flujo, mapeo, auditoría |
| Zammad 7.2.3 local | Evidencia técnica | 14/11/2026 | SLA, calendario, reportes, CSAT, triggers |
| Respuestas del negocio | Evidencia verbal | 14/11/2026 | Licencias, roles, canal, SLA, informes, CSAT |
| Capturas del Centro de administración | Evidencia visual | 14/11/2026 | Equipo, grupos, roles, canales, correo, formularios, campos, estados, comportamiento, disparadores, automatizaciones |

**Regla:** una captura demuestra lo que muestra; no demuestra actividad, uso ni configuración interna no visible.

---

## 3. Datos confirmados por el negocio

| # | Dato | Valor | Estado |
|---|---|---|---|
| 1 | Licencias | Agentes ilimitados | `VERIFICADO_ACTIVO` (fuente: negocio) |
| 2 | Roles | Administrador, supervisor, asesor | `VERIFICADO_ACTIVO` (fuente: negocio) |
| 3 | Canal | Correo electrónico | `VERIFICADO_ACTIVO` (fuente: negocio + COSE) |
| 4 | SLA | “Soporte en Línea” | `VERIFICADO_ACTIVO` (fuente: negocio) |
| 5 | Horario SLA | L–V 09:00–23:00; S–D 09:00–20:00; editable | `VERIFICADO_ACTIVO` (fuente: negocio) |
| 6 | Automatizaciones | No disponibles (“esto no lo tengo”) | `PENDIENTE_DE_ACCESO` |
| 7 | Informes | Volumen, cumplimiento SLA en quintiles, etc. | `PENDIENTE_DE_VALIDACION` |
| 8 | CSAT | Deseable implementarlo | `PENDIENTE_DE_ACCESO` (no se confirmó si está activo) |
| 9 | Integrantes visibles | 10 personas en la captura de Equipo | `VERIFICADO_ACTIVO` (captura 14/11/2026; no implica totalidad histórica) |
| 10 | Grupos | Administrador (2), Costumer Support (10, predeterminado), DEV Team Follow Up (3) | `VERIFICADO_ACTIVO` (captura 14/11/2026) |
| 11 | Roles de sistema | Administrador (5 integrantes), Colaborador (0) | `VERIFICADO_ACTIVO` (captura 14/11/2026) |
| 12 | Dirección de correo visible | `clientes@restaurant.pe` | `VERIFICADO_ACTIVO` (captura 14/11/2026) |
| 13 | Formulario de ticket | 1 formulario con 9 campos | `VERIFICADO_ACTIVO` (captura 14/11/2026) |
| 14 | Campos de ticket | 12 campos con ID y tipo | `VERIFICADO_ACTIVO` (captura 14/11/2026) |
| 15 | Disparadores / automatizaciones | 6 disparadores visibles; 2 automatizaciones visibles | `VERIFICADO_ACTIVO` (captura 14/11/2026; condiciones/acciones pendientes) |

---

## 4. Inventario por área

Leyenda de estado: `VERIFICADO_ACTIVO`, `VERIFICADO_INACTIVO`, `EXISTE_PERO_NO_SE_USA`, `NO_ENCONTRADO`, `PENDIENTE_DE_ACCESO`, `PENDIENTE_DE_VALIDACION`, `NO_APLICA`.

### A. Plan, licencias y usuarios

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Plan contratado | `PENDIENTE_DE_ACCESO` | No hay factura/plan | — | — | — | P1 |
| Licencias | `VERIFICADO_ACTIVO` | “Agentes ilimitados” | Negocio | — | Zammad no usa licencias por agente (AGPL); validar legalmente | — |
| Roles | `VERIFICADO_ACTIVO` | Admin, supervisor, asesor | Negocio | COSE tiene roles propios | Roles y permisos de Zammad | P1 |
| Administradores | `PENDIENTE_DE_ACCESO` | No hay listado | — | — | `admin.*` | P1 |
| Grupos | `PENDIENTE_DE_ACCESO` | No hay listado | — | COSE filtra por grupo en Zammad, no en Zendesk | Grupos de Zammad | P1 |
| Agentes por grupo | `PENDIENTE_DE_ACCESO` | No hay listado | — | — | `groups_users` | P1 |
| Usuarios finales | `PENDIENTE_DE_ACCESO` | No hay conteo | — | — | `User` con rol Customer | P2 |
| Restricciones de acceso | `PENDIENTE_DE_ACCESO` | No hay política | — | — | Permisos por grupo | P1 |

**Evidencia administrativa del 14/11/2026:**

| Elemento | Valor observado | Estado |
|---|---|---|
| Integrantes visibles | Alex Lopez, Cristian Arbulu, Danilo Peña, Eveling Lovera, Lidia Ceferino, Lisbeth Huaman, Sheyla Guevara, Victor Castagnino, Victor Guevara, Vivyam Vivas | `VERIFICADO_ACTIVO` (captura) |
| Grupos | Administrador (2), Costumer Support (10), DEV Team Follow Up (3) | `VERIFICADO_ACTIVO` (captura) |
| Grupo predeterminado | Costumer Support | `VERIFICADO_ACTIVO` (captura) |
| Roles de sistema | Administrador (5), Colaborador (0) | `VERIFICADO_ACTIVO` (captura) |

**Precauciones:** los 10 integrantes son los visibles en la captura, no necesariamente la totalidad histórica. Los miembros de grupos no son usuarios únicos: una persona puede estar en varios grupos. Los roles no son grupos.

### B. Canales de atención

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Correo electrónico | `VERIFICADO_ACTIVO` | Canal confirmado; COSE lee/escribe tickets | Negocio + COSE | Flujo completo | Canal Email/Google | P0 |
| WhatsApp | `PENDIENTE_DE_ACCESO` | COSE tiene proveedor Meta, pero no se confirmó como canal de Zendesk | COSE | Parcial (Meta) | Driver WhatsApp (requiere proveedor) | P1 |
| Chat web | `PENDIENTE_DE_ACCESO` | No implementado en COSE | — | No | Chat de Zammad | P2 |
| Formularios web | `PENDIENTE_DE_ACCESO` | No evidenciado | — | No | Formularios/portal | P2 |
| Teléfono / Talk | `PENDIENTE_DE_ACCESO` | No evidenciado | — | No | CTI (integración) | P3 |
| Redes sociales | `PENDIENTE_DE_ACCESO` | No evidenciado | — | No | Facebook/Telegram (drivers) | P3 |
| Dirección/identidad de cada canal | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | EmailAddress/Channel | P1 |
| Volumen mensual por canal | `PENDIENTE_DE_ACCESO` | No hay métricas de Zendesk | — | COSE BI tiene volumen por canal | Reportes de Zammad/BI | P1 |
| Grupos que reciben cada canal | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | `group_id` del canal | P1 |

**Evidencia administrativa del 14/11/2026 — opciones visibles en el menú de Canales:**

| Opción visible | Estado | Observación |
|---|---|---|
| Text | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| Páginas de Facebook | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| Cuentas de X Corp. | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| Talk | `PENDIENTE_DE_VALIDACION` | Muestra invitación a prueba gratuita; no implica canal activo |
| Email | `VERIFICADO_ACTIVO` | Único canal confirmado por uso y dirección visible |
| Web Widget | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| SDK para móviles | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |

**Dirección de correo observada:** `clientes@restaurant.pe` es la única dirección visible en “Administrar direcciones de soporte”. El buzón exclusivo de Soporte Especializado **no se observó** en esa pantalla; no se concluye que no exista. Su asociación a grupos y su ubicación en Zendesk quedan `PENDIENTE_DE_VALIDACION`.

**Diferenciación:** solo el correo está confirmado como canal realmente utilizado. Las opciones del menú no son canales activos. Los demás no deben asumirse.

### C. Tickets y conversaciones

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Estados | `PENDIENTE_DE_ACCESO` | COSE maneja `new/open/pending/solved/closed` | COSE | Sí | `new/open/pending reminder/closed/pending close` | P1 |
| Prioridades | `PENDIENTE_DE_ACCESO` | COSE maneja `low/normal/high/urgent` | COSE | Sí | `1 low/2 normal/3 high` | P1 |
| Tipos de ticket | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Atributo `type` (inactivo por defecto) | P2 |
| Campos estándar | `VERIFICADO_ACTIVO` | Asunto, descripción, estado, prioridad, solicitante, asignado | COSE | Sí | Campos de `Ticket` | — |
| Campos personalizados | `VERIFICADO_ACTIVO` | Dominio (`40769061038615`), país (`1500005211481`), categoría/subcategoría (`38744095836311`) | COSE | Sí | `dominio`, `categoria_subcategoria` | P1 |
| Comentarios públicos | `VERIFICADO_ACTIVO` | `comment.public=true` | COSE | Sí | Artículo `email`/`web` público | — |
| Notas internas | `VERIFICADO_ACTIVO` | `comment.public=false` | COSE | Sí | Artículo `note` + `internal=true` | — |
| Seguimientos por correo | `VERIFICADO_ACTIVO` | `via.source.rel=follow_up`, `followup_ids` | COSE | Sí (QyD) | `message_id`/`in_reply_to` + asunto | P1 |
| Reaperturas | `PENDIENTE_DE_VALIDACION` | COSE no implementa reapertura explícita | COSE | No | `follow_up?` y `follow_up_possible` | P2 |
| Transferencias | `PENDIENTE_DE_VALIDACION` | No evidenciado en UI | — | No | Cambio de `group_id` | P2 |
| Asignación de agentes | `VERIFICADO_ACTIVO` | `assignee_id` | COSE | Sí | `owner_id` | P1 |
| Tickets relacionados | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | `Link` | P2 |
| Duplicados | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | Búsqueda/duplicados de Zammad | P2 |
| Fusión y división | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | `ticket_merge`, `ticket_split` | P2 |
| Adjuntos | `VERIFICADO_ACTIVO` | `comment.attachments`, uploads | COSE | Sí | `Store`/`UploadCache` | P1 |
| Historial y auditoría | `VERIFICADO_ACTIVO` | Comentarios + `atencion_auditoria` de COSE | COSE | Sí | Historial de Zammad + auditoría COSE | P1 |

**Formulario de ticket observado (14/11/2026):** un formulario con Asunto, Descripción, PAÍS, Tipo de resolución, Categoría de Soporte, Grupo de canales, Nivel de resolución, Dominio e ID de correo electrónico de varios destinatarios. La interfaz indica que para agregar más formularios se debe actualizar la cuenta. No se afirma que sea el único formulario histórico.

**Campos de ticket observados (14/11/2026):**

| Campo | ID | Tipo | Personalizado |
|---|---|---|---|
| Agente asignado | 360055496673 | Desplegable | No |
| Asunto | 360055496553 | Texto | No |
| Categoría de Soporte | 38744095836311 | Desplegable | **Sí** |
| Descripción | 360055496573 | Multilíneas | No |
| Dominio | 40769061038615 | Texto | **Sí** |
| Grupo | 360055496653 | Desplegable | No |
| Grupo de canales | 40450627571351 | Desplegable | No |
| ID de correo electrónico de varios destinatarios | 41121515402903 | Texto | No |
| Nivel de resolución | 40450627572631 | Desplegable | No |
| PAÍS | 1500005211481 | Desplegable | **Sí** |
| Ticket status | 9191755491095 | Desplegable | No |
| Tipo de resolución | 36134434290711 | Desplegable | No |

**Estados observados (14/11/2026):** Nuevo, Abierto, Pendiente, Resuelto. La captura no muestra la lista completa; queda `PENDIENTE_DE_VALIDACION`.

**Comportamiento de tickets observado (14/11/2026):**

| Preferencia | Estado |
|---|---|
| Configurar el redactor en público de manera predeterminada | Activada |
| Permitir que los comentarios de agentes enviados por correo sean públicos por defecto | Activada |
| Modo borrador predeterminado | Desactivado |
| Permitir comentarios por correo de usuarios finales en CC públicos | Desactivado |
| Revisión ortográfica y gramatical | Activada |
| Permitir reemplazo de texto con emoji | Activada |
| Permitir que los agentes cambien el color del texto | Activada |
| Permitir que los agentes traduzcan conversaciones | Desactivada |
| Traducciones hechas con IA para todos los canales | Desactivada |
| Mostrar divulgación de traducción de IA | Desactivada |
| Permitir que los agentes envíen mensajes de audio | Activada |

No se inspeccionaron los apartados de descargas/adjuntos, CC y seguidores, asignaciones/notificaciones, estados personalizados ni etiquetas. Quedan `PENDIENTE_DE_VALIDACION`.

### D. Automatizaciones

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Triggers | `PENDIENTE_DE_ACCESO` | “Esto no lo tengo” | Negocio | No se conoce | Triggers (0 activos en local) | P1 |
| Automations | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No se conoce | Schedulers/triggers | P1 |
| Macros | `PENDIENTE_DE_ACCESO` | Sin inventario | — | COSE no tiene macros | Macros (1 en local) | P1 |
| Reglas de asignación | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No | Triggers/macros | P1 |
| Reglas de prioridad | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No | Triggers | P2 |
| Notificaciones | `PENDIENTE_DE_ACCESO` | Sin inventario | — | COSE tiene motor propio de notificaciones | Notificaciones de Zammad | P1 |
| Escalamiento | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No | SLA/escalation | P1 |
| Reapertura automática | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No | Triggers/schedulers | P2 |
| Automatizaciones por canal | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No | Triggers con condición de canal | P2 |
| Automatizaciones por horario | `PENDIENTE_DE_ACCESO` | Sin inventario | — | No | Schedulers | P2 |

**Evidencia administrativa del 14/11/2026 — Disparadores:**

Se observan **6 disparadores** en la categoría inicial:

1. Notificar al solicitante y a los destinatarios de copias (CC) sobre la solicitud recibida.
2. Notificar al solicitante y a los destinatarios de copias (CC) sobre la actualización de los comentarios.
3. Notificar al solicitante sobre nuevo ticket proactivo.
4. Notificar al agente asignado sobre actualización de comentarios.
5. Notificar al agente asignado sobre asignación.
6. Notificar al agente asignado sobre ticket que se haya vuelto a abrir.

La categoría “Asignaciones de tickets” muestra **0 disparadores**.

**No se inspeccionaron** condiciones, acciones ni estado activo/inactivo de cada disparador. No se afirma que los seis estén activos.

**Evidencia administrativa del 14/11/2026 — Automatizaciones:**

Se observan **2 automatizaciones** en la pestaña “Activas”, ambas con el nombre:

`Cerrar el ticket 4 días después de que el estado se haya definido como resuelto`

| Automatización | Creación | Última actualización |
|---|---|---|
| Primera | 18/11/2020 | 06/06/2023 |
| Segunda | 24/11/2020 | 24/11/2020 |

No se inspeccionaron condiciones ni acciones internas. **No se asume que sean duplicadas funcionalmente**; deben revisarse.

**Conclusión del área:** el inventario ya no está vacío, pero sigue siendo **parcial**. Se conocen nombres y existencia de 6 disparadores y 2 automatizaciones; faltan condiciones, acciones, estado y alcance. No se puede afirmar paridad operativa todavía.

### E. SLA y horarios

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Políticas SLA en Zendesk | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | `Sla` (0 en local) | P0 |
| Primera respuesta | `VERIFICADO_ACTIVO` (en COSE BI) | Meta correo 1440 min en `unificado.repository.ts` | COSE | Sí (dashboard) | `first_response_time` | P1 |
| Próxima respuesta | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | `response_time`/`update_time` | P2 |
| Resolución | `VERIFICADO_ACTIVO` (provisional en COSE BI) | Meta correo 1440 min, marcada “PROVISIONAL” | COSE | Sí (dashboard) | `solution_time` | P1 |
| Horario de atención | `VERIFICADO_ACTIVO` | L–V 09:00–23:00; S–D 09:00–20:00; editable | Negocio | Sí | `Calendar.business_hours` | P0 |
| Feriados | `PENDIENTE_DE_VALIDACION` | No hay calendario | — | — | `Calendar.public_holidays` | P1 |
| Calendarios | `PENDIENTE_DE_VALIDACION` | No hay inventario | — | — | `Calendar` (1 en local, horario incorrecto) | P1 |
| Pausas y suspensiones | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | — | Estados pendientes/SLA | P2 |
| Escalamientos | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | `Ticket::Escalation` | P1 |
| Grupos/canales afectados | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | — | Condición de SLA | P1 |

**Nota de reconciliación:** `AUDITORIA_MODULO_ATENCIONES_COSE.md` afirma “no hay SLA propio (se depende de Zendesk)”. Eso describe el **módulo Atenciones**. COSE sí calcula cumplimiento SLA en el **dashboard BI** (`/dashboard/sla`) a partir de `v_unificado_norm`. Son dos cosas distintas: cálculo analítico vs política operativa. La política operativa de Zendesk no está verificada.

**Evidencia administrativa del 14/11/2026:** las capturas compartidas corresponden a Equipo, Canales, Correo, Formularios, Campos, Estados, Comportamiento, Disparadores y Automatizaciones. **No incluyeron la configuración de SLA.** Por tanto, las políticas SLA de Zendesk siguen `PENDIENTE_DE_ACCESO`.

### F. Vistas y productividad

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Vistas de Zendesk | `EXISTE_PERO_NO_SE_USA` | COSE usa search, no Views; `ZendeskViewIds.ts` está deprecado | COSE | No | Overviews | P2 |
| Vistas de Soporte Especializado | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Overviews (13 en local) | P1 |
| Condiciones/orden/columnas | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Overviews | P2 |
| Acciones disponibles | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Macros/acciones | P2 |
| Filtros | `VERIFICADO_ACTIVO` | Filtros locales de bandeja (canal, estado, “solo míos”) | COSE | Sí | Búsqueda/overviews | P1 |
| Búsqueda | `VERIFICADO_ACTIVO` | `searchTickets("type:ticket status<closed")` | COSE | Sí | `/tickets/search` | P1 |
| Acciones masivas | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | `tickets_mass_update` | P2 |
| Colisiones entre agentes | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | Bloqueo/actualización | P2 |
| Actualización en tiempo real | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | WebSocket/Redis | P2 |

### G. Clientes y organizaciones

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Usuarios finales | `VERIFICADO_ACTIVO` | `requester_id` → `/users/{id}` | COSE | Sí | `User` Customer | — |
| Organizaciones | `PENDIENTE_DE_VALIDACION` | COSE no las usa en el flujo | — | No | `Organization` | P2 |
| Dominios | `VERIFICADO_ACTIVO` | Custom field + normalización COSE | COSE | Sí | Atributo `dominio` | P1 |
| Campos de cliente | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Campos de `User` | P2 |
| Campos de organización | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Campos de `Organization` | P2 |
| Relación ticket–cliente | `VERIFICADO_ACTIVO` | `requester_id` | COSE | Sí | `customer_id` | — |
| Duplicados | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | Búsqueda/deduplicación | P2 |
| Reglas de identificación | `VERIFICADO_ACTIVO` | Dominio por historial; único dominio | COSE | Sí | BFF/atributos | P1 |

### H. Reportes y analítica

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Informes nativos de Zendesk | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Reportes de Zammad | P1 |
| Explore | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | No equivalente directo | P1 |
| Dashboards | `VERIFICADO_ACTIVO` (en COSE) | `/dashboard/zendesk`, `/dashboard/sla`, etc. | COSE | Sí | Reportes/overviews | P1 |
| Métricas de atención | `VERIFICADO_ACTIVO` | `Zendesk.tsx`: volumen, estados, primera respuesta, resolución, SLA | COSE | Sí | Reportes | P1 |
| Volumen por canal | `VERIFICADO_ACTIVO` | `Sla.tsx`: por canal/país/asesor/categoría | COSE | Sí | Reportes | P1 |
| Primera respuesta | `VERIFICADO_ACTIVO` | Mediana, p90, promedio, cobertura | COSE | Sí | SLA/reportes | P1 |
| Resolución | `VERIFICADO_ACTIVO` | Mediana, p90, promedio, cobertura | COSE | Sí | SLA/reportes | P1 |
| Cumplimiento SLA | `VERIFICADO_ACTIVO` | `cumplimientoPrimera`, `cumplimientoResolucion` | COSE | Sí | SLA/reportes | P1 |
| Productividad por agente | `VERIFICADO_ACTIVO` | `porAsesorCorreo` | COSE | Sí | Reportes | P1 |
| Productividad por grupo | `PENDIENTE_DE_VALIDACION` | No se observó desglose por grupo | — | No | Reportes | P2 |
| Exportaciones | `PENDIENTE_DE_VALIDACION` | No evidenciado | — | No | Exportación CSV/API | P2 |
| Reportes de jefatura | `PENDIENTE_DE_VALIDACION` | “Volumen, SLA en quintiles, etc.” | Negocio | Parcial | Reportes/BI | P1 |

**Nota:** el código de COSE usa **mediana y p90**, no “quintiles”. El negocio menciona quintiles. `PENDIENTE_DE_VALIDACION` aclarar si “quintiles” significa cinco tramos de cumplimiento o percentiles.

**Evidencia administrativa del 14/11/2026:** las capturas no incluyeron informes ni Explore. Los informes nativos de Zendesk siguen `PENDIENTE_DE_ACCESO`; lo verificado sigue siendo el BI de COSE.

### I. Calidad y experiencia del cliente

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| CSAT | `PENDIENTE_DE_ACCESO` | No se confirmó si está activo | Negocio | No | **No se encontró encuesta nativa**; requiere desarrollo/extensión | P1 |
| Encuestas | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | No nativo | P2 |
| Calificaciones | `VERIFICADO_ACTIVO` (en COSE) | `calificacion` 1–5 en `atencion` | COSE | Sí, interna | Atributo personalizado | P2 |
| Comentarios de satisfacción | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | No nativo | P2 |
| Reglas de envío | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Triggers (si se implementa) | P2 |
| Momentos de envío | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Triggers | P2 |
| Guide / base de conocimiento | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Knowledge Base | P2 |
| Portal de clientes | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Portal de Zammad | P2 |
| Formularios de autoservicio | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Formularios | P2 |

**CSAT:** el negocio lo considera deseable. En Zammad no se encontró una encuesta CSAT nativa; solo un ratio de satisfacción en el módulo de analítica de IA, que no es una encuesta al cliente. Se clasifica como **DESARROLLO**.

### J. Integraciones y extensiones

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Aplicaciones instaladas | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | — | P2 |
| Integraciones | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Webhooks/API | P1 |
| Webhooks | `PENDIENTE_DE_ACCESO` | No hay inventario | — | No | Webhooks (0 en local) | P2 |
| API tokens/OAuth | `PENDIENTE_DE_ACCESO` | Solo inventariar existencia/tipo; nunca valores | — | COSE usa API token | Tokens de Zammad | P1 |
| Integración con COSE | `VERIFICADO_ACTIVO` | `/api/zendesk/*` | COSE | Sí | BFF (futuro) | P0 |
| WhatsApp / Meta | `VERIFICADO_ACTIVO` (en COSE) | `MetaService` | COSE | Parcial | Driver WhatsApp | P1 |
| BI | `VERIFICADO_ACTIVO` (en COSE) | `v_unificado_norm` | COSE | Sí | ETL/BFF | P1 |
| Herramientas externas | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | — | P3 |

### K. Administración, seguridad y conservación

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Autenticación | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Local/LDAP/OIDC | P1 |
| SSO | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | OIDC/SAML (según configuración) | P2 |
| Restricciones por IP | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Proxy/red | P3 |
| Políticas de contraseñas | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Settings de Zammad | P2 |
| Auditoría | `PENDIENTE_DE_ACCESO` | Zendesk audit no inventariado | — | COSE tiene auditoría propia | Historial/audit logs | P1 |
| Retención de datos | `PENDIENTE_DE_ACCESO` | No hay política | — | — | Configuración/backups | P1 |
| Almacenamiento de adjuntos | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | `Store` (DB) | P1 |
| Exportación de datos | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | API/exportación | P1 |
| Política de eliminación | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Configuración | P2 |
| Seguridad de API | `PENDIENTE_DE_ACCESO` | No hay inventario | — | — | Tokens/permisos | P1 |

### L. Volumen e histórico

| Funcionalidad | Estado | Evidencia | Fuente | Uso en COSE | Equivalencia Zammad | Prioridad |
|---|---|---|---|---|---|---|
| Tickets totales | `PENDIENTE_DE_ACCESO` | No hay conteo | — | — | — | P1 |
| Tickets por año/mes | `PENDIENTE_DE_ACCESO` | No hay conteo | — | COSE BI puede tener volumen | Reportes | P1 |
| Abiertos/pendientes/cerrados | `PENDIENTE_DE_ACCESO` | No hay conteo | — | COSE BI | Reportes | P1 |
| Volumen por canal/grupo/agente | `PENDIENTE_DE_ACCESO` | No hay conteo | — | COSE BI parcial | Reportes | P1 |
| Artículos | `PENDIENTE_DE_ACCESO` | No hay conteo | — | — | — | P2 |
| Adjuntos (cantidad/volumen) | `PENDIENTE_DE_ACCESO` | No hay conteo | — | — | — | P1 |
| Antigüedad del histórico | `PENDIENTE_DE_ACCESO` | No hay fecha de inicio | — | — | — | P1 |
| Exportación histórica | `PENDIENTE_DE_ACCESO` | No hay plan | — | — | Importador de Zendesk | P0 |

---

## 5. Limitaciones

1. No hubo acceso directo autorizado a Zendesk; no se hicieron llamadas.
2. Se recibieron capturas administrativas del 14/11/2026, pero no exportaciones completas.
3. El negocio no dispone del inventario de automatizaciones; las capturas solo muestran nombres, no condiciones ni acciones.
4. No se pudo verificar SLA, condiciones/acciones de triggers y automatizaciones, CSAT, informes, retención ni volumen.
5. El código de COSE demuestra **uso**, no **configuración de Zendesk**.
6. Las capturas demuestran **existencia visible**, no actividad ni uso operativo.

---

## 6. Conclusión

**Verificado con evidencia:** correo como canal, 10 integrantes visibles, 3 grupos, 2 roles de sistema, `clientes@restaurant.pe`, 1 formulario, 12 campos con ID, 4 estados visibles, 6 disparadores y 2 automatizaciones visibles, SLA de negocio con horario, uso de tickets/comentarios/asignación/estado/categoría/dominio/adjuntos, y dashboards BI de SLA/volumen en COSE.

**No verificado:** condiciones/acciones/estado de disparadores y automatizaciones, SLA policies de Zendesk, CSAT, informes nativos/Explore, canales activos distintos de correo, integraciones, seguridad, retención y volumen.

**Estado:** inventario **parcial consolidado**. La evidencia administrativa cubre presencia y configuración visible; no cubre actividad ni uso. Para cerrar la 5F falta la información listada en `PENDIENTES_ADMINISTRADOR_ZENDESK.md`.
