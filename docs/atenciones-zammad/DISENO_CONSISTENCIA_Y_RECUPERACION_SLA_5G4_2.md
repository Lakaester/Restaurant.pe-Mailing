# DISEÑO DE CONSISTENCIA Y RECUPERACIÓN DEL MOTOR SLA — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**

---

## 1. Principio rector

> El compromiso de SLA es **inmutable** una vez asignado. Los hechos se reincorporan; el compromiso no se recalcula.

Este principio resuelve el defecto principal del motor nativo, que recalcula vencimientos cuando cambia la política o el calendario (`app/models/concerns/has_escalation_calculation_impact.rb` 6-34; `app/jobs/ticket_escalation_rebuild_job.rb` 6-16).

Consecuencias:

1. Un evento tardío puede **corregir un hecho** (por ejemplo, confirmar un envío).
2. Un evento tardío **no puede cambiar** el plazo comprometido ni su fecha de vencimiento.
3. Una reclasificación **no puede** sustituir la política original.
4. Una reapertura **no puede** borrar el primer cierre.

---

## 2. Fuentes de verdad

| Dato | Fuente de verdad | El BFF lo copia |
|---|---|---|
| Ticket, estado, propietario, prioridad | Zammad | Sí, como hechos |
| Artículos y estado de envío | Zammad | Sí, como hechos |
| Historial de cambios | Zammad | Sí, para reconciliación |
| Política aplicable | Catálogo del BFF | No se copia de Zammad |
| Compromiso de SLA por ticket | **BFF** | Es la autoridad |
| Ciclos y reaperturas | **BFF** | Es la autoridad |

Zammad no almacena el compromiso. El BFF no modifica Zammad.

---

## 3. Idempotencia

### 3.1 Clave propuesta

```
idempotency_key = sha256( source + '|' + event_type + '|' + ticket_id + '|' + entity_id + '|' + occurred_at )
```

Donde `entity_id` es `article_id`, `history_id` o el identificador del cambio.

### 3.2 Regla

- Cada evento se registra con su `idempotency_key` en una tabla de eventos procesados con índice único.
- Si la clave ya existe, el evento se descarta sin efectos.
- Si el mismo hecho llega por dos vías (webhook y sondeo), la segunda se descarta.

### 3.3 Por qué no basta el `event_id`

- El webhook no envía `event_id` propio; solo `X-Zammad-Delivery` (`app/jobs/trigger_webhook_job.rb` 99-102).
- El sondeo no tiene `event_id`.
- La clave derivada de los datos permite deduplicar entre fuentes distintas.

---

## 4. Duplicados

| Causa | Ejemplo | Mitigación |
|---|---|---|
| Reintento del webhook | 5 intentos (`trigger_webhook_job.rb` 7-10) | Clave de idempotencia |
| Varios triggers | Dos triggers con webhook | Clave de idempotencia |
| Webhook + sondeo | Mismo cambio por dos vías | Clave de idempotencia |
| Solapamiento de ventanas | Ventana de reconciliación de 10 min | Clave de idempotencia |

El motor debe tolerar duplicados por diseño, no por suerte.

---

## 5. Eventos fuera de orden

**Problema:** el webhook no garantiza orden. Los jobs se ejecutan en paralelo.

**Solución propuesta:** máquina de estados con control de versión.

Cada ticket en el BFF guarda:

| Campo | Uso |
|---|---|
| `last_occurred_at` | Mayor `occurred_at` aplicado |
| `last_history_id` | Mayor `histories.id` aplicado |
| `state` | Estado actual del ticket según el BFF |
| `state_version` | Contador incremental |

Reglas:

1. Un evento con `occurred_at` anterior al último aplicado se registra pero **no retrocede el estado**.
2. Un cambio de estado se aplica solo si es una transición válida desde el estado actual.
3. Las transiciones inválidas se guardan como `ignored_out_of_order` para auditoría.
4. El cierre se aplica una sola vez: el primero gana.
5. La reapertura se aplica solo si existe un cierre previo.

**Excepción:** la confirmación de envío puede llegar después de otros eventos y **sí debe aplicarse**, porque no cambia el estado del ticket sino el hecho de la primera respuesta. Se trata como evento de hechos, no de estado.

---

## 6. Reintentos

| Nivel | Estrategia |
|---|---|
| Recepción HTTP | Responder 2xx solo tras persistir el evento |
| Procesamiento | Reintento con espera exponencial (1, 5, 15, 60 min) |
| Fallo definitivo | Cola de descarte (`dead letter`) con alerta |
| Sondeo | Reintento en el siguiente ciclo, sin límite |

El BFF debe **persistir antes de procesar**. Si procesa y falla, el evento queda en estado `pending` y se reintenta.

---

## 7. Registro de eventos procesados

Tabla propuesta `sla_event`:

| Columna | Tipo | Uso |
|---|---|---|
| `id` | uuid | PK |
| `idempotency_key` | text | Único |
| `event_type` | text | Tipo |
| `ticket_id` | integer | Ticket |
| `article_id` | integer | Artículo, si aplica |
| `occurred_at` | timestamptz | Cuándo ocurrió en Zammad |
| `received_at` | timestamptz | Cuándo llegó al BFF |
| `source` | text | `webhook`, `poll`, `reconcile` |
| `payload` | jsonb | Cuerpo normalizado |
| `status` | text | `pending`, `applied`, `ignored`, `failed` |
| `error` | text | Motivo del fallo |
| `processed_at` | timestamptz | Cuándo se aplicó |

Índices propuestos: `idempotency_key` único, `(ticket_id, occurred_at)`, `(status, received_at)`.

---

## 8. Reconciliación

### 8.1 Objetivo

Detectar eventos perdidos **sin reiniciar ni modificar compromisos ya asignados**.

### 8.2 Estrategia

1. **Marca de agua por `updated_at`.** El BFF guarda el mayor `updated_at` visto.
2. **Ventana de solapamiento.** Cada ciclo relee los últimos N minutos (propuesta: 15) para cubrir desfase de relojes y transacciones lentas.
3. **Consulta.** `/api/v1/tickets/search` con condición sobre `ticket.updated_at` (`app/controllers/application_controller/renders_models.rb` 122-165).
4. **Comparación por ticket.** Para cada ticket modificado:
   - se lee `/api/v1/ticket_history/:id` (`app/controllers/tickets_controller.rb` 317-325);
   - se leen los artículos (`/api/v1/ticket_articles/by_ticket/:id`);
   - se generan eventos sintéticos con `source='reconcile'`;
   - se aplican con la misma clave de idempotencia.
5. **Detección de huecos.** Si un ticket tiene `updated_at` mayor que la marca de agua pero no generó evento, se registra una divergencia.
6. **Avance de la marca.** Solo avanza cuando el ciclo termina sin errores.

### 8.3 Pseudocódigo

```
para cada ciclo de reconciliación:
  desde = marca_agua - ventana_solapamiento
  tickets = buscar_tickets(updated_at >= desde, orden = updated_at asc)

  para cada ticket:
    hechos = leer_historial(ticket) + leer_articulos(ticket)
    eventos = normalizar(hechos, source='reconcile')
    aplicar(eventos)          # idempotente
    verificar_compromiso(ticket)

  marca_agua = max(updated_at de los tickets leídos)
  registrar_ciclo(ok: true)
```

### 8.4 Frecuencia propuesta

| Modo | Frecuencia | Motivo |
|---|---|---|
| Tiempo real (webhook) | Inmediata | Baja latencia |
| Reconciliación incremental | Cada 5-15 min | Corrige pérdidas |
| Reconciliación completa | Diaria, fuera de horario | Detecta deriva estructural |

### 8.5 Verificación de compromisos

Para cada ticket con SLA asignado, el reconciliador comprueba:

1. Que existe el compromiso.
2. Que su `policy_key` coincide con la clasificación registrada al momento de la asignación.
3. Que el vencimiento no cambió.
4. Que el primer cierre registrado coincide con el de Zammad.
5. Que las reaperturas registradas coinciden con las transiciones de estado.

Si algo no coincide, se registra una **divergencia**, no se corrige automáticamente el compromiso.

---

## 9. Recuperación tras caída del BFF

| Escenario | Acción |
|---|---|
| Caída corta (< ventana) | Reconciliación normal cubre el hueco |
| Caída larga | Reconciliación desde la marca de agua, por lotes |
| Pérdida de la marca de agua | Reconciliación completa desde el inicio del piloto |
| Pérdida de la base del BFF | Restaurar respaldo; si no hay, reconstruir desde Zammad (posible porque los hechos están allí) |

**Nota importante:** el compromiso se puede reconstruir desde Zammad **solo si** se registró la política aplicada en un lugar persistente. Si el BFF pierde esa información, la reconstrucción usaría la clasificación actual y podría diferir de la original. Por eso la política aplicada debe guardarse también en Zammad (atributo o etiqueta) o en un almacenamiento externo duradero. **Decisión pendiente.**

---

## 10. Recuperación tras caída de Zammad

| Escenario | Acción |
|---|---|
| Zammad no responde | El BFF pausa el sondeo, mantiene la cola y reintenta |
| Zammad responde con error 5xx | Reintento con espera; no avanzar marca de agua |
| Zammad restaurado desde respaldo | Reconciliación completa; detectar tickets desaparecidos |
| Tickets eliminados | Marcar como `deleted` en el BFF; no borrar el compromiso histórico |

---

## 11. Divergencias y tratamiento

| Divergencia | Detección | Acción |
|---|---|---|
| Ticket cerrado en Zammad sin cierre en BFF | Reconciliación | Crear evento de cierre con la fecha de Zammad |
| Ticket abierto en Zammad con cierre en BFF | Reconciliación | Registrar reapertura |
| Cambio de categoría no registrado | Historial | Registrar reclasificación; no cambiar compromiso |
| Primera respuesta confirmada tardíamente | Lectura de `delivery_status` | Actualizar hecho; recalcular cumplimiento de primera respuesta |
| Envío fallido detectado después | Lectura de `delivery_status` | Invalidar la primera respuesta; buscar la siguiente |
| Compromiso con política distinta a la clasificación actual | Verificación | Registrar divergencia; no corregir |
| Ticket inexistente en Zammad | Reconciliación | Marcar `orphan`; conservar historial |

---

## 12. Garantías del diseño

| Garantía | Cómo se logra |
|---|---|
| Ningún evento se pierde definitivamente | Webhook + sondeo + reconciliación |
| Ningún evento se aplica dos veces | Clave de idempotencia única |
| El orden no altera el resultado | Máquina de estados con versión |
| El compromiso no se altera | Inmutabilidad explícita |
| Las pérdidas son detectables | Marca de agua + comparación |
| La recuperación es posible | Reconstrucción desde Zammad |

**Nivel de garantía:** *at-least-once* en la captura, *effectively-once* en la aplicación.

---

## 13. Métricas y alertas operativas

| Métrica | Umbral propuesto |
|---|---|
| Eventos pendientes | > 100 durante 10 min |
| Eventos fallidos | > 0 |
| Retraso de reconciliación | > 30 min |
| Divergencias nuevas | > 0 |
| Tickets sin compromiso con categoría válida | > 0 |
| Hueco entre marca de agua y `max(updated_at)` | > 1 h |

---

## 14. Pendientes

| # | Pendiente | Impacto |
|---:|---|---|
| 1 | Dónde persistir la política aplicada si se pierde el BFF | Alto |
| 2 | Frecuencia definitiva de reconciliación | Medio |
| 3 | Retención de eventos | Medio |
| 4 | Ventana de solapamiento | Medio |
| 5 | Tratamiento de tickets eliminados | Bajo |

---

## 15. Confirmación

No se creó ninguna tabla, índice, job ni webhook. Todo es diseño.
