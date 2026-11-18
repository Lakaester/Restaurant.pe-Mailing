# OBSERVACIONES Y DECISIONES PENDIENTES — 5G.2.1

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2.1
**Fecha:** 16/11/2026
**Aprobador:** Victor
**Estado:** ninguna decisión de este documento está tomada.

---

## 1. Verificación real del calendario

El calendario se verificó **directamente en la base de datos de Zammad** (`mailing_development`, PostgreSQL local), en modo lectura.

### 1.1 Calendarios existentes

| ID | Nombre | Zona horaria | Predeterminado | iCal | Feriados |
|---:|---|---|---|---|---|
| 1 | `My Calendar` | `America/Los_Angeles` | **Sí** | — | — |
| 2 | `Soporte Especializado` | `America/Lima` | No | — | **Sin definir** |

### 1.2 Horario configurado del calendario 2

| Día | Activo | Franja |
|---|---|---|
| Lunes | Sí | 09:00 – 23:00 |
| Martes | Sí | 09:00 – 23:00 |
| Miércoles | Sí | 09:00 – 23:00 |
| Jueves | Sí | 09:00 – 23:00 |
| Viernes | Sí | 09:00 – 23:00 |
| Sábado | Sí | 09:00 – 20:00 |
| Domingo | Sí | 09:00 – 20:00 |

**Confirmado:** coincide exactamente con lo declarado en el alcance. **No se modificó.**

**Cálculo de cobertura semanal:**

- Lunes a viernes: 14 h/día × 5 = 70 h
- Sábado y domingo: 11 h/día × 2 = 22 h
- **Total: 92 h de 168 h semanales = 54,8 %**

### 1.3 Estado de SLA y de pausas

- **SLAs configurados: 0.** No hay ninguna política que interfiera.
- Estados con `ignore_escalation = true` (pausan el reloj): `pending reminder`, `pending close`, `closed`, `merged`.
- Estados sin pausa: `new`, `open`.

**Implicación:** cualquier ticket que entre en `pending reminder` deja de consumir SLA. Esto debe decidirse antes de publicar (DP-04).

---

## 2. Tiempo calendario vs. tiempo hábil

### 2.1 El problema

| Elemento | Cómo mide |
|---|---|
| Datos históricos de COSE | **Tiempo calendario**: diferencia entre marcas de tiempo, 24×7, sin pausas |
| Zammad | **Tiempo hábil**: solo avanza dentro del horario del calendario y excluye estados con `ignore_escalation` |

No son la misma unidad. El mismo número de minutos significa cosas distintas.

### 2.2 Cuánto se desvía realmente

Se calculó, **ticket por ticket**, qué proporción del tiempo transcurrido cayó dentro del horario del calendario 2.

Método: para cada ticket se reconstruyó su hora de creación y se cronometró cuántos minutos hábiles transcurrieron hasta el cierre. El cociente `tiempo hábil / tiempo calendario` mide la distorsión.

| Canal | Tickets analizados | Cociente mediano | Cociente promedio |
|---|---:|---:|---:|
| WhatsApp | 15.481 | **1,00** | 0,96 |
| Correo | 3.211 | **0,64** | 0,73 |

**Hallazgo principal:** la distorsión **no es uniforme entre canales**.

- **WhatsApp:** cociente 1,00. La operación ocurre íntegramente en horario y resuelve rápido. **Convertir a horas hábiles no cambia nada.**
- **Correo:** cociente 0,64. Solo el 64 % del tiempo transcurrido es tiempo hábil: un ticket de correo pasa de media un 36 % de su vida fuera de horario (noches, fines de semana, horas muertas).

> Este resultado corrige el supuesto de 5G.2, que aplicaba un factor único de 1,83 (168/92) a todo. Ese factor solo es válido para tickets que abarcan varias jornadas completas; no describe el comportamiento real de WhatsApp.

**Advertencia:** el cálculo de correo excluye **1.502 tickets** con hora de creación truncada (ver §3.1). Afecta al 32 % del canal.

### 2.3 Ejemplos concretos

Meta de **90 minutos** (SLA de respaldo de WhatsApp):

| Creación | Vencimiento en horas hábiles | Tiempo de reloj |
|---|---|---:|
| Lunes 10:00 | Lunes 11:30 | 1 h 30 min |
| Lunes 22:50 | Martes 10:20 | **11 h 30 min** |
| Viernes 22:30 | Sábado 10:00 | **11 h 30 min** |
| Domingo 19:00 | Lunes 09:30 | **14 h 30 min** |
| Sábado 12:00 | Sábado 13:30 | 1 h 30 min |

Meta de **15 minutos** (primera respuesta de WhatsApp):

| Creación | Vencimiento | Tiempo de reloj |
|---|---|---:|
| Lunes 22:50 | Martes 09:05 | **10 h 15 min** |

Meta de **24 horas** (correo):

| Creación | Vencimiento | Tiempo de reloj |
|---|---|---:|
| Lunes 10:00 | Martes 20:00 | 34 h |
| Viernes 22:30 | Lunes 10:30 | **60 h** |
| Sábado 12:00 | Lunes 14:00 | 50 h |
| Domingo 19:00 | Martes 18:00 | 47 h |

Meta de **36 horas** (correo):

| Creación | Vencimiento | Tiempo de reloj |
|---|---|---:|
| Lunes 10:00 | Miércoles 18:00 | 56 h |
| Lunes 22:50 | Jueves 16:50 | 66 h |
| Viernes 22:30 | Lunes 22:30 | 72 h |

### 2.4 Equivalencia de las metas actuales

Si se mantienen los números de la matriz como **minutos hábiles**:

| Meta | WhatsApp (hábil) | Correo (hábil) |
|---|---:|---:|
| 45 min | 45 | 29 |
| 1 h | 60 | 38 |
| 1 h 30 min | 90 | 58 |
| 2 h | 120 | 77 |
| 24 h | 1.440 | 923 |
| 36 h | 2.160 | 1.385 |
| 48 h | 2.880 | 1.846 |
| 72 h | 4.320 | 2.769 |
| 120 h | 7.200 | 4.615 |

La columna "Correo" indica **cuántos minutos hábiles equivalen al mismo rendimiento histórico**. Si se configura 36 h hábiles, en la práctica se está pidiendo el equivalente a ~56 h de reloj: **más laxo** que el desempeño actual.

### 2.5 Impacto promedio en tiempo de reloj

Para una creación uniformemente distribuida en la semana, un SLA de N minutos hábiles vence en promedio en:

| SLA hábil | Vencimiento medio de reloj | Factor |
|---|---:|---:|
| 15 min | 2,9 h | 11,6× |
| 1 h | 3,9 h | 3,9× |
| 1 h 30 min | 4,7 h | 3,1× |
| 2 h | 5,4 h | 2,7× |
| 24 h | 43,1 h | 1,8× |
| 36 h | 64,6 h | 1,8× |
| 48 h | 86,9 h | 1,8× |
| 72 h | 131,5 h | 1,8× |
| 120 h | 218,4 h | 1,8× |

**Lectura:** cuanto más corta es la meta, más importa la hora de creación. Un SLA de 15 minutos puede tardar 10 horas en vencer si el ticket entra a las 22:50. Un SLA de 36 horas siempre tarda ~1,8× en reloj.

---

## 3. Observaciones de calidad de datos

### 3.1 Hora de creación truncada en Zendesk (nuevo)

**2.171 de 5.824 registros (37,3 %)** tienen `tickets_created_at` exactamente a las `00:00:00`. En la ventana son **1.502 de 4.713** tickets incluidos.

Evidencia:

| Hora almacenada | Registros |
|---|---:|
| 00:00 | 2.171 |
| 15:00 | 425 |
| 16:00 | 393 |
| 21:00 | 370 |
| 17:00 | 368 |
| 14:00 | 341 |

Un tercio del canal correo no tiene hora real de creación, solo fecha.

**Impactos:**

- El análisis horario de correo es inválido para ese subconjunto.
- El cálculo de tiempo hábil se degrada (se asumió 00:00, que está fuera de horario).
- No se puede saber si esos tickets entraron de noche o de día.

### 3.2 Fecha y hora pueden ser de días distintos (nuevo)

**1.000 registros** tienen `tickets_created_at::date <> fecha_reporte`. La vista usa `fecha_reporte` como `fecha` y `tickets_created_at` para la hora. Si difieren, la fecha y la hora del mismo ticket pertenecen a días distintos.

### 3.3 Los demás hallazgos de 5G.2 se mantienen

| Hallazgo | Magnitud | Estado |
|---|---|---|
| Subcategoría fuera del catálogo oficial | 4.842 tickets (31,1 %) | Sin resolver |
| Categoría derivada de la subcategoría | Estructural | Sin resolver |
| Catálogo COSE ≠ catálogo Zammad | 9 categorías comunes de 13 | Sin resolver |
| WHATICKET no comparable | 1.360 registros, mediana 286 min | Excluido |
| Estados `SI`/`NO` sin mapear | 300 filas | Excluido |
| Ceros de resolución | 113 en la ventana | Excluido |
| Etiquetas concatenadas en Zendesk | ~867 registros | Sin resolver |
| Asesores con alias | 16 alias / ~10 personas | Sin resolver |

---

## 4. Decisiones pendientes

### DP-01 — Base de datos viva: fijar fecha de corte

**Situación.** Entre el 14/11 y el 16/11 la tabla creció 34 filas. Los totales cambian a diario.

| Opción | Descripción |
|---|---|
| A | Fijar el corte en 2026-10-31 y congelar la matriz hasta la próxima revisión |
| B | Recalcular en cada revisión y aceptar variación |

**Recomendación: A.** Publicar con fecha de corte explícita.

---

### DP-02 — Umbral de cumplimiento exigido

**Situación.** La propuesta tiene 81,4 % de cumplimiento histórico. No se ha definido qué se exige.

| Opción | Umbral | Comentario |
|---|---|---|
| A | ≥ 75 % | Coherente con P75 puro |
| B | ≥ 81 % | Coherente con la matriz actual |
| C | ≥ 85 % | Exigiría mejorar la operación |

**Recomendación: B** para el piloto, revisión a 90 días.

---

### DP-03 — Tiempo calendario vs. tiempo hábil (crítica)

**Situación.** Ver §2. La distorsión es **nula en WhatsApp y del 36 % en correo**.

| Opción | Descripción | Efecto |
|---|---|---|
| A | Publicar los valores de la matriz como minutos hábiles | Correo ~1,56× más laxo; WhatsApp igual |
| B | Escalar: WhatsApp ×1,00 y correo ×0,64 | Preserva el rendimiento histórico |
| C | Asociar un calendario 24/7 al SLA | Equivale a tiempo calendario |
| D | Recalcular percentiles en tiempo hábil | Requiere tratar los 1.502 tickets sin hora |

**Recomendación:** **B** para correo y **A** para WhatsApp, con la salvedad de que la primera respuesta de WhatsApp sí necesita revisión (15 min hábiles pueden vencer al día siguiente).

**Evidencia disponible para D:** el cálculo por ticket ya está hecho; es viable para el 100 % de WhatsApp y el 68 % de correo. Podría ejecutarse en una etapa posterior sin volver a extraer datos.

---

### DP-04 — Estados que pausan el SLA

**Situación.** En Zammad, `pending reminder` y `pending close` pausan el reloj. Los datos históricos **no registran pausas**.

| Opción | Descripción |
|---|---|
| A | Dejar la pausa activa en `pending reminder` (comportamiento nativo) |
| B | Desactivar la pausa para que el reloj corra siempre |
| C | Pausar solo en espera de terceros |

**Recomendación: A**, documentando que el SLA resultante es más exigente que el histórico.

---

### DP-05 — Feriados

**Situación.** El calendario 2 no tiene feriados. Los días feriados cuentan como hábiles.

| Opción | Descripción |
|---|---|
| A | Publicar sin feriados |
| B | Cargar el calendario de feriados de Perú antes de producción |

**Recomendación: B.** **No se creó ningún feriado.**

---

### DP-06 — Tratamiento de los 1.502 tickets sin hora

**Situación.** Un tercio de correo no tiene hora de creación real.

| Opción | Descripción |
|---|---|
| A | Aceptarlos con hora 00:00 (sesga el análisis horario) |
| B | Excluirlos de cualquier análisis horario y de tiempo hábil |
| C | Solicitar la hora real al origen |

**Recomendación: B** para análisis, **C** como mejora de datos.

---

### DP-07 — Catálogo de subcategorías incompleto

**Situación.** 4.842 tickets de servicio (31,1 %) no tienen subcategoría oficial.

| Opción | Descripción |
|---|---|
| A | Aplicar el SLA de respaldo del canal |
| B | Revisar y ampliar el catálogo antes de publicar |
| C | Dejar sin SLA |

**Recomendación: A** para el piloto y **B** antes de producción.

---

### DP-08 — Combinaciones con muestra baja o dispersión extrema

**Situación.** 12 combinaciones tienen n entre 10 y 29, y 20 tienen CV ≥ 2,0.

| Opción | Descripción |
|---|---|
| A | Publicar todas, marcadas como provisionales |
| B | Publicar solo ALTA y MEDIA |
| C | Publicar todas y revisar a 90 días |

**Recomendación: C**, con revisión obligatoria de las marcadas.

---

### DP-09 — Granularidad de las políticas

**Situación.** En WhatsApp, 33 de 37 combinaciones caen en 1 h 30 min o 2 h. Crear 37 políticas reproduce tres valores.

| Opción | Descripción |
|---|---|
| A | 65 políticas (una por subcategoría) |
| B | 19 políticas (canal × categoría) |
| C | 3 núcleo + excepciones justificadas |

**Recomendación: C**, coherente con `COMPATIBILIDAD_SLA_ZAMMAD.md`.

---

### DP-10 — Precedencia y nomenclatura

**Situación.** Zammad resuelve superposiciones por **orden alfabético del nombre**, no por especificidad.

| Opción | Descripción |
|---|---|
| A | Prefijo numérico (`00`, `10`, `20`, `99`) |
| B | Nomenclatura jerárquica sin número |
| C | Dejar los nombres actuales |

**Recomendación: A.** No se creó ninguna política.

---

### DP-11 — Tratamiento de WHATICKET

**Situación.** Mediana 286 min frente a 51 min de WHATMETA; 78 % sin categoría homologable.

**Recomendación:** excluirlo de la base de SLA y mantenerlo solo para reporte histórico.

---

### DP-12 — Revisión periódica

**Recomendación:** recalcular cada **90 días** o ante cambio de herramienta, con la misma ventana y el mismo método.

---

## 5. Orden sugerido de resolución

1. **DP-03** (calendario) y **DP-04** (pausas): sin esto ningún número es correcto.
2. **DP-05** (feriados) y **DP-06** (hora truncada).
3. **DP-01**, **DP-02** y **DP-07**: fijan base y umbral.
4. **DP-08**, **DP-09** y **DP-10**: diseño de políticas.
5. **DP-11** y **DP-12**: operación.

---

## 6. Confirmación

- No se creó ningún SLA.
- No se modificó el calendario ni se crearon feriados.
- No se modificó código de COSE ni de Zammad.
- No se modificó ninguna tabla, vista, registro ni función.
- No se activaron workers ni jobs.
- No se conectó Zendesk ni ningún buzón.
- No se implementó BFF ni interfaces.
- No se instalaron dependencias.
- Las consultas a la base de Zammad fueron **solo lectura** (`SELECT`).
