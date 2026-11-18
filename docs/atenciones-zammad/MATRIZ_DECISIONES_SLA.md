# MATRIZ DE DECISIONES — EPIC-SLA-01

**Fecha:** 17/11/2026 · **Etapa:** 1 · **Estado:** consolidada.
**Regla:** «recomendado» no es «aprobado». Las firmas no se simulan.
**Fuentes:** `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md`, EPIC §1.4/§5/§16.1, 5G.4.5, `TABLERO_EJECUCION_ETAPA_1_SLA.md`.

| ID | Decisión | Fuente contractual | Evidencia | Alternativas | Recomendación | Impacto funcional | Impacto técnico | Impacto BD | Responsable | Estado | Dependencias |
|---|---|---|---|---|---|---|---|---|---|---|---|
| D-01 | Ciclos 2..N: alternativa A | BR-36..BR-40; `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2 L132; `RESUMEN_EJECUTIVO_5G4_5.md` §3.1 | A declarada aprobada en 5G.4.5; registro 5G.4.4 obsoleto | A: ciclo con plazo · B: ciclo sin plazo (no representable) | **A** | Reaperturas medibles; alertas por ciclo | Sin cambios | Ninguno | Responsable funcional | `REQUIERE_APROBACION_FUNCIONAL` · recomendada | Ninguna para el DDL |
| D-02 | Ratificar 28 subcategorías con respaldo 36 h | BR-43; `MATRIZ_POLITICAS_CATALOGO_SLA.md` §1 | 28 filas en 9 categorías; 1.016 tickets fuera de matriz | RATIFICO / EXCLUIR (enmienda DEC-05) / PROMOVER (n≥10) | Ratificar | Gobierna el 32,51 % del volumen | Carga de 28 políticas `99-FALLBACK` | Ninguno | Soporte + dueño catálogo | `REQUIERE_APROBACION_FUNCIONAL` · preparada | D-11 |
| D-03 | `policy_class` en política y compromiso | BR-41/42 vs BR-65; EPIC §5.6 | 5G.4.5 no la contempla; sin ella 3 y 7 se confunden | Mantener / eliminar | Mantener | Separa «sin evidencia» de «no servicio» | 4 CHECK adicionales | Columna en 2 tablas | Responsable técnico | `REQUIERE_APROBACION_TECNICA` · propuesta en DDL | Ninguna |
| D-04 | Sexto estado `excluded_non_service` | DEC-05; BR-65; EPIC §1.4.1 L85 | 5G.4.5 §4.2 L165 lista 5 | Mantener / usar `no_policy` | Mantener | DEC-05 representable sin falsear canal | 1 valor en CHECK | Ninguno | Responsable técnico + visto funcional | `REQUIERE_APROBACION_TECNICA` | Ninguna |
| D-05 | `threshold_pct = 100` | BR-54; 5G.4.5 §8 L445-455 | 5G.4.5 §4.6 L273 solo 75/90 → contradictoria | Mantener 100 / solo 75-90 | Mantener | Alerta de vencimiento | 1 valor en CHECK | Ninguno | Responsable técnico | `REQUIERE_APROBACION_TECNICA` | Ninguna |
| D-06 | `catalog_mirror_mismatch` | BR-66; DT-01b; EPIC L385 | 5G.4.5 §4.8 L306 lista 9 tipos, ninguno aplica | Añadir / reutilizar `policy_mismatch` | Añadir | Divergencia de espejo diagnosticable | 1 valor en CHECK | Ninguno | Responsable técnico | `REQUIERE_APROBACION_TECNICA` | Ninguna |
| D-07 | Clasificación vigente (OBS-33) | BR-13/BR-14; ESPEC §6.1 | Retención eventos 2 años vs compromiso permanente | A columnas · B tabla · C derivar | **B** | Consulta y auditoría de clasificación actual | +1 tabla, +1 FK, +2 índices, +3 CHECK | 10→11 tablas | Responsable técnico | `REQUIERE_APROBACION_TECNICA` · recomendada | Ninguna para el DDL de 9 tablas |
| D-08 | Registro de migraciones | `PLAN_DESBLOQUEO` §5.4; `PAQUETE` §7 | 24+11 SQL planos, sin tabla de control, sin Prisma Migrate | Tabla propia / registro externo / mecanismo existente (no existe) | **Tabla propia** | No aplicable | Guarda de doble aplicación | 9→10 tablas, +4 CHECK | Responsable técnico + DBA | `REQUIERE_APROBACION_TECNICA` | **Cambia `001` antes de aplicar** |
| D-09 | Base `restaurant_bi_test` + 2 roles | PLAN §4.2; PAQUETE §10 | Sin `psql`/Docker; `pgvector_user` sin CREATEDB | DBA crea / elevar privilegios (prohibido) | Solicitar al DBA | Ninguna hasta migrar | Habilita M1-M8 | Base y roles | DBA | `REQUIERE_DBA` · BLK-05 | Ninguna |
| D-10 | Procedimiento M1–M8 | PLAN §5.2; PAQUETE §11 | Diseñado, no ejecutado | Aprobar / seguir sin procedimiento | Aprobar | Ninguna hasta migrar | Aplicación controlada | Ninguno | Responsable técnico | `REQUIERE_APROBACION_TECNICA` · BLK-06 | D-09 |
| D-11 | Dueño del catálogo | EPIC §1.4.1 L84; TABLERO §2.1 L168 = **confirmada Soporte**; PAQUETE D-11 = abierta | **Contradicción documental**: prevalece EPIC/TABLERO por posteriores | Confirmar / dejar abierta | Registrar confirmación y corregir el paquete | Define quién ratifica | Ninguno | Ninguno | Responsable del proyecto | `RESUELTO_POR_CONTRATO` con inconsistencia de seguimiento | Corrección documental autorizada |
| D-12 | Canales de alerta `internal`, `email` | BR-54; 5G.4.5 §2.1 L49 prohíbe webhooks | DDL anterior tenía `webhook`, se eliminó | 2 canales / solo internal | Mantener 2 | Notificación interna y correo | CHECK existente | Ninguno | Responsable técnico | `REQUIERE_APROBACION_TECNICA` | Ninguna |
| D-13 | Etiqueta Épica 1 en `AGENTS.md` | `AGENTS.md` §EPICA ACTIVA | Ya contiene EPIC-SLA-01 | Documentar / no documentar | Documentar | Ninguna | Ninguno | Ninguno | Responsable del proyecto | `RESUELTO_POR_EVIDENCIA_TECNICA` | Ninguna |
| D-14 | Rotular legado `domain/sla/` | OBS-27 | Coexistencia aislada decidida; sin borrar ni mover | Rotular / borrar (prohibido) | Rotular como legado | Evita dos modelos SLA | Sin importar `SLAPolicy`/`CalculoSLA` | Ninguno | Responsable técnico | Decidida, cambio de archivos no autorizado | Autorización de cambio |

## Contradicciones tratadas

| # | Contradicción | Precedencia aplicada |
|---:|---|---|
| 1 | `<` vs `≤` en primera respuesta | `< 86.400 s` estricto (DP-E-04 cerrada, BR-23), aunque resolución use `≤` |
| 2 | REA-02 pendiente vs cerrada | 5G.4.5 gana; queda pendiente solo la firma (D-01) |
| 3 | 5 vs 6 estados de compromiso | DDL propone 6 sin confirmar (D-04) |
| 4 | `policy_class` ausente en especificación | Propuesta D-03, no regla |
| 5 | Umbrales 75/90 vs alerta de vencimiento | §8 + BR-54 ganan; D-05 sin confirmar |
| 6 | `source` con webhook | 5G.4.5 L108/L49 gana; discrepancia descartada |
| 7 | Divergencia de espejo sin tipo | Propuesta D-06, no regla |
| 8 | DP-04 abierta vs confirmada | EPIC/TABLERO (posteriores) ganan; el paquete requiere corrección |
| 9 | BR-68/69/70 | `SIN_EVIDENCIA`: no existen; no se inventan |
