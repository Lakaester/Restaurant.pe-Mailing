# DISEÑO DE CICLOS Y COMPROMISOS SLA — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**
**Estado de REA-02:** propuesta, pendiente de aprobación (ver `DECISIONES_FUNCIONALES_MOTOR_SLA_5G4_3.md`).

---

## 1. Compromiso

Un compromiso es el **snapshot** de la política aplicada al ticket en el momento de la primera clasificación completa.

### 1.1 Cuándo se asigna

- Al primer momento en que el ticket tiene canal, categoría y subcategoría.
- Si el ticket se crea ya clasificado, la asignación ocurre en la creación.
- Si nunca se clasifica, el compromiso queda en `pending_classification` y no cuenta en el denominador.

### 1.2 Qué se fija

Los campos de `sla_commitment` listados en `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` §3.2: política, versión, canal, categoría y subcategoría originales, tiempos, `started_at`, `assigned_at` y vencimientos.

### 1.3 Qué no cambia nunca

| Evento | Efecto sobre el compromiso |
|---|---|
| Reasignación | Ninguno |
| Cambio de prioridad | Ninguno |
| Cambio de grupo | Ninguno |
| Reclasificación (categoría o subcategoría) | Ninguno. Se incrementa `reclassified_count` y se registra en `sla_audit` |
| Cambio de estado a pendiente | Ninguno (no pausa) |
| Cambio en la matriz publicada | Ninguno. Solo afecta tickets nuevos |
| Desactivación de la política | Ninguno. Solo afecta tickets nuevos |
| Corrección administrativa | Solo con `sla_audit` y motivo (CON-04) |

### 1.4 Reclasificación: registro sin efecto

Cuando un agente cambia la categoría de un ticket con compromiso:

1. Se registra el evento `ticket.classified` con valores anterior y nuevo.
2. Se incrementa `reclassified_count`.
3. Se escribe una fila en `sla_audit` con `action = 'reclassify'`… (se añade a la lista de acciones de `sla_audit`; pendiente de aprobación).
4. El compromiso y sus vencimientos **no cambian**.
5. La matriz del nuevo valor **no se aplica** a este ticket.

**Consecuencia:** un ticket mal clasificado conserva el compromiso de la clasificación inicial. Esto es lo que aprobó 5G.3 (A-08). Si el negocio quisiera lo contrario, sería una decisión nueva.

### 1.5 Ticket sin compromiso al reclasificar

Si el ticket no tenía compromiso (estaba `pending_classification`) y ahora se clasifica, **sí** se asigna compromiso en ese momento, con `started_at = created_at`.

**Riesgo:** un ticket creado hace 3 días y clasificado hoy recibiría un vencimiento ya vencido. Ver §6 (decisión pendiente).

---

## 2. Ciclo de resolución

### 2.1 Ciclo 1

- `opened_at = started_at` (creación del ticket).
- `due_at = resolution_due_at` del compromiso.
- Se cierra en la **primera** transición a estado tipo `closed`.
- `outcome = met` si `closed_at ≤ due_at`; `missed` en caso contrario.

### 2.2 Cierre del ciclo 1

| Evento | Acción |
|---|---|
| Transición a `closed` con ciclo 1 abierto | Cierra ciclo 1; calcula `outcome` |
| Transición a `closed` con ciclo 1 ya cerrado y sin reapertura | Registrar `reclose` en `sla_audit`; no modifica nada |
| Transición a `merged` | Tratar como cierre (ver §5.4) |

### 2.3 Reapertura (alternativa A, REA-02)

Al pasar de un estado `closed` a un estado abierto:

1. Se registra `ticket.reopened` con el cierre anterior.
2. Se crea `sla_cycle` con `cycle_number = N + 1`, `opened_at = fecha de reapertura`.
3. `due_at = opened_at + resolution_minutes` del compromiso original.
4. El ciclo N queda cerrado con su `outcome` original, **sin cambios**.
5. Ciclo N+1 no tiene primera respuesta (REA-06).

**Regla de cálculo de `due_at` del ciclo N+1:** usar el mismo `resolution_minutes` de la política original. Es una decisión, no un hecho del negocio; queda como pendiente (§6).

### 2.4 Cierre del ciclo N+1

Igual que el ciclo 1. Su `outcome` se reporta como **indicador operativo**, no como cumplimiento histórico (REA-04 y REA-05).

### 2.5 Reapertura sin ciclo nuevo (alternativa B, no recomendada)

Si se aprueba B: no se crea `sla_cycle`. La reapertura se registra en `sla_audit` y en `sla_event`. El cierre original es el único resultado.

---

## 3. Primera respuesta por ciclo

| Ciclo | Primera respuesta |
|---|---|
| 1 | Medida, según PR-01 a PR-08 |
| 2 o posterior | No medida (REA-06) |

En `sla_commitment` solo se guarda la primera respuesta del ciclo 1. Esto evita una segunda columna de primera respuesta en `sla_cycle`.

---

## 4. Ejemplos

### 4.1 Creación y primera respuesta a tiempo

| Hora | Evento | Resultado |
|---|---|---|
| Lun 10:00 | Creación; WhatsApp; política 15 min / 2 h | `started_at=10:00`, `first_response_due_at=10:15`, `resolution_due_at=12:00` |
| Lun 10:09 | Artículo de agente, `delivery_status=success` | `first_response_at=10:09`, `met` |
| Lun 11:30 | Cierre | Ciclo 1 cerrado, `met` |

### 4.2 Cierre tardío y reapertura

| Hora | Evento | Resultado |
|---|---|---|
| Lun 10:00 | Creación; política 2 h | `resolution_due_at=12:00` |
| Lun 13:00 | Cierre | Ciclo 1 cerrado, `missed` |
| Lun 15:00 | Reapertura (REA-02) | Ciclo 2 abierto, `due_at = 17:00` |
| Lun 16:30 | Cierre | Ciclo 2 cerrado, `met` (indicador operativo) |

El cumplimiento histórico del ticket es **missed** (ciclo 1). El ciclo 2 aparece en el reporte operativo.

### 4.3 Reclasificación después de reabrir

| Hora | Evento | Resultado |
|---|---|---|
| Lun 15:00 | Reapertura | Ciclo 2 con `due_at = 17:00` |
| Lun 15:20 | Cambio de categoría | Registro en `sla_audit`; `due_at` del ciclo 2 **no** cambia |

### 4.4 Cierre, merge y eliminación

| Caso | Tratamiento |
|---|---|
| Fusión con otro ticket | Cierra el ciclo abierto; no abre otro |
| Eliminación de ticket | Ciclo abierto queda `open` y se registra `orphan_ticket` en `sla_divergence` |
| Reapertura de un ticket fusionado | No aplica: estado `merged` es terminal (decisión pendiente, §6) |

---

## 5. Reglas de integridad

1. Un compromiso tiene como máximo un ciclo `open` (índice único parcial en `sla_cycle`).
2. Un ciclo N+1 solo existe si el ciclo N está cerrado.
3. `due_at` de un ciclo es inmutable.
4. `closed_at` de un ciclo es inmutable una vez fijado.
5. `outcome` solo cambia de `open` a `met` o `missed`.
6. Un ticket sin compromiso no tiene ciclos.

---

## 6. Decisiones pendientes específicas

| # | Pendiente | Recomendación |
|---:|---|---|
| 1 | Aprobar REA-02 (ciclo nuevo) o B | A |
| 2 | `due_at` del ciclo N+1: mismo `resolution_minutes` original, o valor propio de reapertura | Mismo valor original |
| 3 | Reclasificación de un ticket sin compromiso más antiguo que su política | Asignar con `started_at = created_at` y marcar `late_classification` en divergencias |
| 4 | Estado `merged` como terminal | Sí |
| 5 | Medir primera respuesta en ciclos posteriores | No (REA-06) |
| 6 | Añadir `reclassify` a las acciones de `sla_audit` | Sí |

---

## 7. Métricas que dependen de este diseño

| Métrica | Fórmula | Tipo |
|---|---|---|
| Cumplimiento histórico de resolución | Ciclos 1 `met` / ciclos 1 cerrados | Oficial |
| Cumplimiento de primera respuesta | Compromisos con `first_response_outcome = met` / evaluables | Oficial |
| Reincidencia | Tickets con ciclo ≥ 2 / tickets con ciclo 1 cerrado | Operativa |
| Cumplimiento de ciclos posteriores | Ciclos ≥ 2 `met` / ciclos ≥ 2 cerrados | Operativa |
| Reclasificados | Compromisos con `reclassified_count > 0` | Calidad de clasificación |

---

## 8. Confirmación

Diseño. No se creó ninguna tabla, ciclo ni compromiso. No se modificó ningún ticket.
