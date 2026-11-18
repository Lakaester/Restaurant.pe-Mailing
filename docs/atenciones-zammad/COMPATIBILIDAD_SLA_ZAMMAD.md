# COMPATIBILIDAD DE SLA — ZAMMAD 7.2.3

**Proyecto:** MAILING / C.O.S.E. – Restaurant.pe
**Etapa:** 5G.2 — Fase H
**Fecha:** 14/11/2026
**Código inspeccionado:** `/home/acast/mailing` (Zammad 7.2.3, `VERSION` = `7.2.3`)
**Modo:** solo lectura. No se creó, editó ni eliminó ningún SLA, calendario ni configuración.

---

## 1. Modelo de datos del SLA

Tabla `slas` (definición real en `db/schema.rb`):

| Columna | Tipo | Nulo | Significado |
|---|---|---|---|
| `id` | serial | no | — |
| `calendar_id` | integer | **no** | Calendario de tiempo hábil. **Obligatorio** |
| `name` | string(150) | sí (validado) | Único, sin distinguir mayúsculas |
| `first_response_time` | integer | sí | Minutos para primera respuesta |
| `response_time` | integer | sí | Minutos para respuesta al último contacto del cliente |
| `update_time` | integer | sí | Minutos para próxima actualización del agente |
| `solution_time` | integer | sí | Minutos para resolución |
| `condition` | text | sí | Selector de tickets serializado |
| `data` | text | sí | Opciones de UI |
| `created_by_id` / `updated_by_id` | integer | no | — |

Unidades: **minutos enteros**. No hay campo de segundos ni de horas.

Validaciones del modelo (`app/models/sla.rb`):

- `name` presente y único (case-insensitive).
- **`cannot_have_response_and_update`**: no se puede definir `response_time` y `update_time` a la vez.
- `condition` validada con `Selector::Sql` (`ChecksConditionValidation`).

---

## 2. Semántica real de cada tiempo

Verificada en `lib/escalation.rb`:

| Campo Zammad | Se calcula desde | Se escribe en | Métrica operativa |
|---|---|---|---|
| `first_response_time` | `ticket.created_at` | `first_response_escalation_at` | **Primera respuesta** |
| `solution_time` | `ticket.created_at` | `close_escalation_at` | **Resolución** |
| `response_time` | `ticket.last_contact_customer_at` | `update_escalation_at` | Respuesta al último mensaje del cliente |
| `update_time` | `ticket.last_contact_agent_at` (o `created_at`) | `update_escalation_at` | Cadencia de actualización del agente |

Código relevante:

```ruby
# lib/escalation.rb
first_response_escalation_at: calculate_time(ticket.created_at, sla.first_response_time)
close_escalation_at:          calculate_time(ticket.created_at, sla.solution_time)

def calculate_time(start_time, span)
  return if span.nil? || !span.positive?
  Escalation::DestinationTime.new(start_time, span, biz).destination_time
end

def biz
  @biz ||= calendar&.biz breaks: biz_breaks
end
```

`biz` es el calendario de horas hábiles del SLA. **Todo SLA se mide en tiempo hábil según su calendario**, no en tiempo calendario.

Para este proyecto solo se usarían `first_response_time` y `solution_time`. `response_time` y `update_time` deben quedar vacíos para no interferir.

---

## 3. Respuestas a las diez preguntas de la Fase H

### 3.1 ¿Las políticas SLA pueden filtrar por canal?

**Sí.** `condition` es un selector de tickets evaluado con `Ticket.selector2sql`. Permite condiciones sobre cualquier atributo del ticket, incluidos los de canal (`channel`, `group`, `sender`, etc.).

```ruby
def condition_matches?(ticket)
  query_condition, bind_condition, tables = Ticket.selector2sql(condition)
  Ticket.where(query_condition, *bind_condition).joins(tables).exists?(ticket.id)
end
```

### 3.2 ¿Pueden filtrar por categoría y subcategoría?

**Parcialmente.** No existe un atributo nativo de categoría. La clasificación vive en el atributo personalizado `categoria_subcategoria` (`tree_select`), que almacena el path `CATEGORÍA::subcategoría`. Como el selector opera sobre atributos de objeto, **puede filtrarse por ese campo**, pero:

- No hay dos campos separados: no se puede filtrar "categoría = X" sin arrastrar la subcategoría del path.
- El operador disponible para `tree_select` (igualdad, contiene, comienza con) debe validarse antes de generar condiciones masivas.

### 3.3 ¿El atributo `categoria_subcategoria` puede usarse como condición?

**Sí, con reservas.** Es un atributo de ObjectManager y los selectores soportan atributos de objeto. La reserva es el formato del path y el operador. **No validado en esta etapa** (implicaría escribir/ejecutar contra la instancia; queda como validación previa a la implementación).

### 3.4 ¿Cómo se asocia el calendario ID 2?

`slas.calendar_id` es **NOT NULL**. Cada política se vincula a un calendario concreto mediante `belongs_to :calendar`. El calendario ID 2 (`Soporte Especializado`) se asigna indicando `calendar_id = 2` en cada política. No hay herencia ni calendario por defecto para SLA: si no se indica, la política no se puede crear.

> El calendario ID 2 se toma como dato del alcance aprobado. **No se re-verificó ni se modificó** en esta etapa.

### 3.5 ¿Cómo se aplican primera respuesta y resolución?

Ambas se calculan desde `ticket.created_at` con el calendario del SLA. La primera respuesta se considera cumplida cuando `ticket.first_response_at` tiene valor; la resolución, cuando `ticket.close_at` tiene valor.

### 3.6 ¿Cómo se manejan las pausas?

Las pausas se derivan del **historial de estados** del ticket. Todo estado con `ignore_escalation = true` genera un "break" que se excluye del tiempo hábil:

```ruby
# lib/escalation/ticket_biz_break.rb
def range_on_break?(from, _to)
  ignored_escalation_state_names.include? from['value_to']
end
```

Y en `lib/escalation.rb`:

```ruby
def escalation_disabled?
  Ticket::State.lookup(id: ticket.state_id).ignore_escalation?
end
```

Consecuencias:

- Una pausa **no se configura en el SLA**, se configura en el estado.
- Los estados con `ignore_escalation` deben definirse en `DECISIONES_PENDIENTES_SLA.md` (D-08).
- Los tiempos históricos de COSE **no distinguen pausas**: no hay marcas de estado en la vista.

### 3.7 ¿Qué sucede si cambia la categoría de un ticket?

El escalamiento se recalcula en **cada guardado** del ticket:

```ruby
# app/models/ticket/escalation.rb
included do
  after_commit :update_escalation_information
end
```

Por tanto, al cambiar `categoria_subcategoria`, `Sla.for_ticket` se vuelve a evaluar y el ticket puede pasar a otra política.

**Riesgo documentado en el propio código** (`lib/escalation.rb`):

> "ATTENTION: Recalculation after SLA change won't happen. SLA change will cause wrong statistics in some edge cases."

Es decir: las **estadísticas** (`first_response_in_min`, `update_in_min`) no se recalculan retroactivamente, aunque el escalamiento sí. Un ticket reclasificado puede tener escalamiento correcto y estadística antigua.

### 3.8 ¿Cómo se resuelven políticas superpuestas?

**Por orden alfabético del nombre, no por especificidad.**

```ruby
def self.for_ticket(ticket)
  fallback = nil
  all.reorder(:name, :created_at).as_batches(size: 10) do |record|
    if record.condition.present?
      return record if record.condition_matches?(ticket)
    else
      fallback = record
    end
  end
  fallback
end
```

Reglas reales:

1. Se recorre **todo** el conjunto ordenado por `name` (alfabético) y luego `created_at`.
2. Gana **la primera** política cuya condición coincida.
3. Las políticas **sin condición** no compiten: la última encontrada queda como `fallback`.
4. Si ninguna condición coincide, se aplica el `fallback`.

**Consecuencia crítica:** una política llamada `"A - WhatsApp"` gana siempre a `"SLA WhatsApp Facturación"`, aunque la segunda sea más específica. **El nombre es el mecanismo de precedencia.** Se requiere una convención numérica explícita.

### 3.9 ¿Qué limitaciones tiene la API para crear y editar SLA?

Endpoints (controlador `app/controllers/slas_controller.rb`, rutas `/api/v1/slas`):

| Método | Ruta | Acción |
|---|---|---|
| GET | `/api/v1/slas.json` | Listar |
| GET | `/api/v1/slas/:id.json` | Detalle |
| POST | `/api/v1/slas.json` | Crear |
| PUT | `/api/v1/slas/:id.json` | Actualizar |
| DELETE | `/api/v1/slas/:id.json` | Eliminar |

Limitaciones observadas:

- Requiere autenticación y permiso `admin.sla`.
- `calendar_id` obligatorio: no se puede crear una política "sin calendario".
- `name` único case-insensitive: renombrar puede colisionar.
- `condition` debe ser un selector válido; se valida con `User.find(1)` como contexto, lo que puede fallar si depende de permisos de otro usuario.
- No hay endpoint específico de "validar condición" ni de simulación: hay que crear y observar.
- Cambiar una política dispara `TicketEscalationRebuildJob` (recálculo masivo de escalamientos).
- No hay `PATCH` parcial documentado; se usa `PUT`.

### 3.10 ¿Es viable administrar SLA desde una interfaz propia?

**Sí, con matices.** La API cubre el CRUD completo. Un administrador propio podría:

- Generar políticas a partir de la matriz estadística.
- Validar nombres y condiciones antes de enviar.
- Versionar la matriz y comparar con lo publicado.

Lo que **no** puede hacer sin acceso adicional:

- Simular el resultado de una condición sobre tickets reales.
- Forzar el recálculo de estadísticas históricas.
- Evitar el orden alfabético como regla de precedencia.

---

## 4. Restricción estructural: un solo SLA por ticket

`Escalation#sla` es **una sola política** (`@sla ||= Sla.for_ticket(ticket)`), y de ella salen **todos** los tiempos:

```ruby
first_response_escalation_at: calculate_time(ticket.created_at, sla.first_response_time)
close_escalation_at:          calculate_time(ticket.created_at, sla.solution_time)
```

**Implicación de diseño decisiva:** no se puede tener "una política de primera respuesta por canal" y "otra de resolución por categoría". El ticket recibe **una** política y esa política debe contener **ambas metas**.

Por tanto, cada política de resolución debe llevar también `first_response_time`:

| Canal | `first_response_time` en **todas** sus políticas |
|---|---:|
| WhatsApp | 15 min |
| Correo | 1.440 min |

Esto obliga a que las metas de primera respuesta se repliquen en cada registro, no a que exista una política separada.

---

## 5. Calendario y tiempo hábil

### 5.1 Diferencia entre tiempo calendario y tiempo hábil

El calendario ID 2 cubre:

- Lunes a viernes: 09:00–23:00 → 14 h/día × 5 = 70 h
- Sábados y domingos: 09:00–20:00 → 11 h/día × 2 = 22 h
- **Total semanal: 92 h de 168 h = 54,8 %**

Un SLA expresado en horas hábiles es **~1,83 veces más laxo** en tiempo de reloj que el mismo número en horas calendario (168 / 92 = 1,826).

### 5.2 Qué miden los datos históricos

Los tiempos de `v_unificado_norm` son **tiempo calendario**:

- Se calculan como diferencia entre marcas de tiempo, sin calendario.
- No hay marcas de pausa ni de estado.
- No hay `closed_at`, solo duración.

**No es posible convertir esos valores a tiempo hábil con la evidencia disponible.** No se puede saber cuánto del tiempo transcurrió dentro o fuera de horario, ni cuánto estuvo el ticket en pausa.

### 5.3 Efecto sobre la propuesta

Las metas de `MATRIZ_PROPUESTA_SLA_RESOLUCION.md` están en **minutos calendario**. Si se configuran tal cual en Zammad con el calendario 2, se vuelven ~1,83× más holgadas en tiempo de reloj.

Ejemplo: WhatsApp, SLA propuesto 90 min calendario.

| Configuración | Tiempo de reloj efectivo |
|---|---|
| Sin horas hábiles (24/7) | 90 min |
| Con calendario 2 (92 h/semana) | ~164 min en promedio |

Este desajuste es una **decisión pendiente obligatoria** (D-03). Opciones:

| Opción | Descripción | Efecto |
|---|---|---|
| A | Configurar con calendario 2 usando los valores calendario | Meta ~1,83× más laxa |
| B | Escalar los valores por 92/168 antes de configurar | Mantiene la exigencia histórica |
| C | Usar un calendario 24/7 para SLA | Mantiene la exigencia, pero ignora el horario real |
| D | Recalcular los P75 en tiempo hábil | Requiere datos que hoy no existen |

**No se modificó el calendario ni se crearon feriados.**

### 5.4 Feriados

El calendario no tiene feriados definidos. Mientras no los tenga, los días feriados cuentan como hábiles y **alargarán artificialmente** los tiempos medidos en horas hábiles.

---

## 6. Arquitectura propuesta (sin implementar)

### 6.1 Opciones evaluadas

| Opción | Descripción | Ventajas | Riesgos |
|---|---|---|---|
| **A. SLA nativo por política** | 65 políticas, una por subcategoría | Máxima fidelidad a la matriz | Precedencia alfabética frágil; 65 registros a mano; recálculo masivo en cada cambio |
| **B. Conjunto por canal/categoría** | 19 políticas (2 canales + 17 categorías) | Mantenible; cubre el 68,9 % | Pierde la diferenciación fina dentro de categoría |
| **C. Administrador propio vía API** | Interfaz que genera y publica políticas | Versionado, validación, repetible | Requiere desarrollo y pruebas; no elimina la precedencia alfabética |
| **D. Híbrido** | Pocas políticas nativas + generador validado | Equilibrio | Complejidad de gobierno |

### 6.2 Recomendación: híbrido con generación controlada

**Núcleo nativo mínimo (3 políticas):**

| Nombre | Condición | `first_response_time` | `solution_time` |
|---|---|---:|---:|
| `00 - WhatsApp` | canal = WhatsApp | 15 | 90 |
| `01 - Correo` | canal = correo | 1.440 | 2.160 |
| `99 - Respaldo` | sin condición | — | — |

**Capa de excepciones generada (solo donde la evidencia lo justifique):**

- Prefijo numérico que garantice precedencia: `10 - WA - ...`, `20 - MAIL - ...`.
- Solo para combinaciones con **n ≥ 30** y diferencia material frente al respaldo del canal.
- `first_response_time` replicado del canal.

**Por qué no 65 políticas:** con los datos actuales, 37 de 39 combinaciones de WhatsApp caen en 1 h / 1 h 30 min / 2 h. Crear 65 políticas para reproducir tres valores añade riesgo operativo sin beneficio medible.

**Gobierno:**

1. La matriz estadística es la fuente de verdad; las políticas se generan desde ella.
2. Convención de nombres obligatoria (el nombre define la precedencia).
3. Una sola política sin condición (el `fallback`).
4. Validación previa: nombre único, `calendar_id = 2`, condición válida, `first_response_time` coherente con el canal.
5. Registro de cambios con fecha y versión de la matriz.

### 6.3 Lo que la arquitectura debe evitar

- Nombres sin prefijo numérico.
- Más de una política sin condición.
- Mezclar `response_time` y `update_time`.
- Políticas con `solution_time` pero sin `first_response_time` (dejaría la primera respuesta sin meta).
- Publicar metas de combinaciones con n < 10.

---

## 7. Resumen de compatibilidad

| Requisito del negocio | ¿Soportado nativamente? | Observación |
|---|---|---|
| SLA de primera respuesta por canal | **Sí** | Condición por canal; replicar en cada política |
| SLA de resolución por categoría | **Sí** | Vía `categoria_subcategoria` (operador por validar) |
| SLA de resolución por subcategoría | **Sí, con reservas** | 65 condiciones; precedencia por nombre |
| Calendario ID 2 | **Sí** | `calendar_id` obligatorio |
| Pausas | **Sí** | Vía estados con `ignore_escalation` |
| Cambio de categoría recalcula SLA | **Sí** | `after_commit` en cada guardado |
| Estadísticas recalculadas al cambiar SLA | **No** | Limitación documentada en el código |
| Superposición de políticas | **Sí, por nombre** | No por especificidad |
| CRUD por API | **Sí** | `/api/v1/slas` |
| Administrador propio | **Viable** | Sin simulación ni recálculo histórico |

---

## 8. Confirmación

- No se creó ningún SLA.
- No se editó ni eliminó ningún SLA existente (la instancia tiene **0 SLA**).
- No se modificó el calendario ID 2 ni se crearon feriados.
- No se modificó código de Zammad.
- No se activaron workers ni jobs.
- No se conectó ningún buzón.
- No se ejecutaron migraciones.
