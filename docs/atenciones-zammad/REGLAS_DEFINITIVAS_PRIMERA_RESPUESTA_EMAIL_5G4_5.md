# REGLAS DEFINITIVAS DE PRIMERA RESPUESTA — EMAIL — 5G.4.5

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.5
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Estado:** regla cerrada. **No implementada.**
**Alcance:** exclusivamente correo electrónico.

---

## 1. Definición

| Elemento | Regla |
|---|---|
| Métrica | Primera respuesta pública de un agente, confirmada por envío |
| Inicio | `created_at` del ticket |
| Fin | `delivery_status_date` del primer artículo que cumple todas las condiciones |
| Meta | **estrictamente menos de 24 horas** (86.400 segundos) |
| Calendario | 24/7, sin pausas |
| Diferenciación por categoría | **Prohibida** |
| Unidad de medida | segundos; se reporta en minutos y horas |

**Fórmula:**

```
primera_respuesta_cumplida  ⇔  (fin − inicio) < 86.400 s
```

No existe `≤`. El instante exacto de 24 h **no cumple**. Esta es la decisión **DP-E-04**, cerrada por el alcance de esta etapa ("estrictamente menor a 24 horas").

---

## 2. Condiciones del artículo que cuenta

Un artículo es candidato **solo si cumple las cinco condiciones**:

| # | Condición | Campo de la API | Valor exigido |
|---:|---|---|---|
| 1 | Es público | `internal` | `false` |
| 2 | Lo escribió un agente | `sender` | `Agent` |
| 3 | Es correo | `type` | `email` |
| 4 | El envío fue aceptado | `preferences.delivery_status` | `success` |
| 5 | Es posterior a la creación del ticket | `created_at` | `>= ticket.created_at` |

**Nunca cuentan:**

| Caso | Por qué |
|---|---|
| Nota interna (`internal = true`) | No se envía al cliente |
| Artículo del cliente (`sender = Customer`) | No es respuesta del agente |
| Artículo del sistema (`sender = System`) | No es una respuesta humana |
| Artículo `type = note`, `web`, `phone`, `sms`, `chat`, `fax`, `twitter`, `facebook`, `telegram` | No es correo; fuera del alcance |
| Artículo `delivery_status = fail` | No fue aceptado |
| Artículo `delivery_status` ausente | El envío aún no se confirma |
| Artículo creado antes del ticket (importación) | No es respuesta a este ticket |

---

## 3. Fecha de medición

### 3.1 Fuente primaria

`preferences.delivery_status_date`, escrito por `app/jobs/ticket_article_communicate_email_job.rb` 103-108 en el mismo `save!` que fija `delivery_status = 'success'`.

**Verificado en código:** la fecha se toma con `Time.zone.now` **después** de que el servidor de salida (SMTP o Microsoft Graph) aceptó el mensaje. No es la fecha de creación del artículo.

### 3.2 Orden de fuentes

| Orden | Fuente | Cuándo | Marca de auditoría |
|---:|---|---|---|
| 1 | `delivery_status_date` | Siempre que exista | `source = delivery_status_date` |
| 2 | `updated_at` del artículo | `success` sin `delivery_status_date` (importaciones, datos antiguos) | `source = updated_at_fallback` |
| 3 | ninguna | `success` sin fecha ni `updated_at` utilizable | `source = unavailable` → no cumple todavía |

**Por qué `updated_at` es conservador:** es igual o posterior al momento del `save!` que confirmó el envío. Usarlo nunca acorta el tiempo medido; puede alargarlo. En una métrica de cumplimiento, el error debe ir en contra del cumplimiento, no a favor.

**Regla:** el motor **nunca** usa `created_at` del artículo como fecha de respuesta. Hacerlo reproduciría el defecto de `first_response_at` de Zammad.

### 3.3 Por qué no se usa `first_response_at` de Zammad

**Verificado en 5G.4.2:** `first_response_at` se fija en la **creación** del artículo, no en la confirmación de envío.

Evidencia registrada (ticket 7): `first_response_at` coincide al segundo con el `created_at` del artículo; la confirmación de envío llegó **9 h 34 min** después. Usar `first_response_at` habría declarado cumplida una respuesta que tardó casi diez horas más.

**Regla:** `first_response_at` de Zammad se ignora por completo. El motor calcula su propia marca.

---

## 4. Qué prueba `delivery_status = success`

| Afirmación | ¿La prueba? |
|---|---|
| El agente escribió el artículo | **Sí** |
| Zammad generó el mensaje | **Sí** |
| El servidor de salida (SMTP/Graph) **aceptó** el mensaje | **Sí** |
| El mensaje llegó a la bandeja del destinatario | **No** |
| El destinatario lo leyó | **No** |
| No rebotó después | **No** |

**Regla de comunicación:** en reportes y actas debe decirse **"envío aceptado por el servidor de salida"**, nunca "correo entregado".

**Riesgo asociado R-01 (alto):** un rebote asíncrono posterior no cambia `delivery_status`; el motor seguiría contando la respuesta como cumplida. Es un límite del canal y del registro de Zammad, no del motor. Se documenta y no se corrige con datos que no existen.

---

## 5. Tratamiento de correos fallidos

`delivery_status` tiene tres valores observables: `success`, `fail` y ausente.

| Estado | `delivery_retry` | Condición | Tratamiento |
|---|---:|---|---|
| `success` | cualquiera | — | **Cuenta** como respuesta confirmada |
| `fail` | ≤ 3 | Reintento disponible | **No cuenta**; queda provisional |
| `fail` | > 3 | Fallo definitivo | **No cuenta nunca** |
| ausente | — | Job no terminado | **No cuenta todavía** |

**Verificado en código:**

- cada intento incrementa `delivery_retry` (líneas 34-35);
- el fallo se registra en 142-151;
- con `delivery_retry > 3` se genera una **nota interna** y el ticket pasa a `default_follow_up` (154-190).

**Consecuencias:**

1. Un `fail` con reintentos disponibles **no cierra** la primera respuesta; el motor espera.
2. Un `fail` definitivo **no se convierte** en respuesta. Si el agente reenvía, se crea un **artículo nuevo**, que se evalúa por separado.
3. La nota interna de error **nunca** cuenta: es `internal = true` y `sender = System` o `Agent`.
4. El artículo fallido se conserva en `sla_article_delivery` para auditoría; no se borra.

**Riesgo R-02 (medio):** un fallo transitorio que el motor observe como definitivo antes de que Zammad termine los reintentos. **Mitigación:** el motor solo marca `fallido_definitivo` cuando lee `delivery_retry > 3`; mientras tanto usa `fallido_provisional`.

---

## 6. Respuestas múltiples

| Situación | Regla |
|---|---|
| Varios artículos candidatos | Gana el de **menor `delivery_status_date`** |
| Empate exacto de fecha | Gana el de **menor `article_id`** |
| Un artículo falla y otro posterior tiene éxito | Cuenta el exitoso, con su propia fecha |
| Primer artículo exitoso fuera de plazo, segundo también | Se registra el primero; el resultado es `missed` |
| Artículo exitoso posterior a la meta pero antes del cierre | `missed`; no hay recuperación |
| Se reabre el ticket | La primera respuesta **no se recalcula** (solo se mide en el ciclo 1) |

**Regla:** la primera respuesta es un hecho histórico único. Una vez registrada, **no se modifica** salvo corrección auditada (CON-04).

---

## 7. Respuestas fuera de horario

| Situación | Efecto |
|---|---|
| Respuesta a las 23:59 del día 1 | Igual que a las 00:01 |
| Fin de semana | Sin efecto |
| Feriado | Sin efecto |
| Noche | Sin efecto |
| `pending close` | Sin efecto |

**Motivo:** calendario continuo 24/7 (decisión de 5G.3, vigente). No existe horario hábil, no existe pausa y no existe exclusión de feriados.

**Consecuencia operativa que debe asumirse:** un ticket recibido el viernes a las 23:50 tiene su vencimiento el sábado a las 23:50. El equipo debe cubrir fines de semana o aceptar el incumplimiento.

---

## 8. Casos límite y resolución

| # | Caso | Regla | Resultado |
|---:|---|---|---|
| 1 | Ticket creado por el agente (contacto saliente) y su primer artículo es público, de agente y con éxito | Cuenta; el tiempo es cercano a 0 | `met` |
| 2 | Ticket con primer artículo de cliente y respuesta de agente a las 23 h 59 min 59 s | `< 86.400 s` | `met` |
| 3 | Respuesta exactamente a las 24 h 00 min 00 s | No es estrictamente menor | `missed` |
| 4 | Ticket cerrado sin ninguna respuesta de agente | No hay fin; al vencer se marca | `missed` |
| 5 | Ticket cerrado antes del vencimiento sin respuesta | Igual: no hay respuesta | `missed` |
| 6 | Artículo `success` pero `internal = true` | No cuenta | sigue `pending` |
| 7 | Artículo de agente con `type = note` público | No es correo; no tiene `delivery_status` | no cuenta |
| 8 | Artículo `success` con fecha anterior a `created_at` del ticket | Se descarta por la condición 5 | no cuenta |
| 9 | Ticket sin política (3 combinaciones o fuera de catálogo sin respaldo aprobado) | No hay compromiso | `not_applicable` |
| 10 | Ticket no clasificado | No hay política todavía | `pending_classification` |
| 11 | Ticket creado antes de la fecha de activación del motor | Se marca histórico, sin SLA | `historical` |
| 12 | Ticket de un grupo fuera del alcance | No se ingesta | fuera del universo |
| 13 | Ticket cuyo primer artículo no es de tipo `email` | Fuera del alcance Email | `non_email` (divergencia) |
| 14 | Zammad reabre el ticket por fallo definitivo de envío | No altera la primera respuesta del ciclo 1 | sin cambio |

**Regla del caso 11 (fecha de activación):** solo se crean compromisos para tickets con `created_at >= activation_at` (instante en que el motor empieza a operar). Los tickets anteriores se registran como `historical`, sin vencimientos y fuera del denominador. Sin esta regla, todo el histórico nacería incumplido y la métrica sería inútil desde el día uno.

---

## 9. Algoritmo

```
para cada ticket del alcance con compromiso asignado:
    candidatos = artículos del ticket donde
        internal == false
        AND sender == 'Agent'
        AND type == 'email'
        AND preferences.delivery_status == 'success'
        AND created_at >= ticket.created_at
    si candidatos no está vacío:
        elegido = min(candidatos, clave = (fecha_respuesta, article_id))
        fecha = elegido.delivery_status_date
                o elegido.updated_at  (fallback)
        first_response_at = fecha
        first_response_article_id = elegido.id
        first_response_source = fuente usada
        outcome = (fecha - ticket.created_at) < 86400 s ? 'met' : 'missed'
    si no:
        si now > first_response_due_at:
            outcome = 'missed'      # no llegó a tiempo y ya venció
        si no:
            outcome = 'pending'
```

**Idempotencia:** recalcular el algoritmo sobre el mismo conjunto de artículos produce el mismo resultado. Es seguro repetirlo en cada reconciliación.

**Inmutabilidad:** una vez que `first_response_outcome` pasa de `pending` a `met` o `missed`, no cambia. Si aparece un artículo con fecha anterior (evento fuera de orden), se aplica como corrección auditada, con `sla_audit` y motivo.

---

## 10. Alertas

| Umbral | Instante | Condición |
|---|---:|---|
| 75 % | 18 h (64.800 s) | Sin respuesta confirmada |
| 90 % | 21,6 h (77.760 s) | Sin respuesta confirmada |
| Vencimiento | 24 h (86.400 s) | Sin respuesta confirmada |

Una alerta por compromiso y umbral. Si la respuesta llega antes del umbral, no se emite. Si llega después de emitida, la alerta no se borra (es historia).

**Banda de 2 minutos:** aplica a tickets con primera respuesta pendiente y vencimiento a menos de 4 h. Fuera de esa banda, cadencia de 5 minutos.

---

## 11. Reporte

| Campo | Valor |
|---|---|
| Denominador | compromisos con `assignment_status = 'assigned'` y `first_response_outcome IN ('met','missed')` |
| Numerador | `first_response_outcome = 'met'` |
| Cumplimiento | `met / (met + missed)` |
| Meta global | **≥ 80 %** |
| Desagregación | global y por categoría (nunca por categoría para fijar la meta) |
| Excluidos | `pending`, `not_applicable`, `historical`, `no_policy`, `non_email` |
| Corte | los `pending` con vencimiento anterior al corte cuentan como `missed` provisorio, marcados `overdue_at_cutoff` |

**Regla de transparencia:** el reporte debe publicar, junto al porcentaje, cuántos tickets quedaron fuera del denominador y por qué. Un 95 % sobre 10 tickets no es mejor que un 82 % sobre 1.000.

---

## 12. Decisiones cerradas en esta etapa

| ID | Decisión | Estado |
|---|---|---|
| DP-E-04 | Borde de la meta: estrictamente `< 24 h` | **CERRADA** |
| PR-03 | `delivery_status = success` como único criterio | **CERRADA** |
| DP-E-06 | `fail` definitivo solo con `delivery_retry > 3` | **CERRADA** |
| DP-E-11 | Clasificación tardía: `started_at = created_at`, marcada | **CERRADA** |
| DP-E-12 | No almacenar cuerpos de correo | **CERRADA** (solo metadatos) |

---

## 13. Confirmación

Documento de reglas. No se creó ningún servicio, tabla, índice, credencial ni política. No se modificó Zammad. No se envió ningún correo. No se inició ningún worker.
