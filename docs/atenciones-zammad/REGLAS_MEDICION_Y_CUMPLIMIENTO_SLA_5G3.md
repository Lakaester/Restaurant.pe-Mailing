# REGLAS DE MEDICIÓN Y CUMPLIMIENTO — SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**

---

## 1. Principios aprobados

1. **Tiempo calendario:** 24 horas al día, 7 días a la semana.
2. **Sin pausas:** ningún estado pendiente detiene el reloj.
3. **Inicio:** `created_at` del ticket.
4. **Primera respuesta:** primer artículo público de agente.
5. **Resolución:** al pasar a `closed`.
6. **`pending close`:** no finaliza ni pausa.
7. **Reapertura:** conserva el primer cumplimiento.
8. **Reclasificación:** conserva el SLA original.
9. **Cumplimiento objetivo:** ≥ 80 %.
10. **Ventana estadística:** 01/04/2026–31/10/2026.

---

## 2. Fórmulas

```
tiempo_transcurrido = ahora - created_at
vencimiento_primera_respuesta = created_at + first_response_time
vencimiento_resolucion = created_at + solution_time

primera_respuesta_cumplida =
  first_response_at existe Y first_response_at <= vencimiento_primera_respuesta

resolucion_cumplida =
  first_closed_at existe Y first_closed_at <= vencimiento_resolucion

incumplido =
  (primera_respuesta no cumplida Y ahora > vencimiento_primera_respuesta)
  O
  (resolucion no cumplida Y ahora > vencimiento_resolucion)
```

**Nota:** `ahora` solo se usa para detectar incumplimiento mientras el ticket está abierto. Una vez cumplido, el resultado no cambia.

---

## 3. Primera respuesta

### 3.1 Definición verificada

**VERIFICADO en `app/models/ticket/article/has_ticket_contact_attributes_impact.rb`:**

`first_response_at` se fija cuando:

- El artículo no es `internal`.
- El emisor es `Agent`.
- El tipo de artículo es de comunicación.
- `first_response_at` está vacío.

### 3.2 Exclusiones

| Caso | ¿Cuenta? |
|---|---|
| Nota interna | **No** |
| Artículo de cliente | No |
| Artículo de sistema | No |
| Respuesta pública de agente | **Sí** |
| Respuesta automática de trigger | **PENDIENTE** |
| Respuesta por WhatsApp | **PENDIENTE** de validar el tipo |
| Respuesta por correo | **Sí**, si el tipo es `email` |

**PENDIENTE:** confirmar si los triggers que crean artículos de agente cuentan. La regla de código solo mira emisor y tipo, no el origen.

### 3.3 Objetivos

| Canal | Objetivo | Minutos |
|---|---:|---:|
| WhatsApp | < 15 min | 15 |
| Correo | < 24 h | 1.440 |

---

## 4. Resolución

### 4.1 Definición

- Se registra al pasar a un estado de tipo `closed`.
- `pending close` no finaliza.
- `pending reminder` no finaliza.
- `merged` no se considera resolución.

**VERIFICADO en `app/models/ticket/sets_close_time.rb`:** `close_at` se fija cuando `state_type.name == 'closed'`.

### 4.2 Reapertura

- `close_at` conserva el primer cierre.
- `last_close_at` se actualiza.
- El primer cumplimiento no se borra.
- La reapertura se registra como evento.
- Un ticket reabierto puede tener un nuevo cierre, pero el cumplimiento original se mantiene para la métrica histórica.

**PROPUESTA:** distinguir:

- `first_closed_at`: primer cierre.
- `last_closed_at`: último cierre.
- `reopen_count`: número de reaperturas.

---

## 5. Estados de cumplimiento

| Estado | Definición |
|---|---|
| `DENTRO` | No vencido, sin marca de cumplimiento |
| `PROXIMO` | Falta menos que el umbral |
| `INCUMPLIDO` | Venció sin cumplir |
| `CUMPLIDO` | Cumplió dentro del plazo |
| `SIN_SLA` | No hay política aplicable |

### 5.1 Separación

Cada ticket tiene dos estados independientes:

- Primera respuesta.
- Resolución.

No se agregan en un solo estado.

---

## 6. Umbrales de alerta

| Métrica | Aviso | Crítico |
|---|---:|---:|
| Primera respuesta | 75 % del tiempo | 100 % |
| Resolución | 75 % del tiempo | 90 % del tiempo |

**PROPUESTA.** Configurables por canal.

**HIPÓTESIS:** no se verificó un mecanismo nativo de alertas con estos umbrales.

---

## 7. Cumplimiento

### 7.1 Fórmula

```
cumplimiento_primera = cumplidos_primera / evaluables_primera
cumplimiento_resolucion = cumplidos_resolucion / evaluables_resolucion
```

### 7.2 Denominador

- Solo tickets con SLA asignado.
- Solo tickets con marca real.
- Los tickets sin SLA no cuentan.
- Los tickets abiertos no cuentan como incumplidos hasta que vence el plazo.
- Los tickets cerrados sin `close_at` se excluyen y se reportan como dato faltante.

### 7.3 Objetivo

**APROBADO:** ≥ 80 %.

**PENDIENTE:** definir si el 80 % aplica por canal, por categoría o global.

---

## 8. Casos especiales

### 8.1 Ticket sin categoría

- Sin SLA.
- No cuenta en el denominador.
- Se muestra como “sin SLA hasta clasificar”.

### 8.2 Ticket sin subcategoría

- Sin SLA.
- No cuenta.
- Se muestra como pendiente de clasificación.

### 8.3 Categoría no homologada

- Respaldo provisional del canal.
- Se marca `provisional=true`.
- Cuenta en el denominador, pero se reporta aparte.

### 8.4 Subcategoría nueva

- Respaldo provisional.
- Se marca.
- Se revisa en la siguiente versión de la matriz.

### 8.5 Canal no contemplado

- Sin SLA.
- No cuenta.
- Se reporta.

### 8.6 Combinación sin evidencia

- Sin SLA.
- No cuenta.
- Se muestra como pendiente.

### 8.7 Política desactivada

- Sin SLA para tickets nuevos.
- Los tickets existentes conservan su SLA congelado.
- Se reporta.

### 8.8 Reclasificación

- El SLA original se conserva.
- Se registra el cambio.
- No se reinicia el reloj.
- No se cambia el vencimiento.
- El ticket sigue en el denominador con su SLA original.

### 8.9 Reapertura

- Se conserva el primer cumplimiento.
- Se registra la reapertura.
- No se reinicia el SLA.
- Se reporta como reincidencia.

---

## 9. Ejemplo funcional

Ticket creado el lunes a las 22:00.
SLA de resolución: 2 horas.
Vencimiento: lunes a las 24:00.

| Evento | Hora | Efecto |
|---|---|---|
| Creación | Lunes 22:00 | Inicio |
| Estado `pending reminder` | Lunes 23:00 | **No pausa** |
| Sin resolver | Martes 00:01 | **Incumplido** |
| Resolución | Martes 08:00 | Incumplido, no cumplido |

**Resultado:** incumplido desde el lunes a las 24:00.

---

## 10. Ejemplo de primera respuesta

Ticket de WhatsApp creado a las 22:50.
SLA de primera respuesta: 15 min.
Vencimiento: 23:05.

| Evento | Hora | Efecto |
|---|---|---|
| Creación | 22:50 | Inicio |
| Respuesta pública | 23:04 | Cumplido |
| Respuesta pública | 23:06 | Incumplido |

---

## 11. Datos que deben registrarse

| Dato | Fuente |
|---|---|
| `created_at` | Ticket |
| `first_response_at` | Ticket |
| `close_at` | Ticket |
| `last_close_at` | Ticket |
| `sla_policy_key` | Atributo/snapshot |
| `first_response_due_at` | Cálculo |
| `resolution_due_at` | Cálculo |
| `reopen_count` | Snapshot |
| `reclassified_at` | Snapshot |

---

## 12. Reportes de cumplimiento

| Reporte | Denominador |
|---|---|
| Por canal | Tickets con SLA del canal |
| Por categoría | Tickets con SLA de la categoría |
| Por subcategoría | Tickets con SLA de la subcategoría |
| Por agente | Tickets asignados |
| Global | Tickets con SLA |

**PROPUESTA:** COSE BI o BFF.

---

## 13. Validaciones

1. Un ticket `pending` no se detiene.
2. Un ticket `pending close` no se detiene.
3. Un ticket `closed` se detiene.
4. Una reapertura no borra el primer cierre.
5. Una reclasificación no cambia el vencimiento.
6. Una nota interna no cuenta como primera respuesta.
7. Un ticket sin SLA no cuenta como incumplido.
8. Un ticket cerrado sin `close_at` se reporta como dato faltante.

---

## 14. Confirmación

No se modificó ningún estado, SLA, calendario ni ticket. Este documento es diseño.
