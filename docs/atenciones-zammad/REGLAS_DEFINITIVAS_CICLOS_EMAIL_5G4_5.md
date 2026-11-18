# REGLAS DEFINITIVAS DE CICLOS Y ESTADOS — EMAIL — 5G.4.5

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.5
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Estado:** reglas cerradas. **No implementadas.**
**Alcance:** exclusivamente correo electrónico.

---

## 1. Modelo de ciclos

Un ticket puede cerrarse y reabrirse. El motor mide **ciclos**, no una única duración.

```
Ticket
  │
  ├── Ciclo 1: created_at ──────────────► primer cierre
  │              (métrica oficial)
  │
  ├── Ciclo 2: reapertura ──────────────► siguiente cierre
  │              (indicador operativo)
  │
  └── Ciclo N: …
```

| Concepto | Regla |
|---|---|
| Métrica oficial de resolución | **Ciclo 1** |
| Ciclos posteriores | Indicador operativo, no entran en el cumplimiento oficial |
| Primera respuesta | Solo se mide en el ciclo 1 |
| Número máximo de ciclos | Sin límite; se registran todos |
| Snapshot del compromiso | Se crea una vez y no cambia |

**Justificación:** el compromiso con el cliente se adquiere al recibir el ticket. Una reapertura es trabajo adicional, no un segundo compromiso con el mismo plazo. Mezclarlos permitiría "arreglar" un incumplimiento reabriendo y cerrando rápido.

---

## 2. Ciclo 1

| Campo | Regla |
|---|---|
| `opened_at` | `created_at` del ticket |
| `due_at` | `opened_at + resolution_minutes` de la política congelada |
| `closed_at` | Primer instante en que el ticket pasa a un estado de tipo `closed` |
| `outcome` | `met` si `closed_at ≤ due_at`; `missed` si es posterior; `open` mientras no cierre |
| Denominador | Sí, si el compromiso está `assigned` |

**Borde del ciclo 1:** inclusivo (`≤`). Cerrar exactamente en el vencimiento **cumple**. Es un escalón redondeado, no una promesa literal.

**Asimetría documentada:** la primera respuesta usa `<` (estricto) porque el alcance lo exige literalmente ("estrictamente menor a 24 horas"); la resolución usa `≤` porque la meta es un escalón de la escalera. La diferencia se registra para que no se interprete como error.

---

## 3. Cierre

### 3.1 Qué cuenta como cierre

Solo el **primer estado de tipo `closed`**. En esta instalación, el estado `closed` tiene ID 4 y tipo `closed`.

| Estado | Tipo | ¿Cierra el ciclo? |
|---|---|---|
| `new` | new | No |
| `open` | open | No |
| `pending reminder` | pending reminder | No |
| `pending close` | pending action | **No** |
| `closed` | closed | **Sí** |
| `merged` | merged | **No** (ver §6) |

**`pending close` no detiene el reloj, no cierra y no pausa.** Es un estado de espera como cualquier otro.

### 3.2 Cómo se obtiene la marca

| Orden | Fuente | Cuándo | Precisión |
|---:|---|---|---|
| 1 | `close_at` del ticket | Ciclo 1, cuando coincide con la primera transición a `closed` | Segundos |
| 2 | `History` (`attribute = 'state_id'`, `value_to` = estado cerrado) | Ciclo N, o cuando `close_at` no es utilizable | Segundos |
| 3 | Primer sondeo que observa el estado cerrado | Solo si no hay historial | Hasta 5 min de error |

**Verificado en código** (`app/models/ticket/sets_close_time.rb` 14-32):

- `close_at` se fija en el **primer** cierre y **nunca se reescribe**;
- `last_close_at` se actualiza en **cada** transición estando cerrado.

Esto significa que Zammad ya conserva la marca del primer cierre. El motor la usa y **no la reconstruye** salvo que falte.

### 3.3 Reconciliación de la marca

En cada reconciliación diaria, el motor compara `close_at` con la primera transición cerrada del historial:

| Caso | Acción |
|---|---|
| Coinciden (± 2 s) | Nada |
| `close_at` es anterior a la transición | Se conserva `close_at` (es la marca nativa y la más temprana) |
| `close_at` es posterior a la transición | Se conserva `close_at`, se registra divergencia `missing_close` y se documenta |
| No hay `close_at` pero hay transición | Se usa la transición y se registra `missing_close` |
| No hay ninguno de los dos | El ciclo queda `open`; se registra `delivery_unresolved` o `missing_close` |

**Regla:** nunca se "corrige" en silencio. Toda diferencia deja divergencia.

---

## 4. Reapertura

### 4.1 Definición

Una reapertura es una transición **desde un estado de tipo `closed` hacia un estado que no es `closed` ni `merged`**.

| Transición | ¿Reapertura? |
|---|---|
| `closed` → `open` | **Sí** |
| `closed` → `new` | **Sí** |
| `closed` → `pending close` | **Sí** |
| `closed` → `pending reminder` | **Sí** |
| `closed` → `closed` (otro estado cerrado) | **No** |
| `closed` → `merged` | **No** (ver §6) |
| `open` → `pending` | **No** |

### 4.2 Efecto

| Elemento | Efecto |
|---|---|
| Ciclo N se cierra | Sí, con su `closed_at` y su `outcome` |
| Ciclo N+1 se abre | Sí, con `opened_at` = instante de la reapertura |
| `due_at` del ciclo N+1 | `opened_at + resolution_minutes` de la **misma** política congelada |
| Compromiso | **No cambia** |
| Política | **No cambia**, aunque la categoría se haya modificado |
| Primera respuesta | **No se recalcula** |
| Métrica oficial | **No cambia**: sigue siendo el ciclo 1 |

**Alternativa A aprobada:** cada reapertura abre un ciclo nuevo con su propio plazo. Se descarta "congelar todo en el ciclo 1" porque un ticket reabierto y sin cerrar quedaría eternamente abierto y sin indicador.

### 4.3 Reaperturas encadenadas

```
C1: 01/06 10:00 → 01/06 12:00   met
C2: 03/06 09:00 → 03/06 18:00   met
C3: 10/06 08:00 → (abierto)     open
```

| Indicador | Valor |
|---|---|
| Cumplimiento oficial | Solo C1 (`met`) |
| Reaperturas | 2 |
| Ciclos abiertos | 1 |
| Indicador operativo | 2 de 3 ciclos cumplidos (66,7 %) |

**Regla:** el indicador de ciclos se publica como **complemento**, nunca como sustituto del oficial.

---

## 5. Reapertura automática por fallo definitivo de envío

**Verificado en código** (`app/jobs/ticket_article_communicate_email_job.rb` 154-190): cuando `delivery_retry > 3`, Zammad:

1. crea una **nota interna** con el mensaje de error;
2. cambia el estado del ticket a `default_follow_up` (estado abierto);
3. vuelve a lanzar el error.

Si el ticket estaba cerrado, esto **lo reabre**.

| Situación | Tratamiento |
|---|---|
| Ticket abierto, falla el envío | Cambio de estado sin cierre; no hay ciclo nuevo |
| Ticket cerrado, falla un envío posterior | **Reapertura real**: cierra C1, abre C2 |
| Nota interna de error | No cuenta como primera respuesta ni como respuesta |
| Artículo fallido | `fallido_definitivo`; no cuenta |

**Regla:** la causa de la reapertura **no se adivina**. El motor registra el hecho (transición de estado) y, si en los 5 minutos previos hay un artículo con `delivery_status = fail` y `delivery_retry > 3`, añade `reopen_hint = delivery_failure` como **anotación**, no como reclasificación.

**Por qué no se excluye la reapertura:** excluirla exigiría determinar la intención del sistema; el hecho objetivo es que el ticket volvió a estar abierto. Se mide como tal y se anota la causa probable para el análisis.

**Riesgo R-03 (medio):** un fallo de correo puede inflar el conteo de reaperturas y, en ciclos N, el indicador operativo. **Mitigación:** el indicador operativo se publica desagregado por `reopen_hint`.

---

## 6. Tickets fusionados (`merged`)

### 6.1 Qué hace Zammad

Fusionar un ticket lo deja en estado `merged` (ID 5, tipo `merged`) y crea un enlace al ticket superviviente. **No es un cierre**: el tipo de estado es `merged`, no `closed`.

**Verificado:** `Ticket::State` tiene `merged` con tipo `merged`; `ticket_closed?` solo considera el tipo `closed` (`sets_close_time.rb` 34-40), por lo que **no fija `close_at`**.

### 6.2 Consecuencia sin regla

Sin una regla explícita, un ticket fusionado quedaría **abierto para siempre** y su ciclo nunca cerraría. Eso contaminaría el denominador con tickets que ya no existen operativamente.

### 6.3 Regla

| Elemento | Regla |
|---|---|
| ¿Cierra el ciclo? | **No** |
| ¿Se mide como incumplimiento? | **No** |
| `outcome` | `excluded` |
| `closed_at` | Instante de la fusión (marca de cierre administrativo del ciclo) |
| `exclusion_reason` | `merged` |
| Divergencia | `merged_ticket` (informativa) |
| Denominador | **Fuera** |

**Justificación:** el trabajo continúa en otro ticket, que tiene su propio compromiso. Contar ambos duplicaría el mismo trabajo; contar solo el fusionado lo haría incumplible.

**Trazabilidad:** se guarda `merged_into_ticket_id` si el enlace está disponible. Si no, se guarda `NULL` y la divergencia lo indica.

---

## 7. Tickets eliminados

| Elemento | Regla |
|---|---|
| Detección | `GET /tickets/{id}` devuelve 404 después de haber existido |
| ¿Cierra el ciclo? | No |
| `outcome` | `excluded` |
| `exclusion_reason` | `ticket_deleted` |
| Divergencia | `orphan_ticket` |
| Datos | **Se conservan** en el motor |
| Denominador | Fuera |

**Regla:** el motor **nunca borra** sus propias filas porque Zammad haya borrado un ticket. El histórico del SLA es evidencia; su borrado destruiría la auditoría.

**Caso especial:** un ticket eliminado **antes** de ser ingerido no existe para el motor; no genera nada.

---

## 8. Tickets sin clasificación

| Situación | `assignment_status` | Denominador |
|---|---|---|
| Sin categoría o sin subcategoría | `pending_classification` | Fuera |
| Con categoría pero fuera de catálogo y sin respaldo aprobado | `no_policy` | Fuera |
| En una de las 3 combinaciones sin evidencia | `no_policy` (motivo `insufficient_evidence`) | Fuera |
| Con categoría y subcategoría mapeadas | `assigned` | **Dentro** |

**Regla de origen de la clasificación:** el motor lee dos campos del ticket (`sla_category`, `sla_subcategory` o los que se definan en la fase 2). Mientras no existan, **todo ticket queda `pending_classification`** y el motor no inventa categorías a partir del texto.

**Prohibición:** el motor no infiere la categoría con un modelo de lenguaje, ni con palabras clave, ni con el asunto. La clasificación es un dato del ticket, auditable y corregible por una persona.

**Consecuencia:** si la organización no clasifica, no hay SLA. Es una decisión de proceso, no un defecto del motor.

---

## 9. Clasificación tardía

### 9.1 Definición

Un ticket está **clasificado tardíamente** cuando recibe categoría y subcategoría **después** de que su plazo de resolución ya venció.

```
classified_at > created_at + resolution_minutes
```

`classified_at` se obtiene, en este orden:

1. la entrada de `History` que deja ambos campos no vacíos por primera vez;
2. si no hay historial, el instante de la primera observación del motor.

### 9.2 Regla

| Elemento | Regla |
|---|---|
| `started_at` | `created_at` (**nunca** la fecha de clasificación) |
| `assigned_at` | Instante real de clasificación |
| `resolution_due_at` | `started_at + resolution_minutes` (puede estar en el pasado al nacer) |
| `outcome` | `met` si hay cierre anterior al vencimiento; si no, `missed_at_birth` |
| Marca | `late_classification = true` |
| Divergencia | `late_classification` |
| Indicador principal | **Fuera** |
| Indicador secundario | **Dentro**, como "cartera clasificada tarde" |

### 9.3 Por qué se excluye del indicador principal

Un ticket creado hace dos meses y clasificado hoy nace incumplido por un problema de proceso, no de atención. Incluirlo haría que el primer mes de operación pareciera un desastre y ocultaría la señal real.

**Contrapeso obligatorio:** el indicador de cartera tardía se publica **al lado** del principal, con su propio denominador y su volumen. No se oculta; se separa.

### 9.4 Fecha de activación

Solo se crean compromisos con `created_at >= activation_at`. Los anteriores quedan `historical`, fuera de todo denominador.

**Sin esta regla, el histórico completo nacería incumplido.**

---

## 10. `pending close`

| Pregunta | Respuesta |
|---|---|
| ¿Detiene el reloj? | **No** |
| ¿Cierra el ciclo? | **No** |
| ¿Pausa el SLA? | **No** |
| ¿Se considera espera del cliente? | **No** |
| ¿Genera alerta? | Sí, si el vencimiento se acerca |

**Motivo:** el calendario es continuo y no hay pausas por estado (decisión de 5G.3, vigente).

**Riesgo operativo R-04 (medio):** un ticket en `pending close` que espera confirmación del cliente puede vencer sin acción del agente. **Mitigación:** alerta al 75 % y al 90 %; el equipo decide si cierra o responde. El motor no decide por él.

---

## 11. Máquina de estados del ciclo

```
                    ┌──────────────┐
   created_at ─────►│   open (C1)  │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌─────────┐      ┌────────────┐     ┌──────────┐
   │  met    │      │   missed   │     │ excluded │
   └─────────┘      └────────────┘     └──────────┘
        ▲                  ▲                  ▲
        │                  │                  │
   cierre ≤ due      cierre > due      merged / deleted

   desde met o missed:
        reapertura ──► abre C(N+1) ──► open
```

| Transición | Disparador | Efecto |
|---|---|---|
| `open` → `met` | Cierre con `closed_at ≤ due_at` | Cierra ciclo; entra al denominador |
| `open` → `missed` | Cierre con `closed_at > due_at`, o vencimiento sin cierre al corte | Cierra ciclo; entra al denominador |
| `open` → `excluded` | `merged` o ticket eliminado | Cierra ciclo; fuera del denominador |
| `met`/`missed` → nuevo ciclo | Reapertura | Abre C(N+1) en `open` |
| `excluded` → nuevo ciclo | No ocurre | Un fusionado o eliminado no reabre |

**Invariante:** como máximo un ciclo `open` por compromiso.

---

## 12. Tiempo y zona horaria

| Elemento | Regla |
|---|---|
| Zona | **UTC** en almacenamiento y cálculo |
| Presentación | Zona de Perú (UTC−5) solo en reportes |
| Precisión | Segundos |
| Horario hábil | No existe |
| Feriados | No existen |
| Pausas | No existen |

**Regla:** ninguna comparación de fechas se hace en hora local. Un cambio de horario estacional (no aplica a Perú, pero sí a otros países del grupo) no puede alterar un vencimiento.

---

## 13. Denominadores oficiales

| Indicador | Numerador | Denominador |
|---|---|---|
| Resolución (oficial) | C1 `met` | C1 `met` + C1 `missed` |
| Primera respuesta | `met` | `met` + `missed` |
| Reaperturas (operativo) | C2..N `met` | C2..N `met` + `missed` |
| Cartera tardía (secundario) | `missed_at_birth` | Todos los `late_classification` |
| Cobertura | Compromisos `assigned` | Tickets Email del período |

**Excluidos de todos:** `no_policy`, `pending_classification`, `historical`, `non_email`, `excluded` por `merged` o `ticket_deleted`, y ciclos `open` que aún no vencieron.

**Regla de cierre de período:** al corte del reporte, un ciclo `open` con `due_at < corte` se cuenta como `missed` **provisorio**, marcado `overdue_at_cutoff`. Se recalcula si el ticket cierra después, pero el reporte ya emitido no se reescribe.

---

## 14. Decisiones cerradas en esta etapa

| ID | Decisión | Estado |
|---|---|---|
| REA-02 / DP-02 | Alternativa A: cada reapertura abre ciclo nuevo | **CERRADA** |
| REA-03 | Histórico por ciclo | **CERRADA** |
| REA-04 | Métrica oficial = ciclo 1 | **CERRADA** |
| REA-05 | Ciclos posteriores = indicador operativo | **CERRADA** |
| REA-06 | Primera respuesta solo en ciclo 1 | **CERRADA** |
| DP-E-05 | `merged` no cierra: se excluye con divergencia | **CERRADA** |
| — | Tickets eliminados: excluidos, datos conservados | **CERRADA** |
| — | `pending close` no pausa | **CERRADA** (ya vigente) |
| — | Clasificación tardía separada del indicador principal | **CERRADA** |

---

## 15. Confirmación

Documento de reglas. No se creó ningún estado, atributo, trigger, webhook ni política. No se modificó Zammad. No se borró ni se alteró ningún dato histórico.
