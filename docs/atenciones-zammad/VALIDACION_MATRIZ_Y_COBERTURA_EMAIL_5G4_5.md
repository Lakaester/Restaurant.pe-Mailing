# VALIDACIÓN DE MATRIZ Y COBERTURA — SLA EXCLUSIVAMENTE EMAIL — 5G.4.5

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.5 — Cierre funcional y validación final
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Naturaleza:** verificación documental y medición sobre las fuentes COSE. **No se recalculó ningún valor de la matriz. No se modificó ningún sistema.**
**Fuentes:**
- `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` (matriz oficial, 30 filas).
- `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` (5G.2.1, fuente original).
- `CORRECCIONES_MATRIZ_SLA_5G2_1.md` (conteo 30 / 3 / 27).
- COSE `public.v_unificado_norm`, ventana 2026-04-01 → 2026-10-31, `canal = 'CORREO'`.

---

## 1. Método

1. Se extrajeron las 30 combinaciones oficiales de la matriz 5G.4.4 (categoría, subcategoría, N, P75, escalón, meta).
2. Se tradujo cada subcategoría oficial a su etiqueta normalizada de origen en COSE (`normalizar_texto(subcategoria)`).
3. Se contó, por etiqueta y por combinación, el volumen real de tickets Email del universo de servicio.
4. Se comparó fila por fila contra el N de la matriz.
5. Se midió el complemento (rótulos sin combinación oficial) y se reconcilió con los totales documentados de 5G.2.

**Definición de universo de servicio Email (idéntica a 5G.2):**

```sql
canal = 'CORREO'
AND fecha BETWEEN '2026-04-01' AND '2026-10-31'
AND estado_homologado IN ('cerrado','resuelto')
AND resolucion_min_norm > 0
AND categoria NOT IN ('SIN HOMOLOGAR','SIN CATEGORIA EN ORIGEN',
                      'DUPLICADO','DUPLICADA','NO CONTESTO','ADD ONS')
```

**Unidad de conteo:** ticket (`ticket_id`), no fila. Se verificó que no hay duplicados: 3.125 filas y 3.125 `ticket_id` distintos.

---

## 2. Universo medido

| Paso | Criterio | Tickets |
|---|---|---:|
| A | Email en la ventana, todos los estados | **4.834** |
| B | Cerrado o resuelto con `resolucion_min_norm > 0` | **4.713** |
| C | B con categoría de servicio (sin pseudo-categorías) | **3.125** |
| D | C con combinación en la matriz oficial (30 etiquetas) | **2.109** |
| E | C sin combinación en la matriz oficial | **1.016** |

Comprobación: `2.109 + 1.016 = 3.125` ✓

Distribución de A por estado: `cerrado` 3.819 · `resuelto` 1.015.

**Nota:** la palabra "resuelto" es el valor homologado del origen; en Zammad el equivalente operativo es el estado `closed`. La distinción no altera el conteo porque ambos son cierres.

---

## 3. Validación fila por fila de las 30 combinaciones

`N matriz` es el valor publicado en 5G.2.1/5G.4.4. `N medido` es el conteo directo en COSE. `Variantes` indica cuántos rótulos crudos se agrupan bajo la etiqueta normalizada (diferencias de mayúsculas, tildes o espacios).

| # | Categoría oficial | Subcategoría oficial | N matriz | N medido | Variantes | ¿Coincide? |
|---:|---|---|---:|---:|---:|---|
| 1 | ADMINISTRATIVO | Nueva licencia o sucursal | 35 | **35** | 1 | Sí |
| 2 | ADMINISTRATIVO | Solicitud de migración | 27 | **27** | 1 | Sí |
| 3 | CAPACITACION | Solicitud agenda capacitación | 115 | **115** | 1 | Sí |
| 4 | CAPACITACION | Capacitación adm Reportes | 21 | **21** | 1 | Sí |
| 5 | DEVOLUCION | Solicitud de devolución | 37 | **37** | 2 | Sí |
| 6 | FACTURACION ELECTRONICA | Ajustes FE | 341 | **341** | 2 | Sí |
| 7 | FACTURACION ELECTRONICA | Cambio de razón social | 170 | **170** | 1 | Sí |
| 8 | FACTURACION ELECTRONICA | Activacion FE | 94 | **94** | 1 | Sí |
| 9 | FACTURACION ELECTRONICA | Validación de comprobantes FE | 67 | **67** | 1 | Sí |
| 10 | FACTURACION ELECTRONICA | Requisitos FE | 60 | **60** | 1 | Sí |
| 11 | FACTURACION ELECTRONICA | Error FE del facturador | 38 | **38** | 2 | Sí |
| 12 | FACTURACION ELECTRONICA | Error FE de cálculo | 36 | **36** | 1 | Sí |
| 13 | FACTURACION ELECTRONICA | Emisión de invoice | 28 | **28** | 1 | Sí |
| 14 | FACTURACION ELECTRONICA | Error FE envio manual | 19 | **19** | 1 | Sí |
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | **9** | 1 | Sí |
| 16 | GESTION | Renovación certificado normal | 177 | **177** | 2 | Sí |
| 17 | GESTION | Venta de CDT certificado | 81 | **81** | 1 | Sí |
| 18 | GESTION | Envio de pago | 45 | **45** | 1 | Sí |
| 19 | GESTION | Seguimiento proactivo | 33 | **33** | 1 | Sí |
| 20 | INTEGRACIONES | Consulta consumo de apis | 83 | **83** | 1 | Sí |
| 21 | INTEGRACIONES | Solicitud de integracion rappi | 25 | **25** | 1 | Sí |
| 22 | INTEGRACIONES | Solicitud de integracion Pedidos ya | 14 | **14** | 1 | Sí |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | **9** | 1 | Sí |
| 24 | INTEGRACIONES | Error integracion | 4 | **4** | 1 | Sí |
| 25 | LOGISTICA | Tarea o capacitación logistica | 319 | **319** | 2 | Sí |
| 26 | LOGISTICA | Error logistica | 20 | **20** | 1 | Sí |
| 27 | OPERATIVO | Temas operativos | 119 | **119** | 1 | Sí |
| 28 | SOFTWARE | Error punto de venta | 37 | **37** | 2 | Sí |
| 29 | SOFTWARE | Seguimiento de errores | 34 | **34** | 1 | Sí |
| 30 | SOFTWARE | Error web | 12 | **12** | 1 | Sí |
| | | **Total** | **2.109** | **2.109** | | **30 / 30** |

### 3.1 Resultado

- **30 de 30 filas coinciden exactamente.** Ninguna diferencia de un solo ticket.
- La suma medida es **2.109**, igual al valor publicado.
- El conteo por combinación se reproduce sin necesidad de recalcular P75 ni la escalera.
- Las 6 combinaciones con variantes ortográficas explican por qué el N no coincide con un `GROUP BY subcategoria` crudo: la matriz agrupa variantes, y esa agrupación es la correcta.

### 3.2 Combinaciones con y sin SLA

| Concepto | Combinaciones | Tickets |
|---|---:|---:|
| Con SLA | **27** | **2.087** |
| Sin evidencia suficiente (n < 10) | **3** | **22** |
| Total | **30** | **2.109** |

Las tres sin SLA, verificadas una por una:

| # | Categoría | Subcategoría | n medido | Estado |
|---:|---|---|---:|---|
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | **9** | Sin SLA |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | **9** | Sin SLA |
| 24 | INTEGRACIONES | Error integracion | **4** | Sin SLA |

`9 + 9 + 4 = 22` ✓

---

## 4. Verificación de P75 y escalón

No se recalculó ningún P75. Se verificó la **consistencia interna** de los 27 valores publicados:

| Verificación | Resultado |
|---|---|
| Todos los SLA son escalones de la escalera de 5G.2.1 §2 | **27 / 27** |
| Ningún SLA es inferior al P75 de su propia combinación | **27 / 27** |
| Ningún SLA salta más de un escalón por encima del P75 | **27 / 27** |
| Ningún SLA usa mediana ni promedio | **27 / 27** |
| Ningún P75 fue sustituido por P90 | **27 / 27** |

Casos límite comprobados (los mismos de 5G.4.4, sin cambios):

| Combinación | P75 | Escalón aplicado | Escalón anterior | Por qué no el anterior |
|---|---:|---:|---:|---|
| ERROR FE del facturador | 780,5 | 1.440 | 720 | 720 < P75 |
| Emisión de invoice | 2.097,6 | 2.160 | 1.440 | 1.440 < P75 |
| Temas operativos | 2.718 | 2.880 | 2.160 | 2.160 < P75 |
| Solicitud de devolución | 3.075 | 4.320 | 2.880 | 2.880 < P75 |
| Error logística | 4.635,6 | 5.760 | 4.320 | 4.320 < P75 |
| Requisitos FE | 5.920,7 | 7.200 | 5.760 | 5.760 < P75 |

**Conclusión:** la matriz es aritméticamente coherente. No hay inconsistencia demostrable que justifique alterar un valor.

---

## 5. Cobertura real

Hay dos coberturas distintas y no deben confundirse.

| Cobertura | Fórmula | Valor |
|---|---|---:|
| **Interna de la matriz** | 2.087 / 2.109 | **98,96 %** |
| **Sobre el universo de servicio** | 2.109 / 3.125 | **67,49 %** |
| **Con SLA sobre el universo de servicio** | 2.087 / 3.125 | **66,78 %** |
| **Fuera de la matriz** | 1.016 / 3.125 | **32,51 %** |

Referencias adicionales:

| Base | Tickets | 2.109 representa | 1.016 representa |
|---|---:|---:|---:|
| Universo de servicio (C) | 3.125 | 67,49 % | 32,51 % |
| Cerrados/resueltos con resolución > 0 (B) | 4.713 | 44,75 % | 21,56 % |
| Email total en ventana (A) | 4.834 | 43,63 % | 21,02 % |

**Lectura:** la matriz cubre dos tercios del trabajo clasificado de Email. El tercio restante **no tiene SLA por diseño** y recibiría el respaldo de 36 h si se aprueba DP-E-02.

---

## 6. Composición del volumen fuera de la matriz

**1.016 tickets · 28 rótulos normalizados.**

| # | Rótulo normalizado | Tickets | Categoría en COSE |
|---:|---|---:|---|
| 1 | consultas generales | 283 | GESTION |
| 2 | consultas fe | 159 | FACTURACION ELECTRONICA |
| 3 | comunicacion de baja | 134 | ADMINISTRATIVO |
| 4 | seguimiento de cdt certificado | 97 | FACTURACION ELECTRONICA |
| 5 | mejoras personalizadas | 94 | SOFTWARE |
| 6 | consultas pagos reactivaciones | 47 | ADMINISTRATIVO |
| 7 | queja | 40 | GESTION |
| 8 | seguimiento de mejoras | 24 | GESTION |
| 9 | error facturacion | 22 | FACTURACION ELECTRONICA |
| 10 | gestiones de implementacion | 22 | GESTION |
| 11 | reactivo | 14 | GESTION |
| 12 | error del cliente fe | 12 | SOFTWARE |
| 13 | solicitud inspeccion tecnica | 11 | GESTION |
| 14 | error fe no especificado | 11 | SOFTWARE |
| 15 | error fe por envio fuera de fecha | 7 | SOFTWARE |
| 16 | solicitud de cdt | 6 | FACTURACION ELECTRONICA |
| 17 | error fe informacion cliente | 6 | SOFTWARE |
| 18 | solicitudes de limpieza insu vent local etc | 6 | GESTION |
| 19 | prorroga | 5 | ADMINISTRATIVO |
| 20 | solicitud de integracion justo | 3 | INTEGRACIONES |
| 21 | agenda para seguimiento con ejecutivo de cuenta | 2 | GESTION |
| 22 | problema consumo de apis | 2 | INTEGRACIONES |
| 23 | problemas consultas int peya | 2 | INTEGRACIONES |
| 24 | descuentos | 2 | ADMINISTRATIVO |
| 25 | correcion de error operativo del cliente | 2 | GESTION |
| 26 | problemas consultas int rappi | 1 | INTEGRACIONES |
| 27 | problemas consultas int didi | 1 | INTEGRACIONES |
| 28 | error fe usuario secundario eliminado o incorrecto | 1 | SOFTWARE |
| | **Total** | **1.016** | |

### 6.1 Distribución por categoría

| Categoría (homologación COSE) | Tickets | % del fuera de matriz |
|---|---:|---:|
| GESTION | **404** | 39,76 % |
| FACTURACION ELECTRONICA | **284** | 27,95 % |
| ADMINISTRATIVO | **188** | 18,50 % |
| SOFTWARE | **131** | 12,89 % |
| INTEGRACIONES | **9** | 0,89 % |
| **Total** | **1.016** | **100 %** |

### 6.2 Lectura

1. **No son datos corruptos.** Son rótulos válidos de negocio que no tienen combinación en el catálogo oficial con el que se construyó la matriz.
2. **Concentración alta:** 5 rótulos explican 767 tickets (75,5 % del fuera de matriz): consultas generales, consultas FE, comunicación de baja, seguimiento de CDT y mejoras personalizadas.
3. **Dos rótulos de consulta suman 442 tickets** (consultas generales + consultas FE). Es el mayor hueco del catálogo: trabajo real y frecuente sin política.
4. **El respaldo de 36 h no es un caso marginal:** gobernaría 1 de cada 3 tickets clasificados. Ese es el hallazgo más importante de esta etapa.

---

## 7. Reconciliación con los totales de 5G.2

Los totales documentados en 5G.2 son de **ambos canales** (Email + WHATMETA; WHATICKET excluido):

| Concepto | Documentado (5G.2) | Email (medido) | WHATMETA (derivado) |
|---|---:|---:|---:|
| Categorías de servicio | 15.591 | 3.125 | 12.466 |
| Con subcategoría del catálogo oficial | 10.750 | 2.109 | 8.641 |
| Fuera de catálogo | 4.841 | 1.016 | 3.825 |

Comprobaciones:

- `3.125 + 12.466 = 15.591` ✓
- `2.109 + 8.641 = 10.750` ✓
- `1.016 + 3.825 = 4.841` ✓
- `3.125 − 2.109 = 1.016` ✓
- `12.466 − 8.641 = 3.825` ✓

**La reconciliación cierra en los tres totales.** Esto confirma que la definición operativa usada aquí ("con combinación en la matriz oficial") es la misma que produjo el 31,1 % documentado, y que el 32,5 % de Email es la porción correcta de ese total.

---

## 8. Hallazgo adicional: categoría oficial frente a categoría COSE

En **10 de las 30 filas**, la categoría de la matriz oficial **no coincide** con la columna `categoria` de COSE. Los tickets son los mismos; cambia la clasificación.

| # | Subcategoría | Categoría matriz | Categoría COSE |
|---:|---|---|---|
| 1 | Nueva licencia o sucursal | ADMINISTRATIVO | GESTION |
| 2 | Solicitud de migración | ADMINISTRATIVO | GESTION |
| 3 | Solicitud agenda capacitación | CAPACITACION | GESTION |
| 5 | Solicitud de devolución | DEVOLUCION | GESTION |
| 13 | Emisión de invoice | FACTURACION ELECTRONICA | ADMINISTRATIVO |
| 16 | Renovación certificado normal | GESTION | FACTURACION ELECTRONICA |
| 17 | Venta de CDT certificado | GESTION | FACTURACION ELECTRONICA |
| 24 | Error integracion | INTEGRACIONES | SOFTWARE |
| 26 | Error logistica | LOGISTICA | SOFTWARE |
| 29 | Seguimiento de errores | SOFTWARE | GESTION |

**Consecuencias:**

1. La categoría `DEVOLUCION` existe en la matriz y **no existe** en la homologación COSE (que la ubica en GESTION). Por eso la matriz tiene 9 categorías y COSE 8.
2. Si el motor usara `v_unificado_norm.categoria` como fuente de clasificación, **10 combinaciones cambiarían de categoría** y los reportes por categoría no cuadrarían con la matriz.
3. **Regla obligatoria:** el motor clasifica con el **catálogo oficial de la matriz** (categoría + subcategoría), no con la columna de homologación. La homologación COSE sirve para los datos históricos; la matriz es la fuente de la política.

**Riesgo derivado:** la clave de política (`20-MAIL-<CAT>-<SUB>`) debe generarse desde la categoría oficial. Dos tickets con el mismo rótulo de origen pueden caer en categorías distintas si se usan fuentes distintas. Se documenta como riesgo R-05.

---

## 9. Limitaciones de la medición

| Limitación | Efecto | Tratamiento |
|---|---|---|
| El archivo `CategoryData.ts` (catálogo oficial de 65 subcategorías) **no existe** en los equipos revisados | No se puede validar el catálogo contra su fuente primaria | Se usó la matriz de 30 combinaciones como definición operativa de "oficial" |
| La identificación de "fuera de catálogo" es por **complemento** de las 30 etiquetas | Una subcategoría oficial sin volumen en Email no aparecería en la matriz, pero tampoco generaría tickets | Sin efecto práctico: el complemento se mide sobre tickets, no sobre etiquetas |
| Categoría de origen ≠ categoría oficial en 10 filas | Cambia la lectura por categoría | Regla del §8: clasificar con la matriz |
| `resolucion_min_norm > 0` excluye 121 tickets cerrados con resolución 0 o nula | Quedan fuera del universo de la matriz | Coherente con 5G.2; no afecta la política |
| La ventana termina el 31/10/2026 | Los totales son de 7 meses completos | Es la ventana aprobada (POL-07) |

**Lo que no se puede afirmar:** el listado nominal de las 65 subcategorías oficiales. No se inventó ni se reconstruyó. Se documenta la ausencia.

---

## 10. Conclusiones

1. **Matriz validada:** las 30 combinaciones reproducen exactamente 2.109 tickets, fila por fila, sin una sola diferencia.
2. **27 políticas con SLA** cubren 2.087 tickets; **3 combinaciones sin evidencia** cubren 22 y quedan sin SLA.
3. **P75 y escalera intactos:** 27/27 coherentes; ningún valor recalculado.
4. **Fuera de catálogo Email medido:** **1.016 tickets (32,51 %)**, con distribución por categoría y por rótulo.
5. **Reconciliación exacta** con los totales de ambos canales de 5G.2.
6. **Hallazgo nuevo:** 10 filas tienen categoría oficial distinta de la categoría COSE; el motor debe clasificar con la matriz.
7. **DP-E-01 y DP-E-08 quedan cerradas** con evidencia reproducible.

---

## 11. Confirmación

Verificación documental y consultas de solo lectura. No se modificó código, base de datos, configuración de Zammad, calendarios, SLA nativos, triggers, webhooks, usuarios, permisos, buzones, credenciales, Zendesk ni COSE. No se inició ningún worker ni servicio. No se creó ni se sobrescribió ningún documento anterior.
