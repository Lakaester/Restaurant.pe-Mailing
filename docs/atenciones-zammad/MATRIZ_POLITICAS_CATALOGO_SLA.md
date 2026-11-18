# MATRIZ DE POLÍTICAS DEL CATÁLOGO — EPIC-SLA-01

**Fecha:** 17/11/2026
**Estado:** clasificación derivada y verificada. **No cargada en base de datos.**
**Fuente del catálogo:** `frontend/src/components/workspace/CategoryData.ts`
**Copia verificada:** `backend/src/domain/sla/catalogo/catalogo-oficial.json` (SHA-256 `d0fb5aae25019acad683ddb9273af124ba66b124a504ebc41c2605ed18a91196`)
**Fuente de la matriz:** `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` y `EPIC_IMPLEMENTACION_SLA_COSE.md` §6.3
**Fuente de las exclusiones:** decisión confirmada DEC-05 (16/11/2026)

---

## 1. Objeto

Esta matriz asigna a **cada una de las 65 subcategorías del catálogo oficial** una de cuatro clases de política:

| Clase | Significado | Cantidad |
|---|---|---:|
| **SLA de matriz** | Combinación con evidencia suficiente; recibe el escalón aprobado de la matriz | **27** |
| **Sin evidencia** | Combinación conocida con n < 10; sin SLA y sin respaldo | **3** |
| **Respaldo de servicio** | Subcategoría de servicio fuera de las 30 filas; hereda `99-FALLBACK` de 36 h, marcado provisional | **28** |
| **Excluido no servicio** | Caso no servicio confirmado por DEC-05; sin SLA ni respaldo | **7** |
| **Total** | | **65** |

Resuelve **OBS-30**: el catálogo por sí solo no determina la clase SLA. La clase se deriva del cruce entre el par (categoría, subcategoría), la matriz oficial y DEC-05. Esta matriz es la propuesta de mapa derivado; **no sustituye la ratificación de Soporte** (DP-04) ni la aprobación final AP-01.

---

## 2. Método de derivación

1. Se recorre el catálogo exportado en su orden original (13 categorías, 65 subcategorías).
2. Se normaliza el par (categoría, subcategoría) sin tildes y sin distinguir mayúsculas.
3. Si el par coincide con una de las **30 filas** de la matriz:
   - con `n >= 10` → **SLA de matriz**;
   - con `n < 10` → **sin evidencia**.
4. Si no coincide con la matriz pero pertenece a las **7 subcategorías DEC-05** → **excluido no servicio**.
5. Si no coincide con la matriz ni con DEC-05 → **respaldo de servicio** de 36 h.

Reglas de precedencia:

- La coincidencia exige **categoría y subcategoría**, nunca solo la subcategoría. `Cambio de razón social` existe en dos categorías y produce dos políticas distintas.
- Las 7 excluidas se evalúan **antes** del respaldo. Si no fuera así, DEC-05 recibiría 36 h, que es exactamente lo que la decisión prohíbe.
- Las 3 sin evidencia **no** reciben respaldo (BR-42). Son combinaciones conocidas, no subcategorías fuera de la matriz.

---

## 3. Niveles de aprobación

No todas las filas tienen el mismo grado de respaldo documental. Esta matriz distingue:

| Nivel | Alcance | Qué significa |
|---|---|---|
| **Decisión confirmada** | Las 7 filas DEC-05 | Confirmada el 16/11/2026; no se reabre sin revisión formal |
| **Regla del EPIC** | Las 3 sin evidencia (BR-41/42) | Regla escrita en el contrato de la épica; sujetas a AP-01 |
| **Matriz oficial con aprobación condicional** | Las 27 con SLA | Matriz oficial para la implementación; AP-01 sigue en `conditional_pending_final_validation` |
| **Clase derivada pendiente de ratificación** | Las 28 con respaldo | El respaldo está aprobado (BR-43 / Matriz §9); la clasificación de cada subcategoría como servicio necesita la ratificación de Soporte (DP-04) |

**Consecuencia:** ninguna de las 65 filas se declara "aprobada" por esta matriz. Esta matriz es el objeto a aprobar, no la aprobación.

---

## 4. Matriz completa (65 filas)

| # | Categoría | Subcategoría | Slug (`value`) | Identificador de política | Clase | SLA / motivo | Fuente de la decisión | Evidencia | Estado de aprobación |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | FACTURACIÓN ELECTRÓNICA | Activacion NV | `activacion_nv` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 2 | FACTURACIÓN ELECTRÓNICA | Ajustes FE | `ajustes_fe` | `20-MAIL-FACTURACION_ELECTRONICA-AJUSTES_FE` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 6 / Matriz 5G.4.4 | n=341; P75=1.111,2; ALTA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 3 | FACTURACIÓN ELECTRÓNICA | Cambio de razón social | `cambio_de_razón_social` | `20-MAIL-FACTURACION_ELECTRONICA-CAMBIO_DE_RAZON_SOCIAL` | SLA de matriz | 4.320 min (72 h) | EPIC §6.3 fila 7 / Matriz 5G.4.4 | n=170; P75=2.996,1; ALTA; escalón 4.320 min | Matriz oficial; ratificación AP-01 pendiente |
| 4 | FACTURACIÓN ELECTRÓNICA | Cambio impuesto FE | `cambio_impuesto_fe` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 5 | FACTURACIÓN ELECTRÓNICA | Activacion FE | `activacion_fe` | `20-MAIL-FACTURACION_ELECTRONICA-ACTIVACION_FE` | SLA de matriz | 2.880 min (48 h) | EPIC §6.3 fila 8 / Matriz 5G.4.4 | n=94; P75=2.632,2; MEDIA; escalón 2.880 min | Matriz oficial; ratificación AP-01 pendiente |
| 6 | FACTURACIÓN ELECTRÓNICA | Emisión de invoice | `emisión_de_invoice_o_factura` | `20-MAIL-FACTURACION_ELECTRONICA-EMISION_DE_INVOICE` | SLA de matriz | 2.160 min (36 h) | EPIC §6.3 fila 13 / Matriz 5G.4.4 | n=28; P75=2.097,6; BAJA; escalón 2.160 min | Matriz oficial; ratificación AP-01 pendiente |
| 7 | FACTURACIÓN ELECTRÓNICA | Requisitos FE | `requisitos_fe` | `20-MAIL-FACTURACION_ELECTRONICA-REQUISITOS_FE` | SLA de matriz | 7.200 min (120 h) | EPIC §6.3 fila 10 / Matriz 5G.4.4 | n=60; P75=5.920,7; MEDIA; escalón 7.200 min | Matriz oficial; ratificación AP-01 pendiente |
| 8 | FACTURACIÓN ELECTRÓNICA | Error FE del facturador | `error_fe_del_facturador_o_ente_regulador` | `20-MAIL-FACTURACION_ELECTRONICA-ERROR_FE_DEL_FACTURADOR` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 11 / Matriz 5G.4.4 | n=38; P75=780,5; MEDIA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 9 | FACTURACIÓN ELECTRÓNICA | Error FE de cálculo | `error_fe_de_cálculo` | `20-MAIL-FACTURACION_ELECTRONICA-ERROR_FE_DE_CALCULO` | SLA de matriz | 4.320 min (72 h) | EPIC §6.3 fila 12 / Matriz 5G.4.4 | n=36; P75=2.971,7; MEDIA; escalón 4.320 min | Matriz oficial; ratificación AP-01 pendiente |
| 10 | FACTURACIÓN ELECTRÓNICA | Error FE por duplicidad | `error_fe_por_duplicidad` | `20-MAIL-FACTURACION_ELECTRONICA-ERROR_FE_POR_DUPLICIDAD` | Sin evidencia | Sin SLA — n=9 < 10; no aplica respaldo | EPIC §6.5 / BR-41, BR-42 | n=9; P75=4.465,8; INSUFICIENTE | Regla BR-41/42; DP-E-07 pendiente |
| 11 | FACTURACIÓN ELECTRÓNICA | Error FE envio manual | `error_fe_envio_manual_postman` | `20-MAIL-FACTURACION_ELECTRONICA-ERROR_FE_ENVIO_MANUAL` | SLA de matriz | 2.880 min (48 h) | EPIC §6.3 fila 14 / Matriz 5G.4.4 | n=19; P75=2.170,8; BAJA; escalón 2.880 min | Matriz oficial; ratificación AP-01 pendiente |
| 12 | FACTURACIÓN ELECTRÓNICA | Consecutivos topes folios | `consecutivos_topes_folios` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 13 | FACTURACIÓN ELECTRÓNICA | FE solicitud xml pdf | `fe_solicitud_xml_pdf` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 14 | FACTURACIÓN ELECTRÓNICA | Validación de comprobantes FE | `validación_de_comprobantes_fe` | `20-MAIL-FACTURACION_ELECTRONICA-VALIDACION_DE_COMPROBANTES_FE` | SLA de matriz | 2.160 min (36 h) | EPIC §6.3 fila 9 / Matriz 5G.4.4 | n=67; P75=1.818; MEDIA; escalón 2.160 min | Matriz oficial; ratificación AP-01 pendiente |
| 15 | LOGÍSTICA | Capacitación logistica avanzado | `capacitación_logistica_avanzado` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 16 | LOGÍSTICA | Capacitación logistica insumos recetas | `capacitación_logistica_insumos_recetas` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 17 | LOGÍSTICA | Tarea o capacitación logistica | `tarea_o_capacitación_logistica` | `20-MAIL-LOGISTICA-TAREA_O_CAPACITACION_LOGISTICA` | SLA de matriz | 2.880 min (48 h) | EPIC §6.3 fila 25 / Matriz 5G.4.4 | n=319; P75=2.836,5; ALTA; escalón 2.880 min | Matriz oficial; ratificación AP-01 pendiente |
| 18 | LOGÍSTICA | Temas operativos punto de venta | `temas_operativos_punto_de_venta` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 19 | LOGÍSTICA | Error logistica | `error_logistica` | `20-MAIL-LOGISTICA-ERROR_LOGISTICA` | SLA de matriz | 5.760 min (96 h) | EPIC §6.3 fila 26 / Matriz 5G.4.4 | n=20; P75=4.635,6; BAJA; escalón 5.760 min | Matriz oficial; ratificación AP-01 pendiente |
| 20 | INTEGRACIONES | Solicitud de integracion rappi | `solicitud_de_integración_rappi` | `20-MAIL-INTEGRACIONES-SOLICITUD_DE_INTEGRACION_RAPPI` | SLA de matriz | 2.160 min (36 h) | EPIC §6.3 fila 21 / Matriz 5G.4.4 | n=25; P75=1.615,2; BAJA; escalón 2.160 min | Matriz oficial; ratificación AP-01 pendiente |
| 21 | INTEGRACIONES | Solicitud de integracion Pedidos ya | `solicitud_de_integración_pedidos_ya` | `20-MAIL-INTEGRACIONES-SOLICITUD_DE_INTEGRACION_PEDIDOS_YA` | SLA de matriz | 5.760 min (96 h) | EPIC §6.3 fila 22 / Matriz 5G.4.4 | n=14; P75=5.371,7; BAJA; escalón 5.760 min | Matriz oficial; ratificación AP-01 pendiente |
| 22 | INTEGRACIONES | Solicitud de integracion uber | `solicitud_de_integración_uber` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 23 | INTEGRACIONES | Integraciones y apis | `integraciones_y_apis` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 24 | INTEGRACIONES | Consulta consumo de apis | `consulta_consumo_de_apis` | `20-MAIL-INTEGRACIONES-CONSULTA_CONSUMO_DE_APIS` | SLA de matriz | 2.880 min (48 h) | EPIC §6.3 fila 20 / Matriz 5G.4.4 | n=83; P75=2.597,4; MEDIA; escalón 2.880 min | Matriz oficial; ratificación AP-01 pendiente |
| 25 | INTEGRACIONES | Error integracion | `error_integracion` | `20-MAIL-INTEGRACIONES-ERROR_INTEGRACION` | Sin evidencia | Sin SLA — n=4 < 10; no aplica respaldo | EPIC §6.5 / BR-41, BR-42 | n=4; P75=3.922,8; INSUFICIENTE | Regla BR-41/42; DP-E-07 pendiente |
| 26 | INTEGRACIONES | Solicitud de integracion sistemas contables | `solicitud_de_integración_sistemas_contables` | `20-MAIL-INTEGRACIONES-SOLICITUD_DE_INTEGRACION_SISTEMAS_CONTABLES` | Sin evidencia | Sin SLA — n=9 < 10; no aplica respaldo | EPIC §6.5 / BR-41, BR-42 | n=9; P75=5.733; INSUFICIENTE | Regla BR-41/42; DP-E-07 pendiente |
| 27 | SOFTWARE | Error punto de venta | `error_punto_de_venta` | `20-MAIL-SOFTWARE-ERROR_PUNTO_DE_VENTA` | SLA de matriz | 2.160 min (36 h) | EPIC §6.3 fila 28 / Matriz 5G.4.4 | n=37; P75=1.935; MEDIA; escalón 2.160 min | Matriz oficial; ratificación AP-01 pendiente |
| 28 | SOFTWARE | Error web | `error_web` | `20-MAIL-SOFTWARE-ERROR_WEB` | SLA de matriz | 4.320 min (72 h) | EPIC §6.3 fila 30 / Matriz 5G.4.4 | n=12; P75=3.881,4; BAJA; escalón 4.320 min | Matriz oficial; ratificación AP-01 pendiente |
| 29 | SOFTWARE | Error backend | `error_backend` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 30 | SOFTWARE | Mejora personalizada | `mejora_personalizada` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 31 | SOFTWARE | Seguimiento de errores | `seguimiento_de_errores` | `20-MAIL-SOFTWARE-SEGUIMIENTO_DE_ERRORES` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 29 / Matriz 5G.4.4 | n=34; P75=1.403,7; MEDIA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 32 | SOFTWARE | Error add on asistencias | `error_add_on_asistencias` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 33 | GESTIÓN | Seguimiento proactivo | `seguimiento_proactivo` | `20-MAIL-GESTION-SEGUIMIENTO_PROACTIVO` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 19 / Matriz 5G.4.4 | n=33; P75=1.398; MEDIA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 34 | GESTIÓN | Seguimiento de cdt | `seguimiento_de_cdt` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 35 | GESTIÓN | Renovación certificado normal | `renovación_certificado_normal` | `20-MAIL-GESTION-RENOVACION_CERTIFICADO_NORMAL` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 16 / Matriz 5G.4.4 | n=177; P75=1.024,2; ALTA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 36 | GESTIÓN | Venta de CDT certificado | `venta_de_cdt_certificado` | `20-MAIL-GESTION-VENTA_DE_CDT_CERTIFICADO` | SLA de matriz | 2.160 min (36 h) | EPIC §6.3 fila 17 / Matriz 5G.4.4 | n=81; P75=1.698; MEDIA; escalón 2.160 min | Matriz oficial; ratificación AP-01 pendiente |
| 37 | GESTIÓN | Envio de pago | `envio_de_pago` | `20-MAIL-GESTION-ENVIO_DE_PAGO` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 18 / Matriz 5G.4.4 | n=45; P75=1.233; MEDIA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 38 | GESTIÓN | Pagos prorrogas descuentos | `pagos__prorrogas__descuentos` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 39 | ADMINISTRATIVO | Nueva licencia o sucursal | `nueva_licencia_o_sucursal` | `20-MAIL-ADMINISTRATIVO-NUEVA_LICENCIA_O_SUCURSAL` | SLA de matriz | 1.440 min (24 h) | EPIC §6.3 fila 1 / Matriz 5G.4.4 | n=35; P75=1.161,3; MEDIA; escalón 1.440 min | Matriz oficial; ratificación AP-01 pendiente |
| 40 | ADMINISTRATIVO | Baja sucursal | `baja_sucursal` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 41 | ADMINISTRATIVO | Cambio de razón social | `cambio_de_razón_social` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 42 | ADMINISTRATIVO | Temas administrativos | `temas_administrativos_o_configuraciones_del_sistema` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 43 | ADMINISTRATIVO | Solicitud de migración | `solicitud_de_migración` | `20-MAIL-ADMINISTRATIVO-SOLICITUD_DE_MIGRACION` | SLA de matriz | 4.320 min (72 h) | EPIC §6.3 fila 2 / Matriz 5G.4.4 | n=27; P75=4.271,1; BAJA; escalón 4.320 min | Matriz oficial; ratificación AP-01 pendiente |
| 44 | ADMINISTRATIVO | Activación de Addons | `activación_de_addons` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 45 | OPERATIVO | Temas operativos | `temas_operativos` | `20-MAIL-OPERATIVO-TEMAS_OPERATIVOS` | SLA de matriz | 2.880 min (48 h) | EPIC §6.3 fila 27 / Matriz 5G.4.4 | n=119; P75=2.718; ALTA; escalón 2.880 min | Matriz oficial; ratificación AP-01 pendiente |
| 46 | OPERATIVO | Cajas | `cajas` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 47 | OPERATIVO | Redes y conexiones | `redes_y_conexiones` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 48 | OPERATIVO | Caída del servidor | `caída_del_servidor` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 49 | CAPACITACIÓN | Capacitación logistica | `capacitación_logistica` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 50 | CAPACITACIÓN | Capacitación integraciones | `capacitación_integraciones` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 51 | CAPACITACIÓN | Capacitación adm Reportes | `capacitación_adm_reportes` | `20-MAIL-CAPACITACION-CAPACITACION_ADM_REPORTES` | SLA de matriz | 2.160 min (36 h) | EPIC §6.3 fila 4 / Matriz 5G.4.4 | n=21; P75=1.644; BAJA; escalón 2.160 min | Matriz oficial; ratificación AP-01 pendiente |
| 52 | CAPACITACIÓN | Capacitación adm Productos | `capacitación_adm_productos` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 53 | CAPACITACIÓN | Capacitación operativa | `capacitación_operativa` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 54 | CAPACITACIÓN | Capacitación delivery pro | `capacitación_delivery_pro` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 55 | CAPACITACIÓN | Solicitud agenda capacitación | `solicitud_agenda_capacitación` | `20-MAIL-CAPACITACION-SOLICITUD_AGENDA_CAPACITACION` | SLA de matriz | 4.320 min (72 h) | EPIC §6.3 fila 3 / Matriz 5G.4.4 | n=115; P75=3.054,6; ALTA; escalón 4.320 min | Matriz oficial; ratificación AP-01 pendiente |
| 56 | SERVIDOR | Caída del servidor | `caída_del_servidor` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 57 | SERVIDOR | Redes y conexiones | `redes_y_conexiones` | `99-FALLBACK` | Respaldo de servicio | 2.160 min (36 h) provisional | EPIC §6.6 / BR-43 / Matriz §9 | Fuera de las 30 filas; no es una de las 7 DEC-05 | BR-43 aprobado; clase pendiente OBS-30 |
| 58 | SIN HOMOLOGAR | Sin dato | `sin_dato` | `20-MAIL-SIN_HOMOLOGAR-SIN_DATO` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 59 | SIN HOMOLOGAR | Duplicado o spam | `duplicado_o_spam` | `20-MAIL-SIN_HOMOLOGAR-DUPLICADO_O_SPAM` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 60 | SIN HOMOLOGAR | No contestó | `no_contestó` | `20-MAIL-SIN_HOMOLOGAR-NO_CONTESTO` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 61 | RECLAMO | Reclamo | `reclamo` | `20-MAIL-RECLAMO-RECLAMO` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 62 | QUEJA | Servicio | `queja_servicio` | `20-MAIL-QUEJA-SERVICIO` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 63 | QUEJA | Producto | `queja_producto` | `20-MAIL-QUEJA-PRODUCTO` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 64 | QUEJA | Otro | `queja_otro` | `20-MAIL-QUEJA-OTRO` | Excluido no servicio | Sin SLA ni respaldo — excluido | EPIC §1.4.1 DEC-05 / BR-65 | Caso no servicio confirmado el 16/11/2026 | Confirmada (DEC-05) |
| 65 | DEVOLUCIÓN | Solicitud de devolución | `solicitud_de_devolución` | `20-MAIL-DEVOLUCION-SOLICITUD_DE_DEVOLUCION` | SLA de matriz | 4.320 min (72 h) | EPIC §6.3 fila 5 / Matriz 5G.4.4 | n=37; P75=3.075; MEDIA; escalón 4.320 min | Matriz oficial; ratificación AP-01 pendiente |

**Nota sobre el identificador:** las 28 filas de respaldo comparten `99-FALLBACK` porque no tienen política propia: heredan la política provisional de 36 h. Las 37 filas restantes tienen clave `20-MAIL-<CATEGORÍA>-<SUBCATEGORÍA>`, normalizada sin tildes y con separadores en guion bajo.

---

## 5. Verificación de cantidades

| Verificación | Resultado |
|---|---:|
| Subcategorías del catálogo | 65 |
| Filas con SLA de matriz | 27 |
| Filas sin evidencia | 3 |
| Filas con respaldo de servicio | 28 |
| Filas excluidas no servicio | 7 |
| Suma de clases | 65 |
| Filas de la matriz consumidas exactamente una vez | 30 / 30 |
| Exclusiones DEC-05 consumidas exactamente una vez | 7 / 7 |
| Suma de N de las 27 con SLA | 2.087 |
| Suma de N de las 3 sin evidencia | 22 |
| Suma de N de las 30 filas | 2.109 |

---

## 6. Distribución por categoría

| Categoría | Subcategorías | Matriz | Sin evidencia | Respaldo | Excluidas |
|---|---:|---:|---:|---:|---:|
| FACTURACIÓN ELECTRÓNICA | 14 | 9 | 1 | 4 | 0 |
| LOGÍSTICA | 5 | 2 | 0 | 3 | 0 |
| INTEGRACIONES | 7 | 3 | 2 | 2 | 0 |
| SOFTWARE | 6 | 3 | 0 | 3 | 0 |
| GESTIÓN | 6 | 4 | 0 | 2 | 0 |
| ADMINISTRATIVO | 6 | 2 | 0 | 4 | 0 |
| OPERATIVO | 4 | 1 | 0 | 3 | 0 |
| CAPACITACIÓN | 7 | 2 | 0 | 5 | 0 |
| SERVIDOR | 2 | 0 | 0 | 2 | 0 |
| SIN HOMOLOGAR | 3 | 0 | 0 | 0 | 3 |
| RECLAMO | 1 | 0 | 0 | 0 | 1 |
| QUEJA | 3 | 0 | 0 | 0 | 3 |
| DEVOLUCIÓN | 1 | 1 | 0 | 0 | 0 |
| **Total** | **65** | **27** | **3** | **28** | **7** |

---

## 7. Casos que requieren atención

### 7.1 Cambio de razón social

La etiqueta existe en dos categorías:

- `FACTURACIÓN ELECTRÓNICA | Cambio de razón social` → matriz fila 7 → **4.320 min (72 h)**.
- `ADMINISTRATIVO | Cambio de razón social` → fuera de la matriz → **respaldo de 36 h**.

Elegir la categoría equivocada cambia el compromiso en 36 horas. El motor nunca debe inferir la categoría desde el slug.

### 7.2 Slugs repetidos

| Slug | Apariciones | Pares (categoría \| subcategoría) |
|---|---:|---|
| `cambio_de_razón_social` | 2 | FACTURACIÓN ELECTRÓNICA | Cambio de razón social<br>ADMINISTRATIVO | Cambio de razón social |
| `redes_y_conexiones` | 2 | OPERATIVO | Redes y conexiones<br>SERVIDOR | Redes y conexiones |
| `caída_del_servidor` | 2 | OPERATIVO | Caída del servidor<br>SERVIDOR | Caída del servidor |

Los 3 slugs repetidos producen 62 identificadores únicos para 65 subcategorías. El par (categoría, subcategoría) es obligatorio.

### 7.3 Las 3 sin evidencia

`Error FE por duplicidad`, `Solicitud de integracion sistemas contables` y `Error integracion` suman 22 tickets. No reciben SLA ni respaldo. La recomendación de revisarlas a los 90 días (DP-E-07) sigue pendiente de confirmación.

### 7.4 Las 28 con respaldo

Incluyen, entre otras, `Cambio de razón social` de ADMINISTRATIVO, `Caída del servidor` y `Redes y conexiones` (presentes en OPERATIVO y en SERVIDOR). El respaldo de 36 h gobernaría 1 de cada 3 tickets según el EPIC §6.6; no es un caso marginal.

### 7.5 Las 7 excluidas

No se ofrecen como clasificación de SLA, no reciben compromiso y quedan fuera de todos los denominadores. Aun así conservan fila de política `inactive` para que el motor pueda distinguirlas del respaldo y registrar el motivo.

---

## 8. Lo que esta matriz no hace

- No carga políticas en `sla_policy_version`.
- No modifica el catálogo original ni el JSON exportado.
- No crea ni modifica tablas, bases o roles.
- No aprueba la matriz: la somete a revisión.
- No convierte las 28 clases derivadas en decisiones de Soporte.
- No altera la condición de AP-01, AP-02 ni AP-03.

---

## 9. Confirmación

- 65 filas generadas desde el catálogo exportado, no transcritas a mano.
- 27 + 3 + 28 + 7 = 65, verificado por el generador.
- Las 30 filas de la matriz y las 7 exclusiones DEC-05 se consumen exactamente una vez.
- Ninguna fila se marcó como aprobada sin registro de aprobación.
- No se ejecutó SQL ni se conectó a PostgreSQL.
