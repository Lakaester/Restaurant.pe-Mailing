# MATRIZ OFICIAL DE SLA DE RESOLUCIÓN — EXCLUSIVAMENTE EMAIL — 5G.4.4

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.4
**Fecha:** 16/11/2026
**Modo:** verificación documental, solo lectura.
**Fuente:** `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` (5G.2.1), filas `CORREO`.
**Correcciones aplicadas:** `CORRECCIONES_MATRIZ_SLA_5G2_1.md` (conteo), `DECISIONES_PENDIENTES_5G3.md` (decisiones aprobadas).
**Estado:** matriz oficial para la implementación. **No se creó ningún SLA en Zammad.**

---

## 1. Alcance

Esta matriz contiene **únicamente** combinaciones de correo electrónico.

| Concepto | Valor |
|---|---|
| Canal | Correo electrónico (origen histórico: Zendesk) |
| Filas | **30** |
| Combinaciones con SLA | **27** |
| Combinaciones sin evidencia suficiente | **3** |
| Tickets con SLA asignable | **2.087** |
| Base Email con subcategoría homologada | **2.109** |
| Cobertura interna de la matriz | **98,96 %** |
| Ventana | 2026-04-01 → 2026-10-31 |
| Unidad | minutos calendario |

Las 40 filas de WhatsApp de la matriz original **no forman parte de esta matriz oficial**. Permanecen en el documento fuente como evidencia histórica, conforme a `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` §4.

---

## 2. Metodología (sin cambios)

### 2.1 Criterio estadístico: P75

```
SLA = menor valor de la escalera ≥ P75 de la propia combinación

Escalera: 15 · 30 · 45 · 60 · 90 · 120 · 180 · 240 · 360 · 480 · 720
        · 1440 · 2160 · 2880 · 4320 · 5760 · 7200 min
```

Reglas que se mantienen:

1. **P75 es el criterio.** No se sustituye por mediana ni por promedio.
2. No se usa P90 (consagraría un 10 % de incumplimiento).
3. No se agregan subcategorías para inflar la muestra.
4. Con **n < 10** no se propone SLA.
5. No se usa evidencia de otro canal para completar ninguna fila.

### 2.2 Escala de redondeo operativo

El redondeo **no es arbitrario ni proporcional**: se toma el **primer escalón igual o superior** al P75, de la escalera documentada en 5G.2.1 §2. Por eso los saltos son grandes en la zona alta (2.880 → 4.320 → 5.760 → 7.200).

### 2.3 Confianza

| Nivel | Regla |
|---|---|
| ALTA | n ≥ 100 |
| MEDIA | 30 ≤ n ≤ 99 |
| BAJA | 10 ≤ n ≤ 29 |
| INSUFICIENTE | n < 10 |

---

## 3. Prueba de que se usa P75 y no mediana ni promedio

Cinco casos tomados de esta misma matriz:

| Combinación | Mediana | P75 | Promedio | SLA oficial | Si se usara la mediana |
|---|---:|---:|---:|---:|---:|
| FE / Ajustes FE | 171 | 1.111,2 | 912,9 | **1.440** | 180 |
| GESTIÓN / Renovación certificado normal | 193,8 | 1.024,2 | 726,6 | **1.440** | 240 |
| FACTURACIÓN / Requisitos FE | 1.386,9 | 5.920,7 | 3.541 | **7.200** | 1.440 |
| LOGÍSTICA / Tarea o capacitación logística | 1.071 | 2.836,5 | 2.057,4 | **2.880** | 1.080 |
| SOFTWARE / Error punto de venta | 859,8 | 1.935 | 1.511,5 | **2.160** | 900 |

Queda demostrado que:

- la mediana produciría metas entre 5× y 8× más cortas;
- el promedio quedaría por debajo del P75 en todos los casos;
- la meta oficial sigue al P75 y a la escalera, no al promedio ni a la mediana.

---

## 4. Matriz oficial (30 filas)

Los valores de N, promedio, mediana, P75 y P90 se reproducen **exactamente** del documento fuente. La ortografía de categorías y subcategorías también se conserva, porque de ella depende la clave de política.

| # | Categoría | Subcategoría | N | Promedio | Mediana | P75 | P90 | Conf. | Escalón (min) | Meta | Cumpl. histórico |
|---:|---|---|---:|---:|---:|---:|---:|---|---:|---|---:|
| 1 | ADMINISTRATIVO | Nueva licencia o sucursal | 35 | 660,5 | 219 | 1.161,3 | 1.438,2 | MEDIA | 1.440 | **24 h** | 88,6 % |
| 2 | ADMINISTRATIVO | Solicitud de migración | 27 | 2.556,4 | 1.788 | 4.271,1 | 5.625,5 | BAJA | 4.320 | **3 d** | 74,1 % |
| 3 | CAPACITACION | Solicitud agenda capacitación | 115 | 2.195,6 | 1.180,8 | 3.054,6 | 5.503,8 | ALTA | 4.320 | **3 d** | 81,7 % |
| 4 | CAPACITACION | Capacitación adm Reportes | 21 | 1.257,4 | 264 | 1.644 | 3.424,2 | BAJA | 2.160 | **36 h** | 81,0 % |
| 5 | DEVOLUCION | Solicitud de devolución | 37 | 2.282 | 1.348,8 | 3.075 | 6.384,6 | MEDIA | 4.320 | **3 d** | 83,8 % |
| 6 | FACTURACION ELECTRONICA | Ajustes FE | 341 | 912,9 | 171 | 1.111,2 | 2.584,8 | ALTA | 1.440 | **24 h** | 83,9 % |
| 7 | FACTURACION ELECTRONICA | Cambio de razón social | 170 | 2.125,1 | 955,2 | 2.996,1 | 6.048,2 | ALTA | 4.320 | **3 d** | 81,8 % |
| 8 | FACTURACION ELECTRONICA | Activacion FE | 94 | 2.099,8 | 355,5 | 2.632,2 | 7.241,1 | MEDIA | 2.880 | **2 d** | 75,5 % |
| 9 | FACTURACION ELECTRONICA | Validación de comprobantes FE | 67 | 1.913,6 | 220,2 | 1.818 | 6.646,7 | MEDIA | 2.160 | **36 h** | 77,6 % |
| 10 | FACTURACION ELECTRONICA | Requisitos FE | 60 | 3.541 | 1.386,9 | 5.920,7 | 8.995,4 | MEDIA | 7.200 | **5 d** | 86,7 % |
| 11 | FACTURACION ELECTRONICA | Error FE del facturador | 38 | 877,5 | 246 | 780,5 | 1.823,3 | MEDIA | 1.440 | **24 h** | 86,8 % |
| 12 | FACTURACION ELECTRONICA | Error FE de cálculo | 36 | 2.361,8 | 1.515 | 2.971,7 | 7.145,4 | MEDIA | 4.320 | **3 d** | 83,3 % |
| 13 | FACTURACION ELECTRONICA | Emisión de invoice | 28 | 1.410,4 | 279,3 | 2.097,6 | 3.649,5 | BAJA | 2.160 | **36 h** | 75,0 % |
| 14 | FACTURACION ELECTRONICA | Error FE envio manual | 19 | 1.359,2 | 666 | 2.170,8 | 3.548,4 | BAJA | 2.880 | **2 d** | 78,9 % |
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | 2.515,2 | 979,2 | 4.465,8 | 5.583 | INSUF | — | **sin SLA** | — |
| 16 | GESTION | Renovación certificado normal | 177 | 726,6 | 193,8 | 1.024,2 | 1.560,6 | ALTA | 1.440 | **24 h** | 85,3 % |
| 17 | GESTION | Venta de CDT certificado | 81 | 1.898,4 | 1.198,2 | 1.698 | 5.719,8 | MEDIA | 2.160 | **36 h** | 77,8 % |
| 18 | GESTION | Envio de pago | 45 | 1.085,3 | 231 | 1.233 | 2.727,7 | MEDIA | 1.440 | **24 h** | 77,8 % |
| 19 | GESTION | Seguimiento proactivo | 33 | 1.109,1 | 252 | 1.398 | 2.801,5 | MEDIA | 1.440 | **24 h** | 75,8 % |
| 20 | INTEGRACIONES | Consulta consumo de apis | 83 | 1.804,9 | 535,8 | 2.597,4 | 4.899,6 | MEDIA | 2.880 | **2 d** | 80,7 % |
| 21 | INTEGRACIONES | Solicitud de integracion rappi | 25 | 2.238,2 | 313,2 | 1.615,2 | 6.968,5 | BAJA | 2.160 | **36 h** | 80,0 % |
| 22 | INTEGRACIONES | Solicitud de integracion Pedidos ya | 14 | 3.250,6 | 1.405,2 | 5.371,7 | 7.936,7 | BAJA | 5.760 | **4 d** | 78,6 % |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | 2.849,9 | 1.672,8 | 5.733 | 6.067,2 | INSUF | — | **sin SLA** | — |
| 24 | INTEGRACIONES | Error integracion | 4 | 3.626,4 | 1.221,3 | 3.922,8 | 8.566,8 | INSUF | — | **sin SLA** | — |
| 25 | LOGISTICA | Tarea o capacitación logistica | 319 | 2.057,4 | 1.071 | 2.836,5 | 5.962,4 | ALTA | 2.880 | **2 d** | 76,2 % |
| 26 | LOGISTICA | Error logistica | 20 | 4.668,2 | 2.096,1 | 4.635,6 | 14.584,4 | BAJA | 5.760 | **4 d** | 80,0 % |
| 27 | OPERATIVO | Temas operativos | 119 | 2.162,8 | 1.027,8 | 2.718 | 5.533,7 | ALTA | 2.880 | **2 d** | 77,3 % |
| 28 | SOFTWARE | Error punto de venta | 37 | 1.511,5 | 859,8 | 1.935 | 3.276,6 | MEDIA | 2.160 | **36 h** | 75,7 % |
| 29 | SOFTWARE | Seguimiento de errores | 34 | 1.254,6 | 1.007,1 | 1.403,7 | 2.796,6 | MEDIA | 1.440 | **24 h** | 73,5 % |
| 30 | SOFTWARE | Error web | 12 | 3.770 | 2.322,9 | 3.881,4 | 5.436,6 | BAJA | 4.320 | **3 d** | 75,0 % |

**Equivalencias:** 1.440 = 24 h · 2.160 = 36 h · 2.880 = 48 h (2 d) · 4.320 = 72 h (3 d) · 5.760 = 96 h (4 d) · 7.200 = 120 h (5 d).

---

## 5. Verificación de integridad de la matriz

| Verificación | Resultado |
|---|---|
| Filas de correo en la fuente | **30** |
| Filas con SLA | **27** |
| Filas sin evidencia | **3** |
| Suma de N de las 30 filas | **2.109** |
| Suma de N de las 27 filas con SLA | **2.087** |
| Suma de N de las 3 filas sin SLA | **22** |
| Todos los SLA son escalones de la escalera | **Sí, 27 de 27** |
| Ningún SLA es menor que su P75 | **Sí, 27 de 27** |
| Ningún SLA salta más de un escalón por encima del P75 | **Sí, 27 de 27** |
| Ningún valor fue recalculado en esta etapa | **Correcto** |

**Casos límite comprobados:**

| P75 | Escalón correcto | Error posible |
|---:|---:|---|
| 780,5 | **1.440** | Haber usado 720 (queda por debajo del P75) |
| 2.097,6 | **2.160** | Haber usado 1.440 |
| 2.718 | **2.880** | Haber usado 2.160 |
| 3.075 | **4.320** | Haber usado 2.880 |
| 4.635,6 | **5.760** | Haber usado 4.320 |
| 5.920,7 | **7.200** | Haber usado 5.760 |

---

## 6. Distribución de metas Email

| Meta | Combinaciones | % de las 27 |
|---|---:|---:|
| 24 h (1.440 min) | 7 | 25,9 % |
| 36 h (2.160 min) | 6 | 22,2 % |
| 48 h (2.880 min) | 5 | 18,5 % |
| 72 h (4.320 min) | 6 | 22,2 % |
| 96 h (5.760 min) | 2 | 7,4 % |
| 120 h (7.200 min) | 1 | 3,7 % |
| **Total** | **27** | **100 %** |

**Rango:** de 24 h a 120 h. La diferenciación por categoría y subcategoría es real y amplia: 5× entre la meta más corta y la más larga.

**Contraste con el alcance anterior:** la concentración de WhatsApp en 90–120 min era la que hacía parecer que la matriz no discriminaba. En Email sí discrimina, y por eso la regla de metas por categoría y subcategoría tiene sentido.

---

## 7. Combinaciones sin evidencia suficiente

| # | Categoría | Subcategoría | n | Estado |
|---:|---|---|---:|---|
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | `PENDIENTE DE VALIDACIÓN — SIN SLA` |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | `PENDIENTE DE VALIDACIÓN — SIN SLA` |
| 24 | INTEGRACIONES | Error integracion | 4 | `PENDIENTE DE VALIDACIÓN — SIN SLA` |

**Regla:** no se asigna ningún tiempo. No se usa el respaldo de 36 h para "rellenar" estas tres filas: el respaldo es para **subcategorías fuera del catálogo**, no para combinaciones conocidas con muestra insuficiente. Mezclar ambos casos ocultaría un problema de evidencia.

**Consecuencia:** un ticket de estas tres combinaciones queda sin compromiso de resolución y **no entra en el denominador** de cumplimiento. Debe registrarse como `no_policy` con motivo `insufficient_evidence`.

**Pendiente:** definir si se revisa a los 90 días con datos nuevos (recomendado) o si se les aplica un respaldo explícito aprobado (decisión del negocio).

---

## 8. Primera respuesta Email

| Concepto | Valor |
|---|---|
| Canal | Correo electrónico |
| Meta | **< 24 h (1.440 min)** |
| Diferenciación por categoría | **No** (prohibida por el alcance) |
| Criterio de cumplimiento | Artículo público de agente con `delivery_status = success` |
| Notas internas | No cuentan |
| Base del reloj | `created_at` del ticket |
| Calendario | 24/7, sin pausas |

Esta meta ya estaba fijada en 5G.2.1 §1 y **no se recalcula**. Lo nuevo de 5G.4.4 es que:

1. es la **única** meta de primera respuesta del proyecto;
2. exige confirmación de envío;
3. desaparece la meta de 15 minutos de WhatsApp.

**Límite exacto:** la meta está expresada como "menos de 24 horas". Falta decidir si el cumplimiento se evalúa con `≤ 1.440 min` o con `< 1.440 min`. Es la decisión **DP-E-04** de `DECISIONES_PENDIENTES_EMAIL_5G4_4.md`. No se resuelve por cuenta propia.

---

## 9. Volumen fuera de catálogo

| Concepto | Valor documentado | Observación |
|---|---:|---|
| Filas de servicio totales (ambos canales) | 15.591 | 5G.2 |
| Con subcategoría homologada (ambos canales) | 10.750 | 68,9 % |
| Fuera de catálogo (ambos canales) | **4.841** | 31,1 % |

**El dato específico de Email no está disponible en los documentos revisados.** La cifra de 4.841 es la suma de ambos canales y **no se puede atribuir a Email**. No se inventa ni se estima.

| Dato requerido | Estado |
|---|---|
| Tickets Email con subcategoría fuera de catálogo | **PENDIENTE** de consulta de solo lectura |
| Porcentaje sobre la base Email | **PENDIENTE** |

**Tratamiento provisional aprobado:** respaldo Email de **36 h** para subcategorías fuera de catálogo, marcado `provisional = true`, hasta que se revise el catálogo. El respaldo de 90 minutos de WhatsApp **queda eliminado**.

**Advertencia:** si el volumen fuera de catálogo en Email fuese alto, el respaldo de 36 h dominaría la medición y ocultaría el efecto de la matriz. Debe medirse antes de la fase 2.

---

## 10. Claves de política

Convención vigente de 5G.3, aplicada solo a Email:

```
20-MAIL-<CATEGORÍA>-<SUBCATEGORÍA>
99-FALLBACK
```

Ejemplos:

- `20-MAIL-SOFTWARE-ERROR_WEB` → 4.320 min
- `20-MAIL-FACTURACION_ELECTRONICA-AJUSTES_FE` → 1.440 min
- `99-FALLBACK` → 2.160 min (provisional, fuera de catálogo)

La clave `10-WA-…` **no se usa**. Se conserva en la documentación histórica de 5G.3 para trazabilidad de la convención.

---

## 11. Qué no se hizo en esta etapa

| Acción | Estado |
|---|---|
| Recalcular P75 | **No** |
| Recalcular promedio o mediana | **No** |
| Cambiar la escalera | **No** |
| Añadir filas de otro canal | **No** |
| Completar las 3 filas sin evidencia | **No** |
| Convertir a horas hábiles | **No** (siguen en calendario 24/7) |
| Crear políticas en Zammad | **No** |

---

## 12. Confirmación

La matriz es una extracción verificada de la fuente 5G.2.1, limitada a las filas de correo. No se recalculó ningún valor, no se creó ninguna política y no se modificó ningún sistema.
