# OBSERVACIONES TÉCNICAS DEL BACKEND SLA — EPIC-SLA-01

**Fecha:** 17/11/2026
**Repositorio:** `/home/acast/mailing`, `main`, HEAD `80e0f313`
**Última revisión:** 17/11/2026 — consolidación del diseño del esquema (`REVISION_DECISIONES_PENDIENTES_SLA.md`). Total: 33 observaciones.
**Clasificación:** bugs reales, limitaciones de Zammad, bloqueantes, decisiones pendientes, dependencias externas y deuda técnica se registran por separado.

**Estados:** `abierta`, `en progreso`, `resuelta`, `bloqueada`.

---

## A. Bloqueantes técnicos

| ID | Componente | Descripción | Evidencia | Impacto | Severidad | Dependencia | Acción correctiva | Estado | Criterio de cierre |
|---|---|---|---|---|---|---|---|---|---|
| OBS-01 | BFF | No hay ubicación ni stack definidos para el BFF; ningún componente SLA existe. | `ls` raíz; ausencia en `app`, `lib`, `db`, `config`, `spec`; documentación sin stack. | Impide implementar cualquier parte del motor de forma coherente con la arquitectura aprobada. | **Crítica** | Decisión humana | Elegir ubicación y stack del BFF. | **En progreso (17/11/2026)** | Proyecto del BFF creado, con ubicación y stack registrados en EPIC. Ubicación y stack definidos (`restaurant-bi/backend`, Node/TS/Express/Prisma/PostgreSQL); el componente SLA no existe. |
| OBS-02 | Entorno | Memoria disponible de 378 MB de 2.911 MB; `background-worker` de otra sesión usa ~1,1 GB. | `free -m`; `ps` por RSS. | Impide ejecutar la suite de Zammad o un entorno de pruebas adicional con seguridad. | **Crítica** | Operación del entorno | Ventana de pruebas con recursos, acordada con el operador de la sesión concurrente. | **Bloqueada** | Ejecución de pruebas en ventana declarada con memoria libre suficiente. |
| OBS-03 | Pruebas | No existen pruebas SLA. La suite de Zammad no se ejecutó. | `spec/` sin pruebas SLA. | Ningún comportamiento del motor está verificado. | **Alta** | OBS-01 | Crear pruebas con el BFF y ejecutar la suite en ventana. | **Abierta** | Pruebas de los escenarios de la sección 9 del mandato ejecutadas, con evidencia. |
| OBS-04 | API | No existen endpoints SLA; ningún contrato real para el frontend. | `config/routes` sin rutas SLA. | El frontend no puede integrarse. | **Alta** | OBS-01 | Documentar el contrato tras implementar. | **Abierta** | `CONTRATO_API_FRONTEND_SLA.md` creado a partir de rutas reales. |

## B. Dependencias externas y de datos

| ID | Componente | Descripción | Evidencia | Impacto | Severidad | Dependencia | Acción correctiva | Estado | Criterio de cierre |
|---|---|---|---|---|---|---|---|---|---|
| OBS-05 | Catálogo | `CategoryData.ts` (fuente de las 65 subcategorías) está fuera del repositorio, en un proyecto de Windows. El BFF no puede consumirlo de forma versionada. | Ruta en `restaurant-bi-fase1`; verificada en la auditoría del 16/11/2026. | Riesgo de divergencia entre catálogo del selector y matriz. | **Alta** | Autorización de copia | Versionar el catálogo en el proyecto del BFF (DEP-08). | **Resuelta técnicamente (17/11/2026)** | Catálogo versionado con hash y comparación automática contra la matriz de 30 filas. Exportado con hash idéntico, JSON de consumo y 5 pruebas en verde; el commit no está autorizado. |
| OBS-06 | Seguridad | Credenciales OAuth del canal de correo en `channels.options` y tokens API en `tokens.token`, en texto plano. | Esquema: `channels.options` es `text`; `tokens.token` es `string`; modelo `token.rb:206-212`. | Exposición de credenciales si se accede a la base o a un respaldo. | **Alta** | Gestor de secretos | Gestor de secretos y rotación. **No modificada en esta tarea** (fuera de alcance). | **Abierta** | Credenciales fuera de la base y rotadas, con evidencia. |
| OBS-07 | Respaldos | Los respaldos de Zammad incluyen secretos en claro. | `contrib/backup/functions:164,212,244-246`. | Mismo riesgo que OBS-06 en copias. | **Alta** | OBS-06 | Cifrado de respaldos. | **Abierta** | Respaldo cifrado y restauración probada. |

## C. Limitaciones conocidas de Zammad

| ID | Componente | Descripción | Evidencia | Impacto | Severidad | Dependencia | Acción correctiva | Estado | Criterio de cierre |
|---|---|---|---|---|---|---|---|---|---|
| OBS-08 | Webhooks | Los webhooks no observan actualizaciones de artículos; la detección debe hacerse por sondeo. | `lib/transaction_dispatcher.rb:148-150`. | Obliga a sondeo incremental. | **Media** | Diseño | Mantener sondeo con solapamiento (ya en diseño). | **Abierta** | Sondeo implementado y probado. |
| OBS-09 | Primera respuesta | `first_response_at` de Zammad se fija al crear el artículo, no al confirmar envío. | Ticket 7: diferencia de 9 h 34 min con `delivery_status_date`. | El motor no puede usar ese campo. | **Media** | Diseño | Usar `delivery_status_date` del artículo. | **Abierta** | Prueba de primera respuesta con el campo correcto. |
| OBS-10 | Cierres | `close_at` se fija una vez; `last_close_at` cambia en cada cierre. `merged` y `pending close` no son cierre. | `app/models/ticket/sets_close_time.rb:14-32`. | Riesgo de falsos cierres si se usa el campo equivocado. | **Media** | Diseño | Reglas de ciclos (5G.4.5). | **Abierta** | Pruebas F0-07, F0-08 y F0-09 ejecutadas en ventana. |
| OBS-11 | Fallos de envío | Un fallo definitivo (`delivery_retry > 3`) reabre el ticket y crea una nota interna. | `app/jobs/ticket_article_communicate_email_job.rb:154-190`. | Debe medirse como reapertura real. | **Media** | Diseño | Tratamiento en el motor. | **Abierta** | Prueba de fallo definitivo. |

## D. Decisiones funcionales y organizativas pendientes

`DT-01`, `DT-02`, `DP-04` y `DEC-05` están confirmadas. Sin embargo, **REA-02 sigue pendiente** en `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` (crítica) y **OBS-31 mantiene cuatro confirmaciones** de la especificación. La afirmación anterior («no hay decisiones funcionales pendientes») no se sostiene frente a esas fuentes.

Pendientes de otra naturaleza, organizativas o de autorización:

| ID | Descripción | Estado |
|---|---|---|
| OBS-12 | Validación final de AP-01, AP-02 y AP-03. | `conditional_pending_final_validation` |
| OBS-13 | Ventana de pruebas, grupo y buzón del piloto (AP-04). | Pendiente |

## E. Discrepancias documentales

| ID | Descripción | Evidencia | Severidad | Acción | Estado |
|---|---|---|---|---|---|
| OBS-14 | El paquete Fase 0 v1.3, §2, marca F0-03 y F0-15 como `blocked` en la tabla y como `Pendiente` en la nota. | `PAQUETE_AUTORIZACION_FASE_0_SLA.md` líneas 140, 153 y 161. | Media | Registrada en el acta. Corrección en una revisión documental con registro del cambio. | **Abierta** |
| OBS-15 | En documentos 5G.4.5 aparecen «4 de 17 ejecutadas» y «11/11 con 403»; los documentos v1.x las refinan a 3 `passed` + apertura de F0-01 y 10/11 + caso 7. Añadido el 17/11/2026: la misma tabla declara «4 ejecutadas» y «13 pendientes», pero una fila (F0-05) figura como **Parcial**, de modo que 4 + 13 = 17 no cuadra con las 17 filas reales. | `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` líneas 111, 153, 312-330. | Baja | Documentada; fuentes sin modificar. No se corrigió el conteo: es un documento de criterios, no de seguimiento. | **Abierta** |

## F. Deuda técnica y mejoras opcionales

| ID | Descripción | Severidad | Estado |
|---|---|---|---|
| OBS-16 | `docs/` del repositorio contiene también `README.md`, `decisiones.md` y `verificacion-fase-1.md`, anteriores a este trabajo y no evaluados. | Baja | Abierta |
| OBS-17 | Los archivos `99-cose-theme.css` (3) están sin versionar desde antes de esta etapa. | Baja | Abierta |

---

## G. Reapertura del 17/11/2026: backend canónico localizado

| ID | Componente | Descripción | Evidencia | Impacto | Severidad | Dependencia | Acción correctiva | Estado | Criterio de cierre |
|---|---|---|---|---|---|---|---|---|---|
| OBS-18 | Git | **Corregida la premisa.** El repositorio sí existe (`restaurant-bi`, rama `remediation/audit`, HEAD `27b973a`, sincronizada con `origin`). El error anterior fue de búsqueda. | `git rev-parse`, `git branch -a`, `git cat-file -e`, `git merge-base --is-ancestor`. Ver `PLAN_DESBLOQUEO_IMPLEMENTACION_SLA.md` §2. Además, el responsable autorizó trabajar sobre `remediation/audit` el 17/11/2026. | Ninguno: la decisión está tomada y registrada. | **Media** | — | — | **Cerrada (17/11/2026)** | Autorización registrada y estado Git verificado antes y después de los cambios. |
| OBS-19 | Base de datos | No existe `restaurant_bi_test`. `pgvector_user` no tiene `CREATEDB` ni `CREATEROLE`. | `docs/test-environment/README.md` §1. | Ninguna migración ni prueba puede validarse de forma aislada. | **Crítica** | DBA | Ejecutar el runbook de §1 del documento de entorno de pruebas. | **Bloqueada** | Base aislada creada y verificada con la consulta de la §1 del runbook. |
| OBS-20 | Migraciones | Las migraciones son SQL manual aplicado con `psql` a `DATABASE_URL`, que en producción es la base de negocio. Prisma no tiene historial de migraciones (`prisma:pull`). | `docs/SEGUIMIENTO_PROACTIVO.md` línea 95; `package.json`. | Un error de migración afectaría datos reales. | **Alta** | OBS-19 | Procedimiento de migración aprobado; ejecución solo en la base de prueba. | **Abierta** | Migración probada en `restaurant_bi_test` con reversión documentada. |
| OBS-21 | Gobierno | `AGENTS.md` limita a una épica por sesión y un dominio por cambio. El módulo SLA es una épica nueva sin autorizar. | `AGENTS.md` reglas 1, 5, 11 y 13. | Iniciar el módulo sin autorización viola las reglas del repositorio. | **Media** | Decisión del responsable | Confirmar la épica activa y autorizar el módulo SLA. | **Cerrada (17/11/2026)** | Autorización escrita de la épica SLA. EPIC-SLA-01 registrada en `AGENTS.md`; rama `remediation/audit` autorizada. |

**Pendientes de otra naturaleza (sin severidad):**

| ID | Descripción | Estado |
|---|---|---|
| OBS-22 | Confirmar que `restaurant-bi` es el backend de C.O.S.E.: coincide por stack, catálogo y vista, pero el literal «C.O.S.E.» no aparece en `backend/src`. | Abierta |

## H. Hallazgos de la recuperación del 17/11/2026

| ID | Componente | Descripción | Evidencia | Impacto | Severidad | Dependencia | Acción correctiva | Estado | Criterio de cierre |
|---|---|---|---|---|---|---|---|---|---|
| OBS-23 | Git | 58 cambios sin commit en `docs/captures/` (capturas y HTML). El backend y el frontend están limpios. | `git status --porcelain` agrupado por directorio. | Riesgo de perderlos en una limpieza o cambio de rama. | **Media** | Decisión del responsable | Decidir si se versionan, se ignoran o se mueven. No eliminar. | **Abierta** | Decisión registrada y cambios preservados. |
| OBS-24 | Git | La rama `main` local (`e07f21c`) está 31 commits por detrás de `origin/main`. | `git branch -vv`. | Confusión sobre cuál es la rama de referencia. | **Baja** | Ninguna | Usar `remediation/audit` como base; no actualizar `main` sin autorización. | **Abierta** | Rama de referencia documentada. |
| OBS-25 | Datos | El README dice que la plataforma consume `public.v_unificado`; `AGENTS.md` y el código usan `public.v_unificado_norm`. | `README.md` línea 4; `TicketWorkspaceAssembler.ts`; `utils/filtros.ts`. | Riesgo de consultar una vista equivocada. | **Media** | Confirmación del responsable | Confirmar la vista vigente. El código usa `_norm`. | **Abierta** | Vista vigente confirmada y el README corregido. |
| OBS-26 | Catálogo | `CategoryData.ts` declara sus valores como «valor Zendesk», no como identificadores del catálogo funcional. | Comentario de cabecera del archivo. | Si se retira Zendesk, el catálogo podría quedar acoplado a valores de Zendesk. | **Media** | Decisión del responsable | Versionar el catálogo como identificadores propios (plan §6.3). | **Abierta** | Catálogo versionado con hash y sin dependencia de Zendesk. |

## Resumen por severidad

Recuento del 17/11/2026 tras la consolidación del diseño del esquema.

| Severidad | Cantidad | IDs |
|---|---:|---|
| Crítica | 3 | OBS-01, OBS-02, OBS-19 |
| Alta | 7 | OBS-03, OBS-04, OBS-05, OBS-06, OBS-07, OBS-20, OBS-28 |
| Media | 15 | OBS-08 a OBS-11, OBS-14, OBS-18, OBS-21, OBS-23, OBS-25, OBS-26, OBS-27, OBS-29, OBS-30, OBS-31, OBS-33 |
| Baja | 5 | OBS-15, OBS-16, OBS-17, OBS-24, OBS-32 |
| Sin severidad (pendientes organizativos o de identidad) | 3 | OBS-12, OBS-13, OBS-22 |

**Total:** 33 observaciones. **Cerradas:** 2 (OBS-18, OBS-21). **Resueltas en diseño o técnicamente:** 4 (OBS-05, OBS-27, OBS-29, OBS-30). **En progreso:** 1 (OBS-01). **Abiertas:** 22. **Bloqueadas:** 2 (OBS-02, OBS-19). **Organizativas:** 2 (OBS-12, OBS-13).

**Nota de recuento:** la versión anterior omitía OBS-18 de la fila Media y declaraba 32 observaciones con 31 abiertas. El recuento se corrige aquí.

**Nota del 17/11/2026 (segunda parte):** ninguna observación pasó a cerrada en esta etapa. Cuatro quedaron con propuesta escrita y ficha de firma: OBS-28 (decisión de ciclos), OBS-30 (28 filas para Soporte), OBS-31 (cuatro fichas) y OBS-33 (recomendación de tabla). Las 33 siguen repartidas como arriba.

## I. Hallazgos de la ejecución del 17/11/2026

| ID | Componente | Descripción | Evidencia | Impacto | Severidad | Dependencia | Acción correctiva | Estado | Criterio de cierre |
|---|---|---|---|---|---|---|---|---|---|
| OBS-27 | Módulo SLA | `backend/src/domain/sla/` ya existe con `README.md`, `index.ts` y `types.ts` que definen `SLAPolicy` con `canalId`, `tiempoMaximoMinutos` y semáforo por canal. Es un modelo genérico anterior, contrario a «solo correo» y al compromiso congelado. No lo consume ningún módulo. | `backend/src/domain/sla/*`; `grep` de `SLAPolicy`/`CalculoSLA` sin consumidores; mención en `domain/canales/README.md` | Confusión de dos modelos SLA en la misma ruta. Implementar encima sin resolverlo duplica conceptos. | **Media** | Autorización del responsable | Decidir si se retira, se reubica como legado o se reescribe. No se modificó. | **Resuelta en diseño (17/11/2026)** | Un único modelo SLA en `domain/sla/`, con decisión registrada. Decisión: coexistencia aislada; no borrar, mover ni modificar sin autorización. El cambio de archivos sigue pendiente. |
| OBS-28 | Ciclos | REA-02 (vencimiento del ciclo de reapertura) figura como regla en el EPIC y 5G.4.5 la declara aprobada, pero `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` la deja **pendiente**: registro anterior que nunca se actualizó. | `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` líneas 61-66; EPIC BR-38; `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2; `RESUMEN_EJECUTIVO_5G4_5.md` §3.1 | Sin decisión, el ciclo 2..N no puede tener `due_at`. Afecta a la implementación de reaperturas y a las alertas por ciclo. | **Alta** | Responsable funcional | Ratificar A con firma funcional en `DECISION_CICLOS_REAPERTURA_OBS_28.md`. A cabe sin cambios; B (ciclo sin plazo) no. | **Abierta: falta firma, no análisis (17/11/2026)** | Decisión escrita que fija el vencimiento del ciclo N. 5G.4.5 ya la declara cerrada; falta la firma que sustituya al registro obsoleto de 5G.4.4. |
| OBS-29 | Prisma | Prisma 5 no expresa `CHECK` ni índices únicos parciales en `schema.prisma`. El esquema SLA depende de ambos. | `DISEÑO_ESQUEMA_BD_SLA.md` §H.2 | `prisma db pull` no reproduciría las restricciones y `prisma migrate` crearía un historial paralelo al SQL manual. | **Media** | Convención del repositorio | Documentar que las tablas SLA se modelan sin esas restricciones y que el DDL vive solo en SQL. | **Resuelta documentalmente (17/11/2026)** | Convención escrita y respetada en la implementación. Frontera en `DISEÑO_ESQUEMA_BD_SLA.md` §H.2: Prisma no modela el esquema SLA; sin `db pull`, `db push` ni `migrate`. |
| OBS-30 | Catálogo | `CategoryData.ts` no contiene la clase de política de cada subcategoría. Las 27 de matriz, 3 sin evidencia, 28 con respaldo y 7 excluidas se derivan de la matriz y de DEC-05. | `DISEÑO_ESQUEMA_BD_SLA.md` §C.2 e §I.7 | Sin un mapa aprobado, la carga de `sla_policy_version` dependería de una interpretación no validada. | **Media** | Soporte (DP-04) | Aprobar el mapa derivado antes de la carga inicial de las 38 políticas. | **Resuelta técnicamente (17/11/2026)** | Mapa derivado y contrastado con las 30 filas de la matriz. `MATRIZ_POLITICAS_CATALOGO_SLA.md`: 65 filas, 27/3/28/7, 0 errores. `MATRIZ_RATIFICACION_FALLBACK_SLA.md`: 28 filas en 9 categorías, preparadas para firma de Soporte. La ratificación (DP-04) sigue pendiente. |
| OBS-31 | Especificación | Cinco discrepancias entre `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md` y el EPIC/BR: `policy_class` inexistente, 5 estados de asignación frente a 6 necesarios, `threshold_pct` 75/90 frente a alerta de vencimiento, `source` con `webhook` frente a solo sondeo, y tipo de divergencia para el espejo de Zammad. | `DISEÑO_ESQUEMA_BD_SLA.md` §I.2 a §I.6 | El DDL propone correcciones que requieren confirmación; aprobarlo sin ellas dejaría reglas sin representación. | **Media** | Responsable técnico | Confirmar las cuatro propuestas restantes en las fichas del paquete de aprobación. | **Parcialmente resuelta (17/11/2026)** | 1 descartada por falsa y 4 pendientes de confirmación. `source`/`webhook` no es discrepancia: 5G.4.5 línea 108 ya define `poll \| reconcile \| manual` y la línea 49 prohíbe webhooks. Fichas D-03 a D-06 en `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §4. Sin aprobar. |
| OBS-32 | Gobierno | `AGENTS.md` declara EPIC-SLA-01 como épica activa, pero conserva la tabla «CONGELADOS (Epica 1)» y la regla 13 (solo iniciar una épica tras finalizar la anterior). | `AGENTS.md` líneas 17-48, 90 y 100-120 | Ambigüedad sobre si la épica anterior sigue abierta. | **Baja** | Responsable del proyecto | Confirmar que la épica anterior está cerrada o renombrar la tabla de congelados. | **Abierta** | Estado de las épicas sin ambigüedad en `AGENTS.md`. No se halló evidencia de cierre formal de la Épica 1; se propone un cambio mínimo de etiqueta, no ejecutado. |
| OBS-33 | Clasificación | El esquema congela `category` y `subcategory` en `sla_commitment` y audita la reclasificación en `sla_audit`, pero **no almacena la clasificación vigente** en una columna o tabla consultable. | `DISEÑO_ESQUEMA_BD_SLA.md` §B.2 y §B.7; `001_diseno_esquema_sla.sql` | Mostrar la categoría actual exige leer el último `new_value` de auditoría o recalcular desde Zammad; JSONB no es indexable por categoría. | **Media** | Responsable técnico | Adoptar la tabla `sla_classification` con índice único parcial `WHERE is_current`; borrador en el paquete §6.3. No se aplicó. | **Recomendada B, sin aprobar (17/11/2026)** | Decisión registrada y DDL ajustado antes de la interfaz de clasificación. La derivación desde eventos se descarta por retención (2 años frente a compromiso permanente). |

**Corregidas en esta tarea:** OBS-21 (autorización de la épica) y OBS-18 (decisión Git ya registrada). **Resueltas en diseño o técnicamente:** OBS-05, OBS-27, OBS-29 y OBS-30. **Parcialmente resuelta:** OBS-31 (1 discrepancia descartada, 4 pendientes). Ninguna observación se marcó como cerrada si su criterio exigía una ejecución no realizada.
