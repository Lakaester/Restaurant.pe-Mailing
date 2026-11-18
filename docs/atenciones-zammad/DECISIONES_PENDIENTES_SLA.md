# DECISIONES PENDIENTES DE SLA

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2
**Fecha:** 14/11/2026
**Aprobador:** Victor
**Estado:** ninguna de estas decisiones está tomada. La propuesta de `MATRIZ_PROPUESTA_SLA_RESOLUCION.md` no debe implementarse hasta que se resuelvan.

---

## Resumen

| ID | Decisión | Bloquea | Prioridad |
|---|---|---|---|
| D-01 | Ventana de referencia del SLA | Recalcular metas | **Alta** |
| D-02 | Tratamiento de Zendesk sin correo | Aplicación de la meta de 24 h | **Alta** |
| D-03 | Tiempo calendario vs. tiempo hábil | Todos los valores | **Crítica** |
| D-04 | Uso del calendario ID 2 sin feriados | Cálculo de vencimientos | **Crítica** |
| D-05 | Política de cumplimiento exigida | Diseño de la meta | Alta |
| D-06 | Granularidad: 65 políticas vs. 19 | Arquitectura de SLA | Alta |
| D-07 | Casos con dependencia externa | Metas de FE y migraciones | Media |
| D-08 | Estados que pausan el SLA | Comportamiento del reloj | **Crítica** |
| D-09 | Tratamiento de WHATICKET | Base histórica | Media |
| D-10 | Catálogo de subcategorías incompleto | 31 % del volumen | **Alta** |
| D-11 | Precedencia y nomenclatura de políticas | Orden de aplicación | Alta |
| D-12 | Revisión periódica de metas | Vigencia | Baja |

---

## D-01 — Ventana de referencia del SLA

**Situación.** Los datos disponibles van del 2025-10-10 al 2026-11-14 (13 meses). Febrero y marzo de 2026 son meses de arranque con medianas anómalas (8.771 min y 146 min frente a ~55–66 min del resto). Noviembre está incompleto.

**Opciones.**

| Opción | Ventana | Consecuencia |
|---|---|---|
| A | 2026-04-01 → 2026-10-31 | 7 meses estables. Es la usada en esta etapa |
| B | 2026-03-17 → 2026-11-14 | Incluye arranque; metas más laxas |
| C | 2026-06-01 → 2026-10-31 | 5 meses; muestras más pequeñas, más combinaciones insuficientes |

**Recomendación:** **A**.

**Decisión requerida:** confirmar la ventana. Si se elige otra, toda la matriz debe recalcularse.

---

## D-02 — Tratamiento de Zendesk sin correo

**Situación.** 1.091 de 5.663 registros de Zendesk (19,3 %) no tienen valor en `correo`. La tabla no tiene campo de canal ni de origen, por lo que la naturaleza de correo de esos tickets **no está demostrada**.

**Opciones.**

| Opción | Descripción | Efecto |
|---|---|---|
| A | Aplicar la meta de 24 h solo a registros con `correo` no nulo | Cumple el criterio de "correo demostrado"; 4.572 tickets |
| B | Aplicar la meta a todo Zendesk | Asume equivalencia no demostrada |
| C | Clasificar los 1.091 como "canal no homologado" y excluirlos de SLA | Más conservador; requiere flujo de reclasificación |

**Recomendación:** **A** para primera respuesta; **C** para resolución hasta validar el origen.

**Decisión requerida:** confirmar.

---

## D-03 — Tiempo calendario vs. tiempo hábil (crítica)

**Situación.** Las metas propuestas están calculadas en **tiempo calendario**. Zammad mide el SLA en **tiempo hábil** según el calendario de la política. El calendario ID 2 cubre 92 de 168 horas semanales.

Un SLA de 90 min en horas hábiles equivale a ~164 min de reloj para un ticket creado en día laborable.

**Opciones.**

| Opción | Descripción | Efecto sobre la exigencia |
|---|---|---|
| A | Publicar los valores calendario y usar calendario 2 | Meta ~1,83× más laxa |
| B | Escalar los valores × 92/168 antes de publicar | Mantiene la exigencia histórica |
| C | Asociar un calendario 24/7 al SLA | Mantiene la exigencia; ignora el horario real |
| D | Recalcular percentiles en tiempo hábil | Requiere datos que no existen hoy |

**Recomendación:** **B** para resolución, manteniendo el calendario 2 como calendario operativo. Para primera respuesta, revisar por separado: 15 min de WhatsApp con horas hábiles puede vencer antes de que abra el turno.

> **Riesgo específico:** un ticket de WhatsApp creado a las 22:50 tiene solo 10 minutos hábiles antes de las 23:00; el SLA de 15 min vencería al día siguiente a las 09:05. Esto puede ser deseable o no, pero **debe decidirse**.

**Decisión requerida:** elegir opción A, B, C o D, y definir el comportamiento para primera respuesta.

---

## D-04 — Uso del calendario ID 2 sin feriados

**Situación.** El calendario `Soporte Especializado` no tiene feriados definidos. Mientras no los tenga, los feriados cuentan como tiempo hábil y los vencimientos se calculan mal en esas fechas.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Publicar SLA sin feriados y aceptar el desvío |
| B | Definir el calendario de feriados de Perú antes de publicar |
| C | Publicar y añadir feriados de forma incremental |

**Recomendación:** **B** antes de producción; **A** solo para piloto controlado.

**Decisión requerida:** confirmar si se cargan feriados y quién los mantiene. **No se creó ningún feriado en esta etapa.**

---

## D-05 — Política de cumplimiento exigida

**Situación.** Las metas ancladas en P75 tienen un cumplimiento histórico del 73–88 %. No se ha definido qué porcentaje de cumplimiento se exige.

**Opciones.**

| Opción | Meta de cumplimiento | Efecto |
|---|---|---|
| A | ≥ 75 % | Coherente con P75; poco exigente |
| B | ≥ 85 % | Exigente; requeriría operar mejor que hoy en varios bloques |
| C | ≥ 90 % | Equivale a fijar el SLA en P90; contradice el criterio acordado |

**Recomendación:** **B**, con revisión a los 90 días.

**Decisión requerida:** fijar el umbral y el período de gracia inicial.

---

## D-06 — Granularidad: 65 políticas vs. 19

**Situación.** En WhatsApp, 37 de 39 combinaciones caen en 1 h, 1 h 30 min o 2 h. En correo la dispersión es real (medianas de 278 a 1.349 min).

Zammad aplica **una sola política por ticket** y resuelve superposiciones por **orden alfabético del nombre**.

**Opciones.**

| Opción | Políticas | Ventaja | Riesgo |
|---|---:|---|---|
| A | 65 (todas las subcategorías) | Fidelidad total | Precedencia frágil; mantenimiento alto |
| B | 19 (canal × categoría) | Mantenible | Pierde matices |
| C | 3 núcleo + excepciones justificadas | Simple y suficiente | Requiere criterio de excepción |
| D | 2 (una por canal) | Mínimo riesgo | No diferencia resolución |

**Recomendación:** **C**. Núcleo de 3 políticas + excepciones solo donde la diferencia con el respaldo supere el 50 % y n ≥ 30.

**Decisión requerida:** elegir A, B, C o D.

---

## D-07 — Casos con dependencia externa

**Situación.** Algunas combinaciones tienen dispersión extrema que sugiere dependencia de terceros:

| Canal | Categoría | Subcategoría | P75 | P90 | Máx |
|---|---|---|---:|---:|---:|
| Correo | FACTURACIÓN | Requisitos FE | 5.921 | 8.995 | 24.424 |
| Correo | LOGÍSTICA | Error logística | 4.636 | 14.584 | 21.566 |
| Correo | ADMINISTRATIVO | Solicitud de migración | 4.271 | 5.625 | 8.375 |
| WhatsApp | SERVIDOR | Caída del servidor | 56 | 591 | 2.678 |

La propuesta asignó 120 h a Requisitos FE solo porque el P75 es alto. **No hay evidencia en los datos de la causa** (cliente, ente regulador, proveedor).

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Aceptar la meta derivada del P75 |
| B | Separar estos casos como "en espera de terceros" y excluirlos del reloj de SLA |
| C | Dejarlos sin SLA hasta caracterizar la dependencia |

**Recomendación:** **C** para Requisitos FE y Error logística; **B** para Caída del servidor.

**Decisión requerida:** definir qué casos tienen espera legítima por terceros.

---

## D-08 — Estados que pausan el SLA (crítica)

**Situación.** En Zammad la pausa no se configura en el SLA, sino en el **estado**: todo estado con `ignore_escalation = true` excluye ese período del tiempo hábil. Los datos históricos de COSE **no registran pausas**, así que las metas calculadas incluyen el tiempo en espera.

**Opciones.**

| Opción | Descripción | Efecto |
|---|---|---|
| A | Sin estados de pausa | El reloj corre siempre; coincide con los datos históricos |
| B | Pausar en `pendiente` | SLA más exigente en tiempo efectivo; rompe comparabilidad |
| C | Pausar solo en espera de terceros | Requiere clasificación fiable |

**Recomendación:** **A** al inicio, para que el SLA sea comparable con la historia; evaluar B/C después de 90 días.

**Decisión requerida:** qué estados tendrán `ignore_escalation`.

---

## D-09 — Tratamiento de WHATICKET

**Situación.** WHATICKET aporta 1.360 registros (5,5 % del total) con mediana de 286,5 min frente a 50,7 min de WHATMETA. Es una herramienta legada con 78 % de registros sin categoría homologable y 300 filas con estado `SI`/`NO` no mapeado.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Excluir de la base de SLA (recomendado) |
| B | Incluir y recalcular con mezcla |
| C | Incluir solo para reporte histórico, no para SLA |

**Recomendación:** **A** (o **C** si se necesita continuidad de reporte).

**Decisión requerida:** confirmar el estado de WHATICKET y su fecha de retiro.

---

## D-10 — Catálogo de subcategorías incompleto (alta)

**Situación.** El 39 % de las filas cerradas no se puede clasificar con el catálogo oficial de 65 subcategorías. En categorías de servicio, el 31,1 % (4.841 tickets) tiene subcategoría fuera de catálogo:

- `sin categorizar` (2.573 en total)
- Etiquetas concatenadas en Zendesk (`certificados  cambio de razón social  ajustes fe`, 867)
- Etiquetas operativas inexistentes (`Consultas generales`, `Consultas pagos / reactivaciones`, `Prorroga`, `Seguimiento`, `Reactivo`, `Comunicación de baja`, `Tarea desarrollo`, `Capacitación Plaza puntos`)

Además, el catálogo de COSE y el de Zammad **no coinciden**: COSE no tiene `RECLAMO`, `QUEJA` ni `DEVOLUCIÓN`; y tiene `ADD ONS`, `DUPLICADA`, `DUPLICADO`, `NO CONTESTO` que no existen en el árbol oficial.

**Opciones.**

| Opción | Descripción | Efecto |
|---|---|---|
| A | Publicar SLA solo para el 68,9 % clasificable | Deja un tercio sin política |
| B | Aplicar el SLA de respaldo del canal al resto | Cobertura total con menor precisión |
| C | Revisar y ampliar el catálogo antes de publicar | Más trabajo, mejor calidad |

**Recomendación:** **B** para el piloto y **C** como tarea previa a producción.

**Decisión requerida:** aceptar la cobertura parcial y autorizar la revisión del catálogo.

---

## D-11 — Precedencia y nomenclatura de políticas

**Situación.** Zammad elige el SLA por **orden alfabético del nombre**, no por especificidad. Una política llamada `"A - WhatsApp"` gana siempre a `"SLA WhatsApp Facturación"`.

**Opciones.**

| Opción | Convención |
|---|---|
| A | Prefijo numérico `00`, `10`, `20`, `99` |
| B | Convención jerárquica `CANAL-CATEGORIA-SUBCATEGORIA` |
| C | Dejar los nombres actuales |

**Recomendación:** **A**, con `99 - Respaldo` como única política sin condición.

**Decisión requerida:** aprobar la convención antes de crear políticas.

---

## D-12 — Revisión periódica

**Situación.** Las metas dependen de una ventana de 7 meses y de una operación en cambio (migración de Zendesk a Zammad, retiro de WHATICKET).

**Recomendación:** recalcular cada **90 días** o ante cambio de herramienta, y comparar contra el cumplimiento real.

**Decisión requerida:** fijar periodicidad y responsable.

---

## Orden sugerido de resolución

1. **D-03** y **D-08** — sin esto, ningún número es correcto.
2. **D-04** — afecta vencimientos.
3. **D-01**, **D-02**, **D-10** — definen la base de cálculo.
4. **D-05**, **D-06**, **D-11** — definen el diseño de las políticas.
5. **D-07**, **D-09**, **D-12** — ajustes operativos.

---

## Lo que NO se decide aquí

- No se autoriza crear SLA.
- No se autoriza desarrollar el administrador.
- No se autoriza iniciar el BFF.
- No se autoriza comenzar la Etapa 5G.3.

Cada una de esas acciones requiere autorización expresa de Victor.
