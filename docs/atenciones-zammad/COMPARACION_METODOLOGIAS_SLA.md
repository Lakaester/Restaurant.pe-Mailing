# COMPARACIÓN DE METODOLOGÍAS PARA FIJAR EL SLA

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2.1
**Fecha:** 16/11/2026
**Base:** 65 combinaciones con n ≥ 10 · 10.711 tickets · ventana 2026-04-01 → 2026-10-31

---

## 1. Resumen

Se compararon tres estadísticos como posible referencia del SLA de resolución:

| Alternativa | SLA = | Cumplimiento histórico esperado |
|---|---|---:|
| **Promedio histórico** | media aritmética | **73,53 %** |
| **Percentil 75** | P75 | **74,95 %** |
| **Percentil 90** | P90 | **89,81 %** |
| **Propuesta final** | P75 redondeado a escalera | **81,40 %** |

> El promedio produce **menos cumplimiento que el P75**, porque la cola lo empuja por encima del percentil 75. Es un resultado contraintuitivo y decisivo: usar el promedio no es "más holgado", es **peor en cobertura y además impredecible**.

---

## 2. Definición de cada alternativa

### 2.1 Promedio histórico

$$\text{SLA} = \bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$$

**Qué promete:** que el ticket promedio se resuelva en ese tiempo.

**Problema estructural:** en distribuciones de cola pesada, el promedio se desplaza hacia los valores extremos. Un solo ticket de 20.000 minutos en una muestra de 300 sube el promedio varios minutos.

**Evidencia de esta base:**

- La desviación estándar supera al promedio en ambos canales.
- El promedio es hasta **4,52×** el P75 en una misma combinación (WhatsApp / Error punto de venta: media 309 min, P75 68 min).
- En 12 combinaciones el CV es ≥ 2,0.

### 2.2 Percentil 75

$$P_{75} = \text{valor bajo el cual cae el 75 \% de los tickets}$$

**Qué promete:** 3 de cada 4 tickets se resuelven en ese tiempo o menos.

**Ventaja:** es robusto frente a la cola; no lo mueve un caso extremo. Es el punto donde la operación ya demuestra un desempeño consistente.

**Límite:** no distingue entre una distribución compacta y una dispersa; por eso se acompaña siempre de P90 y CV.

### 2.3 Percentil 90

$$P_{90} = \text{valor bajo el cual cae el 90 \% de los tickets}$$

**Qué promete:** 9 de cada 10 tickets se resuelven en ese tiempo o menos.

**Ventaja:** es la meta más exigente y la que mejor refleja el extremo operativo razonable.

**Límite:** equivale a **fijar como objetivo que el 10 % incumpla siempre**. Además, en colas largas el P90 se dispara y produce metas poco útiles (por ejemplo, 120 horas en Requisitos FE de correo).

---

## 3. Resultado comparado

### 3.1 Global (ponderado por tickets)

| Método | SLA aplicado | Tickets que habrían cumplido | Incumplirían |
|---|---:|---:|---:|
| Promedio | media de cada combinación | 7.876 | 2.835 (26,5 %) |
| P75 | P75 de cada combinación | 8.028 | 2.683 (25,0 %) |
| P90 | P90 de cada combinación | 9.620 | 1.091 (10,2 %) |
| **Final (P75 + escalera)** | valores de la matriz | **8.719** | **1.992 (18,6 %)** |

### 3.2 Por canal

| Método | WhatsApp | Correo |
|---|---:|---:|
| Promedio | 74,25 % | 70,58 % |
| P75 | 74,97 % | 74,89 % |
| P90 | 89,85 % | 89,60 % |
| **Final** | **81,66 %** | **80,36 %** |

**Observación:** en correo el promedio rinde **4,3 puntos menos** que el P75. Es el canal donde la cola es más dañina.

### 3.3 Cuánto se separan las tres referencias

| Relación | Combinaciones | Comentario |
|---|---:|---|
| Media / P75 < 1,5 | 41 | Las tres alternativas son cercanas |
| Media / P75 entre 1,5 y 2,5 | 18 | El promedio empieza a despegarse |
| Media / P75 > 2,5 | 6 | El promedio es inservible como meta |

Casos extremos:

| Canal | Subcategoría | n | Media | P75 | P90 | Media/P75 |
|---|---|---:|---:|---:|---:|---:|
| WhatsApp | Error punto de venta | 293 | 309 | 68 | 128 | **4,52** |
| WhatsApp | Caída del servidor | 49 | 169 | 56 | 591 | **3,03** |
| WhatsApp | Solicitud integración Pedidos Ya | 165 | 233 | 118 | 207 | **1,97** |
| WhatsApp | Venta de CDT certificado | 157 | 139 | 77 | 119 | **1,81** |
| WhatsApp | Renovación certificado normal | 312 | 115 | 71 | 101 | **1,62** |

---

## 4. Ventajas y desventajas

### 4.1 Promedio

| Ventajas | Desventajas |
|---|---|
| Es intuitivo y fácil de explicar | Se distorsiona con un solo caso extremo |
| Usa toda la muestra | No representa al ticket típico (la mediana sí) |
| — | En esta base rinde **menos** que el P75 (73,5 % vs 75,0 %) |
| — | Obliga a metas muy altas en combinaciones con cola: hasta 4,5× el P75 |
| — | Es inestable: cambia mucho entre períodos |

**Veredicto: descartado como criterio principal.** Se conserva solo como dato descriptivo.

### 4.2 Percentil 75

| Ventajas | Desventajas |
|---|---|
| Robusto frente a atípicos | No refleja la cola (el 25 % restante queda fuera) |
| Representa el desempeño habitual | Puede ser poco exigente si la distribución es muy compacta |
| Estable entre períodos | Requiere acompañarse de P90 y CV para no ocultar dispersión |
| Cumplimiento esperado conocido (~75 %) | — |

**Veredicto: adoptado como ancla.**

### 4.3 Percentil 90

| Ventajas | Desventajas |
|---|---|
| Meta exigente | **Acepta por diseño un 10 % de incumplimiento** |
| Cubre la cola razonable | Se dispara en distribuciones de cola pesada (hasta 120 h) |
| Útil como referencia de techo | Difícil de defender ante el negocio: "el 10 % siempre incumple" |

**Veredicto: no se usa como meta, sí como referencia de techo y control.**

---

## 5. Metodología final propuesta

### 5.1 Regla

```
SLA = menor valor de la escalera ≥ P75 de la combinación
```

Escalera: `15 · 30 · 45 · 60 · 90 · 120 · 180 · 240 · 360 · 480 · 720 · 1440 · 2160 · 2880 · 4320 · 5760 · 7200` minutos.

### 5.2 Por qué redondear hacia arriba y no usar el P75 exacto

| Razón | Explicación |
|---|---|
| Operabilidad | Un SLA de "1 h 47 min" no es gestionable ni auditable |
| Comunicación | El equipo entiende y recuerda valores cerrados |
| Configuración | Zammad almacena minutos enteros y el calendario opera en franjas |
| Efecto | El redondeo sube la meta y eleva el cumplimiento de 75,0 % a **81,4 %** |

### 5.3 Reglas complementarias

| Regla | Descripción |
|---|---|
| R1 | El SLA nunca queda por debajo de la mediana |
| R2 | El SLA no se calcula con datos de otra combinación |
| R3 | Con n < 10 no hay SLA |
| R4 | Se reporta siempre P90 y CV junto a la meta |
| R5 | CV ≥ 2,0 obliga a revisión a 90 días aunque n sea alto |
| R6 | El promedio se reporta, nunca decide |

### 5.4 Distribución resultante de metas

| SLA propuesto | Combinaciones |
|---|---:|
| 45 min | 1 |
| 1 h | 2 |
| 1 h 30 min | 18 |
| 2 h | 15 |
| 3 h | 2 |
| 24 h | 7 |
| 36 h | 6 |
| 48 h | 5 |
| 72 h | 6 |
| 96 h | 2 |
| 120 h | 1 |
| **Total** | **65** |

---

## 6. Sensibilidad: qué pasaría con las otras alternativas

### 6.1 Si se usara el promedio

- WhatsApp: metas de 60 a 309 min (contra 45–180 del P75).
- Correo: metas de 660 a 4.668 min.
- Cumplimiento esperado: 73,5 %.
- Riesgo: metas que **cambian fuerte** con un solo ticket extremo entre períodos.

### 6.2 Si se usara el P90

- WhatsApp: metas de 56 a 591 min.
- Correo: metas de 1.438 a 14.584 min (hasta 10 días).
- Cumplimiento esperado: 89,8 %.
- Riesgo: metas tan amplias que dejan de ser exigentes; el equipo podría "cumplir" sin mejorar.

### 6.3 Con la propuesta final (P75 + escalera)

- WhatsApp: 45 min a 3 h.
- Correo: 24 h a 120 h.
- Cumplimiento esperado: **81,4 %**.
- Equilibrio: más exigente que el promedio, más alcanzable que el P90, y estable frente a atípicos.

---

## 7. Advertencia sobre la comparación con horas hábiles

Todos estos porcentajes se calculan sobre **tiempo calendario**. Zammad mide en **tiempo hábil** según el calendario `Soporte Especializado`.

La comparación entre metodologías es válida entre sí (todas en la misma unidad), pero **los valores absolutos no son directamente trasladables** a una política de Zammad. Ver `OBSERVACIONES_Y_DECISIONES_PENDIENTES_5G2_1.md` §2.

---

## 8. Conclusión

1. El **promedio** no sirve como meta: rinde menos que el P75 y es inestable.
2. El **P90** no sirve como meta: consagra un 10 % de incumplimiento y produce valores inoperantes.
3. El **P75 redondeado** entrega el mejor equilibrio: 81,4 % de cumplimiento esperado, metas legibles y estabilidad ante atípicos.
4. La decisión de exigir formalmente un umbral de cumplimiento (75 %, 85 % o 90 %) sigue abierta y corresponde a Victor.
5. La conversión a horas hábiles es una decisión separada que **no se aplicó** en esta etapa.
