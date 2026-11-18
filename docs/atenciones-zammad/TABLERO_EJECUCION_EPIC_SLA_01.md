# TABLERO DE EJECUCIÓN — EPIC-SLA-01

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Fecha de apertura:** 17/11/2026
**Naturaleza:** documento maestro de ejecución. Registra hechos verificables. **No declara pruebas ejecutadas que no lo estén.**
**Estado global:** `BLOQUEADO_POR_DEPENDENCIA` — Etapas 2 y 6 dependen de base de pruebas, roles y ventana autorizada.

---

## 0. Regla de avance

El porcentaje de avance se calcula sobre actividades verificables, no por estimación:

```
avance = (actividades con evidencia ejecutadas) / (actividades planificadas) * 100
```

Un artefacto escrito cuenta como actividad ejecutada solo si existe en disco y su contenido es verificable. Una prueba cuenta solo si se ejecutó y se conservó su salida.

---

## 1. Inspección inicial (17/11/2026)

| # | Verificación | Resultado | Evidencia |
|---:|---|---|---|
| 1 | Repositorio correcto | `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi` | `Get-Item` |
| 2 | Rama | `remediation/audit` | `git rev-parse --abbrev-ref HEAD` |
| 3 | HEAD | `27b973a53a96761e54b108a36f09b4c60eb99625` | `git rev-parse HEAD` |
| 4 | Remoto | `Lakaester/CentrodeAtenci-n` | `git remote -v` |
| 5 | Git status | 62 entradas: 58 `docs/captures/` + `M AGENTS.md` + 3 rutas nuevas (`backend/scripts/sla/`, `backend/src/__tests__/sla-catalogo.test.ts`, `backend/src/domain/sla/catalogo/`) | `git status --porcelain` |
| 6 | Docs SLA | 73 archivos en `docs/atenciones-zammad/` | listado recursivo |
| 7 | Backend | Express 4 + TypeScript estricto + Prisma 5.22 + Zod 3 + Vitest 4; SQL crudo con `Prisma.sql` sobre singleton `repositories/prisma.ts` | `backend/package.json`, `tsconfig.json` |
| 8 | Convención de rutas | `src/routes/index.ts` monta routers con `requireAuth` y `requirePermission(módulo, acción)` | `routes/index.ts` |
| 9 | Convención de errores | `DomainError`, `ApplicationError`, `InfrastructureError` + `toErrorResponse` en `core/errors/types.ts` | `middlewares/error.middleware.ts` |
| 10 | Catálogo | 13 / 65 / 62 / 3; JSON y snapshot con hashes documentados; prueba `sla-catalogo.test.ts` | `domain/sla/catalogo/` |
| 11 | Módulo SLA actual | Solo `types.ts` (modelo genérico legado `SLAPolicy`/`CalculoSLA`), `index.ts`, `README.md` y catálogo | listado `domain/sla/` |
| 12 | Frontend | React 18 + Vite + Tailwind + React Query + axios; página `pages/Sla.tsx` existe pero **no está montada en el router** | `router/index.tsx` |
| 13 | Node/npm | Node v24.18.0 / npm 11.16.0; `node_modules` presentes en backend y frontend | `node --version`, `npm --version` |
| 14 | PostgreSQL | **Sin cliente `psql` ni Docker en la estación.** No se abre `backend/.env`. No se conecta a ninguna base | `Get-Command` |
| 15 | Memoria | 611 MB libres de 6.030 MB; 7 procesos node activos → **prohibido paralelismo intensivo** | `Win32_OperatingSystem` |
| 16 | DDL | 3 archivos SQL sin cambios: 9 tablas, 100 CHECK, 4 FK, 24 índices | verificador estructural |

---

## 2. Estado de las siete etapas

| Etapa | Nombre | Estado | Bloqueo | Avance |
|---:|---|---|---|---:|
| 1 | Cierre funcional y técnico de decisiones | EJECUTADA (documental) | Firmas humanas no disponibles | 6/6 actividades |
| 2 | Base de datos y migración | `BLOQUEADO_POR_DEPENDENCIA` | BLK-05, BLK-06, BLK-09, sin `psql`/Docker | 0 % |
| 3 | Implementación del motor SLA | EJECUTADA | Ninguno para lógica pura | 3/3 actividades |
| 4 | API SLA estable | EJECUTADA | Sin servidor para pruebas HTTP | 1/1 actividad |
| 5 | Frontend C.O.S.E. | EJECUTADA | Sin validación visual del usuario | 1/1 actividad |
| 6 | Integración Zammad y pruebas integrales | `BLOQUEADO_POR_DEPENDENCIA` | Sin base, sin usuario de lectura, sin ventana | Cliente implementado; 0/20 escenarios ejecutados |
| 7 | QA y entrega | EJECUTADA (documental) | Depende de 2 y 6 para cierre | 1/1 actividad |

**Avance global por criterios de etapa:** 5 de 7 etapas ejecutadas en su parte posible; 2 bloqueadas. La épica global sigue `BLOQUEADO_POR_DEPENDENCIA`.

---

## 3. Bloqueos vigentes

| ID | Bloqueo | Tipo | Qué habilita | Estado |
|---|---|---|---|---|
| BLK-05 | Base `restaurant_bi_test` y roles `cope_test_migration` / `cope_test_runtime` | `REQUIERE_DBA` | Etapa 2 | Sin crear. `pgvector_user` no tiene `CREATEDB`/`CREATEROLE` y no se eleva |
| BLK-06 | Procedimiento M1–M8 aprobado | `REQUIERE_APROBACION_TECNICA` | Etapa 2 | Diseñado, sin firma |
| BLK-09 | Ventana exclusiva de pruebas | `BLOQUEO_EXTERNO` | Etapa 2 rollback y Etapa 6 | No concedida |
| BLK-10 | Cliente PostgreSQL en la estación | `BLOQUEO_EXTERNO` | Verificación real | No instalado; no se instala sin autorización |
| AP-01..03 | AP-01/02/03 condicionales | `REQUIERE_APROBACION_FUNCIONAL` | Carga de matriz | `conditional_pending_final_validation` |
| DP-04 | Dueño designado del catálogo | `REQUIERE_APROBACION_FUNCIONAL` | Ratificación de 28 filas | Sin designar |

---

## 4. Actividades habilitadas sin base de datos

| ID | Actividad | Etapa | Estado | Evidencia |
|---|---|---:|---|---|
| A-01 | Inspección inicial y registro de estado Git | 1 | EJECUTADA | §1 de este documento |
| A-02 | Digest de contratos SLA vigentes | 1 | EJECUTADA | Materia de `MATRIZ_DECISIONES_SLA.md` y reglas del motor |
| A-03 | Matriz de decisiones D-01..D-14 | 1 | EJECUTADA | `MATRIZ_DECISIONES_SLA.md` |
| A-04 | Matriz de aprobaciones reales vs propuestas | 1 | EJECUTADA | `MATRIZ_APROBACIONES_SLA.md` |
| A-05 | Plan de migración y verificación previa | 1 | EJECUTADA | `PLAN_MIGRACION_SLA.md` |
| A-06 | Acta de cierre de decisiones | 1 | EJECUTADA | `ACTA_CIERRE_DECISIONES_SLA.md` |
| A-07 | Motor SLA: lógica pura y pruebas unitarias | 3 | EJECUTADA | 21 pruebas en `engine/__tests__/engine.test.ts` |
| A-08 | Repositorio SQL parametrizado (no ejecutado) | 3 | EJECUTADA | `infrastructure/sla.repository.ts`; guarda de entorno |
| A-09 | Servicios de aplicación con repositorio falso en pruebas | 3 | EJECUTADA | 10 pruebas en `application/__tests__/sla.service.test.ts` |
| A-10 | API SLA: DTO, controlador, rutas | 4 | EJECUTADA | `api/` + 1 línea en `routes/index.ts`; sin pruebas HTTP |
| A-11 | Frontend SLA integrado | 5 | EJECUTADA | `modules/sla/`, `pages/sla/`, router y sidebar |
| A-12 | Cliente Zammad de solo lectura + sincronización | 6 | EJECUTADA (código) | `zammad.client.ts`; 0 escenarios E2E ejecutados |
| A-13 | QA y documentación final | 7 | EJECUTADA | 8 documentos finales; estados honestos |

---

## 5. Registro de ejecución

| Fecha | Acción | Resultado |
|---|---|---|
| 17/11/2026 | Apertura del tablero e inspección inicial | Repositorio, rama, HEAD y estado Git confirmados. Sin base ni cliente PostgreSQL. Sin cambios en SQL, Zammad ni capturas |
| 17/11/2026 | Etapa 1 | 4 documentos creados; 14 decisiones trazadas; 0 firmas inventadas |
| 17/11/2026 | Etapa 3 | Motor, repositorio y servicios implementados. `npx vitest run src/domain/sla`: 31/31. Suite backend completa: 688/688. `tsc --noEmit`: 0 errores |
| 17/11/2026 | Etapa 4 | API montada en `/api/sla` con autenticación de sesión. Pruebas HTTP: `NOT_RUN` |
| 17/11/2026 | Etapa 5 | Página `/sla` y módulo frontend conectados a la API. `tsc -b`: 0 errores; suite frontend 29/29. Validación visual: `NOT_RUN` |
| 17/11/2026 | Etapas 6 y 7 | Cliente Zammad implementado; 20 escenarios documentados; ninguno ejecutado por falta de base, usuario y ventana |

---

## 6. Próxima actividad ejecutable

La siguiente actividad **ejecutable** es la aprobación formal de D-03..D-08 y D-10 por el responsable técnico, seguida de la creación de la base por el DBA. No puede ejecutarse ninguna prueba de base, API contra servidor, navegador ni integración hasta que se resuelvan BLK-05, BLK-06 y BLK-09.

**Estado Git al cierre:** rama `remediation/audit`, HEAD `27b973a`, 72 entradas sin confirmar (58 `docs/captures/` intactas, 5 archivos modificados, 9 rutas nuevas). 0 commits, 0 pushes. Los 3 archivos SQL siguen byte-idénticos.
