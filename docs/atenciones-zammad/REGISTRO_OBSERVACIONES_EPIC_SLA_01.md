# REGISTRO DE OBSERVACIONES — EPIC-SLA-01

**Fecha:** 17/11/2026 · **Clasificación:** `RESUELTO_POR_CONTRATO`, `RESUELTO_POR_EVIDENCIA_TECNICA`, `REQUIERE_APROBACION_FUNCIONAL`, `REQUIERE_APROBACION_TECNICA`, `REQUIERE_DBA`, `BLOQUEO_EXTERNO`, `SIN_EVIDENCIA`.

| ID | Hallazgo | Clasificación | Acción tomada | Estado |
|---|---|---|---|---|
| OBS-E-01 | ¿Primera respuesta `≤` o `<` 24 h? | `RESUELTO_POR_CONTRATO` | `< 86.400 s`; DP-E-04 cerrada, BR-23 | Cerrada |
| OBS-E-02 | REA-02 aparece pendiente en 5G.4.4 y aprobada en 5G.4.5 | `RESUELTO_POR_CONTRATO` | Precedencia 5G.4.5; queda la firma D-01 | Cerrada; firma pendiente |
| OBS-E-03 | `source` con `webhook` | `RESUELTO_POR_EVIDENCIA_TECNICA` | Descartada: L108/L49 prohíben webhooks | Cerrada |
| OBS-E-04 | BR-68/69/70 citados en el encargo | `SIN_EVIDENCIA` | No existen; no se inventaron | Cerrada |
| OBS-E-05 | DP-04 abierta en paquete, confirmada en EPIC | `RESUELTO_POR_CONTRATO` | Prevalece EPIC/TABLERO; se documentó la inconsistencia | Cerrada; corrección documental pendiente |
| OBS-E-06 | Roles/API propios del módulo SLA sin contrato | `SIN_EVIDENCIA` | Se reutilizan `requireAuth` y `requirePermission("Configuracion","administrar")`; se documentó la decisión | Cerrada con decisión técnica |
| OBS-E-07 | OpenAPI no implementado en el repositorio | `RESUELTO_POR_EVIDENCIA_TECNICA` | Se documenta `CONTRATOS_API_SLA.md` como especificación | Cerrada |
| OBS-E-08 | Sin base `restaurant_bi_test` ni roles | `REQUIERE_DBA` | Solicitud exacta en `PLAN_MIGRACION_SLA.md` §2 | `BLOCKED` |
| OBS-E-09 | Sin cliente `psql`/Docker en la estación | `BLOQUEO_EXTERNO` | No se instala; no se conecta | `BLOCKED` |
| OBS-E-10 | Memoria libre 611 MB, 7 procesos node | `BLOQUEO_EXTERNO` | No se lanzaron pruebas paralelas intensivas | Mitigado |
| OBS-E-11 | M1–M8 sin aprobación | `REQUIERE_APROBACION_TECNICA` | Procedimiento documentado | `DEFERRED` |
| OBS-E-12 | BLK-09 sin ventana | `BLOQUEO_EXTERNO` | Rollback y E2E no ejecutados | `BLOCKED` |
| OBS-E-13 | D-01 sin firma funcional | `REQUIERE_APROBACION_FUNCIONAL` | Alternativa A implementada en código | `DEFERRED` |
| OBS-E-14 | D-02 sin firma de las 28 filas | `REQUIERE_APROBACION_FUNCIONAL` | Motor bloquea el fallback por defecto | `DEFERRED` |
| OBS-E-15 | D-03..D-06 sin confirmación técnica | `REQUIERE_APROBACION_TECNICA` | Fichas en el paquete; DDL sin cambios | `DEFERRED` |
| OBS-E-16 | D-07/D-08 recomendadas, no aprobadas | `REQUIERE_APROBACION_TECNICA` | No se crearon las tablas; impacto documentado | `DEFERRED` |
| OBS-E-17 | AP-01/02/03 condicionales | `REQUIERE_APROBACION_FUNCIONAL` | No se declara aprobada la matriz | `DEFERRED` |
| OBS-E-18 | Sin usuario técnico de Zammad (F0-03) | `BLOQUEO_EXTERNO` | Cliente implementado; no probado | `BLOCKED` |
| OBS-E-19 | Sin prueba real de entrega SMTP (F0-06) | `BLOQUEO_EXTERNO` | `success` se reporta como «aceptación», no entrega | `BLOCKED` |
| OBS-E-20 | Sin validación visual del usuario | `REQUIERE_APROBACION_FUNCIONAL` | Frontend implementado; `QA-FE-05/06 NOT_RUN` | `NOT_RUN` |
| OBS-E-21 | Ejecución de las suites completas | `RESUELTO_POR_EVIDENCIA_TECNICA` | Backend 688/688 y frontend 29/29 en verde | Cerrada |
| OBS-E-22 | `error.middleware.ts` no respetaba `httpStatus` de dominio | `RESUELTO_POR_EVIDENCIA_TECNICA` | Se añadió lectura opcional de `httpStatus` sin alterar las demás clases de error | Cerrada |
| OBS-E-23 | Legado `domain/sla/` con `SLAPolicy` | `RESUELTO_POR_EVIDENCIA_TECNICA` | Coexistencia aislada; el motor nuevo no lo importa | Cerrada |
| OBS-E-24 | Fecha de commit del catálogo vs rama actual | `RESUELTO_POR_EVIDENCIA_TECNICA` | Hash del snapshot idéntico; prueba en verde | Cerrada |

**Sin hallazgos clasificados como `REQUIERE_APROBACION_FUNCIONAL` resueltos por este trabajo.** Las firmas no se simularon.
