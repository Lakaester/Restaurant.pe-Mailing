# CIERRE TÉCNICO DEL BACKEND SLA — EPIC-SLA-01

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Repositorio auditado:** `/home/acast/mailing`, rama `main`, HEAD `80e0f313`
**Fecha de la auditoría:** 17/11/2026
**Estado de cierre:** **BLOQUEADO**
**Diseño del esquema:** revisado y consolidado el 17/11/2026 (§12). No aplicado.

---

## 1. Resultado general

**Estado: BLOQUEADO.** No se implementó el backend SLA. La razón no es de ejecución sino de ausencia de decisión previa: la documentación no define dónde vive el BFF ni con qué stack, y el repositorio disponible es Zammad 7.2.3 sin ningún componente SLA.

**Qué se consiguió:**

- Auditoría real del repositorio (Fase A), con evidencia reproducible.
- Verificación de que no existe motor SLA, BFF, tablas `sla_*` ni migraciones propias.
- Verificación de recursos del entorno, que impide ejecutar validaciones automatizadas de forma segura.
- Registro de observaciones y bloqueantes con criterios de cierre.

**Qué no se pudo completar, y por qué:**

| Actividad | Motivo |
|---|---|
| Implementación del motor SLA (Fase B) | No hay ubicación ni stack definidos para el BFF. Implementarlo dentro de Zammad contradice la arquitectura aprobada (motor propio en el BFF, Zammad sin escrituras SLA). |
| Adaptador de integración (Fase C) | Depende del BFF y de la base propia del motor. |
| Seguridad validada (Fase D) | Requiere el componente a validar y un entorno aislado; el entorno actual no tiene margen de memoria. |
| Batería de pruebas (Fase E) | No existe código SLA que probar. La suite de Zammad no se ejecutó (ver OBS-02). |
| Contrato API para frontend (Fase F) | No existen endpoints SLA. Documentarlos sería inventar rutas. |
| Guía de inicio frontend (Fase H) | Depende del contrato. |

---

## 2. Matriz de auditoría (Fase A)

| Componente | Estado real | Evidencia | Acción |
|---|---|---|---|
| BFF | **No existe** en el repositorio. No hay stack ni ubicación definidos en la documentación. | `ls` de la raíz; búsqueda de «BFF» y stack en `docs/atenciones-zammad/`: sin definición. | Decisión previa (BLK-01). |
| Motor SLA | **No existe**. | Búsqueda de `sla_policy_version`, `sla_commitment`, `sla_cycle`, `sla_event` en `app`, `lib`, `db`, `config`, `spec`: sin resultados reales. | No crear implementación paralela. Esperar BLK-01. |
| Persistencia | **No existe** para el motor. `mailing_development` contiene solo tablas de Zammad. | Migraciones `db/migrate` sin ninguna referencia `sla_`. | Diseñar tras BLK-01. No migrar bases existentes. |
| Integración Zammad | Existe la API nativa de Zammad. **No hay adaptador SLA**. | `app/controllers` y `config/routes` son los de Zammad. | Adaptador tras BLK-01. |
| Clasificación | Existe el atributo `categoria_subcategoria` (tree_select) en Zammad. **La validación de opciones solo se aplica en ejecución de IA.** No existe lógica de clasificación SLA. | `lib/validations/object_manager/attribute_validator/option.rb:8` y `attribute_validator.rb:28`. | Validación centralizada en el BFF (OBS-05). |
| Cálculo de vencimientos | **No existe**. | Sin código de cálculo 24/7 ni de compromisos. | Implementar tras BLK-01. |
| Reaperturas | **No existe** lógica de ciclos. Zammad conserva `close_at` y `last_close_at`, pero el motor no los usa todavía. | Documentado en 5G.4.5; sin código. | Implementar tras BLK-01. |
| Auditoría | Existe `audit_logs` de Zammad, de uso general. **No hay auditoría SLA**. | Tabla `audit_logs` con 29 filas en `mailing_development`. | Tabla `sla_audit` en el BFF. |
| API para frontend | **No existen endpoints SLA**. | Sin rutas SLA en `config/routes`. | Documentar tras implementación. |
| Pruebas | **No hay pruebas SLA**. La suite de Zammad existe pero no se ejecutó por recursos. | `spec/` contiene pruebas de Zammad; ninguna de SLA. | Crear pruebas con el BFF. Ejecutar suite en ventana con memoria. |

---

## 3. Entorno verificado

| Elemento | Valor observado | Consecuencia |
|---|---|---|
| Memoria total | 2.911 MB | — |
| Memoria disponible | 378 MB | Insuficiente para levantar un entorno de pruebas adicional con seguridad. |
| `background-worker` (sesión concurrente) | ~1,1 GB RSS | Ocupa la mayor parte de la memoria. No se detuvo (no es de esta sesión). |
| `puma`, `websocket`, `vite`, PostgreSQL | Activos | No se tocaron. |
| Git | Sin cambios de código; mismos archivos no versionados que al inicio | Ninguna modificación técnica. |

---

## 4. Criterios de cierre de la etapa backend (sección 13 del mandato)

| Criterio | Estado | Observación |
|---|---|---|
| Arquitectura coherente sin duplicidad | **No cumplido** | BLK-01: sin ubicación del BFF. |
| Clasificación validada en BFF | **No cumplido** | No existe BFF. |
| Matriz SLA con fallback y exclusiones | **No cumplido** | Solo documentado; no implementado. |
| Asignación y congelamiento | **No cumplido** | No implementado. |
| Primera respuesta | **No cumplido** | No implementado. |
| Resolución y reaperturas | **No cumplido** | No implementado. |
| Persistencia con trazabilidad e idempotencia | **No cumplido** | No existe persistencia del motor. |
| Sincronización recuperable con Zammad | **No cumplido** | No implementado. |
| Seguridad validada | **No cumplido** | Riesgos identificados (OBS-06); no validados. |
| Pruebas con evidencia | **No cumplido** | Ninguna prueba SLA ejecutada. |
| Contratos API reales | **No cumplido** | No existen endpoints. |
| Observaciones inventariadas | **Cumplido** | `OBSERVACIONES_TECNICAS_BACKEND_SLA.md`. |
| Guía de integración frontend | **No cumplido** | Depende de contrato. |

**Regla de decisión aplicada:** `BLOQUEADO`. Existe una dependencia crítica (BLK-01) que impide avanzar al backend y, por tanto, al frontend de forma segura. No se declara `CERRADO CON OBSERVACIONES`, porque no hay backend utilizable que observar.

---

## 5. Bloqueantes para reabrir la etapa

| ID | Bloqueante | Decisión o autorización necesaria |
|---|---|---|
| **BLK-01** | Ubicación y stack del BFF no definidos. | Decidir si el BFF es un proyecto nuevo (stack elegido por el equipo) o un módulo separado. Ninguna de las dos opciones se implementa sin esta decisión. |
| **BLK-02** | Memoria insuficiente para validar. | Ventana con recursos: detener o no el worker de otra sesión es decisión del operador, no de esta tarea. |
| **BLK-03** | Catálogo oficial fuera del repositorio. | Versionar `CategoryData.ts` o su exportación dentro del proyecto del BFF (DEP-08). |
| **BLK-04** | Secretos en texto plano. | Gestor de secretos y rotación de credenciales (autorización del responsable técnico). |

Las decisiones DT-01 (BFF como fuente), DT-02 (65 con marca), DP-04 (responsable Soporte) y DEC-05 (siete casos excluidos) están confirmadas y **no se han reabierto**.

---

## 6. Qué puede hacerse ya, sin BLK-01

- Mantener la documentación y su trazabilidad.
- Preparar, sin ejecutar, el procedimiento de ventana de pruebas.
- Versionar el catálogo (BLK-03), si se autoriza, en un directorio nuevo.

No se debe iniciar frontend de C.O.S.E. sobre contratos inexistentes.

---

## 7. Confirmación

- No se modificó código, configuración, base de datos, Redis, Zammad, Gmail, usuarios, permisos ni credenciales.
- No se iniciaron ni detuvieron servicios, workers ni schedulers.
- No se ejecutaron pruebas automatizadas.
- No se conectó a PostgreSQL empresarial ni al buzón definitivo.
- No se hizo commit ni push.
- No se modificaron documentos fuente.

---

## 8. Reapertura del 17/11/2026: verificación de BLK-01

**Decisión recibida:** el BFF SLA vivirá como módulo dentro del backend canónico de C.O.S.E., con Node.js, TypeScript, Express, Prisma y PostgreSQL.

### 8.1 Backend candidato localizado

| Atributo | Verificado |
|---|---|
| Ruta | `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi\backend` |
| Stack | Express 4, Prisma 5, TypeScript 5, Vitest, Zod |
| Descripción en `package.json` | «API REST de la plataforma BI (Express + Prisma + PostgreSQL)» |
| Catálogo de referencia | `CategoryData.ts` del frontend del mismo proyecto |
| Vista de datos | `public.v_unificado_norm`, según `AGENTS.md` |
| Alcance funcional observado | Dashboard, QyD, facturación, actas, agendas, contactos, adaptadores Zendesk y TicketBI |
| Identidad como backend de C.O.S.E. | **Parcial.** Coincide por stack, catálogo y vista, pero el literal «C.O.S.E.» no aparece en `backend/src`. Debe confirmarse. |

Se descarta `C:\dev\centralizador-correos`: es un clon de la interfaz de Zammad, no un backend de C.O.S.E.

### 8.2 Bloqueos que impiden implementar el módulo

| ID | Bloqueo | Evidencia | Autorización necesaria |
|---|---|---|---|
| BLK-01b | ~~No es un repositorio Git~~ **Corrección 17/11/2026:** el repositorio **sí existe**; el `.git` está en `restaurant-bi`, no en `restaurant-bi-fase1`. Rama `remediation/audit`, HEAD `27b973a`, sincronizada con `origin`. Los commits `288ffad`, `c7e480e` y `76dffe7` existen. | Ver `PLAN_DESBLOQUEO_IMPLEMENTACION_SLA.md` §2. Pendiente: autorización para crear la rama de trabajo. |
| BLK-05 | **No hay base de datos de prueba aislada.** `pgvector_user` no puede crear bases ni roles. | `docs/test-environment/README.md` §1: bloqueado hasta que un DBA ejecute el runbook. | DBA para crear `restaurant_bi_test` y los roles de migración y runtime. |
| BLK-06 | **Las migraciones se aplican a mano** con `psql` sobre `DATABASE_URL`, que en producción apunta a la base de negocio. Prisma no gestiona un historial de migraciones. | `docs/SEGUIMIENTO_PROACTIVO.md` línea 95; `prisma:pull` en `package.json`. | Procedimiento de migración aprobado y uso exclusivo de la base de prueba. |
| BLK-07 | **Reglas del repositorio.** `AGENTS.md` limita a una épica por sesión y exige un único dominio por cambio. Un módulo SLA es una épica nueva. | `AGENTS.md` reglas 1, 5, 11 y 13. | Confirmar la épica activa y autorizar el inicio del módulo SLA. |

### 8.3 Estado de esta reapertura

- **Implementación del módulo SLA:** no iniciada. Ningún archivo se creó ni modificó en `restaurant-bi`.
- **Migraciones:** no creadas ni ejecutadas.
- **Pruebas:** no ejecutadas. No existe base aislada.
- **Contratos API:** no documentados. No existen endpoints SLA.
- **Estado de cierre:** sigue **BLOQUEADO**, con BLK-01 en progreso (decisión tomada, ubicación localizada, implementación pendiente de autorización).

### 8.4 Lo que sí se puede preparar sin autorización

1. Confirmar la identidad de `restaurant-bi` como backend de C.O.S.E., con una revisión de su `README.md` raíz.
2. Redactar el diseño de tablas `sla_*` en SQL, sin aplicarlo, para revisión del DBA.
3. Preparar el runbook de la base `restaurant_bi_test`, ya descrito en `docs/test-environment/README.md`.

---

## 9. Estado tras la recuperación del 17/11/2026

El plan de desbloqueo consta en `PLAN_DESBLOQUEO_IMPLEMENTACION_SLA.md`.

Estado actualizado el 17/11/2026 tras la autorización del responsable. El detalle de esta última ejecución está en §10.

| Bloqueante | Estado | Evidencia |
|---|---|---|
| BLK-01b (Git) | **Cerrado** | Se autoriza trabajar sobre `remediation/audit`. Rama y HEAD verificados; los 58 cambios de `docs/captures/` siguen intactos |
| BLK-05 (base de pruebas) | **Pendiente de DBA** | Solicitud redactada en el plan §4.2. Sin base no hay validación posible |
| BLK-06 (migraciones) | **Diseñado; no aprobado** | Procedimiento M1–M8 en el plan §5.2. El DDL 001 incluye guarda de base y rol, pero **no se ejecutó** |
| BLK-07 (épica) | **Cerrado** | EPIC-SLA-01 registrada en `AGENTS.md` por autorización expresa |
| BLK-08 (catálogo) | **Cerrado técnicamente** | Exportación con hash y 5 pruebas en verde. El versionado en Git queda pendiente de un commit no autorizado |
| BLK-02 / BLK-09 (ventana) | **Pendiente** | Sin cambios |

**Estado de cierre:** sigue **BLOQUEADO** por BLK-05 y BLK-06. La implementación del motor y la aplicación del esquema no pueden comenzar hasta que exista `restaurant_bi_test` y el procedimiento de migración esté aprobado.

---

## 10. Ejecución del 17/11/2026: épica, catálogo y diseño del esquema

**Alcance autorizado:** registrar la épica, exportar el catálogo, diseñar el esquema SQL y actualizar documentación. **No** ejecutar SQL, crear bases o roles, ni implementar el motor.

### 10.1 Estado Git

| Dato | Valor |
|---|---|
| Rama | `remediation/audit` |
| HEAD inicial | `27b973a` |
| HEAD final | `27b973a` (sin commits) |
| Cambios previos | 58, todos en `docs/captures/` |
| Cambios previos preservados | 58 de 58 |
| Historial | Sin alteración |

### 10.2 Épica registrada

`AGENTS.md` incorpora una sección `EPICA ACTIVA` con nombre, módulo, estado, objetivo, alcance, fuera de alcance y reglas propias. Las 13 reglas del proyecto, la regla de oro, el stop automático y la tabla de congelados se conservan sin cambios. El documento pasó de 85 a 120 líneas.

**Residuo detectado:** la tabla «CONGELADOS (Epica 1)» sigue refiriéndose a una épica anterior y la regla 13 exige finalizar una épica antes de iniciar la siguiente. La autorización resuelve el registro, no la numeración histórica. Se registra como OBS-32.

### 10.3 Catálogo exportado

| Dato | Valor |
|---|---|
| Origen | `frontend/src/components/workspace/CategoryData.ts` |
| SHA-256 origen | `55cec0dea77edbb462021c2a63bbac50694428125ddb20869cddecb020d9e97e` |
| Snapshot | `backend/src/domain/sla/catalogo/catalogo-fuente.snapshot.ts` |
| SHA-256 snapshot | `55cec0dea77edbb462021c2a63bbac50694428125ddb20869cddecb020d9e97e` (identico al origen) |
| JSON de consumo | `backend/src/domain/sla/catalogo/catalogo-oficial.json` |
| SHA-256 JSON | `d0fb5aae25019acad683ddb9273af124ba66b124a504ebc41c2605ed18a91196` |
| Metadatos | `backend/src/domain/sla/catalogo/catalogo-oficial.meta.json` |
| Categorias | 13 |
| Subcategorias | 65 |
| `value` unicos | 62 |
| Duplicados | 3: `cambio_de_razón_social`, `caída_del_servidor`, `redes_y_conexiones` |
| Exportador | `backend/scripts/sla/export-catalogo.ts` |
| Prueba | `backend/src/__tests__/sla-catalogo.test.ts` |

**Pruebas ejecutadas:** `npx vitest run src/__tests__/sla-catalogo.test.ts` → 1 archivo, 5 pruebas, 5 en verde. `npx tsc --noEmit -p tsconfig.json` → sin errores.

### 10.4 Esquema diseñado, no aplicado

| Entregable | Ruta |
|---|---|
| Diseño y diccionario | `docs/atenciones-zammad/DISEÑO_ESQUEMA_BD_SLA.md` |
| DDL propuesto (9 tablas) | `docs/atenciones-zammad/sql/001_diseno_esquema_sla.sql` |
| Rollback propuesto | `docs/atenciones-zammad/sql/001_rollback_diseno_sla.sql` |

**Ninguna sentencia se ejecutó.** El DDL incluye una guarda que aborta si `current_database()` no es `restaurant_bi_test` o si el rol es `pgvector_user`/`postgres`.

### 10.5 Lo que sigue bloqueado

- Aplicar el DDL: requiere BLK-05 (base) y BLK-06 (procedimiento aprobado).
- Implementar el motor en `backend/src/domain/sla/`: requiere el esquema aplicado y la reconciliación del módulo preexistente (OBS-27).
- Contratos API y frontend: requieren endpoints reales.
- Fase 0: sin ejecutar y sin autorizar.

---

## 12. Consolidación del diseño del 17/11/2026

**Alcance:** revisar y consolidar el diseño del motor SLA, clasificar las 32 observaciones y corregir el DDL antes de someterlo al DBA. **No** se ejecutó SQL, no se creó ninguna base o rol y no se implementó el motor.

### 12.1 Resultado de la revisión

| Elemento | Resultado |
|---|---|
| Tablas del DDL | 9 |
| `CHECK` con nombre | 100 |
| Claves foráneas | 4 |
| Índices con nombre | 24 |
| Triggers | 0 |
| Sentencias de escritura | 0 |
| Sentencias ejecutadas | 0 |
| Defectos reales corregidos en el DDL | 24 |
| Endurecimientos aplicados | 5 |
| Observaciones totales | 33 |
| Cerradas | 2 (OBS-18, OBS-21) |
| Resueltas en diseño o técnicamente | 4 (OBS-05, OBS-27, OBS-29, OBS-30) |
| Abiertas o parcialmente resueltas | 27 |

El detalle está en `REVISION_DECISIONES_PENDIENTES_SLA.md`.

### 12.2 Hallazgos que cambian el estado anterior

| Hallazgo | Efecto |
|---|---|
| OBS-31: la discrepancia `source`/`webhook` es falsa | 5G.4.5 línea 108 ya define `poll \| reconcile \| manual`; quedan 4 confirmaciones, no 5 |
| OBS-31: el canal `webhook` de `sla_alert` contradecía la prohibición de webhooks | Eliminado del DDL; canales `internal` y `email` |
| `sla_cycle`: el bicondicional `open = sin cierre` impedía `missed_at_birth` cerrado | Corregido; `missed_at_birth` puede estar abierto o cerrado |
| `sla_sync_run`: el watermark se exigía a todo run `ok` | Corregido; solo al tipo `incremental` |
| `sla_audit`: `alert_config` no corresponde a ninguna tabla | Sustituido por las 8 entidades reales |
| `sla_commitment`: `no_policy` no exigía la versión ni la clase de insuficiencia | Corregido |
| REA-02: el DDL no soporta «ciclo nuevo sin vencimiento» (variante C) | Registrado como dependencia; A y B sí caben |
| OBS-33: no se almacena la clasificación vigente | Nueva observación; no bloquea el DDL, sí la interfaz |
| Recuento de observaciones | Se corrige la omisión de OBS-18 en la severidad Media |

### 12.3 Condiciones que siguen abiertas

1. **BLK-05:** creación de `restaurant_bi_test` y de los roles `cope_test_migration` y `cope_test_runtime`.
2. **BLK-06:** aprobación del procedimiento M1–M8.
3. **OBS-31:** cuatro confirmaciones (`policy_class`, sexto estado, `threshold_pct = 100`, `catalog_mirror_mismatch`).
4. **OBS-30 / DP-04:** ratificación de las 28 clases con respaldo.
5. **OBS-28 / REA-02:** decisión escrita sobre el vencimiento del ciclo N.
6. **OBS-33:** decisión sobre la clasificación vigente.
7. **Registro de migraciones:** decidir si se añade una décima tabla.

### 12.4 Estado de cierre

El cierre técnico **sigue BLOQUEADO** por BLK-05 y BLK-06. La consolidación mejora el diseño y reduce las decisiones abiertas, pero no sustituye la base aislada, el procedimiento aprobado ni las confirmaciones funcionales.

### 12.5 Confirmación

- No se ejecutó SQL ni se conectó a PostgreSQL.
- No se creó ninguna base, rol, tabla, índice o restricción.
- No se modificó Zammad, sus tablas, workers o credenciales.
- No se alteró `public.v_unificado_norm` ni ninguna vista o tabla existente.
- No se tocaron los 58 archivos de `docs/captures/`.
- No se hizo commit ni push.
- No se marcó ninguna prueba no ejecutada como aprobada.

---

## 13. Versión candidata y paquete de aprobación (17/11/2026, segunda parte)

**Alcance:** cerrar las decisiones que pueden resolverse con documentación, preparar fichas para las que requieren firma y dejar el paquete listo para el responsable funcional, el responsable técnico y el DBA. **No** se ejecutó SQL, no se creó ninguna base y no se modificó el DDL.

### 13.1 Entregables

| Archivo | Contenido |
|---|---|
| `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` | Paquete maestro: decisiones, fichas, requisitos DBA, M1–M8, condiciones y rollback |
| `DECISION_CICLOS_REAPERTURA_OBS_28.md` | Decisión formal de ciclos 2..N, comparación A/B con impacto |
| `MATRIZ_RATIFICACION_FALLBACK_SLA.md` | 28 filas de respaldo para firma de Soporte |

### 13.2 Qué quedó cerrado

Nada nuevo se cerró con firma. Sí quedaron **cerradas documentalmente** dos cuestiones que estaban abiertas por falta de lectura:

| Cuestión | Resultado |
|---|---|
| OBS-28: ¿REA-02 sigue pendiente? | 5G.4.5 §4.2 dice «Alternativa A aprobada» y el resumen ejecutivo la lista como cerrada. `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` es un registro anterior sin actualizar. La contradicción es cronológica, no semántica |
| OBS-28: ¿B es una alternativa real? | No con la formulación habitual: A tampoco asigna compromiso nuevo. La diferencia real es plazo sí / plazo no. B no cabe en el DDL sin relajarlo |
| OBS-33: ¿derivar de eventos es viable? | Sí técnicamente (`ticket.classified` existe), pero la retención de 2 años de `sla_event` no cubre un compromiso permanente |

### 13.3 Qué sigue abierto y por qué

| Condición | Motivo |
|---|---|
| BLK-05 y BLK-06 | Siguen bloqueando la aplicación. Sin base y sin procedimiento aprobado no hay migración |
| D-03 a D-06 | Cuatro confirmaciones técnicas: las fichas están, la firma no |
| D-07 y D-08 | Recomendaciones escritas que cambian el modelo si se aprueban: 10 u 11 tablas |
| D-01 y D-02 | Firmas funcionales: ciclos y régimen de respaldo |
| D-11 | DP-04: dueño del catálogo, decisión organizativa |
| AP-01/AP-02/AP-03 | Siguen en `conditional_pending_final_validation` |

### 13.4 Estado de cierre

El cierre técnico **sigue BLOQUEADO**. La diferencia con §12 es que ya no queda ninguna decisión «sin analizar»: cada una tiene propuesta, impacto y responsable. Lo que falta es firma y base de prueba.

### 13.5 Confirmación

- No se ejecutó SQL ni se conectó a PostgreSQL.
- No se modificó el DDL, el rollback ni el script de verificación.
- No se aplicó ningún `ALTER TABLE`.
- No se creó ninguna base, rol, tabla, índice o restricción.
- No se modificó Zammad ni `public.v_unificado_norm`.
- No se tocaron los 58 archivos de `docs/captures/`.
- No se hizo commit ni push.
- No se convirtió ninguna propuesta en regla aprobada.
