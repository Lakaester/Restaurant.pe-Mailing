# MATRIZ Y PROPUESTA DE SLA DE RESOLUCIÓN

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2 — Fase F
**Fecha:** 14/11/2026
**Base:** `ANALISIS_ESTADISTICO_RESOLUCION.md` (ventana 2026-04-01 → 2026-10-31)
**Naturaleza:** propuesta analítica. **No se creó ningún SLA en Zammad.**

---

## 1. Metas de primera respuesta (fijas, no recalculadas)

| Canal | Meta aprobada |
|---|---|
| WhatsApp | **< 15 minutos** |
| Correo electrónico | **< 24 horas** |

Estas metas **no dependen** de categoría ni subcategoría y **no se modifican** en esta etapa. No se calcularon percentiles de primera respuesta ni se proponen objetivos alternativos.

---

## 2. Metodología de la propuesta de resolución

### 2.1 Ancla: P75, no el promedio ni el P90

Se usa el **percentil 75** como ancla porque:

- El promedio está dominado por la cola (en correo triplica la mediana) y produciría metas incumplibles.
- El P90 es el límite de la peor décima parte: fijarlo como meta equivale a "aceptar que el 10 % incumpla siempre", lo que la instrucción prohíbe como copia automática.
- El P75 representa el desempeño que la operación ya demuestra en 3 de cada 4 casos: **exigente pero alcanzable**.

### 2.2 Escalera operativa

El P75 se redondea **hacia arriba** al siguiente valor de una escalera cerrada, para que las metas sean legibles y auditables en Zammad:

`30 · 45 · 60 · 90 · 120 · 180 · 240 · 360 · 480 · 720 · 1440 · 2160 · 2880 · 4320 · 5760 · 7200` minutos

(30 min, 45 min, 1 h, 1,5 h, 2 h, 3 h, 4 h, 6 h, 8 h, 12 h, 24 h, 36 h, 48 h, 72 h, 96 h, 120 h)

### 2.3 Reglas de aplicación

| Regla | Descripción |
|---|---|
| R1 | Si n ≥ 30, la meta se calcula sobre la **subcategoría**. |
| R2 | Si 10 ≤ n < 30, la meta se calcula sobre la **categoría** agrupada y se marca como agregada. |
| R3 | Si n < 10, **no se propone SLA**. |
| R4 | La meta nunca queda por debajo de la mediana. |
| R5 | La meta no se toma de otro canal ni de otra categoría. |
| R6 | No se usa el promedio como criterio. |
| R7 | Los atípicos se conservan; su efecto se controla con percentiles. |
| R8 | Las pseudo-categorías (SIN HOMOLOGAR, DUPLICADO, NO CONTESTO, ADD ONS, SIN CATEGORÍA) no reciben SLA. |

### 2.4 Cumplimiento histórico

La columna "Cumple" indica qué porcentaje de los tickets históricos habría cumplido la meta propuesta. Al anclar en P75 y redondear hacia arriba, el valor esperado ronda **75–88 %**. Fijar la política de cumplimiento exigida (por ejemplo ≥ 85 %) es una decisión pendiente (D-05).

### 2.5 Los valores están en minutos calendario, no en horas hábiles

Los tiempos históricos de COSE son **tiempo calendario** (diferencia entre marcas de tiempo, sin calendario ni pausas). Zammad, en cambio, mide el SLA en **tiempo hábil** según el calendario asignado.

El calendario ID 2 cubre 92 de 168 horas semanales (54,8 %). Por tanto, configurar estos mismos números con el calendario 2 hace la meta **~1,83× más holgada** en tiempo de reloj.

Ejemplo: 90 min calendario ≈ 164 min de reloj si se aplican horas hábiles.

**Ninguna de las metas de este documento debe publicarse sin resolver antes la decisión D-03.**

---

## 3. Matriz propuesta — WhatsApp

Canal de referencia: **WHATMETA**. Base: 8.641 tickets cerrados con subcategoría oficial.

| Categoría | Subcategoría | Tickets | Mediana | P75 | P90 | Confianza | SLA propuesto | Cumple |
|---|---|---:|---:|---:|---:|---|---:|---:|
| OPERATIVO | Temas operativos | 1.063 | 36 min | 63 | 102 | ALTA | **1 h 30 min** | 87,3 % |
| FACTURACIÓN | Ajustes FE | 1.075 | 51 min | 80 | 123 | ALTA | **1 h 30 min** | 80,9 % |
| LOGÍSTICA | Capacitación logística avanzado | 859 | 57 min | 86 | 122 | ALTA | **1 h 30 min** | 77,4 % |
| GESTIÓN | Seguimiento proactivo | 473 | 40 min | 76 | 123 | ALTA | **1 h 30 min** | 82,5 % |
| CAPACITACIÓN | Capacitación integraciones | 454 | 61 min | 107 | 161 | ALTA | **2 h** | 81,1 % |
| CAPACITACIÓN | Solicitud agenda capacitación | 432 | 63 min | 98 | 146 | ALTA | **2 h** | 84,0 % |
| GESTIÓN | Envío de pago | 386 | 33 min | 57 | 101 | ALTA | **1 h** | 76,2 % |
| FACTURACIÓN | Validación de comprobantes FE | 329 | 51 min | 82 | 118 | ALTA | **1 h 30 min** | 81,2 % |
| GESTIÓN | Renovación certificado normal | 312 | 47 min | 71 | 101 | ALTA | **1 h 30 min** | 84,9 % |
| LOGÍSTICA | Capacitación logística insumos recetas | 298 | 56 min | 86 | 127 | ALTA | **1 h 30 min** | 78,5 % |
| SOFTWARE | Error punto de venta | 293 | 36 min | 68 | 128 | ALTA | **1 h 30 min** | 80,2 % |
| INTEGRACIONES | Solicitud integración Rappi | 280 | 61 min | 106 | 176 | ALTA | **2 h** | 82,1 % |
| SOFTWARE | Seguimiento de errores | 241 | 59 min | 106 | 154 | ALTA | **2 h** | 82,6 % |
| CAPACITACIÓN | Capacitación adm Productos | 199 | 54 min | 87 | 129 | ALTA | **1 h 30 min** | 75,9 % |
| CAPACITACIÓN | Capacitación adm Reportes | 190 | 51 min | 77 | 108 | ALTA | **1 h 30 min** | 83,2 % |
| INTEGRACIONES | Solicitud integración Pedidos Ya | 165 | 66 min | 118 | 207 | ALTA | **2 h** | 75,8 % |
| GESTIÓN | Venta de CDT certificado | 157 | 51 min | 77 | 119 | ALTA | **1 h 30 min** | 81,5 % |
| ADMINISTRATIVO | Nueva licencia o sucursal | 133 | 41 min | 64 | 110 | ALTA | **1 h 30 min** | 85,0 % |
| FACTURACIÓN | Cambio de razón social | 132 | 63 min | 97 | 133 | ALTA | **2 h** | 86,4 % |
| FACTURACIÓN | Activación FE | 119 | 61 min | 100 | 176 | ALTA | **2 h** | 81,5 % |
| FACTURACIÓN | Error FE envío manual | 119 | 40 min | 62 | 93 | ALTA | **1 h 30 min** | 87,4 % |
| FACTURACIÓN | Requisitos FE | 102 | 56 min | 82 | 104 | ALTA | **1 h 30 min** | 84,3 % |
| ADMINISTRATIVO | Solicitud de migración | 85 | 71 min | 113 | 144 | MEDIA | **2 h** | 81,2 % |
| INTEGRACIONES | Consulta consumo de APIs | 80 | 53 min | 72 | 104 | MEDIA | **1 h 30 min** | 86,3 % |
| FACTURACIÓN | Error FE del facturador | 75 | 70 min | 105 | 163 | MEDIA | **2 h** | 78,7 % |
| CAPACITACIÓN | Capacitación operativa | 71 | 45 min | 74 | 136 | MEDIA | **1 h 30 min** | 77,5 % |
| FACTURACIÓN | Error FE de cálculo | 66 | 79 min | 113 | 166 | MEDIA | **2 h** | 75,8 % |
| FACTURACIÓN | Consecutivos topes folios | 57 | 44 min | 68 | 98 | MEDIA | **1 h 30 min** | 86,0 % |
| FACTURACIÓN | Error FE por duplicidad | 51 | 79 min | 108 | 151 | MEDIA | **2 h** | 86,3 % |
| SOFTWARE | Error add-on asistencias | 51 | 62 min | 98 | 142 | MEDIA | **2 h** | 82,4 % |
| INTEGRACIONES | Error integración | 49 | 73 min | 100 | 157 | MEDIA | **2 h** | 79,6 % |
| LOGÍSTICA | Error logística | 49 | 89 min | 118 | 193 | MEDIA | **2 h** | 75,5 % |
| SERVIDOR | Caída del servidor | 49 | 41 min | 56 | 591 | MEDIA | **1 h** | 75,5 % |
| FACTURACIÓN | Emisión de invoice | 48 | 44 min | 66 | 97 | MEDIA | **1 h 30 min** | 87,5 % |
| SOFTWARE | Error web | 26 | 48 min | 94 | 152 | BAJA (agregado a categoría) | **2 h** | 84,9 % |
| INTEGRACIONES | Solicitud integración Uber | 24 | 61 min | 104 | 174 | BAJA (agregado a categoría) | **2 h** | 81,0 % |
| FACTURACIÓN | FE solicitud XML/PDF | 20 | 53 min | 84 | 126 | BAJA (agregado a categoría) | **1 h 30 min** | 78,7 % |
| INTEGRACIONES | Integración sistemas contables | 12 | 61 min | 104 | 174 | BAJA (agregado a categoría) | **2 h** | 81,0 % |
| FACTURACIÓN | Activación NV | 9 | — | — | — | INSUFICIENTE | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | — |
| DEVOLUCIÓN | Solicitud de devolución | 8 | — | — | — | INSUFICIENTE | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | — |

**SLA general de respaldo WhatsApp:** **1 h 30 min** (n = 8.641, mediana 50, P75 84, P90 131; cumplimiento 78,2 %).

> **Observación:** en WhatsApp la diferenciación por subcategoría aporta poco: 37 de 39 combinaciones caen en 1 h, 1 h 30 min o 2 h. Se recomienda **una sola política WhatsApp de 2 h con excepción de 1 h para Envío de pago**, en lugar de 39 políticas. Ver `DECISIONES_PENDIENTES_SLA.md` D-06.

---

## 4. Matriz propuesta — Correo

Base: 2.109 tickets cerrados con subcategoría oficial.

| Categoría | Subcategoría | Tickets | Mediana | P75 | P90 | Confianza | SLA propuesto | Cumple |
|---|---|---:|---:|---:|---:|---|---:|---:|
| FACTURACIÓN | Ajustes FE | 341 | 171 min | 1.111 | 2.585 | ALTA | **24 h** | 83,9 % |
| LOGÍSTICA | Tarea o capacitación logística | 319 | 1.071 min | 2.837 | 5.962 | ALTA | **48 h** | 76,2 % |
| GESTIÓN | Renovación certificado normal | 177 | 194 min | 1.024 | 1.561 | ALTA | **24 h** | 85,3 % |
| FACTURACIÓN | Cambio de razón social | 170 | 955 min | 2.996 | 6.048 | ALTA | **72 h** | 81,8 % |
| OPERATIVO | Temas operativos | 119 | 1.028 min | 2.718 | 5.534 | ALTA | **48 h** | 77,3 % |
| CAPACITACIÓN | Solicitud agenda capacitación | 115 | 1.181 min | 3.055 | 5.504 | ALTA | **72 h** | 81,7 % |
| FACTURACIÓN | Activación FE | 94 | 356 min | 2.632 | 7.241 | MEDIA | **48 h** | 75,5 % |
| INTEGRACIONES | Consulta consumo de APIs | 83 | 536 min | 2.597 | 4.900 | MEDIA | **48 h** | 80,7 % |
| GESTIÓN | Venta de CDT certificado | 81 | 1.198 min | 1.698 | 5.720 | MEDIA | **36 h** | 77,8 % |
| FACTURACIÓN | Validación de comprobantes FE | 67 | 220 min | 1.818 | 6.647 | MEDIA | **36 h** | 77,6 % |
| FACTURACIÓN | Requisitos FE | 60 | 1.387 min | 5.921 | 8.995 | MEDIA | **120 h** | 86,7 % |
| GESTIÓN | Envío de pago | 45 | 231 min | 1.233 | 2.728 | MEDIA | **24 h** | 77,8 % |
| FACTURACIÓN | Error FE del facturador | 38 | 246 min | 780 | 1.823 | MEDIA | **24 h** | 86,8 % |
| DEVOLUCIÓN | Solicitud de devolución | 37 | 1.349 min | 3.075 | 6.385 | MEDIA | **72 h** | 83,8 % |
| SOFTWARE | Error punto de venta | 37 | 860 min | 1.935 | 3.277 | MEDIA | **36 h** | 75,7 % |
| FACTURACIÓN | Error FE de cálculo | 36 | 1.515 min | 2.972 | 7.145 | MEDIA | **72 h** | 83,3 % |
| ADMINISTRATIVO | Nueva licencia o sucursal | 35 | 219 min | 1.161 | 1.438 | MEDIA | **24 h** | 88,6 % |
| SOFTWARE | Seguimiento de errores | 34 | 1.007 min | 1.404 | 2.797 | MEDIA | **24 h** | 73,5 % |
| GESTIÓN | Seguimiento proactivo | 33 | 252 min | 1.398 | 2.802 | MEDIA | **24 h** | 75,8 % |
| FACTURACIÓN | Emisión de invoice | 28 | 314 min | 1.600 | 5.354 | BAJA (agregado a categoría) | **36 h** | 79,5 % |
| ADMINISTRATIVO | Solicitud de migración | 27 | 818 min | 1.754 | 4.330 | BAJA (agregado a categoría) | **36 h** | 79,0 % |
| INTEGRACIONES | Solicitud integración Rappi | 25 | 986 min | 2.815 | 5.857 | BAJA (agregado a categoría) | **48 h** | 77,0 % |
| CAPACITACIÓN | Capacitación adm Reportes | 21 | 1.094 min | 2.940 | 5.300 | BAJA (agregado a categoría) | **72 h** | 83,1 % |
| LOGÍSTICA | Error logística | 20 | 1.123 min | 2.891 | 6.661 | BAJA (agregado a categoría) | **72 h** | 83,5 % |
| FACTURACIÓN | Error FE envío manual | 19 | 314 min | 1.600 | 5.354 | BAJA (agregado a categoría) | **36 h** | 79,5 % |
| INTEGRACIONES | Solicitud integración Pedidos Ya | 14 | 986 min | 2.815 | 5.857 | BAJA (agregado a categoría) | **48 h** | 77,0 % |
| SOFTWARE | Error web | 12 | 982 min | 2.308 | 3.718 | BAJA (agregado a categoría) | **48 h** | 79,5 % |
| FACTURACIÓN | Error FE por duplicidad | 9 | — | — | — | INSUFICIENTE | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | — |
| INTEGRACIONES | Integración sistemas contables | 9 | — | — | — | INSUFICIENTE | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | — |
| INTEGRACIONES | Error integración | 4 | — | — | — | INSUFICIENTE | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | — |

**SLA general de respaldo Correo:** **36 h** (n = 2.109, mediana 506, P75 1.783, P90 5.261; cumplimiento 79,0 %).

> **Observación:** "Requisitos FE" concentra la mayor dispersión (P75 5.921 min, P90 8.995 min) y arrastra su meta a 120 h. Es un caso con dependencia externa probable (documentos del cliente / ente regulador) que debe revisarse antes de publicarlo (D-07).

---

## 5. Resumen cuantitativo

| Canal | Combinaciones con SLA | Sin SLA (insuficiente) | Tickets cubiertos | SLA de respaldo |
|---|---:|---:|---:|---:|
| WhatsApp | 37 | 2 | 8.641 | 1 h 30 min |
| Correo | 28 | 3 | 2.109 | 36 h |
| **Total** | **65** | **5** | **10.750** | — |

**Cobertura de la propuesta:** 10.750 de 15.591 tickets de servicio en la ventana = **68,9 %**.

El **31,1 % restante** (4.841 tickets) no puede recibir SLA por subcategoría porque su etiqueta no existe en el catálogo oficial. Para ese volumen se propone:

| Tratamiento | Descripción |
|---|---|
| A | Aplicar el SLA de respaldo del canal (1 h 30 min WhatsApp / 36 h correo) |
| B | Revisar el catálogo de subcategorías antes de publicar (recomendado) |

---

## 6. Advertencias explícitas

1. **Las metas son una propuesta analítica, no una decisión de negocio.** Requieren aprobación de Victor.
2. **No se copió ningún valor del documento general de SLA de Zendesk** ni de `SLA_MINUTOS` de COSE (120 min / 1440 min, marcados como provisionales).
3. **Los valores dependen del período 2026-04-01 → 2026-10-31.** Si la operación cambia, deben recalcularse.
4. **No se propone SLA para combinaciones con n < 10.**
5. **No se usaron categorías de otro canal para rellenar faltantes.** Las agregaciones se hicieron siempre dentro del mismo canal.
6. **La primera respuesta no se recalculó.**
7. **El SLA de WhatsApp aplica al canal**, pero la evidencia proviene solo de WHATMETA; WHATICKET no se usó como base.

---

## 7. Traducción a minutos para Zammad

Zammad almacena los tiempos en **minutos enteros** (`first_response_time`, `solution_time`).

| Meta | Minutos |
|---|---:|
| WhatsApp primera respuesta | 15 |
| Correo primera respuesta | 1.440 |
| WhatsApp resolución (respaldo) | 90 |
| WhatsApp resolución (Envío de pago) | 60 |
| WhatsApp resolución (resto) | 120 |
| Correo resolución (respaldo) | 2.160 |
| Correo 24 h | 1.440 |
| Correo 36 h | 2.160 |
| Correo 48 h | 2.880 |
| Correo 72 h | 4.320 |
| Correo 120 h | 7.200 |
