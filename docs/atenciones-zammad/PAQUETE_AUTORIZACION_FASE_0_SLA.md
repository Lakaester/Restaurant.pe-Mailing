# PAQUETE DE AUTORIZACIÓN — FASE 0 — EPIC-SLA-01

**Proyecto:** MAILING — C.O.S.E. sobre Zammad 7.2.3
**Épica:** EPIC-SLA-01
**Etapa:** 1 — Cierre y preparación
**Fase:** 0 — Evidencia previa a la implementación
**Documento base:** `EPIC_IMPLEMENTACION_SLA_COSE.md` v1.1
**Documentos de referencia:** `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md`, `TABLERO_EJECUCION_ETAPA_1_SLA.md`, `ANALISIS_BLOQUEANTES_ETAPA_1_1_SLA.md`
**Fecha:** 16/11/2026
**Modo:** PLAN — **solo lectura**. No ejecuta pruebas.
**Naturaleza:** paquete de revisión y autorización. **No implementa, no configura y no modifica ningún sistema.**
**Versión:** 1.3 — cuarta revisión correctiva (H-16 a H-20).
**Estado:** **listo para cuarta revisión.** Fase 0 **no ejecutada**.

> **Regla de lectura.** Este paquete no crea pruebas nuevas ni renumera las existentes. Reproduce el inventario exacto de 17 pruebas F0 definido en `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md`. Ninguna prueba se ejecuta con una aprobación condicional.

---

## 0. Resumen ejecutivo

| Elemento | Valor |
|---|---|
| Pruebas F0 documentadas | **17** |
| Estado `passed` | **3**: F0-10, F0-11, F0-11b |
| Estado `pending` | **7**: F0-01 (cierre), F0-02, F0-04, F0-05, F0-07, F0-08, F0-09 |
| Estado `blocked` | **3**: F0-03, F0-06, F0-15 |
| Estado `deferred` | **4**: F0-12, F0-13, F0-14, F0-16 |
| Con evidencia de lectura | **4**: F0-01 (apertura), F0-10, F0-11, F0-11b |
| Candidatas en Fase 0, sujetas a precondiciones | **9 IDs**: F0-02 (P e I), F0-04, F0-03*, F0-05, F0-06*, F0-07, F0-08, F0-09, F0-15* |
| Requieren harness o base del BFF | **4**: F0-12, F0-13, F0-14, F0-16 |
| Pruebas que escriben en Zammad | 6: F0-02, F0-03, F0-06, F0-07, F0-08, F0-09 |
| Pruebas que requieren instancia aislada | F0-03 (casos destructivos o globales) |
| Decisiones funcionales | **Confirmadas**: DT-01, DT-02, DP-04, exclusión de 7 no servicio |
| Aprobaciones | **Condicionales**: AP-01, AP-02, AP-03 |
| Autorización para ejecutar | **No otorgada** |
| Pruebas ejecutadas en esta sesión | **0** |

**Advertencia central:** **F0-15 no puede considerarse una prueba de solo lectura mientras el worker genere escrituras de auditoría o historial.** Aunque el motor no escriba, el worker activo modifica `histories` y `audit_logs` y hace fallar la comparación de contadores. F0-15 exige una **ventana exclusiva**, sin F0-06, F0-07, F0-08 ni F0-09 en paralelo, y con worker, scheduler, Gmail y Redis verificados como inactivos o sin actividad.

**Nota de alcance:** `*` F0-03 se ejecuta **exclusivamente** en una instancia aislada y desechable, con base independiente y credencial propia; **no hay ejecución parcial en el piloto** y, si la instancia no existe, queda **bloqueada**. F0-06 requiere **barrera técnica del piloto**; sin ella, queda **bloqueada**. F0-15 requiere una ventana exclusiva o se marca **`inconclusive`**. Las 4 pruebas que requieren harness/BFF **no** se ejecutan antes de que ese componente exista: no se afirma un 17/17 previo.

**Conclusión:** el paquete está corregido para cuarta revisión. La ejecución requiere la validación final de AP-01, AP-02 y AP-03, las credenciales, la instancia aislada, la ventana exclusiva, la barrera técnica del piloto y el resto de precondiciones de §10.

### 0.1 Correcciones de la revisión

| Hallazgo | Corrección aplicada | Estado |
|---|---|---|
| H-01 | F0-03 rediseñada: 11 intentos con método, endpoint, recurso y efecto; caso 7 contra agente/admin; instancia aislada o bloqueo | Corregido |
| H-02 | F0-15 aislada en ventana exclusiva; prohibido ejecutarla en paralelo con F0-06/07/08/09 | Corregido |
| H-03 | Redis: prohibición de `FLUSHDB`, `FLUSHALL` y borrado masivo; solo inspección | Corregido |
| H-04 | F0-06: destinatario allowlisted, barrera verificable, SMTP ≠ entrega, criterio de marcas precisado | Corregido |
| H-05 | F0-01: baseline de apertura y de cierre en archivos separados, sin sobrescritura | Corregido |
| H-06 | F0-12/13/14/16: harness aislado o traslado; no se afirma 17/17 antes de construir | Corregido |
| H-07 | Tickets desechables con identificación inequívoca y registro | Corregido |
| H-08 | Reversión: documentada / posible / probada; `2xx` inesperado = incidente S1 | Corregido |
| H-09 | Secuencia corregida: sin paralelismos incompatibles | Corregido |
| H-10 | Checklist ampliado; AP-01/02/03 siguen condicionales | Corregido |
| H-11 | F0-03 exclusivamente en instancia aislada; sin ejecución parcial en el piloto; credencial **a crear** en la misma instancia | Corregido |
| H-12 | Criterios individuales de los 11 intentos: política, HTTP, recurso, efecto, aislamiento e interpretación de 401/403/2xx; caso 7 con usuario desechable | Corregido |
| H-13 | F0-06: barrera técnica **del piloto**, no solo validación operativa; sin restricción efectiva, bloqueada | Corregido |
| H-14 | F0-15: contadores nominales, detección de escrituras concurrentes, inactividad verificada y evidencia sin payloads | Corregido |
| H-15 | Separación piloto / instancia aislada / BFF; credenciales separadas y no compartidas | Corregido |
| H-16 | F0-02-P figura como **pendiente** de creación y verificación; F0-04 y F0-05 dependen de ella y de sus demás precondiciones | Corregido |
| H-17 | F0-15: limitaciones de las cuatro señales y mecanismos complementarios; sin prueba de ausencia absoluta; `inconclusive` si falta evidencia | Corregido |
| H-18 | Alcance de la credencial alineado: sin escritura en tickets/artículos/configuración; usuarios cliente permitidos por Zammad; BFF GET-only y sin `/users` | Corregido |
| H-19 | F0-06: barrera técnica **del piloto**; el canal aislado solo si la prueba se traslada formalmente | Corregido |
| H-20 | F0-12/13/14/16: ejecución **secuencial por defecto**; paralelismo solo con aislamiento demostrado | Corregido |

### 0.2 Hallazgos que siguen abiertos

| ID | Hallazgo abierto | Impacto | Se cierra con |
|---|---|---|---|
| H-01r | No hay instancia aislada disponible | F0-03 bloqueada | Provisión de instancia desechable |
| H-02r | No hay ventana exclusiva acordada | F0-15 `inconclusive` o bloqueada | Acta de ventana |
| H-03r | Procedimiento Redis no aprobado | Ninguna intervención permitida | Procedimiento separado |
| H-04r | Allowlist y barrera de F0-06 no declaradas | F0-06 bloqueada | Acta de destinatario |
| H-05r | Baseline de cierre no tomada | F0-01 incompleta | Cierre de ventana |
| H-06r | Decisión harness/BFF pendiente | F0-12/13/14/16 bloqueadas | Decisión A/B/C |
| H-07r | Tickets desechables no registrados | F0-05/06/07/08/09 bloqueadas | Registro §5.3 |
| H-08r | Ninguna reversión probada | Solo documentada | Evidencia de reversión |
| H-09r | Sin garantía de ausencia de sesiones concurrentes | Toda la Fase 0 bloqueada | Coordinación |
| H-10r | AP-01, AP-02 y AP-03 condicionales | No se autoriza ejecución | Validación final expresa |
| H-11r | No hay instancia aislada con base independiente | F0-03 bloqueada | Provisión de instancia |
| H-12r | No hay usuario desechable en la instancia aislada | Caso 7 no ejecutable | Provisión de usuario |
| H-13r | No hay barrera técnica **del piloto** para F0-06 | F0-06 bloqueada | Relay/regla de correo del piloto |
| H-14r | No hay evidencia de ventana silenciosa | F0-15 `inconclusive` | Evidencia §9.7.1 |
| H-15r | No hay separación física de credenciales | F0-02/F0-03 bloqueadas | Provisión separada |
| H-16r | F0-02-P no creada | F0-04/F0-05 bloqueadas | Creación autorizada |
| H-17r | Las cuatro señales no prueban ausencia absoluta | F0-15 `inconclusive` | Mecanismos complementarios |
| H-18r | El BFF aún no implementa GET-only ni la exclusión de `/users` | Riesgo de diseño | Implementación en etapa 2 |
| H-19r | No hay barrera técnica del canal del piloto | F0-06 bloqueada | Relay o regla de correo del piloto |
| H-20r | No se demostró aislamiento para paralelismo BFF | F0-12..16 secuenciales | Prueba de aislamiento |

---

## 1. Objetivo y alcance

### 1.1 Objetivo

Demostrar, **antes de construir el motor**, que:

1. la integración puede leer todo lo necesario;
2. **no puede escribir en tickets, artículos ni configuración**; la política nativa de Zammad permite editar usuarios cliente, y el BFF lo bloquea por diseño (`GET`-only, sin `/users`);
3. las marcas de tiempo de la métrica existen y son fiables;
4. la matriz es reproducible;
5. el diseño sobrevive a duplicados, desorden y caídas;
6. no se almacenan datos personales.

Fase 0 **no crea el motor**. Crea evidencia. De las 17 pruebas, **9 IDs** son candidatos en Fase 0 **cuando se cumplan sus precondiciones**; **4** requieren harness/BFF y se difieren; las 4 restantes tienen evidencia de lectura (F0-01 apertura y 3 pruebas `passed`).

### 1.2 Qué incluye este paquete

- Inventario exacto de las 17 pruebas.
- Clasificación por tipo.
- Precondiciones, dependencias y riesgos.
- Evidencia exigida.
- Criterios de aprobación, rechazo y aborto.
- Procedimiento de reversión.
- Secuencia de ejecución.
- Checklist de autorización.
- Dependencias de worker, scheduler, Gmail, PostgreSQL y Redis.

### 1.3 Qué no incluye

- Ejecución de pruebas.
- Creación de usuarios, tokens, bases o tablas.
- Cambios en Zammad, Zendesk, COSE, PostgreSQL o Redis.
- Implementación del motor.

---

## 2. Inventario exacto de las 17 pruebas F0

> Los identificadores y nombres se conservan literalmente del documento de criterios. **No se renumeran ni se agregan pruebas.**

| ID | Nombre | Bloqueante | Estado | Tipo | Evidencia |
|---|---|---|:---:|---|---|
| F0-01 | Línea base íntegra | Sí | `pending` (apertura ejecutada; cierre pendiente) | A. Solo lectura | `F0-01_baseline_open_<UTC>.json` y `F0-01_baseline_close_<UTC>.json` |
| F0-02 | Credencial de solo lectura | Sí | `pending` | D. Permisos/seguridad | `F0-02_credential_pilot.json` y `F0-02_credential_isolated.json` |
| F0-03 | Prueba negativa de escritura (11 casos) | Sí | `blocked` (sin instancia aislada) | D. Permisos/seguridad | `F0-03_negative_writes.json` |
| F0-04 | Inmutabilidad de la configuración | Sí | `pending` (depende de F0-02-P) | D. Permisos/seguridad | `F0-04_admin_endpoints.json` |
| F0-05 | Superficie de lectura suficiente | Sí | `pending` (depende de F0-02-P y ticket desechable) | A. Solo lectura | `F0-05_api_surface.json` |
| F0-06 | La confirmación eleva `updated_at` | Sí | `blocked` (sin barrera técnica del piloto) | C. Correo piloto | `F0-06_touch.json` |
| F0-07 | Semántica de `close_at` | Sí | `pending` (tickets desechables y ventana) | B. Escritura local | `F0-07_close_at.json` |
| F0-08 | `pending close` no cierra | Sí | `pending` (tickets desechables y ventana) | B. Escritura local | `F0-08_pending_close.json` |
| F0-09 | `merged` no cierra | Sí | `pending` (tickets desechables y ventana) | B. Escritura local | `F0-09_merged.json` |
| F0-10 | Reproducción de las 30 filas | Sí | `passed` | Ya ejecutada (lectura) | `F0-10_matrix.json` |
| F0-11 | Reproducción del volumen fuera de catálogo | Sí | `passed` | Ya ejecutada (lectura) | `F0-11_out_of_catalog.json` |
| F0-11b | Categoría oficial | Sí | `passed` | Ya ejecutada (lectura) | `F0-11b_category_mapping.md` |
| F0-12 | Evento duplicado | Sí | `deferred` (sin harness/BFF) | E. Requiere BFF | `F0-12_duplicates.md` |
| F0-13 | Eventos fuera de orden | Sí | `deferred` (sin harness/BFF) | E. Requiere BFF | `F0-13_out_of_order.md` |
| F0-14 | Recuperación tras caída | Sí | `deferred` (sin harness/BFF) | E. Requiere BFF | `F0-14_recovery.md` |
| F0-15 | Ninguna escritura durante el sondeo | Sí | `blocked` (sin ventana exclusiva/evidencia) | A. Solo lectura condicionada | `F0-15_no_writes.json` |
| F0-16 | Sin datos personales almacenados | Sí | `deferred` (sin harness/BFF) | E. Requiere BFF | `F0-16_no_pii.md` |

**Total:** 17 pruebas: **3 `passed`**, **7 `pending`**, **3 `blocked`**, **4 `deferred`**.

**F0-01:** apertura ejecutada; cierre pendiente. Por eso figura `pending`.
**F0-02:** dos ejecuciones por ambiente (F0-02-P/F0-02-I), **no** dos pruebas lógicas.

**Nota:** F0-03 y F0-15 tienen condición de entorno. Su estado sigue siendo `Pendiente`, pero no se ejecutan sin instancia aislada (F0-03) o ventana exclusiva (F0-15).

**Trazabilidad F0-01:** el documento de criterios 5G.4.5 nombra `F0-01_baseline.json`. Esta versión conserva el ID F0-01 y desdobla la evidencia en apertura y cierre, sin sobrescribir.

**Trazabilidad F0-03:** el criterio 5G.4.5 «11/11 con 403» se refina en v1.2: 10/11 con 403 + caso 7 documentado (7a/7b), porque `UserPolicy#update?` permite al agente modificar clientes. No se modifica el documento fuente.

### 2.1 Separación de ambientes

| Ambiente | Pruebas | Credencial | Base | Regla |
|---|---|---|---|---|
| **Piloto** | F0-01, F0-02-P, F0-04, F0-05, F0-06, F0-07, F0-08, F0-09, F0-15 | F0-02-P (piloto) | `mailing_development` | No se usa para F0-03 |
| **Instancia aislada desechable** | F0-02-I, F0-03 | F0-02-I (pendiente de creación en la instancia) | Base independiente | No comparte token con el piloto |
| **Harness/BFF** | F0-12, F0-13, F0-14, F0-16 | Credencial del harness (pendiente) | Base del harness | No toca el piloto |
| **Histórico** | F0-10, F0-11, F0-11b | Solo lectura | COSE histórico | Ya ejecutadas |

**Reglas:**

1. No se comparten tokens entre ambientes.
2. Un resultado del piloto **no** demuestra el comportamiento de la instancia aislada.
3. F0-02 se ejecuta dos veces: piloto (F0-02-P) e instancia aislada (F0-02-I), con evidencia separada.
4. F0-03 usa **exclusivamente** la credencial de la instancia aislada.
5. La instancia aislada tiene base de datos independiente y no contiene datos reales.

---

## 3. Clasificación por tipo de prueba

| Tipo | Definición | Pruebas | Total |
|---|---|---|---:|
| **Ya ejecutadas** | Resultados de solo lectura documentados en 5G.4.5 | F0-01, F0-10, F0-11, F0-11b | 4 |
| **A. Solo lectura** | Lectura pura sobre Zammad; no escriben | F0-05, F0-15 | 2 |
| **B. Escritura local** | Cambian estado de tickets de prueba | F0-07, F0-08, F0-09 | 3 |
| **C. Correo piloto** | Crean ticket y envían correo real | F0-06 | 1 |
| **D. Permisos/seguridad** | Crean credencial o intentan escrituras | F0-02, F0-03, F0-04 | 3 |
| **E. Requiere BFF** | Necesitan la base de pruebas del BFF | F0-12, F0-13, F0-14, F0-16 | 4 |
| | | **Total** | **17** |

### 3.1 Nota sobre F0-15

F0-15 se clasifica como **A. Solo lectura** por su intención: 20 ciclos de sondeo no deben modificar nada. Sin embargo, **su resultado solo es válido en una ventana exclusiva y sin escrituras ajenas**. Si el worker está activo, genera historias y auditoría, y los contadores cambian aunque el sondeo sea correcto.

**Regla:** F0-15 se ejecuta en una **ventana independiente**, sin F0-06, F0-07, F0-08 ni F0-09 en paralelo, y con worker, scheduler, Gmail y Redis verificados. Si no puede garantizarse, se marca **`inconclusive`**, no **`failed`**.

### 3.2 Nota sobre F0-16

F0-16 es de solo lectura sobre la base del BFF, pero **no puede ejecutarse antes de que esa base exista**. Por eso se clasifica como E.

### 3.3 Alcance real de la credencial de integración

La credencial **no es de solo lectura universal**. Su alcance exacto es:

| Capacidad | ¿Permitida? | Fundamento |
|---|---|---|
| Leer tickets y artículos del grupo | **Sí** | `TicketPolicy#show?` → `access?('read')` |
| Leer usuarios | **Sí** | `UserPolicy#show?` permite agentes |
| Actualizar tickets | **No** | `update?` exige `change` |
| Crear artículos | **No** | `ArticlePolicy#create?` → `follow_up?` → `update?` |
| Crear o eliminar tickets | **No** | `create?` exige `create`; `destroy?` exige admin |
| Modificar configuración, triggers, webhooks o SLA | **No** | permisos administrativos |
| Modificar usuarios cliente | **Sí, por política de Zammad** | `UserPolicy#update?` permite a un agente actualizar clientes |

**Consecuencia:** la credencial es de solo lectura **para tickets, artículos y configuración**, pero conserva la capacidad nativa de un agente de editar usuarios cliente. Por eso:

1. El cliente HTTP del motor es `GET`-only.
2. F0-03 no asume aislamiento absoluto.
3. El caso 7 se rediseña para no tocar usuarios reales.
4. La validación de escrituras se hace en una instancia aislada o queda bloqueada.
5. La credencial del piloto (F0-02-P) **no** se usa en la instancia aislada.
6. La credencial de la instancia aislada (F0-02-I) **no** se usa en el piloto.
7. El BFF **no expone endpoints de escritura** ni llamadas a `/users`; el cliente del motor no implementa `POST`, `PUT`, `PATCH` ni `DELETE`.
8. La conclusión distingue **permisos nativos de Zammad** (lectura de tickets; edición de clientes) de las **restricciones del BFF** (GET-only, sin `/users`, sin escritura).

**Ninguna credencial existe todavía:** F0-02-P y F0-02-I están pendientes de creación y verificación.

---

## 4. Precondiciones, dependencias y riesgos

### 4.1 Precondiciones globales

| # | Precondición | Estado |
|---:|---|---|
| 1 | AP-01 validada definitivamente | `conditional_pending_final_validation` |
| 2 | AP-02 ratificada definitivamente | `conditional_pending_final_validation` |
| 3 | AP-03 validada definitivamente | `conditional_pending_final_validation` |
| 4 | DP-04 confirmada (Soporte) | **Cumplida** |
| 5 | DT-01 confirmada (BFF como fuente) | **Cumplida** |
| 6 | DT-02 confirmada (65 con marca; 7 excluidas) | **Cumplida** |
| 7 | Usuario técnico `read` y token | Pendiente |
| 8 | Buzón de prueba y ventana | Pendiente |
| 9 | Base de pruebas del BFF | Pendiente |
| 10 | Línea base F0-01 en la ventana | Pendiente |
| 11 | Sin sesiones concurrentes | **No cumplida** |
| 12 | Rollback por prueba | Pendiente |
| 13 | Gestor de secretos y cifrado de backups | Pendiente |

### 4.2 Precondiciones por prueba

| ID | Precondición específica | Dependencia | Riesgo | Control |
|---|---|---|---|---|
| F0-02 | Autorización para crear **dos** credenciales separadas: piloto (F0-02-P) e instancia aislada (F0-02-I) | AP-03, DEP-04 | Medio: identidad nueva con permisos mal configurados | Revisar `access='read'` y ausencia de `admin` en cada ambiente |
| F0-03 | F0-02-I aprobada; **instancia aislada con base independiente**; si no existe, bloqueada | F0-02-I | **Alto**: un `2xx` escribe de verdad y puede tener efectos secundarios no reversibles | Instancia aislada; contadores antes/después; aborto inmediato; incidente S1 |
| F0-04 | Credencial piloto F0-02-P | F0-02-P | Bajo | Solo lectura de endpoints administrativos |
| F0-05 | Credencial piloto F0-02-P; **ticket desechable declarado** | F0-02-P | Bajo | Solo lectura; no usar tickets operativos |
| F0-06 | Worker, Gmail y **barrera técnica del piloto**; destinatario allowlisted | DEP-05 | Medio: correo real a destinatario no autorizado | Allowlist; barrera técnica; verificación pre/post; aborto |
| F0-07 | **Ticket desechable declarado**; ventana | DEP-05 | Medio: cambios de estado | Ticket desechable; estado final documentado |
| F0-08 | **Ticket desechable declarado**; ventana | DEP-05 | Bajo | Reversible |
| F0-09 | **Dos tickets desechables declarados** | DEP-05 | **Medio-alto**: la fusión no se revierte | Solo tickets desechables |
| F0-12 | **Harness o base del BFF aislada**; decisión pendiente | DEP-06 | Bajo | No ejecutar antes de existir |
| F0-13 | **Harness o base del BFF aislada**; decisión pendiente | DEP-06 | Bajo | No ejecutar antes de existir |
| F0-14 | **Harness o base del BFF aislada**; proceso controlable | DEP-06 | Medio: matar un proceso de prueba | Entorno aislado |
| F0-15 | Credencial piloto F0-02-P o script de solo `GET`; **ventana exclusiva**; worker, scheduler, Gmail y Redis verificados | F0-02-P, DEP-05 | Medio: falsos fallos por actividad ajena | Ventana exclusiva; si no se garantiza, **`inconclusive`** |
| F0-16 | **Harness o base del BFF aislada** con datos de ejemplo | DEP-06 | Bajo | Inspección de esquema y muestra |

### 4.3 Riesgos específicos de Fase 0

| ID | Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|---|
| RF0-01 | La credencial tiene más permisos de los previstos | Media | Alto | Revisar rol, grupo y token antes de F0-03 |
| RF0-02 | Un `2xx` en F0-03 escribe datos | Media | Alto | Aborto inmediato y rollback |
| RF0-03 | El worker contamina F0-15 | Alta | Medio | Ventana sin worker o prueba `inconclusive` |
| RF0-04 | El correo de F0-06 llega a un destinatario no controlado | Baja | Alto | Destinatario de prueba declarado |
| RF0-05 | La fusión de F0-09 deja residuos | Media | Medio | Tickets desechables |
| RF0-06 | La base del BFF no está aislada | Baja | Medio | Instancia de prueba separada |
| RF0-07 | Se confunde evidencia con implementación | Media | Alto | Este paquete no ejecuta nada |
| RF0-08 | La ventana se solapa con otra sesión | Alta | Alto | Coordinación y bloqueo de sesiones |
| RF0-09 | La credencial puede modificar usuarios cliente por `UserPolicy#update?` | Alta | Alto | Caso 7 contra agente/admin; instancia aislada; cliente `GET`-only |
| RF0-10 | Un `2xx` en F0-03 deja efectos secundarios no reversibles | Media | Alto | Incidente S1; preservar evidencia; no asumir reversión total |
| RF0-11 | Una intervención en Redis destruye jobs o claves | Media | Alto | Prohibir `FLUSHDB`/`FLUSHALL`; solo inspección; procedimiento separado |
| RF0-12 | F0-06 envía a un destinatario no autorizado | Baja | Alto | Allowlist, barrera y verificación pre/post |
| RF0-13 | F0-12 a F0-16 se ejecutan sin harness o base | Media | Alto | Bloqueadas hasta decisión y existencia |
| RF0-14 | Se usan tickets operativos como tickets de prueba | Media | Alto | Registro de tickets desechables |

---

## 5. Evidencia requerida

### 5.1 Reglas de evidencia

1. Cada prueba produce los archivos indicados en §5.2; F0-01 produce **dos** (apertura y cierre).
2. El archivo incluye: fecha y hora UTC, ejecutor (rol), entorno, comandos o llamadas, resultado, códigos HTTP y contadores antes/después.
3. **No se crean archivos vacíos** para simular avance.
4. La evidencia de F0-02 y F0-03 **no incluye el token**.
5. La evidencia de F0-16 no incluye cuerpos, direcciones ni adjuntos.
6. Un archivo de evidencia no se reescribe: si se repite la prueba, se agrega una versión con fecha.

### 5.2 Contenido mínimo por prueba

| ID | Contenido mínimo |
|---|---|
| F0-01 | Dos archivos: apertura y cierre, cada uno con contadores completos, hora UTC y comparación |
| F0-02 | Dos archivos (piloto y aislada): usuario, grupo, `access`, permisos, resultado de `GET /tickets`; token redactado |
| F0-03 | Tabla de 11 llamadas con método, endpoint, recurso, efecto posible, código y cuerpo; resumen 10×403 + 7a/7b; si hay un `2xx` inesperado, acta de incidente S1 |
| F0-04 | 3 endpoints administrativos con código |
| F0-05 | 11 campos con presencia y valor de ejemplo |
| F0-06 | Destinatario allowlisted verificado; marcas `ticket.updated_at` y `article.delivery_status_date`; diferencia; nota «aceptación SMTP ≠ entrega» |
| F0-07 | `close_at` y `last_close_at` antes, tras reabrir y tras segundo cierre |
| F0-08 | Estado, `pending_time`, `close_at` |
| F0-09 | Estado, tipo, `close_at` |
| F0-10 | 30 filas, sumas 2.109 / 2.087 / 22 |
| F0-11 | 3.125 / 2.109 / 1.016 y distribución |
| F0-11b | 10 filas divergentes con categoría oficial |
| F0-12 | 100 inserciones, filas resultantes, transiciones |
| F0-13 | Estado final en orden normal e inverso |
| F0-14 | Run interrumpido, watermark, recuperación, duplicados |
| F0-15 | Cuatro señales con limitaciones (§9.7.1), mecanismos complementarios de PostgreSQL, procesos/scheduler/canal y Redis sin payloads; si no hay evidencia suficiente, `inconclusive` |
| F0-16 | Esquema y muestra sin PII; error truncado |

### 5.3 Registro de tickets de prueba (H-07)

No se usan tickets operativos. Cada ticket de prueba se declara antes de la ventana:

| Campo | Regla |
|---|---|
| Identificación | Asunto con prefijo `[F0-TEST]` y número de ticket |
| Grupo | `Soporte Especializado` |
| Cliente | Dirección de prueba allowlisted |
| Estado inicial | Documentado antes de la prueba |
| Pruebas | F0-05, F0-06, F0-07, F0-08 o F0-09 |
| Efecto esperado | Documentado |
| Reversión | Documentada; no probada salvo evidencia |
| Estado | `No creado` hasta la ventana |

**Regla:** un ticket sin registro no se usa. Un ticket operativo no se toca. No se modifica ningún ticket en esta tarea.

---

## 6. Criterios de aprobación, rechazo y aborto

### 6.1 Aprobación

| Nivel | Criterio |
|---|---|
| Por prueba | Resultado esperado cumplido y evidencia completa |
| F0-03 | Casos 1-6 y 8-11: **403**; caso 7: **200** contra cliente desechable y **403** contra agente/admin; ningún `2xx` inesperado; solo instancia aislada |
| F0-06 | `ticket.updated_at` posterior a `delivery_status_date`; diferencia < 5 s entre ambas marcas UTC; no se compara con `created_at` del artículo |
| F0-07 | `close_at` idéntico; `last_close_at` distinto |
| F0-15 | Cuatro contadores idénticos; worker, scheduler, Gmail y Redis en estado declarado; ventana exclusiva |
| Global | **3 `passed`** + **F0-01 cierre** + **6/6** sin condición especial (F0-02, F0-04, F0-05, F0-07, F0-08, F0-09) + **F0-03/F0-06/F0-15** condicionales + **4 `deferred`**. No se declara 17/17 antes de construir |

### 6.2 Rechazo

Una prueba se rechaza si:

1. no cumple el resultado esperado;
2. la evidencia está incompleta o no permite reproducir el resultado;
3. se ejecutó fuera de la ventana o con el worker en estado no declarado;
4. se modificó un contador no declarado;
5. se usó un destinatario o ticket no declarado;
6. no se garantizó la instancia aislada para F0-03;
7. no se verificó el destinatario allowlisted en F0-06;
8. la ventana de F0-15 no fue exclusiva.

### 6.3 Aborto inmediato

Se detiene la Fase 0 si:

- una llamada de escritura devuelve un `2xx` inesperado (distinto del 7a permitido);
- un contador cambia sin estar declarado;
- el ticket o artículo canario cambia;
- se detecta una sesión concurrente;
- el worker o el correo están en un estado distinto del acordado;
- el destinatario no está en la allowlist;
- se detecta una intervención en Redis no autorizada;
- la ventana de F0-15 se contamina con otra prueba;
- aparece un dato personal en la evidencia.

**Regla:** un fallo bloqueante no se mitiga. Se rediseña la parte afectada y se vuelve a probar.

### 6.4 Severidad de defectos

| Severidad | Definición | Efecto |
|---|---|---|
| S1 | Bloquea una compuerta o produce dato incorrecto | Detiene la Fase 0 |
| S2 | Afecta una regla sin bloquear toda la fase | Se corrige antes del cierre |
| S3 | Defecto menor de evidencia o formato | Se corrige antes de la aceptación |
| S4 | Mejora o deuda documentada | Se registra |

### 6.5 Incidente S1 por `2xx` en F0-03

Un `2xx` inesperado en F0-03 es **incidente S1**:

1. Se detiene la prueba.
2. Se preserva la evidencia (código, cuerpo, marca de tiempo).
3. **No se asume** que eliminar el objeto revierte todos los efectos: puede haber historias, auditoría, notificaciones, correos, cachés o efectos externos.
4. Se registra el incidente y se decide la contención con autorización.
5. No se reanuda hasta corregir la causa.

### 6.6 F0-03: criterios individuales de los 11 intentos

**Regla de ambiente:** F0-03 se ejecuta **exclusivamente** en una instancia Zammad aislada y desechable, con base de datos independiente y credencial **a crear** en esa misma instancia (F0-02-I). **No se ejecuta parcialmente en el piloto.** Si la instancia no existe, F0-03 queda **bloqueada**.

| # | Método y endpoint | Recurso | Política esperada | HTTP esperado | Efecto posible si `2xx` | Aislamiento |
|---:|---|---|---|---|---|---|
| 1 | `PATCH /api/v1/tickets/{id}` | Ticket | `TicketPolicy#update?` → `change_access?` → `change` | **403** | Modifica el título | Instancia aislada; ticket desechable |
| 2 | `POST /api/v1/ticket_articles` | Artículo | `ArticlePolicy#create?` → `follow_up?` → `update?` → `change` | **403** | Crea una nota | Aislada; ticket desechable |
| 3 | `POST /api/v1/tickets` | Ticket | `TicketPolicy#create?` → `access?('create')` | **403** | Crea un ticket | Aislada |
| 4 | `DELETE /api/v1/tickets/{id}` | Ticket | `TicketPolicy#destroy?` → admin | **403** | Elimina el ticket | Aislada; ticket desechable |
| 5 | `PUT /api/v1/tickets/{id}` | Ticket | `update?` → `change` | **403** | Actualiza el ticket | Aislada; ticket desechable |
| 6 | `POST /api/v1/users` | Usuario | `UserPolicy` create (admin.user) | **403** | Crea un usuario | Aislada |
| 7 | `PUT /api/v1/users/{id}` | Usuario | `UserPolicy#update?` | **7a: 200** si el objetivo es un cliente desechable; **7b: 403** si es agente/admin | Modifica el usuario | Aislada; usuario desechable; **nunca real** |
| 8 | `PUT /api/v1/settings/{key}` | Configuración | `SettingPolicy#update?` → permiso requerido | **403** | Cambia un ajuste global | Aislada |
| 9 | `POST /api/v1/triggers` | Trigger | admin | **403** | Crea una automatización | Aislada |
| 10 | `POST /api/v1/webhooks` | Webhook | admin | **403** | Crea una salida de datos | Aislada |
| 11 | `POST /api/v1/slas` | SLA nativo | `SlaPolicy` → admin.sla | **403** | Crea un SLA nativo | Aislada |

**No se afirma que los 11 intentos tengan el mismo resultado esperado.** El caso 7 es el único con dos resultados posibles según el recurso.

#### 6.6.1 Interpretación de códigos

| Código | Significado | Acción |
|---|---|---|
| **401** | Token ausente, inválido o expirado | No prueba autorización; repetir con token válido. No cuenta como 403 |
| **403** | Autenticado y sin permiso | Resultado esperado en 10 de los 11 casos (1-6, 8-11) |
| **2xx** | La escritura se ejecutó | Incidente S1; detener; preservar evidencia; no asumir reversión |

#### 6.6.2 Caso 7: capacidad permitida por Zammad frente a capacidad que el BFF debe bloquear

`UserPolicy#update?` permite a un agente actualizar **usuarios cliente**. Por tanto:

- **7a:** `PUT /users/{id}` contra un **cliente desechable** de la instancia aislada → **200 esperado**. Es una **capacidad legítima de Zammad**, no un fallo de la credencial.
- **7b:** `PUT /users/{id}` contra un **agente/admin desechable** → **403 esperado**.
- El BFF **debe bloquear** el endpoint de usuarios por diseño: cliente `GET`-only y sin llamadas a `/users`. El cliente del motor no implementa `POST`, `PUT`, `PATCH` ni `DELETE`.
- No se usan usuarios reales. El usuario desechable se crea en la instancia aislada y se elimina al cerrar.

**Regla:** F0-03 no se ejecuta en el piloto. Si no hay instancia aislada, queda bloqueada. No se ejecuta en esta tarea.

---

## 7. Procedimiento de reversión

### 7.1 Principios

1. Toda escritura de prueba se revierte o se declara.
2. Se registran los contadores antes y después.
3. No se elimina evidencia: se documenta el estado final.
4. Una fusión no se revierte: se usan tickets desechables.
5. Un correo enviado no se puede recuperar: se usa un destinatario controlado.
6. Se distingue **reversión documentada**, **técnicamente posible** y **efectivamente probada**. Sin evidencia, no se declara probada.
7. Un `2xx` en F0-03 es incidente S1; eliminar el objeto no garantiza revertir todos los efectos.

### 7.2 Reversión por prueba

| ID | Efecto | Reversión documentada | Técnicamente posible | Probada | Verificación |
|---|---|---|---|---|---|
| F0-02 | Crea usuario técnico y token | Eliminar usuario y token con autorización de administrador | Sí | **No** | `users` y `tokens` vuelven al valor inicial |
| F0-03 | Intenta 11 escrituras; si hay `2xx`, escribe | Eliminar el objeto creado; registrar incidente S1 | **Parcial**: no garantiza revertir efectos secundarios | **No** | Contadores idénticos; canario intacto; acta S1 |
| F0-04 | Ninguno (solo lectura) | No aplica | Sí | **No** | — |
| F0-05 | Ninguno (solo lectura) | No aplica | Sí | **No** | — |
| F0-06 | Crea ticket y envía correo | El ticket queda declarado; el correo no se recupera | **Parcial** | **No** | Ticket y destinatario declarados |
| F0-07 | Cierra, reabre y vuelve a cerrar | Documentar estado final; el ticket queda como prueba | Sí | **No** | `close_at` del primer cierre intacto |
| F0-08 | Lleva a `pending close` | Restaurar el estado anterior | Sí | **No** | `close_at` vacío |
| F0-09 | Fusiona dos tickets | **No reversible**: usar tickets desechables | **No** | **No** | Par fusionado declarado |
| F0-12 | Escribe en la base del BFF | Truncar o recrear la base de prueba | Sí, con autorización | **No** | Base aislada |
| F0-13 | Escribe en la base del BFF | Truncar o recrear la base de prueba | Sí, con autorización | **No** | Base aislada |
| F0-14 | Interrumpe un run del BFF | Recrear la base de prueba | Sí, con autorización | **No** | Sin duplicados ni pérdida |
| F0-15 | Ninguno (solo lectura) | No aplica | Sí | **No** | Cuatro contadores idénticos |
| F0-16 | Ninguno (solo lectura del BFF) | No aplica | Sí | **No** | — |

### 7.3 Verificación de reversión

Al cerrar cada prueba se verifica:

- contadores de §5.2;
- canario de ticket y artículo;
- ausencia de objetos no declarados;
- estado del worker y del correo.

### 7.4 Límites de la reversión

**Ninguna reversión de este paquete ha sido probada.** Todas son **documentadas** y, como máximo, **técnicamente posibles**. La prueba de reversión requiere evidencia propia y no se deduce de la documentación.

En F0-03, un `2xx` puede crear un ticket, un artículo, un usuario, un trigger, un webhook o un SLA. Eliminar el objeto no revierte necesariamente historias, auditoría, notificaciones, correos, cachés o efectos externos. Por eso el incidente es **S1** y se contiene con autorización.

---

## 8. Secuencia de ejecución

### 8.1 Orden propuesto

| Fase | Pruebas | Precondición | Paralelizable |
|---|---|---|---|
| **P0** | F0-01 apertura (piloto) | Ventana iniciada | No |
| **P1** | F0-02-P → F0-04 → F0-05 (piloto) | Credencial piloto; ticket desechable | No: secuencial |
| **P2** | F0-02-I → F0-03 (instancia aislada) | Credencial **pendiente de creación** en la instancia; base independiente | No: secuencial |
| **P3** | F0-07 → F0-08 → F0-09 (piloto) | Tickets desechables; ventana | No: secuencial |
| **P4** | F0-06 (piloto) | Worker, Gmail y **barrera técnica del canal del piloto** | No: ventana exclusiva de correo |
| **P5** | F0-15 (piloto) | Ventana exclusiva; evidencia §9.7.1 | No: ventana exclusiva |
| **P6** | F0-12 → F0-13 → F0-14 → F0-16 (BFF) | Harness/BFF aislado | **No: secuencial por defecto** |
| **P7** | F0-01 cierre y consolidación (piloto) | Todas las anteriores | No |

### 8.2 Camino crítico

```
AP-03 → DEP-04 → F0-02 (P e I) → F0-03 → 6/6 + F0-01 cierre + F0-06/F0-15 condicionales → 4 diferidas
```

**Por qué:** sin autorización no hay credencial; sin credencial no hay prueba de seguridad; sin F0-03 aprobada no se puede afirmar que la integración es de solo lectura **para tickets, artículos y configuración**. Las 4 pruebas que requieren harness/BFF no forman parte del cierre inmediato. La conclusión distingue **permisos nativos de Zammad** (lectura de tickets; edición de clientes) de las **restricciones del BFF** (GET-only, sin `/users`, sin escritura).

### 8.3 Reglas de orden

- F0-03 **no** se ejecuta antes de F0-02-I ni fuera de una instancia aislada.
- F0-02-P y F0-02-I son credenciales separadas; no se comparten tokens.
- F0-12 a F0-16 **no** se ejecutan antes del harness/BFF.
- F0-15 **no** se ejecuta en paralelo con F0-06, F0-07, F0-08 ni F0-09.
- F0-15 exige ventana exclusiva y evidencia de §9.7.1.
- F0-06 **sí** requiere worker, Gmail y **barrera técnica del piloto**.
- F0-01 tiene apertura y cierre en archivos separados.

### 8.4 Bloques que pueden avanzar en paralelo

| Bloque | Pruebas | Condición |
|---|---|---|
| A | F0-12, F0-13, F0-14 y F0-16 | **Secuencial por defecto**; paralelo solo con aislamiento independiente demostrado |

**Regla:** ninguna prueba de Zammad se ejecuta en paralelo con otra. F0-15 es una ventana exclusiva y no comparte franja con F0-06, F0-07, F0-08 ni F0-09.

### 8.5 Incompatibilidades

| Prueba | Incompatible con | Motivo |
|---|---|---|
| F0-15 | F0-02, F0-03, F0-06, F0-07, F0-08, F0-09 | Escrituras o actividad de worker/correo alteran los contadores |
| F0-03 | Cualquier otra prueba de escritura | Un `2xx` escribe datos reales |
| F0-06 | F0-15 y cualquier prueba que use el mismo buzón | Correo y worker alteran el entorno |
| F0-07, F0-08, F0-09 | Entre sí, si comparten ticket | Cambios de estado incompatibles |
| F0-12 a F0-16 | F0-15 | La ventana de F0-15 es exclusiva |
| F0-12 a F0-16 | Entre sí, salvo aislamiento demostrado | Bases, datos, procesos o recursos compartidos |

### 8.6 Paralelismo de las pruebas BFF

Por defecto, F0-12, F0-13, F0-14 y F0-16 se ejecutan **en secuencia**.

El paralelismo solo se permite si se demuestra aislamiento independiente de:

1. bases de datos;
2. datos;
3. procesos;
4. recursos compartidos (CPU, memoria, conexiones, colas).

Sin esa demostración, no se afirma que las cuatro puedan ejecutarse en paralelo.

---

## 9. Dependencias específicas de infraestructura

### 9.1 Worker

| Aspecto | Detalle |
|---|---|
| Rol | Procesa jobs, schedulers, notificaciones y correo |
| Estado actual | **Activo al momento del snapshot** (iniciado ~20:50 UTC) |
| Efecto en Fase 0 | Escribe `histories` y `audit_logs`; puede enviar notificaciones |
| F0-06 | **Requiere worker activo** |
| F0-15 | **Requiere verificación de inactividad**; no se detiene ni reinicia en esta tarea |
| Riesgo | Contaminar contadores y producir falsos fallos |
| Control | Declarar el estado por prueba; verificar procesos y contadores; no iniciar ni detener en esta tarea |

### 9.2 Scheduler de correo

| Aspecto | Detalle |
|---|---|
| Scheduler | «Check channels.» |
| Periodo | **30 segundos** |
| Estado | Activo al momento del snapshot (30/30 schedulers activos) |
| Efecto | Consulta el canal Gmail y crea tickets/artículos |
| F0-06 | Necesario para recibir y enviar |
| F0-15 | Debe estar inactivo o sin correo pendiente; verificar último fetch y cola |
| Control | Ventana sin correo; verificar cola y último fetch sin alterar nada |

### 9.3 Canal Gmail

| Aspecto | Detalle |
|---|---|
| Canal | `Google::Account` ID 4, activo |
| Cuenta | `vcastagnino@restaurant.pe` (piloto) |
| Entrada | IMAP XOAUTH2, `INBOX`, `keep_on_server = true` |
| Salida | SMTP `smtp.gmail.com:465`, XOAUTH2 |
| Token | `expires_in = 3599 s`; refresh token presente |
| Grupo | `Soporte Especializado` (ID 3) |
| Riesgo | Enviar correo real a un destinatario no controlado |
| Control | Destinatario allowlisted; asunto identificable |
| Destinatario | **Allowlist expresa**; cualquier otra dirección aborta |
| Validación operativa | Verificación pre-envío del campo `to` y post-envío del artículo |
| Barrera técnica | Relay o sink con allowlist de `RCPT TO` (ver §9.3.2) |
| Entrega | `delivery_status=success` = aceptación SMTP, **no** entrega en buzón |

#### 9.3.1 Blindaje de F0-06

1. **Destinatario:** una sola dirección de prueba, declarada en el acta de ventana y en la allowlist.
2. **Verificación pre-envío:** el ticket de prueba debe tener como cliente esa dirección; se comprueba el campo `to` del artículo y el `email_address_id` del canal antes de enviar.
3. **Validación operativa:** si la dirección no está en la allowlist, se aborta y **no se envía**.
4. **Verificación post-envío:** se comprueba que el artículo tiene `to` = allowlisted y `delivery_status = success`.
5. **Alcance de `success`:** significa que el servidor SMTP **aceptó** el mensaje; **no** prueba entrega en el buzón ni lectura.
6. **Marcas comparadas:** `ticket.updated_at` (después del touch) y `article.preferences.delivery_status_date`, ambas en UTC. La diferencia debe ser **< 5 s**. No se compara con `article.created_at`.
7. Si no se puede verificar el destinatario, no se envía.

**Esto es validación operativa, no una barrera técnica.** La comprobación pre/post del campo `to` no impide por sí sola que el SMTP envíe a otra dirección.

#### 9.3.2 Barrera técnica de salida

| Opción | Mecanismo | Efecto | ¿Aceptable? |
|---|---|---|---|
| A | Relay o sink SMTP con allowlist de `RCPT TO` | Rechaza destinatarios no permitidos | **Sí, preferida** |
| B | Servidor de correo con restricciones de destinatario | Rechaza o desvía | Sí |
| C | Firewall de egreso al relay de prueba | Solo permite el relay | Sí, complementaria |
| D | Canal de la instancia aislada apuntando al relay | Configuración de la instancia de prueba | **Solo si F0-06 se traslada formalmente al ambiente aislado; no protege el Gmail del piloto** |

**Requisito:** F0-06 solo se ejecuta si existe una **restricción efectiva de salida**. Si la instancia no la tiene, F0-06 queda **bloqueada**, no se envía correo y no se declara aprobada.

`delivery_status=success` sigue significando **aceptación SMTP**, no entrega en buzón.

#### 9.3.3 Alcance de la barrera por ambiente

F0-06 está definida para el **piloto**. Por tanto, la barrera técnica debe aplicarse al **canal del piloto** (Gmail): relay o sink con allowlist, regla de correo o firewall de egreso.

La opción de canal aislado **no** justifica F0-06 en el piloto: un relay de la instancia aislada no protege el Gmail del piloto. Solo se acepta si F0-06 se traslada formalmente al ambiente aislado y se actualizan §2.1, §8.1, §11.4, dependencias y aprobaciones.

Sin barrera técnica efectiva para el ambiente elegido, F0-06 permanece **bloqueada**.

### 9.4 PostgreSQL

| Aspecto | Detalle |
|---|---|
| Motor | PostgreSQL 16.15 local |
| Base | `mailing_development` |
| Uso en Fase 0 | Consultas `SELECT` para contadores y verificación |
| Prohibición | Sin DDL, sin DML, sin migraciones, sin `FOR UPDATE` |
| Riesgo | Una consulta mal escrita altera datos |
| Control | Scripts de solo lectura revisados; contadores antes/después |

### 9.5 Redis

| Aspecto | Detalle |
|---|---|
| Motor | Redis 7.0.15 |
| Uso | Colas del worker |
| Estado | `dbsize` observado en el snapshot; **no** es prueba de ausencia de escrituras |
| Riesgo | Jobs pendientes que se procesan durante la ventana |
| Control | **Solo inspección**; prohibido `FLUSHDB`, `FLUSHALL` y borrado masivo |

#### 9.5.1 Prohibiciones y inspección

Prohibido:

- `FLUSHDB`
- `FLUSHALL`
- eliminación masiva de jobs
- eliminación indiscriminada de claves

Inspección permitida, sin alterar contenido:

- `redis-cli info` (versión, clientes, estadísticas)
- `redis-cli dbsize` (solo indicador; **no** prueba de ausencia de escrituras)
- `redis-cli --scan --pattern 'queue:*'` con límite
- `redis-cli llen <cola>`

**Prohibido `LRANGE` sobre colas reales:** puede exponer payloads, correos, identificadores o datos personales. Si se necesita, solo en una cola de prueba con jobs sintéticos y con redacción.

**Regla:** cualquier intervención en Redis requiere procedimiento separado y autorización expresa.

### 9.6 Base de pruebas del BFF

| Aspecto | Detalle |
|---|---|
| Uso | F0-12, F0-13, F0-14, F0-16 |
| Estado | **No existe** |
| Opciones | A) harness temporal aislado; B) base independiente; C) traslado a etapa posterior |
| Decisión | **Pendiente**; no se construye en esta tarea |
| Requisito | Instancia aislada, sin datos reales, recreable |
| Riesgo | Mezclar datos de prueba con datos del motor |
| Control | Base separada; truncar o recrear al cerrar, con autorización |

### 9.7 Regla de la ventana

La ventana se declara por escrito e incluye:

1. hora de inicio y fin en UTC;
2. estado del worker por prueba;
3. estado del scheduler y del canal;
4. tickets de prueba;
5. destinatario allowlisted;
6. contadores de apertura;
7. rollback;
8. responsable de detener la ejecución (rol);
9. **ventana exclusiva de F0-15**, separada de F0-06, F0-07, F0-08 y F0-09;
10. verificación de que worker, scheduler, Gmail y Redis no generan escrituras ajenas.

**Regla:** si la verificación del punto 10 no se cumple, F0-15 se marca **`inconclusive`**.

#### 9.7.1 Evidencia de ventana silenciosa (F0-15)

**Contadores nominales:**

1. `max(tickets.updated_at)`
2. `count(audit_logs)` y `max(audit_logs.id)`
3. `count(histories)` y `max(histories.id)`
4. `count(ticket_articles)`

**Limitaciones de las cuatro señales:**

- `max(tickets.updated_at)` detecta toques de ticket; **no** detecta cambios en artículos.
- `count(audit_logs)` + `max(id)` detecta inserciones; **no** detecta necesariamente actualizaciones o eliminaciones de filas existentes.
- `count(histories)` + `max(id)` tiene la misma limitación.
- `count(ticket_articles)` detecta inserciones/eliminaciones por conteo; **no** detecta actualizaciones que no cambian el total.

**Mecanismos complementarios (documentales; no se ejecutan en esta tarea):**

| Mecanismo | Detecta | No detecta | Ámbito | Limitaciones | Evidencia |
|---|---|---|---|---|---|
| `pg_stat_user_tables` (`n_tup_ins`, `n_tup_upd`, `n_tup_del`, `n_live_tup`, `n_dead_tup`) | Inserciones, actualizaciones y eliminaciones por tabla | Identidad de fila; autor; actividad entre snapshots | Por tabla | Acumulativo; el colector puede tener retraso; requiere before/after | Snapshot por tabla |
| `pg_stat_database` (`xact_commit`, `tup_inserted`, `tup_updated`, `tup_deleted`) | Actividad de escritura global | Tabla, fila y autor | Global | Acumulativo; incluye todas las sesiones | Snapshot global |
| `pg_stat_statements` (si está instalado) | Sentencias de escritura por texto | Filas afectadas exactas; si no está instalado | Global | Requiere extensión; puede estar deshabilitado | Conteo de sentencias |
| `pg_stat_wal` (`wal_records`, `wal_fpi`, `wal_bytes`) | Actividad WAL global | Tabla, fila y origen | Global (clúster) | Incluye toda la actividad; no identifica origen | Snapshot WAL |
| `pg_stat_activity` (`state`, `query`) | Consultas de escritura activas en el instante | Actividad histórica | Global | Muestreo; no prueba ausencia | Muestra de actividad |

**Detección de escrituras concurrentes:**

- Comparar los cuatro contadores y las estadísticas complementarias antes y después; cualquier diferencia = `inconclusive`.
- `max(id)` detecta inserciones aunque el conteo se altere.
- `max(tickets.updated_at)` detecta toques de ticket.
- `DBSIZE` **no** es prueba suficiente.

**Verificación de inactividad:**

- `pgrep -af 'background-worker|sidekiq|script/rails server|websocket-server'` (sin detener).
- `schedulers.last_run` y `next_run` de «Check channels.» (solo lectura).
- `channels.last_log_in` y `last_log_out` del canal 4 (solo lectura).
- `redis-cli info` y `LLEN` por cola; **sin** `LRANGE` sobre colas reales.
- Declaración de ausencia de otras sesiones.

**Evidencia:** `F0-15_no_writes.json` con hora UTC, contadores, estadísticas complementarias, procesos, scheduler, canal, resumen de Redis sin payloads y declaración de ventana.

**Conclusión:** ninguna señal individual prueba ausencia absoluta de escrituras. La combinación de contadores, estadísticas de PostgreSQL, inactividad de procesos y ausencia de sesiones concurrentes es la evidencia máxima. Si falta o no converge, F0-15 es `inconclusive`.

---

## 10. Checklist para autorización final

> **Estados:** las pruebas usan `pending`, `blocked`, `deferred`, `passed`, `failed`, `inconclusive`. El checklist usa `Pendiente`, `Cumplida` y `No cumplida` para **precondiciones**, no para pruebas.

| # | Ítem | Estado | Evidencia |
|---:|---|---|---|
| 1 | AP-01 validada definitivamente | `conditional_pending_final_validation` | Validación expresa |
| 2 | AP-02 ratificada definitivamente | `conditional_pending_final_validation` | Validación expresa |
| 3 | AP-03 validada definitivamente | `conditional_pending_final_validation` | Validación expresa |
| 4 | DP-04 confirmada (Soporte) | **Cumplida** | Registro de decisión |
| 5 | DT-01 confirmada (BFF) | **Cumplida** | Registro de decisión |
| 6 | DT-02 confirmada (65 con marca; 7 excluidas) | **Cumplida** | Registro de decisión |
| 7 | **Credencial piloto F0-02-P** | Pendiente | `F0-02_credential_pilot.json` |
| 8 | **Credencial aislada F0-02-I** | Pendiente | `F0-02_credential_isolated.json` |
| 9 | **Instancia aislada con base independiente** | Pendiente | Acta de entorno |
| 10 | **Usuario desechable en la instancia aislada (caso 7)** | Pendiente | Registro de usuario |
| 11 | Buzón de prueba y ventana | Pendiente | Acta de ventana |
| 12 | **Ventana exclusiva para F0-15** | Pendiente | Acta de ventana |
| 13 | **Evidencia de ventana silenciosa (§9.7.1)** | Pendiente | `F0-15_no_writes.json` |
| 14 | **Procedimiento Redis aprobado** (sin `FLUSH*`) | Pendiente | Procedimiento separado |
| 15 | **Allowlist y barrera técnica del piloto F0-06** | Pendiente | Acta de relay del piloto |
| 16 | **Decisión harness/BFF** (A/B/C) | Pendiente | Registro de decisión |
| 17 | **Registro de tickets desechables** | Pendiente | §5.3 |
| 18 | **F0-01 apertura y cierre separados** | Pendiente | Dos archivos |
| 19 | **Reversión documentada / posible / probada** | Documentada; probada: **no** | §7 |
| 20 | Base o harness del BFF | Pendiente | Instancia aislada |
| 21 | Sin sesiones concurrentes | **No cumplida** | Coordinación |
| 22 | Gestor de secretos y cifrado de backups | Pendiente | Aprobación de TI |
| 23 | Plantillas de evidencia | **Cumplida** | §5 |
| 24 | Autorización expresa de ejecución | **Pendiente** | Validación final |

### 10.1 Bloque de autorización

| Rol | Qué autoriza | Estado |
|---|---|---|
| Responsable de negocio | AP-01, AP-02, AP-03 | `conditional_pending_final_validation` |
| Dirección | AP-01, AP-02, DP-04 | `conditional_pending_final_validation` / DP-04 cumplida |
| TI | Ventana, secretos, backups, procedimiento Redis y **barrera técnica del piloto** | Pendiente |
| Administrador de Zammad | Credenciales piloto y aislada, e instancia aislada | Pendiente |
| Dueño del catálogo (Soporte) | Catálogo y tratamiento de las 7 | **Confirmado** |

**Regla:** Fase 0 **no se ejecuta** hasta que los 24 ítems estén en `Aprobada` o `Validada` y exista autorización expresa. Una reversión documentada no cuenta como probada.

---

## 11. Estado de las pruebas: listas y bloqueadas

### 11.1 Listas para revisión

Las **17 pruebas** están documentadas y listas para revisión. Este paquete no las ejecuta.

### 11.2 Piloto (Zammad actual)

| Prueba | Motivo |
|---|---|
| F0-02-P | Credencial piloto **pendiente de creación y verificación** |
| F0-04 | Inmutabilidad de configuración; **depende de F0-02-P y de sus demás precondiciones** |
| F0-05 | Superficie de lectura; **depende de F0-02-P y de ticket desechable** |

**Ninguna prueba de este bloque está lista para ejecutar mientras sus precondiciones no estén cumplidas.**

**F0-15** se ejecuta en ventana exclusiva (P5) con la credencial piloto y no en paralelo con F0-06, F0-07, F0-08 ni F0-09.

### 11.3 Instancia aislada desechable

| Prueba | Motivo |
|---|---|
| F0-02-I | Credencial **pendiente de creación** en la instancia aislada |
| F0-03 | 11 intentos; solo en la instancia aislada; si no existe, bloqueada |

**Regla:** la credencial F0-02-I no se usa en el piloto; la F0-02-P no se usa en la instancia aislada.

### 11.4 Piloto, tras DEP-05 (correo y estado)

| Prueba | Motivo |
|---|---|
| F0-06 | Correo, worker, allowlist y **barrera técnica del piloto** |
| F0-07 | Cierre y reapertura |
| F0-08 | `pending close` |
| F0-09 | `merged` |

**Secuencia:** F0-07 → F0-08 → F0-09; F0-06 en ventana separada.

### 11.5 Diferidas por harness/BFF (DEP-06)

| Prueba | Motivo |
|---|---|
| F0-12 | Harness/BFF; decisión pendiente |
| F0-13 | Harness/BFF; decisión pendiente |
| F0-14 | Harness/BFF; decisión pendiente |
| F0-16 | Harness/BFF; decisión pendiente |

**Orden:** secuencial por defecto; no se ejecutan en paralelo sin aislamiento demostrado.

### 11.6 Con evidencia de lectura

| Prueba | Estado | Resultado |
|---|---|---|
| F0-01 | `pending` | Apertura registrada; cierre pendiente |
| F0-10 | `passed` | 30/30 filas; 2.109 / 2.087 / 22 |
| F0-11 | `passed` | 3.125 / 2.109 / 1.016 (32,51 %) |
| F0-11b | `passed` | 10 filas divergentes documentadas |

### 11.7 Pruebas ejecutadas en esta sesión

**Ninguna.** Este paquete es de revisión y autorización.

---

## 12. Confirmación

Este paquete se actualizó a v1.3 leyendo el documento maestro, el tablero, el análisis de bloqueantes y los criterios de Fase 0.

- No se modificó código.
- No se modificó la base de datos.
- No se modificó Redis.
- No se modificó la configuración.
- No se modificaron atributos, catálogo, permisos, usuarios ni credenciales.
- No se modificaron Gmail ni sus credenciales.
- No se crearon usuarios, tokens, instancias ni relays.
- No se crearon tablas ni se ejecutaron migraciones.
- No se iniciaron ni detuvieron servicios, schedulers o workers.
- No se enviaron correos.
- No se ejecutaron pruebas de escritura.
- No se tocó Zendesk, COSE ni la base empresarial.
- No se modificó el proyecto fuente de Windows.

La única escritura de esta sesión es documental: este paquete y la actualización de los documentos de seguimiento de EPIC-SLA-01.

**Fase 0 no se ejecutó.** El paquete queda listo para cuarta revisión. **No se autoriza ni se ejecuta Fase 0.**

---

## 13. Control de versiones

| Versión | Fecha | Cambio | Estado |
|---|---|---|---|
| 1.0 | 16/11/2026 | Creación del paquete de autorización de Fase 0 | Vigente |
| 1.1 | 16/11/2026 | Auditoría correctiva H-01 a H-10: F0-03, F0-15, Redis, F0-06, F0-01, BFF, tickets, reversión, concurrencia y checklist | Vigente |
| 1.2 | 17/11/2026 | Tercera revisión H-11 a H-15: F0-03 solo en instancia aislada, criterios individuales, barrera técnica F0-06, evidencia F0-15 y separación de ambientes | Vigente |
| 1.3 | 17/11/2026 | Cuarta revisión H-16 a H-20: F0-02-P pendiente, limitaciones de F0-15, alcance de la credencial, barrera del piloto y secuencialidad BFF | Vigente |

**Fin del paquete de autorización de Fase 0.**

