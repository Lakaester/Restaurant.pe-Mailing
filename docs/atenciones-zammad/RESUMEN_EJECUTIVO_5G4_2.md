# RESUMEN EJECUTIVO — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** auditoría y diseño de solo lectura.
**Resultado:** arquitectura de captura de eventos definida; nada implementado.

---

## 1. Qué se hizo

1. Auditoría de los siete mecanismos de integración de Zammad.
2. Verificación de la cobertura real de los trece eventos requeridos.
3. Análisis del flujo de entrega de correo y WhatsApp.
4. Verificación empírica del problema de primera respuesta.
5. Diseño del contrato de eventos.
6. Diseño de consistencia, idempotencia y reconciliación.
7. Diseño de ciclos de resolución.
8. Diseño de la arquitectura del BFF.
9. Inventario de decisiones pendientes.

---

## 2. Mecanismo de captura recomendado

**Sondeo por API REST como mecanismo principal, con webhook como opción futura.**

| Criterio | Sondeo | Webhook |
|---|---|---|
| Modifica Zammad | No | Sí (trigger + worker) |
| Cubre confirmación de envío | **Sí** | **No** |
| Depende del worker | No | Sí |
| Latencia | 1-5 min | Segundos |
| Garantía | Alta | Baja |

La razón decisiva es que **la confirmación de envío no genera ningún evento en Zammad**. El despachador descarta las actualizaciones de artículo (`lib/transaction_dispatcher.rb` 148-150), por lo que ningún webhook puede verlas.

---

## 3. Cobertura real de eventos

| # | Evento | Sondeo | Webhook |
|---:|---|---|---|
| 1 | Creación de ticket | Sí | Sí |
| 2 | Cambio de canal | Parcial | Parcial |
| 3 | Creación de artículo | Sí | Sí |
| 4 | Respuesta pública de agente | Sí | Sí |
| 5 | Confirmación de envío | **Sí** | **No** |
| 6 | Fallo de envío | **Sí** | **No** |
| 7 | Cambio de categoría | Sí | Sí |
| 8 | Cambio de subcategoría | Sí | Sí |
| 9 | Cambio de estado | Sí | Sí |
| 10 | Cierre | Sí | Sí |
| 11 | Reapertura | Sí | Sí |
| 12 | Reasignación | Sí | Sí |
| 13 | Cambio de prioridad | Sí | Sí |

**Ningún mecanismo cubre los trece eventos por sí solo.** El sondeo cubre doce de trece de forma directa y el restante de forma parcial.

---

## 4. Estrategia de recuperación

| Mecanismo | Función |
|---|---|
| Clave de idempotencia | Evita duplicados entre fuentes |
| Máquina de estados con versión | Evita retrocesos por eventos fuera de orden |
| Marca de agua por `updated_at` | Define qué falta leer |
| Ventana de solapamiento | Cubre desfases y transacciones lentas |
| Reconciliación incremental | Cada 5-15 min |
| Reconciliación completa | Diaria |
| Registro de divergencias | Detecta y conserva inconsistencias |

**Principio:** *at-least-once* en captura, *effectively-once* en aplicación, **compromiso inmutable**.

---

## 5. Tratamiento de primera respuesta

### 5.1 Hallazgo

**VERIFICADO (datos).** En el ticket 7:

```
first_response_at = hora de creación del artículo (diferencia 0.000 s)
envío confirmado  = 9 h 34 min después
artículo 4        = respuesta de agente sin estado de envío
```

### 5.2 Propuesta

Una primera respuesta cuenta solo si:

1. el artículo es público;
2. el emisor es `Agent`;
3. el tipo es de comunicación;
4. `delivery_status = 'success'`;
5. en WhatsApp, existe `timestamp_delivered` o `timestamp_read`.

### 5.3 Distinción

| Nivel | Correo | WhatsApp |
|---|---|---|
| Envío exitoso | Sí | Sí |
| Recepción confirmada | No | Sí |

---

## 6. Tratamiento de WhatsApp

| Aspecto | Estado |
|---|---|
| Identificador externo | `message_id` del proveedor (verificado en código) |
| Estados disponibles | `sent`, `delivered`, `read`, `failed` |
| Persistencia | `preferences[:whatsapp][timestamp_*]` |
| Genera evento | No, salvo `sent` (inferido) |
| Canal configurado en esta instalación | **No verificado** |

**Conclusión:** WhatsApp ofrece mejor trazabilidad que el correo, pero solo si el canal está operativo. Queda **PENDIENTE** confirmar el canal en producción.

---

## 7. Modelo de persistencia propuesto

| Tabla | Propósito |
|---|---|
| `sla_event` | Eventos e idempotencia |
| `sla_ticket` | Estado del ticket en el motor |
| `sla_commitment` | Compromiso congelado |
| `sla_cycle` | Ciclos de resolución |
| `sla_reopen` | Reaperturas |
| `sla_policy` | Catálogo de 65 políticas |
| `sla_policy_version` | Versiones |
| `sla_policy_audit` | Auditoría |
| `sla_alert` | Alertas |
| `sla_reconciliation_run` | Ciclos de reconciliación |
| `sla_divergence` | Divergencias |

**Ninguna tabla fue creada.**

---

## 8. Contrato de eventos

### 8.1 Envoltorio

`event_id`, `event_type`, `event_version`, `occurred_at`, `received_at`, `source`, `ticket_id`, `idempotency_key`, `payload_version`.

### 8.2 Eventos obligatorios

1. `ticket.created`
2. `ticket.state_changed`
3. `ticket.closed`
4. `ticket.reopened`
5. `article.created`
6. `article.delivery_confirmed`
7. `article.delivery_failed`
8. `ticket.classified`

### 8.3 Eventos opcionales

`ticket.assigned`, `ticket.priority_changed`, `ticket.group_changed`, `ticket.channel_detected`, `ticket.merged`, `article.internal_note`.

---

## 9. Alternativas para reaperturas

| Criterio | A. Nuevo ciclo | B. Sin nuevo compromiso |
|---|---|---|
| Conserva primer cierre | Sí | Sí |
| Nuevo plazo | Sí | No |
| Mide reatención | Sí | No |
| Complejidad | Media | Baja |
| Coincide con nativo | No | Sí |

**Recomendación:** A, con el ciclo 1 como métrica oficial de cumplimiento.

**Estado:** PENDIENTE DE APROBACIÓN.

---

## 10. Riesgos

| Riesgo | Nivel |
|---|---|
| La confirmación de envío no genera evento | **Alto** (verificado) |
| Dependencia de la API de Zammad | Alto |
| Pérdida de la política aplicada si cae el BFF | Alto |
| 31,1 % fuera de catálogo | Alto |
| Clasificación incompleta | Alto |
| Latencia del sondeo | Medio |
| Cambios de esquema en Zammad | Medio |
| Volumen diario desconocido | Medio |

---

## 11. Decisiones pendientes críticas

1. Mecanismo de captura inicial (D-5G42-01).
2. Criterio de primera respuesta (D-5G42-02).
3. Alternativa de ciclos (D-5G42-04).
4. Persistencia de la política aplicada (D-5G42-06).
5. Responsable del catálogo (D-5G42-14).
6. Credencial de lectura (D-5G42-15).

---

## 12. Hallazgos verificados con referencia

| Hallazgo | Referencia | Estado |
|---|---|---|
| El cálculo nativo usa tiempo hábil del calendario | `lib/escalation.rb` 15-17, 182-186 | VERIFICADO |
| El vencimiento se ancla en `created_at` | `lib/escalation.rb` 128-136, 172-180 | VERIFICADO |
| `ignore_escalation` anula vencimientos y genera *breaks* | `lib/escalation.rb` 23-25; `ticket_biz_break.rb` 30-56 | VERIFICADO |
| No hay congelamiento: se recalcula en cada guardado | `app/models/ticket/escalation.rb` 7, 29-46 | VERIFICADO |
| Cambiar una política recalcula todos los tickets abiertos | `has_escalation_calculation_impact.rb` 6-34 | VERIFICADO |
| Tras el primer cierre no hay nuevo vencimiento | `lib/escalation.rb` 172-180 | VERIFICADO |
| `first_response_at` se fija al crear el artículo | `has_ticket_contact_attributes_impact.rb` 59-82 | VERIFICADO |
| Las actualizaciones de artículo no generan transacción | `lib/transaction_dispatcher.rb` 148-150 | VERIFICADO |
| La precedencia de SLA por nombre funciona | `app/models/sla.rb` 30-40; `active_record_as_batches.rb` 23-58 | VERIFICADO |
| La auditoría guarda anterior/nuevo y usuario | `has_audit_logs.rb` 42-71, 139-155; `audit_logs` id 1 | VERIFICADO |
| Los cambios automáticos quedan sin usuario | `audit_logs` id 29 (`user_id = nil`) | VERIFICADO |
| El calendario 24/7 sería continuo | gem `biz` 1.8.2, `day_time.rb` y `configuration.rb` | **INFERIDO** |
| El webhook no captura la entrega | `trigger_webhook_job.rb` + `transaction_dispatcher.rb` | VERIFICADO |
| WhatsApp `delivered`/`read` no genera evento | `lib/whatsapp/webhook/message/status.rb` + despachador | VERIFICADO (código) |

---

## 13. Recomendación final

**Adoptar el motor SLA propio en el BFF, en modo solo lectura de Zammad, con sondeo por API como mecanismo inicial.**

Condiciones:

1. No crear SLA ni cambiar estados en Zammad.
2. No activar el worker.
3. No crear triggers ni webhooks en la primera fase.
4. Aprobar las seis decisiones críticas.
5. Designar responsable del catálogo.

**El motor nativo no se recomienda** porque, con la evidencia disponible:

- no congela el compromiso;
- recalcula tickets abiertos al cambiar políticas;
- no reactiva el vencimiento tras el primer cierre;
- registra la primera respuesta antes de confirmar el envío.

---

## 14. Documentos creados

| Documento | Contenido |
|---|---|
| `AUDITORIA_EVENTOS_ZAMMAD_5G4_2.md` | Mecanismos, cobertura, garantías y limitaciones |
| `ANALISIS_ENTREGA_PRIMERA_RESPUESTA_5G4_2.md` | Correo, WhatsApp y primera respuesta efectiva |
| `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md` | Idempotencia, orden, reconciliación y divergencias |
| `CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md` | Envoltorio, catálogo y ejemplos |
| `DISENO_CICLOS_RESOLUCION_SLA_5G4_2.md` | Alternativas A/B y modelo de ciclos |
| `ARQUITECTURA_BFF_MOTOR_SLA_5G4_2.md` | Componentes, modos de captura y fases |
| `DECISIONES_PENDIENTES_5G4_2.md` | 17 decisiones con opciones y recomendación |
| `RESUMEN_EJECUTIVO_5G4_2.md` | Este documento |

Ningún documento anterior fue sobrescrito.

---

## 15. Confirmación de no modificaciones

| Comprobación | Resultado |
|---|---|
| Código fuente | Sin cambios |
| Base de datos | Solo lecturas |
| Tablas creadas | 0 |
| Atributos creados | 0 |
| Webhooks creados | 0 |
| Triggers creados o modificados | 0 |
| SLA creados | 0 |
| Calendarios modificados | 0 |
| Estados modificados | 0 |
| Worker | Detenido, no iniciado |
| Buzones | No tocados |
| Mensajes enviados | 0 |
| Zendesk | No tocado |
| COSE | No tocado |
| Dependencias instaladas | 0 |
| Documentos previos | Intactos |

**Estado de la instalación al cierre:** 0 SLA, 2 calendarios, 0 webhooks, 3 triggers (0 activos), 2 tickets, 5 artículos, 29 registros de auditoría, 44 registros de historial.

---

## 16. Siguiente paso

1. Aprobar o rechazar las seis decisiones críticas.
2. Autorizar la fase 1 del BFF (solo lectura).
3. Designar al responsable del catálogo.
4. Definir el tratamiento del 31,1 % fuera de catálogo.

No se inicia ninguna implementación sin autorización expresa.
