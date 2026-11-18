# PLAN DE MIGRACIÓN SLA — EPIC-SLA-01

**Fecha:** 17/11/2026
**Estado:** `BLOQUEADO_POR_DEPENDENCIA`. **No ejecutado.**
**Archivos:** `sql/001_diseno_esquema_sla.sql`, `sql/001_rollback_diseno_sla.sql`, `sql/001_verificacion_diseno_sla.sql` (sin cambios: 9 tablas, 100 CHECK, 4 FK, 24 índices).

## 1. Orden de resolución antes de tocar la base

1. Responsable técnico: D-03, D-04, D-05, D-06 (confirmaciones) y D-07/D-08 (modelo). D-08 cambia `001`.
2. Responsable funcional: D-01 (ciclos) y D-02 (28 respaldos).
3. Responsable técnico: D-10 (M1–M8).
4. DBA: D-09 (base y roles) y revisión final del archivo con hash (M4/C5).
5. Operador: BLK-09 (ventana).
6. Solo entonces: M1..M8.

Si D-07 o D-08 se aprueban, se actualizan **juntos** diseño, `001`, rollback, verificación y los conteos:
sin aprobación 9/100/4/24 · con D-08 10/104/4/24 · con D-07+D-08 11/107/5/26.

## 2. Instrucciones exactas para el DBA (BLK-05)

```sql
-- Ejecutar SOLO en el servidor de pruebas, nunca en producción.
CREATE DATABASE restaurant_bi_test;

CREATE ROLE cope_test_migration LOGIN PASSWORD '<definido por el DBA>';
ALTER ROLE cope_test_migration IN DATABASE restaurant_bi_test
  GRANT CREATE ON SCHEMA public;

CREATE ROLE cope_test_runtime LOGIN PASSWORD '<definido por el DBA>';
GRANT CONNECT ON DATABASE restaurant_bi_test TO cope_test_runtime;
GRANT USAGE ON SCHEMA public TO cope_test_runtime;

-- Prohibido: SUPERUSER, CREATEDB, CREATEROLE en ambos roles.
```

Permisos posteriores a la migración sobre las 9 tablas:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO cope_test_runtime;
REVOKE UPDATE, DELETE ON sla_audit FROM cope_test_runtime;  -- append-only
```

**Nunca** usar `pgvector_user`, `postgres`, la IP `<IP_BD_PRODUCCION>` ni la base de negocio. El DBA entrega credenciales por canal seguro; no se guardan en el repositorio.

### 2.1 Verificación previa (solo lectura)

```sql
SELECT current_database(), current_user, inet_server_addr(), inet_server_port();

SELECT rolname, rolsuper, rolcreatedb, rolcreaterole
  FROM pg_roles
 WHERE rolname IN ('cope_test_migration','cope_test_runtime');

SELECT datname FROM pg_database
 WHERE datname IN ('restaurant_bi_test','pgvector_db');
```

Criterio: base de prueba ≠ base de producción; los tres atributos de rol en `false`.

## 3. Procedimiento M1–M8 (diseñado, no ejecutado)

| Paso | Acción | Guarda / evidencia |
|---|---|---|
| M1 | Mostrar host y base de `DATABASE_URL` sin contraseña | Solo host y nombre de base |
| M2 | Comparar contra lista negra (`<IP_BD_PRODUCCION>`, `pgvector_db`) | Aborta si coincide |
| M3 | `SELECT current_user` → `cope_test_migration` | Aborta si otro |
| M4 | Revisar el SQL: sin `DROP` ajeno, sin `TRUNCATE`, sin otra base, 0 `CASCADE` | Ya revisado a mano; hash del archivo |
| M5 | Respaldo `pg_dump --schema-only` y de datos sintéticos | Archivo de respaldo fechado |
| M6 | `psql -v ON_ERROR_STOP=1 -1 -f sql/001_diseno_esquema_sla.sql` | Guarda interna del DDL: aborta si base/rol incorrectos |
| M7 | `psql -f sql/001_verificacion_diseno_sla.sql` (solo lectura) | 9 tablas, 100 CHECK, 4 FK, 24 índices |
| M8 | Registrar fecha, usuario, base, hash y salida | Evidencia externa (aunque se apruebe D-08) |

## 4. Rollback

Archivo: `sql/001_rollback_diseno_sla.sql`. 9 `DROP TABLE IF EXISTS` en orden inverso, guarda de entorno, **sin `CASCADE`**. Solo se ejecuta en la ventana autorizada o en base desechable independiente, tras respaldo M5. Verificar después que no quedan tablas, índices ni restricciones `sla_*`.

Criterios: M7 falla sin corrección hacia delante; conteos distintos del diseño; necesidad de reaplicar `001` corregido. No ejecutar por comodidad, sin respaldo ni sobre otra base.

## 5. Carga de políticas (posterior a la migración)

La matriz de 65 filas no se carga completa:

| Clase | Cantidad | Acción |
|---|---:|---|
| `matrix` | 27 | Cargar como `active` con n, P75 y confianza verificados; AP-01 sigue condicional |
| `insufficient_evidence` | 3 | Cargar como `pending`, sin minutos, sin respaldo |
| `fallback` | 28 | **Bloquear hasta D-02.** El motor ya rechaza su uso sin ratificación |
| `excluded_non_service` | 7 | Cargar como `inactive`, sin duraciones, fuera de denominadores |

## 6. Verificación funcional mínima tras M7 (cuando exista base)

1. Compromiso `pending_classification` sin vencimiento asignado.
2. Clasificación de `Ajustes FE` → `20-MAIL-...-AJUSTES_FE`, 1.440 min, inicio = `created_at`.
3. Fallback sin ratificación → `FALLBACK_SIN_RATIFICACION`.
4. Clasificación tardía → `missed_at_birth` + divergencia.
5. `pending close` no cierra; `merged` → `outcome='excluded'` + divergencia.
6. Reapertura → ciclo 2 con `due_at = opened_at + resolution_minutes`.
7. Evento repetido → `duplicado=true`, sin fila nueva.
8. Primera respuesta a 86.399 s → cumplida; a 86.400 s → incumplida.
9. Tres alertas por métrica (75/90/100).
10. Rollback y reaplicación.

**Estado real:** ninguno de estos pasos se ejecutó. No existe base de pruebas.
