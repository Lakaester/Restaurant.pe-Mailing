# REVISIÓN Y CONSOLIDACIÓN DEL DISEÑO SLA — EPIC-SLA-01

**Fecha:** 17/11/2026
**Repositorio backend:** `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi`
**Rama:** `remediation/audit` · **HEAD:** `27b973a`
**Documentos revisados:** `EPIC_IMPLEMENTACION_SLA_COSE.md`, `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md`, `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md`, `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md`, `DECISIONES_PENDIENTES_EMAIL_5G4_4.md`, `ACTA_ENTREGA_CIERRE_HITO_EPIC_SLA_01.md`, `DISEÑO_ESQUEMA_BD_SLA.md`, `001_diseno_esquema_sla.sql`, `001_rollback_diseno_sla.sql`.
**Naturaleza:** revisión documental y estructural. **No se ejecutó SQL, no se conectó a PostgreSQL, no se creó ninguna base, rol ni tabla.**
**Actualización del 17/11/2026 (segunda parte):** las decisiones de este documento se prepararon para firma en `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md`, con la decisión de ciclos en `DECISION_CICLOS_REAPERTURA_OBS_28.md` y las 28 filas de respaldo en `MATRIZ_RATIFICACION_FALLBACK_SLA.md`. Este documento conserva el estado de la revisión; no es el instrumento de aprobación.

---

## 1. Objetivo y veredicto

Esta revisión consolida el diseño del motor SLA antes de someterlo al DBA. Clasifica las 33 observaciones técnicas, resuelve las que dependen de documentación o diseño y aísla las que requieren una decisión que no puede tomarse en este trabajo.

**Veredicto técnico:** el DDL de 9 tablas no presenta defectos estructurales conocidos tras las correcciones de §6. Su aplicación sigue **condicionada** a:

1. creación de `restaurant_bi_test` y de los roles de prueba (BLK-05);
2. aprobación del procedimiento de migración M1–M8 (BLK-06);
3. cuatro confirmaciones de la especificación (OBS-31), una quinta discrepancia descartada;
4. ratificación funcional del mapa de clases del catálogo (OBS-30 / DP-04);
5. decisión sobre la clasificación vigente frente a la congelada (OBS-33).

**Lo que esta revisión no hace:** no declara aprobado el esquema, no aplica el DDL, no cierra AP-01/AP-02/AP-03, no resuelve REA-02 y no convierte ninguna propuesta del DDL en regla aprobada.

---

## 2. Método y límites

| Actividad | Ejecutada | Evidencia |
|---|---|---|
| Lectura de las fuentes normativas | Sí | EPIC §6.1–§6.8, §7.3; 5G.4.5; reglas de ciclos; matriz 5G.4.4; decisiones 5G.4.4; acta |
| Recuento y cruce del catálogo | Sí | `MATRIZ_POLITICAS_CATALOGO_SLA.md`, 65 filas, 0 errores del generador |
| Revisión del legado `domain/sla/` | Sí | `README.md`, `index.ts`, `types.ts`; sin consumidores ni pruebas |
| Revisión de la frontera Prisma | Sí | `backend/prisma/schema.prisma` solo contiene `GenerateAnchor`; migraciones SQL manuales |
| Revisión estructural del DDL | Sí | 9 tablas, 100 `CHECK`, 4 `FK`, 24 índices con nombre |
| Ejecución de SQL | **No** | Ninguna conexión a PostgreSQL |
| Creación de base, rol o tabla | **No** | — |
| Aplicación de migraciones | **No** | — |
| Pruebas de integración | **No** | Sin base aislada ni ventana |

**Regla aplicada:** ninguna observación se marca como cerrada si su criterio de cierre exige una ejecución que no se realizó.

---

## 3. Estado de las 33 observaciones

Claves de clasificación:

- **Cerrada:** decisión tomada y evidencia verificable.
- **Resuelta en diseño:** el diseño o el documento resuelve la cuestión; queda ejecución o ratificación.
- **En progreso:** una parte está resuelta y otra no.
- **Abierta:** sin resolución.
- **Bloqueada:** depende de un tercero (DBA u operación).
- **Organizativa:** depende de una designación o aprobación formal.

| ID | Tema | Sev. | Clasificación | Fundamento | Estado resultante |
|---|---|---|---|---|---|
| OBS-01 | BFF | Crítica | En progreso | Ubicación y stack definidos (`restaurant-bi/backend`, Node/TS/Express/Prisma/PostgreSQL) y módulo registrado en `AGENTS.md`; el componente SLA no existe | **En progreso** |
| OBS-02 | Memoria | Crítica | Bloqueada | Sin ventana de recursos; no se ejecutaron pruebas | **Bloqueada** |
| OBS-03 | Pruebas | Alta | Abierta | No hay pruebas SLA; no existe base aislada | **Abierta** |
| OBS-04 | API | Alta | Abierta | No hay endpoints SLA; documentar rutas sería inventarlas | **Abierta** |
| OBS-05 | Catálogo | Alta | Resuelta en diseño | Exportado con hash idéntico al origen, JSON de consumo, metadatos y prueba de 5 casos; el commit no está autorizado | **Resuelta técnicamente** |
| OBS-06 | Secretos | Alta | Riesgo aceptado | Fuera de alcance; no se abrió `backend/.env` | **Abierta** |
| OBS-07 | Respaldos | Alta | Riesgo aceptado | Fuera de alcance | **Abierta** |
| OBS-08 | Webhooks | Media | Resuelta en diseño | El sondeo con solapamiento es la única vía verificada; ya está en el diseño | **Abierta (diseño cerrado)** |
| OBS-09 | Primera respuesta | Media | Resuelta en diseño | Se usa `delivery_status_date` con respaldo `updated_at`; nunca `first_response_at` | **Abierta (diseño cerrado)** |
| OBS-10 | Cierres | Media | Resuelta en diseño | `close_at` único; `pending close` y `merged` no cierran; reglas en §C.6–C.8 | **Abierta (diseño cerrado)** |
| OBS-11 | Fallos de envío | Media | Resuelta en diseño | `reopen_hint = 'delivery_failure'` y ciclo nuevo | **Abierta (diseño cerrado)** |
| OBS-12 | AP-01/02/03 | — | Organizativa | Siguen en `conditional_pending_final_validation` | **Pendiente** |
| OBS-13 | Piloto | — | Organizativa | Ventana, grupo y buzón sin designar | **Pendiente** |
| OBS-14 | Fase 0 | Media | Abierta | Discrepancia `blocked`/`Pendiente` en el paquete v1.3 | **Abierta** |
| OBS-15 | Conteos Fase 0 | Baja | Abierta | «4 de 17» frente a 3 `passed`; «11/11» frente a 10/11 | **Abierta** |
| OBS-16 | `docs/` previos | Baja | Abierta | Documentos anteriores no evaluados | **Abierta** |
| OBS-17 | CSS sin versionar | Baja | Abierta | 3 archivos previos | **Abierta** |
| OBS-18 | Git | Media | Cerrada | Repositorio y rama verificados; autorización registrada | **Cerrada (17/11/2026)** |
| OBS-19 | Base de prueba | Crítica | Bloqueada | `pgvector_user` no tiene `CREATEDB` ni `CREATEROLE` | **Bloqueada** |
| OBS-20 | Migraciones | Alta | Abierta | M1–M8 diseñado; no aprobado ni probado | **Abierta** |
| OBS-21 | Gobierno | Media | Cerrada | EPIC-SLA-01 registrada en `AGENTS.md`; rama autorizada | **Cerrada (17/11/2026)** |
| OBS-22 | Identidad C.O.S.E. | — | Abierta | El EPIC y el historial lo tratan como backend de C.O.S.E.; falta confirmación nominal | **Abierta** |
| OBS-23 | 58 capturas | Media | Abierta | Verificadas intactas; sin decisión de versionado | **Abierta** |
| OBS-24 | `main` atrasada | Baja | Abierta | Se usa `remediation/audit`; no se actualiza sin autorización | **Abierta** |
| OBS-25 | Vista `_norm` | Media | Abierta | El código usa `v_unificado_norm`; el README dice `v_unificado` | **Abierta** |
| OBS-26 | Valores Zendesk | Media | Abierta | El snapshot conserva `value` como identificador; el acoplamiento persiste | **Abierta** |
| OBS-27 | Legado `domain/sla` | Media | Resuelta en diseño | Coexistencia aislada, sin borrar ni mover sin autorización (§4.1) | **Resuelta en diseño** |
| OBS-28 | REA-02 | Alta | Abierta | Discrepancia documental real; el DDL soporta A y B, no C (§4.2) | **Abierta** |
| OBS-29 | Prisma | Media | Resuelta en diseño | Frontera escrita: Prisma no posee el esquema SLA (§4.3 y §7) | **Resuelta documentalmente** |
| OBS-30 | Clases del catálogo | Media | Resuelta en diseño | Matriz de 65 filas, 27/3/28/7, 0 errores; ratificación de Soporte pendiente (§4.4) | **Resuelta técnicamente** |
| OBS-31 | 5 discrepancias | Media | Parcialmente resuelta | 1 descartada por falsa; 4 requieren confirmación (§4.5 y §5) | **Abierta (4 confirmaciones)** |
| OBS-32 | Épica 1 | Baja | Abierta | No hay evidencia de cierre formal; se propone cambio mínimo, no ejecutado (§4.6) | **Abierta** |
| OBS-33 | Clasificación vigente | Media | Abierta | Nueva: el esquema congela la clasificación pero no almacena la vigente (§4.7) | **Abierta** |

**Totales:** 33 observaciones. Cerradas 2 (OBS-18, OBS-21). Resueltas en diseño o técnicamente 4 (OBS-05, OBS-27, OBS-29, OBS-30). En progreso 1 (OBS-01). Abiertas 22. Bloqueadas 2 (OBS-02, OBS-19). Organizativas 2 (OBS-12, OBS-13).

**Corrección de recuento:** el resumen anterior declaraba 13 observaciones de severidad Media y 32 en total, pero omitía OBS-18 de la fila Media. El recuento correcto, con OBS-33, es: Crítica 3, Alta 7, Media 15, Baja 5, sin severidad 3 = 33.

---

## 4. Resoluciones focalizadas

### 4.1 OBS-27 — módulo `backend/src/domain/sla/` preexistente

**Hecho verificado:** el directorio contiene `README.md`, `index.ts` y `types.ts` con un modelo genérico de semáforo por canal (`SLAPolicy` con `canalId` y `tiempoMaximoMinutos`, `CalculoSLA`, `SemaforoSLA`). No lo consume ningún módulo: la única referencia es la prueba del catálogo, que importa el snapshot. No tiene pruebas propias. El `README.md` de `domain/canales` menciona SLA pero no importa el módulo.

**Decisión de diseño registrada:** coexistencia aislada.

- El motor nuevo vivirá en un subdirectorio propio del módulo, sin reutilizar ni extender `types.ts`.
- El legado no se borra, no se mueve y no se modifica mientras no exista autorización expresa. Borrarlo destruiría trabajo previo no evaluado.
- El motor nuevo no puede importar `SLAPolicy` ni `CalculoSLA`: el compromiso congelado y el canal único de correo son incompatibles con ese modelo.
- La etiqueta de legado en `README.md` y el traslado a una ruta histórica son cambios de código, no de diseño, y quedan pendientes de autorización.

**Consecuencia:** OBS-27 queda resuelta como decisión, no como cambio aplicado. Su criterio de cierre («un único modelo SLA en `domain/sla/`») no se cumple todavía.

### 4.2 OBS-28 — REA-02 y el vencimiento de la reapertura

**Hecho verificado:** hay una contradicción documental real.

| Fuente | Qué dice |
|---|---|
| `EPIC_IMPLEMENTACION_SLA_COSE.md` BR-36 a BR-40 | La reapertura abre un ciclo N+1 con la misma política congelada y un vencimiento nuevo |
| `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §2 y §4 | `due_at` del ciclo N+1 = `opened_at + resolution_minutes` |
| `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` líneas 62-64 | REA-02, REA-03 y REA-04 figuran como **PENDIENTE** (crítica) |

**Resolución:** no se declara aprobada ninguna lectura. Hay que distinguir tres variantes, porque no todas caben en el DDL actual:

| Variante | Qué implica | ¿Cabe en el DDL actual? |
|---|---|---|
| **A. Nuevo ciclo con vencimiento nuevo** | Fila N+1 con `due_at = opened_at + resolution_minutes` | **Sí**, sin cambios |
| **B. Sin fila de ciclo para la reapertura** | Se conserva el ciclo 1; no se abre fila nueva | **Sí**, sin cambios: no se inserta nada |
| **C. Nuevo ciclo sin vencimiento** | Fila N+1 con `due_at NULL` y `outcome = 'open'` | **No**: `sla_cycle_open_needs_due_ck` exige `due_at` cuando `outcome = 'open'` |

La variante C exigiría relajar `sla_cycle_open_needs_due_ck`. No se relaja porque el EPIC describe A como regla y no hay decisión que autorice C.

**Corrección del veredicto anterior:** la afirmación «el esquema soporta ambas» era imprecisa si «ambas» incluía C. Soporta A y B; no soporta C. Se registra como dependencia de implementación, no como defecto del DDL.

**Actualización del 17/11/2026 (segunda parte):** al revisar `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2 y `RESUMEN_EJECUTIVO_5G4_5.md` §3.1 se comprueba que 5G.4.5 **declara aprobada la alternativa A** y lista REA-02..REA-06 como cerradas. La contradicción con `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` es cronológica: ese registro es anterior y nunca se actualizó. Además, la comparación «A asigna compromiso nuevo / B no» es inexacta: A tampoco cambia el compromiso. La decisión formal, con el impacto comparado y la ficha de firma, está en `DECISION_CICLOS_REAPERTURA_OBS_28.md`. **No se declara cerrada**: falta la firma funcional.

**Impacto:** bloquea la implementación de reaperturas, no la aplicación del DDL. Requiere decisión escrita del responsable funcional.

### 4.3 OBS-29 — frontera con Prisma

**Hecho verificado:** `backend/prisma/schema.prisma` contiene solo el modelo ancla `GenerateAnchor`; el repositorio usa SQL crudo (`prisma.$queryRaw`) para la vista y migraciones SQL manuales en `backend/prisma/migrations/`. Prisma 5 no expresa `CHECK` ni índices únicos parciales.

**Decisión de diseño registrada:**

1. Prisma **no posee** el esquema SLA. Las 9 tablas se crean y evolucionan solo por SQL manual.
2. No se añaden modelos SLA a `schema.prisma` en esta etapa.
3. No se ejecuta `prisma db pull` sobre una base que contenga las tablas SLA: sobrescribiría el esquema ancla y no reproduciría las restricciones.
4. No se ejecuta `prisma migrate`, `prisma db push` ni `prisma migrate dev` sobre estas tablas.
5. El acceso del motor será SQL tipado sobre el cliente Prisma existente, no el modelo generado.

**Consecuencia:** OBS-29 queda resuelta documentalmente. Su cumplimiento se verifica en la implementación, no en este trabajo.

### 4.4 OBS-30 — clases de política de las 65 subcategorías

**Hecho verificado:** `MATRIZ_POLITICAS_CATALOGO_SLA.md` se generó desde el catálogo exportado, no por transcripción manual.

| Verificación | Resultado |
|---|---:|
| Filas del catálogo | 65 |
| `matrix` | 27 |
| `insufficient_evidence` | 3 |
| `fallback` | 28 |
| `excluded_non_service` | 7 |
| Suma | 65 |
| Filas de la matriz consumidas exactamente una vez | 30 / 30 |
| Exclusiones DEC-05 consumidas exactamente una vez | 7 / 7 |
| Errores del generador | 0 |

**Estados de aprobación, sin mezclarlos:**

- Las 7 exclusiones DEC-05 están **confirmadas** (16/11/2026).
- Las 3 sin evidencia son **regla del EPIC** (BR-41/42), sujetas a AP-01.
- Las 27 con SLA son **matriz oficial con aprobación condicional** (AP-01).
- Las 28 con respaldo tienen el respaldo aprobado (BR-43), pero la clasificación de cada subcategoría como servicio requiere ratificación de Soporte (DP-04).

**Consecuencia:** OBS-30 queda resuelta técnicamente. La carga de las 38 políticas no debe ejecutarse hasta que exista la ratificación.

### 4.5 OBS-31 — cinco discrepancias, una falsa

Detalle en §5. Resultado: **cuatro confirmaciones pendientes** y **una discrepancia descartada**.

### 4.6 OBS-32 — estado de la Épica 1

**Hecho verificado:** no se encontró evidencia de cierre formal de la Épica 1. `AGENTS.md` conserva la tabla «CONGELADOS (Epica 1)» y la regla 13 exige finalizar una épica antes de iniciar la siguiente. El registro de EPIC-SLA-01 no resuelve la numeración histórica.

**Resolución propuesta, no ejecutada:** cambio mínimo de etiqueta en la tabla de congelados para indicar que es un inventario histórico y no una épica abierta. No se renombra la épica, no se declara cerrada y no se altera la regla 13. Requiere autorización porque `AGENTS.md` es un archivo versionado del repositorio.

**Consecuencia:** OBS-32 sigue abierta. No bloquea el DDL.

### 4.7 OBS-33 — clasificación vigente frente a clasificación congelada (nueva)

**Hallazgo:** el esquema guarda `category` y `subcategory` como snapshot inmutable en `sla_commitment`, y registra la reclasificación en `sla_audit` con `old_value` y `new_value`. **No existe una columna ni tabla que almacene la clasificación vigente.** Para mostrar la clasificación actual de un ticket hay que leer el último registro de auditoría o recalcularla desde Zammad.

**Por qué importa:** el requisito es «reclasificar sin tocar el compromiso congelado». La auditoría lo garantiza, pero la consulta operativa «categoría actual del ticket» no tiene una fuente estructurada. Depender de JSONB en auditoría es frágil y no indexable por categoría.

**Opciones, ninguna aprobada:**

| Opción | Cambio | Ventaja | Riesgo |
|---|---|---|---|
| A | Añadir `current_category` y `current_subcategory` mutables a `sla_commitment` | Simple, indexable, separado del snapshot | Dos pares de columnas que pueden divergir |
| B | Tabla `sla_classification` (décima tabla) | Historial completo y consultable | Cambia el modelo de 9 tablas |
| C | Derivar del último `sla_audit` | Sin cambio de DDL | Costoso y dependiente de JSONB |

**Consecuencia:** OBS-33 queda abierta. No impide aplicar el DDL de 9 tablas, pero debe decidirse antes de implementar la interfaz de clasificación.

**Actualización del 17/11/2026 (segunda parte):** se evaluaron las tres opciones contra cinco criterios (consulta actual, indexabilidad, inmutabilidad, retención y coste). La derivación desde eventos es técnicamente posible porque `ticket.classified` y `ticket.reclassified` existen, pero `sla_event` se retiene **2 años** y el compromiso es permanente: un ticket antiguo perdería su clasificación derivable. **Recomendación: opción B**, tabla `sla_classification` con índice único parcial `WHERE is_current`. El borrador de DDL y la ficha D-07 están en `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §6. No se aplicó.

---

## 5. OBS-31 en detalle

| # | Discrepancia | Veredicto | Tratamiento en el DDL | Qué falta |
|---:|---|---|---|---|
| 1 | `policy_class` no existe en 5G.4.5 | **Real.** Sin ella no se separan las 3 sin evidencia de las 7 excluidas, que BR-41 y BR-65 tratan distinto | Columna `policy_class` con 4 valores | Confirmación del responsable técnico (AP-01) |
| 2 | 5 estados de asignación frente a 6 necesarios | **Real.** DEC-05 exige un tratamiento propio para las 7 excluidas | Sexto estado `excluded_non_service` | Confirmación |
| 3 | `threshold_pct` 75/90 frente a alerta de vencimiento | **Real.** BR-54 exige aviso de vencimiento y 5G.4.5 solo admite 75/90 | Se añade `100` como vencimiento | Confirmación |
| 4 | `source` con `webhook` frente a solo sondeo | **Falsa.** 5G.4.5 línea 49 prohíbe webhooks y línea 108 ya define `source` como `poll \| reconcile \| manual`. El DDL coincide con la especificación | Sin cambio | Nada; se descarta |
| 5 | Tipo de divergencia para el espejo de Zammad | **Real.** BR-66 exige registrar la divergencia y la lista de 5G.4.5 no la incluye | Se añade `catalog_mirror_mismatch` | Confirmación |

**Nota:** la discrepancia 4 se había contado como real en el análisis previo. La lectura de la línea 108 de 5G.4.5 la descarta. El DDL no necesita corrección.

**Consecuencia:** OBS-31 no puede cerrarse entera. Se cierra la discrepancia 4 y quedan cuatro confirmaciones. Ninguna de las cuatro cambia la estructura de 9 tablas: son columnas o valores ya presentes en el DDL.

---

## 6. Revisión integral del DDL

### 6.1 Inventario

| Elemento | Cantidad | Verificación |
|---|---:|---|
| Tablas | 9 | Nombres `sla_*`, sin colisiones |
| `CHECK` con nombre | 100 | Lista exacta en `001_verificacion_diseno_sla.sql` |
| Claves foráneas | 4 | `commitment→policy`, `cycle→commitment`, `alert→cycle`, `divergence→commitment` |
| Índices con nombre | 24 | Incluye 3 únicos parciales |
| Triggers | 0 | El DDL no crea triggers |
| Funciones y extensiones | 0 | `gen_random_uuid()` es nativo desde PostgreSQL 13 |
| Sentencias de datos | 0 | Sin `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE` |
| `CASCADE` | 0 | Ni en el DDL ni en el rollback |

### 6.2 Correcciones aplicadas

| # | Tabla | Corrección | Tipo | Regla |
|---:|---|---|---|---|
| 1 | `sla_policy_version` | Formato de `policy_key`: `99-FALLBACK` o `20-MAIL-%` | Endurecimiento | EPIC §6.8 |
| 2 | `sla_policy_version` | `resolution_minutes` limitado a la escalera oficial de 17 valores | Endurecimiento | EPIC §6.1 |
| 3 | `sla_policy_version` | Respaldo obligado a 2.160 min | Defecto | BR-43 |
| 4 | `sla_policy_version` | Exclusiones con primera respuesta nula | Defecto | DEC-05 |
| 5 | `sla_policy_version` | Fila `matrix` exige `n >= 10`, P75 y confianza | Defecto | EPIC §6.1/§6.3 |
| 6 | `sla_policy_version` | Fila `insufficient_evidence` exige `n < 10` | Defecto | BR-41/42 |
| 7 | `sla_commitment` | `policy_key` exige `policy_version_id` | Defecto | Integridad del snapshot |
| 8 | `sla_commitment` | `provisional` solo en `fallback` | Defecto | BR-43 |
| 9 | `sla_commitment` | `assigned` exige snapshot completo y ambos vencimientos | Defecto | 5G.4.5 §4.2 |
| 10 | `sla_commitment` | `assigned` solo con clase `matrix` o `fallback` | Endurecimiento | Semántica de asignación |
| 11 | `sla_commitment` | Vencimientos presentes si y solo si `assigned` | Defecto | 5G.4.5 §4.2 |
| 12 | `sla_commitment` | `no_policy` exige versión y clase `insufficient_evidence`, con ambas duraciones nulas | Defecto | 5G.4.5 §6.1 |
| 13 | `sla_commitment` | `excluded_non_service` exige snapshot de exclusión y métricas nulas | Defecto | DEC-05 |
| 14 | `sla_commitment` | `pending`, `historical` y `non_email` sin política, versión, clase ni duraciones | Defecto | 5G.4.5 §6.1 |
| 15 | `sla_commitment` | Primera respuesta: `met` exige marca, `pending` la prohíbe, nunca anterior al inicio | Defecto | BR-23/BR-26 |
| 16 | `sla_commitment` | `first_response_due_at` exige `started_at` | Defecto | BR-24 |
| 17 | `sla_commitment` | `late_classification` exige vencimiento resuelto y comparación estricta | Defecto | BR-44 |
| 18 | `sla_cycle` | `open` no tiene cierre; `missed_at_birth` puede estar abierto o cerrado | **Defecto** | Reglas de ciclos §9 |
| 19 | `sla_cycle` | `met`/`missed` exigen cierre y comparación con `due_at`; borde inclusivo | Defecto | BR-33 |
| 20 | `sla_cycle` | `missed_at_birth` exige `due_at` y solo en ciclo 1 | Defecto | BR-44 |
| 21 | `sla_cycle` | Índice único de ciclo abierto sobre `closed_at IS NULL` | Defecto | BR-40 |
| 22 | `sla_event` | `idempotency_key` debe ser SHA-256 hexadecimal en minúsculas | Endurecimiento | BR-61 |
| 23 | `sla_event` | `ignored` o `failed` exigen `status_reason` | Endurecimiento | Trazabilidad |
| 24 | `sla_article_delivery` | `accepted_at` exige fuente | Defecto | 5G.4.5 §4.5 |
| 25 | `sla_article_delivery` | Estado fallido exige `failed_at` | Defecto | 5G.4.5 §4.5 |
| 26 | `sla_alert` | Canal `webhook` eliminado: solo `internal` y `email` | **Defecto de contradicción** | 5G.4.5 línea 49 |
| 27 | `sla_audit` | `alert_config` eliminado: no existe tabla de configuración de alertas | **Defecto de referencia colgante** | Modelo de 9 tablas |
| 28 | `sla_audit` | `reclassify` exige `old_value` y `new_value` | Endurecimiento | Auditabilidad |
| 29 | `sla_sync_run` | `watermark_after` solo obligatorio en `kind = 'incremental'` | **Defecto** | 5G.4.5 §7 |
| 30 | Comentario | «Singapure» → «Garantiza» | Corrección editorial | — |

**Defectos reales corregidos:** 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 24, 25, 26, 27, 29. **Endurecimientos:** 1, 10, 22, 23, 28. **Editorial:** 30.

### 6.3 Defectos y decisiones que **no** se corrigieron

| # | Tema | Por qué no se tocó | Qué se necesita |
|---:|---|---|---|
| 1 | REA-02 y `due_at` del ciclo N+1 | Es una decisión funcional, no un defecto de esquema | Decisión escrita |
| 2 | `policy_class` | El DDL lo incluye, pero 5G.4.5 no lo define | Confirmación OBS-31 #1 |
| 3 | `excluded_non_service` | El DDL lo incluye; 5G.4.5 lista 5 estados | Confirmación OBS-31 #2 |
| 4 | `threshold_pct = 100` | BR-54 lo exige; 5G.4.5 solo admite 75/90 | Confirmación OBS-31 #3 |
| 5 | `catalog_mirror_mismatch` | BR-66 lo exige; 5G.4.5 no lo lista | Confirmación OBS-31 #5 |
| 6 | Canal de alerta `internal`/`email` | Se eliminó `webhook` por la prohibición expresa; el conjunto final no está aprobado | Confirmación junto con OBS-31 |
| 7 | Registro de migraciones | Una décima tabla `sla_schema_migration` cambiaría el modelo | **Recomendación emitida (17/11/2026):** tabla propia con guarda de doble aplicación. Ver `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §7. Decisión del responsable técnico |
| 8 | Clasificación vigente | OBS-33; requiere decidir entre columna, tabla o derivación | **Recomendación emitida (17/11/2026):** tabla `sla_classification`. Ver `PAQUETE_APROBACION_PRE_MIGRACION_SLA.md` §6. Decisión del responsable técnico |
| 9 | Unicidad de filas `pending` | El índice único parcial solo cubre `active`; dos `pending` podrían coexistir | Endurecimiento opcional |
| 10 | `closed_at` en ciclos `excluded` | Se mantiene la interpretación previa: `closed_at` registra el instante de exclusión, no un cierre válido | Confirmación de la interpretación |
| 11 | Nombres `updated_at_fallback` y `updated_at` | 5G.4.5 usa nombres distintos en `first_response_source` y `accepted_at_source` | Ninguna; se respeta la especificación |

### 6.4 Consistencias verificadas

| Verificación | Resultado |
|---|---|
| 27 + 3 + 1 + 7 = 38 filas de política | Correcto |
| 27 + 3 + 28 + 7 = 65 subcategorías | Correcto |
| Las 30 filas de la matriz se consumen una vez | Correcto |
| Las 7 exclusiones se consumen una vez | Correcto |
| Los 3 slugs duplicados no se usan como clave | Correcto: la clave usa el par categoría/subcategoría |
| `Cambio de razón social` produce dos políticas distintas | Correcto: 4.320 min y respaldo 2.160 min |
| Escalera de resolución | 17 valores, idénticos a EPIC §6.1 |
| Calendario | 24/7; sin columnas de horario ni pausas |
| Primera respuesta | 1.440 min, borde estricto en la aplicación, no en el `CHECK` |
| Retención de eventos | 2 años; referencias lógicas sin FK |
| Auditoría | Append-only por privilegios; sin triggers |
| `gen_random_uuid()` | Disponible sin extensión en PostgreSQL 13+ |

---

## 7. Frontera con Prisma (OBS-29)

| Decisión | Consecuencia operativa |
|---|---|
| Prisma no modela las 9 tablas SLA | `schema.prisma` sigue con `GenerateAnchor` |
| DDL y evolución solo por SQL manual | El historial real es el archivo SQL y su registro documental |
| Prohibido `prisma db pull` sobre una base con SLA | Evita sobrescribir el ancla y perder la expresividad del SQL |
| Prohibido `prisma migrate`, `db push` y `migrate dev` | Evita un historial paralelo al SQL manual |
| Acceso del motor por SQL tipado | No se usa el cliente generado para estas tablas |

**Riesgo residual:** sin tabla de control de migraciones, el estado aplicado es documental. El procedimiento M1–M8 exige registrar hash, fecha, usuario y base. Si se aprueba una décima tabla, debe decidirse antes de aplicar `001`.

---

## 8. Riesgos y condiciones para el DBA

| Riesgo | Estado | Mitigación |
|---|---|---|
| Aplicar el DDL sobre producción | Controlado en el archivo | Guarda de base y rol; M1/M2; lista negra de host |
| Base de prueba inexistente | **Abierto** (BLK-05) | Solicitud §4.2 del plan |
| Procedimiento de migración no aprobado | **Abierto** (BLK-06) | Aprobar M1–M8 antes de aplicar |
| Restricciones no reproducibles por Prisma | Documentado | SQL manual; verificación estructural |
| Pérdida de datos por rollback | Documentado | Respaldo R1/R2; rollback sin `CASCADE` |
| Clasificación vigente no consultable | **Abierto** (OBS-33) | Decidir antes de la interfaz |
| Reaperturas sin vencimiento definido | **Abierto** (OBS-28) | Decisión funcional antes de implementar |
| Carga de políticas sin ratificación | **Abierto** (OBS-30) | DP-04 y AP-01 antes de la carga |

**Condición de aplicación:** BLK-05 y BLK-06. **Condición de implementación:** además, OBS-27, OBS-28, OBS-30 y OBS-33.

---

## 9. Lo que esta revisión no aprueba

- No aprueba AP-01, AP-02 ni AP-03: siguen en `conditional_pending_final_validation`.
- No declara cerrada la Épica 1 ni la épica anterior.
- No aprueba REA-02 ni ninguna alternativa de ciclo.
- No aprueba las cuatro confirmaciones de OBS-31.
- No ratifica la clasificación de las 28 subcategorías con respaldo.
- No aprueba la tabla de control de migraciones.
- No aprueba la solución de OBS-33.
- No autoriza ejecutar `001_diseno_esquema_sla.sql`.
- No autoriza implementar el motor ni crear endpoints.
- No convierte ninguna propuesta del DDL en regla aprobada.

---

## 10. Verificación ejecutada en esta revisión

| Verificación | Resultado |
|---|---|
| Rama y HEAD antes | `remediation/audit`, `27b973a` |
| Rama y HEAD después | `remediation/audit`, `27b973a` |
| Cambios en `docs/captures/` | 58, intactos |
| Commits creados | 0 |
| `CHECK` con nombre en el DDL | 100 |
| Índices con nombre | 24 |
| Claves foráneas | 4 |
| Tablas | 9 |
| Sentencias de escritura en el DDL | 0 |
| Conexiones a PostgreSQL | 0 |
| Ejecuciones de SQL | 0 |
| Pruebas de integración | 0 |
| Script de verificación estructural | Creado, **no ejecutado** |

El script `sql/001_verificacion_diseno_sla.sql` comprueba, tras una eventual aplicación: existencia de las 9 tablas, los 100 `CHECK`, las 4 `FK`, los 24 índices, los 3 predicados parciales, ausencia de triggers, tablas vacías antes de la carga, privilegios de `sla_audit` y disponibilidad de `gen_random_uuid()`. No se ejecutó porque no existe la base.

---

## 11. Entregables de esta revisión

| Archivo | Cambio |
|---|---|
| `REVISION_DECISIONES_PENDIENTES_SLA.md` | Nuevo: este documento |
| `MATRIZ_POLITICAS_CATALOGO_SLA.md` | Nuevo: 65 filas, 27/3/28/7, verificado por generador |
| `DISEÑO_ESQUEMA_BD_SLA.md` | Actualizado: restricciones, frontera Prisma, decisiones y revisión |
| `sql/001_diseno_esquema_sla.sql` | Corregido: 30 cambios de §6.2 |
| `sql/001_rollback_diseno_sla.sql` | Sin cambios de fondo; se conserva como evidencia |
| `sql/001_verificacion_diseno_sla.sql` | Nuevo: verificación estructural, no ejecutado |
| `OBSERVACIONES_TECNICAS_BACKEND_SLA.md` | Actualizado: estados, OBS-33 y recuento corregido |
| `CIERRE_TECNICO_BACKEND_SLA.md` | Actualizado: estado tras la consolidación |
| `PLAN_DESBLOQUEO_IMPLEMENTACION_SLA.md` | Actualizado: OBS-31 pasa a 4 confirmaciones |

---

## 12. Confirmación

- No se ejecutó SQL en ninguna base de datos.
- No se creó ni modificó ninguna base, rol, tabla, índice o restricción.
- No se conectó a PostgreSQL, a producción ni a la base empresarial.
- No se tocó Zammad, sus tablas, sus workers ni sus credenciales.
- No se modificó `public.v_unificado_norm` ni ninguna vista o tabla existente.
- No se alteró el catálogo original ni el JSON exportado.
- No se modificaron los 58 archivos de `docs/captures/`.
- No se crearon triggers, funciones ni extensiones.
- No se hizo commit ni push.
- No se marcó ninguna prueba no ejecutada como aprobada.
