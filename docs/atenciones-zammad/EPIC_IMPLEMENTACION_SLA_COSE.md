# EPIC-SLA-01 — ÉPICA MAESTRA DE IMPLEMENTACIÓN DEL SLA C.O.S.E.

**Proyecto:** MAILING — C.O.S.E. sobre Zammad 7.2.3
**Épica:** EPIC-SLA-01
**Versión del documento:** 1.1
**Fecha de consolidación:** 16/11/2026
**Naturaleza:** documento maestro de planificación y trazabilidad. **No implementa nada.**
**Base documental:** 59 documentos previos en `docs/atenciones-zammad/`. Este documento es el número 60 y no los sustituye.
**Estado general:** diseño funcional cerrado; **implementación no iniciada**; decisiones funcionales confirmadas; tres aprobaciones condicionales pendientes de validación final.

> **Regla de lectura.** Este documento consolida, ordena y traza. No crea reglas nuevas ni cambia valores de la matriz. Cuando hay conflicto, prevalecen `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` y los seis documentos de 5G.4.5 sobre cualquier propuesta anterior incompatible. Los documentos originales se conservan íntegros y no se editan.

---

## RESUMEN DE LA ÉPICA

| Elemento | Definición |
|---|---|
| Qué se quiere construir | Un motor propio de SLA para atención **exclusivamente por correo electrónico** sobre Zammad, sin usar el motor SLA nativo ni escribir en Zammad. |
| Dónde vive el motor | En el BFF de C.O.S.E., con base de datos propia. |
| Cómo se clasifica | Manualmente, por el asesor, con categoría y subcategoría del catálogo oficial. Sin IA, sin palabras clave, sin clasificación automática. |
| Qué se mide | Primera respuesta pública de agente confirmada por envío, en estricto menos de 24 h; y resolución por combinación categoría/subcategoría, según 27 políticas. |
| Cómo se mide | Calendario continuo 24/7, sin pausas; inicio en `created_at`; cierre en el primer estado `closed`; ciclo 1 como métrica oficial. |
| Meta | Cumplimiento global ≥ 80 %, con denominador y exclusiones publicados. |
| Estado actual | Reglas y arquitectura diseñadas. Motor, frontend y dashboard **no implementados**. Fase 0: 4 con evidencia de lectura (3 `passed` + F0-01 apertura); 7 `pending`, 3 `blocked`, 4 `deferred`. |
| Decisiones confirmadas | **DT-01** (BFF como fuente), **DT-02** (65 con marca), **DP-04** (Soporte) y exclusión de las 7 subcategorías no servicio. |
| Aprobaciones condicionales | **AP-01**, **AP-02** y **AP-03** en `conditional_pending_final_validation`. |
| Compuerta principal | No se implementa el motor hasta la validación final de AP-01, AP-02 y AP-03 y el cierre de la Fase 0. |

---

# 1. IDENTIFICACIÓN DE LA ÉPICA

## 1.1 Ficha de identificación

| Campo | Valor |
|---|---|
| Identificador | **EPIC-SLA-01** |
| Nombre | Implementación del motor SLA C.O.S.E. para correo electrónico |
| Programa | MAILING / C.O.S.E. |
| Plataforma de tickets | Zammad 7.2.3 |
| Canal del alcance | Correo electrónico |
| Tipo de épica | Épica maestra de diseño, implementación, validación, frontend, pruebas y aceptación |
| Documento maestro | `docs/atenciones-zammad/EPIC_IMPLEMENTACION_SLA_COSE.md` |
| Versión | 1.0 |
| Estado | Diseño funcional cerrado; implementación pendiente; decisiones funcionales confirmadas; tres aprobaciones condicionales |
| Autoridad documental | 5G.4.5 para reglas funcionales; 5G.4.4 para alcance Email y matriz; 5G.3 para principios de medición no contradichos |
| Entorno de pruebas | Buzón piloto ya conectado a Zammad. **No se conecta el buzón definitivo mientras Zendesk lo gestione.** |
| Sistemas que no se modifican | Zammad (salvo autorizaciones futuras expresas), Zendesk, COSE, PostgreSQL de COSE, Redis |

## 1.2 Roles que intervienen

La épica nombra roles, no personas. No se asignan responsables nominales ni fechas.

| Rol | Función en la épica |
|---|---|
| Asesor de Soporte Especializado | Recibe el correo, clasifica manualmente y responde. Es el único que origina la clasificación. |
| Supervisor / jefatura | Consulta cumplimiento, vencimientos, cartera pendiente y reportes. |
| Dueño del catálogo SLA | **Soporte**, responsable funcional y operativo confirmado (DP-04). Decide la vigencia del catálogo y su proceso de actualización. |
| Administrador de Zammad | Ejecuta, solo con autorización, la creación del usuario técnico de solo lectura, el token y las pruebas de escritura controladas. |
| TI / infraestructura | Provisión del BFF, base de datos, respaldos, secretos, supervisor de procesos y recursos. |
| Responsable de negocio | Aprueba matriz, reglas, criterios de aceptación, alcance del piloto y aceptación final. |
| Equipo de COSE | Adapta la interfaz y los reportes, y consume los datos del BFF sin acoplarse a la base de Zammad. |
| Auditoría | Verifica trazabilidad, inmutabilidad del compromiso y motivo obligatorio en correcciones. |

## 1.3 Qué es y qué no es esta épica

| Es | No es |
|---|---|
| Una épica de implementación por etapas, con compuertas verificables | Un documento de diseño nuevo que reemplace los 59 anteriores |
| Un contrato de alcance, reglas, dependencias y aceptación | Una autorización para escribir en Zammad, COSE o Zendesk |
| Un plan de pruebas con evidencia exigida | Una estimación de esfuerzo, plazo o costo |
| Un mapa de trazabilidad entre decisiones y entregables | Una declaración de funcionalidades ya implementadas |

## 1.4 Decisiones confirmadas y aprobaciones condicionales

### 1.4.1 Decisiones confirmadas

| ID | Decisión | Registro | Efecto |
|---|---|---|---|
| DT-01 | El **BFF es la fuente oficial** de la clasificación manual. | Confirmada, 16/11/2026 | El motor no infiere la categoría desde Zammad. |
| DT-01b | El campo `categoria_subcategoria` de Zammad es un **espejo opcional**, sujeto a verificación de divergencias. | Confirmada, 16/11/2026 | Si se usa, se compara con el par del BFF y se registra divergencia. |
| DT-02 | Selector con las **65 subcategorías** y **marca de política** (con SLA / sin evidencia / respaldo). | Confirmada, 16/11/2026 | No se oculta el 32,51 % fuera de matriz. |
| DP-04 | Responsable funcional y operativo del catálogo: **Soporte**. | Confirmada, 16/11/2026 | Deja de ser decisión abierta. |
| DEC-05 | Las **7 subcategorías no servicio** (SIN HOMOLOGAR 3, RECLAMO 1, QUEJA 3) quedan **excluidas del motor SLA**, sin SLA y sin respaldo 36 h. | Confirmada, 16/11/2026 | No entran al denominador. |

### 1.4.2 Aprobaciones condicionales

| ID | Materia | Estado | Efecto |
|---|---|---|---|
| AP-01 | Aprobación definitiva de 5G.4.5 | `conditional_pending_final_validation` | No es aprobación definitiva. |
| AP-02 | Ratificación definitiva del alcance Email-only | `conditional_pending_final_validation` | No es ratificación definitiva. |
| AP-03 | Autorización para ejecutar Fase 0 | `conditional_pending_final_validation` | No autoriza ejecución todavía. |

**Regla:** estas tres aprobaciones no se convierten en definitivas hasta la validación final expresa. Ninguna prueba de Fase 0 se ejecuta con una aprobación condicional.

---

# 2. CONTEXTO Y PROBLEMA

## 2.1 Situación de partida

C.O.S.E. atiende hoy por correo electrónico y utiliza Zendesk como motor de conversación. La operación (dominio, categoría, calificación, auditoría, Quejas y Devoluciones, LocalBI y TicketBI) vive en COSE. Se está migrando la conversación a Zammad 7.2.3, que ya recibió correo real en un buzón piloto y respondió con firma institucional.

La instalación piloto verificada tiene:

| Elemento | Valor de línea base |
|---|---|
| Políticas SLA nativas | **0** |
| Calendarios | **2** (`My Calendar` y `Soporte Especializado`) |
| Triggers | 3 definidos, **0 activos** |
| Webhooks | **0** |
| Tickets / artículos | 2 / 5 |
| Usuarios / grupos | 6 / 3 |
| Canales | Correo piloto (Google) y notificación |
| Worker | **Detenido** |
| Reportes nativos | Deshabilitados (`Report.enabled? = false`) |

## 2.2 El problema

Zammad no tiene una política SLA operativa. Su motor nativo mide en tiempo hábil, depende de calendarios y recalcula al cambiar la clasificación. Eso no sirve para el compromiso que C.O.S.E. quiere medir:

1. **El compromiso debe congelarse al clasificar.** Una reclasificación posterior no puede mejorar ni empeorar el plazo ya adquirido.
2. **La medición debe ser calendario 24/7.** No hay horario hábil, feriados ni pausas por estado.
3. **La resolución debe diferenciarse por categoría y subcategoría.** Una meta única no representa el trabajo real.
4. **La primera respuesta debe medirse con la confirmación de envío**, no con la creación del artículo. `first_response_at` de Zammad no es confiable para esto.
5. **La fuente de verdad no se puede modificar.** La integración debe ser de solo lectura y demostrablemente incapaz de escribir.

La consecuencia es que el SLA debe vivir en un **motor propio**, alimentado por la API de Zammad, sin tocar su configuración ni su base de datos.

## 2.3 Evidencia que cambió el diseño

| Hallazgo | Consecuencia |
|---|---|
| `first_response_at` se fija al crear el artículo, no al confirmar el envío (ticket 7: 9 h 34 min de diferencia) | El motor ignora `first_response_at` y usa `delivery_status_date`. |
| `delivery_status = success` eleva `ticket.updated_at` mediante `after_commit :ticket_touch` | El sondeo por `updated_at` es viable; la Fase 0 debe confirmarlo con un envío real. |
| Los webhooks no ven actualizaciones de artículo (`lib/transaction_dispatcher.rb` 148-150) | El sondeo no es una preferencia: es la única vía verificada para observar la entrega. |
| `close_at` se fija en el primer cierre y no se reescribe; `last_close_at` sí se actualiza | Zammad ya conserva la marca del ciclo 1; el motor no la reconstruye. |
| `pending close` es tipo `pending action`, no `closed` | No cierra ni pausa el reloj. |
| `merged` es tipo `merged`, no `closed` | No cierra; se excluye con divergencia. |
| Un fallo definitivo de envío (`delivery_retry > 3`) crea una nota interna y reabre el ticket | El motor debe tratar esa reapertura como un hecho real, no como un error. |
| En 10 de 30 filas la categoría oficial difiere de la categoría COSE | El motor clasifica con la matriz oficial, no con `v_unificado_norm.categoria`. |
| El 32,51 % del volumen clasificado de Email está fuera del catálogo de la matriz | El respaldo de 36 h no es marginal: gobernaría 1 de cada 3 tickets. |

## 2.4 Restricciones estructurales

1. Zammad es la fuente de hechos de tickets, artículos, usuarios, grupos y estados.
2. El BFF no escribe en Zammad en ninguna fase.
3. Cero SLA nativos; `ignore_escalation` intacto.
4. La clasificación es un dato manual y auditable, no una inferencia.
5. El compromiso se congela al clasificar.
6. El buzón piloto es el entorno de pruebas; el definitivo sigue en Zendesk.
7. No se toca Zendesk productivo ni COSE productivo sin autorización separada.
8. WhatsApp, WHATMETA, WHATICKET y mensajería instantánea están fuera del alcance.

---

# 3. OBJETIVO GENERAL

## 3.1 Objetivo

Implementar, validar y poner en operación controlada un motor propio de SLA para la atención por correo electrónico de C.O.S.E. sobre Zammad 7.2.3, que:

1. reciba la clasificación manual del asesor;
2. asigne un compromiso de resolución según la matriz oficial de 27 políticas;
3. mida la primera respuesta pública confirmada por envío en estricto menos de 24 h;
4. mida la resolución con calendario 24/7 y ciclo 1 como métrica oficial;
5. emita alertas, auditoría, divergencias y reconciliación;
6. exponga cumplimiento y cartera en la interfaz de C.O.S.E.;
7. lo haga sin modificar Zammad, sin SLA nativos y sin almacenar datos personales innecesarios.

## 3.2 Objetivos específicos

| # | Objetivo específico | Se verifica con |
|---:|---|---|
| 1 | Cerrar las decisiones y aprobaciones que bloquean la implementación | Etapa 1 y compuerta de Fase 0 |
| 2 | Construir el motor con modelo de datos propio, idempotente y recuperable | Etapa 2 |
| 3 | Validar las 27 combinaciones con SLA, las 3 sin evidencia y el respaldo 36 h | Etapa 3 |
| 4 | Adaptar la interfaz de C.O.S.E. para clasificar y visualizar el SLA | Etapa 4 |
| 5 | Probar el recorrido real de extremo a extremo | Etapa 5 |
| 6 | Entregar dashboard, reportes, documentación operativa y aceptación final | Etapa 6 |

## 3.3 Métricas de éxito de la épica

| Métrica | Meta | Condición de medición |
|---|---|---|
| Cumplimiento de primera respuesta | **≥ 80 %** | `met / (met + missed)` sobre compromisos asignados y evaluables |
| Cumplimiento de resolución (ciclo 1) | **≥ 80 %** | `C1.met / (C1.met + C1.missed)` |
| Cobertura de la matriz | ≥ 66,78 % del universo de servicio Email con SLA | 2.087 / 3.125, valor histórico de referencia |
| Políticas con SLA reproducidas | 27 de 27, sin recalcular valores | Validación contra matriz 5G.4.4 |
| Combinaciones sin evidencia | 3, sin SLA y fuera del denominador | n < 10 |
| Escrituras en Zammad | **0** | 10 de 11 con 403; caso 7 documentado (7a/7b); sin `2xx` inesperado |
| Datos personales almacenados | **0** cuerpos, 0 direcciones, 0 adjuntos | Inspección de esquema y payloads |
| Duplicados aplicados | **0** | 100 inserciones del mismo evento → 1 fila |
| Pérdida de eventos tras caída | **0** | Recuperación desde watermark |

## 3.4 No objetivos

| No objetivo | Motivo |
|---|---|
| Gestionar WhatsApp, WHATMETA o WHATICKET | Fuera del alcance vigente |
| Usar el motor SLA nativo de Zammad | Cero políticas nativas por diseño |
| Clasificar con IA, palabras clave o asunto | La clasificación es un dato manual |
| Medir productividad individual como compromiso | No es un compromiso con el cliente |
| Medir satisfacción (CSAT) | No hay dato fiable en el alcance |
| Reemplazar a Zammad | Zammad sigue siendo la fuente de hechos |
| Migrar Zendesk en esta épica | Requiere decisión y autorización separadas |
| Conectar el buzón definitivo | Zendesk lo gestiona todavía |
| Integrar COSE de forma productiva sin autorización | Prohibido por alcance |

---

# 4. ALCANCE Y EXCLUSIONES

## 4.1 Dentro del alcance

| Elemento | Detalle |
|---|---|
| Canal | Correo electrónico exclusivamente |
| Tickets | Tickets del grupo de Soporte Especializado, creados desde la fecha de activación del motor |
| Clasificación | Categoría y subcategoría del catálogo oficial, seleccionadas manualmente por el asesor |
| Resolución | 27 combinaciones con SLA; 3 sin evidencia; respaldo 36 h solo fuera de catálogo |
| Primera respuesta | Artículo público de agente, tipo `email`, con `delivery_status = success` |
| Medición | Calendario 24/7, sin pausas, en UTC; presentación en zona de Perú |
| Ciclos | Ciclo 1 oficial; reaperturas como indicador operativo |
| Alertas | 75 %, 90 % y vencimiento |
| Auditoría | Append-only, con motivo obligatorio en correcciones |
| Reconciliación | Incremental, diaria y semanal de integridad |
| Seguridad | Usuario técnico con acceso `read`; cliente HTTP solo `GET` |
| Persistencia | PostgreSQL del BFF con respaldo y reconstrucción desde eventos |
| Frontend | Adaptación de la bandeja y ficha de ticket de C.O.S.E. |
| Dashboard | Cumplimiento global, por categoría, subcategoría y asesor; cartera y vencimientos |
| Documentación | Operativa, técnica y de aceptación |

## 4.2 Fuera del alcance

| Elemento | Estado |
|---|---|
| WhatsApp | Excluido |
| WHATMETA | Excluido |
| WHATICKET | Excluido |
| SLA de mensajería instantánea | Excluido |
| Migración de Zendesk | Excluida de esta épica |
| Conexión del buzón definitivo mientras Zendesk lo gestione | Excluida |
| Integraciones productivas con COSE no autorizadas | Excluidas |
| Creación de SLA nativos en Zammad | Prohibida |
| Modificación de estados, calendarios, triggers, webhooks, atributos o workers de Zammad | Prohibida sin autorización separada |
| Modificación de la base de datos de COSE | Prohibida |
| Clasificación automática o por IA | Prohibida |
| Medición de CSAT | Fuera de alcance |
| Cambio del tema visual C.O.S.E. en esta tarea documental | Prohibido |

## 4.3 Fronteras operativas

| Frontera | Regla |
|---|---|
| Buzón | Se mantiene el correo piloto como entorno de pruebas. El buzón definitivo no se conecta mientras Zendesk lo gestione. |
| Zendesk | Solo lectura histórica. No se modifica ni se migra en esta épica. |
| COSE productivo | No se modifica. La etapa 4 consume el BFF; no escribe en la base de COSE. |
| Zammad | La integración es de solo lectura. Cualquier escritura de prueba requiere autorización explícita y ventana controlada. |
| Datos históricos | La ventana estadística 01/04/2026–31/10/2026 es la fuente de la matriz. No se recalcula. |
| Fecha de activación | Solo se crean compromisos para tickets con `created_at >= activation_at`. |

## 4.4 Autorización de esta tarea

Esta creación documental está autorizada únicamente para leer los 59 documentos y escribir este documento maestro. **No autoriza** código, tablas, migraciones, PostgreSQL, Redis, configuración de Zammad, SLA nativos, triggers, webhooks, usuarios, permisos, buzones, correos, workers, dependencias, CSS, Zendesk ni COSE.

---

# 5. REGLAS DE NEGOCIO DEFINITIVAS

Las reglas se numeran para poder citarlas en historias, pruebas y actas. Todas provienen de 5G.3, 5G.4.4 y 5G.4.5. Ninguna se inventa en este documento.

## 5.1 Canal, fuente y soberanía del dato

| ID | Regla | Origen |
|---|---|---|
| BR-01 | El único canal del SLA es **correo electrónico**. WhatsApp, WHATMETA, WHATICKET y mensajería instantánea están fuera. | 5G.4.4 §1 |
| BR-02 | Zammad es la fuente de hechos de tickets, artículos, estados, usuarios y grupos. | 5G.4.4 §1 |
| BR-03 | El motor SLA es propio y vive en el BFF. No se usa el motor nativo de Zammad. | 5G.3 / 5G.4.4 |
| BR-04 | Cero políticas SLA nativas. `ignore_escalation` permanece intacto. | 5G.4.4 §1 |
| BR-05 | La integración **no escribe** en Zammad: solo `GET`. La restricción es de permisos, no una convención. | 5G.4.5 §12 |
| BR-06 | El motor no lee cuerpos de correo, adjuntos, direcciones del cliente ni teléfonos. | 5G.4.5 §2.2 y §12.3 |

## 5.2 Clasificación manual

| ID | Regla | Origen |
|---|---|---|
| BR-07 | La clasificación la realiza **manualmente el asesor**. No hay clasificación automática, por IA, por palabras clave ni por asunto. | 5G.4.5 §8 |
| BR-08 | La clasificación es la combinación **categoría + subcategoría** del catálogo oficial. | 5G.4.5 §8 |
| BR-09 | El motor clasifica con el **catálogo oficial de la matriz**, no con la columna `categoria` de COSE. En 10 de 30 filas difieren. | 5G.4.5 §8 |
| BR-10 | Sin categoría o sin subcategoría, el ticket queda en `pending_classification`. | 5G.4.5 §8 |
| BR-11 | Un ticket `pending_classification` **no recibe** el respaldo de 36 h ni ningún compromiso anticipado. | 5G.4.5 §8 |
| BR-12 | El motor registra la fecha de clasificación (`classified_at`) y la fecha de asignación (`assigned_at`). | 5G.4.5 §9 |
| BR-13 | El compromiso se **congela** al clasificar. Ningún cambio posterior de categoría, política, calendario o prioridad lo altera. | 5G.3 / 5G.4.5 §6.1 |
| BR-14 | Una reclasificación se registra y cuenta, pero **no cambia** `policy_key`, `resolution_minutes`, `started_at` ni `due_at`. | 5G.4.5 §6.1 |
| BR-15 | Una corrección del snapshot solo se admite con auditoría, motivo y aprobación (CON-04). | 5G.4.5 §4.2 |

**Fuente de clasificación (DT-01 confirmada):** el BFF es la fuente oficial; el campo de Zammad es un espejo opcional. La regla BR-09 se mantiene: la política se genera desde la categoría oficial de la matriz, nunca desde COSE.

## 5.3 Medición del tiempo

| ID | Regla | Origen |
|---|---|---|
| BR-16 | El calendario es continuo **24/7**, sin horario hábil, feriados ni pausas. | 5G.3 §1 |
| BR-17 | El compromiso de resolución inicia en `created_at` del ticket. | 5G.3 / 5G.4.5 §6.3 |
| BR-18 | El almacenamiento y el cálculo se hacen en **UTC**. La presentación en zona de Perú (UTC−5) es solo de reporte. | 5G.4.5 §12 |
| BR-19 | La precisión es de segundos. | 5G.4.5 §12 |
| BR-20 | `pending close` **no** detiene el reloj, no cierra y no pausa. | 5G.4.5 §10 |
| BR-21 | `pending reminder` y cualquier otro estado pendiente tampoco pausan. | 5G.3 §1 |
| BR-22 | La reasignación de agente o el cambio de prioridad no reinician el reloj. | 5G.3 RES-05 |

## 5.4 Primera respuesta

| ID | Regla | Origen |
|---|---|---|
| BR-23 | La meta de primera respuesta es **estrictamente menos de 24 horas** (86.400 s). El instante exacto de 24 h **no cumple**. | 5G.4.5 §1 |
| BR-24 | El inicio es `created_at` del ticket. | 5G.4.5 §1 |
| BR-25 | Solo cuenta un artículo que cumpla las cinco condiciones: `internal = false`, `sender = Agent`, `type = email`, `delivery_status = success`, `created_at >= ticket.created_at`. | 5G.4.5 §2 |
| BR-26 | La fecha de respuesta es `delivery_status_date`. Si falta, se usa `updated_at` del artículo como fallback conservador. | 5G.4.5 §3 |
| BR-27 | El motor **nunca** usa `created_at` del artículo ni `first_response_at` de Zammad como fecha de respuesta. | 5G.4.5 §3.3 |
| BR-28 | `delivery_status = success` prueba que el servidor de salida **aceptó** el mensaje. No prueba llegada al buzón ni lectura. Todo reporte debe decirlo así. | 5G.4.5 §4 |
| BR-29 | Un `fail` con `delivery_retry ≤ 3` es provisional y no cuenta todavía. Un `fail` con `delivery_retry > 3` es definitivo y no cuenta nunca. | 5G.4.5 §5 |
| BR-30 | Las notas internas, los artículos del cliente, los del sistema y los de tipo distinto de `email` no cuentan. | 5G.4.5 §2 |
| BR-31 | La primera respuesta se mide solo en el ciclo 1 y no se recalcula al reabrir. | 5G.4.5 §6 y §13 |

## 5.5 Resolución, cierres y ciclos

| ID | Regla | Origen |
|---|---|---|
| BR-32 | La resolución termina en el **primer estado de tipo `closed`**. | 5G.4.5 §3 |
| BR-33 | El borde de resolución es inclusivo: `closed_at ≤ due_at` cumple. | 5G.4.5 §2 |
| BR-34 | `merged` **no** es cierre válido. Se excluye con `exclusion_reason = 'merged'` y divergencia `merged_ticket`. | 5G.4.5 §6 |
| BR-35 | Un ticket eliminado se excluye con `exclusion_reason = 'ticket_deleted'` y divergencia `orphan_ticket`. Sus datos se conservan. | 5G.4.5 §7 |
| BR-36 | Una reapertura es una transición desde `closed` hacia un estado que no es `closed` ni `merged`. Abre un **ciclo nuevo**. | 5G.4.5 §4 |
| BR-37 | El **ciclo 1** es la métrica oficial de resolución. Los ciclos 2..N son indicador operativo. | 5G.4.5 §1 y §13 |
| BR-38 | Cada ciclo nuevo usa la **misma política congelada**, con `due_at = opened_at + resolution_minutes`. | 5G.4.5 §4.2 |
| BR-39 | Un ticket reabierto por fallo definitivo de envío se mide como reapertura real y se anota `reopen_hint = delivery_failure`. | 5G.4.5 §5 |
| BR-40 | Como máximo existe un ciclo `open` por compromiso. | 5G.4.5 §11 |

## 5.6 Excepciones y clasificación tardía

| ID | Regla | Origen |
|---|---|---|
| BR-41 | Las 3 combinaciones con n < 10 quedan **sin SLA**, con `assignment_status = 'no_policy'` y motivo `insufficient_evidence`. | 5G.4.4 §7 / 5G.4.5 §3.2 |
| BR-42 | Las 3 combinaciones sin evidencia **no** reciben el respaldo de 36 h. | 5G.4.4 §7 |
| BR-43 | El respaldo de **36 h (2.160 min)** aplica solo a subcategorías **fuera del catálogo**, con `provisional = true`. | 5G.4.4 §9 / 5G.4.5 §6.1 |
| BR-44 | Un ticket clasificado después de vencer su plazo se marca `late_classification = true` y `missed_at_birth`, con `started_at = created_at`. | 5G.4.5 §9 |
| BR-45 | La cartera clasificada tarde se publica como indicador **secundario**, nunca se oculta ni se mezcla con el principal. | 5G.4.5 §9.3 |
| BR-46 | Solo se crean compromisos para tickets con `created_at >= activation_at`. Los anteriores quedan `historical`, fuera de todo denominador. | 5G.4.5 §9.4 |
| BR-47 | Un ticket de un grupo fuera del alcance no se ingesta. Un ticket no-email se marca `non_email` y se registra divergencia. | 5G.4.5 §8 |

## 5.7 Cumplimiento, reportes y alertas

| ID | Regla | Origen |
|---|---|---|
| BR-48 | La meta global es **≥ 80 %** en primera respuesta y en resolución oficial. | 5G.3 §7 / 5G.4.5 §6.4 |
| BR-49 | El denominador de primera respuesta es `met + missed`. El de resolución oficial es `C1.met + C1.missed`. | 5G.4.5 §13 |
| BR-50 | Se excluyen de todos los denominadores: `no_policy`, `pending_classification`, `historical`, `non_email`, `excluded` por `merged` o `ticket_deleted`, y ciclos `open` no vencidos. | 5G.4.5 §13 |
| BR-51 | Un ciclo `open` con `due_at < corte` cuenta como `missed` provisorio, marcado `overdue_at_cutoff`. | 5G.4.5 §13 |
| BR-52 | Todo reporte publica numerador, denominador, excluidos por motivo, peso de lo provisional y la nota "envío aceptado ≠ entregado". | 5G.4.5 §11 |
| BR-53 | Está prohibido publicar un porcentaje sin su denominador. | 5G.4.5 §11 |
| BR-54 | Las alertas se emiten al 75 %, al 90 % y al vencimiento, una por compromiso, ciclo, métrica y umbral. | 5G.4.5 §8 |
| BR-55 | La banda de sondeo de 2 minutos aplica a primera respuesta pendiente con vencimiento a menos de 4 h; fuera de ella, 5 minutos. | 5G.4.5 §7 |

## 5.8 Seguridad, auditoría y persistencia

| ID | Regla | Origen |
|---|---|---|
| BR-56 | La credencial de integración es un usuario técnico con `groups_users.access = 'read'` y token de API, sin permiso `admin`. | 5G.4.5 §12.1 |
| BR-57 | La escritura de tickets está bloqueada por `TicketPolicy#update?`; la creación de artículos por `Ticket::ArticlePolicy#create?`; el borrado es solo admin. | 5G.4.5 §12.1 |
| BR-58 | El cliente HTTP solo permite `GET`. Los secretos viven en gestor de secretos, nunca en el repositorio ni en logs. | 5G.4.5 §12 / 5G.4.3 §4 |
| BR-59 | `sla_audit` es append-only. Sin `reason` no se permite `correct`, `publish` ni `deactivate`. | 5G.4.5 §9 |
| BR-60 | La reconciliación nunca modifica `started_at`, `due_at`, `policy_key` ni el snapshot. Solo agrega hechos y registra divergencias. | 5G.4.5 §10 |
| BR-61 | La inserción del evento y la transición se aplican en la misma transacción; la clave de idempotencia es `sha256('zammad' | event_type | ticket_id | entity_id | occurred_at_utc)`. | 5G.4.5 §3 |
| BR-62 | El watermark solo avanza si el run termina `ok`. Un run `failed` no avanza. | 5G.4.5 §7 |
| BR-63 | Los cuerpos de correo, adjuntos, direcciones y teléfonos no se almacenan. El mensaje de error se trunca a 500 caracteres. | 5G.4.5 §12.3 |
| BR-64 | La retención se aplica por tabla: compromisos y ciclos permanentes; auditoría 5 años; eventos 2 años; alertas y sync runs 1 año. | 5G.4.5 §14 |

## 5.9 Reglas incorporadas por decisiones confirmadas (16/11/2026)

| ID | Regla | Origen |
|---|---|---|
| BR-65 | Las 7 subcategorías no servicio (SIN HOMOLOGAR: Sin dato, Duplicado o spam, No contestó; RECLAMO: Reclamo; QUEJA: Servicio, Producto, Otro) quedan **excluidas del motor SLA**: sin SLA, sin respaldo de 36 h y fuera de todo denominador. | Decisión confirmada DEC-05 |
| BR-66 | La clasificación manual se registra en el **BFF** como par (categoría oficial, subcategoría oficial). El campo `categoria_subcategoria` de Zammad es un **espejo opcional**; si difiere, se registra divergencia y prevalece el BFF. | Decisión confirmada DT-01 |
| BR-67 | El selector de clasificación muestra las **65 subcategorías** con marca de política: con SLA (27), sin evidencia (3) o respaldo provisional (28). Las 7 no servicio no se ofrecen como clasificación de SLA. | Decisión confirmada DT-02 |

---

# 6. MATRIZ SLA Y FUENTE HISTÓRICA

## 6.1 Fuente y método

| Elemento | Valor |
|---|---|
| Fuente histórica | COSE `public.v_unificado_norm`, `canal = 'CORREO'` |
| Ventana | 2026-04-01 → 2026-10-31 |
| Universo de servicio | Cerrados/resueltos, `resolucion_min_norm > 0`, sin pseudo-categorías |
| Criterio estadístico | **P75** de la propia combinación |
| Redondeo | Primer escalón de la escalera ≥ P75 |
| Escalera | 15 · 30 · 45 · 60 · 90 · 120 · 180 · 240 · 360 · 480 · 720 · 1.440 · 2.160 · 2.880 · 4.320 · 5.760 · 7.200 min |
| Muestra mínima | n ≥ 10 |
| Unidad | Minutos calendario |
| Prohibiciones | No se usa mediana, promedio, P90, ni evidencia de otro canal |
| Matriz oficial | 30 filas: 27 con SLA, 3 sin evidencia |

**Fórmula:**

```
SLA_resolución = menor escalón de la escalera ≥ P75 de la combinación
```

## 6.2 Universo medido

| Paso | Criterio | Tickets |
|---|---|---:|
| A | Email en la ventana, todos los estados | 4.834 |
| B | Cerrado o resuelto con `resolucion_min_norm > 0` | 4.713 |
| C | B con categoría de servicio | 3.125 |
| D | C con combinación en la matriz oficial | 2.109 |
| E | C fuera de la matriz oficial | 1.016 |

**Comprobación:** `2.109 + 1.016 = 3.125` ✓

## 6.3 Matriz oficial de 30 combinaciones

> Los valores de N, P75, confianza y meta se reproducen exactamente de `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md`. No se recalculan. La ortografía de categorías y subcategorías se conserva porque de ella depende la clave de política.

| # | Categoría | Subcategoría | N | P75 (min) | Conf. | Escalón | Meta | Cumpl. hist. |
|---:|---|---|---:|---:|---|---:|---|---:|
| 1 | ADMINISTRATIVO | Nueva licencia o sucursal | 35 | 1.161,3 | MEDIA | 1.440 | **24 h** | 88,6 % |
| 2 | ADMINISTRATIVO | Solicitud de migración | 27 | 4.271,1 | BAJA | 4.320 | **3 d** | 74,1 % |
| 3 | CAPACITACION | Solicitud agenda capacitación | 115 | 3.054,6 | ALTA | 4.320 | **3 d** | 81,7 % |
| 4 | CAPACITACION | Capacitación adm Reportes | 21 | 1.644 | BAJA | 2.160 | **36 h** | 81,0 % |
| 5 | DEVOLUCION | Solicitud de devolución | 37 | 3.075 | MEDIA | 4.320 | **3 d** | 83,8 % |
| 6 | FACTURACION ELECTRONICA | Ajustes FE | 341 | 1.111,2 | ALTA | 1.440 | **24 h** | 83,9 % |
| 7 | FACTURACION ELECTRONICA | Cambio de razón social | 170 | 2.996,1 | ALTA | 4.320 | **3 d** | 81,8 % |
| 8 | FACTURACION ELECTRONICA | Activacion FE | 94 | 2.632,2 | MEDIA | 2.880 | **2 d** | 75,5 % |
| 9 | FACTURACION ELECTRONICA | Validación de comprobantes FE | 67 | 1.818 | MEDIA | 2.160 | **36 h** | 77,6 % |
| 10 | FACTURACION ELECTRONICA | Requisitos FE | 60 | 5.920,7 | MEDIA | 7.200 | **5 d** | 86,7 % |
| 11 | FACTURACION ELECTRONICA | Error FE del facturador | 38 | 780,5 | MEDIA | 1.440 | **24 h** | 86,8 % |
| 12 | FACTURACION ELECTRONICA | Error FE de cálculo | 36 | 2.971,7 | MEDIA | 4.320 | **3 d** | 83,3 % |
| 13 | FACTURACION ELECTRONICA | Emisión de invoice | 28 | 2.097,6 | BAJA | 2.160 | **36 h** | 75,0 % |
| 14 | FACTURACION ELECTRONICA | Error FE envio manual | 19 | 2.170,8 | BAJA | 2.880 | **2 d** | 78,9 % |
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | 4.465,8 | INSUF. | — | **sin SLA** | — |
| 16 | GESTION | Renovación certificado normal | 177 | 1.024,2 | ALTA | 1.440 | **24 h** | 85,3 % |
| 17 | GESTION | Venta de CDT certificado | 81 | 1.698 | MEDIA | 2.160 | **36 h** | 77,8 % |
| 18 | GESTION | Envio de pago | 45 | 1.233 | MEDIA | 1.440 | **24 h** | 77,8 % |
| 19 | GESTION | Seguimiento proactivo | 33 | 1.398 | MEDIA | 1.440 | **24 h** | 75,8 % |
| 20 | INTEGRACIONES | Consulta consumo de apis | 83 | 2.597,4 | MEDIA | 2.880 | **2 d** | 80,7 % |
| 21 | INTEGRACIONES | Solicitud de integracion rappi | 25 | 1.615,2 | BAJA | 2.160 | **36 h** | 80,0 % |
| 22 | INTEGRACIONES | Solicitud de integracion Pedidos ya | 14 | 5.371,7 | BAJA | 5.760 | **4 d** | 78,6 % |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | 5.733 | INSUF. | — | **sin SLA** | — |
| 24 | INTEGRACIONES | Error integracion | 4 | 3.922,8 | INSUF. | — | **sin SLA** | — |
| 25 | LOGISTICA | Tarea o capacitación logistica | 319 | 2.836,5 | ALTA | 2.880 | **2 d** | 76,2 % |
| 26 | LOGISTICA | Error logistica | 20 | 4.635,6 | BAJA | 5.760 | **4 d** | 80,0 % |
| 27 | OPERATIVO | Temas operativos | 119 | 2.718 | ALTA | 2.880 | **2 d** | 77,3 % |
| 28 | SOFTWARE | Error punto de venta | 37 | 1.935 | MEDIA | 2.160 | **36 h** | 75,7 % |
| 29 | SOFTWARE | Seguimiento de errores | 34 | 1.403,7 | MEDIA | 1.440 | **24 h** | 73,5 % |
| 30 | SOFTWARE | Error web | 12 | 3.881,4 | BAJA | 4.320 | **3 d** | 75,0 % |

**Verificación de integridad:**

| Verificación | Resultado |
|---|---|
| Suma de N de las 30 filas | **2.109** |
| Suma de N de las 27 con SLA | **2.087** |
| Suma de N de las 3 sin SLA | **22** |
| SLA que son escalón de la escalera | **27 / 27** |
| SLA inferior a su P75 | **0** |
| SLA que salta más de un escalón | **0** |
| Valores recalculados en esta consolidación | **0** |

## 6.4 Distribución de metas

| Meta | Combinaciones | % de 27 |
|---|---:|---:|
| 24 h (1.440 min) | 7 | 25,9 % |
| 36 h (2.160 min) | 6 | 22,2 % |
| 48 h (2.880 min) | 5 | 18,5 % |
| 72 h (4.320 min) | 6 | 22,2 % |
| 96 h (5.760 min) | 2 | 7,4 % |
| 120 h (7.200 min) | 1 | 3,7 % |
| **Total** | **27** | **100 %** |

**Rango:** 24 h a 120 h. La diferenciación es real y amplia (5× entre la meta más corta y la más larga).

## 6.5 Combinaciones sin evidencia suficiente

| # | Categoría | Subcategoría | n | Tratamiento |
|---:|---|---|---:|---|
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | `no_policy` / `insufficient_evidence`; sin SLA; fuera del denominador |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | `no_policy` / `insufficient_evidence`; sin SLA; fuera del denominador |
| 24 | INTEGRACIONES | Error integracion | 4 | `no_policy` / `insufficient_evidence`; sin SLA; fuera del denominador |

**Regla:** no se les asigna ningún tiempo y **no** se les aplica el respaldo de 36 h. El respaldo es para subcategorías fuera del catálogo, no para combinaciones conocidas con muestra insuficiente. Se revisan a los 90 días con datos nuevos.

## 6.6 Volumen fuera de catálogo

**Medido:** 1.016 tickets de 3.125 (32,51 %).

| Categoría COSE | Tickets | % del fuera de matriz |
|---|---:|---:|
| GESTION | 404 | 39,76 % |
| FACTURACION ELECTRONICA | 284 | 27,95 % |
| ADMINISTRATIVO | 188 | 18,50 % |
| SOFTWARE | 131 | 12,89 % |
| INTEGRACIONES | 9 | 0,89 % |
| **Total** | **1.016** | **100 %** |

**Concentración:** cinco rótulos explican 767 tickets (75,5 %): `consultas generales` 283, `consultas fe` 159, `comunicacion de baja` 134, `seguimiento de cdt certificado` 97, `mejoras personalizadas` 94.

**Lectura obligatoria:** el respaldo de 36 h gobernaría 1 de cada 3 tickets clasificados. No es un caso marginal. Con DP-04 confirmada (Soporte), el gobierno del catálogo queda asignado; la métrica seguirá dependiendo del respaldo mientras no se incorporen los cinco rótulos de mayor volumen.

## 6.7 Categoría oficial frente a categoría COSE

En **10 de 30 filas** la categoría de la matriz no coincide con la columna `categoria` de COSE:

| # | Subcategoría | Categoría matriz | Categoría COSE |
|---:|---|---|---|
| 1 | Nueva licencia o sucursal | ADMINISTRATIVO | GESTION |
| 2 | Solicitud de migración | ADMINISTRATIVO | GESTION |
| 3 | Solicitud agenda capacitación | CAPACITACION | GESTION |
| 5 | Solicitud de devolución | DEVOLUCION | GESTION |
| 13 | Emisión de invoice | FACTURACION ELECTRONICA | ADMINISTRATIVO |
| 16 | Renovación certificado normal | GESTION | FACTURACION ELECTRONICA |
| 17 | Venta de CDT certificado | GESTION | FACTURACION ELECTRONICA |
| 24 | Error integracion | INTEGRACIONES | SOFTWARE |
| 26 | Error logistica | LOGISTICA | SOFTWARE |
| 29 | Seguimiento de errores | SOFTWARE | GESTION |

**Regla obligatoria:** el motor clasifica con la matriz (categoría + subcategoría oficial), no con la homologación COSE. La homologación sirve para leer el histórico; la matriz es la fuente de la política. La clave `20-MAIL-<CAT>-<SUB>` se genera desde la categoría oficial.

## 6.8 Claves de política

```
20-MAIL-<CATEGORÍA>-<SUBCATEGORÍA>
99-FALLBACK
```

Ejemplos:

- `20-MAIL-SOFTWARE-ERROR_WEB` → 4.320 min
- `20-MAIL-FACTURACION_ELECTRONICA-AJUSTES_FE` → 1.440 min
- `99-FALLBACK` → 2.160 min (provisional, solo fuera de catálogo)

La clave `10-WA-…` no se usa. Se conserva solo como evidencia histórica de la convención.

---

# 7. ARQUITECTURA OBJETIVO

## 7.1 Principio arquitectónico

| Componente | Responsabilidad |
|---|---|
| Zammad | Tickets, artículos, estados, usuarios, grupos. Fuente de hechos. |
| BFF C.O.S.E. | Ingesta, eventos, políticas, compromisos, ciclos, alertas, auditoría, reconciliación, reportes. |
| PostgreSQL del BFF | Persistencia propia del motor. Sin acceso directo a la base de Zammad. |
| Frontend C.O.S.E. | Clasificación manual, visualización del SLA, cartera y reportes. Consume el BFF. |
| Motor SLA nativo de Zammad | **Desactivado.** Cero políticas. |

**Regla:** el BFF no escribe en Zammad. La única dirección permitida es Zammad → BFF por API REST de solo lectura.

## 7.2 Vista de componentes

```
┌──────────────────────────────────────────────────────────────┐
│ ZAMMAD 7.2.3                                                 │
│  Tickets · Artículos · Historial · Estados · Grupos          │
│  API REST (solo lectura)                                     │
└───────────────────────────┬──────────────────────────────────┘
                            │ GET /tickets/search
                            │ GET /tickets/{id}
                            │ GET /ticket_articles/by_ticket/{id}
                            │ GET /ticket_history/{id}
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ BFF C.O.S.E. — MOTOR SLA                                     │
│                                                              │
│  Ingesta incremental ─► Eventos idempotentes ─► Motor        │
│       │                                        │             │
│       │                                        ├─ Políticas  │
│       │                                        ├─ Compromiso │
│       │                                        ├─ Ciclos     │
│       │                                        ├─ Alertas    │
│       │                                        └─ Auditoría  │
│       │                                                      │
│  Reconciliación ─► Divergencias                              │
│  Seguridad: token read-only · allowlist GET                  │
└───────────────────────────┬──────────────────────────────────┘
                            │ API de consulta
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ C.O.S.E.                                                     │
│  Bandeja · Ficha de ticket · Clasificación manual            │
│  Panel SLA · Dashboard · Reportes                            │
└──────────────────────────────────────────────────────────────┘
```

## 7.3 Modelo de datos: 9 tablas

| # | Tabla | Función | Regla clave |
|---:|---|---|---|
| 1 | `sla_policy_version` | Catálogo versionado de 27 políticas + 3 pendientes + 1 fallback | Inmutable al publicar; `channel = 'email'` |
| 2 | `sla_commitment` | Snapshot inmutable por ticket | Un compromiso por ticket; campos congelados al asignar |
| 3 | `sla_cycle` | Ciclos y reaperturas | Un solo ciclo `open` por compromiso |
| 4 | `sla_event` | Hechos idempotentes | `UNIQUE (idempotency_key)`; payload sin PII |
| 5 | `sla_article_delivery` | Estado de entrega por artículo | Solo `sin_estado`, `aceptado`, `fallido_provisional`, `fallido_definitivo` |
| 6 | `sla_alert` | Alertas emitidas | Una por compromiso, ciclo, métrica y umbral |
| 7 | `sla_audit` | Auditoría append-only | Motivo obligatorio en corrección/publicación/desactivación |
| 8 | `sla_divergence` | Inconsistencias detectadas | Tipos acotados; resolución con evidencia |
| 9 | `sla_sync_run` | Watermark y evidencia de cada ciclo | Un run `failed` no avanza el watermark |

**Columnas eliminadas respecto de 5G.4.3:** `delivered_at`, `read_at`, `external_message_id` de `sla_article_delivery`. Eran de WhatsApp y no aplican al correo.

## 7.4 Catálogo de eventos

| Evento | Obligatorio | Origen |
|---|---|---|
| `ticket.created` | Sí | Sondeo |
| `ticket.classified` | Sí | Sondeo / historial |
| `ticket.reclassified` | Sí | Sondeo / historial |
| `ticket.state_changed` | Sí | Sondeo / historial |
| `ticket.closed` | Sí | Sondeo |
| `ticket.reopened` | Sí | Sondeo / historial |
| `ticket.merged` | Sí | Sondeo |
| `ticket.deleted` | Sí | Reconciliación |
| `article.created` | Sí | Sondeo |
| `article.delivery_confirmed` | Sí | Sondeo |
| `article.delivery_failed` | Sí | Sondeo (`delivery_retry > 3`) |
| `article.delivery_retry_pending` | No | Sondeo |
| `commitment.assigned` | Sí | Motor |
| `cycle.opened` | Sí | Motor |
| `cycle.closed` | Sí | Motor |

**Eliminados:** `article.delivery_delivered`, `article.delivery_read` y cualquier evento `whatsapp`.

**Envoltorio:** `event_id`, `event_type`, `event_version`, `ticket_id`, `entity_id`, `occurred_at`, `source`, `payload`. `source ∈ {poll, reconcile, manual}`.

## 7.5 Ingesta, sondeo y reconciliación

| Ámbito | Cadencia | Función |
|---|---|---|
| Tickets abiertos del grupo | **5 min** | Detección normal |
| Primera respuesta pendiente con vencimiento < 4 h | **2 min** | Ventana crítica de alerta |
| Reconciliación incremental | 15 min | Recupera eventos perdidos |
| Reconciliación completa | Diaria | Cambios tardíos y artículos sin confirmar |
| Reconciliación de integridad | Semanal | `close_at` vs historial, ciclos huérfanos, políticas |

**Consulta incremental:**

```
desde = watermark_efectivo - 15 min
tickets = search(updated_at >= desde, orden updated_at asc, id asc, 200/página)
para cada ticket:
    artículos = by_ticket(id)
    si state_id, close_at o last_close_at cambiaron:
        historial = history(id)
    emitir eventos idempotentes
watermark = max(updated_at) solo si el ciclo terminó sin error
```

**Por qué no 1 minuto:** el motor mide con marcas de Zammad, no con la hora de detección. La cadencia solo cambia la latencia de alerta, no el valor medido. 1 minuto multiplicaría por 5 la carga sin cambiar ningún resultado.

## 7.6 Seguridad de la integración

| Control | Implementación |
|---|---|
| Credencial | Token de API de un usuario técnico dedicado |
| Permiso de lectura | `groups_users.access = 'read'` en el grupo de soporte |
| Escritura de tickets | Bloqueada por `TicketPolicy#update?` (exige `change`/`full`) |
| Creación de artículos | Bloqueada por `Ticket::ArticlePolicy#create?` → `follow_up?` → `update?` |
| Borrado | Solo admin (`TicketPolicy#destroy?`) |
| Administración | Sin permiso `admin` |
| Cliente HTTP | Allowlist de método: solo `GET` |
| Secretos | Gestor de secretos; nunca en repositorio, docs, URL o logs |
| Rotación | Token cada 90 días; solapamiento de 24 h |
| Prueba negativa | 10 de 11 con 403; caso 7 documentado (7a/7b); sin `2xx` inesperado |

**Datos personales:** no se almacena cuerpo de correo, adjunto, dirección del cliente ni teléfono. Solo identificadores, marcas de tiempo y metadatos. El mensaje de error de envío se trunca a 500 caracteres.

## 7.7 Persistencia y recuperación

| Escenario | Comportamiento |
|---|---|
| Caída del BFF | Al reiniciar, retoma desde el watermark del último `sla_sync_run` `ok`; reprocesa 15 min de solape |
| Caída de Zammad | El run queda `failed`; el watermark no avanza; al volver, recupera el hueco |
| Pérdida de conectividad | Reintentos con backoff exponencial; mismo comportamiento que caída de Zammad |
| Evento duplicado | `idempotency_key` lo descarta |
| Evento fuera de orden | Se aplica por `occurred_at`; si contradice un hecho aplicado, se registra divergencia |
| Base del BFF caída | El motor no opera; al volver reconstruye desde eventos. El histórico no vive en memoria |
| Reconstrucción | `sla_event` es el registro de verdad; las proyecciones se pueden reconstruir sin cambiar compromisos |

**Diseño:** PostgreSQL del BFF, escritura síncrona antes de confirmar el evento, respaldo diario y snapshot inmutable.

## 7.8 Frontend y dashboard: posición en la arquitectura

| Capacidad | Dónde vive | Estado |
|---|---|---|
| Clasificación manual | Frontend C.O.S.E. / ficha de ticket | Diseño funcional pendiente en etapa 4 |
| Visualización del SLA | Frontend C.O.S.E. / bandeja y ficha | Diseño funcional pendiente en etapa 4 |
| Dashboard y reportes | C.O.S.E. / BFF | Requisitos definidos; implementación pendiente en etapa 6 |
| Administración de políticas | BFF | Diseñada a nivel funcional; implementación pendiente |

**Regla de secuencia:** la etapa 4 no comienza hasta que la etapa 3 (validación técnica del motor) esté cerrada. No se rediseña la interfaz sobre un motor no validado.

## 7.9 Lo que la arquitectura no incluye

- Nodo de WhatsApp, adaptador de proveedor de mensajería o webhook de estados de entrega.
- Escritura en Zammad, triggers, webhooks o SLA nativos.
- Acceso directo a la base de datos de Zammad.
- Clasificación automática o IA.
- Almacenamiento de cuerpos, adjuntos o direcciones.
- Migración de Zendesk.
- Integración productiva con COSE sin autorización.

---

# 8. LAS SEIS ETAPAS

## 8.1 Vista general y compuertas

| Etapa | Nombre | Resultado esperado | Compuerta de salida | Estado |
|---:|---|---|---|---|
| 1 | Cierre y preparación | Requisitos, matriz, decisiones, criterios y Fase 0 aprobados | 3 `passed` + F0-01 cierre + 6/6 + F0-03/F0-06/F0-15 condicionales + 4 `deferred` + decisiones confirmadas + AP-01/02/03 validadas | `diseñado` / `conditional_pending_final_validation` / `pendiente de validación` |
| 2 | Implementación del motor SLA | Motor operando en el BFF, sin escribir en Zammad | Pruebas T2 aprobadas + 0 escrituras + 0 PII | `pendiente de implementación` |
| 3 | Validación técnica | 27 combinaciones, excepciones y resiliencia demostradas | Pruebas T3 aprobadas + comparación COSE | `pendiente de implementación` |
| 4 | Adaptación del frontend C.O.S.E. | Clasificación y SLA visibles en bandeja y ficha | Pruebas T4 aprobadas + etapa 3 cerrada | `pendiente de implementación` |
| 5 | Pruebas funcionales integrales | Recorrido real de 12 pasos probado | Pruebas T5 aprobadas | `pendiente de implementación` |
| 6 | Panel y aceptación final | Dashboard, reportes, documentación y aceptación | Pruebas T6 aprobadas + acta de aceptación | `pendiente de implementación` |

**Regla de compuerta:** ninguna etapa avanza si una prueba bloqueante falla. No se "mitiga" una prueba fallida: se rediseña la parte afectada.

## 8.2 Dependencia entre etapas

```
ETAPA 1  Cierre y preparación
   │  (AP-01/02/03 + Fase 0: 3 `passed` + F0-01 cierre + 6/6 + condicionales + 4 `deferred`)
   ▼
ETAPA 2  Implementación del motor
   │  (T2 aprobadas)
   ▼
ETAPA 3  Validación técnica
   │  (T3 aprobadas + comparación COSE)
   ▼
ETAPA 4  Frontend C.O.S.E.
   │  (T4 aprobadas)
   ▼
ETAPA 5  Pruebas integrales
   │  (T5 aprobadas)
   ▼
ETAPA 6  Panel y aceptación final
```

**Paralelismo permitido:** la preparación de la infraestructura del BFF y la definición del contrato de la interfaz pueden avanzar durante la etapa 1, pero **no** la implementación del motor ni el rediseño de la interfaz.

## 8.3 ETAPA 1 — Cierre y preparación

**Objetivo:** dejar el proyecto en condiciones de autorizar la implementación, sin ambigüedades documentales ni decisiones críticas abiertas.

**Alcance:**

1. Consolidación de requisitos y precedencia documental.
2. Validación y aprobación de la matriz oficial.
3. Aplicación de las decisiones confirmadas: DT-01, DT-02, DP-04 y exclusión de las 7 no servicio.
4. Designación del dueño funcional del catálogo y su proceso de actualización.
5. Aprobación de los criterios de aceptación y de las compuertas.
6. Preparación y ejecución de la Fase 0.
7. Congelación de línea base, fecha de activación y alcance del piloto.

**Entregables:**

- Documento maestro aprobado.
- Matriz oficial aprobada sin cambios de valores.
- Registro de DP-04: Soporte como responsable funcional y operativo del catálogo.
- Criterios de aceptación aprobados.
- Autorización de Fase 0 y credencial de solo lectura.
- Evidencia F0-01 a F0-16.
- Línea base y `activation_at` documentados.

**Compuerta de salida:**

- 3 `passed` + F0-01 cierre + 6/6 + F0-03/F0-06/F0-15 condicionales; 4 diferidas o tras harness.
- 10/11 con 403 + caso 7 documentado (7a/7b); sin `2xx` inesperado.
- Decisiones DT-01, DT-02 y DP-04 registradas y aplicadas.
- Documentos 5G.4.5 aprobados.
- Sin cambios técnicos no autorizados.

**Estado:** `diseñado`; decisiones confirmadas; AP-01, AP-02 y AP-03 en `conditional_pending_final_validation`; la Fase 0 está `pendiente de autorización`.

## 8.4 ETAPA 2 — Implementación del motor SLA

**Objetivo:** construir el motor propio en el BFF con modelo de datos, ingesta, eventos, asignación, ciclos, alertas, auditoría, reconciliación y seguridad.

**Alcance:**

1. Modelo de datos propio: 9 tablas, restricciones e índices.
2. Integración de lectura con Zammad: solo `GET`.
3. Sondeo incremental con watermark y solape.
4. Procesamiento idempotente de eventos.
5. Captura de clasificación manual y fecha.
6. Asignación y congelamiento del compromiso.
7. Primera respuesta.
8. Resolución y ciclos.
9. Clasificación pendiente, sin evidencia y respaldo 36 h.
10. Clasificación tardía.
11. Alertas.
12. Auditoría.
13. Reconciliación y divergencias.
14. Seguridad, persistencia y retención.

**Entregables:**

- Esquema de 9 tablas con restricciones e índices.
- Carga inicial de 27 políticas activas, 3 pendientes y 1 fallback.
- Servicio de ingesta y sondeo.
- Procesador idempotente.
- Motor de asignación, primera respuesta y ciclos.
- Alertas y auditoría.
- Reconciliación y bandeja de divergencias.
- Credencial de solo lectura y pruebas negativas.
- Respaldos y procedimiento de recuperación.

**Compuerta de salida:**

- T2-01 a T2-19 aprobadas.
- 0 escrituras en Zammad.
- 100 duplicados → 1 evento aplicado.
- Recuperación tras caída sin pérdida ni duplicado.
- 0 PII almacenada.

**Estado:** `pendiente de implementación`.

## 8.5 ETAPA 3 — Validación técnica

**Objetivo:** demostrar que el motor implementado reproduce la matriz, respeta las reglas y sobrevive a excepciones, duplicados, desorden y caídas.

**Alcance:**

1. Pruebas de las 27 combinaciones con SLA.
2. Casos de las 3 combinaciones sin SLA.
3. Tickets fuera de catálogo y respaldo 36 h.
4. Clasificación tardía.
5. Reclasificación.
6. Reapertura y ciclos.
7. Fallos de envío.
8. Duplicados y eventos fuera de orden.
9. Recuperación ante caídas.
10. Comparación con resultados históricos COSE.
11. Categoría oficial frente a categoría COSE en las 10 filas divergentes.

**Entregables:**

- Informe de validación con evidencia por caso.
- Tabla de las 27 combinaciones con resultado `met`/`missed` esperado y obtenido.
- Evidencia de las 3 sin SLA.
- Evidencia de fuera de catálogo y fallback.
- Comparación contra COSE con tolerancias declaradas.
- Registro de divergencias y su resolución.

**Compuerta de salida:**

- T3-01 a T3-11 aprobadas.
- 27/27 combinaciones correctas.
- 3/3 sin SLA correctas.
- 1.016 / 32,51 % reproducido o diferencia explicada.
- 10/10 filas de categoría divergente clasificadas con la matriz.
- Sin regresiones en primera respuesta, ciclos ni exclusiones.

**Estado:** `pendiente de implementación`; será `pendiente de validación` cuando exista motor.

## 8.6 ETAPA 4 — Adaptación del frontend C.O.S.E.

**Objetivo:** permitir que el asesor clasifique manualmente y que asesor, supervisor y jefatura vean el SLA sin salir de la bandeja y la ficha de ticket de C.O.S.E.

**Alcance:**

1. Clasificación manual en la ficha.
2. Selección dependiente de categoría y subcategoría.
3. Estado pendiente de clasificación.
4. Visualización del SLA.
5. Tiempo transcurrido.
6. Fecha de vencimiento.
7. Indicadores de riesgo.
8. Historial de clasificación.
9. Integración visual con la bandeja y la ficha de ticket.

**Entregables:**

- Componentes de clasificación y visualización.
- Contrato de datos entre frontend y BFF.
- Manejo de estados: pendiente, asignado, próximo, vencido, sin SLA, histórico.
- Historial de clasificación y reclasificación.
- Pruebas de interfaz y permisos.

**Compuerta de salida:**

- Etapa 3 cerrada.
- T4-01 a T4-09 aprobadas.
- Ninguna clasificación automática en la interfaz.
- El asesor no puede alterar el compromiso congelado.
- La interfaz no escribe en Zammad.

**Estado:** `pendiente de implementación`. **No se inicia antes de la validación técnica del motor.**

## 8.7 ETAPA 5 — Pruebas funcionales integrales

**Objetivo:** probar el recorrido real completo, desde la recepción del correo hasta el reporte, con un ticket controlado y un asesor real o simulado autorizado.

**Recorrido obligatorio de 12 pasos:**

1. Recepción del correo.
2. Visualización del ticket.
3. Clasificación manual.
4. Asignación del SLA.
5. Respuesta pública.
6. Confirmación de envío.
7. Medición de primera respuesta.
8. Seguimiento de resolución.
9. Cierre.
10. Reapertura.
11. Consulta de historial.
12. Verificación de reportes.

**Entregables:**

- Guion de prueba de extremo a extremo.
- Evidencia de cada paso con marcas de tiempo.
- Resultado de primera respuesta y resolución.
- Evidencia de reapertura y ciclo 2.
- Reporte de la prueba.

**Compuerta de salida:**

- T5-01 a T5-08 aprobadas.
- Los 12 pasos ejecutados sin saltos.
- Primera respuesta medida con `delivery_status_date`, no con `first_response_at`.
- Ciclo 1 oficial y ciclo 2 operativo.
- Reporte con denominador y exclusiones.

**Estado:** `pendiente de implementación`.

## 8.8 ETAPA 6 — Panel y aceptación final

**Objetivo:** entregar el dashboard de cumplimiento, los reportes por categoría, subcategoría y asesor, la cartera pendiente y vencida, la documentación operativa y la aceptación formal.

**Alcance:**

1. Dashboard de cumplimiento.
2. Reportes por categoría.
3. Reportes por subcategoría.
4. Reportes por asesor.
5. Tickets pendientes de clasificación.
6. Tickets próximos a vencer.
7. Tickets vencidos.
8. Promedio, mediana y P75.
9. Cumplimiento global con denominadores.
10. Documentación operativa.
11. Aceptación final.

**Entregables:**

- Dashboard operativo.
- Reportes con numerador, denominador y exclusiones.
- Bandeja de pendientes de clasificación.
- Bandeja de próximos a vencer y vencidos.
- Documento de operación, incidentes y escalamiento.
- Acta de aceptación final.

**Compuerta de salida:**

- T6-01 a T6-09 aprobadas.
- Todo reporte publica denominador y exclusiones.
- La nota "envío aceptado ≠ entregado" aparece en los reportes de primera respuesta.
- La documentación operativa está aprobada.
- El negocio acepta el resultado.

**Estado:** `pendiente de implementación`.

---

# 9. HISTORIAS DE USUARIO

## 9.1 Convenciones

| Campo | Regla |
|---|---|
| Identificador | `EP<etapa>-<número>` |
| Estado inicial | **`pendiente`** en todas las historias |
| Prioridad | `Alta`, `Media`, `Baja`. `Alta (bloqueante)` cuando impide avanzar de etapa |
| Dependencias | Se expresan por ID de historia, decisión o dependencia |
| Criterios | Verificables, sin adjetivos ambiguos |
| Pruebas | Referencian el plan de pruebas de la sección 13 |
| Fechas, responsables y esfuerzo | **No se asignan** en esta épica |

**Estados de historia:** `pendiente` → `en curso` → `bloqueada` / `completada` / `descartada`.
**Estados de madurez del entregable:** `aprobado`, `diseñado`, `pendiente de implementación`, `pendiente de validación`, `pendiente de decisión`. No son intercambiables con los estados de historia.

## 9.2 ETAPA 1 — Cierre y preparación

### EP1-01 · Consolidar requisitos y precedencia documental

| Campo | Definición |
|---|---|
| Descripción | Reunir en una sola lectura el alcance, las reglas, la matriz y las decisiones de los 59 documentos, declarando qué prevalece. |
| Objetivo | Evitar que se implemente una propuesta anterior incompatible con 5G.4.4 o 5G.4.5. |
| Dependencias | Ninguna. |
| Criterios de aceptación | 1) El documento maestro declara la precedencia 5G.4.5 > 5G.4.4 > etapas anteriores. 2) No hay regla vigente contradicha. 3) Los 59 documentos fuente están referenciados. 4) Ningún documento previo fue editado. |
| Pruebas necesarias | RD-01 Revisión de precedencia y trazabilidad. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP1-02 · Aprobar la matriz oficial y las reglas definitivas

| Campo | Definición |
|---|---|
| Descripción | Aprobar sin cambios de valores la matriz de 30 filas, las 27 políticas, las 3 sin evidencia y las reglas de primera respuesta y ciclos. |
| Objetivo | Convertir el diseño validado en base contractual de la implementación. |
| Dependencias | EP1-01. |
| Criterios de aceptación | 1) La matriz se aprueba con 30 filas, 2.109 tickets, 27 con SLA y 3 sin SLA. 2) No se recalcula ningún P75 ni escalón. 3) Se aprueba la meta de primera respuesta `< 86.400 s`. 4) Se aprueban las reglas de ciclos, `merged`, eliminados y clasificación tardía. 5) El acta identifica la versión documental aprobada. |
| Pruebas necesarias | RD-02 Reproducción documental 30/30; F0-10; F0-11; F0-11b. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP1-03 · DP-04: dueño y proceso del catálogo (confirmado)

| Campo | Definición |
|---|---|
| Descripción | Registrar el rol responsable confirmado (**Soporte**) y el proceso de alta, cambio, revisión y retiro de categorías y subcategorías. |
| Objetivo | Evitar que el 32,51 % del volumen dependa indefinidamente del respaldo de 36 h. |
| Dependencias | EP1-01. |
| Criterios de aceptación | 1) El rol confirmado es Soporte, responsable funcional y operativo. 2) Existe un proceso documentado de actualización del catálogo. 3) El proceso define cómo se incorporan los cinco rótulos de mayor volumen. 4) La decisión queda registrada como confirmada. |
| Pruebas necesarias | RD-03 Revisión del registro DP-04 y del proceso. |
| Evidencia | Confirmación de la decisión, 16/11/2026. |
| Prioridad | Alta (bloqueante) |
| Estado | `completada` |

### EP1-04 · Aprobar criterios de aceptación y compuertas

| Campo | Definición |
|---|---|
| Descripción | Aprobar los criterios globales, las compuertas por etapa y el plan de pruebas de esta épica. |
| Objetivo | Fijar de antemano qué significa "terminado" y qué impide avanzar. |
| Dependencias | EP1-01, EP1-02. |
| Criterios de aceptación | 1) Los criterios AC-01 a AC-24 están aprobados. 2) Cada etapa tiene compuerta de salida. 3) Está escrito que una prueba bloqueante fallida detiene el avance. 4) No se incluyen fechas ni estimaciones. |
| Pruebas necesarias | RD-01; revisión de cobertura de criterios. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP1-05 · Autorizar la Fase 0 y aprovisionar la credencial de solo lectura

| Campo | Definición |
|---|---|
| Descripción | Obtener autorización explícita para crear el usuario técnico, el token de solo lectura, el buzón de prueba, la base de pruebas del BFF y la ventana de escritura controlada. |
| Objetivo | Permitir la evidencia de Fase 0 sin abrir escritura productiva ni tocar el buzón definitivo. |
| Dependencias | EP1-04. |
| Criterios de aceptación | 1) Existe autorización escrita y acotada. 2) El usuario técnico tiene `groups_users.access = 'read'` y ningún permiso `admin`. 3) El token se guarda en gestor de secretos. 4) El buzón de prueba está identificado. 5) La base de pruebas del BFF está disponible para F0-12 a F0-14. 6) La ventana de escritura está definida. |
| Pruebas necesarias | F0-02; F0-03; F0-04. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP1-06 · Ejecutar las pruebas F0 de lectura, seguridad y matriz

| Campo | Definición |
|---|---|
| Descripción | Ejecutar F0-01 a F0-05, F0-10, F0-11 y F0-11b, con evidencia y contadores antes/después. |
| Objetivo | Demostrar que la integración lee todo lo necesario, no puede escribir y reproduce la matriz. |
| Dependencias | EP1-05. |
| Criterios de aceptación | 1) F0-01, F0-02, F0-03, F0-04, F0-05, F0-10, F0-11 y F0-11b aprobadas. 2) 10 de 11 con 403 + caso 7 documentado (7a/7b); sin `2xx` inesperado. 3) 30/30 filas y 2.109 / 2.087 / 22 reproducidos. 4) 1.016 tickets fuera de catálogo reproducidos. 5) Los contadores de línea base no cambian salvo los tickets de prueba declarados. |
| Pruebas necesarias | F0-01; F0-02; F0-03; F0-04; F0-05; F0-10; F0-11; F0-11b. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP1-07 · Ejecutar las pruebas F0 de envío, cierre, resiliencia y PII

| Campo | Definición |
|---|---|
| Descripción | Ejecutar F0-06 a F0-09 y F0-12 a F0-16 con un ticket de prueba controlado y la base de pruebas del BFF. |
| Objetivo | Confirmar que las marcas de Zammad son fiables y que el diseño sobrevive a duplicados, desorden, caídas y datos personales. |
| Dependencias | EP1-05, EP1-06. |
| Criterios de aceptación | 1) La confirmación de envío eleva `ticket.updated_at` y puebla `delivery_status_date`. 2) `close_at` no se reescribe al reabrir y `last_close_at` sí cambia. 3) `pending close` no fija `close_at`. 4) `merged` no fija `close_at`. 5) 100 eventos duplicados producen una sola fila. 6) El orden inverso produce el mismo resultado. 7) La caída no pierde ni duplica. 8) No hay PII almacenada. |
| Pruebas necesarias | F0-06; F0-07; F0-08; F0-09; F0-12; F0-13; F0-14; F0-15; F0-16. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP1-08 · Congelar línea base, fecha de activación y alcance del piloto

| Campo | Definición |
|---|---|
| Descripción | Registrar los contadores de partida, definir `activation_at`, el grupo y buzón del piloto, y el procedimiento de rollback. |
| Objetivo | Evitar que el histórico nazca incumplido y que el piloto se confunda con producción. |
| Dependencias | EP1-06, EP1-07. |
| Criterios de aceptación | 1) La línea base coincide con los contadores verificados. 2) `activation_at` está definido y justificado. 3) Los tickets anteriores quedan `historical` y fuera de denominadores. 4) El grupo y buzón del piloto están identificados. 5) Existe rollback documentado. 6) El buzón definitivo sigue sin conectar. |
| Pruebas necesarias | F0-01; F0-15; revisión del acta de línea base. |
| Prioridad | Alta |
| Estado | `pendiente` |

## 9.3 ETAPA 2 — Implementación del motor SLA

### EP2-01 · Crear el modelo de datos de 9 tablas

| Campo | Definición |
|---|---|
| Descripción | Implementar en PostgreSQL del BFF las 9 tablas, restricciones, índices y dominios de la especificación final. |
| Objetivo | Tener una persistencia propia, íntegra y reconstruible, sin tocar la base de Zammad. |
| Dependencias | EP1-08. |
| Criterios de aceptación | 1) Existen las 9 tablas con las columnas de 5G.4.5 §4. 2) `channel` tiene `CHECK ('email')`. 3) `sla_commitment` tiene `UNIQUE (ticket_id)`. 4) `sla_cycle` permite un solo `open` por compromiso. 5) `sla_event` tiene `UNIQUE (idempotency_key)`. 6) Existen los índices de 5G.4.5 §5. 7) No se creó ningún SLA nativo en Zammad. |
| Pruebas necesarias | T2-01. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-02 · Implementar el cliente de lectura de Zammad

| Campo | Definición |
|---|---|
| Descripción | Construir el cliente HTTP que consulta tickets, artículos, historial y catálogos con un token de solo lectura. |
| Objetivo | Garantizar que la integración no pueda escribir, ni por error de código ni por permisos. |
| Dependencias | EP2-01; EP1-05. |
| Criterios de aceptación | 1) Solo se permiten métodos `GET`. 2) La URL de Zammad es fija y no acepta entradas externas. 3) El token se lee del gestor de secretos y no se registra en logs. 4) La paginación respeta 200 por página y orden estable. 5) Un intento de `PATCH`, `POST`, `PUT` o `DELETE` no existe en el cliente. 6) Los 11 intentos negativos externos devuelven 403/401. |
| Pruebas necesarias | T2-03; T2-17; F0-03. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP2-03 · Implementar el sondeo incremental y el watermark

| Campo | Definición |
|---|---|
| Descripción | Implementar la consulta por `updated_at`, el solape de 15 minutos, la cadencia de 5 y 2 minutos y el registro en `sla_sync_run`. |
| Objetivo | Detectar tickets, artículos y confirmaciones de envío sin recorrer el histórico completo. |
| Dependencias | EP2-02. |
| Criterios de aceptación | 1) La consulta usa `updated_at >= watermark − 15 min`. 2) El watermark solo avanza con run `ok`. 3) Un run `failed` no avanza. 4) La banda de 2 minutos se activa con primera respuesta pendiente y vencimiento < 4 h. 5) Cada run registra ventana, tickets leídos y eventos creados. |
| Pruebas necesarias | T2-04. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-04 · Implementar el procesamiento idempotente de eventos

| Campo | Definición |
|---|---|
| Descripción | Implementar el catálogo de 15 eventos, la clave `sha256`, la transacción única y el tratamiento de duplicados y desorden. |
| Objetivo | Que repetir un sondeo no duplique hechos ni transiciones. |
| Dependencias | EP2-01; EP2-03. |
| Criterios de aceptación | 1) La clave de idempotencia usa los cinco componentes documentados. 2) La inserción del evento y la transición ocurren en la misma transacción. 3) 100 inserciones del mismo evento producen una fila y una transición. 4) Un evento fuera de orden se aplica por `occurred_at` sin alterar el resultado final. 5) Un evento `ignored` conserva motivo. |
| Pruebas necesarias | T2-05; F0-12; F0-13. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-05 · Capturar la clasificación manual y su fecha

| Campo | Definición |
|---|---|
| Descripción | Leer la categoría y subcategoría seleccionadas por el asesor y registrar `classified_at` desde el historial o la primera observación. |
| Objetivo | Tener una clasificación humana, auditable y con fecha verificable, sin inferencia. |
| Dependencias | EP2-02; EP2-01. |
| Criterios de aceptación | 1) El motor lee los dos campos de clasificación definidos para la fase 2. 2) No infiere categoría por texto, asunto, IA ni palabras clave. 3) `classified_at` se toma de la primera entrada de historial que deja ambos campos no vacíos. 4) Si no hay historial, usa la primera observación del motor. 5) La clasificación incompleta no asigna compromiso. |
| Pruebas necesarias | T2-06. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-06 · Asignar y congelar el compromiso SLA

| Campo | Definición |
|---|---|
| Descripción | Buscar la política vigente por categoría y subcategoría oficiales y crear el snapshot inmutable del compromiso. |
| Objetivo | Que cada ticket clasificado tenga un plazo único, trazable y no alterable por cambios posteriores. |
| Dependencias | EP2-05. |
| Criterios de aceptación | 1) Se cargan 27 políticas activas con sus valores de matriz. 2) `started_at = created_at`. 3) `first_response_due_at = started_at + 1.440 min`. 4) `resolution_due_at = started_at + resolution_minutes`. 5) El snapshot copia política, versión, categoría, subcategoría, minutos y `provisional`. 6) Una reclasificación incrementa `reclassified_count` pero no cambia el snapshot. 7) Toda corrección exige `sla_audit` con motivo. |
| Pruebas necesarias | T2-02; T2-06. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP2-07 · Gestionar clasificación pendiente y combinaciones sin evidencia

| Campo | Definición |
|---|---|
| Descripción | Implementar `pending_classification` y `no_policy` con sus motivos, sin asignar tiempos anticipados. |
| Objetivo | Que la ausencia de clasificación o de evidencia no se convierta en un SLA inventado. |
| Dependencias | EP2-06. |
| Criterios de aceptación | 1) Sin categoría o sin subcategoría, `assignment_status = 'pending_classification'`. 2) Un `pending_classification` no recibe fallback ni vencimiento. 3) Las 3 combinaciones con n < 10 quedan `no_policy` con motivo `insufficient_evidence`. 4) Ambos estados quedan fuera del denominador. 5) La interfaz y los reportes los muestran como cartera, no como incumplimiento. |
| Pruebas necesarias | T2-07; T2-08. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-08 · Aplicar el respaldo de 36 h solo fuera de catálogo

| Campo | Definición |
|---|---|
| Descripción | Implementar la política `99-FALLBACK` de 2.160 minutos, marcada `provisional`, solo para subcategorías fuera del catálogo. |
| Objetivo | Cubrir el trabajo sin política sin contaminar las 3 combinaciones sin evidencia. |
| Dependencias | EP2-06; EP2-07. |
| Criterios de aceptación | 1) `99-FALLBACK` tiene `resolution_minutes = 2160` y `provisional = true`. 2) Solo se aplica cuando no existe política y la subcategoría está fuera del catálogo. 3) No se aplica a `pending_classification`. 4) No se aplica a las 3 combinaciones con evidencia insuficiente. 5) El reporte separa los compromisos provisionales. |
| Pruebas necesarias | T2-09. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-09 · Calcular la primera respuesta

| Campo | Definición |
|---|---|
| Descripción | Implementar la detección del primer artículo público de agente, tipo `email`, con `delivery_status = success`, y el cálculo estricto `< 86.400 s`. |
| Objetivo | Medir la primera respuesta real, no la creación del artículo. |
| Dependencias | EP2-02; EP2-06. |
| Criterios de aceptación | 1) Se aplican las cinco condiciones del artículo candidato. 2) Se elige el menor `delivery_status_date`; si falta, `updated_at`; si empatan, menor `article_id`. 3) `outcome = met` solo si la diferencia es estrictamente menor a 86.400 s. 4) `first_response_at` de Zammad se ignora. 5) Un `fail` ≤ 3 reintentos queda provisional; > 3 es definitivo y no cuenta. 6) Una nota interna nunca cuenta. 7) El resultado `met`/`missed` no se recalcula al reabrir. |
| Pruebas necesarias | T2-10; F0-06. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP2-10 · Calcular resolución, cierres y ciclos

| Campo | Definición |
|---|---|
| Descripción | Implementar el primer `closed`, la marca `close_at`, el historial, las reaperturas, `merged`, eliminados y el ciclo 1 oficial. |
| Objetivo | Medir la resolución con la regla correcta y sin contaminar el denominador. |
| Dependencias | EP2-06. |
| Criterios de aceptación | 1) El cierre es el primer estado de tipo `closed`. 2) `close_at` se usa si es válido; si no, la transición de historial. 3) `close_at` y la transición se comparan con tolerancia de ±2 s. 4) `pending close` no cierra ni pausa. 5) `merged` se excluye con `exclusion_reason = 'merged'`. 6) Un ticket eliminado se excluye con `ticket_deleted` y conserva datos. 7) Una reapertura abre ciclo N+1 con la misma política. 8) Solo hay un ciclo `open`. 9) El ciclo 1 es la métrica oficial. |
| Pruebas necesarias | T2-11; T2-12; F0-07; F0-08; F0-09. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP2-11 · Tratar la clasificación tardía

| Campo | Definición |
|---|---|
| Descripción | Detectar tickets clasificados después de vencer, marcarlos `late_classification` y separar su indicador. |
| Objetivo | Evitar que un problema de proceso destruya la métrica del primer mes. |
| Dependencias | EP2-05; EP2-06. |
| Criterios de aceptación | 1) `started_at` sigue siendo `created_at`, nunca la fecha de clasificación. 2) `classified_at > created_at + resolution_minutes` marca `late_classification = true`. 3) El `outcome` es `missed_at_birth` si no hubo cierre anterior al vencimiento. 4) El ticket sale del indicador principal y entra al secundario de cartera tardía. 5) El indicador secundario se publica con su propio denominador y volumen. |
| Pruebas necesarias | T2-13. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-12 · Emitir alertas de vencimiento

| Campo | Definición |
|---|---|
| Descripción | Implementar alertas al 75 %, 90 % y vencimiento para primera respuesta y resolución. |
| Objetivo | Avisar antes de incumplir, sin depender del worker de Zammad. |
| Dependencias | EP2-06; EP2-10. |
| Criterios de aceptación | 1) Se emite una alerta por compromiso, ciclo, métrica y umbral. 2) Los umbrales son 75, 90 y vencimiento. 3) Una respuesta o cierre anterior al umbral impide la alerta. 4) Una alerta emitida no se borra si luego se cumple. 5) La banda de 2 minutos se aplica a vencimientos < 4 h. 6) No hay alertas duplicadas. |
| Pruebas necesarias | T2-14. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-13 · Registrar auditoría y divergencias

| Campo | Definición |
|---|---|
| Descripción | Implementar `sla_audit` append-only y `sla_divergence` con los tipos y la resolución documentados. |
| Objetivo | Que toda corrección sea trazable y que ninguna inconsistencia se silencie. |
| Dependencias | EP2-06; EP2-10. |
| Criterios de aceptación | 1) `sla_audit` no admite `UPDATE` ni `DELETE` a nivel de rol. 2) `correct`, `publish` y `deactivate` exigen `reason`. 3) Se registran publicación, desactivación, corrección de compromiso, corrección de ciclo y carga de matriz. 4) Las divergencias usan los tipos permitidos. 5) Una diferencia de `close_at` no se corrige en silencio. 6) Toda divergencia resuelta conserva su evidencia. |
| Pruebas necesarias | T2-15; T2-16. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP2-14 · Implementar reconciliación, seguridad, persistencia y retención

| Campo | Definición |
|---|---|
| Descripción | Completar la reconciliación incremental, diaria y semanal; la seguridad de secretos; los respaldos; la recuperación y la retención por tabla. |
| Objetivo | Que el motor sea operable, recuperable y auditable en producción. |
| Dependencias | EP2-01 a EP2-13. |
| Criterios de aceptación | 1) La reconciliación incremental corre cada 15 min; la diaria, una vez al día; la semanal, una vez por semana. 2) La reconciliación no modifica el snapshot. 3) Existe respaldo diario y prueba de restauración. 4) La caída del BFF recupera desde el último watermark `ok`. 5) La retención se aplica por tabla. 6) No se almacena PII. 7) Los secretos no están en el repositorio ni en logs. |
| Pruebas necesarias | T2-16; T2-17; T2-18; T2-19; F0-14; F0-15; F0-16. |
| Prioridad | Alta |
| Estado | `pendiente` |

## 9.4 ETAPA 3 — Validación técnica

### EP3-01 · Validar las 27 combinaciones con SLA

| Campo | Definición |
|---|---|
| Descripción | Ejecutar un caso controlado por cada una de las 27 combinaciones y comparar vencimiento y resultado con la matriz. |
| Objetivo | Demostrar que la política asignada es exactamente la oficial. |
| Dependencias | EP2-06; EP2-09; EP2-10. |
| Criterios de aceptación | 1) 27/27 combinaciones asignan el escalón correcto. 2) El `resolution_due_at` corresponde a `created_at + minutos`. 3) Ningún valor es menor que su P75. 4) Ningún valor salta más de un escalón. 5) Un cierre antes del vencimiento da `met`; uno posterior da `missed`. |
| Pruebas necesarias | T3-01. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP3-02 · Validar las 3 combinaciones sin SLA

| Campo | Definición |
|---|---|
| Descripción | Probar las tres combinaciones con n < 10 y verificar que no reciben plazo ni fallback. |
| Objetivo | Confirmar que la falta de evidencia se trata como exclusión, no como incumplimiento. |
| Dependencias | EP2-07. |
| Criterios de aceptación | 1) Las tres quedan `no_policy` con motivo `insufficient_evidence`. 2) No tienen `resolution_due_at`. 3) No reciben `99-FALLBACK`. 4) Quedan fuera del denominador. 5) Aparecen visibles en el reporte de cobertura. |
| Pruebas necesarias | T3-02. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP3-03 · Validar el fuera de catálogo y el respaldo de 36 h

| Campo | Definición |
|---|---|
| Descripción | Probar subcategorías fuera de catálogo y verificar el respaldo de 2.160 minutos, marcado provisional. |
| Objetivo | Confirmar que el respaldo se aplica solo donde corresponde y que su peso es visible. |
| Dependencias | EP2-08. |
| Criterios de aceptación | 1) Una subcategoría fuera de catálogo recibe `99-FALLBACK` con 2.160 min. 2) El compromiso queda `provisional = true`. 3) Un ticket sin clasificar no recibe el respaldo. 4) Una de las 3 combinaciones sin evidencia no recibe el respaldo. 5) El reporte separa el volumen provisional. 6) La medición histórica reproduce 1.016 tickets (32,51 %) o explica la diferencia. |
| Pruebas necesarias | T3-03; F0-11. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP3-04 · Validar la categoría oficial frente a la categoría COSE

| Campo | Definición |
|---|---|
| Descripción | Comprobar las 10 filas donde la categoría de la matriz difiere de la categoría COSE y verificar que la clave de política se genera desde la matriz. |
| Objetivo | Evitar que los reportes por categoría no cuadren con la matriz. |
| Dependencias | EP2-05; EP2-06. |
| Criterios de aceptación | 1) Las 10 filas se clasifican con la categoría oficial. 2) La clave `20-MAIL-<CAT>-<SUB>` usa la categoría oficial. 3) Un mismo rótulo de origen no cae en dos categorías por usar fuentes distintas. 4) Los reportes por categoría coinciden con la matriz. 5) La diferencia queda documentada como divergencia histórica, no como error del motor. |
| Pruebas necesarias | T3-04; F0-11b. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP3-05 · Validar la clasificación tardía

| Campo | Definición |
|---|---|
| Descripción | Probar tickets clasificados antes y después del vencimiento, incluido el caso que nace vencido. |
| Objetivo | Confirmar que el indicador principal no se contamina con problemas de proceso. |
| Dependencias | EP2-11. |
| Criterios de aceptación | 1) Un ticket clasificado antes de vencer entra al indicador principal. 2) Uno clasificado después se marca `late_classification` y `missed_at_birth`. 3) `started_at` sigue siendo `created_at`. 4) El indicador secundario se publica aparte con su denominador. 5) Un ticket anterior a `activation_at` queda `historical` y no nace incumplido. |
| Pruebas necesarias | T3-05. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP3-06 · Validar la reclasificación

| Campo | Definición |
|---|---|
| Descripción | Cambiar categoría y subcategoría después de asignar el compromiso y verificar que el snapshot no cambia. |
| Objetivo | Demostrar el congelamiento y la trazabilidad del cambio. |
| Dependencias | EP2-06; EP2-13. |
| Criterios de aceptación | 1) `policy_key`, `resolution_minutes`, `started_at` y `due_at` no cambian. 2) `reclassified_count` aumenta. 3) El cambio queda en `sla_audit` con valor anterior, nuevo y motivo. 4) El ticket conserva su denominador original. 5) La interfaz muestra el SLA original, no el nuevo. |
| Pruebas necesarias | T3-06. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP3-07 · Validar la reapertura y los ciclos

| Campo | Definición |
|---|---|
| Descripción | Cerrar, reabrir y volver a cerrar un ticket; verificar ciclo 1, ciclo 2, `pending close` y `close_at`. |
| Objetivo | Confirmar que la métrica oficial es el ciclo 1 y que las reaperturas no la mejoran. |
| Dependencias | EP2-10. |
| Criterios de aceptación | 1) El primer cierre cierra el ciclo 1 con su `outcome`. 2) La reapertura abre ciclo 2 con `opened_at` de la reapertura y la misma política. 3) El ciclo 1 no se recalcula. 4) `pending close` no cierra ni pausa. 5) `merged` no abre ciclo. 6) Solo hay un ciclo `open`. 7) El indicador operativo de ciclos se publica separado. |
| Pruebas necesarias | T3-07; F0-07; F0-08; F0-09. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP3-08 · Validar los fallos de envío

| Campo | Definición |
|---|---|
| Descripción | Probar `success`, `fail` con reintentos, `fail` definitivo y ausencia de estado; verificar su efecto en primera respuesta y reapertura. |
| Objetivo | Confirmar que un fallo no se cuenta como respuesta y que la reapertura automática se mide como hecho real. |
| Dependencias | EP2-09; EP2-10. |
| Criterios de aceptación | 1) `success` cuenta con su fecha. 2) `fail` con `delivery_retry ≤ 3` no cuenta todavía. 3) `fail` con `delivery_retry > 3` no cuenta nunca. 4) La nota interna de error no cuenta. 5) Un ticket cerrado reabierto por fallo definitivo genera ciclo nuevo y `reopen_hint = delivery_failure`. 6) El artículo fallido se conserva para auditoría. |
| Pruebas necesarias | T3-08. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP3-09 · Validar duplicados y eventos fuera de orden

| Campo | Definición |
|---|---|
| Descripción | Repetir eventos, invertir su orden y comparar el estado final del compromiso y del ciclo. |
| Objetivo | Confirmar que la ingesta es idempotente y que el orden de llegada no altera la métrica. |
| Dependencias | EP2-04. |
| Criterios de aceptación | 1) 100 duplicados producen una fila y una transición. 2) El orden inverso produce el mismo `first_response_at`, `outcome` y `closed_at`. 3) Un evento tardío que contradice un hecho aplicado genera divergencia. 4) La regla de precedencia se aplica: más antiguo gana para primera respuesta; más reciente para estado. 5) No hay pérdida de eventos. |
| Pruebas necesarias | T3-09; F0-12; F0-13. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP3-10 · Validar la recuperación ante caídas

| Campo | Definición |
|---|---|
| Descripción | Interrumpir el proceso a mitad de un run, reiniciar y verificar watermark, eventos y duplicados. |
| Objetivo | Confirmar que una caída no pierde ni duplica hechos. |
| Dependencias | EP2-14. |
| Criterios de aceptación | 1) El run interrumpido queda `failed` o `running` recuperable. 2) El watermark no avanza con un run fallido. 3) Al reiniciar se recupera el hueco. 4) No se duplican eventos ni ciclos. 5) El compromiso y el snapshot no cambian. |
| Pruebas necesarias | T3-10; F0-14. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP3-11 · Comparar con los resultados históricos de COSE

| Campo | Definición |
|---|---|
| Descripción | Reproducir los conteos de la matriz y del fuera de catálogo contra COSE y explicar cualquier diferencia. |
| Objetivo | Demostrar que el motor mide lo mismo que la fuente que originó la política. |
| Dependencias | EP3-01 a EP3-04. |
| Criterios de aceptación | 1) 30/30 filas coinciden con N de la matriz. 2) 2.109 / 2.087 / 22 se reproducen. 3) 1.016 / 32,51 % se reproduce o se explica con evidencia. 4) La distribución por categoría del fuera de catálogo coincide. 5) Las 10 filas de categoría divergente se explican. 6) Toda diferencia tiene causa documentada y no se corrige silenciosamente. |
| Pruebas necesarias | T3-11; F0-10; F0-11; F0-11b. |
| Prioridad | Alta |
| Estado | `pendiente` |

## 9.5 ETAPA 4 — Adaptación del frontend C.O.S.E.

> **Precondición de etapa:** EP3-01 a EP3-11 aprobadas. Ninguna historia de esta etapa puede iniciarse antes.

### EP4-01 · Clasificación manual en la ficha del ticket

| Campo | Definición |
|---|---|
| Descripción | Añadir controles para que el asesor seleccione categoría y subcategoría y guarde la clasificación. |
| Objetivo | Que la clasificación sea una acción humana explícita y auditable. |
| Dependencias | Etapa 3 cerrada; contrato de datos del BFF; fuente de catálogo aprobada. |
| Criterios de aceptación | 1) El asesor puede seleccionar y guardar ambos campos. 2) No existe botón ni proceso de clasificación automática. 3) El guardado registra asesor, fecha y valores. 4) Una clasificación incompleta no asigna SLA. 5) El cambio posterior se registra como reclasificación. 6) La interfaz no escribe en Zammad. |
| Pruebas necesarias | T4-01. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP4-02 · Selector dependiente de categoría y subcategoría

| Campo | Definición |
|---|---|
| Descripción | Implementar un selector donde la subcategoría disponible dependa de la categoría elegida y provenga del catálogo aprobado. |
| Objetivo | Evitar combinaciones inválidas y claves de política inexistentes. |
| Dependencias | EP4-01; definición de la fuente de catálogo. |
| Criterios de aceptación | 1) Al elegir categoría se filtran sus subcategorías. 2) No se permite texto libre. 3) Las 27 combinaciones con SLA y las 3 sin evidencia se reconocen. 4) Una combinación fuera de catálogo se marca como tal antes de guardar. 5) El catálogo mostrado es el aprobado, no una copia hardcodeada sin control de versión. |
| Pruebas necesarias | T4-02. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP4-03 · Mostrar el estado pendiente de clasificación

| Campo | Definición |
|---|---|
| Descripción | Mostrar de forma visible que un ticket no tiene clasificación y que, por tanto, no tiene SLA. |
| Objetivo | Evitar que la ausencia de clasificación se confunda con cumplimiento o con incumplimiento. |
| Dependencias | EP4-01. |
| Criterios de aceptación | 1) El ticket sin categoría o sin subcategoría muestra "pendiente de clasificación". 2) No muestra un vencimiento inventado ni el respaldo de 36 h. 3) Se puede filtrar la cartera pendiente. 4) La interfaz explica que no cuenta en el denominador. 5) Al clasificar, el estado cambia y aparece el SLA asignado. |
| Pruebas necesarias | T4-03. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP4-04 · Visualizar el SLA del ticket

| Campo | Definición |
|---|---|
| Descripción | Mostrar primera respuesta y resolución por separado, con política, meta, estado y `provisional`. |
| Objetivo | Que el asesor entienda el compromiso sin ambigüedad. |
| Dependencias | EP4-01; EP4-03. |
| Criterios de aceptación | 1) Primera respuesta y resolución se muestran separadas. 2) Se ve la política aplicada y su meta. 3) Se ve si el compromiso es provisional. 4) Se ve si el ticket está `pending_classification`, `no_policy`, `historical` o `non_email`. 5) Una reclasificación no cambia el SLA mostrado. 6) La etiqueta de primera respuesta dice "envío aceptado", no "entregado". |
| Pruebas necesarias | T4-04. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP4-05 · Mostrar tiempo transcurrido y fecha de vencimiento

| Campo | Definición |
|---|---|
| Descripción | Mostrar el tiempo transcurrido desde `created_at` y la fecha de vencimiento en zona de Perú, calculados sobre UTC. |
| Objetivo | Que el asesor vea el riesgo real sin depender del reloj del navegador. |
| Dependencias | EP4-04. |
| Criterios de aceptación | 1) El tiempo transcurrido se calcula con marcas del servidor. 2) El vencimiento se muestra en zona de Perú. 3) El almacenamiento y la comparación son UTC. 4) El cambio de hora del navegador no altera el valor. 5) Un ticket `historical` no muestra vencimiento. |
| Pruebas necesarias | T4-05. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP4-06 · Mostrar indicadores de riesgo

| Campo | Definición |
|---|---|
| Descripción | Mostrar los umbrales 75 %, 90 % y vencimiento con señal visual y texto accesible. |
| Objetivo | Que el asesor priorice antes de incumplir. |
| Dependencias | EP4-04; EP4-05. |
| Criterios de aceptación | 1) Los tres umbrales son visibles. 2) El color no es el único portador del significado. 3) Un ticket cumplido no sigue mostrando alerta activa. 4) Una alerta histórica no se borra. 5) La banda de 2 minutos se refleja en la actualización. |
| Pruebas necesarias | T4-06. |
| Prioridad | Media |
| Estado | `pendiente` |

### EP4-07 · Mostrar el historial de clasificación

| Campo | Definición |
|---|---|
| Descripción | Mostrar clasificación original, reclasificaciones, fechas, actor y motivo, sin alterar el compromiso. |
| Objetivo | Dar trazabilidad al asesor y al auditor. |
| Dependencias | EP4-01; EP2-13. |
| Criterios de aceptación | 1) Se ve la clasificación original con fecha. 2) Se ven las reclasificaciones con valor anterior y nuevo. 3) Se ve el compromiso congelado. 4) No se puede editar el pasado desde la interfaz. 5) El historial coincide con `sla_audit`. |
| Pruebas necesarias | T4-07. |
| Prioridad | Media |
| Estado | `pendiente` |

### EP4-08 · Integrar la visualización con la bandeja

| Campo | Definición |
|---|---|
| Descripción | Añadir a la bandeja columnas y filtros de estado SLA, vencimiento, pendiente de clasificación y riesgo. |
| Objetivo | Que el supervisor y el asesor prioricen sin abrir cada ticket. |
| Dependencias | EP4-03; EP4-04; EP4-06. |
| Criterios de aceptación | 1) La bandeja muestra estado SLA y vencimiento. 2) Se puede filtrar por pendiente, próximo, vencido y sin SLA. 3) Los filtros no alteran datos de Zammad. 4) La bandeja no muestra un porcentaje sin denominador. 5) El rendimiento es aceptable con el volumen del piloto. |
| Pruebas necesarias | T4-08. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP4-09 · Integrar la visualización con la ficha del ticket

| Campo | Definición |
|---|---|
| Descripción | Incorporar el panel SLA, la clasificación y el historial en la ficha de ticket respetando el tema C.O.S.E. |
| Objetivo | Que la operación ocurra en un solo lugar, sin duplicar la conversación. |
| Dependencias | EP4-04; EP4-05; EP4-07; EP4-08. |
| Criterios de aceptación | 1) La ficha muestra clasificación, SLA e historial. 2) Respeta el tema C.O.S.E. existente. 3) No se modifican los tres CSS sin autorización de etapa 4. 4) Los permisos de lectura y edición son coherentes con el rol. 5) La ficha no escribe en Zammad. 6) La conversación sigue viviendo en Zammad. |
| Pruebas necesarias | T4-09. |
| Prioridad | Alta |
| Estado | `pendiente` |

## 9.6 ETAPA 5 — Pruebas funcionales integrales

### EP5-01 · Recepción de correo y visualización del ticket

| Campo | Definición |
|---|---|
| Descripción | Enviar un correo al buzón piloto y verificar que se crea el ticket correcto y que el motor lo observa. |
| Objetivo | Confirmar el punto de entrada del recorrido real. |
| Dependencias | Etapa 4 cerrada; buzón piloto autorizado. |
| Criterios de aceptación | 1) El correo genera un ticket en el grupo correcto. 2) No se duplica el ticket. 3) El ticket aparece en la bandeja de C.O.S.E. 4) El motor lo registra con `created_at` y estado. 5) El ticket nace `pending_classification`. |
| Pruebas necesarias | T5-01. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP5-02 · Clasificación manual y asignación del SLA

| Campo | Definición |
|---|---|
| Descripción | Clasificar el ticket desde la ficha y verificar que se asigna el compromiso correcto y se congela. |
| Objetivo | Probar la cadena clasificación → política → vencimiento. |
| Dependencias | EP5-01. |
| Criterios de aceptación | 1) La clasificación se guarda con fecha y asesor. 2) Se asigna la política correcta. 3) El vencimiento corresponde a `created_at + minutos`. 4) El compromiso queda congelado. 5) Una reclasificación posterior no cambia el vencimiento. |
| Pruebas necesarias | T5-02. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP5-03 · Respuesta pública y confirmación de envío

| Campo | Definición |
|---|---|
| Descripción | Enviar una respuesta pública de agente y verificar `delivery_status = success` y su fecha. |
| Objetivo | Probar la señal que alimenta la primera respuesta. |
| Dependencias | EP5-02. |
| Criterios de aceptación | 1) El artículo es público, de agente y tipo `email`. 2) `delivery_status` pasa a `success`. 3) `delivery_status_date` queda poblado. 4) `ticket.updated_at` se eleva. 5) Una nota interna no cuenta. 6) El reporte dice "envío aceptado", no "entregado". |
| Pruebas necesarias | T5-03; F0-06. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP5-04 · Medición de la primera respuesta

| Campo | Definición |
|---|---|
| Descripción | Verificar que la primera respuesta se mide con la fecha de confirmación y el borde estricto de 24 h. |
| Objetivo | Demostrar que la métrica no usa `first_response_at` ni la fecha de creación del artículo. |
| Dependencias | EP5-03. |
| Criterios de aceptación | 1) `first_response_at` del motor coincide con `delivery_status_date`. 2) El `outcome` es `met` si la diferencia es < 86.400 s. 3) Si la diferencia es exactamente 86.400 s, es `missed`. 4) La marca de Zammad `first_response_at` no se usa. 5) El resultado queda en el ciclo 1. |
| Pruebas necesarias | T5-04. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP5-05 · Seguimiento de la resolución

| Campo | Definición |
|---|---|
| Descripción | Verificar que `pending close` no cierra ni pausa y que el cierre se mide contra el vencimiento. |
| Objetivo | Probar la regla de resolución en el recorrido real. |
| Dependencias | EP5-02. |
| Criterios de aceptación | 1) `pending close` no fija `close_at`. 2) El reloj sigue corriendo. 3) El cierre en `closed` fija `closed_at`. 4) `met` si `closed_at ≤ due_at`; `missed` si es posterior. 5) El ciclo 1 es el oficial. |
| Pruebas necesarias | T5-05; F0-08. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP5-06 · Cierre, reapertura e historial

| Campo | Definición |
|---|---|
| Descripción | Cerrar, reabrir y volver a cerrar el ticket; consultar el historial y verificar el ciclo 2. |
| Objetivo | Probar que la reapertura no borra el ciclo 1 ni mejora la métrica oficial. |
| Dependencias | EP5-05. |
| Criterios de aceptación | 1) El ciclo 1 conserva su `closed_at` y `outcome`. 2) La reapertura abre ciclo 2. 3) El ciclo 2 tiene su propio `due_at`. 4) El historial muestra ambos ciclos. 5) La métrica oficial sigue siendo el ciclo 1. 6) `close_at` no se reescribe. |
| Pruebas necesarias | T5-06; F0-07. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP5-07 · Verificación de reportes

| Campo | Definición |
|---|---|
| Descripción | Consultar los reportes del ticket y comprobar numerador, denominador, exclusiones y nota de envío. |
| Objetivo | Probar que el resultado es interpretable y no solo un porcentaje. |
| Dependencias | EP5-04; EP5-06. |
| Criterios de aceptación | 1) El reporte muestra numerador y denominador. 2) Muestra excluidos por motivo. 3) Muestra el volumen provisional. 4) Incluye la nota "envío aceptado ≠ entregado". 5) El porcentaje coincide con el cálculo manual del caso. 6) Un ticket sin SLA no aparece como incumplido. |
| Pruebas necesarias | T5-07. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP5-08 · Recorrido integral de 12 pasos

| Campo | Definición |
|---|---|
| Descripción | Ejecutar sin interrupciones los 12 pasos del recorrido real y registrar evidencia de cada uno. |
| Objetivo | Demostrar que la cadena completa funciona como un solo proceso. |
| Dependencias | EP5-01 a EP5-07. |
| Criterios de aceptación | 1) Los 12 pasos se ejecutan en orden. 2) Cada paso tiene evidencia con marca de tiempo. 3) No hay intervención manual en la base de datos. 4) No hay escritura en Zammad distinta de la operación normal del asesor. 5) El resultado final es reproducible. 6) Las desviaciones quedan registradas. |
| Pruebas necesarias | T5-08. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

## 9.7 ETAPA 6 — Panel y aceptación final

### EP6-01 · Dashboard de cumplimiento

| Campo | Definición |
|---|---|
| Descripción | Construir el panel con cumplimiento de primera respuesta y resolución, separados, con filtros y denominadores. |
| Objetivo | Dar a la jefatura una lectura operativa confiable. |
| Dependencias | Etapa 5 cerrada; BFF con datos validados. |
| Criterios de aceptación | 1) Primera respuesta y resolución se muestran separadas. 2) Cada indicador muestra numerador y denominador. 3) Se puede filtrar por fecha, categoría, subcategoría y estado. 4) Se ve el volumen excluido y su motivo. 5) Se ve el peso de los compromisos provisionales. 6) No se publica un porcentaje sin denominador. |
| Pruebas necesarias | T6-01. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP6-02 · Reportes por categoría y subcategoría

| Campo | Definición |
|---|---|
| Descripción | Generar reportes de cumplimiento por las 9 categorías oficiales y por las 27 combinaciones con SLA, más las 3 sin evidencia marcadas. |
| Objetivo | Mostrar dónde se cumple y dónde no, sin mezclar categorías oficiales con homologaciones COSE. |
| Dependencias | EP6-01. |
| Criterios de aceptación | 1) Se usan las 9 categorías oficiales. 2) Las 27 combinaciones aparecen con su meta. 3) Las 3 sin evidencia aparecen como "sin SLA", no como incumplidas. 4) El reporte por subcategoría no agrupa categorías distintas. 5) Los valores cuadran con la matriz. |
| Pruebas necesarias | T6-02. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP6-03 · Reportes por asesor

| Campo | Definición |
|---|---|
| Descripción | Generar reportes de volumen y cumplimiento por asesor, con denominadores y sin convertirlos en el compromiso oficial. |
| Objetivo | Dar seguimiento operativo sin confundir productividad individual con SLA del cliente. |
| Dependencias | EP6-01. |
| Criterios de aceptación | 1) El reporte muestra volumen, primera respuesta y resolución por asesor. 2) Incluye denominador y exclusiones. 3) No se usa para alterar el compromiso del ticket. 4) No expone datos personales del cliente. 5) Los tickets sin asignar se agrupan aparte. |
| Pruebas necesarias | T6-03. |
| Prioridad | Media |
| Estado | `pendiente` |

### EP6-04 · Cartera pendiente de clasificación

| Campo | Definición |
|---|---|
| Descripción | Construir la vista de tickets sin categoría o sin subcategoría, con antigüedad y acción requerida. |
| Objetivo | Hacer visible el trabajo que no tiene SLA por falta de clasificación. |
| Dependencias | EP6-01; EP4-03. |
| Criterios de aceptación | 1) Lista todos los tickets `pending_classification`. 2) Muestra antigüedad y grupo. 3) No los cuenta como incumplidos. 4) Permite ordenar por antigüedad. 5) Se actualiza con el sondeo. 6) No asigna fallback automáticamente. |
| Pruebas necesarias | T6-04. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP6-05 · Vencimientos próximos y vencidos

| Campo | Definición |
|---|---|
| Descripción | Construir las vistas de tickets próximos a vencer y vencidos, por métrica y umbral. |
| Objetivo | Permitir acción antes del incumplimiento y revisión del incumplimiento. |
| Dependencias | EP6-01; EP2-12. |
| Criterios de aceptación | 1) Se ven los tickets al 75 %, al 90 % y vencidos. 2) Se separan primera respuesta y resolución. 3) Se puede filtrar por categoría y asesor. 4) Un ticket cumplido sale de la vista activa. 5) Una alerta histórica permanece consultable. 6) Los conteos cuadran con el dashboard. |
| Pruebas necesarias | T6-05. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP6-06 · Promedio, mediana y P75

| Campo | Definición |
|---|---|
| Descripción | Mostrar promedio, mediana y P75 de resolución por combinación, con tamaño de muestra y sin confundirlos con la meta. |
| Objetivo | Dar lectura estadística sin reemplazar el criterio P75 de la matriz. |
| Dependencias | EP6-01. |
| Criterios de aceptación | 1) Se muestran los tres estadísticos. 2) Se muestra n. 3) Se distingue "meta" de "valor observado". 4) Un n < 10 se marca como insuficiente. 5) No se recalcula la meta a partir del promedio ni de la mediana. 6) Los valores se presentan en minutos y horas. |
| Pruebas necesarias | T6-06. |
| Prioridad | Media |
| Estado | `pendiente` |

### EP6-07 · Cumplimiento global con denominadores

| Campo | Definición |
|---|---|
| Descripción | Publicar el cumplimiento global con numerador, denominador, exclusiones, volumen provisional y nota de envío. |
| Objetivo | Evitar que un porcentaje sin contexto se use como verdad. |
| Dependencias | EP6-01; EP6-02. |
| Criterios de aceptación | 1) El cumplimiento global se calcula con la fórmula oficial. 2) Se publica junto al denominador. 3) Se desglosan los excluidos por motivo. 4) Se marca lo provisional. 5) Se incluye la nota "envío aceptado ≠ entregado". 6) La meta ≥ 80 % se muestra como referencia, no como resultado. |
| Pruebas necesarias | T6-07. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

### EP6-08 · Documentación operativa

| Campo | Definición |
|---|---|
| Descripción | Documentar la operación: clasificación, interpretación del SLA, alertas, incidentes, escalamiento, rollback y control de cambios. |
| Objetivo | Que el equipo pueda operar sin depender del equipo de diseño. |
| Dependencias | EP6-01 a EP6-07. |
| Criterios de aceptación | 1) Existe guía de clasificación manual. 2) Existe guía de lectura del SLA y de sus estados. 3) Existe procedimiento de incidentes y escalamiento. 4) Existe rollback. 5) Existe control de cambios del catálogo. 6) La documentación no promete entrega en buzón. |
| Pruebas necesarias | T6-08; revisión documental. |
| Prioridad | Alta |
| Estado | `pendiente` |

### EP6-09 · Aceptación final

| Campo | Definición |
|---|---|
| Descripción | Verificar que todas las compuertas están cerradas, que no hay bloqueantes abiertos y que el negocio acepta el resultado. |
| Objetivo | Cerrar la épica con evidencia, no con una declaración. |
| Dependencias | EP6-01 a EP6-08. |
| Criterios de aceptación | 1) Las seis etapas tienen compuerta cerrada. 2) AC-01 a AC-24 están verificados. 3) No hay prueba bloqueante fallida. 4) Los riesgos residuales están aceptados por escrito. 5) DP-04 está confirmada (Soporte) y su impacto está aceptado. 6) Existe acta de aceptación final. 7) No se modificó Zammad, Zendesk ni COSE fuera de lo autorizado. |
| Pruebas necesarias | T6-09; revisión de evidencias de todas las etapas. |
| Prioridad | Alta (bloqueante) |
| Estado | `pendiente` |

---

# 10. DEPENDENCIAS

## 10.1 Dependencias de la épica

| ID | Dependencia | Tipo | Estado | Bloquea | Evidencia requerida |
|---|---|---|---|---|---|
| DEP-01 | Aprobación formal de los seis documentos de 5G.4.5 | Decisión | `conditional_pending_final_validation` | Etapa 1 → 2 | Validación final de AP-01 |
| DEP-02 | **DP-04**: dueño y proceso del catálogo | Decisión organizativa | `confirmada` | Evolución del catálogo | Registro DP-04: **Soporte** |
| DEP-03 | Autorización explícita de la Fase 0 | Decisión | `conditional_pending_final_validation` | EP1-05 a EP1-07 | Validación final de AP-03 |
| DEP-04 | Usuario técnico `read` y token de API | Implementación | `pendiente de implementación` | F0-02, F0-03, T2-17 | Usuario y token en gestor de secretos |
| DEP-05 | Buzón de prueba y ventana de escritura | Infraestructura | `pendiente de implementación` | F0-06 a F0-09 | Buzón identificado y ventana aprobada |
| DEP-06 | PostgreSQL del BFF y respaldos | Infraestructura | `pendiente de implementación` | Etapa 2; F0-12 a F0-14 | Instancia, respaldo y restauración |
| DEP-07 | Fuente de la clasificación manual | Decisión de diseño | `confirmada` | EP2-05; etapa 4 | DT-01: **BFF** como fuente |
| DEP-08 | Catálogo oficial completo de 65 subcategorías | Dato / documento | `disponible y validado` | EP4-02; cobertura total del selector | `CategoryData.ts` localizado (13/65) |
| DEP-09 | Medición del límite de tasa de la API de Zammad | Validación | `pendiente de validación` | Dimensionamiento de producción | Prueba de carga y tasa observada |
| DEP-10 | Gestor de secretos | Infraestructura | `pendiente de implementación` | EP2-02; EP2-14 | Gestor designado y política de acceso |
| DEP-11 | Contrato y autenticación del frontend C.O.S.E. | Diseño | `pendiente de implementación` | Etapa 4 | Contrato de datos y autenticación |
| DEP-12 | Recursos WSL y supervisor de procesos | Infraestructura | `pendiente de implementación` | Operación del piloto | RAM, supervisor y umbral de alerta |
| DEP-13 | Acceso de solo lectura al histórico COSE | Dato | `disponible para solo lectura` | Etapa 3 | Consultas reproducibles |
| DEP-14 | Continuidad de Zendesk y buzón definitivo | Externa | `pendiente de decisión` | Producción, no piloto | Plan de transición |
| DEP-15 | Aprobación de retención y respaldo | Decisión | `pendiente de decisión` | Cierre de etapa 2 | Política aprobada |
| DEP-16 | Aprobación del formato y periodicidad de reportes | Decisión | `pendiente de decisión` | Etapa 6 | Definición aprobada |
| DEP-17 | Definición del grupo y alcance del piloto | Decisión | `pendiente de decisión` | EP1-08; etapa 5 | Acta de alcance del piloto |

## 10.2 Decisiones y aprobaciones pendientes

| ID | Materia | Estado | Impacto | No se puede cerrar con |
|---|---|---|---|---|
| **DP-04** | Responsable funcional y operativo del catálogo | **`aprobada`** | **Soporte** (confirmado) | — |
| AP-01 | Aprobación definitiva de 5G.4.5 | **`conditional_pending_final_validation`** | Bloquea el inicio de la etapa 2 | Validación final expresa |
| AP-02 | Ratificación definitiva del alcance Email-only | **`conditional_pending_final_validation`** | Bloquea comunicación y aceptación | Validación final expresa |
| DT-01 | Fuente de la clasificación manual | **`aprobada`** | **BFF** como fuente; Zammad como espejo opcional | — |
| DT-02 | Catálogo del selector | **`aprobada`** | **65 subcategorías con marca de política** | — |
| DP-07 | Aprobación de infraestructura de persistencia | `diseñado`; aprobación pendiente | Alto: sin base no hay motor | Diseño ya cerrado; falta autorización |
| AP-03 | Autorización para ejecutar Fase 0 | **`conditional_pending_final_validation`** | Bloquea evidencia | Validación final expresa |
| AP-04 | Alcance y grupo del piloto | `pendiente de decisión` | Bloquea etapa 5 | Suposición sobre el buzón |
| AP-05 | Formato y periodicidad de reportes | `pendiente de decisión` | Bloquea etapa 6 | Preferencia técnica |

## 10.3 Bloqueantes por etapa

| Etapa | Bloqueante principal | Se desbloquea con |
|---:|---|---|
| 1 | Validación final de AP-01/02/03, Fase 0 y credencial | AP-01, AP-02, AP-03, DEP-04, DEP-05, DEP-06 |
| 2 | Base del BFF y secretos | DEP-06, DEP-10 |
| 3 | Motor implementado y datos históricos accesibles | Etapa 2 cerrada, DEP-13 |
| 4 | Motor validado y catálogo del selector | Etapa 3 cerrada, DEP-08, DEP-11 |
| 5 | Frontend y piloto definidos | Etapa 4 cerrada, DEP-17 |
| 6 | Datos validados y formato de reportes | Etapa 5 cerrada, DEP-16 |

---

# 11. RIESGOS

## 11.1 Registro de riesgos

| ID | Riesgo | Prob. | Impacto | Nivel | Mitigación | Etapa |
|---|---|---|---|---|---|---|
| R-01 | `delivery_status = success` se interpreta como "correo entregado" | Alta | Alto | **Alto** | Nota obligatoria "envío aceptado ≠ entregado" en todo reporte y acta | 2–6 |
| R-02 | Un fallo transitorio se trata como definitivo | Media | Medio | Medio | Solo es definitivo con `delivery_retry > 3`; antes, `fallido_provisional` | 2–3 |
| R-03 | Reaperturas por fallo de correo inflan indicadores | Media | Medio | Medio | `reopen_hint = delivery_failure` y desagregación del indicador operativo | 2–6 |
| R-04 | `pending close` vence sin acción del agente | Media | Medio | Medio | Alertas 75 % y 90 %; el motor no decide por el equipo | 2–6 |
| R-05 | Categoría COSE ≠ categoría oficial en 10 filas | Alta | Alto | **Alto** | Clasificar con la matriz; validar las 10 filas en T3-04 | 2–3 |
| R-06 | 32,51 % fuera de catálogo gobernado por respaldo 36 h | Alta | Alto | **Alto** | Medido; DP-04 confirmada (Soporte); revisión del catálogo; reporte separado de provisionales | 1–6 |
| R-07 | 3 combinaciones sin SLA | Media | Medio | Medio | Excluidas con motivo; revisión a 90 días | 2–6 |
| R-08 | Clasificación tardía distorsiona el primer período | Media | Medio | Medio | `late_classification` e indicador secundario separado | 2–6 |
| R-09 | La confirmación de envío no eleva `updated_at` | Baja | Alto | Bajo | Código lo garantiza; F0-06 lo confirma antes de implementar | 1 |
| R-10 | Paginación por desplazamiento con cambios concurrentes | Media | Medio | Medio | Orden estable, solape de 15 min y reconciliación | 2–3 |
| R-11 | Rebote asíncrono no reflejado en `delivery_status` | Media | Medio | Medio | Límite del canal; documentado y no corregido con datos inexistentes | 2–6 |
| R-12 | DP-04 no se cierra y el respaldo se vuelve la métrica principal | Baja | Alto | Bajo | **Cerrado**: DP-04 confirmada (Soporte), 16/11/2026 | 1 |
| R-13 | La fuente de clasificación manual no se define | Baja | Alto | Bajo | **Cerrado**: DT-01 confirmada (BFF), 16/11/2026 | 1–2 |
| R-14 | El frontend se rediseña antes de validar el motor | Media | Alto | **Alto** | Compuerta explícita: etapa 4 solo después de etapa 3 | 3–4 |
| R-15 | Recursos WSL insuficientes (~1.500 MB) | Media | Medio | Medio | Perfil mínimo, umbral de 600 MB, supervisor y producción fuera de WSL | 2–6 |
| R-16 | Confusión entre buzón piloto y buzón definitivo | Media | Alto | **Alto** | El definitivo no se conecta mientras Zendesk lo gestione; piloto identificado | 1–6 |
| R-17 | Integración productiva con COSE no autorizada | Baja | Alto | **Alto** | Alcance explícito; etapa 4 consume BFF, no escribe en COSE | 4–6 |
| R-18 | Catálogo completo de 65 subcategorías no disponible | Baja | Medio | Bajo | **Cerrado**: `CategoryData.ts` localizado y validado 13/65 | 1–4 |

## 11.2 Riesgo principal del proyecto

**El respaldo de 36 h sobre un tercio del volumen.** Mientras el catálogo no se actualice, la métrica de resolución será, en buena parte, la métrica del respaldo y no la de la operación. No es un riesgo técnico: es un riesgo de gobierno del catálogo. DP-04 confirmada (Soporte); se mitiga revisando los cinco rótulos de mayor volumen.

## 11.3 Riesgos que no se pueden eliminar

| Riesgo | Por qué no se elimina | Tratamiento |
|---|---|---|
| R-01 | El correo no ofrece confirmación fiable de llegada a buzón | Se declara el alcance de la métrica |
| R-11 | Un rebote puede ocurrir después de la aceptación | Se documenta como límite del canal |
| R-04 | Un ticket puede esperar al cliente y vencer | Se alerta; la decisión es operativa |
| R-08 | La clasificación puede llegar tarde por proceso | Se separa el indicador, no se oculta |

---

# 12. CRITERIOS DE ACEPTACIÓN

## 12.1 Criterios globales

| ID | Criterio | Verificación | Etapa |
|---|---|---|---|
| AC-01 | El único canal del SLA es correo electrónico | Revisión de alcance y de datos ingeridos | 1–6 |
| AC-02 | Cero políticas SLA nativas en Zammad | Contador `sla_policies = 0` antes y después | 1–6 |
| AC-03 | La integración no puede escribir en Zammad | 10/11 con 403 + caso 7 documentado; sin `2xx` inesperado | 1–3 |
| AC-04 | La clasificación es manual, sin IA ni palabras clave | Revisión de código y de interfaz | 2–4 |
| AC-05 | El compromiso se congela al clasificar | T3-06; comparación de snapshot | 2–3 |
| AC-06 | Se aplican las 27 políticas con los valores de la matriz | T3-01; 27/27 | 3 |
| AC-07 | Las 3 combinaciones sin evidencia quedan sin SLA y fuera del denominador | T3-02 | 3 |
| AC-08 | El respaldo de 36 h aplica solo fuera de catálogo y es provisional | T3-03 | 3 |
| AC-09 | La primera respuesta es estrictamente `< 86.400 s` | T2-10; T3-01; T5-04 | 2–5 |
| AC-10 | `success` se comunica como envío aceptado, no como entrega | Revisión de reportes y etiquetas | 2–6 |
| AC-11 | La resolución cierra en el primer `closed` y usa `≤ due_at` | T2-11; T3-07 | 2–3 |
| AC-12 | `pending close` no pausa ni cierra | T2-11; F0-08 | 1–5 |
| AC-13 | `merged` y eliminados se excluyen con divergencia | T2-11; F0-09 | 1–3 |
| AC-14 | El ciclo 1 es la métrica oficial y la reapertura abre ciclo nuevo | T2-12; T3-07; T5-06 | 2–5 |
| AC-15 | La clasificación tardía se separa del indicador principal | T2-13; T3-05 | 2–3 |
| AC-16 | Solo se crean compromisos desde `activation_at` | T2-13; revisión de línea base | 1–3 |
| AC-17 | El cumplimiento global se publica con denominador y exclusiones | T6-01; T6-07 | 6 |
| AC-18 | Las alertas se emiten al 75 %, 90 % y vencimiento sin duplicados | T2-14; T6-05 | 2–6 |
| AC-19 | La auditoría es append-only y exige motivo en correcciones | T2-15 | 2 |
| AC-20 | No se almacena PII: cuerpos, direcciones, adjuntos ni teléfonos | T2-19; F0-16 | 1–2 |
| AC-21 | Duplicados y desorden no alteran el resultado | T2-05; T3-09 | 2–3 |
| AC-22 | La caída del BFF no pierde ni duplica hechos | T2-18; T3-10 | 2–3 |
| AC-23 | El frontend no inicia antes de validar el motor | Revisión de compuerta etapa 3 → 4 | 4 |
| AC-24 | La aceptación final tiene acta, evidencias y riesgos residuales aceptados | T6-09 | 6 |

## 12.2 Compuertas por etapa

| Etapa | Condición de cierre | No se acepta si |
|---:|---|---|
| 1 | Documentos aprobados, decisiones confirmadas, AP-01/02/03 validadas, 3 `passed` + F0-01 cierre + 6/6 + condicionales + 4 `deferred`, línea base congelada | Falta una prueba bloqueante, falta la validación final de AP-01/02/03 o hay cambios técnicos no autorizados |
| 2 | T2-01 a T2-19 aprobadas, 0 escrituras, 0 PII, recuperación probada | Hay una escritura, un duplicado aplicado o una pérdida de evento |
| 3 | T3-01 a T3-11 aprobadas, 27/27, 3/3, 1.016 reproducido o explicado | Una combinación no coincide o una exclusión contamina el denominador |
| 4 | T4-01 a T4-09 aprobadas, sin clasificación automática, sin escritura a Zammad | La interfaz inventa SLA, altera el compromiso o se adelanta a la etapa 3 |
| 5 | T5-01 a T5-08 aprobadas, 12 pasos ejecutados | Se salta un paso, se usa `first_response_at` o falta evidencia |
| 6 | T6-01 a T6-09 aprobadas, documentación y acta | Un reporte no tiene denominador o queda un bloqueante abierto |

## 12.3 Regla de aceptación

Una prueba bloqueante fallida **no se mitiga**: se rediseña la parte afectada y se vuelve a probar. Una aceptación con un bloqueante abierto es inválida.

---

# 13. PLAN DE PRUEBAS

## 13.1 Principios

| Principio | Regla |
|---|---|
| Evidencia | Cada prueba deja un archivo `F0-XX_<nombre>.json/.md`, `T2-XX_<nombre>.md`, etc. |
| Datos | Se usa buzón y tickets de prueba; nunca un cliente real |
| Escritura | Toda escritura de prueba requiere autorización, ventana y reversión documentada |
| Aislamiento | No se prueba sobre el buzón definitivo ni sobre Zendesk productivo |
| Repetición | Las pruebas de solo lectura deben poder repetirse con el mismo resultado |
| Bloqueantes | Un fallo bloqueante detiene la etapa; no se compensa con otras pruebas |
| Defectos | Severidad S1 (bloqueante), S2 (alta), S3 (media), S4 (baja) |
| Cierre | Una etapa se cierra con 100 % de pruebas bloqueantes aprobadas |

## 13.2 Fase 0 — 17 pruebas

| ID | Prueba | Bloqueante | Estado actual | Evidencia |
|---|---|---|:---:|---|
| F0-01 | Línea base íntegra | Sí | `pending` (apertura; cierre pendiente) | `F0-01_baseline_open_<UTC>.json` y `F0-01_baseline_close_<UTC>.json` |
| F0-02 | Credencial de solo lectura | Sí | `pending` | `F0-02_credential_pilot.json` y `F0-02_credential_isolated.json` |
| F0-03 | 11 pruebas negativas de escritura | Sí | `blocked` (sin instancia aislada) | `F0-03_negative_writes.json` |
| F0-04 | Inmutabilidad de configuración | Sí | `pending` | `F0-04_admin_endpoints.json` |
| F0-05 | Superficie de lectura suficiente | Sí | `pending` (parcial en código) | `F0-05_api_surface.json` |
| F0-06 | La confirmación eleva `updated_at` | Sí | `blocked` (sin barrera del piloto) | `F0-06_touch.json` |
| F0-07 | Semántica de `close_at` | Sí | `pending` | `F0-07_close_at.json` |
| F0-08 | `pending close` no cierra | Sí | `pending` | `F0-08_pending_close.json` |
| F0-09 | `merged` no cierra | Sí | `pending` | `F0-09_merged.json` |
| F0-10 | Reproducción de las 30 filas | Sí | `passed` | `F0-10_matrix.json` |
| F0-11 | Fuera de catálogo 1.016 | Sí | `passed` | `F0-11_out_of_catalog.json` |
| F0-11b | Categoría oficial frente a COSE | Sí | `passed` | `F0-11b_category_mapping.md` |
| F0-12 | Evento duplicado | Sí | `deferred` (sin harness/BFF) | `F0-12_duplicates.md` |
| F0-13 | Eventos fuera de orden | Sí | `deferred` (sin harness/BFF) | `F0-13_out_of_order.md` |
| F0-14 | Recuperación tras caída | Sí | `deferred` (sin harness/BFF) | `F0-14_recovery.md` |
| F0-15 | Sin escrituras durante el sondeo | Sí | `blocked` (sin ventana/evidencia) | `F0-15_no_writes.json` |
| F0-16 | Sin datos personales almacenados | Sí | `deferred` (sin harness/BFF) | `F0-16_no_pii.md` |

**Resultado actual:** 3 `passed` (F0-10/11/11b) + F0-01 `pending` por cierre; 7 `pending`, 3 `blocked`, 4 `deferred`.

**Condiciones de ambiente:** F0-03 se ejecuta **solo** en instancia aislada; F0-15 en **ventana exclusiva**; F0-02 tiene **credencial piloto y credencial aislada**, sin compartir tokens. Ver `PAQUETE_AUTORIZACION_FASE_0_SLA.md` §2.1.

## 13.3 Etapa 2 — Pruebas del motor

| ID | Prueba | Qué demuestra | Evidencia |
|---|---|---|---|
| T2-01 | Esquema, restricciones e índices | Las 9 tablas y sus invariantes existen | `T2-01_schema.md` |
| T2-02 | Carga de políticas | 27 activas, 3 pendientes, 1 fallback; unicidad | `T2-02_policies.json` |
| T2-03 | Lectura y allowlist | Solo `GET`; paginación estable | `T2-03_read_client.md` |
| T2-04 | Sondeo y watermark | Avance solo con `ok`; solape de 15 min | `T2-04_watermark.md` |
| T2-05 | Idempotencia | 100 duplicados → 1 evento | `T2-05_idempotency.md` |
| T2-06 | Asignación y congelamiento | Snapshot correcto e inmutable | `T2-06_assignment.md` |
| T2-07 | Pendiente de clasificación | Sin fallback ni vencimiento | `T2-07_pending.md` |
| T2-08 | Sin evidencia | 3 combinaciones fuera del denominador | `T2-08_no_policy.md` |
| T2-09 | Respaldo 36 h | Solo fuera de catálogo y provisional | `T2-09_fallback.md` |
| T2-10 | Primera respuesta | `< 86.400 s`; fallback de fecha; fallos | `T2-10_first_response.md` |
| T2-11 | Resolución y estados | `closed`, `pending close`, `merged`, eliminados | `T2-11_resolution.md` |
| T2-12 | Ciclos y reapertura | Ciclo 1 oficial; ciclo N operativo | `T2-12_cycles.md` |
| T2-13 | Clasificación tardía | `late_classification` y `missed_at_birth` | `T2-13_late.md` |
| T2-14 | Alertas | 75/90/vencimiento; sin duplicados | `T2-14_alerts.md` |
| T2-15 | Auditoría | Append-only; motivo obligatorio | `T2-15_audit.md` |
| T2-16 | Reconciliación | No modifica snapshot; registra divergencias | `T2-16_reconciliation.md` |
| T2-17 | Seguridad | Token `read`; 10/11 negativas + caso 7 documentado; secretos | `T2-17_security.md` |
| T2-18 | Persistencia | Respaldo, restauración y recuperación | `T2-18_persistence.md` |
| T2-19 | PII | 0 cuerpos, 0 direcciones, 0 adjuntos | `T2-19_no_pii.md` |

## 13.4 Etapa 3 — Validación técnica

| ID | Prueba | Qué demuestra | Evidencia |
|---|---|---|---|
| T3-01 | 27 combinaciones | Vencimiento y resultado correctos | `T3-01_27_combinations.md` |
| T3-02 | 3 sin SLA | Sin plazo, sin fallback, fuera del denominador | `T3-02_no_evidence.md` |
| T3-03 | Fuera de catálogo | 36 h provisional; 1.016 reproducido | `T3-03_out_of_catalog.md` |
| T3-04 | Categoría oficial | 10 filas con la categoría de la matriz | `T3-04_category_mapping.md` |
| T3-05 | Clasificación tardía | Separación del indicador principal | `T3-05_late.md` |
| T3-06 | Reclasificación | Snapshot intacto; auditoría | `T3-06_reclassification.md` |
| T3-07 | Reapertura y ciclos | Ciclo 1 oficial; ciclo 2 operativo | `T3-07_reopen.md` |
| T3-08 | Fallos de envío | Provisional, definitivo y reapertura | `T3-08_delivery_failures.md` |
| T3-09 | Duplicados y desorden | Resultado idéntico | `T3-09_events.md` |
| T3-10 | Recuperación | Sin pérdida ni duplicado | `T3-10_recovery.md` |
| T3-11 | Comparación COSE | Conteos y distribución reproducidos | `T3-11_cose_comparison.md` |

## 13.5 Etapa 4 — Pruebas de interfaz

| ID | Prueba | Qué demuestra | Evidencia |
|---|---|---|---|
| T4-01 | Clasificación manual | Guarda ambos campos; sin automatismo | `T4-01_classification.md` |
| T4-02 | Selector dependiente | Subcategoría filtrada por categoría | `T4-02_selector.md` |
| T4-03 | Pendiente de clasificación | Sin SLA inventado; filtro visible | `T4-03_pending.md` |
| T4-04 | Panel SLA | Primera respuesta y resolución separadas | `T4-04_panel.md` |
| T4-05 | Tiempo y vencimiento | UTC de servidor; presentación Perú | `T4-05_time.md` |
| T4-06 | Indicadores de riesgo | 75/90/vencimiento; accesibles | `T4-06_risk.md` |
| T4-07 | Historial | Original y reclasificaciones | `T4-07_history.md` |
| T4-08 | Bandeja | Columnas y filtros sin escribir en Zammad | `T4-08_inbox.md` |
| T4-09 | Ficha de ticket | Integración y permisos | `T4-09_ticket.md` |

## 13.6 Etapa 5 — Pruebas integrales

| ID | Prueba | Qué demuestra | Evidencia |
|---|---|---|---|
| T5-01 | Recepción y visualización | Ticket correcto, sin duplicado | `T5-01_receive.md` |
| T5-02 | Clasificación y asignación | Política y vencimiento correctos | `T5-02_assign.md` |
| T5-03 | Respuesta y confirmación | `success` y fecha poblada | `T5-03_send.md` |
| T5-04 | Primera respuesta | `< 24 h` con fecha de envío | `T5-04_first_response.md` |
| T5-05 | Seguimiento y cierre | `pending close` no cierra; `≤ due_at` | `T5-05_resolution.md` |
| T5-06 | Reapertura e historial | Ciclo 1 intacto; ciclo 2 visible | `T5-06_reopen.md` |
| T5-07 | Reportes | Numerador, denominador y exclusiones | `T5-07_reports.md` |
| T5-08 | 12 pasos | Recorrido completo reproducible | `T5-08_e2e.md` |

## 13.7 Etapa 6 — Panel y aceptación

| ID | Prueba | Qué demuestra | Evidencia |
|---|---|---|---|
| T6-01 | Dashboard | Indicadores separados y filtrables | `T6-01_dashboard.md` |
| T6-02 | Categoría y subcategoría | 9 categorías; 27 + 3 | `T6-02_reports.md` |
| T6-03 | Asesor | Volumen y cumplimiento con denominador | `T6-03_agents.md` |
| T6-04 | Pendientes de clasificación | Cartera visible y accionable | `T6-04_pending.md` |
| T6-05 | Próximos y vencidos | Umbrales y conteos coherentes | `T6-05_due.md` |
| T6-06 | Promedio, mediana y P75 | Estadísticos con n; meta separada | `T6-06_stats.md` |
| T6-07 | Cumplimiento global | ≥ 80 % con denominador y nota | `T6-07_compliance.md` |
| T6-08 | Documentación operativa | Guías, incidentes y rollback | `T6-08_ops.md` |
| T6-09 | Aceptación final | Compuertas y acta | `T6-09_acceptance.md` |

## 13.8 Pruebas documentales

| ID | Prueba | Qué demuestra |
|---|---|---|
| RD-01 | Precedencia y trazabilidad | 5G.4.5 > 5G.4.4 > etapas anteriores; 59 fuentes referenciadas |
| RD-02 | Reproducción documental de la matriz | 30 filas, 27/3, 2.109/2.087/22, sin recálculo |
| RD-03 | Cobertura de la épica | Seis etapas, 59 historias, criterios y pruebas por historia |

## 13.9 Gestión de defectos

| Severidad | Definición | Efecto |
|---|---|---|
| S1 | Bloquea una compuerta o produce dato incorrecto | Detiene la etapa; no se acepta |
| S2 | Afecta una regla sin bloquear toda la etapa | Se corrige antes del cierre de etapa |
| S3 | Defecto funcional menor o de visualización | Se corrige antes de la aceptación final |
| S4 | Mejora o deuda documentada | Se registra y se planifica |

**Regla:** un defecto S1 no se cierra por decisión; se corrige y se vuelve a probar.

---

# 14. CONTROL DE CAMBIOS

## 14.1 Control del documento

| Versión | Fecha | Cambio | Estado |
|---|---|---|---|
| 1.0 | 16/11/2026 | Creación del documento maestro EPIC-SLA-01 a partir de los 59 documentos existentes | Vigente |
| 1.1 | 16/11/2026 | Consolidación de DT-01, DT-02, DP-04 y exclusión de las 7 no servicio; AP-01/02/03 como `conditional_pending_final_validation` | Vigente |

**Reglas:**

1. Este documento no se sobrescribe con una versión incompatible. Los cambios se registran en la tabla anterior.
2. Un cambio de alcance, regla, matriz o arquitectura exige una nueva versión y, si afecta decisiones aprobadas, un anexo de decisión.
3. No se editan los 59 documentos fuente. Las correcciones se hacen por anexo y se declara la precedencia.
4. La numeración de secciones y de historias se conserva entre versiones; una historia nueva se añade, no se renumera.
5. Toda afirmación de estado debe poder respaldarse con evidencia. No se marca `completada` una historia solo porque exista un documento.

## 14.2 Tipos de cambio

| Tipo | Ejemplo | Quién aprueba | Efecto |
|---|---|---|---|
| Cambio de alcance | Incluir otro canal | Negocio + dirección | Nueva versión de épica; revisión de todas las etapas |
| Cambio de regla | Cambiar el borde de 24 h | Negocio | Nueva versión de reglas y pruebas |
| Cambio de matriz | Alta de subcategoría o cambio de meta | Dueño del catálogo + negocio | Nueva `matrix_version`; no altera compromisos existentes |
| Cambio de arquitectura | Cambiar el BFF o la fuente | Arquitectura + TI | Nueva versión de especificación y pruebas |
| Cambio de interfaz | Reordenar el panel SLA | Producto + operación | Nueva versión de etapa 4 |
| Cambio de prueba | Añadir un caso | Calidad + negocio | Se añade al plan sin borrar evidencia previa |

## 14.3 Versionado de la matriz

| Regla | Detalle |
|---|---|
| `matrix_version` | Identifica la versión de la matriz aplicada |
| Inmutabilidad | Una política publicada no se edita; se crea una versión nueva |
| Vigencia | `valid_from` / `valid_to`; solo una versión activa por combinación |
| Compromisos existentes | Conservan su snapshot; no se recalculan |
| Tickets nuevos | Usan la versión vigente al clasificar |
| Auditoría | Publicación y desactivación exigen motivo |

## 14.4 Corrección de un compromiso o de un ciclo

| Paso | Regla |
|---:|---|
| 1 | Detectar la divergencia y registrarla en `sla_divergence` |
| 2 | No corregir en silencio |
| 3 | Registrar `sla_audit` con valor anterior, nuevo, actor y motivo |
| 4 | Exigir aprobación cuando afecte un compromiso ya reportado |
| 5 | Reemitir el reporte afectado; el reporte anterior no se reescribe |

## 14.5 Regla de no reescritura

Un reporte ya emitido no se reescribe. Si un cierre posterior cambia un resultado provisional, se emite una nota de corrección y se conserva el original. La trazabilidad vale más que un porcentaje estéticamente perfecto.

---

# 15. ESTADO GENERAL DEL PROYECTO

## 15.1 Estado por elemento

| Elemento | Estado | Evidencia |
|---|---|---|
| Alcance Email | `diseñado`; ratificación formal pendiente | `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` |
| Matriz de 30 filas | `diseñado` y validado 30/30; aprobación formal pendiente | `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md`; `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md` |
| Reglas de primera respuesta | `diseñado`; no implementado | `REGLAS_DEFINITIVAS_PRIMERA_RESPUESTA_EMAIL_5G4_5.md` |
| Reglas de ciclos | `diseñado`; no implementado | `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` |
| Especificación del motor | `diseñado`; no implementado | `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md` |
| Criterios de Fase 0 | `diseñado`; 3 `passed` + F0-01 apertura | `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` |
| Motor SLA | **No implementado** | No existe código ni tabla del motor |
| Frontend C.O.S.E. | **No implementado** | Sin componentes de clasificación ni panel |
| Dashboard y reportes | **No implementado** | Sin dashboard |
| Credencial de solo lectura | **No creada** | F0-02 pendiente |
| Base del BFF | **No creada** | F0-12 a F0-14 pendientes |
| DP-04 | **`aprobada`** | Soporte, responsable funcional y operativo del catálogo |
| DT-01 | **`aprobada`** | BFF como fuente; Zammad como espejo opcional |
| DT-02 | **`aprobada`** | 65 subcategorías con marca de política |
| Zammad | Sin cambios no autorizados | `sla_policies = 0`; triggers 3/0 activos; webhooks 0 |
| Documentos previos | 59 intactos | Manifiesto de verificación |

## 15.2 Qué está diseñado y qué está implementado

| Capacidad | Diseñado | Implementado | Validado |
|---|:---:|:---:|:---:|
| Matriz de 27 políticas | Sí | No | Sí, estadísticamente |
| Regla de primera respuesta | Sí | No | No |
| Regla de ciclos y reaperturas | Sí | No | No |
| Modelo de 9 tablas | Sí | No | No |
| Motor de ingesta y eventos | Sí | No | No |
| Clasificación manual | Sí, funcional | No | No |
| Frontend de clasificación | Requisitos funcionales | No | No |
| Dashboard | Requisitos funcionales | No | No |
| Seguridad de solo lectura | Sí | No | Parcial (código) |
| Fase 0 | Sí | 3 `passed` + F0-01 apertura | Parcial |

**Advertencia:** ninguna capacidad de esta tabla debe presentarse como "implementada" por el hecho de estar documentada.

## 15.3 Indicadores de la épica

| Indicador | Valor |
|---|---:|
| Documentos fuente | 59 |
| Documento maestro | 1 (este) |
| Etapas | 6 |
| Historias de usuario | 59 |
| Historias completadas | 2 |
| Decisiones funcionales abiertas | 0 |
| Aprobaciones condicionales | 3 (AP-01, AP-02, AP-03) |
| Pruebas Fase 0 definidas | 17 |
| Pruebas Fase 0 con evidencia de lectura | 4 (3 `passed` + F0-01 apertura) |
| Pruebas Fase 0 no `passed` | 14 (7 `pending` + 3 `blocked` + 4 `deferred`) |
| Políticas con SLA | 27 |
| Combinaciones sin evidencia | 3 |
| Volumen fuera de catálogo | 1.016 (32,51 %) |
| Escrituras en Zammad | 0 |
| Tablas del motor creadas | 0 |
| Cambios en Zendesk | 0 |
| Cambios en COSE | 0 |

## 15.4 Seguimiento por etapa

> Tabla viva. Se actualiza al cerrar cada etapa. `Pendientes` cuenta las historias en estado `pendiente`.

| Etapa | Historias | Total | Pendientes | En curso | Bloqueadas | Completadas | Estado de etapa | Compuerta |
|---|---|---:|---:|---:|---:|---:|---|---|
| 1 — Cierre y preparación | EP1-01..EP1-08 | 8 | 5 | 1 | 0 | 2 | `diseñado` / `conditional_pending_final_validation` | Abierta |
| 2 — Motor SLA | EP2-01..EP2-14 | 14 | 14 | 0 | 0 | 0 | `pendiente de implementación` | Cerrada |
| 3 — Validación técnica | EP3-01..EP3-11 | 11 | 11 | 0 | 0 | 0 | `pendiente de implementación` | Cerrada |
| 4 — Frontend C.O.S.E. | EP4-01..EP4-09 | 9 | 9 | 0 | 0 | 0 | `pendiente de implementación` | Cerrada |
| 5 — Pruebas integrales | EP5-01..EP5-08 | 8 | 8 | 0 | 0 | 0 | `pendiente de implementación` | Cerrada |
| 6 — Panel y aceptación | EP6-01..EP6-09 | 9 | 9 | 0 | 0 | 0 | `pendiente de implementación` | Cerrada |
| **Total** | — | **59** | **56** | **1** | **0** | **2** | — | — |

## 15.5 Seguimiento por historia

> Tabla viva. `Estado` inicial `pendiente`. `Evidencia` se completa con el archivo o acta que demuestra el cierre. `Actualizado` se completa con la fecha real de cambio; no se inventa.

| ID | Historia | Etapa | Estado | Evidencia | Actualizado |
|---|---|---:|---|---|---|
| EP1-01 | Consolidar requisitos y precedencia | 1 | `completada` | `EPIC_IMPLEMENTACION_SLA_COSE.md` v1.1 | 16/11/2026 |
| EP1-02 | Aprobar matriz y reglas | 1 | `pendiente` | — | — |
| EP1-03 | DP-04: dueño y proceso (Soporte) | 1 | `completada` | Registro DP-04 | 16/11/2026 |
| EP1-04 | Aprobar criterios y compuertas | 1 | `pendiente` | — | — |
| EP1-05 | Autorizar Fase 0 y credencial | 1 | `pendiente` | — | — |
| EP1-06 | F0 lectura, seguridad y matriz | 1 | `en curso` | F0-01, F0-10, F0-11, F0-11b | 16/11/2026 |
| EP1-07 | F0 envío, cierre, resiliencia y PII | 1 | `pendiente` | — | — |
| EP1-08 | Congelar línea base y piloto | 1 | `pendiente` | — | — |
| EP2-01 | Modelo de 9 tablas | 2 | `pendiente` | — | — |
| EP2-02 | Cliente de lectura | 2 | `pendiente` | — | — |
| EP2-03 | Sondeo y watermark | 2 | `pendiente` | — | — |
| EP2-04 | Eventos idempotentes | 2 | `pendiente` | — | — |
| EP2-05 | Capturar clasificación manual | 2 | `pendiente` | — | — |
| EP2-06 | Asignar y congelar compromiso | 2 | `pendiente` | — | — |
| EP2-07 | Pendiente y sin evidencia | 2 | `pendiente` | — | — |
| EP2-08 | Respaldo 36 h | 2 | `pendiente` | — | — |
| EP2-09 | Primera respuesta | 2 | `pendiente` | — | — |
| EP2-10 | Resolución y ciclos | 2 | `pendiente` | — | — |
| EP2-11 | Clasificación tardía | 2 | `pendiente` | — | — |
| EP2-12 | Alertas | 2 | `pendiente` | — | — |
| EP2-13 | Auditoría y divergencias | 2 | `pendiente` | — | — |
| EP2-14 | Reconciliación, seguridad y persistencia | 2 | `pendiente` | — | — |
| EP3-01 | Validar 27 combinaciones | 3 | `pendiente` | — | — |
| EP3-02 | Validar 3 sin SLA | 3 | `pendiente` | — | — |
| EP3-03 | Validar fuera de catálogo | 3 | `pendiente` | — | — |
| EP3-04 | Validar categoría oficial | 3 | `pendiente` | — | — |
| EP3-05 | Validar clasificación tardía | 3 | `pendiente` | — | — |
| EP3-06 | Validar reclasificación | 3 | `pendiente` | — | — |
| EP3-07 | Validar reapertura y ciclos | 3 | `pendiente` | — | — |
| EP3-08 | Validar fallos de envío | 3 | `pendiente` | — | — |
| EP3-09 | Validar duplicados y desorden | 3 | `pendiente` | — | — |
| EP3-10 | Validar recuperación | 3 | `pendiente` | — | — |
| EP3-11 | Comparar con COSE | 3 | `pendiente` | — | — |
| EP4-01 | Clasificación manual | 4 | `pendiente` | — | — |
| EP4-02 | Selector dependiente | 4 | `pendiente` | — | — |
| EP4-03 | Estado pendiente | 4 | `pendiente` | — | — |
| EP4-04 | Panel SLA | 4 | `pendiente` | — | — |
| EP4-05 | Tiempo y vencimiento | 4 | `pendiente` | — | — |
| EP4-06 | Indicadores de riesgo | 4 | `pendiente` | — | — |
| EP4-07 | Historial de clasificación | 4 | `pendiente` | — | — |
| EP4-08 | Integración con bandeja | 4 | `pendiente` | — | — |
| EP4-09 | Integración con ficha | 4 | `pendiente` | — | — |
| EP5-01 | Recepción y visualización | 5 | `pendiente` | — | — |
| EP5-02 | Clasificación y asignación | 5 | `pendiente` | — | — |
| EP5-03 | Respuesta y confirmación | 5 | `pendiente` | — | — |
| EP5-04 | Medición primera respuesta | 5 | `pendiente` | — | — |
| EP5-05 | Seguimiento y cierre | 5 | `pendiente` | — | — |
| EP5-06 | Reapertura e historial | 5 | `pendiente` | — | — |
| EP5-07 | Verificación de reportes | 5 | `pendiente` | — | — |
| EP5-08 | Recorrido de 12 pasos | 5 | `pendiente` | — | — |
| EP6-01 | Dashboard | 6 | `pendiente` | — | — |
| EP6-02 | Reportes categoría/subcategoría | 6 | `pendiente` | — | — |
| EP6-03 | Reportes por asesor | 6 | `pendiente` | — | — |
| EP6-04 | Pendientes de clasificación | 6 | `pendiente` | — | — |
| EP6-05 | Próximos y vencidos | 6 | `pendiente` | — | — |
| EP6-06 | Promedio, mediana y P75 | 6 | `pendiente` | — | — |
| EP6-07 | Cumplimiento global | 6 | `pendiente` | — | — |
| EP6-08 | Documentación operativa | 6 | `pendiente` | — | — |
| EP6-09 | Aceptación final | 6 | `pendiente` | — | — |

## 15.6 Próximos pasos, en orden

1. Obtener la validación final de **AP-01** (5G.4.5) y **AP-02** (alcance Email).
2. Obtener la validación final de **AP-03** (autorización de Fase 0).
3. Aprobar los criterios de aceptación y las compuertas de esta épica.
4. Aprovisionar el usuario técnico de solo lectura, el token, el buzón de prueba, la base de pruebas y la ventana de escritura.
5. Ejecutar las 13 pruebas F0 pendientes, en el orden del paquete de autorización.
6. Aplicar DT-01 (BFF como fuente) y DT-02 (65 con marca) en la etapa 2 y la etapa 4.
7. Aprobar la infraestructura de persistencia (DP-07), el gestor de secretos y el cifrado de backups.
8. Iniciar la etapa 2 solo con la compuerta de etapa 1 cerrada.
9. No iniciar la etapa 4 hasta cerrar la etapa 3.
10. No conectar el buzón definitivo ni tocar COSE productivo sin autorización separada.

---

# 16. REFERENCIAS A LOS DOCUMENTOS FUENTE

## 16.1 Regla de precedencia

| Orden | Documento | Qué manda |
|---:|---|---|
| 1 | `REGLAS_DEFINITIVAS_PRIMERA_RESPUESTA_EMAIL_5G4_5.md` | Primera respuesta, candidatos, fallos, borde `< 24 h` |
| 2 | `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` | Ciclos, cierres, reaperturas, `merged`, eliminados, tardía |
| 3 | `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md` | Fuentes, eventos, 9 tablas, índices, cálculo, sondeo, alertas, auditoría, reconciliación |
| 4 | `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md` | Matriz 30/30, cobertura, 1.016 fuera de catálogo, 10 filas de categoría |
| 5 | `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` | 17 pruebas F0 y criterio de aprobación |
| 6 | `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` | Valores oficiales de las 30 filas |
| 7 | `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` | Alcance exclusivamente Email y retiro de WhatsApp |
| 8 | `REGLAS_MEDICION_Y_CUMPLIMIENTO_SLA_5G3.md` | Principios de medición no contradichos por 5G.4.4/5G.4.5 |

**Nota:** los documentos de 5G.4.5 no sobrescriben los de 5G.4.4; los precisan. Los de 5G.4.4 no sobrescriben los de 5G.2/5G.3; retiran del alcance lo que ya no aplica. Los documentos originales se conservan íntegros.

## 16.2 Documentos principales por tema

| Tema | Documento |
|---|---|
| Plan de etapa y contexto | `ETAPA_5G_PLAN.md` |
| Alcance Email | `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` |
| Matriz oficial | `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` |
| Validación de matriz y cobertura | `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md` |
| Primera respuesta | `REGLAS_DEFINITIVAS_PRIMERA_RESPUESTA_EMAIL_5G4_5.md` |
| Ciclos y estados | `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` |
| Especificación del motor | `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md` |
| Fase 0 | `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` |
| Resumen de cierre | `RESUMEN_EJECUTIVO_5G4_5.md` |
| Modelo de datos base | `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` |
| Seguridad BFF–Zammad | `SEGURIDAD_INTEGRACION_BFF_SLA_5G4_3.md` |
| Arquitectura Email | `ARQUITECTURA_MOTOR_SLA_EMAIL_5G4_4.md` |
| Decisiones Email | `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` |
| Auditoría de datos COSE | `AUDITORIA_DATOS_SLA_COSE.md` |
| Inventario Zendesk | `INVENTARIO_REAL_ZENDESK.md` |
| Mapa Zendesk–COSE | `MAPA_USO_ZENDESK_COSE.md` |
| Producción | `ROADMAP_PRODUCCION.md`; `AUDITORIA_PREPARACION_PRODUCCION.md` |
| Worker y recursos | `WORKER_MINIMO.md` |

## 16.3 Inventario completo de los 59 documentos fuente

### A. Contexto, canales, Zendesk y producción (13)

1. `AUDITORIA_PREPARACION_PRODUCCION.md`
2. `CATALOGO_AUTOMATIZACIONES_ZENDESK.md`
3. `CONCLUSION_INVENTARIO_5F.md`
4. `ETAPA_5G_PLAN.md`
5. `INVENTARIO_CANALES_Y_SLA_ZENDESK.md`
6. `INVENTARIO_REAL_ZENDESK.md`
7. `INVENTARIO_REPORTES_Y_PRODUCTIVIDAD_ZENDESK.md`
8. `MAPA_USO_ZENDESK_COSE.md`
9. `MIGRACION_GMAIL_DEDICADO.md`
10. `PENDIENTES_ADMINISTRADOR_ZENDESK.md`
11. `RIESGOS_Y_CRITERIOS_ACEPTACION.md`
12. `ROADMAP_PRODUCCION.md`
13. `WORKER_MINIMO.md`

### B. Estadística, matriz y decisiones de 5G.2 (9)

14. `ANALISIS_ESTADISTICO_RESOLUCION.md`
15. `AUDITORIA_DATOS_SLA_COSE.md`
16. `COMPARACION_METODOLOGIAS_SLA.md`
17. `CORRECCIONES_MATRIZ_SLA_5G2_1.md`
18. `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md`
19. `MATRIZ_PROPUESTA_SLA_RESOLUCION.md`
20. `OBSERVACIONES_Y_DECISIONES_PENDIENTES_5G2_1.md`
21. `RESUMEN_EJECUTIVO_5G2.md`
22. `VALIDACION_ESTADISTICA_SLA_5G2_1.md`

### C. Medición, administrador y arquitectura de 5G.3 (8)

23. `ARQUITECTURA_TECNICA_MOTOR_SLA_5G3.md`
24. `COMPATIBILIDAD_SLA_ZAMMAD.md`
25. `DECISIONES_PENDIENTES_5G3.md`
26. `DISENO_FUNCIONAL_ADMINISTRADOR_SLA_5G3.md`
27. `DISENO_INTERFAZ_ADMINISTRADOR_SLA_5G3.md`
28. `MODELO_DATOS_Y_AUDITORIA_SLA_5G3.md`
29. `REGLAS_MEDICION_Y_CUMPLIMIENTO_SLA_5G3.md`
30. `RESUMEN_EJECUTIVO_5G3.md`

### D. Motor nativo, eventos y entrega de 5G.4.2 (8)

31. `ANALISIS_ENTREGA_PRIMERA_RESPUESTA_5G4_2.md`
32. `ARQUITECTURA_BFF_MOTOR_SLA_5G4_2.md`
33. `AUDITORIA_EVENTOS_ZAMMAD_5G4_2.md`
34. `CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md`
35. `DECISIONES_PENDIENTES_5G4_2.md`
36. `DISENO_CICLOS_RESOLUCION_SLA_5G4_2.md`
37. `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md`
38. `RESUMEN_EJECUTIVO_5G4_2.md`

### E. Arquitectura, datos y seguridad de 5G.4.3 (8)

39. `ARQUITECTURA_PROCESAMIENTO_EVENTOS_SLA_5G4_3.md`
40. `DECISIONES_FUNCIONALES_MOTOR_SLA_5G4_3.md`
41. `DISENO_CICLOS_Y_COMPROMISOS_SLA_5G4_3.md`
42. `DISENO_SONDEO_INCREMENTAL_ZAMMAD_5G4_3.md`
43. `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md`
44. `PLAN_IMPLEMENTACION_MOTOR_SLA_5G4_3.md`
45. `RESUMEN_EJECUTIVO_5G4_3.md`
46. `SEGURIDAD_INTEGRACION_BFF_SLA_5G4_3.md`

### F. Corrección de alcance y matriz Email de 5G.4.4 (5)

47. `ARQUITECTURA_MOTOR_SLA_EMAIL_5G4_4.md`
48. `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md`
49. `DECISIONES_PENDIENTES_EMAIL_5G4_4.md`
50. `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md`
51. `RESUMEN_EJECUTIVO_EMAIL_5G4_4.md`

### G. Cierre funcional de 5G.4.5 (6)

52. `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md`
53. `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md`
54. `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md`
55. `REGLAS_DEFINITIVAS_PRIMERA_RESPUESTA_EMAIL_5G4_5.md`
56. `RESUMEN_EJECUTIVO_5G4_5.md`
57. `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md`

### H. Decisiones de arquitectura y pendientes transversales (2)

58. `DECISIONES_ARQUITECTURA.md`
59. `DECISIONES_PENDIENTES_SLA.md`

## 16.4 Este documento

`EPIC_IMPLEMENTACION_SLA_COSE.md` es el documento **60** de la carpeta. No reemplaza a ninguno de los 59 anteriores. Su función es consolidar, ordenar y permitir el seguimiento. Cuando una historia o un criterio de este documento entre en conflicto con una regla de 5G.4.5, prevalece la regla de 5G.4.5 y este documento se corrige por nueva versión.

## 16.5 Confirmación de creación documental

Este documento se creó leyendo los 59 documentos existentes. No se modificó código, base de datos, configuración de Zammad, calendarios, SLA nativos, triggers, webhooks, usuarios, permisos, buzones, credenciales, Zendesk ni COSE. No se inició ningún worker ni servicio. No se sobrescribió ningún documento anterior.

---

**Fin del documento maestro EPIC-SLA-01.**

