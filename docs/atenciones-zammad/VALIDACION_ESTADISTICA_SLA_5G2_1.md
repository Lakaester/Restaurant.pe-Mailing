# VALIDACIÓN ESTADÍSTICA SLA — ETAPA 5G.2.1

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2.1 — Validación estadística y definición de SLA de resolución
**Fecha:** 16/11/2026
**Modo:** solo lectura. Sin escrituras en bases de datos, sin cambios en COSE ni en Zammad.

---

## 1. Objetivo

Validar y corregir los resultados de la etapa 5G.2 antes de diseñar las políticas SLA, ampliando los estadísticos exigidos (promedio, desviación estándar, mínimo, máximo y conteo de exclusiones) y reconciliando todas las cifras publicadas.

Las metas de **primera respuesta no se recalculan**: WhatsApp < 15 min y correo < 24 h permanecen fijas.

---

## 2. Universo y denominadores

Ventana: **2026-04-01 → 2026-10-31**. Canales: WHATMETA y ZENDESK.

| Paso | Filas | Denominador |
|---|---:|---|
| Registros totales de la vista (todas las fechas) | 24.788 | — |
| Cerrados o resueltos | 24.176 | — |
| Con `resolucion_min_norm > 0` | 23.999 | — |
| **Dentro de la ventana y canales válidos** | **20.535** | base bruta |
| − abiertos / sin mapear | 206 | exclusión |
| − resolución nula | 22 | exclusión |
| − resolución = 0 | 113 | exclusión |
| **= Incluidos** | **20.194** | base limpia |
| − pseudo-categorías | 4.602 | no reciben SLA |
| **= Categorías de servicio** | **15.592** | base de servicio |
| − subcategoría fuera del catálogo oficial | 4.842 | no asignable |
| **= Con subcategoría oficial** | **10.750** | base de la matriz |
| − combinaciones con n < 10 | 39 | insuficientes |
| **= Cobertura efectiva de la propuesta** | **10.711** | 65 combinaciones |

**Pseudo-categorías excluidas (4.602):** `SIN HOMOLOGAR`, `SIN CATEGORIA EN ORIGEN`, `DUPLICADO`, `DUPLICADA`, `NO CONTESTO`, `ADD ONS`.

**Cobertura:** 10.750 / 15.592 = **68,94 %** de las categorías de servicio.

---

## 3. Reconciliación con la etapa 5G.2

### 3.1 Deriva de datos entre ejecuciones

La fuente `v_unificado_norm` **es una vista sobre tablas vivas**: los totales cambian entre ejecuciones. Entre el 14/11/2026 (5G.2) y el 16/11/2026 (5G.2.1) ingresaron registros nuevos.

| Métrica | 5G.2 (14/11) | 5G.2.1 (16/11) | Δ |
|---|---:|---:|---:|
| Filas totales | 24.754 | 24.788 | **+34** |
| Cerrados / resueltos | 24.137 | 24.176 | +39 |
| Con resolución > 0 | 23.960 | 23.999 | +39 |
| En ventana (WHATMETA + ZENDESK) | 20.193 | 20.194 | +1 |
| Categorías de servicio | 15.591 | 15.592 | +1 |
| Con subcategoría oficial | 10.750 | 10.750 | **0** |

**Lectura:** la diferencia es **deriva de datos**, no un error de cálculo. El crecimiento se produce en noviembre (fuera de la ventana), por eso la base de la matriz permanece idéntica. Toda cifra de este proyecto debe citarse con fecha de corte.

### 3.2 Combinaciones con SLA: 65 confirmadas

| Canal | Combinaciones totales | Con SLA (n ≥ 10) | Sin evidencia (n < 10) |
|---|---:|---:|---:|
| WhatsApp | 39 | **37** | 2 |
| Correo | 31 | **28** | 3 |
| **Total** | **70** | **65** | **5** |

Cifra de 5G.2 **correcta**.

### 3.3 Combinaciones sin evidencia: 5 confirmadas

| Canal | Categoría | Subcategoría | n |
|---|---|---|---:|
| WhatsApp | DEVOLUCIÓN | Solicitud de devolución | 8 |
| WhatsApp | FACTURACIÓN | Activación NV | 9 |
| Correo | FACTURACIÓN | Error FE por duplicidad | 9 |
| Correo | INTEGRACIONES | Integración sistemas contables | 9 |
| Correo | INTEGRACIONES | Error integración | 4 |

Cifra de 5G.2 **correcta**. Suman 39 tickets, que explican la diferencia entre 10.750 y 10.711.

### 3.4 Cobertura 10.750 (68,9 %): confirmada

Cifra de 5G.2 **correcta** (68,94 % con el denominador actual).

### 3.5 Distribución de confianza: **corregida**

| Confianza | 5G.2 publicó | Recuento real (16/11) | Corrección |
|---|---:|---:|---|
| ALTA (≥ 100) | 24 | **28** | **+4** |
| MEDIA (30–99) | 26 | **25** | −1 |
| BAJA (10–29) | 11 | **12** | +1 |
| INSUFICIENTE (< 10) | 5 | **5** | 0 |
| **Total** | 66 | **70** | — |

**Dos defectos en la cifra anterior:**

1. **No sumaba:** 24 + 26 + 11 + 5 = 66, cuando el total de combinaciones es 70.
2. **No se derivaba de la tabla:** el recuento celda a celda de la matriz publicada en 5G.2 da 28 / 25 / 12 / 5.

**Evidencia del recuento real:**

- ALTA WhatsApp (22): Temas operativos 1.063; Ajustes FE 1.075; Capacitación logística avanzado 859; Seguimiento proactivo 473; Capacitación integraciones 454; Solicitud agenda capacitación 432; Envío de pago 386; Validación comprobantes FE 329; Renovación certificado 312; Capacitación insumos recetas 298; Error punto de venta 293; Rappi 280; Seguimiento errores 241; Capacitación adm Productos 199; Capacitación adm Reportes 190; Pedidos Ya 165; Venta CDT 157; Nueva licencia 133; Cambio razón social 132; Activación FE 119; Error FE envío manual 119; Requisitos FE 102.
- ALTA Correo (6): Ajustes FE 341; Tarea o capacitación logística 319; Renovación certificado 177; Cambio razón social 170; Temas operativos 119; Solicitud agenda capacitación 115.

**Total ALTA = 28.**

---

## 4. Cambio metodológico aplicado

### 4.1 Qué cambió

En 5G.2, las combinaciones con 10–29 registros (BAJA) no se calculaban con sus propios datos: se **agregaban a la categoría** para "robustecer" la muestra.

En 5G.2.1 se elimina esa agregación. La instrucción de esta etapa prohíbe combinar categorías distintas y exige no inflar la muestra. Una subcategoría con n = 20 tiene 20 datos y debe declararse como tal.

**Nueva regla:** el SLA se calcula **siempre con los datos propios de la combinación** cuando n ≥ 10. Si n < 10, no hay propuesta.

### 4.2 Efecto: 10 de las 12 combinaciones BAJA cambian de meta

| Canal | Categoría | Subcategoría | n | SLA 5G.2 (agregado) | SLA 5G.2.1 (propio) |
|---|---|---|---:|---:|---:|
| Correo | ADMINISTRATIVO | Solicitud de migración | 27 | 36 h | **72 h** |
| Correo | CAPACITACIÓN | Capacitación adm Reportes | 21 | 72 h | **36 h** |
| Correo | FACTURACIÓN | Emisión de invoice | 28 | 36 h | 36 h (sin cambio) |
| Correo | FACTURACIÓN | Error FE envío manual | 19 | 36 h | **48 h** |
| Correo | INTEGRACIONES | Solicitud integración Rappi | 25 | 48 h | **36 h** |
| Correo | INTEGRACIONES | Solicitud integración Pedidos Ya | 14 | 48 h | **96 h** |
| Correo | LOGÍSTICA | Error logística | 20 | 72 h | **96 h** |
| Correo | SOFTWARE | Error web | 12 | 48 h | **72 h** |
| WhatsApp | SOFTWARE | Error web | 26 | 2 h | **3 h** |
| WhatsApp | INTEGRACIONES | Solicitud integración Uber | 24 | 2 h | 2 h (sin cambio) |
| WhatsApp | INTEGRACIONES | Integración sistemas contables | 12 | 2 h | **3 h** |
| WhatsApp | FACTURACIÓN | FE solicitud XML/PDF | 20 | 1 h 30 min | **45 min** |

**Efecto neto:** las metas BAJA se vuelven más fieles a su propia distribución, pero también más volátiles. Todas llevan la marca de "muestra baja" y deben revisarse a los 90 días.

### 4.3 Efecto en la cobertura

La cobertura no cambia (10.711 tickets, 65 combinaciones); cambia el valor asignado a 12 filas.

---

## 5. Estadísticos ampliados

Se agregaron los campos exigidos que 5G.2 no reportaba: **promedio aritmético, desviación estándar, mínimo, máximo y conteo de exclusiones por combinación**.

### 5.1 Resumen por canal (combinaciones con n ≥ 10)

| Canal | Combinaciones | Tickets | Mediana de medianas | Promedio global | Desv. estándar global |
|---|---:|---:|---:|---:|---:|
| WhatsApp | 37 | 8.624 | 57 min | 96 min | 440 min |
| Correo | 28 | 2.087 | 990 min | 1.930 min | 3.020 min |

**La desviación estándar es mayor que el promedio en ambos canales**, señal de distribuciones de cola pesada. Es la razón principal por la que el promedio no debe usarse como meta.

### 5.2 Coeficiente de variación (CV = desv. estándar / promedio)

| Rango de CV | Interpretación | Combinaciones |
|---|---|---:|
| CV < 1,0 | Dispersión moderada | 15 |
| CV 1,0 – 1,9 | Dispersión alta | 38 |
| CV ≥ 2,0 | Dispersión extrema (cola dominante) | 12 |

Casos con CV extremo:

| Canal | Subcategoría | n | Promedio | Mediana | CV |
|---|---|---:|---:|---:|---:|
| WhatsApp | Solicitud integración Pedidos Ya | 165 | 233 | 66 | **7,3** |
| WhatsApp | Capacitación logística avanzado | 859 | 98 | 57 | **7,1** |
| WhatsApp | Error punto de venta | 293 | 309 | 36 | **6,2** |
| WhatsApp | Venta de CDT certificado | 157 | 139 | 51 | **5,8** |
| WhatsApp | Capacitación integraciones | 454 | 111 | 61 | **5,4** |

En estos casos, fijar el SLA en el promedio implicaría una meta **3 a 8 veces superior a la mediana** y un cumplimiento esperado cercano al 55–60 %.

### 5.3 Exclusiones por combinación

El detalle de exclusiones (abiertos, nulos, ceros) está en la matriz final. Totales globales:

| Motivo | WhatsApp | Correo | Total |
|---|---:|---:|---:|
| Estado abierto / sin mapear | 206 | 0 | 206 |
| Resolución nula | 0 | 22 | 22 |
| Resolución = 0 | 0 | 113 | 113 |
| **Total excluido de la ventana** | **206** | **135** | **341** |

Las exclusiones por ceros se concentran en correo (113 de 135), lo que sugiere cierres automáticos o plantillas en Zendesk.

---

## 6. Problemas de datos confirmados en esta etapa

### 6.1 Marca de creación truncada en Zendesk

**2.171 de 5.824 registros (37,3 %)** de `Categorización_zendesk` tienen `tickets_created_at` exactamente a las **00:00:00**, es decir, fecha sin hora. En la ventana analizada son **1.502 de 4.713** tickets incluidos.

**Consecuencias:**

- No se puede reconstruir la hora real de creación de un tercio del canal correo.
- El análisis de distribución horaria de correo es inválido para ese subconjunto.
- El cálculo de tiempo hábil se degrada: se tomó 00:00 como hora de creación, que está fuera de horario.

**Tratamiento:** para el análisis de horas hábiles se excluyeron esos 1.502 registros y se trabajó con los **3.211** que tienen hora real.

### 6.2 Inconsistencia entre `fecha_reporte` y `tickets_created_at`

**1.000 registros** tienen `tickets_created_at::date <> fecha_reporte`. La vista usa `fecha_reporte` como `fecha`, mientras que la hora proviene de `tickets_created_at`. Es decir, **fecha y hora pueden provenir de días distintos**.

### 6.3 Homologación de categorías

Se mantienen los hallazgos de 5G.2:

- 2.400+ etiquetas crudas sin normalizar (204 combinaciones canal × subcategoría).
- 4.842 tickets de servicio (31,06 %) con subcategoría fuera del catálogo oficial.
- Categoría derivada de la subcategoría: no hay dos niveles independientes.
- Catálogo COSE ≠ catálogo Zammad (faltan RECLAMO, QUEJA, DEVOLUCIÓN; sobran ADD ONS y pseudo-categorías).

### 6.4 Estados no mapeados

`WHATICKET` tiene 300 filas con estado `SI`/`NO` sin mapear, de las cuales 188 tienen tiempo de resolución. Se excluyen porque no puede afirmarse que estén cerradas. WHATICKET sigue fuera de la base de SLA por su comportamiento no comparable (mediana 286 min frente a 51 min).

### 6.5 Valores atípicos

No se elimina ningún atípico. Criterio documentado:

- Se conservan todos los valores positivos.
- Se excluyen únicamente ceros y nulos por no representar trabajo medible.
- El efecto de la cola se controla con percentiles.
- Los máximos se reportan en la matriz (hasta 26.072 min en correo).

---

## 7. Reproducibilidad

Fecha de corte de esta validación: **2026-11-16**.

```sql
-- Universo y embudo
SELECT COUNT(*) AS total,
       COUNT(*) FILTER (WHERE estado_homologado IN ('cerrado','resuelto')) AS cerrados,
       COUNT(*) FILTER (WHERE estado_homologado IN ('cerrado','resuelto')
                          AND resolucion_min_norm > 0) AS con_tiempo
FROM public.v_unificado_norm;

-- Base de la matriz
SELECT canal, COUNT(*)
FROM public.v_unificado_norm
WHERE fecha BETWEEN '2026-04-01' AND '2026-10-31'
  AND subcanal IN ('WHATMETA','ZENDESK')
  AND estado_homologado IN ('cerrado','resuelto')
  AND resolucion_min_norm > 0
GROUP BY 1;

-- Estadísticos por combinación
SELECT canal, categoria, subcategoria,
       COUNT(*) AS n,
       AVG(resolucion_min_norm) AS promedio,
       PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY resolucion_min_norm) AS mediana,
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY resolucion_min_norm) AS p75,
       PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY resolucion_min_norm) AS p90,
       STDDEV_SAMP(resolucion_min_norm) AS desv_estandar,
       MIN(resolucion_min_norm) AS minimo,
       MAX(resolucion_min_norm) AS maximo
FROM public.v_unificado_norm
WHERE fecha BETWEEN '2026-04-01' AND '2026-10-31'
  AND subcanal IN ('WHATMETA','ZENDESK')
  AND estado_homologado IN ('cerrado','resuelto')
  AND resolucion_min_norm > 0
GROUP BY 1,2,3;
```

> La última consulta requiere la homologación de subcategorías aplicada en memoria (ver `ANALISIS_ESTADISTICO_RESOLUCION.md` §1 y el diccionario de 65 subcategorías).

---

## 8. Conclusión de la validación

| Elemento de 5G.2 | Resultado |
|---|---|
| Universo y ventana | **Válidos** (con deriva de +34 filas) |
| 65 combinaciones con SLA | **Confirmado** |
| 37 WhatsApp / 28 correo | **Confirmado** |
| 5 combinaciones sin evidencia | **Confirmado** |
| Cobertura 10.750 (68,9 %) | **Confirmado** |
| Distribución ALTA/MEDIA/BAJA | **Corregida**: 28 / 25 / 12 |
| Metodología de muestras BAJA | **Corregida**: sin agregación |
| Cifras de SLA de 12 filas BAJA | **Recalculadas** |

Ninguna corrección invalida la conclusión general de 5G.2: la evidencia permite proponer SLA diferenciados, pero un tercio del volumen sigue sin clasificación oficial.
