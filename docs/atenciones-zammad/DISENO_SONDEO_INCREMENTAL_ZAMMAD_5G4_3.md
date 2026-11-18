# DISEÑO DE SONDEO INCREMENTAL CONTRA ZAMMAD — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Modo:** investigación de solo lectura. **No se realizó ninguna llamada a la API.**

---

## 1. Convención de marcas

| Marca | Significado |
|---|---|
| **VERIFICADO (código)** | Leído en el código instalado |
| **VERIFICADO (datos)** | Observado en la base de la instalación |
| **INFERIDO** | Deducido del código, sin prueba de ejecución |
| **ESTIMACIÓN** | Cálculo con supuestos declarados |
| **PENDIENTE** | Requiere prueba controlada |

---

## 2. Capacidades verificadas de la API

### 2.1 Búsqueda de tickets por fecha de modificación

**VERIFICADO (código).**

- Endpoint: `GET|POST /api/v1/tickets/search` (`config/routes/ticket.rb`).
- Acción: `TicketsController#search` → `model_search_render(Ticket, params)` (`app/controllers/tickets_controller.rb` 453-455).
- Parámetros: `condition` (selector), `sort_by`, `order_by`, `limit`, `page`, `per_page` (`app/controllers/application_controller/renders_models.rb` 122-165).
- Filtro por `updated_at`: el selector `ticket.updated_at` con operador `after (absolute)` se traduce a `updated_at >= ?` (`lib/selector/sql.rb` 607-609).
- Orden: se puede fijar con `sort_by=updated_at` y `order_by=asc` (`app/models/concerns/can_search.rb` 55-67).

**Ejemplo de condición (forma conceptual, no ejecutada):**

```json
{
  "condition": {
    "ticket.updated_at": { "operator": "after (absolute)", "value": "2026-11-16T10:00:00Z" },
    "ticket.state_id": { "operator": "is", "value": ["1", "2", "3"] }
  },
  "sort_by": "updated_at",
  "order_by": "asc",
  "limit": 200,
  "page": 1
}
```

Nota: el formato exacto del valor de fecha y de `state_id` debe confirmarse con una llamada real (PENDIENTE).

### 2.2 Paginación

**VERIFICADO (código).**

| Parámetro | Valor | Referencia |
|---|---|---|
| Máximo por página en búsquedas | **200** | `renders_models.rb` 123 (`paginate_with(max: 200, default: 50)`) |
| Por defecto | 50 | idem |
| Mecanismo | `OFFSET` / `LIMIT` | `app/controllers/concerns/can_paginate/pagination.rb` |
| Total | Disponible con `with_total_count` | `renders_models.rb` 143-151 |

**Riesgo verificado:** la paginación es por desplazamiento. Si entre dos páginas se modifican tickets que caen dentro de la ventana, pueden repetirse o saltarse registros. Mitigación en §4.

### 2.3 Artículos

**VERIFICADO (código).**

- `GET /api/v1/ticket_articles/by_ticket/:id` → `TicketArticlesController#index_by_ticket` (`app/controllers/ticket_articles_controller.rb` 36-48).
- Devuelve atributos con `preferences`, que incluyen `delivery_status`, `delivery_status_date`, `delivery_retry` (`app/models/ticket/article/assets.rb` 47; `ticket_articles.preferences`).
- `GET /api/v1/ticket_articles/:id` (`config/routes/ticket.rb`).
- **No hay** filtro por `updated_at` en el endpoint de artículos por ticket (verificado en el controlador: solo `ticket.articles`). Por tanto se consulta por ticket, no globalmente.

**PENDIENTE:** confirmar si `ticket_articles` (índice general) acepta filtro por fecha. Si lo acepta, el coste baja.

### 2.4 Historial

**VERIFICADO (código).** `GET /api/v1/ticket_history/:id` → `render json: ticket.history_get(true)` (`app/controllers/tickets_controller.rb` 317-325). Devuelve `history` y `assets`.

Sin filtro de fecha. Cada llamada devuelve el historial completo del ticket.

### 2.5 Límites de tasa

**VERIFICADO (código).**

- `lib/rack_attack_setup.rb` y `lib/rack_attack_setup/*.rb` solo limitan **formularios** y **endpoints públicos**.
- No se encontró limitación de tasa para `/api/v1/tickets/*` ni `/api/v1/ticket_articles/*` en el código revisado.

**Conclusión:** en el código revisado **no existe límite de tasa para la API**. Esto no garantiza que el despliegue no tenga un proxy o un balanceador con límites: **PENDIENTE** de verificar en la infraestructura real.

No se inventa ningún límite numérico.

### 2.6 Tokens y permisos

**VERIFICADO (código).** `app/controllers/user_access_token_controller.rb` 14-48:

- Un token tiene una lista de permisos, por ejemplo `["cti.agent", "ticket.agent"]`.
- No existe un permiso de solo lectura en la lista de permisos del token.
- Un token con `ticket.agent` puede **modificar** tickets.

**Consecuencia:** la restricción a solo lectura debe obtenerse por el rol y los accesos del usuario al grupo, no por el token.

**INFERIDO:** `TicketPolicy::ReadScope` usa `ACCESS_TYPE = :read` (`app/policies/ticket_policy/read_scope.rb`). Un usuario cuyo rol tenga acceso de lectura al grupo solo debería ver esos tickets para lectura. **PENDIENTE** de prueba con un rol real.

---

## 3. Propagación de cambios de entrega al ticket

**VERIFICADO (código).**

Cadena:

1. El job de correo guarda `delivery_status` en el artículo (`app/jobs/ticket_article_communicate_email_job.rb` 103-108).
2. El guardado del artículo ejecuta `after_commit :ticket_touch` (`app/models/ticket/article.rb` 49, 472-474).
3. `ticket.touch` actualiza `updated_at` del ticket.

**VERIFICADO (datos)** en el ticket 7:

| Registro | `updated_at` |
|---|---|
| Artículo 3 (con `delivery_status_date` 14:32:10.073) | 14:32:10.082 |
| Ticket 7 | 15:29:09.082 (posterior, por otra actividad) |

Conclusión: el artículo se actualizó **en el mismo instante** que se registró la confirmación. Que el `touch` del ticket ocurra en ese mismo instante **no quedó demostrado** por los datos (el ticket cambió después por otra causa). Está soportado por código.

**Consecuencia para el sondeo:** un cambio de `delivery_status` debería **elevar `ticket.updated_at`**, por lo que una búsqueda de tickets modificados detecta la confirmación. **INFERIDO.** Prueba obligatoria antes de depender de ello: PENDIENTE (ver `PLAN_IMPLEMENTACION_MOTOR_SLA_5G4_3.md`, fase 0).

---

## 4. Estrategia de consulta incremental

### 4.1 Marca de agua

- Cada ciclo guarda `watermark = max(updated_at)` de los tickets procesados **con éxito**.
- El siguiente ciclo consulta `updated_at >= watermark - overlap`.
- `overlap` propuesto: **15 minutos** (ver DECISIONES_FUNCIONALES §2 y CONTRATO).
- La marca **no avanza** si el ciclo falla.

### 4.2 Desplazamiento por paginación

Para evitar pérdidas por la paginación por desplazamiento:

1. Ordenar siempre por `updated_at asc`, `id asc`.
2. Leer todas las páginas de la ventana en un solo ciclo.
3. Procesar y persistir cada ticket con idempotencia (ver `ARQUITECTURA_PROCESAMIENTO_EVENTOS_SLA_5G4_3.md`).
4. El solapamiento de 15 min absorbe tickets que cambian durante la lectura.

### 4.3 Modificaciones tardías

Un ticket puede cambiar **después** de haber sido leído (por ejemplo, un correo que se confirma horas después). Ese ticket volverá a aparecer en el sondeo porque su `updated_at` sube. El procesador debe aplicar el hecho sin retroceder el estado (ver §5 del documento de procesamiento).

**Riesgo:** un ticket cuya confirmación llega **después** de la ventana de solapamiento se vuelve a ver solo si otro cambio lo toca. Por eso la reconciliación completa diaria es necesaria.

### 4.4 Procedimiento por ciclo

```
1. desde = watermark - 15 min
2. para page = 1..N:
     tickets = POST /tickets/search (updated_at >= desde, sort updated_at asc, limit 200)
     para cada ticket:
       articulos = GET /ticket_articles/by_ticket/{id}
       si estado o categoría cambiaron respecto al snapshot:
         historial = GET /ticket_history/{id}
       persistir hechos (idempotente)
3. si todo OK: watermark = max(updated_at) de los tickets leídos
4. registrar ciclo en sla_sync_run
```

### 4.5 Qué se evita

| Coste evitado | Cómo |
|---|---|
| Recorrer el histórico completo | Filtro `updated_at >= watermark` |
| Consultar historial de todos los tickets | Historial solo si cambió estado o categoría |
| Releer artículos sin cambios | Comparar último `article.id` y `updated_at` almacenados |

---

## 5. Cálculo de carga

### 5.1 Supuestos (ESTIMACIÓN)

| Supuesto | Valor | Origen |
|---|---|---|
| Tickets activos | 100 / 1.000 / 10.000 | Escenarios solicitados |
| Fracción de tickets activos modificada por minuto | 2 % / 5 % / 15 % | **Supuesto sin medir** |
| Fracción de tickets modificados que cambian estado o categoría | 30 % | **Supuesto sin medir** |
| Páginas de búsqueda por ciclo | `ceil(modificados / 200)` + 1 de solapamiento | Derivado de §2.2 |
| Tamaño por respuesta | **No medido** | PENDIENTE |

Ninguno de los supuestos proviene de datos de producción. La instalación de prueba tiene 2 tickets y 5 artículos, insuficientes para medir.

### 5.2 Peticiones por minuto

Fórmula: `peticiones = páginas + modificados (artículos) + 0,3 × modificados (historial)`.

| Tickets activos | Modificación 2 % | Modificación 5 % | Modificación 15 % |
|---:|---:|---:|---:|
| 100 | ≈ 3 | ≈ 7 | ≈ 20 |
| 1.000 | ≈ 27 | ≈ 66 | ≈ 196 |
| 10.000 | ≈ 262 | ≈ 652 | ≈ 1.960 |

Conversión a peticiones por segundo (cargas de 1 minuto):

| Tickets activos | 2 % | 5 % | 15 % |
|---:|---:|---:|---:|
| 100 | 0,05 | 0,12 | 0,33 |
| 1.000 | 0,45 | 1,10 | 3,27 |
| 10.000 | 4,37 | 10,87 | 32,67 |

### 5.3 Lectura de la tabla

- Con hasta 1.000 tickets activos, la carga es **baja** para cualquier supuesto razonable.
- Con 10.000 activos y modificación alta, la carga supera **30 peticiones por segundo** sostenidas. Ese volumen **no se ha probado** en esta instalación.
- El cuello de botella probable es el número de artículos consultados por ticket modificado, no la búsqueda.

### 5.4 Reducción posible en el escenario alto

| Medida | Efecto estimado |
|---|---|
| Consultar artículos solo si cambió el último `article.id` o su `updated_at` | Reduce artículos consultados al número de tickets con actividad real de artículos |
| Frecuencia de 5 min para tickets sin primera respuesta pendiente | Reduce el ciclo de 1 min al subconjunto crítico (CAP-02) |
| Historial solo cuando cambia estado o categoría | Ya incluido |

**ESTIMACIÓN:** estas medidas pueden reducir la carga en varios órdenes de magnitud en el escenario alto. **No medido.**

---

## 6. Límites y pendientes

| Límite | Estado |
|---|---|
| Límite de tasa de la API | No hay en el código revisado; **PENDIENTE** en infraestructura |
| Tamaño de respuesta de artículos | **PENDIENTE** (puede incluir cuerpos largos) |
| Tiempo de respuesta de la búsqueda con 10.000 tickets | **PENDIENTE** |
| Filtro por fecha en artículos generales | **PENDIENTE** |
| Efecto del `touch` sobre `updated_at` en entrega | INFERIDO; prueba obligatoria |
| Comportamiento de paginación ante cambios concurrentes | Riesgo conocido; mitigado con solapamiento |

---

## 7. Conclusiones

1. El sondeo por `updated_at` es **viable** con los endpoints existentes, sin modificar Zammad.
2. La detección de confirmaciones de envío **depende** de que el `touch` eleve `updated_at`. Está soportado por código y por una observación parcial; debe probarse.
3. La carga es baja hasta 1.000 tickets activos. A 10.000 activos con alta modificación, requiere medición y reducción por artículos.
4. No existe límite de tasa verificado en el código. No se afirma ningún valor numérico.

---

## 8. Confirmación

No se realizaron llamadas a la API. No se creó token ni rol. No se modificó Zammad.
