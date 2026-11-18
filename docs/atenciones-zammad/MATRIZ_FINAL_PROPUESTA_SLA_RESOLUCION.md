# MATRIZ FINAL — PROPUESTA DE SLA DE RESOLUCIÓN

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2.1
**Fecha:** 16/11/2026
**Ventana:** 2026-04-01 → 2026-10-31
**Base:** 10.750 tickets con subcategoría oficial · 65 combinaciones con n ≥ 10 · 10.711 tickets cubiertos
**Unidad:** minutos. Valores entre paréntesis en horas o días.
**Naturaleza:** propuesta analítica. **No se creó ningún SLA en Zammad.**

---

## 1. Metas de primera respuesta (fijas)

| Canal | Meta | Estado |
|---|---|---|
| WhatsApp | **< 15 minutos** | Aprobada, no recalculada |
| Correo electrónico | **< 24 horas** | Aprobada, no recalculada |

No se calculó ningún percentil de primera respuesta ni se propone objetivo alternativo.

---

## 2. Regla de cálculo aplicada

```
SLA = menor valor de la escalera ≥ P75 de la propia combinación
Escalera: 15 · 30 · 45 · 60 · 90 · 120 · 180 · 240 · 360 · 480 · 720 · 1440 · 2160 · 2880 · 4320 · 5760 · 7200 min
```

- **No** se usa el promedio (sesgado por la cola).
- **No** se usa el P90 (consagra 10 % de incumplimiento).
- **No** se agregan subcategorías ni canales para inflar la muestra.
- Con n < 10 **no hay propuesta**.

Confianza: **ALTA** ≥ 100 · **MEDIA** 30–99 · **BAJA** 10–29 · **INSUFICIENTE** < 10.

---

## 3. Matriz completa

| Canal | Categoría | Subcategoría | N | Promedio | Mediana | P75 | P90 | Confianza | SLA propuesto | Justificación |
|---|---|---|---:|---:|---:|---:|---:|---|---|---|
| CORREO | ADMINISTRATIVO | Nueva licencia o sucursal | 35 | 660.5 | 219 | 1161.3 | 1438.2 | MEDIA | **24 h (1440 min)** | P75 → 24 h (1440 min); cumplimiento histórico 88.6% |
| CORREO | ADMINISTRATIVO | Solicitud de migración | 27 | 2556.4 | 1788 | 4271.1 | 5625.5 | BAJA | **3 d (4320 min)** | P75 → 3 d (4320 min); muestra baja; cumplimiento histórico 74.1% |
| CORREO | CAPACITACION | Solicitud agenda capacitación | 115 | 2195.6 | 1180.8 | 3054.6 | 5503.8 | ALTA | **3 d (4320 min)** | P75 → 3 d (4320 min); cumplimiento histórico 81.7% |
| CORREO | CAPACITACION | Capacitación adm Reportes | 21 | 1257.4 | 264 | 1644 | 3424.2 | BAJA | **36 h (2160 min)** | P75 → 36 h (2160 min); muestra baja; cumplimiento histórico 81% |
| CORREO | DEVOLUCION | Solicitud de devolución | 37 | 2282 | 1348.8 | 3075 | 6384.6 | MEDIA | **3 d (4320 min)** | P75 → 3 d (4320 min); cumplimiento histórico 83.8% |
| CORREO | FACTURACION ELECTRONICA | Ajustes FE | 341 | 912.9 | 171 | 1111.2 | 2584.8 | ALTA | **24 h (1440 min)** | P75 → 24 h (1440 min); alta dispersión (CV 2.3); cumplimiento histórico 83.9% |
| CORREO | FACTURACION ELECTRONICA | Cambio de razón social | 170 | 2125.1 | 955.2 | 2996.1 | 6048.2 | ALTA | **3 d (4320 min)** | P75 → 3 d (4320 min); cumplimiento histórico 81.8% |
| CORREO | FACTURACION ELECTRONICA | Activacion FE | 94 | 2099.8 | 355.5 | 2632.2 | 7241.1 | MEDIA | **2 d (2880 min)** | P75 → 2 d (2880 min); cumplimiento histórico 75.5% |
| CORREO | FACTURACION ELECTRONICA | Validación de comprobantes FE | 67 | 1913.6 | 220.2 | 1818 | 6646.7 | MEDIA | **36 h (2160 min)** | P75 → 36 h (2160 min); alta dispersión (CV 1.8); cumplimiento histórico 77.6% |
| CORREO | FACTURACION ELECTRONICA | Requisitos FE | 60 | 3541 | 1386.9 | 5920.7 | 8995.4 | MEDIA | **5 d (7200 min)** | P75 → 5 d (7200 min); cumplimiento histórico 86.7% |
| CORREO | FACTURACION ELECTRONICA | Error FE del facturador | 38 | 877.5 | 246 | 780.5 | 1823.3 | MEDIA | **24 h (1440 min)** | P75 → 24 h (1440 min); alta dispersión (CV 2.1); cumplimiento histórico 86.8% |
| CORREO | FACTURACION ELECTRONICA | Error FE de cálculo | 36 | 2361.8 | 1515 | 2971.7 | 7145.4 | MEDIA | **3 d (4320 min)** | P75 → 3 d (4320 min); cumplimiento histórico 83.3% |
| CORREO | FACTURACION ELECTRONICA | Emisión de invoice | 28 | 1410.4 | 279.3 | 2097.6 | 3649.5 | BAJA | **36 h (2160 min)** | P75 → 36 h (2160 min); alta dispersión (CV 1.6); muestra baja; cumplimiento histórico 75% |
| CORREO | FACTURACION ELECTRONICA | Error FE envio manual | 19 | 1359.2 | 666 | 2170.8 | 3548.4 | BAJA | **2 d (2880 min)** | P75 → 2 d (2880 min); muestra baja; cumplimiento histórico 78.9% |
| CORREO | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | 2515.2 | 979.2 | 4465.8 | 5583 | INSUF | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | Sin evidencia suficiente (n < 10) |
| CORREO | GESTION | Renovación certificado normal | 177 | 726.6 | 193.8 | 1024.2 | 1560.6 | ALTA | **24 h (1440 min)** | P75 → 24 h (1440 min); alta dispersión (CV 1.8); cumplimiento histórico 85.3% |
| CORREO | GESTION | Venta de CDT certificado | 81 | 1898.4 | 1198.2 | 1698 | 5719.8 | MEDIA | **36 h (2160 min)** | P75 → 36 h (2160 min); cumplimiento histórico 77.8% |
| CORREO | GESTION | Envio de pago | 45 | 1085.3 | 231 | 1233 | 2727.7 | MEDIA | **24 h (1440 min)** | P75 → 24 h (1440 min); alta dispersión (CV 1.7); cumplimiento histórico 77.8% |
| CORREO | GESTION | Seguimiento proactivo | 33 | 1109.1 | 252 | 1398 | 2801.5 | MEDIA | **24 h (1440 min)** | P75 → 24 h (1440 min); alta dispersión (CV 1.6); cumplimiento histórico 75.8% |
| CORREO | INTEGRACIONES | Consulta consumo de apis | 83 | 1804.9 | 535.8 | 2597.4 | 4899.6 | MEDIA | **2 d (2880 min)** | P75 → 2 d (2880 min); alta dispersión (CV 1.7); cumplimiento histórico 80.7% |
| CORREO | INTEGRACIONES | Solicitud de integracion rappi | 25 | 2238.2 | 313.2 | 1615.2 | 6968.5 | BAJA | **36 h (2160 min)** | P75 → 36 h (2160 min); alta dispersión (CV 1.9); muestra baja; cumplimiento histórico 80% |
| CORREO | INTEGRACIONES | Solicitud de integracion Pedidos ya | 14 | 3250.6 | 1405.2 | 5371.7 | 7936.7 | BAJA | **4 d (5760 min)** | P75 → 4 d (5760 min); muestra baja; cumplimiento histórico 78.6% |
| CORREO | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | 2849.9 | 1672.8 | 5733 | 6067.2 | INSUF | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | Sin evidencia suficiente (n < 10) |
| CORREO | INTEGRACIONES | Error integracion | 4 | 3626.4 | 1221.3 | 3922.8 | 8566.8 | INSUF | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | Sin evidencia suficiente (n < 10) |
| CORREO | LOGISTICA | Tarea o capacitación logistica | 319 | 2057.4 | 1071 | 2836.5 | 5962.4 | ALTA | **2 d (2880 min)** | P75 → 2 d (2880 min); cumplimiento histórico 76.2% |
| CORREO | LOGISTICA | Error logistica | 20 | 4668.2 | 2096.1 | 4635.6 | 14584.4 | BAJA | **4 d (5760 min)** | P75 → 4 d (5760 min); muestra baja; cumplimiento histórico 80% |
| CORREO | OPERATIVO | Temas operativos | 119 | 2162.8 | 1027.8 | 2718 | 5533.7 | ALTA | **2 d (2880 min)** | P75 → 2 d (2880 min); alta dispersión (CV 1.5); cumplimiento histórico 77.3% |
| CORREO | SOFTWARE | Error punto de venta | 37 | 1511.5 | 859.8 | 1935 | 3276.6 | MEDIA | **36 h (2160 min)** | P75 → 36 h (2160 min); cumplimiento histórico 75.7% |
| CORREO | SOFTWARE | Seguimiento de errores | 34 | 1254.6 | 1007.1 | 1403.7 | 2796.6 | MEDIA | **24 h (1440 min)** | P75 → 24 h (1440 min); cumplimiento histórico 73.5% |
| CORREO | SOFTWARE | Error web | 12 | 3770 | 2322.9 | 3881.4 | 5436.6 | BAJA | **3 d (4320 min)** | P75 → 3 d (4320 min); muestra baja; cumplimiento histórico 75% |
| WHATSAPP | ADMINISTRATIVO | Nueva licencia o sucursal | 133 | 65.7 | 40.8 | 64.4 | 109.5 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 2.1); cumplimiento histórico 85% |
| WHATSAPP | ADMINISTRATIVO | Solicitud de migración | 85 | 80.4 | 71 | 112.6 | 143.8 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 81.2% |
| WHATSAPP | CAPACITACION | Capacitación integraciones | 454 | 111.1 | 61.3 | 106.5 | 160.5 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 5.4); cumplimiento histórico 81.1% |
| WHATSAPP | CAPACITACION | Solicitud agenda capacitación | 432 | 91.3 | 62.8 | 98 | 146.4 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 1.9); cumplimiento histórico 84% |
| WHATSAPP | CAPACITACION | Capacitación adm Productos | 199 | 74.5 | 53.5 | 86.7 | 129.4 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 75.9% |
| WHATSAPP | CAPACITACION | Capacitación adm Reportes | 190 | 60.4 | 51.4 | 77 | 108.2 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 83.2% |
| WHATSAPP | CAPACITACION | Capacitación operativa | 71 | 63.6 | 45.3 | 74.4 | 136.3 | MEDIA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 77.5% |
| WHATSAPP | DEVOLUCION | Solicitud de devolución | 8 | 60.3 | 32.2 | 64.5 | 120.9 | INSUF | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | Sin evidencia suficiente (n < 10) |
| WHATSAPP | FACTURACION ELECTRONICA | Ajustes FE | 1075 | 69.4 | 50.6 | 80.5 | 123.2 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 80.9% |
| WHATSAPP | FACTURACION ELECTRONICA | Validación de comprobantes FE | 329 | 67.4 | 51.1 | 81.6 | 118.3 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 81.2% |
| WHATSAPP | FACTURACION ELECTRONICA | Cambio de razón social | 132 | 84.1 | 63.5 | 97.4 | 133.4 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 86.4% |
| WHATSAPP | FACTURACION ELECTRONICA | Error FE envio manual | 119 | 59.5 | 40.5 | 62.2 | 93.3 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 1.6); cumplimiento histórico 87.4% |
| WHATSAPP | FACTURACION ELECTRONICA | Activacion FE | 119 | 90.6 | 60.5 | 100.2 | 176.1 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 81.5% |
| WHATSAPP | FACTURACION ELECTRONICA | Requisitos FE | 102 | 96.5 | 56.3 | 81.5 | 104 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 2.9); cumplimiento histórico 84.3% |
| WHATSAPP | FACTURACION ELECTRONICA | Error FE del facturador | 75 | 77.2 | 70.1 | 105.1 | 163 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 78.7% |
| WHATSAPP | FACTURACION ELECTRONICA | Error FE de cálculo | 66 | 92.4 | 78.7 | 112.6 | 166.4 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 75.8% |
| WHATSAPP | FACTURACION ELECTRONICA | Consecutivos topes folios | 57 | 53.5 | 44.1 | 67.6 | 98.4 | MEDIA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 86% |
| WHATSAPP | FACTURACION ELECTRONICA | Error FE por duplicidad | 51 | 91.2 | 79 | 107.8 | 151.1 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 86.3% |
| WHATSAPP | FACTURACION ELECTRONICA | Emisión de invoice | 48 | 63.3 | 43.6 | 66 | 97.3 | MEDIA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 87.5% |
| WHATSAPP | FACTURACION ELECTRONICA | FE solicitud xml pdf | 20 | 38.3 | 32.9 | 44.6 | 56.3 | BAJA | **45 min** | P75 → 45 min; muestra baja; cumplimiento histórico 75% |
| WHATSAPP | FACTURACION ELECTRONICA | Activacion NV | 9 | 82.2 | 57.3 | 125 | 160.9 | INSUF | **PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO** | Sin evidencia suficiente (n < 10) |
| WHATSAPP | GESTION | Seguimiento proactivo | 473 | 58 | 39.5 | 76.1 | 122.5 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 82.5% |
| WHATSAPP | GESTION | Envio de pago | 386 | 83 | 33.1 | 56.9 | 100.6 | ALTA | **1 h (60 min)** | P75 → 1 h (60 min); alta dispersión (CV 4.5); cumplimiento histórico 76.2% |
| WHATSAPP | GESTION | Renovación certificado normal | 312 | 115.3 | 46.9 | 70.7 | 100.9 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 4.5); cumplimiento histórico 84.9% |
| WHATSAPP | GESTION | Venta de CDT certificado | 157 | 138.9 | 51 | 76.8 | 119.5 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 5.8); cumplimiento histórico 81.5% |
| WHATSAPP | INTEGRACIONES | Solicitud de integracion rappi | 280 | 109.5 | 60.6 | 105.6 | 176.5 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 2.8); cumplimiento histórico 82.1% |
| WHATSAPP | INTEGRACIONES | Solicitud de integracion Pedidos ya | 165 | 232.7 | 65.7 | 117.8 | 206.6 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 7.3); cumplimiento histórico 75.8% |
| WHATSAPP | INTEGRACIONES | Consulta consumo de apis | 80 | 63.8 | 53 | 72 | 103.6 | MEDIA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 86.3% |
| WHATSAPP | INTEGRACIONES | Error integracion | 49 | 83.8 | 73.4 | 100.4 | 156.7 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 79.6% |
| WHATSAPP | INTEGRACIONES | Solicitud de integracion uber | 24 | 143.7 | 50 | 95.2 | 198.1 | BAJA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 2.2); muestra baja; cumplimiento histórico 79.2% |
| WHATSAPP | INTEGRACIONES | Solicitud de integracion sistemas contables | 12 | 103.7 | 92.1 | 137.8 | 168 | BAJA | **3 h (180 min)** | P75 → 3 h (180 min); muestra baja; cumplimiento histórico 91.7% |
| WHATSAPP | LOGISTICA | Capacitación logistica avanzado | 859 | 98.2 | 56.5 | 86.3 | 122 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 7.1); cumplimiento histórico 77.4% |
| WHATSAPP | LOGISTICA | Capacitación logistica insumos recetas | 298 | 75.7 | 56.3 | 86.3 | 127.5 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); cumplimiento histórico 78.5% |
| WHATSAPP | LOGISTICA | Error logistica | 49 | 137.2 | 89.4 | 117.9 | 192.9 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 1.7); cumplimiento histórico 75.5% |
| WHATSAPP | OPERATIVO | Temas operativos | 1063 | 61.6 | 36.2 | 62.5 | 102.3 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 1.9); cumplimiento histórico 87.3% |
| WHATSAPP | SERVIDOR | Caída del servidor | 49 | 169.4 | 40.5 | 55.7 | 590.5 | MEDIA | **1 h (60 min)** | P75 → 1 h (60 min); alta dispersión (CV 2.5); cumplimiento histórico 75.5% |
| WHATSAPP | SOFTWARE | Error punto de venta | 293 | 308.8 | 35.7 | 68.3 | 127.8 | ALTA | **1.5 h (90 min)** | P75 → 1.5 h (90 min); alta dispersión (CV 6.2); cumplimiento histórico 80.2% |
| WHATSAPP | SOFTWARE | Seguimiento de errores | 241 | 107 | 58.7 | 106.4 | 153.5 | ALTA | **2 h (120 min)** | P75 → 2 h (120 min); alta dispersión (CV 2); cumplimiento histórico 82.6% |
| WHATSAPP | SOFTWARE | Error add on asistencias | 51 | 82.1 | 62.1 | 98.5 | 142.4 | MEDIA | **2 h (120 min)** | P75 → 2 h (120 min); cumplimiento histórico 82.4% |
| WHATSAPP | SOFTWARE | Error web | 26 | 114.9 | 101.2 | 160.7 | 218.4 | BAJA | **3 h (180 min)** | P75 → 3 h (180 min); muestra baja; cumplimiento histórico 80.8% |

---

## 4. Resumen

| Canal | Combinaciones con SLA | Combinaciones sin SLA | Tickets cubiertos | Rango de metas |
|---|---:|---:|---:|---|
| WhatsApp | 37 | 2 | 8.624 | 45 min – 3 h |
| Correo | 28 | 3 | 2.087 | 24 h – 120 h |
| **Total** | **65** | **5** | **10.711** | — |

**Cumplimiento histórico agregado de la propuesta:** **81,4 %** (WhatsApp 81,7 % · Correo 80,4 %).

### 4.1 Distribución de metas

| SLA | Combinaciones |
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

**Concentración:** 33 de 37 combinaciones de WhatsApp caen en 1 h 30 min o 2 h. La diferenciación real está en correo.

---

## 5. Combinaciones sin SLA

| Canal | Categoría | Subcategoría | n | Motivo |
|---|---|---|---:|---|
| WhatsApp | DEVOLUCIÓN | Solicitud de devolución | 8 | n < 10 |
| WhatsApp | FACTURACIÓN | Activación NV | 9 | n < 10 |
| Correo | FACTURACIÓN | Error FE por duplicidad | 9 | n < 10 |
| Correo | INTEGRACIONES | Integración sistemas contables | 9 | n < 10 |
| Correo | INTEGRACIONES | Error integración | 4 | n < 10 |

**Estado:** `PENDIENTE DE VALIDACIÓN — SIN SLA PROPUESTO`. No se asigna ningún tiempo.

---

## 6. Volumen no cubierto

| Concepto | Tickets | % de la base de servicio |
|---|---:|---:|
| Categorías de servicio | 15.592 | 100 % |
| Cubiertos por la matriz | 10.711 | 68,7 % |
| Subcategoría fuera del catálogo oficial | 4.842 | 31,1 % |
| Combinaciones con n < 10 | 39 | 0,3 % |

**Tratamiento propuesto para el 31,1 %:** aplicar el SLA de respaldo del canal (WhatsApp 1 h 30 min · correo 36 h), tal como se definió en 5G.2, hasta que se revise el catálogo de subcategorías.

---

## 7. Advertencias

1. Las metas están en **minutos calendario**. Zammad mide en **horas hábiles**: la equivalencia se analiza en `OBSERVACIONES_Y_DECISIONES_PENDIENTES_5G2_1.md` §2. **No se convirtieron.**
2. Las metas de confianza **BAJA** (12 combinaciones) son provisionales y deben revisarse a los 90 días.
3. Las 20 combinaciones con CV ≥ 2,0 requieren revisión aunque su muestra sea alta.
4. No se copió ningún valor del documento general de SLA de Zendesk ni del `SLA_MINUTOS` provisional de COSE.
5. No se usaron datos de otro canal para completar ninguna fila.
6. La primera respuesta no se recalculó.

---

## 8. Traducción a minutos para Zammad

| Meta | Minutos |
|---|---:|
| WhatsApp — primera respuesta | 15 |
| Correo — primera respuesta | 1.440 |
| 45 min | 45 |
| 1 h | 60 |
| 1 h 30 min | 90 |
| 2 h | 120 |
| 3 h | 180 |
| 24 h | 1.440 |
| 36 h | 2.160 |
| 48 h | 2.880 |
| 72 h | 4.320 |
| 96 h | 5.760 |
| 120 h | 7.200 |
