# ANÁLISIS ESTADÍSTICO DE RESOLUCIÓN — COSE

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2 — Fase E
**Fecha:** 14/11/2026
**Fuente:** `public.v_unificado_norm`
**Modo:** solo lectura, cálculo en memoria. No se crearon tablas ni objetos.

---

## 1. Definición del universo analizado

| Criterio | Valor |
|---|---|
| Ventana | **2026-04-01 → 2026-10-31** (7 meses completos) |
| Estado | `cerrado` o `resuelto` |
| Tiempo de resolución | `resolucion_min_norm > 0` (excluye nulos y ceros) |
| Canales | `WHATMETA` (WhatsApp) y `ZENDESK` (correo) |
| Excluido | `WHATICKET` (legado no comparable, ver auditoría §5.2) |
| Unidad interna | **minutos**; se presentan también en horas |

**Embudo de depuración:**

| Paso | Filas |
|---|---:|
| Universo total de la vista | 24.754 |
| Cerrados/resueltos | 24.137 |
| Con resolución > 0 | 23.960 |
| Dentro de la ventana y en WHATMETA/ZENDESK | 20.193 |
| Categorías de servicio (excluye pseudo-categorías) | 15.591 |
| Con subcategoría homologable al catálogo oficial | **10.750** |

Las pseudo-categorías excluidas son: `SIN HOMOLOGAR` (4.375), `SIN CATEGORIA EN ORIGEN` (857), `DUPLICADO/DUPLICADA` (752), `NO CONTESTO` (1.181) y `ADD ONS` (245, fuera del catálogo oficial).

---

## 2. Resultado por canal

Base: categorías de servicio con subcategoría homologada (10.750 filas).

| Canal | n | Mediana | P75 | P90 | P95 | Promedio | Máximo | ≤ 4 h | ≤ 8 h | ≤ 24 h | ≤ 48 h | ≤ 72 h |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| WHATSAPP | 8.641 | 50 min | 84 min | 131 min | 179 min | 93 min | 15,2 d | 97,1 % | 98,5 % | 99,6 % | 99,8 % | 99,8 % |
| CORREO | 2.109 | 506 min (8,4 h) | 1.783 min (29,7 h) | 5.261 min (87,7 h) | 7.321 min (5,1 d) | 1.746 min (29,1 h) | 18,1 d | 38,3 % | 49,5 % | 69,0 % | 81,1 % | 87,2 % |

**Lectura:** la distribución es fuertemente asimétrica en ambos canales. La mediana de correo (8,4 h) es 10× la de WhatsApp (50 min), y el promedio de ambos queda muy por encima de su mediana (efecto de la cola). **El promedio no es un criterio válido para fijar metas.**

---

## 3. Resultado por canal × categoría

Base: categorías de servicio con subcategoría homologada.

| Canal | Categoría | n | Mediana | P75 | P90 | P95 | Promedio | Máximo |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| WHATSAPP | OPERATIVO | 1.063 | 36 | 63 | 102 | 146 | 62 | 1.489 |
| WHATSAPP | GESTION | 1.328 | 41 | 70 | 113 | 155 | 88 | 10.092 |
| WHATSAPP | SOFTWARE | 611 | 48 | 94 | 152 | 245 | 202 | 18.601 |
| WHATSAPP | ADMINISTRATIVO | 218 | 48 | 90 | 125 | 156 | 71 | 1.422 |
| WHATSAPP | FACTURACION ELECTRONICA | 2.202 | 52 | 84 | 126 | 172 | 73 | 2.836 |
| WHATSAPP | LOGISTICA | 1.206 | 58 | 88 | 126 | 160 | 94 | 20.400 |
| WHATSAPP | CAPACITACION | 1.346 | 58 | 97 | 146 | 192 | 90 | 12.742 |
| WHATSAPP | INTEGRACIONES | 610 | 61 | 104 | 174 | 263 | 136 | 21.849 |
| WHATSAPP | SERVIDOR | 49 | 41 | 56 | 591 | 653 | 169 | 2.678 |
| WHATSAPP | DEVOLUCION | 8 | 32 | 64 | 121 | 169 | 60 | 217 |
| CORREO | GESTION | 336 | 278 | 1.271 | 2.850 | 5.717 | 1.095 | 12.792 |
| CORREO | FACTURACION ELECTRONICA | 862 | 314 | 1.600 | 5.354 | 7.451 | 1.644 | 26.072 |
| CORREO | ADMINISTRATIVO | 62 | 818 | 1.754 | 4.330 | 5.328 | 1.486 | 8.375 |
| CORREO | SOFTWARE | 83 | 982 | 2.308 | 3.718 | 4.683 | 1.733 | 20.179 |
| CORREO | INTEGRACIONES | 135 | 986 | 2.815 | 5.857 | 9.309 | 2.159 | 20.170 |
| CORREO | OPERATIVO | 119 | 1.028 | 2.718 | 5.534 | 7.131 | 2.163 | 21.124 |
| CORREO | CAPACITACION | 136 | 1.094 | 2.940 | 5.300 | 6.925 | 2.051 | 17.653 |
| CORREO | LOGISTICA | 339 | 1.123 | 2.891 | 6.661 | 8.541 | 2.211 | 23.001 |
| CORREO | DEVOLUCION | 37 | 1.349 | 3.075 | 6.385 | 8.101 | 2.282 | 14.397 |

Valores en **minutos**.

### 3.1 Distribución por umbrales

| Canal | Categoría | ≤ 4 h | ≤ 8 h | ≤ 24 h | ≤ 48 h | ≤ 72 h |
|---|---|---:|---:|---:|---:|---:|
| WHATSAPP | ADMINISTRATIVO | 98,6 % | 99,1 % | 100 % | 100 % | 100 % |
| WHATSAPP | CAPACITACION | 97,4 % | 99,0 % | 99,9 % | 99,9 % | 99,9 % |
| WHATSAPP | FACTURACION ELECTRONICA | 97,5 % | 99,0 % | 100 % | 100 % | 100 % |
| WHATSAPP | GESTION | 97,4 % | 98,3 % | 99,5 % | 99,6 % | 99,6 % |
| WHATSAPP | INTEGRACIONES | 94,6 % | 98,2 % | 99,3 % | 99,7 % | 99,7 % |
| WHATSAPP | LOGISTICA | 97,8 % | 98,9 % | 99,6 % | 99,9 % | 99,9 % |
| WHATSAPP | OPERATIVO | 98,0 % | 98,3 % | 99,9 % | 100 % | 100 % |
| WHATSAPP | SERVIDOR | 83,7 % | 85,7 % | 98,0 % | 100 % | 100 % |
| WHATSAPP | SOFTWARE | 94,8 % | 96,7 % | 98,2 % | 99,2 % | 99,3 % |
| CORREO | ADMINISTRATIVO | 33,9 % | 46,8 % | 66,1 % | 82,3 % | 88,7 % |
| CORREO | CAPACITACION | 27,2 % | 39,0 % | 62,5 % | 73,5 % | 83,1 % |
| CORREO | DEVOLUCION | 29,7 % | 40,5 % | 56,8 % | 73,0 % | 83,8 % |
| CORREO | FACTURACION ELECTRONICA | 44,5 % | 55,0 % | 72,5 % | 82,6 % | 87,5 % |
| CORREO | GESTION | 45,8 % | 58,0 % | 78,9 % | 90,8 % | 93,8 % |
| CORREO | INTEGRACIONES | 40,0 % | 45,9 % | 64,4 % | 77,0 % | 83,7 % |
| CORREO | LOGISTICA | 27,7 % | 41,0 % | 59,9 % | 74,9 % | 83,5 % |
| CORREO | OPERATIVO | 26,1 % | 39,5 % | 61,3 % | 77,3 % | 84,0 % |
| CORREO | SOFTWARE | 26,5 % | 37,3 % | 67,5 % | 79,5 % | 90,4 % |

**Hallazgo:** en WhatsApp el 94–98 % de los casos se resuelve dentro de 4 horas. En correo ningún bloque supera el 46 % a 4 horas ni el 58 % a 8 horas. Las dos distribuciones **no son comparables** y no deben compartir una meta común.

---

## 4. Resultado por canal × categoría × subcategoría

Base: subcategoría homologada al catálogo oficial. Valores en **minutos**.

Confianza: **ALTA** ≥ 100 · **MEDIA** 30–99 · **BAJA** 10–29 · **INSUF** < 10.

### 4.1 WhatsApp

| Categoría | Subcategoría | n | Med | P75 | P90 | P95 | Prom | Máx | ≤4h | ≤8h | ≤24h | Conf. |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| OPERATIVO | Temas operativos | 1.063 | 36 | 63 | 102 | 146 | 62 | 1.489 | 98,0 | 98,3 | 99,9 | ALTA |
| FACTURACIÓN | Ajustes FE | 1.075 | 51 | 80 | 123 | 158 | 69 | 1.360 | 98,0 | 99,0 | 100 | ALTA |
| LOGÍSTICA | Capacitación logística avanzado | 859 | 57 | 86 | 122 | 159 | 98 | 20.400 | 98,0 | 99,0 | 99,7 | ALTA |
| GESTIÓN | Seguimiento proactivo | 473 | 40 | 76 | 123 | 150 | 58 | 753 | 98,5 | 99,6 | 100 | ALTA |
| CAPACITACIÓN | Capacitación integraciones | 454 | 61 | 107 | 161 | 210 | 111 | 12.742 | 96,5 | 99,1 | 99,8 | ALTA |
| CAPACITACIÓN | Solicitud agenda capacitación | 432 | 63 | 98 | 146 | 199 | 91 | 2.754 | 96,8 | 98,4 | 99,8 | ALTA |
| GESTIÓN | Envío de pago | 386 | 33 | 57 | 101 | 161 | 83 | 6.961 | 96,1 | 96,9 | 99,7 | ALTA |
| FACTURACIÓN | Validación de comprobantes FE | 329 | 51 | 82 | 118 | 152 | 67 | 603 | 97,6 | 99,4 | 100 | ALTA |
| GESTIÓN | Renovación certificado normal | 312 | 47 | 71 | 101 | 145 | 115 | 6.142 | 97,1 | 98,1 | 98,7 | ALTA |
| LOGÍSTICA | Capacitación logística insumos recetas | 298 | 56 | 86 | 127 | 141 | 76 | 1.485 | 98,3 | 99,0 | 99,7 | ALTA |
| SOFTWARE | Error punto de venta | 293 | 36 | 68 | 128 | 251 | 309 | 18.601 | 94,2 | 95,9 | 96,9 | ALTA |
| INTEGRACIONES | Solicitud integración Rappi | 280 | 61 | 106 | 176 | 265 | 109 | 4.528 | 94,3 | 97,9 | 99,3 | ALTA |
| SOFTWARE | Seguimiento de errores | 241 | 59 | 106 | 154 | 227 | 107 | 1.615 | 95,0 | 96,7 | 99,2 | ALTA |
| CAPACITACIÓN | Capacitación adm Productos | 199 | 54 | 87 | 129 | 154 | 74 | 1.020 | 98,5 | 99,0 | 100 | ALTA |
| CAPACITACIÓN | Capacitación adm Reportes | 190 | 51 | 77 | 108 | 155 | 60 | 248 | 99,5 | 100 | 100 | ALTA |
| INTEGRACIONES | Solicitud integración Pedidos Ya | 165 | 66 | 118 | 207 | 306 | 233 | 21.849 | 92,1 | 98,2 | 99,4 | ALTA |
| GESTIÓN | Venta de CDT certificado | 157 | 51 | 77 | 119 | 178 | 139 | 10.092 | 97,5 | 98,1 | 99,4 | ALTA |
| ADMINISTRATIVO | Nueva licencia o sucursal | 133 | 41 | 64 | 110 | 143 | 66 | 1.422 | 98,5 | 98,5 | 100 | ALTA |
| FACTURACIÓN | Cambio de razón social | 132 | 63 | 97 | 133 | 250 | 84 | 623 | 93,9 | 98,5 | 100 | ALTA |
| FACTURACIÓN | Activación FE | 119 | 61 | 100 | 176 | 218 | 91 | 1.344 | 95,0 | 99,2 | 100 | ALTA |
| FACTURACIÓN | Error FE envío manual | 119 | 40 | 62 | 93 | 110 | 59 | 951 | 98,3 | 99,2 | 100 | ALTA |
| FACTURACIÓN | Requisitos FE | 102 | 56 | 82 | 104 | 150 | 96 | 2.836 | 97,1 | 98,0 | 99,0 | ALTA |
| ADMINISTRATIVO | Solicitud de migración | 85 | 71 | 113 | 144 | 174 | 80 | 278 | 98,8 | 100 | 100 | MEDIA |
| INTEGRACIONES | Consulta consumo de APIs | 80 | 53 | 72 | 104 | 131 | 64 | 615 | 98,8 | 98,8 | 100 | MEDIA |
| FACTURACIÓN | Error FE del facturador | 75 | 70 | 105 | 163 | 192 | 77 | 231 | 100 | 100 | 100 | MEDIA |
| CAPACITACIÓN | Capacitación operativa | 71 | 45 | 74 | 136 | 153 | 64 | 262 | 98,6 | 100 | 100 | MEDIA |
| FACTURACIÓN | Error FE de cálculo | 66 | 79 | 113 | 166 | 216 | 92 | 621 | 95,5 | 98,5 | 100 | MEDIA |
| FACTURACIÓN | Consecutivos topes folios | 57 | 44 | 68 | 98 | 131 | 53 | 182 | 100 | 100 | 100 | MEDIA |
| FACTURACIÓN | Error FE por duplicidad | 51 | 79 | 108 | 151 | 184 | 91 | 428 | 96,1 | 100 | 100 | MEDIA |
| SOFTWARE | Error add-on asistencias | 51 | 62 | 98 | 142 | 189 | 82 | 394 | 98,0 | 100 | 100 | MEDIA |
| INTEGRACIONES | Error integración | 49 | 73 | 100 | 157 | 176 | 84 | 292 | 98,0 | 100 | 100 | MEDIA |
| LOGÍSTICA | Error logística | 49 | 89 | 118 | 193 | 292 | 137 | 1.705 | 91,8 | 98,0 | 98,0 | MEDIA |
| SERVIDOR | Caída del servidor | 49 | 41 | 56 | 591 | 653 | 169 | 2.678 | 83,7 | 85,7 | 98,0 | MEDIA |
| FACTURACIÓN | Emisión de invoice | 48 | 44 | 66 | 97 | 108 | 63 | 678 | 97,9 | 97,9 | 100 | MEDIA |
| SOFTWARE | Error web | 26 | 101 | 161 | 218 | 252 | 115 | 305 | 92,3 | 100 | 100 | BAJA |
| INTEGRACIONES | Solicitud integración Uber | 24 | 50 | 95 | 198 | 336 | 144 | 1.570 | 91,7 | 95,8 | 95,8 | BAJA |
| FACTURACIÓN | FE solicitud XML/PDF | 20 | 33 | 45 | 56 | 96 | 38 | 145 | 100 | 100 | 100 | BAJA |
| INTEGRACIONES | Integración sistemas contables | 12 | 92 | 138 | 168 | 190 | 104 | 217 | 100 | 100 | 100 | BAJA |
| FACTURACIÓN | Activación NV | 9 | 57 | 125 | 161 | 163 | 82 | 164 | 100 | 100 | 100 | INSUF |
| DEVOLUCIÓN | Solicitud de devolución | 8 | 32 | 64 | 121 | 169 | 60 | 217 | 100 | 100 | 100 | INSUF |

### 4.2 Correo

| Categoría | Subcategoría | n | Med | P75 | P90 | P95 | Prom | Máx | ≤4h | ≤8h | ≤24h | Conf. |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| FACTURACIÓN | Ajustes FE | 341 | 171 | 1.111 | 2.585 | 4.139 | 913 | 26.072 | 57,5 | 66,9 | 83,9 | ALTA |
| LOGÍSTICA | Tarea o capacitación logística | 319 | 1.071 | 2.837 | 5.962 | 8.461 | 2.057 | 23.001 | 28,5 | 42,6 | 61,4 | ALTA |
| GESTIÓN | Renovación certificado normal | 177 | 194 | 1.024 | 1.561 | 3.075 | 727 | 9.743 | 54,2 | 66,7 | 85,3 | ALTA |
| FACTURACIÓN | Cambio de razón social | 170 | 955 | 2.996 | 6.048 | 7.888 | 2.125 | 17.351 | 35,3 | 44,1 | 65,9 | ALTA |
| OPERATIVO | Temas operativos | 119 | 1.028 | 2.718 | 5.534 | 7.131 | 2.163 | 21.124 | 26,1 | 39,5 | 61,3 | ALTA |
| CAPACITACIÓN | Solicitud agenda capacitación | 115 | 1.181 | 3.055 | 5.504 | 7.060 | 2.196 | 17.653 | 24,3 | 35,7 | 61,7 | ALTA |
| FACTURACIÓN | Activación FE | 94 | 356 | 2.632 | 7.241 | 9.798 | 2.100 | 11.762 | 42,6 | 52,1 | 64,9 | MEDIA |
| INTEGRACIONES | Consulta consumo de APIs | 83 | 536 | 2.597 | 4.900 | 8.583 | 1.805 | 20.170 | 44,6 | 49,4 | 66,3 | MEDIA |
| GESTIÓN | Venta de CDT certificado | 81 | 1.198 | 1.698 | 5.720 | 6.798 | 1.898 | 12.792 | 27,2 | 35,8 | 66,7 | MEDIA |
| FACTURACIÓN | Validación de comprobantes FE | 67 | 220 | 1.818 | 6.647 | 9.680 | 1.914 | 16.918 | 50,7 | 59,7 | 70,1 | MEDIA |
| FACTURACIÓN | Requisitos FE | 60 | 1.387 | 5.921 | 8.995 | 14.343 | 3.541 | 24.424 | 16,7 | 35,0 | 53,3 | MEDIA |
| GESTIÓN | Envío de pago | 45 | 231 | 1.233 | 2.728 | 4.747 | 1.085 | 8.745 | 53,3 | 55,6 | 77,8 | MEDIA |
| FACTURACIÓN | Error FE del facturador | 38 | 246 | 780 | 1.823 | 3.407 | 878 | 10.156 | 50,0 | 65,8 | 86,8 | MEDIA |
| FACTURACIÓN | Error FE de cálculo | 36 | 1.515 | 2.972 | 7.145 | 8.519 | 2.362 | 8.827 | 13,9 | 19,4 | 44,4 | MEDIA |
| DEVOLUCIÓN | Solicitud de devolución | 37 | 1.349 | 3.075 | 6.385 | 8.101 | 2.282 | 14.397 | 29,7 | 40,5 | 56,8 | MEDIA |
| SOFTWARE | Error punto de venta | 37 | 860 | 1.935 | 3.277 | 4.408 | 1.512 | 11.250 | 24,3 | 40,5 | 70,3 | MEDIA |
| ADMINISTRATIVO | Nueva licencia o sucursal | 35 | 219 | 1.161 | 1.438 | 1.969 | 660 | 4.262 | 54,3 | 62,9 | 88,6 | MEDIA |
| SOFTWARE | Seguimiento de errores | 34 | 1.007 | 1.404 | 2.797 | 4.031 | 1.255 | 7.253 | 35,3 | 41,2 | 73,5 | MEDIA |
| GESTIÓN | Seguimiento proactivo | 33 | 252 | 1.398 | 2.802 | 5.758 | 1.109 | 5.838 | 36,4 | 69,7 | 75,8 | MEDIA |
| FACTURACIÓN | Emisión de invoice | 28 | 279 | 2.098 | 3.650 | 4.508 | 1.410 | 10.618 | 35,7 | 57,1 | 71,4 | BAJA |
| ADMINISTRATIVO | Solicitud de migración | 27 | 1.788 | 4.271 | 5.625 | 6.277 | 2.556 | 8.375 | 7,4 | 25,9 | 37,0 | BAJA |
| INTEGRACIONES | Solicitud integración Rappi | 25 | 313 | 1.615 | 6.969 | 10.011 | 2.238 | 18.304 | 44,0 | 52,0 | 72,0 | BAJA |
| CAPACITACIÓN | Capacitación adm Reportes | 21 | 264 | 1.644 | 3.424 | 4.637 | 1.257 | 6.773 | 42,9 | 57,1 | 66,7 | BAJA |
| LOGÍSTICA | Error logística | 20 | 2.096 | 4.636 | 14.584 | 16.638 | 4.668 | 21.566 | 15,0 | 15,0 | 35,0 | BAJA |
| FACTURACIÓN | Error FE envío manual | 19 | 666 | 2.171 | 3.548 | 4.888 | 1.359 | 4.915 | 31,6 | 47,4 | 68,4 | BAJA |
| INTEGRACIONES | Solicitud integración Pedidos Ya | 14 | 1.405 | 5.372 | 7.937 | 9.405 | 3.251 | 11.446 | 28,6 | 35,7 | 50,0 | BAJA |
| SOFTWARE | Error web | 12 | 2.323 | 3.881 | 5.437 | 12.138 | 3.770 | 20.179 | 8,3 | 16,7 | 41,7 | BAJA |
| FACTURACIÓN | Error FE por duplicidad | 9 | 979 | 4.466 | 5.583 | 7.401 | 2.515 | 9.219 | 44,4 | 44,4 | 55,6 | INSUF |
| INTEGRACIONES | Integración sistemas contables | 9 | 1.673 | 5.733 | 6.067 | 6.568 | 2.850 | 7.068 | 22,2 | 22,2 | 44,4 | INSUF |
| INTEGRACIONES | Error integración | 4 | 1.221 | 3.923 | 8.567 | 10.115 | 3.626 | 11.663 | 0,0 | 25,0 | 75,0 | INSUF |

---

## 5. Suficiencia de muestra

| Nivel | Combinaciones | Observación |
|---|---:|---|
| ALTA (≥ 100) | 24 | Base sólida para fijar meta directa |
| MEDIA (30–99) | 26 | Meta admisible con revisión trimestral |
| BAJA (10–29) | 11 | **Se agregó a nivel categoría** para proponer |
| INSUFICIENTE (< 10) | 5 | **Sin SLA propuesto** |

Combinaciones insuficientes (sin evidencia):

| Canal | Categoría | Subcategoría | n |
|---|---|---|---:|
| WHATSAPP | DEVOLUCIÓN | Solicitud de devolución | 8 |
| WHATSAPP | FACTURACIÓN | Activación NV | 9 |
| CORREO | FACTURACIÓN | Error FE por duplicidad | 9 |
| CORREO | INTEGRACIONES | Integración sistemas contables | 9 |
| CORREO | INTEGRACIONES | Error integración | 4 |

**Cobertura de la evidencia:** 15.591 filas de servicio en la ventana; 10.750 (68,9 %) caen en una subcategoría oficial. Las **4.841 restantes (31,1 %)** tienen categoría de servicio pero subcategoría fuera del catálogo (`sin categorizar`, etiquetas concatenadas, variantes ortográficas). No se les puede asignar un SLA por subcategoría.

---

## 6. Valores extremos y colas

| Canal | > 7 días | > 30 días | Máximo | Comentario |
|---|---:|---:|---:|---|
| WHATSAPP | 46 | 0 | 21.849 min (15,2 d) | Cola corta pero con casos aislados |
| CORREO | 117 | 1 | 29.090 min (20,2 d) | Cola larga y pesada |

**Criterio aplicado:** los atípicos **no se eliminan**. Se conservan y se reportan, porque representan trabajo real y porque recortarlos inflaría artificialmente la calidad del servicio. Su efecto se controla usando percentiles (P75/P90) en lugar del promedio.

Ejemplos de valores extremos documentados:

- CORREO / Requisitos FE: máximo 24.424 min (17 d) con mediana de 1.387 min.
- WHATSAPP / Capacitación logística avanzado: máximo 20.400 min (14 d) con mediana de 57 min.
- WHATSAPP / SERVIDOR: P90 de 591 min frente a mediana de 41 min (dispersión 14×), indicativo de dos poblaciones mezcladas (caída real vs. consulta).

---

## 7. Distribución por día y horario

> **Advertencia de validez:** en CORREO la hora proviene de `to_char(tickets_created_at,'HH24')` **sin conversión de UTC a America/Lima**. Las franjas de correo están desplazadas 5 horas y **no deben interpretarse** como horario local. En WHATSAPP la hora sí es local.

### 7.1 WhatsApp (hora local)

| Franja | n | Mediana |
|---|---:|---:|
| 00–08 | 749 | 122 min |
| 09–13 | 8.600 | 55 min |
| 14–18 | 7.509 | 47 min |
| 19–22 | 1.525 | 39 min |
| 23–24 | 58 | 624 min |

| Día | n | Mediana |
|---|---:|---:|
| Lunes | 3.274 | 53 min |
| Martes | 3.365 | 53 min |
| Miércoles | 3.300 | 53 min |
| Jueves | 3.155 | 53 min |
| Viernes | 2.886 | 54 min |
| Sábado | 1.766 | 45 min |
| Domingo | 695 | 44 min |

**Lectura:** la operación de WhatsApp es estable de lunes a viernes y algo más rápida el fin de semana (menor volumen). La franja 23–24 muestra mediana anómala (624 min) con solo 58 casos: no es concluyente.

### 7.2 Correo (hora UTC — no interpretable como local)

| Franja UTC | n | Mediana |
|---|---:|---:|
| 00–08 | 2.327 | 781 min |
| 09–13 | 163 | 514 min |
| 14–18 | 1.729 | 261 min |
| 19–22 | 1.102 | 1.110 min |
| 23–24 | 198 | 1.199 min |

La distribución no es interpretable en horario de Lima. **No se usa para diseñar SLA.**

---

## 8. Comparación WHATMETA vs WHATICKET (control de mezcla)

| Métrica | WHATMETA | WHATICKET |
|---|---:|---:|
| n (servicio) | 13.318 | 206 |
| Mediana | 50,7 min | 286,5 min |
| P75 | 83,8 min | 1.559,7 min |
| P90 | 131,8 min | 4.773,1 min |

Mezclar ambos subcanales bajo "WHATSAPP" habría producido una mediana artificial de 52 min pero un P90 de 182 min, distorsionado por una cola que no pertenece a la operación actual. **Por eso el análisis usa solo WHATMETA.**

---

## 9. Conclusión estadística

1. **Dos regímenes temporales distintos.** WhatsApp resuelve en minutos; correo en horas o días. No comparten escala ni meta.
2. **Dentro de WhatsApp la dispersión entre categorías es baja** (medianas 36–61 min). Un SLA común por canal sería casi tan bueno como uno por subcategoría.
3. **Dentro de correo la dispersión es alta** (medianas 278–1.349 min, factor 4,8). Aquí sí se justifica diferenciar por categoría y subcategoría.
4. **La cola manda en el promedio.** En correo el promedio (1.746 min) triplica la mediana (506 min). Cualquier meta basada en promedio sería incumplible.
5. **Un tercio del volumen no tiene subcategoría oficial.** El árbol de 65 subcategorías debe revisarse antes de prometer SLA por subcategoría.
