# CATÁLOGO DE AUTOMATIZACIONES — ZENDESK

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con capturas de Disparadores y Automatizaciones.
**Modo:** solo lectura. No se activó, desactivó ni probó ninguna automatización.

---

## 0. Estado del inventario

**El inventario es parcial.** El negocio había respondido que no disponía de la información (“esto no lo tengo”), pero el 14/11/2026 compartió capturas del Centro de administración de Zendesk.

Lo observado:

- **6 disparadores** visibles en la categoría inicial.
- **0 disparadores** en la categoría “Asignaciones de tickets”.
- **2 automatizaciones** visibles en la pestaña “Activas”, con el mismo nombre.

Lo que **no** se observó:

- Condiciones y acciones de cada disparador.
- Estado activo/inactivo de cada disparador.
- Condiciones y acciones de cada automatización.
- Si las dos automatizaciones son funcionalmente duplicadas.
- Macros, reglas de asignación, prioridad, escalamiento, reapertura, canal u horario.

**Regla:** no se migra ni se activa ninguna automatización en Zammad hasta completar condiciones, acciones, estado y alcance.

### 0.1 Trazabilidad de fuentes

| Fuente | Tipo | Fecha | Uso |
|---|---|---|---|
| Captura `Reglas de negocio → Disparadores` | Evidencia visual | 14/11/2026 | Nombres y categoría inicial |
| Captura `Reglas de negocio → Automatizaciones` | Evidencia visual | 14/11/2026 | Nombres, pestaña Activas y fechas |
| Código de COSE | Evidencia técnica | 14/11/2026 | Automatizaciones propias de COSE |
| Zammad local | Evidencia técnica | 14/11/2026 | Equivalencias y estado local |

---

## 1. Qué se pudo verificar

### 1.1 Disparadores observados (14/11/2026)

Categoría inicial, **6 elementos visibles**. No se verificó estado activo/inactivo.

| # | Nombre | Categoría | Estado observado |
|---:|---|---|---|
| 1 | Notificar al solicitante y a los destinatarios de copias (CC) sobre la solicitud recibida | Inicial | Visible; activo/inactivo no verificado |
| 2 | Notificar al solicitante y a los destinatarios de copias (CC) sobre la actualización de los comentarios | Inicial | Visible; activo/inactivo no verificado |
| 3 | Notificar al solicitante sobre nuevo ticket proactivo | Inicial | Visible; activo/inactivo no verificado |
| 4 | Notificar al agente asignado sobre actualización de comentarios | Inicial | Visible; activo/inactivo no verificado |
| 5 | Notificar al agente asignado sobre asignación | Inicial | Visible; activo/inactivo no verificado |
| 6 | Notificar al agente asignado sobre ticket que se haya vuelto a abrir | Inicial | Visible; activo/inactivo no verificado |

**Categoría “Asignaciones de tickets”:** 0 disparadores visibles.

**No se inspeccionaron** condiciones ni acciones individuales.

### 1.2 Automatizaciones observadas (14/11/2026)

Pestaña “Activas”, **2 elementos visibles**. Ambas con el mismo nombre.

| # | Nombre | Creación | Última actualización | Estado observado |
|---:|---|---|---|---|
| 1 | Cerrar el ticket 4 días después de que el estado se haya definido como resuelto | 18/11/2020 | 06/06/2023 | Visible en Activas; condiciones/acciones no verificadas |
| 2 | Cerrar el ticket 4 días después de que el estado se haya definido como resuelto | 24/11/2020 | 24/11/2020 | Visible en Activas; condiciones/acciones no verificadas |

**No se asume que sean duplicadas funcionalmente.** Deben revisarse condiciones, acciones y alcance.

### 1.3 Elementos no observados

| Elemento | Estado |
|---|---|
| Macros de Zendesk | `PENDIENTE_DE_ACCESO` |
| Reglas de asignación | `PENDIENTE_DE_ACCESO` |
| Reglas de prioridad | `PENDIENTE_DE_ACCESO` |
| Notificaciones automáticas (detalle) | `PENDIENTE_DE_VALIDACION` |
| Escalamiento | `PENDIENTE_DE_ACCESO` |
| Reapertura automática | `PENDIENTE_DE_ACCESO` |
| Automatizaciones por canal | `PENDIENTE_DE_ACCESO` |
| Automatizaciones por horario | `PENDIENTE_DE_ACCESO` |
| Condiciones/acciones de los 6 disparadores | `PENDIENTE_DE_VALIDACION` |
| Condiciones/acciones de las 2 automatizaciones | `PENDIENTE_DE_VALIDACION` |

---

## 2. Automatizaciones propias de COSE (no son de Zendesk)

COSE tiene lógica de automatización propia. No debe confundirse con la configuración de Zendesk ni migrarse al motor de Zammad sin decisión.

| Automatización COSE | Evidencia | Qué hace | ¿Migrar a Zammad? |
|---|---|---|---|
| Auto-identificación de dominio por historial | `AtencionOperativaService.aplicarIdentificacionAutomatica` | Si hay un único dominio histórico, lo asigna | **No**. Es lógica de negocio COSE. |
| Registro de resolución en CustomerMemory | `ZendeskTestController.changeStatus` | Guarda resolución por email | **No**. COSE. |
| Creación/reutilización de expediente QyD | `crearCasoDesdeCategoria` | Crea caso de Quejas/Devoluciones al categorizar | **No**. COSE. |
| Registro de auditoría operativa | `atencion_auditoria` | Append-only de acciones | **No**. COSE. |
| Motor de notificaciones | `backend/src/domain/notifications` | Reglas y canales de notificación | **No** por ahora; evaluar. |
| Motor de automatización | `backend/src/domain/automation` | Condiciones/acciones propias | **No** por ahora; evaluar. |
| Cálculo de SLA en BI | `unificado.repository.ts`, `dashboardGerencial.repository.ts` | Cumplimiento por canal/asesor/categoría | **Parcial**. Zammad puede calcular SLA operativo; el BI puede seguir en COSE. |

**Regla:** Zammad debe ser el motor de tickets y conversaciones; COSE conserva su lógica operativa. No se duplican automatizaciones sin una decisión explícita.

---

## 3. Equivalencias en Zammad

| Tipo de automatización | Zammad | Estado en nuestra instalación | Observación |
|---|---|---|---|
| Triggers por acción | `Trigger` (`activator: action`) | 3 definidos, **0 activos** | Se pueden configurar; no activar sin aprobación. |
| Triggers por tiempo | `Trigger` (`activator: time`) | 0 activos | Requiere scheduler/worker. |
| Automatizaciones programadas | `Scheduler` | 30 schedulers activos | Revisar cuáles son del sistema. |
| Macros | `Macro` | 1 definida | Revisar contenido y alcance. |
| Reglas de asignación | Triggers + `Group.assignment_timeout` | Configurable | No configurado. |
| Reglas de prioridad | Triggers | Configurable | No configurado. |
| Notificaciones | Notificaciones de Zammad + triggers | Configurable | Requiere SMTP. |
| Escalamiento | `Sla` + `Ticket::Escalation` | 0 SLA | Requiere calendario y políticas. |
| Reapertura | `follow_up_possible`, `reopen_time_in_days` | Grupo 3: `follow_up=yes` | Configurable por grupo. |
| Respuestas predefinidas | `TextModule` | Existe el modelo; no inventariado | Configurable. |
| Base de conocimiento | `KnowledgeBase` | Existe el modelo; sin contenido | Configurable. |

---

## 4. Riesgos de migrar automatizaciones sin inventario

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Duplicar correos automáticos | Enviar dos respuestas al cliente | No activar triggers hasta inventariar Zendesk |
| Duplicar cambios de estado | Historial inconsistente | Mantener triggers inactivos |
| Perder una regla crítica | Tickets sin asignar o sin prioridad | Inventario + pruebas en staging |
| Migrar una regla obsoleta | Comportamiento no deseado | Revisión funcional con Soporte |
| Depender de macros de Zendesk | Pérdida de productividad | Replicar solo las usadas |

---

## 5. Preguntas concretas para el administrador

### 5.1 Respondidas parcialmente el 14/11/2026

| # | Pregunta | Respuesta observada |
|---|---|---|
| 1 | ¿Qué disparadores existen? | 6 visibles en la categoría inicial; faltan condiciones, acciones y estado |
| 2 | ¿Qué automatizaciones existen? | 2 visibles en Activas; faltan condiciones y acciones |
| 3 | ¿Hay disparadores de asignación? | 0 visibles en “Asignaciones de tickets” |

### 5.2 Siguen abiertas

1. Condiciones y acciones de cada uno de los **6 disparadores**.
2. Estado **activo/inactivo** de cada disparador.
3. Condiciones y acciones de las **2 automatizaciones**.
4. ¿Las dos automatizaciones son funcionalmente duplicadas?
5. ¿Qué **macros** usan los asesores? Nombre, acciones y quién las usa.
6. ¿Hay reglas de **asignación automática** por grupo, canal o carga?
7. ¿Hay reglas de **prioridad automática**?
8. ¿Hay reglas de **escalamiento** o avisos por SLA vencido?
9. ¿Hay reglas de **reapertura** automática?
10. ¿Hay reglas específicas por **canal** o por **horario**?
11. ¿Qué **notificaciones** reciben agentes, supervisores y clientes?
12. ¿Se usan **respuestas predefinidas** o plantillas? ¿Cuáles?

**Evidencia necesaria:** captura o exportación de condiciones, acciones, estado y alcance de cada elemento. No se requieren credenciales en el documento.

---

## 6. Conclusión

El catálogo ya no está vacío: se conocen **6 disparadores** y **2 automatizaciones** por nombre. Pero sigue siendo **insuficiente para migrar**, porque faltan condiciones, acciones, estado y alcance.

**Recomendación:** no activar ninguna automatización en Zammad hasta completar este catálogo y decidir cuáles se replican, cuáles se rediseñan y cuáles se descartan. Las dos automatizaciones de cierre a 4 días deben revisarse antes de asumir que son equivalentes.
