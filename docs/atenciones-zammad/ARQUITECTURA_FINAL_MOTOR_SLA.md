# ARQUITECTURA FINAL DEL MOTOR SLA — EPIC-SLA-01

**Fecha:** 17/11/2026 · **Estado:** implementada en código, **no ejecutada contra base**.

## 1. Principios

1. Arquitectura real del repositorio: Express 4 + TypeScript estricto + Prisma 5 con SQL crudo (`Prisma.sql`, `$queryRaw`, `$executeRaw`), Zod y Vitest.
2. Prisma **no posee** el esquema SLA. `schema.prisma` solo tiene `GenerateAnchor`; no se hizo introspección ni migración.
3. El BFF es fuente de verdad de clasificación y compromiso; Zammad es fuente de hechos por REST de solo lectura.
4. Compromiso inmutable; clasificación vigente consultada desde `sla_audit` (5 años) mientras D-07 no se apruebe.
5. Ninguna regla de negocio duplicada en el frontend.

## 2. Capas (todas nuevas; el legado `domain/sla/*.ts` permanece intacto)

```
backend/src/domain/sla/
├── catalogo/                  catálogo oficial congelado (preexistente, sin cambios)
├── engine/                    DOMINIO PURO — sin BD, sin red
│   ├── types.ts               enumeraciones y estructuras del DDL de 9 tablas
│   ├── catalog.ts             validación del par, normalización de policy_key, espejo
│   ├── calculation.ts         primera respuesta, resolución, alertas, objetivo 80%
│   ├── cycles.ts              máquina de ciclos (alternativa A), missed_at_birth
│   ├── idempotency.ts         sha256 BR-61 y orden de eventos
│   ├── matriz-oficial.generated.ts  27/3/28/7 generada desde la matriz verificada
│   └── __tests__/             21 pruebas ejecutadas
├── infrastructure/
│   ├── sla.repository.ts      único lugar que toca las tablas sla_*; guarda de entorno
│   └── zammad.client.ts       solo GET: tickets, artículos, historial
├── application/
│   ├── sla.service.ts         orquestación, reglas de aprobación, sincronización
│   └── __tests__/            10 pruebas ejecutadas con repositorio falso
└── api/
    ├── dto.ts                 8 esquemas Zod
    ├── sla.controller.ts      respuestas {ok,data}, sin lógica de negocio
    └── sla.routes.ts          montado en /api/sla
```

## 3. Flujo completo

1. `POST /sla/tickets` o sincronización → compromiso `pending_classification`, sin vencimiento.
2. `POST /sla/clasificar` → valida par contra catálogo, resuelve política, congela snapshot, `started_at=created_at`, crea ciclo 1 con `due_at`, auditoría `assign`/`open_cycle`.
3. Si la política ya vencía al clasificar → ciclo 1 `missed_at_birth` + divergencia `late_classification`.
4. `POST /sla/eventos` → idempotencia sha256, reconstrucción de ciclos, cierre válido, `merged`, reapertura A, divergencias.
5. `POST /sla/articulos/evaluar` → `delivery_state`, primera respuesta con `delivery_status_date`/`updated_at_fallback`, 3 alertas, marca inmutable.
6. `POST /sla/alertas/generar` → 75/90/100 por ciclo.
7. `GET /sla/indicadores` → denominadores explícitos y meta ≥ 80 %.
8. `POST /sla/sincronizar` → solo GET a Zammad, solape 15 min, watermark solo si status `ok`.

## 4. Decisiones incorporadas al código

| Decisión | Cómo se respeta |
|---|---|
| BR-01 solo email | `registrarTicket` rechaza otro canal |
| BR-10/11 sin clasificación | compromiso `pending_classification`, sin vencimiento ni respaldo |
| BR-23 `< 86.400 s` | comparación en milisegundos con `<` |
| BR-26 fecha de respuesta | `delivery_status_date` → `updated_at_fallback`; nunca `created_at` ni `first_response_at` |
| BR-29 fallos | `clasificarEntrega` distingue provisional/definitivo por retry > 3 |
| BR-32/34 cierre | primer `closed`; `merged` = `excluded` + divergencia |
| BR-36..40 ciclos | alternativa A; compromiso único; política congelada |
| BR-44 clasificación tardía | `started_at = created_at`, `missed_at_birth` |
| BR-61 idempotencia | sha256('zammad'|tipo|ticket|entity|occurred_at), 64 hex |
| BR-62 watermark | solo avanza si el run termina `ok` |
| D-02 | fallback bloqueado salvo bandera de ratificación |
| D-07 | no se crea `sla_classification`; se usa `sla_audit` |
| D-08 | no se crea `sla_schema_migration` |
| OBS-27 | no se importa `SLAPolicy` ni `CalculoSLA` del legado |

## 5. Seguridad

- Cliente Zammad con allowlist GET, `redirect: 'error'`, HTTPS, sin cuerpos ni datos de contacto, sin `Authorization` en logs.
- Guarda de entorno en **toda escritura** del repositorio: exige `restaurant_bi_test` y rechaza `pgvector_user`/`postgres`.
- `sla_audit` append-only: permisos previstos en el plan, no otorgados aquí.
- Errores centralizados; `httpStatus` de dominio respetado por el middleware existente.

## 6. Fuera de esta implementación

Motor SLA nativo de Zammad, escrituras en Zammad, WhatsApp/WHATMETA/WHATICKET, clasificación automática, D-07/D-08 (sin aprobación), ejecución de SQL, creación de base/roles y despliegue productivo.
