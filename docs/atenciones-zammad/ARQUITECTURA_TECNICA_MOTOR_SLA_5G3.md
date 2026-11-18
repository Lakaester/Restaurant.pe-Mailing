# ARQUITECTURA TÉCNICA — MOTOR SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño y auditoría. **No implementado.**
**Código verificado:** `/home/acast/mailing` (Zammad 7.2.3).

---

## 1. Resumen

La alternativa recomendada es el **motor nativo de Zammad**, con cuatro ajustes de configuración y una capa de control:

1. Calendario **24/7** para medir tiempo calendario.
2. Estados `pending reminder` y `pending close` con `ignore_escalation = false`.
3. **65 políticas** con nombres prefijados y una política de respaldo.
4. Congelamiento del SLA inicial mediante un atributo de ticket y una regla de asignación.

Ninguno de estos cambios está aplicado. Este documento es diseño.

---

## 2. Modelo nativo verificado

### 2.1 Tabla `slas`

| Columna | Tipo | Nulo | Uso |
|---|---|---|---|
| `id` | serial | no | — |
| `calendar_id` | integer | **no** | Calendario obligatorio |
| `name` | string(150) | validado | Único, case-insensitive |
| `first_response_time` | integer | sí | Minutos |
| `response_time` | integer | sí | Minutos (no se usará) |
| `update_time` | integer | sí | Minutos (no se usará) |
| `solution_time` | integer | sí | Minutos |
| `condition` | text | sí | Selector de tickets |
| `data` | text | sí | Opciones de UI |

**VERIFICADO:** `Sla` incluye `HasAuditLogs`, `ChecksConditionValidation`, `HasEscalationCalculationImpact` y `belongs_to :calendar`.

### 2.2 Cálculo

**VERIFICADO en `lib/escalation.rb`:**

- `first_response_escalation_at = created_at + first_response_time`.
- `close_escalation_at = created_at + solution_time`.
- El cálculo usa `calendar.biz`, es decir, **tiempo hábil del calendario**, no tiempo calendario puro.
- `response_time` y `update_time` no se usarán.

### 2.3 Primera respuesta

**VERIFICADO en `app/models/ticket/article/has_ticket_contact_attributes_impact.rb`:**

`first_response_at` se fija cuando:

- El artículo no es interno.
- El emisor es `Agent`.
- El tipo de artículo es de comunicación.
- `first_response_at` aún está vacío.

Una nota interna no cuenta. La marca se fija una sola vez.

### 2.4 Resolución

**VERIFICADO en `app/models/ticket/sets_close_time.rb`:**

- `close_at` se fija cuando el estado es de tipo `closed`.
- `last_close_at` se actualiza en cada cambio de estado o si está vacío.
- Si el ticket se reabre, `close_at` **no se borra**; se conserva el primer cierre.

### 2.5 Precedencia

**VERIFICADO en `app/models/sla.rb`:**

```ruby
all.reorder(:name, :created_at).as_batches(size: 10)
```

- Gana la primera política cuyo `condition` coincida.
- Las políticas sin condición son `fallback`; solo debe existir una.
- **El nombre define la precedencia**, no la especificidad.

### 2.6 Pausas

**VERIFICADO en `lib/escalation/ticket_biz_break.rb`:**

- Todo estado con `ignore_escalation = true` genera un “break”.
- Los breaks se descuentan del tiempo hábil.
- La pausa se configura en el **estado**, no en el SLA.

**Estado actual verificado en la base:**

| Estado | `ignore_escalation` |
|---|---|
| `new` | false |
| `open` | false |
| `pending reminder` | **true** |
| `closed` | true |
| `merged` | true |
| `pending close` | **true** |

Para cumplir “ningún estado pendiente pausa”, hay que cambiar `pending reminder` y `pending close` a `false`. `closed` y `merged` pueden seguir en `true` porque son terminales.

---

## 3. Calendario 24/7

### 3.1 Requisito

El SLA nativo siempre usa un calendario. Para medir tiempo calendario puro se necesita un calendario:

| Campo | Valor propuesto |
|---|---|
| Nombre | `SLA 24x7` |
| Zona horaria | `America/Lima` |
| Lunes a domingo | 00:00–23:59 |
| Feriados | Ninguno |
| Predeterminado | No |

**PROPUESTA.** No se creó. El calendario `Soporte Especializado` (ID 2) no sirve para este fin porque solo cubre 92 de 168 horas semanales.

### 3.2 Formato

Zammad representa el último minuto del día como `23:59`; `business_hours_to_hash` lo convierte a `24:00` para el cálculo. **VERIFICADO en `app/models/calendar.rb`.**

### 3.3 Validación

Antes de publicar, se debe probar:

1. Un ticket creado a las 22:50 con SLA de 15 min vence a las 23:05, no al día siguiente.
2. Un ticket creado en sábado consume el SLA.
3. Un feriado no altera el vencimiento.

**HIPÓTESIS:** el calendario 24/7 con `23:59` funciona como tiempo calendario. Requiere prueba controlada.

---

## 4. Las 65 políticas

### 4.1 Estructura

Cada política debe contener:

- `first_response_time` del canal.
- `solution_time` de la combinación.
- `calendar_id` del calendario 24/7.
- `condition` que identifique canal + categoría + subcategoría.
- Nombre con prefijo numérico.

### 4.2 Nomenclatura propuesta

```
10-WA-<CAT>-<SUB>
20-MAIL-<CAT>-<SUB>
99-FALLBACK
```

Ejemplos:

```
10-WA-FACTURACION_ELECTRONICA-AJUSTES_FE
20-MAIL-SOFTWARE-ERROR_WEB
99-FALLBACK
```

**PROPUESTA.** El prefijo numérico garantiza el orden alfabético. El nombre debe ser único y estable.

### 4.3 Condición

**HIPÓTESIS:** la condición puede usar `categoria_subcategoria` con el path completo. El operador exacto (`is`, `contains`, `starts with`) debe validarse contra la instancia antes de crear 65 políticas. No se validó en esta etapa.

### 4.4 Política de respaldo

- Una sola política sin condición.
- Nombre `99-FALLBACK`.
- Sin `first_response_time` ni `solution_time` propios, o con los respaldos provisionales.
- Se aplica cuando ninguna condición coincide.

**RIESGO:** si el fallback tiene tiempos, todos los tickets sin categoría reciben un SLA. Si no los tiene, quedan “sin SLA”. La decisión está en `DECISIONES_PENDIENTES_5G3.md`.

---

## 5. Congelamiento del SLA inicial

### 5.1 Problema

**VERIFICADO:** `Ticket::Escalation` se recalcula en cada guardado (`after_commit`). `Sla.for_ticket` evalúa la condición con el estado actual del ticket. Si cambia `categoria_subcategoria`, el SLA puede cambiar y el vencimiento se recalcula.

**VERIFICADO:** el propio código advierte que las estadísticas no se recalculan retroactivamente.

### 5.2 Propuesta

Agregar un atributo de ticket:

```
sla_policy_key (input, oculto o de solo lectura)
```

- Se llena **una sola vez**, en la primera clasificación.
- Contiene la clave de la política asignada (por ejemplo, `20-MAIL-SOFTWARE-ERROR_WEB`).
- Las condiciones de las 65 políticas comparan `sla_policy_key`, no `categoria_subcategoria`.
- Si el ticket se reclasifica, `sla_policy_key` no cambia.
- Se registra la reclasificación en un atributo o historial separado.

**PROPUESTA.** Requiere:

1. Crear el atributo.
2. Crear un trigger o hook que lo llene una sola vez.
3. Ajustar las condiciones de las 65 políticas.
4. Validar que el motor nativo no lo sobrescriba.

**HIPÓTESIS:** un trigger de Zammad puede llenar el atributo en la creación o primera clasificación. No se probó.

### 5.3 Alternativa

Usar `preferences[:sla_snapshot]` con un addon. Mayor control, mayor desarrollo.

---

## 6. Reaperturas

### 6.1 Comportamiento nativo

**VERIFICADO:**

- `close_at` se fija en el primer `closed` y no se borra.
- `last_close_at` se actualiza en cada cambio de estado.
- Al reabrir, el ticket vuelve a `open`; `close_at` conserva el primer cierre.

### 6.2 Propuesta

- Conservar `close_at` como **primer cumplimiento**.
- Registrar `last_close_at` como **último cierre**.
- Agregar un contador de reaperturas (`sla_reopen_count`) y un historial de reaperturas.
- El cumplimiento original no se altera.
- La reapertura se muestra como evento, no como nuevo SLA.

**PROPUESTA.** Requiere atributo y trigger, o un addon.

---

## 7. Auditoría

**VERIFICADO:** `Sla` incluye `HasAuditLogs`.

**PENDIENTE:** confirmar si el audit log guarda valor anterior y nuevo de `first_response_time` y `solution_time`, y si incluye al usuario. Si no, se necesita una tabla o un log propio.

**Propuesta:** tabla `sla_policy_audit` con:

- `sla_id`
- `campo`
- `valor_anterior`
- `valor_nuevo`
- `usuario`
- `fecha`
- `motivo`
- `version_matriz`

---

## 8. Alertas

**VERIFICADO:** Zammad calcula `escalation_at`, `first_response_escalation_at` y `close_escalation_at`, y los muestra en la interfaz.

**HIPÓTESIS:** no se verificó un mecanismo nativo de alertas con umbrales configurables (75 %, 90 %). La alerta proactiva requeriría:

- Un job programado que consulte vencimientos.
- Un canal de notificación.
- Un registro de alertas enviadas.

**PROPUESTA:** job en el BFF o en un addon.

---

## 9. Reportes

**VERIFICADO:** `Report.enabled? = false`.

**PROPUESTA:**

- COSE BI sigue calculando sobre `v_unificado_norm`.
- El BFF expone métricas de SLA desde Zammad.
- Se evita duplicar el motor de reportes en Zammad.

---

## 10. Comparación de alternativas

| Criterio | A. Motor nativo + ajustes | B. Motor propio |
|---|---|---|
| Tiempo calendario | Calendario 24/7 | Por diseño |
| Pausas | Cambiar estados | Control total |
| Precedencia | Alfabética | Definible |
| Congelamiento | Atributo + trigger | Tabla propia |
| Reaperturas | `close_at` nativo | Tabla propia |
| Indicadores en Zammad | Nativos | No |
| Auditoría | `HasAuditLogs` | Propia |
| Alertas | Desarrollo | Desarrollo |
| Reportes | COSE BI | COSE BI |
| Mantenimiento | Bajo | Alto |
| Riesgo | Precedencia y congelamiento | Desalineación |

**Recomendación:** A, con validación técnica de los cuatro puntos críticos: calendario 24/7, condición de `categoria_subcategoria`, congelamiento y auditoría.

---

## 11. Validaciones previas a implementar

| # | Validación | Método | Estado |
|---|---|---|---|
| 1 | Calendario 24/7 mide tiempo calendario | Ticket sintético | **PENDIENTE** |
| 2 | `ignore_escalation=false` no rompe otros flujos | Revisión de código + prueba | **PENDIENTE** |
| 3 | Condición por `categoria_subcategoria` funciona | Ticket sintético | **PENDIENTE** |
| 4 | Precedencia por prefijo | Crear 3 políticas de prueba | **PENDIENTE** |
| 5 | Congelamiento por atributo | Prueba controlada | **PENDIENTE** |
| 6 | `close_at` se conserva al reabrir | Prueba controlada | **PENDIENTE** |
| 7 | Auditoría guarda anterior/nuevo | Revisión de audit log | **PENDIENTE** |

---

## 12. Riesgos técnicos

| Riesgo | Nivel | Mitigación |
|---|---|---|
| El calendario 24/7 no se comporta como tiempo calendario | Alto | Prueba previa |
| Cambiar `ignore_escalation` afecta a tickets en curso | Alto | Ventana de mantenimiento |
| La condición por `categoria_subcategoria` no funciona | Alto | Validar operador |
| El atributo de congelamiento se sobrescribe | Alto | Trigger + prueba |
| La precedencia alfabética falla | Medio | Convención numérica |
| La auditoría no guarda anterior/nuevo | Medio | Tabla propia |
| Los reportes no están activos | Medio | COSE BI/BFF |
| 65 políticas son difíciles de mantener | Medio | Generador desde la matriz |

---

## 13. Confirmación

No se creó ningún calendario, SLA, atributo, trigger, estado ni tabla. Todo es diseño.
