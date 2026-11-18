# PLAN DE DESBLOQUEO PARA LA IMPLEMENTACIÓN DEL MOTOR SLA — EPIC-SLA-01

**Fecha:** 17/11/2026
**Alcance:** resolución documental y técnica de BLK-01b, BLK-05, BLK-06 y BLK-07.
**Naturaleza:** plan y solicitudes. **No implementa el motor, no ejecuta migraciones, no crea bases y no modifica código.**

---

## 0. Corrección previa

El informe anterior (`CIERRE_TECNICO_BACKEND_SLA.md`, §8.2) afirmaba que el backend candidato **no era un repositorio Git**. Era un error de búsqueda: el `.git` está en `restaurant-bi`, no en `restaurant-bi-fase1`. Queda corregido en este plan y en los documentos de seguimiento. El documento anterior se conserva sin modificar su texto original; la corrección se registra aquí.

---

## 1. Identidad del backend

| Verificación | Resultado | Evidencia |
|---|---|---|
| Ruta del repositorio | `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi` | Directorio con `.git` |
| Remoto | `https://github.com/Lakaester/CentrodeAtenci-n.git` | `git remote -v` |
| Commit con nombre C.O.S.E. | `81b567c feat: consolidar version funcional de C.O.S.E` | `git log --grep` |
| Backend en el repositorio | `backend/` versionado (`package.json`, `prisma/schema.prisma`, `vitest.config.ts`) | `git ls-files` |
| Stack | Express 4, Prisma 5, TypeScript 5, Vitest, Zod | `backend/package.json` |
| Frontend asociado | `frontend/`; `VITE_API_URL=/api` con proxy a `localhost:4000` | `frontend/src/lib/api.ts`, `vite.config.ts` |
| Fuente de datos | `public.v_unificado_norm` (usado en `TicketWorkspaceAssembler.ts`, `utils/filtros.ts`, `CustomerMemoryMigrator.ts`) | `grep` en `backend/src` |
| Estado de cambios | Backend y frontend **limpios**. Los 58 cambios sin commit están **solo en `docs/captures/`** | `git status --porcelain` agrupado por directorio |

**Conclusión:** el backend canónico de C.O.S.E. es `restaurant-bi/backend`. Queda verificado por historial, remoto, stack y consumo del frontend.

**Discrepancias a resolver:**

| ID | Discrepancia | Acción |
|---|---|---|
| DIS-01 | El README dice que la plataforma consume `public.v_unificado`; `AGENTS.md` y el código usan `public.v_unificado_norm`. | Confirmar con el responsable cuál es la fuente vigente. El código actual usa `_norm`. |
| DIS-02 | El literal «C.O.S.E.» aparece en el historial de commits, pero no en el README raíz ni en `backend/src`. | Aceptable como evidencia suficiente; pedir confirmación al responsable. |

---

## 2. Recuperación Git

### 2.1 Copias localizadas

Se buscó en: `/home/acast`, `C:\Users\acast\OneDrive\Escritorio`, `C:\Users\acast\Desktop`, `C:\Users\acast\Documents`, `C:\Users\acast\Downloads`, `C:\dev`, y en los proyectos conocidos.

| Ruta | ¿Repositorio Git? | Commits `288ffad`, `c7e480e`, `76dffe7` |
|---|---|---|
| `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi` | **Sí** | **Existen** (ancestros de HEAD) |
| `\\wsl.localhost\Ubuntu-24.04\home\acast\mailing` | Sí (Zammad) | No existen |
| `C:\dev\mailing` | Sí (Zammad) | No existen |
| `C:\dev\centralizador-correos`, `Zammad\zammad-7.2.3`, `catalogo-cose` | No | — |

**Limitación:** la búsqueda en `C:\Users\acast` completo agotó el tiempo y no se repitió por completo. Pueden existir otras copias en rutas no revisadas.

### 2.2 Estado de la copia encontrada

| Elemento | Valor |
|---|---|
| Rama actual | `remediation/audit` |
| HEAD | `27b973a feat(gestion): agregar submodulo de seguimiento proactivo` |
| Remoto de la rama | `origin/remediation/audit` = HEAD (0 commits de diferencia) |
| Commits pedidos | `288ffad`, `c7e480e`, `76dffe7`: existen y son ancestros de HEAD |
| Rama `main` local | `e07f21c`, **31 commits por detrás** de `origin/main` |
| Cambios sin commit | 58 entradas, todas no versionadas, bajo `docs/captures/` |
| Submódulos | Mencionado en el último commit; `git submodule status` no devolvió salida |

### 2.3 Recomendación

**Copia canónica: `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi`, rama `remediation/audit`.**

No hay otra copia que contenga los tres commits. No es necesario inicializar Git ni crear rama nueva.

**Condiciones antes de cualquier cambio:**

1. No ejecutar `checkout`, `reset`, `clean` ni `stash` sobre la copia. Los 58 cambios de `docs/captures/` son trabajo local y deben preservarse.
2. Decidir si `docs/captures/` se versiona, se ignora o se mueve. Esta decisión es del responsable, no de esta tarea.
3. Los cambios del módulo SLA se harán en una rama nueva desde `remediation/audit`, para no mezclarlos con la rama de remediación.

**Dependencia pendiente:** autorización del responsable para crear la rama de trabajo del módulo SLA.

---

## 3. Registro de la épica en `AGENTS.md`

### 3.1 Situación

`AGENTS.md` está versionado y prohíbe ejecutar más de una épica por sesión (reglas 1, 11 y 13). El documento no declara una épica activa. Solo menciona «Épica 1» (congelados) y «Épica 2» (reservada). **No es posible determinar la épica activa a partir del repositorio.**

### 3.2 Propuesta de registro (no aplicada)

Texto propuesto para añadir al inicio de `AGENTS.md`, **solo tras autorización expresa**:

```markdown
## ÉPICA ACTIVA

- **Épica:** EPIC-SLA-01 — Motor SLA de C.O.S.E. para correo electrónico
- **Módulo:** `backend/src/domain/sla/`
- **Documentación:** `docs/atenciones-zammad/EPIC_IMPLEMENTACION_SLA_COSE.md`
- **Autorizada por:** [pendiente: nombre y fecha]
- **Alcance:** backend del módulo SLA, migraciones SQL en base de prueba y contratos de API. Sin cambios en frontend ni en componentes congelados.
```

### 3.3 Dependencia pendiente

Autorización escrita del responsable para: (a) declarar EPIC-SLA-01 como épica activa, y (b) confirmar que el módulo SLA no infringe la regla 5 («cada PR debe afectar un único dominio»), dado que se creará un dominio nuevo.

---

## 4. Solicitud al DBA para la base de pruebas

### 4.1 Contexto

El runbook de `docs/test-environment/README.md` (§1) requiere que un DBA cree `restaurant_bi_test`. El rol de producción `pgvector_user` no tiene `CREATEDB` ni `CREATEROLE`, y no debe elevarse. **Esta tarea no conecta a producción ni crea la base.**

### 4.2 Texto de la solicitud

> **Asunto:** Creación de base de datos aislada `restaurant_bi_test` para el módulo SLA.
>
> **Solicitado por:** [pendiente: nombre del responsable técnico]
> **Ejecutado por:** DBA del servidor de PostgreSQL
> **Fecha:** [pendiente]
>
> **Objetivo:** disponer de una base exclusiva para pruebas de migraciones y pruebas automatizadas del módulo SLA.
>
> **Requisitos:**
>
> 1. **Base nueva e independiente:** `restaurant_bi_test`. No debe ser `pgvector_db` ni ninguna base de negocio.
> 2. **Roles nuevos, con credenciales propias:**
>    - `cope_test_migration`: login, `CREATE` sobre la base de prueba, sin `SUPERUSER`, `CREATEDB` ni `CREATEROLE`.
>    - `cope_test_runtime`: login, solo `SELECT, INSERT, UPDATE, DELETE` sobre tablas del esquema `public` de la base de prueba. Sin `SUPERUSER`, `CREATEDB` ni `CREATEROLE`.
> 3. **Sin reutilizar credenciales de producción.** Las contraseñas las define el DBA y se entregan por canal seguro, no por correo ni por el repositorio.
> 4. **Aislamiento de red:** la base solo debe ser accesible desde la estación de desarrollo autorizada. Si el servidor no permite esa restricción, indicarlo.
> 5. **Sin datos productivos:** no restaurar ningún respaldo de producción en esta base. Solo datos sintéticos.
> 6. **Respaldo y restauración:** la base debe incluirse en la política de respaldo como base de prueba, con retención definida por el DBA.
> 7. **Uso exclusivo para pruebas:** la base no debe usarse para reportes, integraciones ni consultas operativas.
>
> **Verificación que debe entregar el DBA (solo lectura):**
>
> ```sql
> SELECT current_database(), current_user, inet_server_addr(), inet_server_port();
> SELECT rolname, rolsuper, rolcreatedb, rolcreaterole
>   FROM pg_roles WHERE rolname IN ('cope_test_migration', 'cope_test_runtime');
> SELECT datname FROM pg_database WHERE datname IN ('restaurant_bi_test', 'pgvector_db');
> ```
>
> **Criterio de aceptación:** las tres consultas devuelven el resultado esperado; `cope_test_runtime` tiene `rolsuper = false`, `rolcreatedb = false` y `rolcreaterole = false`; la base de prueba y la de producción son distintas.

### 4.3 Procedimiento de respaldo y restauración de la base de prueba

| Paso | Acción | Responsable |
|---|---|---|
| R1 | Respaldo lógico del esquema antes de cada migración: `pg_dump --schema-only` de `restaurant_bi_test`. | Desarrollador, con el usuario `cope_test_migration` |
| R2 | Respaldo completo de datos sintéticos, si existen, antes de migraciones destructivas. | Desarrollador |
| R3 | Restauración desde R1 o R2 con `psql` sobre `restaurant_bi_test`. Nunca sobre otra base. | Desarrollador |
| R4 | Verificación posterior a la restauración con las consultas de §4.2. | Desarrollador |

### 4.4 Estado

**Pendiente de DBA.** Sin esta base no puede validarse ninguna migración ni prueba.

---

## 5. Procedimiento de migración (diseño, no aplicado)

### 5.1 Cómo funcionan hoy las migraciones

- Son archivos SQL en `backend/sql/migrations/` (13) y `backend/prisma/migrations/` (24).
- Se aplican con `psql` sobre `DATABASE_URL`. No hay herramienta de historial: `prisma migrate` no se usa; el script `prisma:pull` sí existe.
- No hay tabla de control de migraciones aplicadas. El registro de qué se aplicó es documental.

Consecuencia: el procedimiento debe añadir un control explícito. No es posible confiar en la tabla de migraciones de Prisma.

### 5.2 Procedimiento propuesto

| Paso | Control | Criterio de bloqueo |
|---|---|---|
| **M1. Identificar el destino** | Un script lee `DATABASE_URL` **sin imprimir la contraseña** y muestra solo host, puerto y nombre de base. | Bloquear si el nombre de base no es `restaurant_bi_test`. |
| **M2. Bloquear producción** | Comparar host y base contra una lista negra: `<IP_BD_PRODUCCION>` y `pgvector_db`. | Bloquear si coincide con cualquier entrada de la lista, aunque el nombre sea de prueba. |
| **M3. Verificar el rol** | Consultar `current_user` y confirmar que es `cope_test_migration`. | Bloquear si es `pgvector_user` o cualquier rol con `SUPERUSER`. |
| **M4. Revisar el SQL** | Revisión humana del archivo: sin `DROP` sobre tablas que no sean del módulo SLA, sin `TRUNCATE`, sin referencias a otra base. | Bloquear ante cualquier `DROP` o `TRUNCATE` no justificado. |
| **M5. Respaldo previo** | Paso R1 de §4.3. | Bloquear si el respaldo falla o queda vacío. |
| **M6. Aplicación** | `psql -v ON_ERROR_STOP=1 -1 -f <archivo>` (transacción única). | Si falla, la transacción revierte; registrar el error. |
| **M7. Verificación** | Consultas de existencia de tablas, columnas, índices y restricciones del módulo. | Bloquear la siguiente migración si falla. |
| **M8. Evidencia** | Registro: fecha, usuario, base, hash SHA-256 del archivo SQL, resultado y consultas de verificación. | Sin evidencia, la migración no se considera aplicada. |

### 5.3 Rollback

Cada migración `up` debe tener su `down` en un archivo separado. El `down` se prueba en la base de prueba antes de darla por válida. Si no es posible escribir un `down` seguro, la migración se marca **no reversible** y requiere aprobación expresa.

### 5.4 Dependencia pendiente

Aprobación del responsable del procedimiento M1–M8, y decisión sobre si el control de migraciones se implementa como tabla `schema_migrations_sla` propia del módulo.

---

## 6. Catálogo

### 6.1 Localización

| Atributo | Valor |
|---|---|
| Archivo | `restaurant-bi/frontend/src/components/workspace/CategoryData.ts` |
| Versionado | Sí, en `remediation/audit` |
| Formato | TypeScript: `CATEGORY_HIERARCHY: Record<string, SubcatEntry[]>` con `label` y `value` |
| Categorías | 13 |
| Subcategorías | 65 |
| Identidad | Coincide con el árbol de Zammad y con las 30 filas de la matriz (verificado el 16/11/2026) |
| Semántica | El comentario dice «valor Zendesk»: los `value` son valores del campo etiquetado (tagger) de Zendesk |

### 6.2 Dudas sobre la fuente oficial

- Es la fuente **vigente** del catálogo funcional según las decisiones confirmadas (DT-02: 65 con marca). Esto se mantiene.
- Su nombre y comentario lo vinculan a Zendesk. Si Zendesk se retira, los valores deben mantenerse como identificadores del catálogo, no como dependencia de Zendesk. Esto debe registrarse.

### 6.3 Propuesta de consumo sin duplicar ni divergir

1. **No mover ni modificar** `CategoryData.ts`.
2. Un script de generación (`scripts/sla/export-catalogo.ts`) lee el archivo y produce `backend/src/domain/sla/catalogo/catalogo-oficial.json`, con 13 categorías, 65 subcategorías y su hash SHA-256.
3. El JSON se versiona en el backend. El backend **no importa** el archivo del frontend.
4. Una prueba automatizada verifica que: (a) el JSON coincide con el hash del archivo fuente; (b) las 30 filas de la matriz existen en el catálogo; (c) las 35 subcategorías restantes se clasifican como servicio o no servicio según DEC-05.
5. Cuando cambie `CategoryData.ts`, el hash no coincidirá y la prueba fallará. El cambio exige regenerar el JSON y revisar la matriz.

### 6.4 Dependencia pendiente

Autorización para crear `scripts/sla/` y `backend/src/domain/sla/catalogo/` en la rama de trabajo. Confirmación del responsable de que el catálogo se conserva como fuente vigente.

---

## 7. Bloqueantes y estado

| ID | Bloqueante | Estado | Evidencia | Responsable de autorizar | Criterio de cierre |
|---|---|---|---|---|---|
| **BLK-01b** | Git | **Cerrado (17/11/2026)** | §2. Responsable autorizó trabajar sobre `remediation/audit`; HEAD `27b973a` verificado antes y después; 58 cambios de `docs/captures/` intactos. | Responsable del proyecto | Autorización registrada y estado Git verificado. **Cumplido.** |
| **BLK-05** | Base de pruebas | **Pendiente de DBA** | §4 | DBA | Las tres consultas de §4.2 devuelven el resultado esperado. |
| **BLK-06** | Migraciones | **Diseñado; no aprobado** | §5. El DDL 001 y su rollback existen como diseño revisable, con guarda de base y rol. | Responsable técnico | Procedimiento M1–M8 aprobado y probado en `restaurant_bi_test`. |
| **BLK-07** | Épica y reglas | **Cerrado (17/11/2026)** | EPIC-SLA-01 registrada en `AGENTS.md` por autorización expresa; 13 reglas previas conservadas. | Responsable del proyecto | Épica declarada en `AGENTS.md`. **Cumplido.** |
| BLK-08 | Catálogo | **Cerrado técnicamente (17/11/2026)** | §6.3 ejecutado: snapshot con hash identico al original, JSON de consumo, metadatos y 5 pruebas en verde. | Responsable del proyecto | Exportación con prueba de hash. **Falta el commit**, no autorizado. |
| BLK-09 | Ventana de pruebas (BLK-02 previo) | Pendiente | `CIERRE_TECNICO_BACKEND_SLA.md` | Operador de la sesión concurrente | Ventana declarada con recursos libres. |

**Observación:** BLK-01b y BLK-07 quedan cerrados por decisión y registro, no por haber redactado un documento. BLK-08 cumple el criterio técnico; el versionado en Git requiere un commit que no está autorizado.

---

## 8. Orden de ejecución

Este orden respeta las dependencias. Los pasos 1 a 3 son independientes entre sí.

| Orden | Paso | Depende de | Quién | Estado |
|---|---|---|---|---|
| 1 | Aprobar la copia canónica y la rama de trabajo (§2.3) | — | Responsable | **Cumplido**: se autoriza trabajar sobre `remediation/audit` |
| 2 | Declarar la épica activa en `AGENTS.md` (§3.2) | — | Responsable | **Cumplido (17/11/2026)** |
| 3 | Solicitar al DBA `restaurant_bi_test` (§4.2) | — | Responsable técnico | Pendiente |
| 4 | Aprobar el procedimiento de migración (§5.2) | — | Responsable técnico | Pendiente |
| 5 | Exportar y versionar el catálogo, con prueba de hash (§6.3) | 1 | Desarrollador | **Exportado y probado**; falta el commit |
| 6 | Redactar el esquema `sla_*` en SQL y su `down` (sin aplicar) | 1, 4 | Desarrollador | **Cumplido y consolidado (17/11/2026)**: diseño 001, rollback y verificación estructural |
| 7 | Aplicar en `restaurant_bi_test` con procedimiento M1–M8 | 3, 6 | Desarrollador | Bloqueado por 3 y 4 |
| 8 | Implementar `backend/src/domain/sla/` y pruebas | 5, 7 | Desarrollador | Bloqueado; además requiere resolver OBS-27 |
| 9 | Pruebas en ventana declarada (BLK-09) | 8 | Desarrollador + operador | Bloqueado |
| 10 | Contrato API y guía de frontend, con rutas reales | 8, 9 | Desarrollador | Bloqueado |

---

## 9. Condiciones de inicio de la implementación

La implementación (orden 8) puede comenzar cuando se cumplan **todas** estas condiciones:

1. ~~Copia canónica y rama de trabajo autorizadas~~ — **cumplida (17/11/2026)**.
2. ~~Épica declarada en `AGENTS.md` por autorización expresa~~ — **cumplida (17/11/2026)**.
3. Base `restaurant_bi_test` creada por el DBA y verificada (paso 3) — **pendiente**.
4. Procedimiento de migración aprobado (paso 4) — **pendiente**.
5. ~~Catálogo exportado con prueba de hash en verde~~ — **cumplida técnicamente (17/11/2026)**; el versionado requiere commit.
6. Esquema SLA revisado y consolidado (17/11/2026) y migración probada en la base de prueba con `down` verificado (paso 7) — **el diseño está revisado; la prueba no existe**.

**Estado:** 3 de 6 condiciones cumplidas. Faltan la base aislada y la aprobación del procedimiento. La implementación sigue bloqueada.

**Lo que no se puede hacer aunque se cumplan las condiciones:**

- Aplicar migraciones sobre `DATABASE_URL` de producción o de negocio.
- Ejecutar la suite de Zammad ni levantar servicios pesados sin ventana (BLK-09).
- Conectar el módulo a la base empresarial de Restaurant.pe.
- Enviar correos reales o conectar el buzón definitivo.

---

## 10. Confirmación de la fase de recuperación (17/11/2026, primera parte)

- No se modificó `restaurant-bi`: ni código, ni `AGENTS.md`, ni la rama, ni el índice, ni los cambios sin commit. (La modificación de `AGENTS.md` se autorizó después y consta en §11.)
- No se creó ninguna base de datos ni se ejecutó migración alguna.
- No se conectó a PostgreSQL de producción ni a la base empresarial.
- No se leyeron secretos: `backend/.env` existe, pero no se abrió.
- No se iniciaron ni detuvieron servicios, workers ni schedulers.
- No se hizo commit ni push.
- Los documentos fuente de EPIC-SLA-01 no se modificaron salvo los de seguimiento indicados en el informe.

---

## 11. Ejecución autorizada del 17/11/2026: épica, catálogo y esquema

**Autorizado:** trabajar sobre `remediation/audit`, registrar EPIC-SLA-01 en `AGENTS.md`, exportar el catálogo con hash y diseñar el esquema SQL.
**No autorizado y no ejecutado:** ejecutar SQL o migraciones, crear bases o roles, implementar el motor.

### 11.1 Resultado

| Entregable | Ruta | Estado |
|---|---|---|
| Registro de la épica | `restaurant-bi/AGENTS.md` (§ `EPICA ACTIVA`) | Hecho; 13 reglas previas conservadas |
| Exportador | `restaurant-bi/backend/scripts/sla/export-catalogo.ts` | Hecho |
| Snapshot literal | `restaurant-bi/backend/src/domain/sla/catalogo/catalogo-fuente.snapshot.ts` | Hecho; hash identico al origen |
| JSON de consumo | `restaurant-bi/backend/src/domain/sla/catalogo/catalogo-oficial.json` | Hecho |
| Metadatos | `restaurant-bi/backend/src/domain/sla/catalogo/catalogo-oficial.meta.json` | Hecho |
| Documentación del catálogo | `restaurant-bi/backend/src/domain/sla/catalogo/README.md` | Hecho |
| Prueba del catálogo | `restaurant-bi/backend/src/__tests__/sla-catalogo.test.ts` | 5 de 5 en verde |
| Matriz de 65 subcategorías | `docs/atenciones-zammad/MATRIZ_POLITICAS_CATALOGO_SLA.md` | Hecho; 27/3/28/7, 0 errores |
| Revisión y consolidación | `docs/atenciones-zammad/REVISION_DECISIONES_PENDIENTES_SLA.md` | Hecho |
| Diseño del esquema | `docs/atenciones-zammad/DISEÑO_ESQUEMA_BD_SLA.md` | Revisado y consolidado |
| DDL 001 | `docs/atenciones-zammad/sql/001_diseno_esquema_sla.sql` | Corregido; no ejecutado |
| Rollback 001 | `docs/atenciones-zammad/sql/001_rollback_diseno_sla.sql` | Propuesta, no ejecutada |
| Verificación estructural | `docs/atenciones-zammad/sql/001_verificacion_diseno_sla.sql` | Creado; no ejecutado |

### 11.2 Verificaciones ejecutadas

| Verificación | Resultado |
|---|---|
| Rama y HEAD antes | `remediation/audit`, `27b973a` |
| Rama y HEAD después | `remediation/audit`, `27b973a` |
| Cambios previos en `docs/captures/` | 58, intactos |
| Commits creados | 0 |
| `npx vitest run src/__tests__/sla-catalogo.test.ts` | 1 archivo, 5 pruebas, 5 en verde |
| `npx tsc --noEmit -p tsconfig.json` | Sin errores |
| Ejecución de SQL | Ninguna |
| Conexión a base de datos | Ninguna |

### 11.3 Bloqueantes que permanecen

| Bloqueante | Estado |
|---|---|
| BLK-05 · base `restaurant_bi_test` | Pendiente de DBA |
| BLK-06 · procedimiento de migración | Pendiente de aprobación |
| BLK-09 · ventana de pruebas | Pendiente |
| OBS-27 · legado `domain/sla` | Resuelto en diseño: coexistencia aislada; cambio de archivos pendiente de autorización |
| OBS-28 · REA-02 | **Falta firma funcional, no análisis.** 5G.4.5 §4.2 la declara «Alternativa A aprobada»; `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` es un registro anterior. A cabe sin cambios; B (ciclo sin plazo) no |
| OBS-30 · mapa de clases del catálogo | Resuelto técnicamente (65 filas, 0 errores); `MATRIZ_RATIFICACION_FALLBACK_SLA.md` con 28 filas preparadas; falta firma de Soporte |
| OBS-31 · discrepancias de especificación | 1 descartada; 4 fichas preparadas (D-03 a D-06), sin confirmar |
| OBS-33 · clasificación vigente | **Recomendada B** (tabla `sla_classification`); borrador escrito, no aplicado. No bloquea el DDL |
| Registro de migraciones | **Recomendada** tabla `sla_schema_migration`; si se aprueba, cambia `001` antes de aplicarlo |

### 11.4 Siguiente paso

La revisión y consolidación del esquema está hecha. El paquete de aprobación reúne las decisiones que faltan. El siguiente paso no es aplicar el DDL, sino:

1. que el responsable técnico firme D-03 a D-06 y decida D-07 y D-08 (pueden cambiar el esquema);
2. que el responsable funcional firme D-01 (ciclos) y Soporte firme D-02 (28 respaldos);
3. solicitar al DBA `restaurant_bi_test` y los dos roles (BLK-05);
4. aprobar el procedimiento M1–M8 (BLK-06);
5. solo entonces, aplicar `001` con M1–M8 y ejecutar `001_verificacion_diseno_sla.sql`.

**Por qué en ese orden:** los pasos 1 y 2 no necesitan base. Si se dejan para el final, un rechazo obliga a un `ALTER TABLE` sobre un esquema ya aplicado; si se resuelven antes, el archivo se aplica una sola vez.

---

## 12. Paquete de aprobación previo a migración (17/11/2026, segunda parte)

**Autorizado:** preparar la versión candidata, evaluar las decisiones pendientes y redactar el paquete.
**No autorizado y no ejecutado:** SQL, migraciones, creación de base o roles, modificación del DDL, implementación del motor.

### 12.1 Entregables

| Archivo | Contenido | Estado |
|---|---|---|
| `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` | Paquete maestro de aprobación | Nuevo, sin firmas |
| `DECISION_CICLOS_REAPERTURA_OBS_28.md` | Decisión formal de ciclos 2..N | Nuevo, sin firmar |
| `MATRIZ_RATIFICACION_FALLBACK_SLA.md` | 28 filas de respaldo para Soporte | Nuevo, sin firmar |

### 12.2 Recomendaciones emitidas (no aprobadas)

| Tema | Recomendación | Efecto si se aprueba |
|---|---|---|
| OBS-28 / REA-02 | Alternativa A (ciclo con plazo propio) | Ninguno sobre el DDL |
| OBS-31 | Mantener las cuatro propuestas del DDL | Ninguno estructural |
| OBS-33 | Tabla `sla_classification` | +1 tabla, +1 FK, +2 índices, +3 `CHECK` |
| Registro de migraciones | Tabla `sla_schema_migration` | +1 tabla, +4 `CHECK`; cambia `001` |
| Prisma | Prisma no posee el esquema SLA; prohibidos `db pull`, `db push`, `migrate` y `db execute` | Ninguno: es norma, no código |

### 12.3 Lo que este paso no hizo

- No modificó el DDL, el rollback ni el script de verificación: las propuestas de tabla están escritas como borrador.
- No actualizó `DECISIONES_PENDIENTES_EMAIL_5G4_4.md`, que sigue marcando REA-02..REA-06 como pendientes: su corrección requiere autorización.
- No convirtió ninguna recomendación en regla.
- No conectó a ninguna base ni ejecutó SQL.
