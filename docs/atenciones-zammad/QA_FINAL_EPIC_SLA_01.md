# MATRIZ QA FINAL — EPIC-SLA-01

**Fecha:** 17/11/2026
**Estados permitidos:** `NOT_RUN`, `PASSED`, `FAILED`, `BLOCKED`, `DEFERRED`.
**Regla:** ningún `NOT_RUN`, `BLOCKED` o `DEFERRED` se convierte en `PASSED`. Las 31 pruebas del módulo se ejecutaron con `npx vitest run src/domain/sla`; además se ejecutaron las suites completas: backend 688/688 y frontend 29/29. Las pruebas sobre base, Zammad y navegador **no se ejecutaron**.

## 1. Pruebas unitarias ejecutadas

| ID | Descripción | Precondición | Resultado esperado | Resultado obtenido | Estado | Evidencia | Responsable |
|---|---|---|---|---|---|---|---|
| QA-U-01 | Catálogo: par válido y rechazo de desconocidos | JSON oficial | 65 pares, validación por par | 21/21 pruebas del motor en verde | `PASSED` | `engine.test.ts` | QA |
| QA-U-02 | `policy_key` normalizado sin tildes | Catálogo oficial | `20-MAIL-FACTURACION_ELECTRONICA-CAMBIO_DE_RAZON_SOCIAL` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-03 | Slugs duplicados no infieren categoría | 3 duplicados | El par decide | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-04 | Primera requiere público/agente/email/success | Artículos mixtos | Sin respuesta válida | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-05 | 86.399 s cumple; 86.400 s no | Fechas exactas | Asimetría verificada | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-06 | Fecha de respuesta = `delivery_status_date` | Artículo con marca | `fechaSource=delivery_status_date` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-07 | Artículo anterior al ticket se ignora | Fecha negativa | `pendiente` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-08 | Fallo 3 reintentos provisional; 4 definitivo | BR-29 | Clasificación correcta | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-09 | `pending close` no detiene | Estado pendiente | `motivo=PENDING_CLOSE` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-10 | `merged` excluido y divergencia | Estado merged | `outcome=excluded` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-11 | `met` dentro y `missed` fuera de plazo | Cierre con marca | Resultado correcto | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-12 | Reapertura: `closed→pending close` sí; `closed→merged` no | BR-36 | Regla aplicada | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-13 | Alternativa A: 2 ciclos con vencimiento propio | 3 eventos | Ciclo 2 = apertura + 1.440 min | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-14 | Un ciclo abierto sin política no es verificable | Sin política | `cicloEsVerificable=false` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-15 | Deduplicación por sha256 de 64 hex | Evento repetido | Misma clave, una fila | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-16 | Alertas 75/90/100 (18/21,6/24 h) | Plazo 1.440 | Tres umbrales | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-17 | Objetivo ≥ 80 % inclusivo | 4/5 y 3/5 | `true` / `false` | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-18 | Totales 27/3/28/7 y escalones 15..7.200 | Matriz generada | Coinciden | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-19 | Resolución de política por par con tildes oficiales | 4 clases | Clase y minutos correctos | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-20 | `missed_at_birth` sin mover inicio ni vencimiento | Clasificación tardía | Regla BR-44 | Confirmado | `PASSED` | `engine.test.ts` | QA |
| QA-U-21 | Clasificación congela compromiso y crea ciclo 1 | Servicio con falso | Snapshot inmutable | 10/10 pruebas de servicio en verde | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-22 | Fallback rechazado sin D-02 | Servicio | `FALLBACK_SIN_RATIFICACION` | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-23 | Fallback ratificado usa 2.160 min provisional | Bandera explícita | `99-FALLBACK` | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-24 | DEC-05 no crea compromiso | 7 excluidas | `EXCLUIDO_NO_SERVICIO` | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-25 | Reclasificación no toca snapshot | Compromiso asignado | Count+auditoría, snapshot intacto | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-26 | Divergencia de espejo | Espejo distinto | `catalog_mirror_mismatch` | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-27 | Evento repetido sin efectos | Mismo evento | `duplicado=true` | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-28 | Primera respuesta fija marca y emite 3 alertas | Artículo válido | Confirmado | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-29 | Canal WhatsApp rechazado | Ticket no email | `ErrorSLA` | Confirmado | `PASSED` | `sla.service.test.ts` | QA |
| QA-U-30 | Catálogo exportado cumple hashes y totales | Prueba existente | 5/5 en verde en etapa anterior | Reverificado en etapa anterior | `PASSED` | `sla-catalogo.test.ts` | QA |
| QA-U-31 | TypeScript backend sin errores | `tsc --noEmit` | 0 errores | 0 errores | `PASSED` | consola | QA |
| QA-U-32 | Suite completa del backend | `npm test` | Sin regresiones | 46 archivos, 688 pruebas en verde | `PASSED` | consola | QA |
| QA-U-33 | Suite completa del frontend | `npm test` | Sin regresiones | 5 archivos, 29 pruebas en verde | `PASSED` | consola | QA |
| QA-U-34 | TypeScript frontend sin errores | `tsc -b` | 0 errores | 0 errores | `PASSED` | consola | QA |

## 2. Pruebas de base de datos — NO EJECUTADAS

| ID | Descripción | Motivo | Estado |
|---|---|---|---|
| QA-DB-01 | Creación de `restaurant_bi_test` y roles | BLK-05 | `BLOCKED` |
| QA-DB-02 | Verificación de roles sin CREATEDB/CREATEROLE | BLK-05 | `BLOCKED` |
| QA-DB-03 | Aplicación de `001` | BLK-05 + BLK-06 + D-08 | `BLOCKED` |
| QA-DB-04 | `001_verificacion_diseno_sla.sql`: 9/100/4/24 | Sin base | `BLOCKED` |
| QA-DB-05 | Rollback y reaplicación | BLK-09 | `BLOCKED` |
| QA-DB-06 | Guarda de entorno del DDL y del repositorio | Sin base | `BLOCKED` |
| QA-DB-07 | `sla_audit` append-only por privilegios | Sin roles | `BLOCKED` |
| QA-DB-08 | Carga de 27/3/7 políticas | AP-01 y D-02 | `BLOCKED` |

## 3. Pruebas de API — NO EJECUTADAS contra servidor

| ID | Descripción | Motivo | Estado |
|---|---|---|---|
| QA-API-01 | 16 endpoints con sesión autenticada | Sin servidor ni base | `NOT_RUN` |
| QA-API-02 | Autorización de `/sincronizar` y `/alertas/generar` | Sin servidor | `NOT_RUN` |
| QA-API-03 | Validación Zod (400) en los 8 esquemas | Sin servidor | `NOT_RUN` |
| QA-API-04 | Idempotencia HTTP de eventos repetidos | Sin servidor | `NOT_RUN` |
| QA-API-05 | Códigos 401/403/404/409/422 | Sin servidor | `NOT_RUN` |
| QA-API-06 | Paginación y límites | Sin servidor | `NOT_RUN` |

## 4. Pruebas frontend — NO EJECUTADAS en navegador

| ID | Descripción | Motivo | Estado |
|---|---|---|---|
| QA-FE-01 | Render de bandeja, panel y administración | Sin servidor | `NOT_RUN` |
| QA-FE-02 | Selector dependiente categoría/subcategoría | Sin servidor | `NOT_RUN` |
| QA-FE-03 | Reclasificación con motivo obligatorio | Sin servidor | `NOT_RUN` |
| QA-FE-04 | Detalle: compromiso, ciclos, auditoría | Sin servidor | `NOT_RUN` |
| QA-FE-05 | Navegación desde el sidebar | Sin validación visual del usuario | `NOT_RUN` |
| QA-FE-06 | Responsive y accesibilidad básica | Sin validación visual del usuario | `NOT_RUN` |

## 5. Pruebas integrales con Zammad — NO EJECUTADAS

20 escenarios definidos en `GUIA_PRUEBAS_SLA.md`. Estado: `BLOCKED` por base de pruebas, usuario técnico de lectura (F0-03), prueba de entrega (F0-06) y ventana (BLK-09).

| ID | Escenario | Estado |
|---|---|---|
| QA-E2E-01..20 | Recepción → clasificación → vencimiento → respuesta → cierre → reapertura → merged → divergencia → sincronización → indicadores | `BLOCKED` |

## 6. Observaciones abiertas de QA

| ID | Observación | Severidad | Estado |
|---|---|---|---|
| QA-OBS-01 | No existe base de pruebas ni cliente PostgreSQL en la estación | Crítica | `BLOCKED` |
| QA-OBS-02 | AP-01/02/03 condicionales y D-01/D-02 sin firma | Alta | `DEFERRED` |
| QA-OBS-03 | Sin usuario técnico de Zammad; no se puede probar la integración | Alta | `BLOCKED` |
| QA-OBS-04 | Sin validación visual del usuario, requisito de cierre de épica en `AGENTS.md` | Alta | `NOT_RUN` |
| QA-OBS-05 | Se ejecutaron las suites completas: backend 688/688 y frontend 29/29 | Media | `PASSED` |

**Veredito QA:** la épica **no** puede declararse completada. Estado: `BLOQUEADO_POR_DEPENDENCIA`.
