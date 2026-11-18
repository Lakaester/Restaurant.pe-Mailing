# ARQUITECTURA DE PROCESAMIENTO DE EVENTOS SLA — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**

---

## 1. Objetivo

Definir cómo el motor SLA captura, persiste, aplica y reconcilia los hechos de Zammad, de forma que:

- no haya eventos duplicados aplicados;
- no haya compromisos duplicados;
- el reloj no se reinicie;
- ningún vencimiento cambie retroactivamente;
- no se pierda un cierre;
- no se pierda una confirmación de entrega.

---

## 2. Pipeline

```
 ┌────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌────────────┐
 │  Captura   │──►│ Persistencia │──►│ Normalización│──►│ Aplicación   │──►│ Compromiso │
 │ (sondeo)   │   │ hechos crudos│   │ a eventos    │   │ (máquina de  │   │ inmutable  │
 └────────────┘   └──────────────┘   └──────────────┘   │ estados)     │   └────────────┘
                                                        └──────┬───────┘
                                                               │
                                                   ┌───────────▼────────────┐
                                                   │ Reconciliación         │
                                                   │ (ventana + diaria)     │
                                                   └────────────────────────┘
```

Cada etapa es reanudable. Ninguna etapa modifica un compromiso ya asignado.

---

## 3. Etapas

### 3.1 Captura

| Aspecto | Definición |
|---|---|
| Entrada | Respuestas de `/tickets/search`, `/ticket_articles/by_ticket/{id}` y, si aplica, `/ticket_history/{id}` |
| Salida | Registros en `sla_raw_fetch` (opcional) y en `sla_event` |
| Cursor | `watermark` en `sla_sync_run` |
| Frecuencia | CAP-02 y CAP-03 de `DECISIONES_FUNCIONALES_MOTOR_SLA_5G4_3.md` |

**Regla:** la captura no interpreta. Solo lee y registra.

### 3.2 Persistencia de hechos

Antes de cualquier interpretación, cada hecho se persiste con:

- `idempotency_key` único;
- `payload` normalizado;
- `status = pending`;
- `received_at`.

**Regla de persistir antes de procesar:** si el proceso cae entre la lectura y el procesamiento, el hecho ya está guardado y se reprocesará.

### 3.3 Normalización a eventos

Cada hecho se convierte a uno de los tipos del contrato (`CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md`).

Derivación de eventos desde lecturas:

| Fuente | Evento generado |
|---|---|
| Ticket nuevo (no visto antes) | `ticket.created` |
| Cambio de `state_id` respecto al último visto | `ticket.state_changed`; `ticket.closed` o `ticket.reopened` si aplica |
| Cambio de `category` o `subcategory` | `ticket.classified` |
| Artículo nuevo (`id` no visto) | `article.created` |
| Artículo con `delivery_status` nuevo | `article.delivery_confirmed` o `article.delivery_failed` |
| Cambio de `owner_id` | `ticket.assigned` (opcional) |
| Cambio de `priority_id` | `ticket.priority_changed` (opcional) |

### 3.4 Aplicación

El procesador aplica eventos en orden de `occurred_at`, con desempate por `event_id`, y respeta las máquinas de estados de §4.

### 3.5 Reconciliación

Ver §7.

---

## 4. Máquinas de estados

### 4.1 Entrega de artículo

```
                 ┌──────────┐
  article.created│ sin_estado│
                 └────┬─────┘
          envío aceptado│        envío fallido
                 ┌──────▼─────┐      ┌──────────┐
                 │  aceptado  │      │  fallido │
                 └──────┬─────┘      └────┬─────┘
          entrega confirmada│     nuevo reintento│
                 ┌──────▼─────┐      ┌────▼─────┐
                 │ entregado  │      │ aceptado │ (reintento exitoso)
                 └──────┬─────┘      └──────────┘
             lectura│
                 ┌──────▼─────┐
                 │   leído    │
                 └────────────┘
```

Reglas:

1. Las transiciones solo avanzan. `aceptado` no vuelve a `sin_estado`.
2. `fallido` puede pasar a `aceptado` si hay reintento exitoso; el artículo conserva ambas marcas en el historial.
3. Para primera respuesta, solo cuentan `aceptado`, `entregado` y `leído` (según PR-04 a PR-06).

### 4.2 Ciclo de resolución

```
  ┌──────────┐  cierre   ┌──────────┐  reapertura  ┌──────────┐
  │ abierto  │──────────►│ cerrado  │─────────────►│ abierto  │  (ciclo N+1)
  └──────────┘           └──────────┘              └──────────┘
```

Reglas:

1. Solo se crea un ciclo nuevo si el anterior está `cerrado` (REA-02).
2. El cierre de un ciclo ya cerrado no se aplica como cierre nuevo; se registra como `reclose`.
3. El `due_at` de un ciclo es inmutable.

### 4.3 Compromiso

```
  ┌──────────┐  asignación  ┌──────────┐  cierre de ciclo  ┌─────────┐
  │ pendiente│─────────────►│ asignado │──────────────────►│ cerrado │
  └──────────┘              └──────────┘                   └─────────┘
                                 │
                                 └─ sin_politica (si no hay coincidencia)
```

Reglas:

1. `asignado` es el único estado con snapshot.
2. Un compromiso `sin_politica` **no** cuenta como incumplido (5G.3, §8).
3. La asignación ocurre una vez, en la primera clasificación completa.

---

## 5. Reglas de integridad

| Riesgo | Regla |
|---|---|
| Evento duplicado aplicado | `idempotency_key` único en `sla_event`; inserción con `ON CONFLICT DO NOTHING` (conceptual) |
| Compromiso duplicado | Restricción única `(ticket_id)` en `sla_commitment` |
| Ciclo duplicado | Restricción única `(commitment_id, cycle_number)` |
| Reinicio del reloj | `started_at` inmutable; ningún evento lo modifica |
| Cambio retroactivo de vencimiento | `due_at` inmutable; el procesador no reescribe |
| Pérdida de cierre | El cierre se persiste como evento antes de aplicarse; reconciliación lo recupera |
| Pérdida de confirmación de entrega | Lectura de `delivery_status` en cada ciclo para artículos con estado pendiente |
| Confirmación después de vencimiento | Se registra con fecha real; la primera respuesta cumple o no según `delivered_at ≤ first_response_due_at` |
| Evento fuera de orden | La máquina de estados ignora transiciones inválidas y las guarda como `ignored_out_of_order` |

---

## 6. Idempotencia

### 6.1 Clave

```
idempotency_key = sha256(
  'zammad' | event_type | ticket_id | entity_id | occurred_at_utc
)
```

`entity_id` es `article_id`, `history_id` o el número de versión del ticket (`updated_at` en microsegundos) cuando no hay otro identificador.

### 6.2 Aplicación

1. Insertar el evento con su clave. Si ya existe, el evento se descarta.
2. Aplicar la transición. Si la transición es inválida, marcar `ignored`.
3. Marcar `applied` en la misma transacción que la transición.

**Regla:** la inserción del evento y la transición de estado van en **una transacción**. Si falla la transición, no queda el evento `applied`.

---

## 7. Reintentos y reconciliación

### 7.1 Reintentos

| Fallo | Acción |
|---|---|
| Error de red al leer Zammad | Reintento con espera exponencial (1, 2, 4, 8 min); no avanza watermark |
| Error al persistir | Reintento inmediato; si persiste, detener ciclo y alertar |
| Error de aplicación de un evento | Evento a `failed`; ciclo continúa; alerta; reintento manual o automático acotado |
| Evento `failed` tras 5 reintentos | Cola de descarte con alerta; no bloquea otros eventos |

### 7.2 Reconciliación incremental

Cada 15 minutos:

1. Leer tickets con `updated_at >= watermark - 15 min`.
2. Para cada uno, comparar el estado observado con el último estado aplicado.
3. Generar eventos faltantes con `source = reconcile`.
4. Aplicar con idempotencia.
5. Registrar divergencias si el compromiso no coincide con la clasificación original.

### 7.3 Reconciliación diaria

Una vez al día, fuera de horario:

1. Leer todos los tickets con `state` abierto y todos los cerrados del periodo de retención activo.
2. Verificar `close_at`, cierres y reaperturas contra `sla_cycle`.
3. Verificar `delivery_status` de artículos sin estado final.
4. Registrar divergencias en `sla_divergence`.

**Regla:** la reconciliación **nunca** modifica `due_at`, `started_at` ni `policy_key`. Solo agrega hechos o registra divergencias.

---

## 8. Recuperación tras interrupciones

### 8.1 Caída del BFF

| Momento | Efecto | Recuperación |
|---|---|---|
| Entre lectura y persistencia | Hechos no guardados | El siguiente ciclo los vuelve a leer (watermark no avanzó) |
| Entre persistencia y aplicación | Eventos `pending` | Procesador reanuda `pending` en el siguiente arranque |
| Durante aplicación | Transacción revertida | Reintento; idempotencia evita duplicados |
| Pérdida de base del BFF | Compromisos perdidos | Restaurar respaldo; si no, reconstrucción desde Zammad **solo** con política persistida externamente (DP-07) |

### 8.2 Caída de Zammad

| Momento | Efecto | Recuperación |
|---|---|---|
| Sin respuesta | Ciclos fallan | Watermark fijo; reanuda al volver |
| Respuesta parcial | Ciclo incompleto | Watermark no avanza; se rehace la ventana |
| Restauración desde respaldo de Zammad | Tickets con `updated_at` antiguo | Reconciliación diaria detecta cambios perdidos |

### 8.3 Interrupción del worker

El worker de Zammad no interviene en el sondeo. Su estado no afecta a este diseño.

---

## 9. Qué no debe ocurrir

| Prohibido | Motivo |
|---|---|
| Recalcular `due_at` al recibir un evento | Cambio retroactivo |
| Reasignar `policy_key` por cambio de categoría | Viola CON-03 |
| Reiniciar `started_at` por reasignación o prioridad | Viola RES-05 |
| Aplicar `closed` si ya existe un cierre del mismo ciclo | Duplicado |
| Marcar primera respuesta sin `delivery_status` | Viola PR-08 |
| Escribir en Zammad desde el procesador | Viola la arquitectura |
| Borrar eventos aplicados | Pierde trazabilidad |

---

## 10. Observabilidad

| Métrica | Umbral propuesto |
|---|---|
| Eventos `pending` con antigüedad > 10 min | > 0 |
| Eventos `failed` | > 0 |
| Ciclos de sondeo fallidos consecutivos | ≥ 2 |
| Retraso de watermark | > 5 min (sondeo) |
| Divergencias nuevas por reconciliación | > 0 |
| Compromisos sin `policy_key` | 0 |

---

## 11. Confirmación

Diseño conceptual. No se creó ningún proceso, tabla ni evento.
