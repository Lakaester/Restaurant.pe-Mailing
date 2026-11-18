# DISEÑO FUNCIONAL — ADMINISTRADOR SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño y auditoría. **No implementado.**
**Estado:** propuesta funcional basada en decisiones aprobadas y evidencia verificada.

---

## 1. Objetivo

Diseñar un administrador de SLA para Soporte Especializado que permita:

- Gestionar la primera respuesta por canal.
- Gestionar la resolución por canal, categoría y subcategoría.
- Administrar 65 combinaciones individuales.
- Medir en tiempo calendario, sin pausas.
- Registrar cambios con auditoría.
- Consultar cumplimiento y alertas.
- Servir de base para la futura integración con COSE.

No se implementa ninguna pantalla ni se crea ningún SLA en esta etapa.

---

## 2. Decisiones aprobadas

| # | Decisión | Estado |
|---|---|---|
| 1 | Tiempo calendario 24×7 | **APROBADA** |
| 2 | Ningún estado pendiente pausa el SLA | **APROBADA** |
| 3 | La resolución finaliza al pasar a `closed` | **APROBADA** |
| 4 | `pending close` no finaliza ni pausa | **APROBADA** |
| 5 | 65 combinaciones individuales | **APROBADA** |
| 6 | Nombres de políticas con prefijo para precedencia | **APROBADA** |
| 7 | Congelar el SLA inicial al clasificar | **APROBADA** |
| 8 | Registrar reclasificación sin alterar el SLA original | **APROBADA** |
| 9 | Respaldos provisionales: WhatsApp 90 min, correo 36 h | **APROBADA (provisional)** |
| 10 | Cumplimiento objetivo ≥ 80 % | **APROBADA** |
| 11 | Ventana estadística 01/04/2026–31/10/2026 | **APROBADA** |
| 12 | Revisión trimestral | **APROBADA** |
| 13 | Responsable administrativo | **PENDIENTE** |

---

## 3. Alcance funcional

### 3.1 Dentro del alcance

1. Panel general de SLA.
2. Administración de primera respuesta.
3. Administración de resolución.
4. Matriz canal × categoría × subcategoría.
5. Excepciones y combinaciones pendientes.
6. Historial de cambios.
7. Configuración de alertas.
8. Reportes de cumplimiento.
9. Auditoría de cambios.
10. Preparación de la integración con COSE.

### 3.2 Fuera del alcance

- Implementación de pantallas.
- Creación de SLA.
- Cambio de estados.
- Creación de calendarios.
- BFF.
- Migración de datos.
- Modificación de COSE.

---

## 4. Roles y permisos

| Rol | Capacidades |
|---|---|
| Administrador SLA | Crear, editar, activar/desactivar políticas; ver historial; configurar alertas |
| Supervisor | Consultar panel, reportes e historial; no editar |
| Asesor | Consultar el SLA del ticket; no administrar |
| Auditor | Consultar historial y cambios; no editar |

**Propuesta:** permiso `admin.sla` para edición y un permiso de solo lectura para supervisores. En COSE, un permiso equivalente (`SLA.ver`, `SLA.editar`). **PENDIENTE** definir el modelo exacto.

---

## 5. Panel general

### 5.1 Indicadores

| Indicador | Definición |
|---|---|
| Políticas activas | SLA con condición vigente |
| Políticas inactivas | SLA desactivada o fuera de vigencia |
| Canales cubiertos | WhatsApp / Correo |
| Combinaciones cubiertas | 65 con SLA + 5 pendientes |
| Tickets dentro del SLA | Sin vencimiento ni incumplimiento |
| Tickets próximos a vencer | Umbral configurable |
| Tickets incumplidos | Primera respuesta o resolución vencida |
| Cumplimiento de primera respuesta | % de tickets con primera respuesta a tiempo |
| Cumplimiento de resolución | % de tickets cerrados dentro del plazo |

### 5.2 Separación obligatoria

El panel debe mostrar **primera respuesta** y **resolución** por separado. No se agregan en un solo porcentaje.

### 5.3 Filtros

- Canal.
- Categoría.
- Subcategoría.
- Grupo.
- Agente.
- Rango de fechas.
- Estado de cumplimiento.

---

## 6. Administración de primera respuesta

### 6.1 Objetivos aprobados

| Canal | Objetivo |
|---|---:|
| WhatsApp | < 15 minutos |
| Correo electrónico | < 24 horas (1.440 minutos) |

### 6.2 Edición

- El valor es editable desde la interfaz.
- Todo cambio exige: usuario, fecha, valor anterior, valor nuevo y motivo.
- No se puede dejar el valor vacío.
- No se puede poner un valor ≤ 0.
- El cambio debe reflejarse en las políticas de ese canal.

### 6.3 Regla de primera respuesta

**VERIFICADO en Zammad 7.2.3:** `first_response_at` se fija con el primer artículo que cumple:

1. No es interno.
2. El emisor es `Agent`.
3. El tipo de artículo es de comunicación.

Una nota interna **no** cuenta. Una respuesta pública de agente **sí** cuenta. `first_response_at` se fija una sola vez y no se sobrescribe.

**PENDIENTE:** confirmar si una respuesta por WhatsApp o correo generada por un trigger cuenta como agente; la regla de código usa el emisor del artículo.

---

## 7. Administración de resolución

### 7.1 Estructura

Cada fila de la matriz contiene:

| Campo | Descripción |
|---|---|
| Canal | WhatsApp / Correo |
| Categoría | Una de las 13 |
| Subcategoría | Una de las 65 |
| N | Tamaño de muestra |
| P75 | Percentil usado |
| Confianza | ALTA / MEDIA / BAJA / INSUFICIENTE |
| SLA propuesto | Minutos |
| Origen estadístico | Ventana 01/04/2026–31/10/2026 |
| Fecha de corte | 31/10/2026 |
| Estado | Activa / Inactiva / Pendiente |
| Versión | Número de versión de la matriz |

### 7.2 Reglas

- Las 65 combinaciones con evidencia se administran individualmente.
- Las 5 sin evidencia se muestran como `PENDIENTE DE VALIDACIÓN — SIN SLA`.
- No se inventa un valor para las 5 pendientes.
- El respaldo provisional (90 min WhatsApp / 36 h correo) se aplica solo a casos fuera de catálogo, no a las 5 combinaciones pendientes, salvo decisión expresa.
- El SLA se calcula desde `created_at`.
- La resolución se registra al pasar a `closed`.

### 7.3 Reclasificación

- El SLA se congela en la primera clasificación.
- Si el ticket se reclasifica, se registra el cambio.
- El SLA original no se altera.
- El nuevo SLA no reemplaza al anterior; se guarda como evento de reclasificación.

**HIPÓTESIS:** el motor nativo de Zammad recalcula el SLA al cambiar `categoria_subcategoria`. Para congelarlo se necesita un mecanismo adicional. Ver `ARQUITECTURA_TECNICA_MOTOR_SLA_5G3.md` §5.

---

## 8. Excepciones y valores predeterminados

| Escenario | Regla propuesta | Estado |
|---|---|---|
| Ticket sin categoría | Sin SLA hasta clasificar; no asignar tiempo arbitrario | **PROPUESTA** |
| Ticket sin subcategoría | Sin SLA hasta clasificar | **PROPUESTA** |
| Categoría no homologada | Respaldo provisional del canal, marcado | **APROBADA (provisional)** |
| Subcategoría nueva | Respaldo provisional del canal, marcado | **APROBADA (provisional)** |
| Canal no contemplado | Sin SLA; revisión manual | **PROPUESTA** |
| Combinación sin evidencia | Sin SLA; pendiente de validación | **APROBADA** |
| Política desactivada | Sin SLA; el ticket queda sin política | **PROPUESTA** |
| Cambio de categoría | Se conserva el SLA original; se registra el cambio | **APROBADA** |

**Distinción obligatoria:** “sin SLA” no es “incumplido”. Un ticket sin política no suma al denominador de cumplimiento.

---

## 9. Alertas

### 9.1 Estados

| Estado | Significado |
|---|---|
| Dentro del SLA | No vencido y sin marca de cumplimiento |
| Próximo a vencer | Falta menos que el umbral configurado |
| Incumplido | Venció sin cumplir |
| Cumplido | Se cumplió dentro del plazo |
| Sin SLA asignado | No hay política aplicable |

### 9.2 Umbrales propuestos

- Primera respuesta: aviso al 75 % del tiempo.
- Resolución: aviso al 75 % y al 90 %.
- Configurables por canal.

**HIPÓTESIS:** Zammad muestra indicadores de escalamiento, pero no se verificó un mecanismo nativo de alertas con umbrales configurables. La alerta proactiva requeriría desarrollo o un job propio.

---

## 10. Reportes

| Reporte | Contenido |
|---|---|
| Cumplimiento por canal | Primera respuesta y resolución |
| Cumplimiento por categoría | Resolución |
| Cumplimiento por subcategoría | Resolución |
| Productividad por agente | Tickets, primera respuesta, resolución |
| Backlog | Tickets abiertos, pendientes y vencidos |
| Reincidencias | Tickets reabiertos |
| Exportación | CSV/API |

**VERIFICADO:** `Report.enabled? = false` en la instalación. Los reportes nativos no están activos. **PROPUESTA:** generarlos en COSE BI o en un módulo propio.

---

## 11. Flujos funcionales

### 11.1 Alta de política

1. Seleccionar canal.
2. Seleccionar categoría.
3. Seleccionar subcategoría.
4. Definir minutos de resolución.
5. Confirmar primera respuesta del canal.
6. Asignar nombre con prefijo.
7. Asignar calendario 24/7.
8. Guardar.
9. Registrar auditoría.

### 11.2 Edición de tiempo

1. Abrir política.
2. Cambiar minutos.
3. Escribir motivo.
4. Guardar.
5. Registrar valor anterior y nuevo.
6. Recalcular tickets afectados (decisión pendiente).

### 11.3 Desactivación

1. Desactivar política.
2. Los tickets existentes conservan su SLA congelado.
3. Los tickets nuevos no la reciben.
4. Registrar auditoría.

### 11.4 Reclasificación

1. El asesor cambia categoría/subcategoría.
2. Se registra el cambio.
3. El SLA original se conserva.
4. Se muestra el SLA original y el nuevo como referencia, sin alterar el vencimiento.

---

## 12. Criterios de aceptación funcionales

1. El panel muestra primera respuesta y resolución separadas.
2. Las 65 combinaciones son consultables y editables.
3. Las 5 pendientes se muestran sin SLA.
4. Todo cambio queda auditado.
5. El SLA se congela al clasificar.
6. La reclasificación no altera el SLA original.
7. La resolución se registra al pasar a `closed`.
8. `pending close` no finaliza el SLA.
9. Los tickets sin SLA no cuentan como incumplidos.
10. El cumplimiento se calcula con marcas de tiempo reales.

---

## 13. Riesgos funcionales

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Confundir cerrado con cumplido | Métricas falsas | Calcular con `close_at` y vencimiento |
| Reclasificación altera el SLA | Pérdida de trazabilidad | Congelar y auditar |
| Política desactivada deja tickets sin SLA | Hueco operativo | Revisar tickets afectados |
| 5 combinaciones sin SLA | Cobertura incompleta | Respaldo provisional o revisión |
| 31,1 % fuera de catálogo | Cobertura parcial | Respaldo provisional marcado |
| Alertas no nativas | Dependencia de desarrollo | Diseñar job/BFF |

---

## 14. Confirmación

Este documento es diseño. No se creó ningún SLA, no se modificó ningún estado, calendario ni configuración.
