# AUDITORÍA DE DATOS PARA SLA — COSE

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2 — Auditoría estadística de COSE para diseño de SLA
**Fecha:** 14/11/2026
**Modo:** solo lectura. No se modificó ningún sistema, tabla, vista, función, configuración ni documento previo.

---

## 1. Objetivo

Documentar el modelo de datos real disponible en COSE para construir dos familias de SLA en Zammad 7.2.3:

1. **Primera respuesta:** fija por canal (WhatsApp < 15 min, correo < 24 h). Decisión ya aprobada; **no se recalcula en esta etapa**.
2. **Resolución:** dinámica por canal × categoría × subcategoría, derivada de la evidencia histórica.

Este documento cubre las fases A (modelo), B (canales), C (categorías) y D (calidad).

---

## 2. Fuentes inspeccionadas

| # | Fuente | Ubicación | Estado | Uso |
|---|---|---|---|---|
| 1 | Vista unificada normalizada | `public.v_unificado_norm` | Disponible | Fuente principal de análisis |
| 2 | Vista unificada base | `public.v_unificado` | Disponible | Se inspeccionó su definición real |
| 3 | Tabla WhatsApp Meta | `public."Whatmeta"` | Disponible | Origen de `subcanal = WHATMETA` |
| 4 | Tabla Whaticket | `public."Whaticket"` | Disponible | Origen de `subcanal = WHATICKET` |
| 5 | Tabla Zendesk | `public."Categorización_zendesk"` | Disponible | Origen de `subcanal = ZENDESK` |
| 6 | Homologación de categorías | `public.homologacion_categorias` y `public.vw_homologacion_categorias` | Disponible | Traduce etiqueta → categoría |
| 7 | Catálogo oficial COSE | `frontend/src/components/workspace/CategoryData.ts` | Disponible | 13 categorías / 65 subcategorías |
| 8 | Otras vistas BI | `vista_bi_tiempos`, `vista_bi_seguimiento`, `vista_bi_altas`, `vista_evolucion_diaria`, `informe_clientes_reporte`, `informe_ventas_reporte` | Disponibles, no usadas para SLA | Se verificó que derivan de las mismas fuentes |
| 9 | Código Zammad 7.2.3 | `/home/acast/mailing` | Disponible | Fase H (ver `COMPATIBILIDAD_SLA_ZAMMAD.md`) |

**No se accedió** a la API productiva de Zendesk, ni a buzones, ni a credenciales externas.

---

## 3. Arquitectura real del dato

```
"Whatmeta"  ─┐
"Whaticket" ─┼─► public.v_unificado ─► public.v_unificado_norm
"Categorización_zendesk" ─┘                    (normaliza estado y minutos)
```

### 3.1 `v_unificado` no es un universo completo

La definición real contiene un **filtro cerrado de asesores** aplicado con `WHERE` sobre `asesor`:

- `victor guevara`, `victor`, `sheyla guevara`, `sheyla`, `lidia ceferino`, `lidia`,
  `lisbeth giron`, `lisbeth huaman`, `lisbeth`, `eveling lovera`, `eveling`,
  `andres espinoza`, `andres espinoza franco`, `andres`, `danilo pena`, `danilo p`,
  `danilo`, `cesar espinoza`, `alex lopez`.

Consecuencias:

- La vista **no representa todos los tickets de la empresa**, sino los de un equipo monitoreado.
- Los 16 valores distintos de `asesor` corresponden a ~10 personas (alias sin normalizar: `Victor` y `Victor Guevara`; `Lisbeth`, `Lisbeth Huaman`, `Lisbeth Giron`; `Danilo`, `Danilo P`, `Danilo Pena`).
- **No es posible un análisis por agente fiable** sin normalizar identidad. Esta etapa no lo requiere.
- Cualquier SLA derivado de esta vista hereda ese sesgo de cobertura.

### 3.2 `v_unificado_norm` solo normaliza tres cosas

1. `estado_homologado` (mapea `closed/solved/open/pending/SI/NO`).
2. `primera_respuesta_min_norm`, `resolucion_min_norm`, `respuesta_promedio_min_norm`.
3. Nada más. **No** normaliza canal, categoría, subcategoría ni asesor.

### 3.3 La categoría NO es un campo independiente

En la vista, `categoria` se calcula como:

```sql
CASE WHEN normalizar_texto(subcategoria_origen) = '' THEN 'SIN CATEGORIA EN ORIGEN'
     ELSE COALESCE(homologacion.categoria, 'SIN HOMOLOGAR') END
```

Donde `homologacion` es `vw_homologacion_categorias` agrupada por `clave`.

**Consecuencia crítica:** la categoría es una **función de la subcategoría**, no un atributo paralelo. COSE nunca almacena categoría y subcategoría de forma independiente. Por tanto:

- No se puede reconstruir la combinación oficial cuando una etiqueta existe en dos categorías del catálogo.
- La homologación fuerza una categoría única por etiqueta (por ejemplo, `Caída del servidor` → `SERVIDOR`, aunque el catálogo oficial la ubica también en `OPERATIVO`).

---

## 4. Diccionario de campos

Unidades verificadas empíricamente: `resolucion` y `primera_respuesta` están en **horas** en los tres orígenes; los campos `*_min` en **minutos**. Comprobación: `3.4227 h × 60 = 205.36 min` y `0.001666 h × 60 = 0.1 min`.

| # | Campo | Tipo | Significado comprobado | Unidad | Nulos | Calidad / limitación |
|---|---|---|---|---|---|---|
| 1 | `canal` | text | Canal homologado en la vista | — | 0 | Solo 2 valores: `WHATSAPP`, `CORREO`. Ver §5 |
| 2 | `subcanal` | text | Herramienta de origen | — | 0 | `WHATMETA`, `WHATICKET`, `ZENDESK` |
| 3 | `ticket_id` | bigint | Identificador del ticket en su sistema de origen | — | 0 | **No es global**: IDs de WhatsApp y Zendesk pueden colisionar. 24.752 distintos sobre 24.754 filas |
| 4 | `fecha` | date | Fecha de reporte / creación | fecha | 0 | Para Zendesk es `fecha_reporte`, no necesariamente la fecha de creación |
| 5 | `hora` | text | Hora de creación | HH:MI(:SS) | 0 | **Para Zendesk está en UTC**, para WhatsApp en hora local. No comparable |
| 6 | `tickets_created_at` | timestamp | Creación real del ticket | timestamp sin zona | Solo Zendesk | WhatsApp no lo tiene: solo `fecha` + `hora` separadas |
| 7 | `tickets_updated_at` | timestamp | Última actualización | timestamp sin zona | Solo Zendesk | — |
| 8 | `categoria` | text | Categoría **derivada** por homologación | — | 0 | 15 valores; no coincide con el catálogo oficial. Ver §6 |
| 9 | `subcategoria` | text | Etiqueta cruda del origen | — | 465 | 204 combinaciones crudas distintas; sin normalizar |
| 10 | `categoria_bot` | text | Opción de bot | — | Solo WhatsApp | No usada para SLA |
| 11 | `subcategoria_bot` | text | Opción de bot | — | Solo WhatsApp | No usada para SLA |
| 12 | `primera_respuesta` | numeric | Duración hasta primera respuesta | **horas** | 553 (CORREO) | Para Zendesk es sospechoso. Ver §5.3 |
| 13 | `primera_respuesta_min` | numeric | Igual, en minutos | minutos | Todos los CORREO | Solo WhatsApp |
| 14 | `primera_respuesta_min_norm` | numeric | `COALESCE(min, horas×60)` | minutos | 553 | Campo recomendado para primera respuesta |
| 15 | `resolucion` | numeric | Duración total hasta cierre/resolución | **horas** | 24 | — |
| 16 | `resolucion_min` | numeric | Igual, en minutos | minutos | Todos los CORREO | Solo WhatsApp |
| 17 | `resolucion_min_norm` | numeric | `COALESCE(min, horas×60)` | minutos | 24 | **Campo recomendado para resolución** |
| 18 | `tiempo_promedio_respuesta` | numeric | Promedio de respuesta del agente | horas | Todos los CORREO | No equivalente a primera respuesta |
| 19 | `respuesta_promedio_min_norm` | numeric | Igual, en minutos | minutos | Todos los CORREO | Referencia, no usado |
| 20 | `estado` | text | Estado crudo | — | 0 | `closed`, `open`, `solved`, `SI`, `NO` |
| 21 | `estado_homologado` | text | Estado normalizado | — | 0 | `cerrado`, `resuelto`, `abierto`, `sin_mapear` |
| 22 | `esperando` | text | Marca de espera de WhatsApp | — | Solo WhatsApp | No es una pausa de SLA |
| 23 | `rango_atencion` | text | Quintil de SLA calculado en COSE | — | Parcial | Derivado, no fuente |
| 24 | `rango_primera_respuesta` | text | Quintil de primera respuesta (Zendesk) | — | Solo Zendesk | Derivado del mismo valor sospechoso |
| 25 | `asesor` | text | Agente asignado | — | 0 | 16 alias para ~10 personas. No normalizado |
| 26 | `departamento` | text | Área | — | Solo WhatsApp | No usado |
| 27 | `contacto` / `numero` / `correo` | text | Identificador del cliente | — | 1.091 en Zendesk | `numero` es correo en CORREO. No hay `cliente_id` estable |
| 28 | `localbi_id` | text | ID de local en LocalBI | — | Solo WhatsApp | Vínculo con maestro de clientes |
| 29 | `dominio` | text | Dominio del cliente | — | Parcial | Útil como identificador de cuenta |
| 30 | `pais` | text | País | — | Parcial | — |
| 31 | `tipo_cliente` | text | Tipo de cliente | — | Solo WhatsApp | — |
| 32 | `comentario_cierre` | text | Texto libre de cierre | — | Mayormente nulo | No estructurado |
| 33 | `es_representativo`, `isexclusive`, `fecha_alta` | varios | Atributos de cartera | — | Parcial | No usados para SLA |
| 34 | `fecha_carga` | timestamp | Carga al repositorio | — | Solo Zendesk | Control de ETL |

**No existen en la vista:** fecha de primera respuesta, fecha de cierre, SLA aplicado, marca de pausa, nivel de prioridad, grupo/equipo. Solo hay **duraciones agregadas**.

---

## 5. Homologación de canales (Fase B)

### 5.1 Matriz real

| Valor original | Subcanal | Valor normalizado | Registros | % | Ventana | ¿Homologado? |
|---|---|---|---:|---:|---|---|
| `WHATSAPP` / Meta | `WHATMETA` | WHATSAPP | 17.731 | 71,6 % | 2026-02-26 → 2026-11-14 | **Sí** |
| `WHATSAPP` / Whaticket | `WHATICKET` | WHATSAPP | 1.360 | 5,5 % | 2025-10-10 → 2026-11-13 | **Parcial** (legado, ver §5.2) |
| `CORREO` / Zendesk | `ZENDESK` | CORREO | 5.663 | 22,9 % | 2026-03-17 → 2026-11-14 | **Inferido**, no demostrado (ver §5.3) |
| Total | | | **24.754** | 100 % | 2025-10-10 → 2026-11-14 | |

- **Registros sin canal:** 0.
- **Canales duplicados/ambiguos:** 0 tickets aparecen en más de un canal (`ticket_id` compartido entre canales = 0).

### 5.2 WHATICKET es un canal legado, no comparable

| Métrica (cerrados, cat. de servicio) | WHATMETA | WHATICKET |
|---|---:|---:|
| n | 13.318 | 206 |
| Mediana | 50,7 min | 286,5 min |
| P75 | 83,8 min | 1.559,7 min |
| P90 | 131,8 min | 4.773,1 min |

La diferencia es de **5,6× en la mediana**. Además, el 78 % de los registros WHATICKET no tiene categoría homologable (`SIN CATEGORIA EN ORIGEN` 421, `SIN HOMOLOGAR` 331, `NO CONTESTO` 195) y 300 filas tienen estado `SI`/`NO` que no se puede mapear.

**Decisión de análisis:** WHATICKET se excluye de la línea base de SLA. Se documenta como canal en extinción.

### 5.3 ZENDESK → CORREO no está plenamente demostrado

Evidencia a favor:

- La tabla `Categorización_zendesk` **no tiene** columna de canal, origen, vía ni tipo de ticket.
- El único identificador de contacto es `correo` (texto de email).

Evidencia en contra:

- **1.091 de 5.663 registros (19,3 %) no tienen correo**, por lo que su naturaleza de correo no puede demostrarse desde los datos.
- Sin campo de canal, no se puede descartar que Zendesk haya recibido tickets por formulario web u otro canal.
- El campo usado como primera respuesta es dudoso: `efficiency_first_resolution` es **idéntico** a `efficiency_full_resolution_time` en 3.368 de 5.816 filas (57,9 %). Ese campo mide tiempo de resolución completa, no primera respuesta.

**Clasificación resultante:**

| Subconjunto | Registros | Naturaleza de correo | Aplicación de la meta de 24 h |
|---|---:|---|---|
| Zendesk con `correo` no nulo | 4.572 | Demostrada por el dato de contacto (evidencia indirecta) | Admisible con reserva |
| Zendesk sin `correo` | 1.091 | **No demostrada** | **No aplicar sin validación** |

> La meta fija de correo (< 24 h) solo debe aplicarse a registros cuya naturaleza de correo esté demostrada. Queda como decisión pendiente (ver `DECISIONES_PENDIENTES_SLA.md`, D-02).

---

## 6. Homologación de categorías (Fase C)

### 6.1 Catálogo oficial (`CategoryData.ts`)

Verificado por lectura directa del archivo:

- **13 categorías**: FACTURACIÓN ELECTRÓNICA, LOGÍSTICA, INTEGRACIONES, SOFTWARE, GESTIÓN, ADMINISTRATIVO, OPERATIVO, CAPACITACIÓN, SERVIDOR, SIN HOMOLOGAR, RECLAMO, QUEJA, DEVOLUCIÓN.
- **65 subcategorías**; **62 etiquetas únicas**.
- **3 etiquetas duplicadas entre categorías** (ambigüedad estructural):

| Etiqueta | Categorías | Valor interno |
|---|---|---|
| Cambio de razón social | FACTURACIÓN ELECTRÓNICA, ADMINISTRATIVO | `cambio_de_razón_social` |
| Caída del servidor | OPERATIVO, SERVIDOR | `caída_del_servidor` |
| Redes y conexiones | OPERATIVO, SERVIDOR | `redes_y_conexiones` |

- El catálogo se usa en Zammad como un solo atributo `categoria_subcategoria` (`tree_select`) que almacena el path `CATEGORÍA::subcategoría`.

### 6.2 Catálogo de homologación de COSE (fuente real del dato)

`vw_homologacion_categorias`: **100 filas, 90 claves, 13 categorías, 0 conflictos** (ninguna clave apunta a dos categorías).

| Categoría en COSE | Filas | ¿En catálogo oficial? |
|---|---:|---|
| GESTION | 20 | Sí (como GESTIÓN) |
| INTEGRACIONES | 19 | Sí |
| FACTURACION ELECTRONICA | 18 | Sí (como FACTURACIÓN ELECTRÓNICA) |
| SOFTWARE | 17 | Sí |
| ADMINISTRATIVO | 8 | Sí |
| ADD ONS | 6 | **No** |
| CAPACITACION | 4 | Sí (como CAPACITACIÓN) |
| LOGISTICA | 3 | Sí (como LOGÍSTICA) |
| DUPLICADA | 1 | **No** (pseudo-categoría) |
| DUPLICADO | 1 | **No** (pseudo-categoría) |
| NO CONTESTO | 1 | **No** (pseudo-categoría) |
| OPERATIVO | 1 | Sí |
| SERVIDOR | 1 | Sí |

**Divergencia estructural:** ambos catálogos tienen 13 categorías, pero **no son el mismo conjunto**.

- Faltan en COSE: `RECLAMO`, `QUEJA`, `DEVOLUCIÓN`.
- Sobran en COSE: `ADD ONS`, `DUPLICADA`, `DUPLICADO`, `NO CONTESTO`.

Coincidencia real: **9 categorías** de servicio + pseudo-categorías.

### 6.3 Cobertura de la subcategoría frente al catálogo oficial

Sobre 23.960 filas cerradas/resueltas con tiempo > 0:

| Resultado | Filas | % |
|---|---:|---:|
| Emparejada a una subcategoría oficial | 14.204 | 59,3 % |
| **Fuera del catálogo oficial** | 9.352 | **39,0 %** |
| Vacía | 392 | 1,6 % |
| Ambigua (etiqueta en 2 categorías) | 12 | 0,1 % |

Valores fuera de catálogo más frecuentes:

| Canal | Valor crudo | Filas |
|---|---|---:|
| WHATSAPP | `sin categorizar` | 2.573 |
| CORREO | `certificados  cambio de razón social  ajustes fe` (etiquetas concatenadas) | 867 |
| CORREO | `consultas_generales` | 325 |
| CORREO | `tarea o capacitación logistica` (sin acento, variante) | 150 |
| CORREO | `comunicación_de_baja` | 143 |
| CORREO | `consultas_fe` | 204 |

Causas identificadas:

1. **Etiquetas concatenadas** en el export de Zendesk (varias etiquetas unidas por espacios dobles), que no representan una subcategoría única.
2. **Variantes ortográficas** de la misma etiqueta (`Consultas FE` / `consultas_fe`, `ajustes fe` / `Ajustes FE`).
3. **Etiquetas operativas que no existen en el árbol oficial**: `Consultas generales`, `Consultas pagos / reactivaciones`, `Prorroga`, `Seguimiento`, `Reactivo`, `Comunicación de baja`, `Capacitación adm clientes`, `Tarea desarrollo`, `Capacitación Plaza puntos`, etc.
4. **Pseudo-categorías de cierre**: `sin categorizar`, `No contestó`, `Duplicado o spam`.

> **Conclusión de la Fase C:** el árbol oficial de 65 subcategorías **no describe la operación real**. El 39 % del volumen no se puede clasificar con él. Diseñar SLA por subcategoría oficial sobre esta base deja un tercio del volumen sin política.

### 6.4 Matriz CANAL × CATEGORÍA × SUBCATEGORÍA

La matriz completa, con volumen y estadísticos, está en `ANALISIS_ESTADISTICO_RESOLUCION.md`. Resumen de estructura:

| Nivel | Combinaciones distintas | Con n ≥ 10 |
|---|---:|---:|
| Canal × categoría (servicio) | 19 | 18 |
| Canal × categoría × subcategoría oficial | 70 | 65 |
| Canal × categoría × subcategoría **cruda** | 204 | — |

Combinaciones incluidas explícitamente en el análisis:

- Sin categoría: `SIN CATEGORIA EN ORIGEN` (857 filas; 392 WHATSAPP + 465 vacías).
- Sin subcategoría: 465 filas WhatsApp (`subcategoria IS NULL`).
- Sin homologar: `SIN HOMOLOGAR` (4.375 filas).
- Pseudo-categorías: `DUPLICADO/DUPLICADA` (752), `NO CONTESTO` (1.181), `ADD ONS` (245).
- Fuera de catálogo oficial: 9.352 filas.

---

## 7. Calidad y cobertura (Fase D)

### 7.1 Volumen total

| Métrica | Valor |
|---|---:|
| Filas totales | 24.754 |
| `ticket_id` distintos | 24.752 |
| Duplicados de `ticket_id` | 2 |
| Duplicados por (`ticket_id`, `subcanal`) | 0 |
| Cerrados + resueltos | 24.137 (97,5 %) |
| Abiertos + sin mapear | 617 (2,5 %) |

### 7.2 Por canal y estado

| Subcanal | Total | Cerrados/resueltos | Con tiempo > 0 | Abiertos/sin mapear |
|---|---:|---:|---:|---:|
| WHATMETA | 17.731 | 17.451 | 17.427 | 280 |
| WHATICKET | 1.360 | 1.023 | 1.014 | 337 |
| ZENDESK | 5.663 | 5.663 | 5.519 | 0 |
| **Total** | **24.754** | **24.137** | **23.960** | **617** |

### 7.3 Calidad de tiempos

| Defecto | CORREO | WHATSAPP | Total | Tratamiento |
|---|---:|---:|---:|---|
| `resolucion_min_norm` nulo | 24 | 0 | 24 | Excluido |
| `resolucion_min_norm` = 0 | 582 | — | 582 | Excluido del cálculo (resolución instantánea no verificable) |
| `resolucion_min_norm` negativo | 0 | 0 | 0 | No existe |
| Resolución > 7 días | 117 | 46 | 163 | **Conservado**, reportado como cola |
| Resolución > 30 días | 1 | 0 | 1 | Conservado, señalado |
| `primera_respuesta_min_norm` nulo | 553 | 0 | 553 | Solo afecta primera respuesta (no recalculada) |

> Los 582 ceros y los 120 ceros de CORREO detectados en el primer perfil corresponden a cierres automáticos o plantillas. Se excluyen por no representar trabajo real, criterio documentado y reproducible.

### 7.4 Registros con tiempo pero sin estado de cierre

- WHATICKET: 188 filas con estado `NO` (no mapeado) tienen `resolucion_min_norm > 0`.
- Se excluyen porque no se puede afirmar que estén cerradas.
- **Pérdida de información:** 188 resoluciones válidas no utilizables.

### 7.5 Otros defectos detectados

| Defecto | Detalle | Impacto |
|---|---|---|
| Hora de Zendesk en UTC | `hora = to_char(tickets_created_at,'HH24:MI')` sin conversión a `America/Lima` | El análisis horario de CORREO es inválido (00–08 UTC = 17–01 Lima) |
| Primera respuesta Zendesk | `efficiency_first_resolution` = `efficiency_full_resolution_time` en 57,9 % | No sirve como primera respuesta |
| Identidad de asesor | 16 alias para ~10 personas | Análisis por agente no fiable |
| Categoría derivada | No hay campo de categoría independiente | Ambigüedad irreducible en 3 etiquetas |
| Sin fecha de cierre | La vista solo tiene duración, no `closed_at` | No se puede calcular tiempo hábil ni pausas |

### 7.6 Ventana temporal

| Elemento | Valor |
|---|---|
| Inicio | 2025-10-10 (solo WHATICKET) |
| Fin | 2026-11-14 |
| Extensión | 13 meses / 401 días |
| Ventana con los 3 orígenes | 2026-03-17 → 2026-11-14 |
| Ventana con 2 orígenes estables (recomendada) | **2026-04-01 → 2026-10-31** (7 meses completos) |

**Por qué se recomienda 2026-04-01 → 2026-10-31:**

| Mes | n | Mediana | P75 |
|---|---:|---:|---:|
| 2026-02 | 22 | 8.771,5 min | 9.980,8 min |
| 2026-03 | 1.413 | 146,3 min | 1.252,3 min |
| 2026-04 | 2.524 | 65,7 min | 141,1 min |
| 2026-05 | 2.807 | 54,0 min | 121,5 min |
| 2026-06 | 3.013 | 54,0 min | 109,2 min |
| 2026-07 | 2.834 | 64,1 min | 139,0 min |
| 2026-08 | 3.038 | 56,1 min | 117,4 min |
| 2026-09 | 3.014 | 60,1 min | 124,2 min |
| 2026-10 | 2.963 | 66,0 min | 148,3 min |
| 2026-11 (parcial) | 1.318 | 70,5 min | 174,6 min |

- Febrero y marzo son **meses de arranque** (mediana 8.771 min y 146 min frente a ~55–66 min del resto): incluyen migración y backlog, no operación normal.
- Noviembre está **incompleto** (14 días).
- Abril a octubre muestran una mediana estable entre 54 y 66 min.

### 7.7 Comparabilidad histórica

| Cambio estructural | Efecto |
|---|---|
| Convivencia WHATMETA (2026-02→) y WHATICKET (2025-10→) | Dos herramientas con comportamiento distinto; no se pueden sumar |
| Entrada de ZENDESK desde 2026-03-17 | Antes de esa fecha no hay correo comparable |
| Cambio de mediana en abril 2026 | Sugiere estabilización operativa; antes no es comparable |
| Etiquetas crudas sin normalizar | La comparación por subcategoría entre meses es débil |

**Recomendación:** usar **2026-04-01 → 2026-10-31** como período de referencia y recalcular el SLA cada trimestre.

---

## 8. Limitaciones que condicionan el SLA

1. **Cobertura parcial:** solo 10 asesores monitoreados, no toda la empresa.
2. **Sin fecha de cierre:** no se puede convertir tiempo calendario en tiempo hábil con evidencia.
3. **Sin marcas de pausa:** no se distingue espera del cliente de espera por terceros.
4. **Sin campo de canal en Zendesk:** la equivalencia Zendesk = correo es inferida.
5. **Categoría derivada:** no existe clasificación de dos niveles independiente.
6. **39 % del volumen fuera del catálogo oficial:** el árbol de 65 subcategorías no cubre la operación.
7. **Nombre de ticket no es único global:** `ticket_id` colisiona entre sistemas.
8. **Hora de Zendesk en UTC:** análisis horario de correo no utilizable.

---

## 9. Consultas de reproducción

Todas son `SELECT` de solo lectura. No se creó ninguna tabla temporal.

```sql
-- Volumen y ventana
SELECT subcanal, COUNT(*), MIN(fecha), MAX(fecha)
FROM public.v_unificado_norm GROUP BY 1 ORDER BY 2 DESC;

-- Calidad de tiempos
SELECT canal,
       COUNT(*) FILTER (WHERE resolucion_min_norm IS NULL) AS nulos,
       COUNT(*) FILTER (WHERE resolucion_min_norm = 0)    AS ceros,
       COUNT(*) FILTER (WHERE resolucion_min_norm < 0)    AS negativos,
       COUNT(*) FILTER (WHERE resolucion_min_norm > 10080) AS mas_7d
FROM public.v_unificado_norm
WHERE estado_homologado IN ('cerrado','resuelto')
GROUP BY 1;

-- Estadísticos base por canal y categoría
SELECT canal, categoria, COUNT(*) AS n,
       percentile_cont(0.5)  WITHIN GROUP (ORDER BY resolucion_min_norm) AS mediana,
       percentile_cont(0.75) WITHIN GROUP (ORDER BY resolucion_min_norm) AS p75,
       percentile_cont(0.90) WITHIN GROUP (ORDER BY resolucion_min_norm) AS p90
FROM public.v_unificado_norm
WHERE estado_homologado IN ('cerrado','resuelto')
  AND resolucion_min_norm > 0
  AND fecha BETWEEN '2026-04-01' AND '2026-10-31'
GROUP BY 1,2 ORDER BY 1,3 DESC;
```

---

## 10. Confirmación

- No se modificó código de COSE ni de Zammad.
- No se modificaron tablas, vistas, registros ni funciones.
- No se crearon tablas temporales persistentes.
- No se creó ni editó ningún SLA.
- No se modificó el calendario.
- No se activaron workers ni se conectó ningún buzón.
- No se consultó la API de Zendesk.
