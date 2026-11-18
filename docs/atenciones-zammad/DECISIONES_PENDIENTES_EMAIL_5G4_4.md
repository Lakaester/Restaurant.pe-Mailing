# DECISIONES DEL MOTOR SLA — EXCLUSIVAMENTE EMAIL — 5G.4.4

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.4
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Función:** reabrir **únicamente** las decisiones afectadas por el cambio a alcance Email.

---

## 1. Regla de esta revisión

1. No se reabre ninguna decisión que el cambio de alcance no toque.
2. Una decisión se marca **REEMPLAZADA** solo si su contenido cambia (número, canal o criterio).
3. Una decisión se marca **SIN OBJETO** cuando el canal al que se refería ya no existe en el proyecto.
4. Una decisión se marca **CERRADA** cuando el cambio de alcance la resuelve sin necesidad de aprobación adicional.
5. Las decisiones nuevas se identifican con el prefijo `DP-E-` para no confundirlas con las de 5G.4.3.

---

## 2. Decisiones de 5G.4.3: estado vigente

### 2.1 Captura

| ID | Decisión | Estado 5G.4.4 | Nota |
|---|---|---|---|
| CAP-01 | Sondeo API REST como mecanismo principal | **VIGENTE** | Se refuerza: es la única vía para ver `delivery_status` |
| CAP-02 | 1 minuto para primera respuesta pendiente | **REEMPLAZADA** | Cadencia única de 5 min con banda de 2 min |
| CAP-03 | 5 minutos para el resto | **REEMPLAZADA** | Integrada en la cadencia única |
| CAP-04 | Webhooks como complemento futuro | **VIGENTE, con matiz** | No pueden observar `delivery_status` (`transaction_dispatcher.rb` 148-150) |
| CAP-05 | Reconciliación 15 min y diaria | **VIGENTE** | Alcance ajustado a Email |

### 2.2 Primera respuesta

| ID | Decisión | Estado 5G.4.4 | Nota |
|---|---|---|---|
| PR-01 | Artículo público de agente | **VIGENTE** | Ahora también `type = 'email'` |
| PR-02 | Notas internas no cuentan | **VIGENTE** | — |
| PR-03 | `delivery_status = success` | **VIGENTE y único criterio** | Deja de ser una opción entre dos: es la regla |
| PR-04 | WhatsApp aceptado | **SIN OBJETO** | Canal fuera del alcance |
| PR-05 | WhatsApp entrega registrada | **SIN OBJETO** | — |
| PR-06 | WhatsApp no exige lectura | **SIN OBJETO** | — |
| PR-07 | Artículo `fail` no cuenta | **VIGENTE, precisado** | Solo es definitivo con `delivery_retry > 3` |
| PR-08 | Artículo sin estado no cuenta | **VIGENTE** | Queda en "pendiente de confirmación" |

### 2.3 Resolución

| ID | Decisión | Estado |
|---|---|---|
| RES-01 | Inicio en `created_at` | **VIGENTE** |
| RES-02 | Fin en el primer `closed` | **VIGENTE** |
| RES-03 | Sin pausas | **VIGENTE** |
| RES-04 | Tiempo calendario 24/7 | **VIGENTE** |
| RES-05 | Reasignación y prioridad no reinician | **VIGENTE** |
| RES-06 | Reclasificación no modifica el compromiso | **VIGENTE** |

### 2.4 Reaperturas

| ID | Decisión | Estado |
|---|---|---|
| REA-01 | Conservar el primer ciclo | **VIGENTE** |
| REA-02 | Alternativa A: nuevo ciclo al reabrir | **PENDIENTE** (crítica) |
| REA-03 | Histórico por ciclo | **PENDIENTE** (depende de REA-02) |
| REA-04 | Métrica oficial = ciclo 1 | **PENDIENTE** (depende de REA-02) |
| REA-05 | Ciclos posteriores = indicador operativo | **PENDIENTE** |
| REA-06 | Primera respuesta solo en ciclo 1 | **PENDIENTE** |

**Nota:** el cambio de alcance **no** afecta a estas decisiones. Siguen exactamente como estaban.

### 2.5 Congelamiento

| ID | Decisión | Estado | Nota |
|---|---|---|---|
| CON-01 | Snapshot inmutable al clasificar | **VIGENTE** | — |
| CON-02 | Campos del snapshot | **VIGENTE, ajustado** | `channel` pasa a ser `email` |
| CON-03 | Nada posterior modifica el snapshot | **VIGENTE** | — |
| CON-04 | Corrección con auditoría y aprobación | **VIGENTE** | — |

### 2.6 Políticas y matriz

| ID | Decisión | Estado 5G.4.4 | Nota |
|---|---|---|---|
| POL-01 | 65 combinaciones con SLA | **REEMPLAZADA** | Ahora **27** políticas Email |
| POL-02 | 5 combinaciones sin evidencia | **REEMPLAZADA** | Ahora **3** Email |
| POL-03 | Valores sin recálculo | **VIGENTE** | Confirmado en `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` §5 |
| POL-04 | Conteo corregido por canal | **REEMPLAZADA** | Email 30 filas / 3 sin SLA / 27 con SLA |
| POL-05 | Respaldos 90 min y 36 h | **REEMPLAZADA** | Solo respaldo Email de **36 h** |
| POL-06 | Cumplimiento ≥ 80 % | **VIGENTE** | Denominador ahora solo Email |
| POL-07 | Ventana 01/04/2026–31/10/2026 | **VIGENTE** | — |
| POL-08 | Revisión trimestral | **VIGENTE** | — |

### 2.7 Pendientes de 5G.4.3

| ID | Pendiente | Estado 5G.4.4 | Motivo |
|---|---|---|---|
| DP-01 | WhatsApp: aceptación o entrega | **CERRADA** | El canal sale del alcance |
| DP-02 | Aprobar alternativa A de reaperturas | **PENDIENTE** | No afectada |
| DP-03 | Alcance del sondeo de 1 minuto | **REEMPLAZADA** | Sustituida por DP-E-03 |
| DP-04 | Responsable del catálogo | **PENDIENTE (crítica)** | No afectada |
| DP-05 | Tratamiento del 31,1 % fuera de catálogo | **PENDIENTE, redefinida** | Necesita el dato específico de Email |
| DP-06 | Tratamiento de las 5 sin evidencia | **REEMPLAZADA** | Ahora son 3; ver DP-E-07 |
| DP-07 | Persistencia de política si cae el BFF | **PENDIENTE (alta)** | No afectada |
| DP-08 | Retención de eventos y payloads | **PENDIENTE** | Se añade retención de cuerpos de correo |
| DP-09 | Nivel de reporte | **PENDIENTE** | Ahora solo Email; ver DP-E-09 |
| DP-10 | Motivo obligatorio en cambios de política | **PENDIENTE** | No afectada |

---

## 3. Decisiones nuevas (`DP-E`)

### 3.1 Críticas

| ID | Decisión propuesta | Recomendación | Bloquea |
|---|---|---|---|
| **DP-E-01** | Aprobar la matriz Email de 27 políticas como matriz oficial del proyecto | Aprobar sin cambios de valores | Fases 2 y 3 |
| **DP-E-04** | Borde de la meta de 24 h: `≤ 1.440 min` o `< 1.440 min` | `≤ 1.440 min` (coherente con el resto de la matriz) | Fase 4 |
| **DP-E-05** | Tratamiento de `merged`: ¿cierra ciclo u origina divergencia? | Divergencia `orphan_ticket`, no cierre | Fase 3 |

**Heredadas críticas:** DP-02 / REA-02 (ciclos) y DP-04 (responsable del catálogo).

### 3.2 Altas

| ID | Decisión propuesta | Recomendación | Bloquea |
|---|---|---|---|
| **DP-E-02** | Confirmar que el respaldo de 36 h aplica solo a subcategorías fuera de catálogo, nunca a las 3 con muestra insuficiente | Aprobar la distinción | Fase 2 |
| **DP-E-03** | Cadencia de sondeo: 5 min general + 2 min para vencimientos a menos de 4 h | Aprobar | Fase 1 |
| **DP-E-06** | Un `delivery_status = fail` solo es definitivo con `delivery_retry > 3` | Aprobar. Nota: el fallo definitivo crea una nota interna y puede reabrir el ticket | Fase 4 |
| **DP-E-07** | Las 3 combinaciones sin evidencia: sin SLA y revisión a 90 días | Aprobar | Fase 2 |
| **DP-E-08** | Medir el volumen Email fuera de catálogo antes de la fase 2 | Obligatorio | Fase 2 |

**Heredada alta:** DP-07 (persistencia de la política aplicada).

### 3.3 Medias

| ID | Decisión propuesta | Recomendación | Bloquea |
|---|---|---|---|
| **DP-E-09** | Nivel de reporte oficial: global Email y por categoría | Global + por categoría | Fase 5 |
| **DP-E-10** | Mantener `channel` en política y compromiso con `CHECK ('email')` | Mantener, por auditoría | Fase 2 |
| **DP-E-11** | Clasificación tardía: ticket creado días antes y clasificado hoy | Asignar con `started_at = created_at` y marcar `late_classification` | Fase 3 |
| **DP-E-12** | Retención de cuerpos de correo en el BFF | No almacenar cuerpos | Fase 1 |

### 3.4 Heredadas que siguen abiertas

| ID | Pendiente | Prioridad |
|---|---|---|
| DP-02 / REA-02 | Alternativa A de ciclos | Crítica |
| DP-04 / A-13 | Responsable administrativo del catálogo | Crítica |
| DP-07 | Persistencia de la política aplicada | Alta |

---

## 4. Decisiones cerradas por el cambio de alcance

| Pregunta que ya no se hace | Por qué se cierra |
|---|---|
| ¿WhatsApp cumple con aceptación o con entrega? | No hay WhatsApp |
| ¿Se exige lectura del mensaje? | El correo no tiene lectura fiable y no es el canal |
| ¿Se registra `timestamp_delivered`? | No aplica |
| ¿Qué respaldo se usa en WhatsApp? | No aplica |
| ¿Cómo se detecta el estado de entrega de WhatsApp? | No aplica |
| ¿Hay que validar la operatividad del canal WhatsApp? | No aplica |
| ¿Se cifra o se hashea el teléfono? | No se almacena teléfono |
| ¿La latencia de 1 minuto es suficiente para WhatsApp? | No aplica |

**Efecto neto:** se cierran 8 preguntas sin necesidad de análisis adicional.

---

## 5. Decisiones que NO se reabren

Se declaran explícitamente intactas para evitar revisión innecesaria:

1. Arquitectura de motor propio en el BFF.
2. Cero SLA nativos y `ignore_escalation` intacto.
3. Tiempo calendario 24/7.
4. Inicio en `created_at` y fin en el primer `closed`.
5. Sin pausas por `pending close` ni por espera del cliente.
6. Congelamiento del compromiso al clasificar.
7. Reclasificación registrada sin alterar el compromiso.
8. Notas internas no cuentan.
9. Objetivo de cumplimiento ≥ 80 %.
10. Ventana estadística 01/04/2026–31/10/2026.
11. Revisión trimestral de la matriz.
12. Método P75 + escalera de redondeo.
13. Auditoría con motivo obligatorio en correcciones.

---

## 6. Resumen de impacto

| Estado | Cantidad |
|---|---:|
| Vigentes sin cambio | 19 |
| Vigentes con ajuste menor | 4 |
| Reemplazadas | 8 |
| Sin objeto | 3 |
| Cerradas por el alcance | 1 |
| Pendientes heredadas | 12 |
| Nuevas propuestas | 12 |

**Verificación:** 19 + 4 + 8 + 3 + 1 + 12 = 47, que es el total de decisiones de 5G.4.3 (CAP 5, PR 8, RES 6, REA 6, CON 4, POL 8, DP 10).

**Ajustes menores incluidos en los 4 vigentes con ajuste:** PR-03 (pasa a criterio único), PR-07 (definitivo solo tras reintentos), CON-02 (`channel = email`) y CAP-04 (los webhooks no ven la entrega).

**Lectura del cambio:** el alcance Email cierra 1 decisión, deja 3 sin objeto, reemplaza 8 y crea 12 nuevas, casi todas de menor complejidad. El proyecto queda con **10 decisiones críticas o altas** por resolver (5 críticas y 5 altas), frente a las 14 anteriores.

---

## 7. Orden recomendado de aprobación

1. **DP-E-01** (matriz oficial) y **DP-E-04** (borde de 24 h).
2. **DP-E-03** (cadencia de sondeo) y **DP-E-08** (medir fuera de catálogo).
3. **DP-E-02** y **DP-E-07** (respaldo y combinaciones sin evidencia).
4. **DP-02 / REA-02** (ciclos), que sigue siendo la decisión funcional más grande pendiente.
5. **DP-04** (responsable del catálogo) y **DP-07** (persistencia).
6. El resto (`DP-E-05`, `DP-E-06`, `DP-E-09` a `DP-E-12`).

---

## 8. Confirmación

Este documento solo propone y clasifica decisiones. No se aplicó ninguna, no se modificó ningún sistema y no se creó ninguna política.
