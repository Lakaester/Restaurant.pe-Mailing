# ACTA DE CIERRE DE DECISIONES — EPIC-SLA-01

**Fecha:** 17/11/2026
**Etapa:** 1 — cierre funcional y técnico de decisiones
**Modo:** revisión documental y verificación de código. **No se ejecutó SQL ni se conectó a PostgreSQL.**
**Resultado:** decisiones trazadas; **aprobaciones humanas pendientes**; bloqueos externos vigentes.

## 1. Objeto

Dejar cada decisión necesaria para implementar y migrar con: identificador, fuente, evidencia, alternativas, recomendación, impactos, responsable, estado y dependencias. El detalle está en `MATRIZ_DECISIONES_SLA.md`; el registro de firmas reales, en `MATRIZ_APROBACIONES_SLA.md`.

## 2. Decisiones cerradas por evidencia

| # | Decisión | Evidencia |
|---:|---|---|
| 1 | Precedencia normativa: EPIC §16.1; reglas definitivas 5G.4.5 por encima de 5G.4.4 | EPIC §16.1 L2221-2234 |
| 2 | Primera respuesta es `< 86.400 s` estricto | BR-23; DP-E-04 cerrada; reglas definitivas §1 L27-30. 24 h exactas = incumplida |
| 3 | Fecha de respuesta = `delivery_status_date`, fallback `updated_at`; prohibidos `created_at` del artículo y `first_response_at` | Reglas definitivas §3.2/§3.3 |
| 4 | `pending close` no detiene; `merged` no cierra y genera divergencia; cierre válido = primer estado `closed` | BR-20/32/34; ciclos §3/§6/§10 |
| 5 | Reapertura = transición desde `closed` a no `closed`/`merged`; ciclo N+1 con plazo de la política congelada; compromiso único | BR-36..BR-40; ciclos §4.2 |
| 6 | Clasificación tardía: `started_at = created_at`, `missed_at_birth`, indicador secundario | BR-44; ciclos §9 |
| 7 | Matriz: 27 con SLA (2.087), 3 sin evidencia (22), 28 respaldo, 7 excluidas | F0-10; `MATRIZ_POLITICAS_CATALOGO_SLA.md` |
| 8 | `policy_key = 20-MAIL-<CAT>-<SUB>` normalizado o `99-FALLBACK`; identidad por par, nunca por slug | EPIC §6.8; catálogo README |
| 9 | Frontera Prisma: `schema.prisma` solo `GenerateAnchor`; prohibidos `db pull`, `db push`, `migrate`, `db execute` | PAQUETE §8 |
| 10 | `source` de evento = `poll \| reconcile \| manual`; no `webhook` | 5G.4.5 L108 y L49. OBS-31 #4 descartada |
| 11 | DP-04: Soporte es dueño del catálogo (EPIC/TABLERO). El paquete la marca abierta: inconsistencia de seguimiento, no decisión abierta real | EPIC §1.4.1 L84 vs PAQUETE D-11 |
| 12 | BR-68, BR-69, BR-70: `SIN_EVIDENCIA`. No se inventan reglas | Búsqueda global en toda la documentación |

## 3. Decisiones que requieren firma

D-01, D-02, D-03, D-04, D-05, D-06, D-07, D-08, D-10, D-12. Ninguna se declara aprobada. D-08 y D-10 son condiciones de aplicación; D-07 depende de la interfaz de clasificación.

## 4. Ajuste operativo aplicado al código

El motor implementado respeta la distinción aprobado/propuesto:

- `SlaService.clasificar` rechaza fallbacks salvo bandera explícita de ratificación (D-02).
- Las subcategorías `excluded_non_service` no generan compromiso (DEC-05).
- Las 3 sin evidencia no reciben SLA ni respaldo y se marcan `no_policy`.
- La clasificación vigente se consulta desde `sla_audit` (retención 5 años) sin crear `sla_classification` (D-07 no aprobada).
- El repositorio exige `current_database() = restaurant_bi_test` y rechaza roles de producción antes de cualquier escritura.
- Ninguna sentencia DDL ni carga de políticas se ejecutó.

## 5. Bloqueos que permanecen

| Bloqueo | Estado |
|---|---|
| BLK-05 base y roles | Sin crear. Sin `psql` ni Docker; no se eleva `pgvector_user` |
| BLK-06 M1–M8 | Diseñados, sin aprobación |
| BLK-09 ventana de pruebas | Sin conceder |
| F0-03 usuario técnico de Zammad | Sin crear |
| F0-06 prueba real de entrega | Sin ejecutar |
| AP-01/02/03 | Condicionales |

## 6. Cierre de la etapa

La Etapa 1 queda **ejecutada en su parte documental y técnica**: no queda decisión sin analizar, las contradicciones están explicadas y las aprobaciones reales están separadas de las propuestas. La etapa **no** puede declararse `COMPLETADA` mientras falten las firmas de D-01..D-08/D-10/D-12; su estado es `BLOQUEADO_POR_DEPENDENCIA`.

## 7. Firmas

| Rol | Nombre | Fecha | Firma |
|---|---|---|---|
| Responsable funcional | | | |
| Responsable técnico | | | |
| DBA | | | |
