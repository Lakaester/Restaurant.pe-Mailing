# MATRIZ DE RATIFICACIÓN — 28 SUBCATEGORÍAS CON RESPALDO DE SERVICIO

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Épica:** EPIC-SLA-01
**Fecha de preparación:** 17/11/2026
**Naturaleza:** **matriz de ratificación. Pendiente de firma de Soporte.** No es una aprobación.
**Observación que atiende:** OBS-30 (clases del catálogo) y DP-04 (responsable del catálogo)
**Documento base:** `MATRIZ_POLITICAS_CATALOGO_SLA.md` (65 filas, 27/3/28/7, generado y verificado)

---

## 1. Para qué sirve este documento

La matriz oficial de 5G.4.4 tiene 30 combinaciones: 27 con SLA y 3 sin evidencia suficiente. El catálogo oficial tiene 65 subcategorías. Las **28 restantes** son subcategorías de servicio que no aparecen en las 30 filas y que, por BR-43, reciben el respaldo de **36 h (2.160 min)** marcado como `provisional`.

Que el respaldo esté aprobado no significa que esté aprobado **a qué subcategorías se aplica**. Eso es lo que ratifica Soporte con esta matriz, fila por fila.

**Por qué importa:** el respaldo de 36 h gobernaría 1 de cada 3 tickets clasificados (`RESUMEN_EJECUTIVO_5G4_5.md` §2: 1.016 de 3.125, 32,51 %). Ratificar estas 28 filas es ratificar el régimen que gobierna ese tercio.

---

## 2. Reglas de ratificación

Soporte debe pronunciarse sobre **cada fila** con una de estas tres respuestas:

| Respuesta | Significado | Consecuencia |
|---|---|---|
| **RATIFICO** | Es una subcategoría de servicio y le corresponde el respaldo de 36 h | La fila se carga como `99-FALLBACK`, `provisional = true` |
| **EXCLUIR** | No es un caso de servicio (equivale a ampliar DEC-05) | La fila pasa a `excluded_non_service`; **requiere enmienda formal de DEC-05**, no basta esta firma |
| **PROMOVER** | Tiene volumen e interés para tener SLA propio | **No se puede promover sin evidencia**: exige n ≥ 10 y P75 calculado sobre datos reales. No se decide en esta matriz; se abre como candidata a la próxima revisión de la matriz |

**Reglas que limitan la ratificación (no son opcionales):**

1. Ninguna fila puede ratificarse como «SLA de matriz» sin n ≥ 10 y P75 verificados (EPIC §6.1).
2. Las 3 combinaciones sin evidencia **no** reciben respaldo (BR-42). No forman parte de este documento.
3. Las 7 exclusiones DEC-05 **no** reciben respaldo (BR-65). No forman parte de este documento.
4. Esta matriz no modifica cantidades: 27 + 3 + 28 + 7 = 65.
5. La ratificación no altera `category` ni `subcategory`: se conservan las etiquetas oficiales con tildes.

---

## 3. Resumen por categoría

| Categoría | Subcategorías con respaldo | Contexto¹ |
|---|---:|---:|
| FACTURACIÓN ELECTRÓNICA | 4 | 284 |
| LOGÍSTICA | 3 | 0 |
| INTEGRACIONES | 2 | 9 |
| SOFTWARE | 3 | 131 |
| GESTIÓN | 2 | 404 |
| ADMINISTRATIVO | 4 | 188 |
| OPERATIVO | 3 | 0 |
| CAPACITACIÓN | 5 | 0 |
| SERVIDOR | 2 | 0 |
| **Total** | **28** | **1.016** |

¹ **Contexto:** tickets de la categoría que quedaron **fuera de las 30 filas de la matriz** en la ventana medida (`RESUMEN_EJECUTIVO_5G4_5.md` §2). **No** es el volumen de la subcategoría concreta: es una señal de prioridad. Las categorías sin cifra tuvieron 0 tickets fuera de la matriz en esa ventana.

**Lectura:** el respaldo se concentra en GESTIÓN (404), FACTURACIÓN ELECTRÓNICA (284), ADMINISTRATIVO (188) y SOFTWARE (131). Estas cuatro categorías explican el 99,1 % del volumen fuera de la matriz. Si Soporte solo puede revisar una parte, el orden de prioridad es ese.

---

## 4. Las 28 filas

### FACTURACIÓN ELECTRÓNICA (4)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 1 | Activacion NV | `activacion_nv` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 284 | Pendiente | — |
| 4 | Cambio impuesto FE | `cambio_impuesto_fe` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 284 | Pendiente | — |
| 12 | Consecutivos topes folios | `consecutivos_topes_folios` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 284 | Pendiente | — |
| 13 | FE solicitud xml pdf | `fe_solicitud_xml_pdf` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 284 | Pendiente | — |

### LOGÍSTICA (3)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 15 | Capacitación logistica avanzado | `capacitación_logistica_avanzado` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 16 | Capacitación logistica insumos recetas | `capacitación_logistica_insumos_recetas` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 18 | Temas operativos punto de venta | `temas_operativos_punto_de_venta` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |

### INTEGRACIONES (2)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 22 | Solicitud de integracion uber | `solicitud_de_integración_uber` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 9 | Pendiente | — |
| 23 | Integraciones y apis | `integraciones_y_apis` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 9 | Pendiente | — |

### SOFTWARE (3)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 29 | Error backend | `error_backend` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 131 | Pendiente | — |
| 30 | Mejora personalizada | `mejora_personalizada` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 131 | Pendiente | — |
| 32 | Error add on asistencias | `error_add_on_asistencias` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 131 | Pendiente | — |

### GESTIÓN (2)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 34 | Seguimiento de cdt | `seguimiento_de_cdt` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 404 | Pendiente | — |
| 38 | Pagos prorrogas descuentos | `pagos__prorrogas__descuentos` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 404 | Pendiente | — |

### ADMINISTRATIVO (4)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 40 | Baja sucursal | `baja_sucursal` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 188 | Pendiente | — |
| 41 | Cambio de razón social | `cambio_de_razón_social` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 188 | Pendiente | El mismo rótulo existe en FACTURACIÓN ELECTRÓNICA con SLA de matriz (4.320 min). La clave por par categoría/subcategoría es la que evita la ambigüedad |
| 42 | Temas administrativos | `temas_administrativos_o_configuraciones_del_sistema` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 188 | Pendiente | — |
| 44 | Activación de Addons | `activación_de_addons` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 188 | Pendiente | — |

### OPERATIVO (3)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 46 | Cajas | `cajas` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 47 | Redes y conexiones | `redes_y_conexiones` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | El mismo rótulo existe en SERVIDOR. Ambos son respaldo; Soporte debe decidir si se mantienen separados |
| 48 | Caída del servidor | `caída_del_servidor` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | El mismo rótulo existe en SERVIDOR. Ambos son respaldo; Soporte debe decidir si se mantienen separados |

### CAPACITACIÓN (5)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 49 | Capacitación logistica | `capacitación_logistica` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 50 | Capacitación integraciones | `capacitación_integraciones` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 52 | Capacitación adm Productos | `capacitación_adm_productos` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 53 | Capacitación operativa | `capacitación_operativa` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |
| 54 | Capacitación delivery pro | `capacitación_delivery_pro` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | — |

### SERVIDOR (2)

| # | Subcategoría | Slug | Política propuesta | Fundamento | Contexto¹ | Estado | Observación |
|---:|---|---|---|---|---:|---|---|
| 56 | Caída del servidor | `caída_del_servidor` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | El mismo rótulo existe en OPERATIVO. Ambos son respaldo; Soporte debe decidir si se mantienen separados |
| 57 | Redes y conexiones | `redes_y_conexiones` | `99-FALLBACK` · 2.160 min (36 h) · provisional | Fuera de las 30 filas; no figura en DEC-05 | 0 | Pendiente | El mismo rótulo existe en OPERATIVO. Ambos son respaldo; Soporte debe decidir si se mantienen separados |

---

## 5. Advertencias que Soporte debe conocer

1. **Tres rótulos están duplicados en el catálogo.** `cambio_de_razón_social`, `redes_y_conexiones` y `caída_del_servidor` aparecen en dos categorías. Por eso la política se identifica por el **par categoría/subcategoría** y no por el slug. En el caso de `Cambio de razón social` la diferencia es material: FACTURACIÓN ELECTRÓNICA tiene 72 h de matriz y ADMINISTRATIVO tendría 36 h de respaldo.
2. **El respaldo no es una política negociada con el cliente.** Es una regla interna, provisional y revisable. La propia matriz lo marca así (`provisional = true`).
3. **Los cinco rótulos de mayor volumen fuera de catálogo no están en esta matriz.** `consultas generales` (283), `consultas fe` (159), `comunicacion de baja` (134), `seguimiento de cdt certificado` (97) y `mejoras personalizadas` (94) no son subcategorías del catálogo de 65; no se pueden ratificar como filas del catálogo. Su incorporación es el trabajo de DP-04.
4. **El respaldo no mejora la métrica.** Mientras un tercio del volumen dependa de 36 h, la métrica de resolución mide en buena parte el respaldo. Es el riesgo R-06 del `RESUMEN_EJECUTIVO_5G4_5.md`, medido, no estimado.

---

## 6. Ficha de ratificación

| Campo | Valor |
|---|---|
| **Decisión solicitada** | Ratificar las 28 subcategorías como servicio con respaldo de 36 h, o marcar las excepciones |
| **Responsable de aprobar** | Soporte (dueño funcional del catálogo) |
| **Corresponsable** | Dueño del catálogo designado por DP-04 |
| **Efecto si se ratifica** | Las 28 filas se cargan con `policy_class = 'fallback'`, `99-FALLBACK`, `provisional = true` |
| **Efecto si no se ratifica** | La carga de políticas se detiene: no se puede cargar un mapa de clases incompleto sin inventar el resto |
| **Efecto sobre el DDL** | Ninguno |
| **Efecto sobre la migración** | Ninguno: la carga es un paso posterior a la aplicación del esquema |

### 6.1 Firma por categoría

| Categoría | Subcategorías | RATIFICO | EXCLUIR (indicar cuáles) | PROMOVER (indicar cuáles) | Fecha |
|---|---:|---|---|---|---|
| FACTURACIÓN ELECTRÓNICA | 4 | ☐ | | | |
| LOGÍSTICA | 3 | ☐ | | | |
| INTEGRACIONES | 2 | ☐ | | | |
| SOFTWARE | 3 | ☐ | | | |
| GESTIÓN | 2 | ☐ | | | |
| ADMINISTRATIVO | 4 | ☐ | | | |
| OPERATIVO | 3 | ☐ | | | |
| CAPACITACIÓN | 5 | ☐ | | | |
| SERVIDOR | 2 | ☐ | | | |

| Rol | Nombre | Fecha | Firma |
|---|---|---|---|
| Soporte — dueño funcional | | | |
| Dueño del catálogo (DP-04) | | | |

**Estado:** preparada, **no firmada**. Mientras no haya firma, las 28 filas figuran como **clase derivada pendiente de ratificación** y OBS-30 sigue resuelta **técnicamente**, no aprobada.

---

## 7. Confirmación

- No se ejecutó SQL ni se conectó a PostgreSQL.
- No se cargó ninguna política en ninguna base de datos.
- No se modificó el catálogo, el JSON exportado, la matriz de 5G.4.4 ni las 65 filas ya verificadas.
- No se alteraron las cantidades 27 / 3 / 28 / 7.
- No se tocó Zammad, sus tablas, sus workers ni sus credenciales.
- No se hizo commit ni push.
