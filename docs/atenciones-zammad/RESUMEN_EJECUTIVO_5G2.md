# RESUMEN EJECUTIVO — ETAPA 5G.2

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2 — Auditoría estadística de COSE para diseño de SLA
**Fecha:** 14/11/2026
**Modo:** solo lectura. Sin escrituras en bases de datos, sin cambios en COSE ni en Zammad.

---

## 1. Qué se hizo

Se auditó la base histórica de COSE (`public.v_unificado_norm`), se homologaron canales y categorías contra el catálogo oficial, se midió la calidad del dato y se calculó la distribución de tiempos de resolución por canal × categoría × subcategoría. Con esa evidencia se construyó una propuesta de SLA de resolución y se evaluó su viabilidad en Zammad 7.2.3.

**No se creó ningún SLA.** **No se modificó ningún sistema.**

---

## 2. Resultados principales

### 2.1 Volumen

| Elemento | Valor |
|---|---:|
| Filas en la vista | 24.754 |
| Tickets distintos | 24.752 |
| Cerrados/resueltos | 24.137 (97,5 %) |
| Ventana total | 2025-10-10 → 2026-11-14 |
| Ventana recomendada | **2026-04-01 → 2026-10-31** |
| Muestra analizada (ventana, canales válidos) | **20.193** |
| Muestra con subcategoría oficial | **10.750** |

### 2.2 Canales

| Canal | Registros | ¿Homologado? |
|---|---:|---|
| WhatsApp / WHATMETA | 17.731 | Sí |
| WhatsApp / WHATICKET | 1.360 | **Parcial** — legado no comparable |
| Correo / ZENDESK | 5.663 | **Inferido** — 19,3 % sin correo |

No hay registros sin canal ni tickets compartidos entre canales.

### 2.3 Tiempos de resolución

| Canal | n | Mediana | P75 | P90 |
|---|---:|---:|---:|---:|
| WhatsApp (WHATMETA) | 8.641 | 50 min | 84 min | 131 min |
| Correo (ZENDESK) | 2.109 | 506 min (8,4 h) | 1.783 min (29,7 h) | 5.261 min (87,7 h) |

**Diferencia estructural:** WhatsApp resuelve en minutos, correo en horas o días. La mediana de correo es 10× la de WhatsApp. No comparten escala.

### 2.4 Categorías

- **13 categorías / 65 subcategorías** en el catálogo oficial (`CategoryData.ts`), con 3 etiquetas duplicadas entre categorías.
- La tabla de homologación de COSE tiene **13 categorías distintas**, no las mismas: faltan `RECLAMO`, `QUEJA`, `DEVOLUCIÓN` y sobran `ADD ONS`, `DUPLICADA`, `DUPLICADO`, `NO CONTESTO`.
- **39 % de las filas no se puede clasificar** con el catálogo oficial.
- La categoría en COSE **no es un campo independiente**: se deriva de la subcategoría.

### 2.5 Calidad del dato

| Defecto | Magnitud |
|---|---:|
| Resolución nula | 24 |
| Resolución = 0 | 582 |
| Resolución negativa | 0 |
| Resolución > 7 días | 163 |
| Resolución > 30 días | 1 |
| Primera respuesta nula | 553 (todo correo) |
| Duplicados de ticket | 2 |
| Abiertos / sin mapear | 617 |
| Hora de Zendesk en UTC | Todo el canal correo |
| `efficiency_first_resolution` = resolución completa | 57,9 % de Zendesk |

---

## 3. Propuesta de SLA de resolución

### 3.1 Metodología

Ancla en el **percentil 75**, redondeado hacia arriba a una escalera operativa. Nunca el promedio (dominado por la cola) ni el P90 (copia automática).

### 3.2 Resultado

| Canal | SLA de respaldo | Combinaciones con SLA | Sin SLA |
|---|---:|---:|---:|
| WhatsApp | **1 h 30 min** | 37 | 2 |
| Correo | **36 h** | 28 | 3 |

**Cobertura:** 10.750 tickets (68,9 % de la muestra de servicio). El 31,1 % restante no tiene subcategoría oficial y recibiría el SLA de respaldo del canal.

### 3.3 Metas de primera respuesta (sin cambios)

| Canal | Meta |
|---|---|
| WhatsApp | **< 15 minutos** |
| Correo | **< 24 horas** |

No se recalcularon ni se modificaron.

---

## 4. Hallazgos que cambian el diseño

### 4.1 Un ticket recibe un solo SLA

Zammad aplica **una sola política por ticket** (`Sla.for_ticket` devuelve un registro). Por tanto no se puede tener "primera respuesta por canal" y "resolución por categoría" como políticas separadas: cada política debe llevar **ambas metas**.

### 4.2 La precedencia es alfabética

Las políticas se evalúan por `ORDER BY name`, no por especificidad. Una política mal nombrada gana a otra más específica. **El nombre es el mecanismo de precedencia.**

### 4.3 El calendario cambia la exigencia

Los datos históricos son **tiempo calendario**. Zammad mide en **tiempo hábil**. El calendario ID 2 cubre 92 de 168 horas semanales (54,8 %), así que el mismo número de minutos resulta **~1,83× más laxo** en tiempo de reloj.

**Ningún valor debe publicarse sin resolver esta conversión.**

### 4.4 El catálogo no describe la operación

Un tercio del volumen usa etiquetas que no existen en el árbol oficial (`sin categorizar`, etiquetas concatenadas, variantes ortográficas, categorías operativas no contempladas). Diseñar SLA por subcategoría sobre el catálogo actual deja ese volumen fuera.

### 4.5 La primera respuesta de Zendesk no es fiable

`efficiency_first_resolution` es idéntico a `efficiency_full_resolution_time` en el 57,9 % de los registros. Ese campo mide resolución completa, no primera respuesta. Refuerza la decisión de **no recalcular** la primera respuesta con estos datos.

---

## 5. Compatibilidad con Zammad 7.2.3

| Capacidad | Resultado |
|---|---|
| SLA por canal | **Soportado** |
| SLA por categoría/subcategoría | **Soportado vía `categoria_subcategoria`**, operador por validar |
| Calendario ID 2 | **Soportado** (`calendar_id` obligatorio) |
| Pausas | **Soportado** por estados con `ignore_escalation` |
| Recálculo al cambiar categoría | **Sí**, en cada guardado |
| Recálculo de estadísticas al cambiar SLA | **No** (limitación del código) |
| Superposición de políticas | **Sí, por nombre** |
| API CRUD | **Sí** (`/api/v1/slas`) |
| Administrador propio | **Viable**, sin simulación ni recálculo histórico |

**Arquitectura recomendada:** híbrida. Núcleo de 3 políticas nativas (`00 - WhatsApp`, `01 - Correo`, `99 - Respaldo`) más una capa de excepciones generada solo donde la evidencia lo justifique. No crear 65 políticas para reproducir tres valores.

---

## 6. Limitaciones del análisis

1. **Cobertura parcial:** la vista filtra por una lista cerrada de ~10 asesores; no representa toda la empresa.
2. **Sin fecha de cierre ni marcas de pausa:** no se puede calcular tiempo hábil ni separar espera del cliente de espera por terceros.
3. **Zendesk sin campo de canal:** la equivalencia con correo es inferida, no demostrada.
4. **Categoría derivada:** no existe clasificación de dos niveles independiente; 3 etiquetas son ambiguas por diseño.
5. **Catálogo incompleto:** 31 % del volumen de servicio sin subcategoría oficial.
6. **Hora de correo en UTC:** el análisis horario de correo no es interpretable.
7. **Ventana corta:** 7 meses; los cambios de herramienta pueden alterar la comparabilidad.
8. **WHATICKET excluido:** 206 casos de servicio con comportamiento 5,6× más lento.

---

## 7. Recomendaciones

### 7.1 Antes de publicar cualquier SLA

1. Resolver **D-03** (tiempo calendario vs. hábil) y **D-08** (estados que pausan): sin esto, los números son incorrectos.
2. Resolver **D-04** (feriados).
3. Confirmar **D-01** (ventana) y **D-02** (Zendesk sin correo).

### 7.2 Sobre el diseño

4. Adoptar la arquitectura híbrida de 3 políticas núcleo + excepciones.
5. Fijar la convención de nombres antes de crear la primera política.
6. Publicar SLA solo para combinaciones con n ≥ 30 y diferencia material frente al respaldo.
7. Marcar explícitamente las 5 combinaciones sin evidencia como `PENDIENTE DE VALIDACIÓN`.

### 7.3 Sobre los datos

8. Revisar el catálogo de subcategorías antes de producción (D-10).
9. Normalizar las etiquetas de origen y las concatenaciones de Zendesk.
10. Incorporar `closed_at`, marcas de pausa y hora local en la vista para poder medir tiempo hábil.
11. Recalcular la matriz cada 90 días.

### 7.4 Sobre el gobierno

12. No administrar SLA a mano: generarlos desde la matriz y versionarlos.
13. Registrar en cada política la versión de la matriz que la originó.

---

## 8. Entregables de la etapa

| Documento | Contenido |
|---|---|
| `AUDITORIA_DATOS_SLA_COSE.md` | Modelo de datos, campos, unidades, canales, categorías y calidad |
| `ANALISIS_ESTADISTICO_RESOLUCION.md` | Estadísticos por canal, categoría y subcategoría |
| `MATRIZ_PROPUESTA_SLA_RESOLUCION.md` | Propuesta de metas, volumen y confianza |
| `COMPATIBILIDAD_SLA_ZAMMAD.md` | Capacidades nativas, limitaciones y arquitectura |
| `DECISIONES_PENDIENTES_SLA.md` | 12 decisiones que Victor debe aprobar |
| `RESUMEN_EJECUTIVO_5G2.md` | Este documento |

---

## 9. Conclusión

La evidencia histórica **permite** proponer SLA de resolución diferenciados: hay volumen suficiente en 65 combinaciones de subcategoría y 18 de categoría.

Pero la evidencia **no permite todavía publicarlos**, por cuatro razones concretas:

1. Los tiempos históricos son calendario y Zammad mide en horas hábiles.
2. Un tercio del volumen no tiene subcategoría oficial.
3. No hay marcas de pausa ni de espera por terceros.
4. La equivalencia Zendesk = correo no está demostrada para el 19,3 % de ese canal.

La propuesta es sólida como **base de decisión**. No es un conjunto de metas listas para producción.

---

## 10. Confirmación de no intervención

- No se modificó código de COSE.
- No se modificó código de Zammad.
- No se modificaron tablas, vistas, registros ni funciones SQL.
- No se crearon tablas temporales persistentes.
- No se modificaron configuraciones.
- No se creó ni editó ningún SLA en Zammad.
- No se modificó el calendario ni se crearon feriados.
- No se activaron workers ni jobs.
- No se conectó Zendesk (ni su API productiva).
- No se conectaron buzones.
- No se ejecutaron migraciones.
- No se instalaron dependencias.
- No se generaron escrituras en bases de datos empresariales.
- No se modificaron reportes ni dashboards existentes.
- No se sobrescribió ningún documento previo.
- Los cálculos intermedios se hicieron en memoria; no quedaron archivos temporales en los repositorios.

**No se creó SLA, no se desarrolló el administrador, no se inició el BFF y no se comenzó la Etapa 5G.3.**
