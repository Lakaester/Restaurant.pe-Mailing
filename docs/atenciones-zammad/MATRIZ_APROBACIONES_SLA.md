# MATRIZ DE APROBACIONES — EPIC-SLA-01

**Fecha:** 17/11/2026 · **Estado de la épica:** `BLOQUEADO_POR_DEPENDENCIA`.
**Principio:** una propuesta documentada no es una aprobación. No hay firmas nuevas en este documento.

## 1. Aprobaciones reales constatadas

| Elemento | Fuente | Fecha | Alcance exacto |
|---|---|---|---|
| DEC-05 — 7 exclusiones no servicio | EPIC §1.4.1 L85; BR-65 | 16/11/2026 | Excluidas de SLA, respaldo y denominadores. **No** autoriza excluir otras 28 filas |
| DT-01 / DT-01b — BFF fuente de verdad; espejo opcional | EPIC §1.4.1 L81-82, L385 | 16/11/2026 | Prevalece BFF; divergencia si difiere |
| DT-02 — selector de 65 con marca de política | EPIC §1.4.1 L86; BR-67 | 16/11/2026 | 27/3/28 marcadas; 7 no ofrecidas |
| DP-04 — dueño del catálogo: Soporte | EPIC §1.4.1 L84; TABLERO §2.1 L168 | 16/11/2026 | Designación de responsable. **No** equivale a la ratificación fila por fila de las 28 |
| DP-E-01..DP-E-12, REA-02..REA-06 | ESPEC §17; RESUMEN §3.1 | 16/11/2026 | Cerradas en diseño. D-01 requiere además firma que actualice el registro 5G.4.4 |
| Matriz oficial 30/30; 1.016/32,51 % fuera de matriz | F0-10 / F0-11 | 16/11/2026 | Evidencia medible; AP-01 sigue condicional |
| Catálogo exportado (13/65/62/3) + 5 pruebas en verde | `catalogo-oficial.meta.json`; `sla-catalogo.test.ts` | 17/11/2026 | Verificado en esta sesión con 21 pruebas del motor |

## 2. Aprobaciones condicionales (NO definitivas)

| ID | Estado literal | Consecuencia |
|---|---|---|
| AP-01 | `conditional_pending_final_validation` | La matriz es oficial para implementación; no se declara aprobada |
| AP-02 | `conditional_pending_final_validation` | Ídem |
| AP-03 | `conditional_pending_final_validation` | Ídem |
| AP-04 | Pendiente | Piloto |
| AP-05 | Pendiente | Reportes |

## 3. Propuestas SIN aprobación

| ID | Propuesta | Responsable | Consecuencia de aprobar | Estado |
|---|---|---|---|---|
| D-01 | Alternativa A para ciclos | Responsable funcional | Ningún cambio de DDL; desbloquea reaperturas | Sin firma |
| D-02 | 28 respaldos | Soporte + dueño catálogo | Habilita la carga de `99-FALLBACK` | Sin firma |
| D-03 | `policy_class` | Responsable técnico | Columna en 2 tablas | Sin confirmar |
| D-04 | `excluded_non_service` | Responsable técnico | Valor adicional en CHECK | Sin confirmar |
| D-05 | `threshold_pct=100` | Responsable técnico | Valor adicional en CHECK | Sin confirmar |
| D-06 | `catalog_mirror_mismatch` | Responsable técnico | Valor adicional en CHECK | Sin confirmar |
| D-07 | Tabla `sla_classification` | Responsable técnico | +1 tabla, +1 FK, +3 CHECK, +2 índices | Sin aprobar; borrador no aplicado |
| D-08 | Tabla `sla_schema_migration` | Responsable técnico + DBA | +1 tabla, +4 CHECK; cambia `001` | Sin aprobar; borrador no aplicado |
| D-10 | M1–M8 | Responsable técnico | Habilita aplicación controlada | Sin aprobar |
| D-12 | Canales `internal`/`email` | Responsable técnico | CHECK existente | Sin confirmar |

**Regla de ejecución aplicada en el motor implementado:** D-02 no se da por aprobada. El servicio `SlaService` rechaza clasificar cualquier fallback con `FALLBACK_SIN_RATIFICACION`, salvo que exista una bandera explícita `SLA_FALLBACK_RATIFICADO=true` fijada por la aprobación. Ninguna política de respaldo se cargó en base.

## 4. Requisitos externos no disponibles

| ID | Requisito | Responsable | Estado |
|---|---|---|---|
| BLK-05 | Base `restaurant_bi_test` y roles | DBA | Sin crear; sin cliente PostgreSQL en la estación |
| BLK-06 | M1–M8 aprobados | Responsable técnico | Diseñados, sin firma |
| BLK-09 | Ventana exclusiva | Operador de la sesión concurrente | Sin conceder |
| F0-03 | Usuario técnico de Zammad con `groups_users.access='read'` | Administrador de Zammad | Sin crear; no se creó |
| F0-06 | Prueba real de confirmación de entrega | Responsable funcional | Sin ejecutar |

## 5. Firmas

| Rol | Nombre | Fecha | Firma | Alcance |
|---|---|---|---|---|
| Responsable funcional | | | | D-01 |
| Soporte / dueño del catálogo | | | | D-02 (28 filas) |
| Responsable técnico | | | | D-03..D-08, D-10, D-12 |
| DBA | | | | D-08, D-09, M1–M8 |

**Ninguna celda firmada. Este documento no autoriza migración ni carga de políticas.**
