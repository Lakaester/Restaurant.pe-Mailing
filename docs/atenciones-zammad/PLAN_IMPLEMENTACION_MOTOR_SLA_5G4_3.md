# PLAN DE IMPLEMENTACIÓN DEL MOTOR SLA — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Modo:** plan. **Nada ejecutado.** Ninguna fase de este plan está autorizada.

---

## 1. Principios del plan

| Principio | Consecuencia |
|---|---|
| Zammad es fuente de hechos, no de cálculo | El motor nativo sigue con 0 políticas |
| Cero escrituras del BFF hacia Zammad | No hay fase que escriba en Zammad |
| Primero observar, después calcular | La fase 0 solo lee y compara |
| Cada fase tiene una puerta de salida verificable | No se avanza sin evidencia |
| El compromiso nace inmutable | La asignación se implementa después de validar el snapshot |
| Nada se activa en producción sin aprobación explícita | Cada fase requiere autorización nominal |

---

## 2. Resumen de fases

| Fase | Nombre | Escribe | Riesgo | Requiere aprobación |
|---|---|---|---|---|
| 0 | Verificación de capacidades de la API | No | Nulo | Sí |
| 1 | Ingesta de solo lectura y registro de hechos | Solo BFF | Bajo | Sí |
| 2 | Catálogo de políticas y snapshot | Solo BFF | Bajo | Sí |
| 3 | Cálculo de compromisos y ciclos | Solo BFF | Medio | Sí |
| 4 | Primera respuesta efectiva | Solo BFF | Medio | Sí |
| 5 | Alertas y reportes | Solo BFF | Bajo | Sí |
| 6 | Reconciliación y operación continua | Solo BFF | Medio | Sí |
| 7 (opcional) | Webhooks como complemento | Zammad (trigger + worker) | Alto | Sí, separada |

Ninguna fase crea políticas SLA nativas, modifica `ignore_escalation`, conecta buzones ni escribe en Zendesk o COSE.

---

## 3. Fase 0 — Verificación de capacidades de la API

**Objetivo:** convertir en VERIFICADO lo que hoy es INFERIDO o PENDIENTE.

| # | Prueba | Qué demuestra | Criterio de éxito |
|---:|---|---|---|
| 0.1 | Crear un usuario de servicio de prueba con rol de solo lectura en un grupo | Que el modelo de permisos permite solo lectura | El usuario lee tickets del grupo y recibe 403 al intentar `PUT /api/v1/tickets/:id` |
| 0.2 | Emitir un token para ese usuario | Que el token hereda la restricción | Las lecturas funcionan; las escrituras siguen prohibidas |
| 0.3 | `POST /api/v1/tickets/search` con `ticket.updated_at after (absolute)` | Formato real del selector de fecha | Devuelve solo tickets posteriores a la fecha |
| 0.4 | Paginación con `per_page=200` y `page=2` | Límite real y comportamiento del desplazamiento | 200 elementos por página; sin duplicados en lectura estática |
| 0.5 | `GET /api/v1/ticket_articles/by_ticket/:id` sobre un ticket con correo confirmado | Que `delivery_status` y `delivery_status_date` se exponen | Campos presentes con valores reales |
| 0.6 | **Prueba clave:** forzar un cambio de `delivery_status` y observar `ticket.updated_at` | Que la confirmación eleva `updated_at` del ticket | `updated_at` del ticket sube en el mismo ciclo que la confirmación |
| 0.7 | `GET /api/v1/ticket_history/:id` | Tamaño y contenido del historial | Se conoce el volumen por ticket |
| 0.8 | Medir tiempo de respuesta de la búsqueda con el volumen actual | Línea base de rendimiento | Se registra el valor; no se extrapola sin datos |
| 0.9 | Verificar si existe limitación de tasa en el proxy o balanceador | Límite real de infraestructura | Se documenta el límite o su ausencia |

**Salida:** informe de verificación con las nueve pruebas y su resultado.

**Puerta:** si 0.1, 0.2 o 0.6 fallan, el diseño de captura se revisa **antes** de la fase 1.

**Nota:** 0.6 exige crear o modificar datos en Zammad. Requiere autorización explícita y un entorno aislado. No se ejecuta en esta etapa.

---

## 4. Fase 1 — Ingesta de solo lectura

**Objetivo:** leer Zammad de forma incremental y persistir hechos, sin calcular SLA.

| Entregable | Descripción |
|---|---|
| Servicio de sondeo | Ciclo incremental por `updated_at` con marca de agua y solapamiento de 15 min |
| Persistencia de hechos | `sla_event` en estado `pending` con `idempotency_key` |
| Registro de ciclos | `sla_sync_run` con marca de agua antes y después |
| Reintentos | Espera exponencial; la marca no avanza si el ciclo falla |
| Observabilidad mínima | Métricas de §10 de `ARQUITECTURA_PROCESAMIENTO_EVENTOS_SLA_5G4_3.md` |

**Lo que esta fase NO hace:**

- No asigna compromisos.
- No calcula vencimientos.
- No genera alertas.
- No escribe en Zammad.

**Criterio de salida:** durante 7 días consecutivos, el sondeo detecta el 100 % de los cambios que la reconciliación completa también detecta. Cero eventos duplicados aplicados.

**Riesgo principal:** pérdida silenciosa por paginación por desplazamiento. Mitigación: orden estable, solapamiento y comparación con la reconciliación completa.

---

## 5. Fase 2 — Catálogo de políticas y snapshot

**Objetivo:** cargar las 65 políticas y producir el snapshot inmutable.

| Entregable | Descripción |
|---|---|
| Carga del catálogo | 65 filas en `sla_policy_version` con `matrix_version = 5G.2.1` |
| 5 combinaciones sin evidencia | `resolution_minutes = NULL`, `status = 'pending'` |
| Resolución de política | Búsqueda por canal, categoría y subcategoría vigente |
| Snapshot | Escritura única en `sla_commitment` al primer clasificado |
| Auditoría | Alta de política con motivo obligatorio en `sla_audit` |

**Datos de entrada:** `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` y correcciones de 5G.3. **No se recalcula ningún valor.**

**Criterio de salida:** simulación sobre datos históricos de la ventana 01/04/2026–31/10/2026 que reproduce exactamente los conteos de la matriz (65 con SLA, 5 sin evidencia, WhatsApp 40/2/38, correo 30/3/27).

**Riesgo principal:** clasificación ambigua o fuera de catálogo. Mitigación: respaldo provisional marcado (`provisional = true`), nunca silencioso.

---

## 6. Fase 3 — Compromisos y ciclos

**Objetivo:** calcular vencimientos en tiempo calendario 24/7 y gestionar ciclos.

| Entregable | Descripción |
|---|---|
| Vencimiento de primera respuesta | `started_at + first_response_minutes` |
| Vencimiento de resolución | `started_at + resolution_minutes` |
| Ciclo 1 | Abierto en `created_at`, cerrado en la primera transición a `closed` |
| Reapertura (si REA-02 se aprueba) | Ciclo N+1 con `due_at = opened_at + resolution_minutes` |
| Inmutabilidad | `started_at` y `due_at` no se reescriben nunca |
| Reconciliación de cierres | Recupera cierres perdidos sin duplicar ciclos |

**Criterio de salida:** sobre un conjunto de tickets de prueba, el cálculo coincide con un cálculo manual independiente, incluidos fines de semana y feriados.

**Riesgo principal:** reaperturas y fusiones. Mitigación: máquina de estados de §4.2 del documento de procesamiento y registro de divergencias.

---

## 7. Fase 4 — Primera respuesta efectiva

**Objetivo:** determinar la primera respuesta que cumple, con confirmación de envío.

| Entregable | Descripción |
|---|---|
| Detección de candidatos | Artículo público, emisor agente, tipo de comunicación |
| Estado de entrega | `sla_article_delivery` por artículo |
| Criterio de cumplimiento | Correo: `delivery_status = success` (PR-03). WhatsApp: aceptación (PR-04) con entrega registrada (PR-05) |
| Exclusión | Notas internas nunca cuentan (PR-02) |
| Resultado | `met` / `missed` / `pending` en `sla_commitment` |

**Punto crítico:** esta fase depende por completo de la prueba 0.6. Si la confirmación no eleva `updated_at`, la detección exige otro mecanismo y la fase se detiene.

**Criterio de salida:** el caso del ticket 7 se clasifica correctamente: primera respuesta registrada a las 0 h 00 min de creado el artículo, entrega confirmada 9 h 34 min después, resultado **no cumplido** si el plazo es de 15 min o de 2 h.

**Riesgo principal:** correo sin recibo de entrega más allá de la aceptación SMTP. Mitigación: criterio PR-03 acordado y documentado; no se promete más de lo que el canal permite.

---

## 8. Fase 5 — Alertas y reportes

**Objetivo:** avisar antes del vencimiento y reportar cumplimiento.

| Entregable | Descripción |
|---|---|
| Alertas | Umbrales 75 % y 90 % del plazo, una por umbral y métrica |
| Panel | Cumplimiento por canal, categoría y global |
| Reporte oficial | Ciclo 1 como métrica de cumplimiento |
| Reporte operativo | Ciclos posteriores, reincidencia y reclasificados |

**Criterio de salida:** los reportes reproducen los conteos de la matriz y el objetivo ≥ 80 % se calcula sobre el denominador correcto (excluye `no_policy` y `pending_classification`).

**Riesgo principal:** reportar un cumplimiento que incluya tickets sin política. Mitigación: denominador explícito y visible en cada reporte.

---

## 9. Fase 6 — Reconciliación y operación

**Objetivo:** operar de forma continua con garantías de recuperación.

| Entregable | Descripción |
|---|---|
| Reconciliación incremental | Cada 15 min, ventana de solapamiento |
| Reconciliación completa | Diaria, fuera de horario |
| Divergencias | Bandeja de `sla_divergence` con resolución registrada |
| Respaldo del BFF | Copia diaria verificada de la base del motor |
| Procedimiento de restauración | Documentado y probado |
| Rotación de credenciales | Token de sondeo cada 90 días con solapamiento de 24 h |

**Criterio de salida:** simulación de caída del BFF de 2 horas sin pérdida de cierres ni de confirmaciones; simulación de restauración desde respaldo con verificación de compromisos.

**Riesgo principal:** pérdida de la base del BFF. Mitigación: DP-07 (persistencia externa de la política aplicada) y respaldo verificado.

---

## 10. Fase 7 (opcional) — Webhooks

**Objetivo:** reducir latencia de captura, sin sustituir el sondeo.

**Requisitos:**

- Trigger activo en Zammad con activador `action`.
- Worker de Zammad en ejecución.
- Endpoint del BFF con verificación HMAC y `X-Zammad-Delivery`.
- Idempotencia compartida con el sondeo.

**Restricción verificada:** el webhook **no** informa cambios de `delivery_status` (`lib/transaction_dispatcher.rb` 148-150 descarta actualizaciones de artículo). Por tanto, aun con webhooks, la confirmación de entrega sigue dependiendo del sondeo.

**Recomendación:** no implementar en la fase 1. Reevaluar cuando el sondeo esté estable y exista una necesidad medida de menor latencia.

---

## 11. Dependencias y bloqueos

| # | Dependencia | Estado | Bloquea |
|---:|---|---|---|
| 1 | Aprobación de DP-01 (criterio de WhatsApp) | Pendiente | Fase 4 |
| 2 | Aprobación de DP-02 / REA-02 (ciclos) | Pendiente | Fase 3 |
| 3 | Designación del responsable del catálogo (DP-04 / A-13) | Pendiente | Fases 2, 5 y 6 |
| 4 | Prueba 0.6 (confirmación eleva `updated_at`) | Pendiente | Fases 1 y 4 |
| 5 | Verificación de rol de solo lectura (0.1 y 0.2) | Pendiente | Fase 1 |
| 6 | Operatividad real del canal WhatsApp | No verificada | Fase 4 |
| 7 | Gestor de secretos | No designado | Fases 1 y 6 |
| 8 | Autorización de la fase 0 | Pendiente | Todo el plan |

---

## 12. Cronograma relativo

No se fija una fecha absoluta. El orden es obligatorio; la duración es estimación sujeta a las dependencias.

| Fase | Duración estimada | Puede solaparse con |
|---|---|---|
| 0 | 1 a 2 semanas | — |
| 1 | 2 a 3 semanas | — |
| 2 | 1 a 2 semanas | Fase 1 |
| 3 | 2 a 3 semanas | — |
| 4 | 2 a 3 semanas | Fase 3 |
| 5 | 1 a 2 semanas | Fase 4 |
| 6 | 2 semanas, más 4 semanas de observación | Fase 5 |
| 7 | 2 semanas | Posterior a 6 |

**ESTIMACIÓN.** No hay medición de esfuerzo real en esta instalación.

---

## 13. Criterios de aceptación global

| # | Criterio |
|---:|---|
| 1 | Cero políticas SLA nativas en Zammad durante todo el proyecto |
| 2 | Cero escrituras del BFF hacia Zammad |
| 3 | Cero cambios de `ignore_escalation` |
| 4 | Ningún `due_at` modificado después de asignado |
| 5 | Ningún cierre perdido en las pruebas de caída |
| 6 | Ninguna confirmación de entrega perdida en las pruebas de caída |
| 7 | Los reportes reproducen la matriz 5G.2.1 sin recalcular valores |
| 8 | El denominador de cumplimiento excluye tickets sin política |
| 9 | Toda corrección administrativa tiene motivo y auditoría |
| 10 | El token de sondeo no puede escribir en Zammad (probado) |

---

## 14. Qué se necesita aprobar antes de empezar

1. Autorizar la fase 0 tal como está descrita, incluida la prueba 0.6 en entorno aislado.
2. Resolver DP-01, DP-02, DP-04 y DP-07.
3. Designar al responsable del catálogo y al gestor de secretos.
4. Confirmar si la fase 7 (webhooks) queda fuera del alcance del proyecto.

---

## 15. Confirmación

Este plan no se ejecutó. No se creó ningún servicio, tabla, credencial ni fase. No se modificó Zammad, Zendesk ni COSE.
