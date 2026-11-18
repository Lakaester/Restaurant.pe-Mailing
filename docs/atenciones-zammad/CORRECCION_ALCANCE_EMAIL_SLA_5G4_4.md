# CORRECCIÓN DE ALCANCE — SLA EXCLUSIVO EMAIL — 5G.4.4

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.4
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Estado:** corrección de alcance documentada. **Nada aplicado a ningún sistema.**
**Efecto:** reemplaza el alcance multicanal de 5G.2 a 5G.4.3. No sobrescribe ningún documento anterior.

---

## 1. Decisión de alcance

Zammad se utiliza **exclusivamente para atención por correo electrónico**.

| Elemento | Queda dentro del alcance | Queda fuera del alcance |
|---|---|---|
| Canal de atención | Correo electrónico | WhatsApp |
| Herramienta WhatsApp Meta | — | WHATMETA |
| Herramienta WhatsApp legado | — | WHATICKET |
| Mensajería instantánea | — | Cualquier variante |
| Otros canales | — | Todos |
| Fuente de hechos | Zammad (API REST, solo lectura) | — |
| Motor SLA | Motor propio en el BFF | Motor SLA nativo de Zammad |
| Datos históricos de metas | Zendesk (`subcanal = ZENDESK`) = correo | WHATMETA y WHATICKET |

**Consecuencias inmediatas:**

1. No existe SLA de primera respuesta por WhatsApp en el alcance vigente.
2. No existe meta de resolución por WhatsApp en el alcance vigente.
3. No hay sondeo diferenciado por canal.
4. No hay eventos de entrega de WhatsApp.
5. No hay columnas de WhatsApp en el modelo de datos.
6. La matriz oficial de resolución es exclusivamente Email.

---

## 2. Auditoría de documentos anteriores

### 2.1 Universo revisado

Se revisaron los 48 documentos de `docs/atenciones-zammad/`. Las menciones a WhatsApp, WHATMETA o WHATICKET aparecen en **37 documentos**, con **356 menciones** en total.

| Etapa | Documentos principales revisados | Menciones |
|---|---|---:|
| 5G.2 (fase E) | `ANALISIS_ESTADISTICO_RESOLUCION.md` (43), `AUDITORIA_DATOS_SLA_COSE.md` (46), `MATRIZ_PROPUESTA_SLA_RESOLUCION.md` (15), `COMPARACION_METODOLOGIAS_SLA.md` (10), `RESUMEN_EJECUTIVO_5G2.md` (12), `DECISIONES_PENDIENTES_SLA.md` (12), inventarios (22) | 160 |
| 5G.2.1 | `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` (48), `VALIDACION_ESTADISTICA_SLA_5G2_1.md` (23), `OBSERVACIONES_Y_DECISIONES_PENDIENTES_5G2_1.md` (16) | 87 |
| 5G.3 | `REGLAS_MEDICION_Y_CUMPLIMIENTO_SLA_5G3.md` (3), `MODELO_DATOS_Y_AUDITORIA_SLA_5G3.md` (1), `DISENO_FUNCIONAL_ADMINISTRADOR_SLA_5G3.md` (6), `DISENO_INTERFAZ_ADMINISTRADOR_SLA_5G3.md` (6), `CORRECCIONES_MATRIZ_SLA_5G2_1.md` (6), `DECISIONES_PENDIENTES_5G3.md` (2), `RESUMEN_EJECUTIVO_5G3.md` (2) | 26 |
| 5G.4 y 5G.4.1 | `COMPATIBILIDAD_SLA_ZAMMAD.md` (7), `PENDIENTES_ADMINISTRADOR_ZENDESK.md` (3), `ETAPA_5G_PLAN.md` (1), `ROADMAP_PRODUCCION.md` (1) | 12 |
| 5G.4.2 | `ANALISIS_ENTREGA_PRIMERA_RESPUESTA_5G4_2.md` (24), `RESUMEN_EJECUTIVO_5G4_2.md` (9), `AUDITORIA_EVENTOS_ZAMMAD_5G4_2.md` (6), `DECISIONES_PENDIENTES_5G4_2.md` (5), `CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md` (4), `ARQUITECTURA_BFF_MOTOR_SLA_5G4_2.md` (2) | 50 |
| 5G.4.3 | `DECISIONES_FUNCIONALES_MOTOR_SLA_5G4_3.md` (8), `PLAN_IMPLEMENTACION_MOTOR_SLA_5G4_3.md` (4), `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` (4), `SEGURIDAD_INTEGRACION_BFF_SLA_5G4_3.md` (2), `RESUMEN_EJECUTIVO_5G4_3.md` (2), `DISENO_CICLOS_Y_COMPROMISOS_SLA_5G4_3.md` (1) | 21 |
| **Total** | **37 documentos con menciones** | **356** |

**Nota de trazabilidad:** no existe un documento separado de 5G.4.1. Esa etapa produjo la auditoría del motor nativo, referenciada dentro de `AUDITORIA_EVENTOS_ZAMMAD_5G4_2.md` y de `COMPATIBILIDAD_SLA_ZAMMAD.md`.

### 2.2 Clasificación de las referencias

Cada mención se clasifica en una de tres categorías.

| Categoría | Definición | Tratamiento |
|---|---|---|
| **H — Histórica** | Explica el análisis ya realizado, la base estadística o por qué un canal no es comparable | **Se conserva tal cual.** No se edita. |
| **O — Operativa** | Describe reglas, eventos, columnas, sondeo o fases que ya no aplican a la implementación | **Se retira del diseño vigente.** Se reemplaza en documentos 5G.4.4. |
| **A — Afectada** | Decisión aprobada que cambia de número o de alcance, sin cambiar de criterio | **Se ajusta por anexo**, no se reescribe el original. |

---

## 3. Referencias operativas que se retiran del diseño

| Documento | Línea | Referencia | Categoría | Sustitución en 5G.4.4 |
|---|---|---:|---|---|
| `DECISIONES_FUNCIONALES_MOTOR_SLA_5G4_3.md` | 51 | PR-04 WhatsApp: cuenta con envío aceptado | O | Eliminada: no hay WhatsApp |
| idem | 52 | PR-05 `timestamp_delivered` | O | Eliminada |
| idem | 53 | PR-06 no exigir lectura | O | Eliminada (no aplica a correo) |
| idem | 57 | Advertencia sobre entrega en WhatsApp | O | Sustituida por regla de confirmación de correo |
| idem | 119 | Snapshot `channel = whatsapp / correo` | O | `channel = email` con restricción |
| idem | 138 | DP-01 criterio WhatsApp | O | Cerrada por alcance: ya no aplica |
| `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` | 225 | `delivered_at` WhatsApp | O | Columna eliminada |
| idem | 226 | `read_at` WhatsApp | O | Columna eliminada |
| idem | 69, 221 | `channel` con dos valores | A | Restringido a `email` |
| `SEGURIDAD_INTEGRACION_BFF_SLA_5G4_3.md` | 173 | Teléfono WhatsApp cifrado o hash | O | Eliminada: no se almacena |
| idem | 171 | Cuerpo de WhatsApp | O | Solo cuerpo de correo |
| `PLAN_IMPLEMENTACION_MOTOR_SLA_5G4_3.md` | 103 | Reproducir conteos 65 / WhatsApp 40/2/38 | A | Reproducir 27 políticas Email |
| idem | 136 | Criterio WhatsApp aceptación + entrega | O | Solo correo con `delivery_status = success` |
| idem | 205 | Dependencia DP-01 | O | Dependencia cerrada |
| idem | 210 | Operatividad del canal WhatsApp | O | Dependencia eliminada |
| `DISENO_CICLOS_Y_COMPROMISOS_SLA_5G4_3.md` | 114 | Ejemplo con WhatsApp 15 min | O | Ejemplo reescrito con correo 24 h |
| `DISENO_SONDEO_INCREMENTAL_ZAMMAD_5G4_3.md` | — | Frecuencia 1 min por canal crítico | O | Frecuencia única justificada en §4.4 |
| `CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md` | 186-188 | `delivered` y `read` del contrato | O | Catálogo reducido |
| `ARQUITECTURA_BFF_MOTOR_SLA_5G4_2.md` | 206 | Latencia menor a 1 min para WhatsApp | O | Eliminada |

**Regla de aplicación:** los documentos citados **no se editan**. Este anexo es el que manda para la implementación. Cualquier lector debe leer los documentos de 5G.4.4 como corrección vigente.

---

## 4. Referencias históricas que se conservan

| Documento | Contenido | Por qué se conserva |
|---|---|---|
| `ANALISIS_ESTADISTICO_RESOLUCION.md` §1 | Universo, filtros, exclusión de WHATICKET | Explica la base estadística de la que sale la matriz Email |
| idem §2-§3 | Comparación WhatsApp vs correo | Demuestra que las distribuciones no son comparables y que no se debe usar una meta común |
| idem §4.1 | Detalle WhatsApp | Evidencia de que esas metas existieron y ya no aplican |
| `AUDITORIA_DATOS_SLA_COSE.md` §5.2 | WHATICKET no comparable (5,6× mediana, 78 % sin categoría homologable) | Justificación formal de la exclusión, exigida por el encargo |
| `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` | Matriz completa de 70 filas | Fuente original de la que se extrae la matriz Email |
| `VALIDACION_ESTADISTICA_SLA_5G2_1.md` | Verificación de P75 y escalera | Demuestra la metodología aplicada |
| `CORRECCIONES_MATRIZ_SLA_5G2_1.md` | Conteo real 70 / 5 / 65 | Corrección documental que sigue siendo válida para la lectura histórica |
| `ANALISIS_ENTREGA_PRIMERA_RESPUESTA_5G4_2.md` §4 | Detalle de entrega WhatsApp | Evidencia histórica de por qué el canal no es comparable; no se implementa |
| `DECISIONES_PENDIENTES_5G3.md` | Lista de combinaciones sin evidencia | Incluye las dos de WhatsApp; se conserva como registro |

**Criterio:** borrar estas referencias destruiría la trazabilidad de por qué la matriz Email es la única oficial. Se conservan íntegras.

---

## 5. WHATICKET: justificación de exclusión (mantenida)

| Métrica (cerrados, categoría de servicio) | WHATMETA | WHATICKET |
|---|---:|---:|
| n | 13.318 | 206 |
| Mediana | 50,7 min | 286,5 min |
| P75 | 83,8 min | 1.559,7 min |
| P90 | 131,8 min | 4.773,1 min |

Motivos documentados en `AUDITORIA_DATOS_SLA_COSE.md` §5.2:

1. Diferencia de **5,6× en la mediana** frente a WHATMETA.
2. **78 %** de registros sin categoría homologable (`SIN CATEGORIA EN ORIGEN` 421, `SIN HOMOLOGAR` 331, `NO CONTESTO` 195).
3. **300 filas** con estado `SI`/`NO` no mapeable a un estado de ticket.
4. Canal en extinción, con datos de 2025-10-10 a 2026-11-13.

**Decisión:** WHATICKET queda excluido del cálculo SLA. Con el nuevo alcance, además, queda fuera por completo del proyecto: no es correo.

**Nota de coherencia:** WHATMETA también queda fuera del cálculo, pero por una razón distinta: no es el canal del alcance. Su exclusión **no** invalida la comparación histórica de §2, que es la que justificó no usar una meta común entre canales.

---

## 6. Impacto sobre la matriz

| Concepto | Antes (5G.2.1 corregido) | Ahora (5G.4.4) |
|---|---:|---:|
| Filas totales | 70 | **30** |
| Combinaciones con SLA | 65 | **27** |
| Combinaciones sin evidencia | 5 | **3** |
| Filas de WhatsApp | 40 | **0 en el alcance** (40 permanecen como histórico) |
| Tickets Email cubiertos | 2.087 | **2.087** (sin cambio) |
| Base Email con subcategoría homologada | 2.109 | **2.109** |
| Cobertura interna de la matriz Email | 98,9 % | **98,9 %** |

Los valores por fila **no cambian**. Solo cambia qué filas son oficiales para la implementación.

Detalle completo en `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md`.

---

## 7. Impacto sobre decisiones

| Decisión | Estado tras 5G.4.4 |
|---|---|
| Arquitectura de motor propio en el BFF | **Vigente** |
| Cero SLA nativos, `ignore_escalation` intacto | **Vigente** |
| Calendario 24/7, sin pausas | **Vigente** |
| Inicio en `created_at`, fin en primer `closed` | **Vigente** |
| Congelamiento al clasificar | **Vigente** |
| Reclasificación sin alterar el compromiso | **Vigente** |
| PR-01 / PR-02 (artículo público de agente; notas internas no cuentan) | **Vigente** |
| PR-03 (`delivery_status = success`) | **Vigente y ahora único criterio**, aplicado solo a correo |
| PR-04 a PR-06 (WhatsApp) | **Sin objeto** |
| REA-02 (ciclos en reapertura) | **Pendiente**, sin cambios |
| CAP-02 / CAP-03 (1 min / 5 min) | **Reemplazadas** por cadencia única justificada |
| POL-01 (65 políticas) | **Reemplazada** por 27 políticas Email |
| POL-05 (respaldos 90 min / 36 h) | **Ajustada**: solo respaldo Email de 36 h |
| DP-01 (criterio WhatsApp) | **Cerrada** por eliminación del canal |
| DP-05 (31,1 % fuera de catálogo) | **Pendiente**, y ahora requiere el dato específico de Email |
| DP-04 (responsable del catálogo) | **Pendiente**, crítica |
| DP-07 (persistencia si cae el BFF) | **Pendiente**, alta |

Detalle en `DECISIONES_PENDIENTES_EMAIL_5G4_4.md`.

---

## 8. Impacto sobre arquitectura y modelo de datos

| Elemento | Efecto |
|---|---|
| Ingesta | Solo tickets de correo del grupo de soporte |
| Detección de respuesta | Solo artículo público de agente con `delivery_status = success` |
| Eventos | Catálogo reducido: se eliminan `delivered` y `read` |
| Tablas | Se mantienen 9; se eliminan 3 columnas y se restringe un dominio |
| Sondeo | Cadencia única de 5 minutos, con banda opcional de 2 minutos |
| Seguridad | Se elimina el tratamiento de teléfono y cuerpo de WhatsApp |

Detalle en `ARQUITECTURA_MOTOR_SLA_EMAIL_5G4_4.md`.

---

## 9. Riesgo de la corrección

| Riesgo | Nivel | Mitigación |
|---|---|---|
| Documentos antiguos siguen citando WhatsApp y alguien los toma como vigentes | Medio | Este anexo declara la precedencia; el resumen ejecutivo lo repite |
| La matriz Email tiene 27 filas y menor base que la de 65 | Medio | Se documenta la cobertura real (2.087 de 2.109) y el respaldo de 36 h |
| El respaldo de 36 h se aplica a un volumen fuera de catálogo cuyo tamaño en Email no está medido | Alto | Se marca como pendiente DP-05-E; no se inventa el número |
| Confusión entre "aceptado por SMTP" y "entregado en buzón" | Alto | Se documenta explícitamente qué prueba `delivery_status = success` |
| Pérdida de trazabilidad si se editaran los documentos originales | Alto | Prohibido editar; solo anexos nuevos |

---

## 10. Confirmación

Esta corrección es documental. No se modificó código, base de datos, configuración de Zammad, calendarios, SLA nativos, triggers, webhooks, usuarios, permisos, buzones, credenciales, Zendesk ni COSE. No se inició ningún worker ni servicio. No se sobrescribió ningún documento anterior.
