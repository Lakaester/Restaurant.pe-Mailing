# ARQUITECTURA DEL MOTOR SLA — EXCLUSIVAMENTE EMAIL — 5G.4.4

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.4
**Fecha:** 16/11/2026
**Modo:** diseño, solo lectura.
**Base:** `ARQUITECTURA_PROCESAMIENTO_EVENTOS_SLA_5G4_3.md`, simplificada al canal correo.
**Estado:** diseño. **No implementado.**

---

## 1. Principio

| Componente | Responsable |
|---|---|
| Tickets, artículos, usuarios, grupos, estados | Zammad (fuente de hechos) |
| Políticas, compromisos, vencimientos, ciclos, alertas, auditoría | Motor SLA propio en el BFF |
| Cálculo de SLA nativo | **Desactivado.** Cero políticas |

Reglas estructurales que no cambian:

1. El BFF **no escribe** en Zammad.
2. Cero SLA nativos; `ignore_escalation` intacto.
3. Tiempo calendario 24/7, sin pausas.
4. Inicio en `created_at`; resolución en el primer estado `closed`.
5. Compromiso congelado al clasificar.

---

## 2. Componentes (vista simplificada)

```
Zammad (API REST, solo lectura)
   │
   │ 1. tickets modificados (updated_at)
   │ 2. artículos del ticket (delivery_status)
   │ 3. historial del ticket (transiciones de estado)
   ▼
┌─────────────────────────────────────────────────────┐
│ BFF                                                  │
│                                                      │
│  Ingesta ─► Hechos ─► Normalización ─► Motor SLA     │
│                                       │              │
│                                       ├─ Compromiso  │
│                                       ├─ Ciclos      │
│                                       ├─ Alertas     │
│                                       └─ Auditoría   │
│                                                      │
│  Reconciliación ─► Divergencias                      │
└─────────────────────────────────────────────────────┘
   │
   ▼
C.O.S.E. (consulta de cumplimiento)
```

**No hay nodo de WhatsApp, ni adaptador de proveedor de mensajería, ni webhook de estados de entrega.**

---

## 3. Detección de la primera respuesta efectiva (correo)

### 3.1 Cadena verificada en código

| Paso | Hecho | Referencia |
|---:|---|---|
| 1 | Se crea el artículo de correo del agente y se encola el envío | `app/models/ticket/article/enqueue_communicate_email_job.rb` |
| 2 | El job envía por SMTP o Microsoft Graph | `app/jobs/ticket_article_communicate_email_job.rb` |
| 3 | Si el envío se acepta, guarda `delivery_status = success` y `delivery_status_date` | idem, líneas 103-108 |
| 4 | Si falla, guarda `delivery_status = fail`, mensaje y fecha | idem, líneas 142-151 |
| 5 | Cada intento incrementa `delivery_retry` | idem, líneas 34-35 |
| 6 | Tras más de 3 reintentos se notifica el fallo definitivo | idem, línea 154 |
| 7 | El guardado del artículo dispara `after_commit :ticket_touch` | `app/models/ticket/article.rb` 49 |
| 8 | `ticket.touch` actualiza `updated_at` del ticket | idem, 472-474 |
| 9 | La API expone `preferences` del artículo, con `delivery_status` | `app/models/ticket/article/assets.rb` 47 |

### 3.2 Qué prueba exactamente `delivery_status = success`

| Prueba | ¿Lo garantiza? |
|---|---|
| El artículo se generó y se envió | **Sí** |
| El servidor de salida (SMTP o Graph) aceptó el mensaje | **Sí** |
| El mensaje llegó a la bandeja del destinatario | **No** |
| El destinatario lo leyó | **No** |

**Consecuencia:** la regla del alcance —"artículo público de agente con confirmación de envío exitoso"— se cumple literalmente con `delivery_status = success`. No se exige recibo de entrega, que el correo no proporciona de forma fiable.

**Advertencia que debe quedar registrada:** este criterio mide **aceptación de envío**, no recepción. Es el máximo que el canal permite y está alineado con el requisito, pero no debe presentarse al negocio como "correo entregado".

### 3.3 Por qué no se usa `first_response_at` de Zammad

**Verificado en 5G.4.2:** `first_response_at` se fija en la **creación** del artículo, no en la confirmación de envío. El caso del ticket 7 lo demuestra: `first_response_at` coincide al segundo con el `created_at` del artículo, mientras la confirmación llegó 9 h 34 min después.

**Regla:** el motor **ignora** `first_response_at` y calcula su propia primera respuesta efectiva.

### 3.4 Estados de entrega del correo

```
        artículo de agente (público, tipo email)
                     │
                     ▼
              ┌─────────────┐
              │  sin_estado │◄── el job aún no terminó
              └──────┬──────┘
       success       │        fail
              ┌──────▼──────┐  ┌──────────────┐
              │  aceptado   │  │   fallido    │
              └─────────────┘  └──────┬───────┘
                                    │ reintento exitoso
                                    ▼
                              ┌─────────────┐
                              │  aceptado   │
                              └─────────────┘
```

Reglas:

1. `aceptado` es estado final para el cumplimiento.
2. `fallido` con `delivery_retry ≤ 3` es **provisional**: puede pasar a `aceptado`.
3. `fallido` con `delivery_retry > 3` es **definitivo**: ese artículo no cuenta nunca.
4. Un artículo `fallido` no bloquea al siguiente artículo del agente; se evalúa el siguiente candidato.
5. `sin_estado` no cuenta todavía; el ticket queda en "pendiente de confirmación".

### 3.5 Candidatos a primera respuesta

Un artículo cuenta como candidato solo si cumple **todo**:

| Condición | Campo |
|---|---|
| Es público | `internal = false` |
| Lo escribió un agente | `sender = 'Agent'` |
| Es correo | `type = 'email'` |
| Tiene confirmación | `preferences['delivery_status'] = 'success'` |
| Es posterior o igual a la creación | `created_at >= ticket.created_at` |

Una nota interna (`internal = true`) **nunca** cuenta, aunque sea del agente.
Un artículo de cliente **nunca** cuenta.
Un artículo de otro tipo (teléfono, WhatsApp, web) **no existe en el alcance** y se ignora si apareciera.

### 3.6 Cómo se detecta de forma confiable

| Mecanismo | Función |
|---|---|
| Sondeo de tickets por `updated_at` | El `touch` del artículo al confirmar eleva `updated_at` (INFERIDO del código; prueba 0.6 pendiente) |
| Lectura de artículos del ticket | Obtiene `delivery_status`, `delivery_status_date` y `delivery_retry` |
| Comparación con lo ya persistido | Evita reprocesar y detecta cambios tardíos |
| Reconciliación incremental (15 min) | Recupera confirmaciones cuya subida de `updated_at` no se observó |
| Reconciliación diaria | Barrido de artículos con `sin_estado` o `fallido` |

**Riesgo residual:** si la confirmación no elevara `updated_at`, el ticket no aparecería en el sondeo. Mitigación: la reconciliación incremental consulta también los tickets con artículos en `sin_estado` cuya antigüedad sea menor a 24 h. Esto acota el problema sin recorrer el histórico.

**Prueba obligatoria antes de la fase 1 (fase 0.6):** provocar un envío, esperar la confirmación y comprobar que `ticket.updated_at` sube.

### 3.7 Por qué un webhook no resuelve esto

**Verificado:** `lib/transaction_dispatcher.rb` 148-150 descarta las actualizaciones de artículo. Un trigger de Zammad nunca vería el cambio de `delivery_status`.

**Conclusión:** el sondeo no es una preferencia; es la única vía verificada para observar la confirmación. Los webhooks, si algún día se usan, solo acelerarían eventos de ticket, nunca de entrega.

### 3.8 Efecto secundario del fallo definitivo: reapertura del ticket

**VERIFICADO (código).** `app/jobs/ticket_article_communicate_email_job.rb` 154-190: cuando `delivery_retry > 3`, Zammad:

1. crea una **nota interna** de tipo `note` con el mensaje de error;
2. cambia el estado del ticket al estado `default_follow_up`;
3. vuelve a lanzar el error.

**Consecuencia para el motor SLA:** un fallo de envío puede **reabrir** el ticket. Ese cambio de estado es un hecho real y debe procesarse como tal:

| Situación | Tratamiento correcto |
|---|---|
| Ticket abierto, falla el envío, Zammad lo deja en `default_follow_up` | No hay cierre, no hay ciclo nuevo; solo un evento de estado |
| Ticket cerrado, falla un envío posterior, Zammad lo reabre | Se registra `ticket.reopened` y, si REA-02 se aprueba, se abre ciclo N+1 |
| La nota interna de error | **No cuenta** como primera respuesta (`internal = true`) |

**Advertencia:** este comportamiento es de Zammad y **no se modifica**. El motor debe estar preparado para reaperturas originadas por fallos técnicos, no solo por el cliente. Es una razón adicional para no dar por cerrado un ciclo sin reconciliación.

---

## 4. Sondeo

### 4.1 Cadencia propuesta

| Ámbito | Cadencia | Justificación |
|---|---|---|
| Tickets abiertos del grupo de soporte | **5 minutos** | Suficiente para 24 h de primera respuesta y 24–120 h de resolución |
| Banda reforzada: tickets con primera respuesta pendiente y vencimiento a menos de 4 h | **2 minutos** | Reduce la latencia de alerta en la ventana crítica |
| Reconciliación incremental | 15 minutos | Corrige pérdidas del sondeo |
| Reconciliación completa | Diaria | Cierra huecos de modificaciones tardías |

### 4.2 Por qué ya no se justifica 1 minuto

**Argumento decisivo:** el motor **no mide con la hora de detección**. Mide con marcas de tiempo de Zammad:

| Métrica | Marca usada | Origen |
|---|---|---|
| Inicio | `created_at` del ticket | Zammad |
| Primera respuesta | `delivery_status_date` del artículo | Zammad |
| Resolución | `close_at` o la transición de historial | Zammad |

Por tanto, la cadencia **no altera el valor medido**. Solo altera:

1. cuánto tarda el motor en enterarse;
2. cuándo se disparan las alertas;
3. cuánto tarda en detectarse un cierre.

Con una meta de 24 h, una latencia de detección de 5 minutos representa el **0,35 %** del plazo, y de 1 minuto el 0,07 %. La diferencia no cambia ninguna decisión operativa. En cambio, multiplicar por 5 las llamadas a la API sí aumenta el riesgo de errores de paginación y de carga.

**Conclusión:** se **reemplazan** CAP-02 (1 min) y CAP-03 (5 min) por una cadencia única de 5 minutos con banda de 2 minutos.

### 4.3 Consulta incremental

```
desde = watermark - 15 min
tickets = /tickets/search (updated_at >= desde, orden updated_at asc, id asc, 200/página)
para cada ticket:
    artículos = /ticket_articles/by_ticket/{id}
    si close_at, last_close_at o state_id cambiaron respecto de lo guardado:
        historial = /ticket_history/{id}
    persistir hechos (idempotente)
watermark = max(updated_at) si el ciclo terminó bien
```

**Uso de `close_at`:** verificado en `app/models/ticket/sets_close_time.rb` 14-32:

- `close_at` se fija en el **primer** cierre y **no se reescribe**;
- `last_close_at` se actualiza en cada transición estando cerrado.

Esto da dos señales nativas y baratas: `close_at` sirve para el ciclo 1, `last_close_at` para detectar actividad de cierre posterior. Es exactamente lo que el diseño necesita y evita depender del historial en el caso normal.

### 4.4 Límites conocidos

| Límite | Estado |
|---|---|
| Máximo 200 por página en búsqueda | VERIFICADO (código) |
| Paginación por desplazamiento | VERIFICADO; riesgo de salto con cambios concurrentes |
| Límite de tasa de la API | No encontrado en el código; **PENDIENTE** en infraestructura |
| Filtro por fecha en artículos | No existe; se consulta por ticket |
| Tamaño de respuesta de artículos | **PENDIENTE** de medir |

---

## 5. Catálogo de eventos (solo Email)

Se reduce el contrato de 5G.4.2. Se eliminan los eventos de entrega de WhatsApp.

| Evento | Obligatorio | Origen |
|---|---|---|
| `ticket.created` | Sí | Sondeo |
| `ticket.classified` | Sí | Sondeo (cambio de categoría o subcategoría) |
| `ticket.state_changed` | Sí | Sondeo |
| `ticket.closed` | Sí | Sondeo o historial |
| `ticket.reopened` | Sí | Sondeo o historial |
| `article.created` | Sí | Sondeo |
| `article.delivery_confirmed` | Sí | Sondeo (`delivery_status = success`) |
| `article.delivery_failed` | Sí | Sondeo (`fail` con reintentos agotados) |
| `commitment.assigned` | Sí | Motor |
| `cycle.opened` | Sí | Motor |
| `cycle.closed` | Sí | Motor |
| `ticket.assigned` | No | Sondeo |
| `ticket.priority_changed` | No | Sondeo |
| `article.delivery_retry_pending` | No | Sondeo (`fail` con reintentos disponibles) |

**Eliminados del alcance:** `article.delivery_delivered`, `article.delivery_read`, y cualquier evento con `channel = whatsapp`.

**Envoltorio del evento:** se mantiene el de 5G.4.2 (`event_id`, `event_type`, `event_version`, `ticket_id`, `occurred_at`, `source`, `payload`), con `source ∈ {poll, reconcile, manual}`. Se elimina `webhook` de los valores previstos para la fase 1.

---

## 6. Procesamiento e idempotencia

Sin cambios respecto de 5G.4.3, con dos precisiones:

1. **Clave de idempotencia:** `sha256('zammad' | event_type | ticket_id | entity_id | occurred_at_utc)`.
2. **Transacción única:** inserción del evento y aplicación de la transición en la misma transacción.
3. **Precisión nueva:** `article.delivery_failed` solo se emite cuando `delivery_retry > 3`. Antes de eso se emite `article.delivery_retry_pending`, que no cierra la primera respuesta.
4. **Precisión nueva:** el motor nunca usa `first_response_at` de Zammad.

---

## 7. Modelo de datos: revisión de las 9 tablas

**Decisión: se mantienen las 9 tablas.** No se reduce el número porque cada una cubre una necesidad distinta y ninguna queda vacía en el alcance Email. Lo que cambia es el contenido de tres de ellas.

| Tabla | ¿Sigue siendo necesaria? | Justificación | Cambios |
|---|---|---|---|
| `sla_policy_version` | **Sí** | Las 27 políticas Email necesitan versión, vigencia y auditoría | `channel` se restringe a `email`; nada más |
| `sla_commitment` | **Sí** | Snapshot inmutable por ticket; sin él no hay congelamiento | `channel` queda fijo en `email` |
| `sla_cycle` | **Sí** | Ciclos y reaperturas; el ciclo 1 es la métrica oficial | Sin cambios |
| `sla_event` | **Sí** | Idempotencia y trazabilidad de hechos | Catálogo reducido a 11 tipos obligatorios |
| `sla_article_delivery` | **Sí** | Estado actual de entrega por artículo; evita recorrer eventos para saber qué falta confirmar | Se eliminan 3 columnas; dominio reducido a 3 estados |
| `sla_alert` | **Sí** | Registrar qué alerta se envió y cuándo; evita duplicados | Sin cambios |
| `sla_audit` | **Sí** | Cambios administrativos con motivo; exigido por CON-04 | Sin cambios |
| `sla_divergence` | **Sí** | Detectar y resolver inconsistencias | Se ajustan los tipos |
| `sla_sync_run` | **Sí** | Marca de agua y evidencia de cada ciclo | Sin cambios |

### 7.1 Columnas que se eliminan

| Tabla | Columna | Motivo |
|---|---|---|
| `sla_article_delivery` | `delivered_at` | Solo lo producía WhatsApp (`timestamp_delivered`) |
| `sla_article_delivery` | `read_at` | Solo lo producía WhatsApp (`timestamp_read`) |
| `sla_article_delivery` | `external_message_id` | Identificador del proveedor de mensajería; el correo usa `message_id` interno, que no aporta al SLA |

### 7.2 Dominios que se reducen

| Tabla | Columna | Antes | Ahora |
|---|---|---|---|
| `sla_policy_version` | `channel` | `whatsapp` / `correo` | `email` (CHECK) |
| `sla_commitment` | `channel` | `whatsapp` / `correo` | `email` (CHECK) |
| `sla_article_delivery` | `delivery_state` | `sin_estado`, `aceptado`, `fallido`, `entregado`, `leido` | `sin_estado`, `aceptado`, `fallido` |
| `sla_divergence` | `kind` | 6 tipos | `missing_close`, `missing_reopen`, `policy_mismatch`, `orphan_ticket`, `delivery_unresolved`, `late_classification` |

### 7.3 Por qué no se fusiona ni se elimina nada más

| Alternativa | Por qué se descarta |
|---|---|
| Fusionar `sla_article_delivery` dentro de `sla_event` | Los eventos son inmutables y crecen; consultar "qué artículos siguen sin confirmar" exigiría recorrer todo el historial. La proyección actual es un índice parcial barato |
| Eliminar `sla_divergence` y solo registrar en logs | Se pierde la bandeja de pendientes y la trazabilidad de la resolución |
| Eliminar `sla_sync_run` | Sin marca de agua no hay recuperación segura tras una caída |
| Fusionar `sla_policy_version` con `sla_commitment` | El compromiso debe sobrevivir a cambios de política; son ciclos de vida distintos |
| Eliminar `sla_alert` | Se perdería el control de duplicados de alerta |

### 7.4 Índices que se mantienen

| Consulta | Índice |
|---|---|
| Política aplicable | `(channel, category, subcategory) WHERE status='active'` |
| Primera respuesta pendiente | `(first_response_due_at) WHERE first_response_at IS NULL` |
| Resolución vencida | `(resolution_due_at) WHERE assignment_status='assigned'` |
| Eventos pendientes | `(status, received_at) WHERE status='pending'` |
| Ciclo abierto | `(commitment_id) WHERE outcome='open'` |
| Artículos sin confirmar | `(delivery_state) WHERE delivery_state IN ('sin_estado','fallido')` |

---

## 8. Cálculo

### 8.1 Compromiso

| Campo | Regla |
|---|---|
| `started_at` | `created_at` del ticket |
| `first_response_due_at` | `started_at + 1.440 min` (24 h) |
| `resolution_due_at` | `started_at + resolution_minutes` de la política Email |
| `resolution_minutes` | Escalón de la matriz oficial (1.440 a 7.200) |
| `provisional` | `true` solo para `99-FALLBACK` |

### 8.2 Primera respuesta

```
si existe artículo público de agente con delivery_status = success
   y delivery_status_date <= first_response_due_at
      → met
   si no
      → missed
si no existe todavía
   → pending
```

### 8.3 Resolución

```
cierre = primer estado de tipo 'closed'
met    = close_at <= resolution_due_at
missed = close_at >  resolution_due_at
```

`pending close` no detiene el reloj. `merged` no es `closed`: no cierra el ciclo y genera divergencia `orphan_ticket` (decisión pendiente DP-E-05).

---

## 9. Alertas

| Umbral | Primera respuesta 24 h | Resolución 24 h | Resolución 120 h |
|---|---:|---:|---:|
| 75 % | 18 h | 18 h | 90 h |
| 90 % | 21,6 h | 21,6 h | 108 h |

Una alerta por compromiso, ciclo, métrica y umbral. La genera el motor; no depende del worker de Zammad.

---

## 10. Reconciliación

| Tipo | Frecuencia | Alcance |
|---|---|---|
| Incremental | 15 min | `updated_at >= watermark - 15 min` |
| Diaria | 1 vez al día | Abiertos + cerrados de los últimos 90 días + artículos `sin_estado`/`fallido` de las últimas 24 h |

**Regla:** la reconciliación nunca modifica `started_at`, `due_at` ni `policy_key`. Solo agrega hechos o registra divergencias.

---

## 11. Carga estimada (solo Email)

**ESTIMACIÓN.** No medida en esta instalación, que tiene 2 tickets.

### 11.1 Supuestos

| Supuesto | Valor | Origen |
|---|---|---|
| Tickets Email activos | 100 / 1.000 / 10.000 | Escenarios solicitados |
| Modificados por ciclo de 5 min | 2 % / 5 % / 10 % | Supuesto; el correo tiene menos actividad que la mensajería |
| Tickets modificados con artículos nuevos | 100 % | Conservador |
| Tickets modificados con cambio de estado | 30 % | Supuesto |
| Páginas por ciclo | `ceil(modificados / 200) + 1` | Derivado del límite verificado |

### 11.2 Peticiones por ciclo de 5 minutos

| Tickets activos | Modificados | Páginas | Artículos | Historial | Total | Por minuto |
|---|---:|---:|---:|---:|---:|---:|
| 100 (2 %) | 2 | 2 | 2 | 1 | ≈ 5 | ≈ 1 |
| 1.000 (5 %) | 50 | 2 | 50 | 15 | ≈ 67 | ≈ 13 |
| 10.000 (10 %) | 1.000 | 6 | 1.000 | 300 | ≈ 1.306 | ≈ 261 |

### 11.3 Lectura

- Hasta 1.000 tickets Email activos, la carga es **muy baja** (≈ 13 peticiones por minuto).
- A 10.000 activos con 10 % de modificación por ciclo, son ≈ 4,4 peticiones por segundo. No está probado en esta instalación, pero es un orden de magnitud manejable.
- Con cadencia de 1 minuto, las mismas cifras se multiplicarían por 5. Esa es la razón principal para no usarla.
- El cuello de botella sigue siendo el número de artículos consultados.

### 11.4 Reducciones disponibles

| Medida | Efecto |
|---|---|
| Consultar artículos solo si cambió el último `article.id` o `updated_at` | Reduce el bloque de artículos |
| Banda de 2 min solo para vencimientos próximos | Mantiene la alerta fina sin carga global |
| Historial solo ante cambio de `close_at`, `last_close_at` o `state_id` | Ya incluido |

---

## 12. Componentes de WhatsApp que salen del diseño

| Componente | Estado |
|---|---|
| Adaptador de proveedor de mensajería | **Eliminado** |
| Webhook de estados (`sent`, `delivered`, `read`) | **Eliminado** |
| Campos `timestamp_delivered`, `timestamp_read` | **Eliminados** |
| Eventos `delivery_delivered`, `delivery_read` | **Eliminados** |
| Meta de primera respuesta 15 min | **Eliminada** |
| Metas de resolución 45 min – 3 h | **Eliminadas del alcance** |
| Respaldo 90 min | **Eliminado** |
| Tratamiento de teléfono | **Eliminado** |
| Sondeo diferenciado por canal | **Eliminado** |
| Validación de operatividad de WhatsApp | **Eliminada** |

La evidencia histórica de estos componentes se conserva en los documentos de 5G.2 a 5G.4.3, sin editar.

---

## 13. Riesgos

| Riesgo | Nivel | Mitigación |
|---|---|---|
| La confirmación de envío no eleva `updated_at` | **Alto** | Prueba 0.6 antes de la fase 1; barrido acotado de artículos `sin_estado` |
| `delivery_status = success` se interpreta como "entregado" | **Alto** | Documentar que es aceptación de envío |
| `fail` transitorio tratado como definitivo | Medio | Solo se cierra tras `delivery_retry > 3` |
| Cierre y reapertura entre dos sondeos | Medio | `close_at` conserva el primer cierre; historial al cambiar `last_close_at` |
| Volumen fuera de catálogo en Email desconocido | **Alto** | Medir antes de la fase 2; respaldo 36 h marcado `provisional` |
| Las 3 combinaciones sin evidencia quedan sin SLA | Medio | Se excluyen del denominador con motivo explícito |
| Reapertura automática del ticket por fallo de envío | Medio | Se trata como reapertura real; depende de DP-02 |
| Paginación por desplazamiento | Medio | Orden estable, solapamiento y reconciliación |
| Motor nativo reactivado por error | Bajo | Verificación periódica de 0 políticas |

---

## 14. Confirmación

Diseño documental. No se creó ningún servicio, tabla, columna, evento, índice, credencial ni política. No se modificó Zammad.
