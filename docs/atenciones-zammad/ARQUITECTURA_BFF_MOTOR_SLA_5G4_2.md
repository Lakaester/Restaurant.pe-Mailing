# ARQUITECTURA DEL BFF Y MOTOR SLA PROPIO — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**

---

## 1. Objetivo

Definir la arquitectura del motor SLA propio integrado con Zammad mediante un BFF, de modo que:

- el SLA se mida en tiempo calendario;
- ningún estado pause el reloj;
- la primera respuesta requiera envío confirmado;
- el compromiso se congele al clasificar;
- las reaperturas conserven el primer cierre;
- COSE consuma los datos sin acoplarse a Zammad.

Zammad sigue siendo el sistema de tickets. El BFF es el sistema de SLA.

---

## 2. Principios

1. **Zammad no se modifica.** Sin atributos, sin triggers, sin SLA, sin cambios de estado.
2. **El BFF no escribe en Zammad.** Solo lee.
3. **El compromiso es inmutable.** Ver `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md`.
4. **La captura es redundante.** Webhook y sondeo se complementan.
5. **La primera respuesta exige evidencia de envío.**
6. **Todo cálculo es reproducible** desde datos persistidos.
7. **COSE consume, no calcula.**

---

## 3. Vista general

```
┌──────────────┐     lectura API      ┌─────────────────────────┐
│   Zammad     │◄─────────────────────│  Reconciliador (poll)   │
│              │                      └───────────┬─────────────┘
│  tickets     │     webhook (opcional)           │
│  artículos   │─────────────────────►┌───────────▼─────────────┐
│  historial   │                      │   Ingesta de eventos    │
└──────────────┘                      └───────────┬─────────────┘
                                                  │
                                      ┌───────────▼─────────────┐
                                      │  Almacén de eventos     │
                                      │  (idempotencia)         │
                                      └───────────┬─────────────┘
                                                  │
                                      ┌───────────▼─────────────┐
                                      │  Motor SLA              │
                                      │  · clasificación        │
                                      │  · congelamiento        │
                                      │  · primera respuesta    │
                                      │  · ciclos               │
                                      └───────────┬─────────────┘
                                                  │
                        ┌─────────────────────────┼─────────────────────────┐
                        │                         │                         │
              ┌─────────▼────────┐     ┌──────────▼─────────┐    ┌──────────▼────────┐
              │ Catálogo de      │     │ Planificador de    │    │ API para COSE     │
              │ políticas (65)   │     │ alertas            │    │ (solo lectura)    │
              └──────────────────┘     └────────────────────┘    └───────────────────┘
```

---

## 4. Componentes

### 4.1 Ingesta de eventos

**Responsabilidad:** recibir webhooks y normalizarlos al contrato de `CONTRATO_EVENTOS_MOTOR_SLA_5G4_2.md`.

| Aspecto | Definición |
|---|---|
| Entrada | HTTP POST con JSON |
| Autenticación | HMAC-SHA1 (`X-Hub-Signature`) + token propio |
| Persistencia | Escribe el evento antes de responder |
| Respuesta | `202` si se persistió, `400`/`401` si no |
| Duplicados | Clave de idempotencia |

### 4.2 Almacén de eventos

**Responsabilidad:** guardar todos los eventos con su estado de procesamiento.

Tabla propuesta `sla_event` (ver `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md` §7).

### 4.3 Motor SLA

**Responsabilidad:** aplicar las reglas aprobadas.

| Regla | Implementación conceptual |
|---|---|
| Inicio del SLA | `created_at` del ticket |
| Tiempo calendario | Aritmética directa en `America/Lima`, sin calendario laboral |
| Sin pausas | No se descuenta ningún estado |
| Primera respuesta | Primer artículo público de agente con envío confirmado |
| Resolución | Primer `closed` del ciclo |
| Congelamiento | Política asignada una vez, inmutable |
| Reclasificación | Se registra; no cambia el compromiso |
| Reapertura | Abre ciclo nuevo según alternativa aprobada |
| Feriados | No se descuentan |

### 4.4 Catálogo de políticas

**Responsabilidad:** mantener las 65 combinaciones y sus valores.

| Campo | Uso |
|---|---|
| `policy_key` | Identificador estable |
| `channel` | `whatsapp` / `correo` |
| `category` | Categoría |
| `subcategory` | Subcategoría |
| `first_response_minutes` | 15 / 1440 |
| `resolution_minutes` | Valor de la matriz |
| `provisional` | Respaldo provisional |
| `status` | `active` / `inactive` / `pending` |
| `version` | Versión de la matriz |

La selección de política es **determinista**: coincidencia exacta de canal, categoría y subcategoría. No hay precedencia alfabética ni evaluación de condiciones.

### 4.5 Planificador de alertas

**Responsabilidad:** detectar vencimientos próximos y vencidos.

| Aspecto | Definición |
|---|---|
| Entrada | Compromisos con `due_at` |
| Umbrales | 75 % y 90 % (propuesta) |
| Salida | Notificación interna, correo o webhook |
| Persistencia | Registro de alertas enviadas |
| Idempotencia | Una alerta por compromiso y umbral |

### 4.6 API para COSE

**Responsabilidad:** exponer el estado del SLA.

| Endpoint propuesto | Uso |
|---|---|
| `GET /sla/tickets/{id}` | Estado del ticket y sus ciclos |
| `GET /sla/compliance` | Cumplimiento agregado |
| `GET /sla/policies` | Catálogo |
| `GET /sla/alerts` | Alertas activas |

Solo lectura. COSE no escribe.

### 4.7 Reconciliador

**Responsabilidad:** detectar y corregir eventos perdidos.

Detalle en `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md` §8.

---

## 5. Modos de captura

### 5.1 Modo A — híbrido (webhook + sondeo)

| Aspecto | Valor |
|---|---|
| Latencia | Segundos |
| Dependencia de worker de Zammad | **Sí** |
| Dependencia de triggers | **Sí** |
| Cobertura de entrega | No (requiere sondeo) |
| Complejidad | Media |
| Riesgo | Medio |

### 5.2 Modo B — solo sondeo

| Aspecto | Valor |
|---|---|
| Latencia | 1-5 min (configurable) |
| Dependencia de worker de Zammad | **No** |
| Dependencia de triggers | **No** |
| Cobertura de entrega | Sí |
| Complejidad | Baja |
| Riesgo | Bajo |

### 5.3 Comparación

| Criterio | A. Híbrido | B. Solo sondeo |
|---|---|---|
| Tiempo real | Sí | No |
| Requiere activar worker | Sí | No |
| Requiere crear triggers | Sí | No |
| Riesgo de efectos colaterales en Zammad | Alto | Nulo |
| Cobertura de envío | Parcial | Total |
| Reconciliación | Necesaria | Es el mecanismo principal |
| Carga sobre Zammad | Baja + picos | Constante y controlada |

### 5.4 Recomendación

**Empezar con el modo B (solo sondeo) y evaluar el modo A después.**

Motivos:

1. El worker está detenido y activarlo tiene efectos colaterales no medidos (triggers, notificaciones, recálculo de escalamiento).
2. Crear triggers requiere autorización y afecta a todos los tickets.
3. La confirmación de envío **solo** se obtiene por lectura, así que el sondeo es obligatorio en cualquier caso.
4. El modo B no modifica Zammad en absoluto.
5. La latencia de 1-5 min es compatible con SLA de 15 min si el intervalo es de 1 min.

**Condición:** si se exige latencia menor a 1 minuto para WhatsApp, se evaluará el modo A en una fase posterior, con autorización explícita.

---

## 6. Modelo de datos propuesto

| Tabla | Propósito |
|---|---|
| `sla_event` | Eventos recibidos y procesados |
| `sla_ticket` | Estado del ticket según el motor |
| `sla_commitment` | Compromiso congelado (política, inicio, vencimientos) |
| `sla_cycle` | Ciclos de resolución |
| `sla_reopen` | Reaperturas |
| `sla_policy` | Catálogo de 65 políticas |
| `sla_policy_version` | Historial de cambios de política |
| `sla_policy_audit` | Auditoría de cambios |
| `sla_alert` | Alertas generadas |
| `sla_reconciliation_run` | Ciclos de reconciliación y marca de agua |
| `sla_divergence` | Divergencias detectadas |

Detalle de campos en `DISENO_CONSISTENCIA_Y_RECUPERACION_SLA_5G4_2.md` y `DISENO_CICLOS_RESOLUCION_SLA_5G4_2.md`.

**Ninguna tabla fue creada.**

---

## 7. Flujos

### 7.1 Alta de ticket

```
1. Sondeo detecta ticket nuevo (updated_at > marca).
2. Lee ticket, artículos e historial.
3. Genera evento ticket.created.
4. Determina canal, categoría y subcategoría.
5. Si hay combinación con política activa:
     asigna compromiso congelado.
   Si no:
     marca sin SLA.
6. Calcula vencimientos en tiempo calendario.
7. Persiste.
```

### 7.2 Primera respuesta

```
1. Llega o se detecta article.created.
2. Verifica: no interno, emisor Agent, tipo comunicación.
3. Consulta delivery_status del artículo.
4. Si success: registra primera respuesta con fecha de envío.
5. Si fail: descarta ese artículo y espera el siguiente.
6. Si ausente: marca pendiente de confirmación.
```

### 7.3 Cierre

```
1. Detecta transición a estado tipo closed.
2. Registra cierre del ciclo abierto.
3. Calcula cumplimiento contra due_at.
4. No borra cierres anteriores.
5. Si el ticket se reabre después, abre ciclo nuevo (si se aprueba A).
```

### 7.4 Reclasificación

```
1. Detecta cambio de categoría o subcategoría.
2. Registra evento ticket.classified.
3. NO modifica el compromiso existente.
4. Si el ticket no tenía compromiso, evalúa asignar uno nuevo.
```

---

## 8. Seguridad

| Aspecto | Definición |
|---|---|
| Transporte | TLS obligatorio |
| Autenticación de webhook | HMAC-SHA1 + token |
| Autenticación de API | Token de servicio |
| Autorización | COSE solo lectura |
| Secretos | Gestión fuera del repositorio |
| Datos personales | Minimizar; no almacenar cuerpos completos |
| Retención | Definir por tabla |

---

## 9. Despliegue y operación

| Aspecto | Propuesta |
|---|---|
| Proceso | Servicio del BFF con worker propio |
| Base de datos | PostgreSQL del BFF |
| Frecuencia de sondeo | 1 min (configurable) |
| Reconciliación completa | Diaria |
| Respaldo | Diario, con prueba de restauración |
| Monitoreo | Salud del sondeo, cola de eventos, divergencias |

**No depende del worker de Zammad en el modo B.**

---

## 10. Observabilidad

| Métrica | Umbral |
|---|---|
| Retraso del sondeo | > 5 min |
| Eventos pendientes | > 100 |
| Eventos fallidos | > 0 |
| Divergencias | > 0 |
| Tickets con SLA sin política | > 0 |
| Errores de lectura de API | > 1 % |

---

## 11. Rendimiento y capacidad

| Dato | Valor |
|---|---|
| Tickets históricos | 10.711 en la ventana estadística |
| Políticas | 65 |
| Consultas por ticket en sondeo | 3 (ticket, artículos, historial) |
| Coste estimado | Lineal con tickets modificados, no con el total |

El sondeo incremental solo procesa tickets modificados, así que la carga depende del volumen diario, no del histórico.

**PENDIENTE:** medir el volumen diario real para dimensionar.

---

## 12. Riesgos

| Riesgo | Nivel | Mitigación |
|---|---|---|
| Latencia del sondeo insuficiente | Medio | Reducir intervalo o modo A |
| Pérdida de compromisos al caer el BFF | Alto | Respaldo + política persistida |
| Clasificación incompleta en Zammad | Alto | Respaldo provisional o sin SLA |
| 31,1 % fuera de catálogo | Alto | Decisión pendiente |
| API de Zammad limita paginación | Bajo | Paginar por `updated_at` |
| Cambios de esquema en Zammad | Medio | Contrato versionado |

---

## 13. Fases propuestas

| Fase | Alcance | Requiere autorización |
|---|---|---|
| 0 | Aprobar arquitectura y decisiones | Sí |
| 1 | BFF en modo lectura, sin SLA | Sí |
| 2 | Motor de clasificación y compromiso | Sí |
| 3 | Primera respuesta confirmada | Sí |
| 4 | Ciclos y reaperturas | Sí |
| 5 | Alertas | Sí |
| 6 | API para COSE | Sí |
| 7 | Evaluación del modo híbrido | Sí |

Ninguna fase está autorizada.

---

## 14. Pendientes

| # | Pendiente |
|---:|---|
| 1 | Aprobar modo B como inicio |
| 2 | Aprobar alternativa de ciclos |
| 3 | Definir política de primera respuesta confirmada |
| 4 | Definir tratamiento del 31,1 % fuera de catálogo |
| 5 | Designar responsable del catálogo |
| 6 | Definir retención |
| 7 | Definir si se persiste la política en Zammad |

---

## 15. Confirmación

No se creó ningún servicio, tabla, endpoint ni job. No se modificó Zammad. Todo es diseño.
