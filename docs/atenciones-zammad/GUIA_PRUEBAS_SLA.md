# GUÍA DE PRUEBAS — EPIC-SLA-01

**Datos:** solo sintéticos en `restaurant_bi_test`. Sin correos reales, sin tickets productivos, sin barrera SMTP real.
**Ejecución:** ninguna de las pruebas de esta guía se ejecutó. Los resultados están en `QA_FINAL_EPIC_SLA_01.md`.

## 1. Precondiciones

1. BLK-05, BLK-06, BLK-09 resueltos.
2. `001` aplicada; `001_verificacion_diseno_sla.sql` devuelve 9/100/4/24.
3. Usuario técnico de Zammad con `groups_users.access='read'` en `Soporte Especializado` (F0-03).
4. Cliente HTTP con allowlist GET y URL fija de pruebas.
5. Flag `SLA_FALLBACK_RATIFICADO` solo si D-02 está firmada.

## 2. Escenarios integrales

| # | Escenario | Pasos | Resultado esperado |
|---:|---|---|---|
| 1 | Recepción | `POST /tickets` con ticket email | Compromiso `pending_classification` sin vencimiento |
| 2 | Registro en C.O.S.E. | Consultar `/compromisos/:ticketId` | Datos del snapshot Zammad, sin categoría inferida |
| 3 | Sin clasificación | Consultar bandeja | Estado `pending_classification`, sin 36 h |
| 4 | Clasificación manual | `POST /clasificar` con `Ajustes FE` | `policyKey` 20-MAIL-…, 1.440 min, inicio = `created_at` |
| 5 | Asignación de compromiso | Consultar detalle | Ciclo 1 con `due_at = started_at + 1.440 min` |
| 6 | Primera respuesta exitosa | Artículo `success` con `delivery_status_date` | `met` si < 86.400 s; 3 alertas |
| 7 | Primera respuesta fallida | `fail`, retry 4 | `fallido_definitivo`; no cuenta |
| 8 | Sin respuesta | Avanzar reloj sin artículo | `missed` al vencer; alerta 100 % |
| 9 | Próximo a vencer | Avanzar al 75 % y 90 % | Alertas en 18 h y 21,6 h |
| 10 | Vencido | Avanzar más de `due_at` | `missed` / `overdue_at_cutoff` según corte |
| 11 | Reclasificación | `POST /reclasificar` con motivo | `reclassified_count+1`, auditoría, snapshot intacto |
| 12 | Reapertura | `closed → open` | Ciclo 2 con plazo propio; compromiso único |
| 13 | Cierre | `open → closed` antes del plazo | Ciclo 1 `met`; oficial = ciclo 1 |
| 14 | `pending close` | `open → pending close` | No cierra, no pausa, sigue generando alertas |
| 15 | `merged` | `ticket.merged` | `outcome=excluded`, divergencia `merged_ticket`, fuera de denominador |
| 16 | Divergencia de espejo | Clasificar con espejo distinto | `catalog_mirror_mismatch`, prevalece BFF |
| 17 | Sincronización repetida | Ejecutar dos veces el mismo evento | Segunda vez `duplicado=true`; sin filas nuevas |
| 18 | Recuperación | Forzar error en un run | `status='failed'`; watermark no avanza |
| 19 | Sin evidencia | Clasificar `Error FE por duplicidad` | `no_policy`, sin SLA ni respaldo |
| 20 | Indicadores | `GET /indicadores` | Porcentaje con denominador y meta ≥ 80 % |

## 3. Casos límite obligatorios

| Caso | Entrada | Esperado |
|---|---|---|
| 24 h exactas | `delivery_status_date = created_at + 86.400 s` | **Incumplida** |
| 86.399 s | Ídem con 86.399 s | Cumplida |
| Cierre en el borde | `closed_at = due_at` | `met` (asimetría documentada) |
| Cierre 1 s tarde | `closed_at = due_at + 1 s` | `missed` |
| Clasificación tardía | Clasificar después del vencimiento | `missed_at_birth`, indicador secundario |
| Slug duplicado | `cambio_de_razón_social` en dos categorías | La categoría elegida decide política (72 h vs 36 h) |
| Fallback sin firma | Clasificar `Activacion NV` | `FALLBACK_SIN_RATIFICACION` |
| Excluida DEC-05 | `SIN HOMOLOGAR / Sin dato` | Sin compromiso |

## 4. Verificación de base (solo lectura, tras migración)

```sql
SELECT current_database(), current_user;
SELECT count(*) FROM information_schema.tables
 WHERE table_schema='public' AND table_name LIKE 'sla\_%';   -- 9
SELECT count(*) FROM pg_constraint
 WHERE conname LIKE 'sla_%' AND contype='c';                  -- 100
SELECT count(*) FROM pg_constraint
 WHERE conname LIKE 'sla_%' AND contype='f';                  -- 4
SELECT count(*) FROM pg_indexes
 WHERE schemaname='public' AND indexname LIKE 'sla_%';        -- 24
```

**No ejecutar hasta que exista la base de pruebas y M7 esté autorizado.**

## 5. Evidencia a conservar

Salida de `npx vitest run src/domain/sla` (31 pruebas), salida de `tsc`, hash del DDL, salida de `001_verificacion_diseno_sla.sql`, registro M8 con fecha/usuario/base/hash y capturas de los 20 escenarios (sin datos reales).
