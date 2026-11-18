# DISEÑO DE CICLOS DE RESOLUCIÓN Y REAPERTURAS — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**

---

## 1. Problema

El requisito aprobado en 5G.3 dice:

> Las reaperturas deben conservar la trazabilidad del primer cierre y sus resultados.

El motor nativo no cumple ese requisito de forma completa.

---

## 2. Comportamiento nativo verificado

**VERIFICADO (código).**

| Hecho | Referencia |
|---|---|
| `close_at` se fija solo si está vacío | `app/models/ticket/sets_close_time.rb` 27-31 |
| `last_close_at` se actualiza en cada cierre | `app/models/ticket/sets_close_time.rb` 22-25 |
| `close_escalation_at` se anula si ya hay `close_at` | `lib/escalation.rb` 172-180 |
| `close_at` nunca se borra al reabrir | `sets_close_time.rb` 27-31 |
| El vencimiento de resolución no se reactiva tras el primer cierre | `lib/escalation.rb` 175-178 |

**Consecuencia:** tras la primera resolución, el ticket no vuelve a tener plazo de resolución. El motor nativo mide **un solo ciclo**.

---

## 3. Definiciones

| Término | Definición |
|---|---|
| Ciclo | Periodo entre una apertura y su cierre |
| Primer ciclo | Desde `created_at` hasta el primer `closed` |
| Primer cierre | Primer `close_at` registrado |
| Reapertura | Transición de `closed` a un estado abierto |
| Ciclo posterior | Desde la reapertura hasta el siguiente cierre |
| Cumplimiento del ciclo | Comparación entre el cierre del ciclo y su vencimiento |

Un ticket puede tener N ciclos. El primero es el que corresponde al compromiso original.

---

## 4. Alternativa A — nuevo ciclo con nuevo compromiso

### 4.1 Descripción

- El primer SLA se conserva intacto.
- Al reabrir, se abre un **ciclo 2** con su propio compromiso de resolución.
- El nuevo compromiso se calcula desde la fecha de reapertura.
- El primer ciclo sigue siendo consultable y sigue siendo la referencia histórica.
- Cada ciclo tiene su propio resultado de cumplimiento.

### 4.2 Reglas

1. El compromiso del ciclo 1 no se modifica.
2. El ciclo 2 se crea solo si la reapertura ocurre después de un cierre.
3. El ciclo 2 usa la política congelada del ticket, no una nueva clasificación.
4. Si el ticket se reclasifica después de reabrir, el compromiso del ciclo 2 **no** cambia.
5. El ciclo 2 termina en el siguiente `closed`.
6. Una nueva reapertura abre el ciclo 3, y así sucesivamente.
7. La primera respuesta solo existe en el ciclo 1 (los ciclos posteriores no tienen primera respuesta).

### 4.3 Ventajas

- Permite medir el esfuerzo real de cada reapertura.
- Refleja el tiempo de atención del segundo ciclo.
- No pierde el histórico.
- Permite detectar reaperturas crónicas.

### 4.4 Riesgos

- Puede incentivar cerrar rápido y reabrir.
- Complica el reporte: hay que decidir qué ciclo es el oficial.
- Requiere una regla explícita de cuál es la métrica de cumplimiento.

---

## 5. Alternativa B — sin nuevo compromiso

### 5.1 Descripción

- El primer SLA se conserva.
- La reapertura se registra como evento.
- **No** se genera un nuevo compromiso de resolución.
- El ticket reabierto se sigue atendiendo, pero no tiene plazo de resolución.
- El cumplimiento histórico se calcula solo con el primer ciclo.

### 5.2 Reglas

1. El cierre original es el único resultado de cumplimiento.
2. La reapertura se registra con fecha, usuario y motivo.
3. El tiempo del segundo ciclo se mide como **tiempo de atención**, no como SLA.
4. El ticket reabierto puede reportarse como reincidencia.
5. No se generan vencimientos nuevos.

### 5.3 Ventajas

- Máxima simplicidad.
- Coincide con el comportamiento nativo actual.
- Evita incentivos perversos.
- El compromiso original nunca se contamina.

### 5.4 Riesgos

- No hay plazo para el segundo ciclo.
- Un ticket reabierto puede quedar abierto indefinidamente sin alerta.
- No se mide la calidad de la reatención.

---

## 6. Comparación

| Criterio | A. Nuevo ciclo | B. Sin nuevo compromiso |
|---|---|---|
| Conserva el primer cierre | Sí | Sí |
| Conserva el primer resultado | Sí | Sí |
| Mide el segundo ciclo | Sí | No (solo tiempo) |
| Genera alertas en el segundo ciclo | Sí | No |
| Complejidad de implementación | Media | Baja |
| Complejidad de reporte | Media | Baja |
| Riesgo de incentivo perverso | Medio | Bajo |
| Coincide con el motor nativo | No | Sí |
| Requiere decisión funcional nueva | Sí | No |

---

## 7. Recomendación

**Recomendación: alternativa A**, con dos condiciones.

### 7.1 Condiciones

1. **La métrica oficial de cumplimiento sigue siendo el ciclo 1.** El ciclo 2 se reporta como indicador operativo separado, no como parte del cumplimiento histórico.
2. **El ciclo 2 usa la política congelada del ticket.** Una reclasificación posterior no genera un nuevo compromiso.

### 7.2 Motivo

- El requisito aprobado exige trazabilidad del primer cierre, y A la conserva.
- B deja sin plazo un ticket que sí está siendo atendido, lo que contradice el objetivo de medir el servicio.
- A permite detectar reaperturas crónicas, que es información operativa valiosa.
- El riesgo de incentivo perverso se neutraliza separando las métricas.

### 7.3 Estado

**PENDIENTE DE APROBACIÓN.** Esta recomendación no reemplaza una decisión funcional. Si se aprueba B, el diseño de datos se simplifica y se elimina la tabla de ciclos.

---

## 8. Modelo de datos propuesto

### 8.1 Tabla `sla_cycle`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid | PK |
| `ticket_id` | integer | Ticket |
| `cycle_number` | integer | 1, 2, 3… |
| `opened_at` | timestamptz | `created_at` o fecha de reapertura |
| `closed_at` | timestamptz | Cierre del ciclo, si existe |
| `due_at` | timestamptz | Vencimiento del ciclo |
| `policy_key` | text | Política aplicada |
| `first_response_at` | timestamptz | Solo ciclo 1 |
| `first_response_due_at` | timestamptz | Solo ciclo 1 |
| `outcome` | text | `met`, `missed`, `open`, `no_sla` |
| `opened_by_event` | uuid | Evento que abrió el ciclo |
| `closed_by_event` | uuid | Evento que lo cerró |

Índice único propuesto: `(ticket_id, cycle_number)`.

### 8.2 Tabla `sla_reopen`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid | PK |
| `ticket_id` | integer | Ticket |
| `from_cycle` | integer | Ciclo cerrado |
| `to_cycle` | integer | Ciclo abierto |
| `reopened_at` | timestamptz | Fecha |
| `actor_id` | integer | Usuario |
| `reason` | text | Motivo, si se captura |
| `event_id` | uuid | Evento asociado |

### 8.3 Reglas de integridad

1. No puede existir un ciclo 2 sin ciclo 1 cerrado.
2. No puede existir más de un ciclo abierto por ticket.
3. El ciclo 1 siempre empieza en `created_at`.
4. `due_at` es inmutable una vez creado.
5. `outcome` solo cambia de `open` a `met` o `missed`.

---

## 9. Métricas bajo la alternativa A

| Métrica | Fórmula | Uso |
|---|---|---|
| Cumplimiento histórico | Ciclos 1 cumplidos / ciclos 1 cerrados | Métrica oficial |
| Reincidencia | Tickets con al menos una reapertura / tickets cerrados | Operativa |
| Reaperturas por ticket | Promedio de ciclos > 1 | Operativa |
| Cumplimiento del ciclo 2 | Ciclos 2 cumplidos / ciclos 2 cerrados | Operativa |
| Tiempo de reatención | Promedio `closed_at - opened_at` en ciclos > 1 | Operativa |
| Tasa de reapertura en 24 h | Reaperturas dentro de 24 h del cierre | Calidad |

---

## 10. Casos límite

| Caso | Alternativa A | Alternativa B |
|---|---|---|
| Cierre y reapertura inmediata | Ciclo 2 desde la reapertura | Sin nuevo plazo |
| Varias reaperturas | Ciclos 3, 4… | Solo eventos |
| Reapertura por error de clasificación | Ciclo 2 con política congelada | Sin nuevo plazo |
| Reclasificación después de reabrir | No cambia el ciclo 2 | No aplica |
| Ticket fusionado | Cierra el ciclo; no abre otro | Cierra el ciclo |
| Ticket eliminado | Ciclo queda `open` y se marca huérfano | Igual |
| Reapertura sin cierre previo | Inválida; se ignora | Igual |

---

## 11. Relación con el requisito de primera respuesta

La primera respuesta solo tiene sentido en el ciclo 1.

- En los ciclos 2 y siguientes no hay "primera respuesta"; hay "primera respuesta del ciclo".
- Se propone **no medir** primera respuesta en ciclos posteriores, para evitar métricas artificiales.
- Si se decidiera medirla, requeriría una decisión funcional nueva.

---

## 12. Pendientes

| # | Pendiente | Prioridad |
|---:|---|---|
| 1 | Aprobar A o B | **Crítica** |
| 2 | Definir si el ciclo 2 tiene alertas | Alta |
| 3 | Definir si se mide primera respuesta en ciclos posteriores | Media |
| 4 | Definir captura del motivo de reapertura | Baja |
| 5 | Definir tratamiento de tickets fusionados | Media |

---

## 13. Confirmación

No se creó ninguna tabla ni campo. No se modificó ningún ticket. Todo es diseño.
