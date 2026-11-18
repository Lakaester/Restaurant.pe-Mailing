# RESUMEN EJECUTIVO — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3 — Cierre de decisiones y diseño de implementación del motor SLA
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Resultado:** ocho documentos de diseño. **Cero cambios técnicos.**

---

## 1. Qué se decidió y qué queda pendiente

### 1.1 Consolidado

| Tema | Estado |
|---|---|
| Zammad conserva tickets, artículos, usuarios, grupos, estados y canales | **Aprobado** (5G.3 y 5G.4) |
| El motor SLA propio calcula políticas, compromisos, vencimientos, ciclos, alertas, auditoría y cumplimiento | **Aprobado** como arquitectura |
| Cero políticas SLA nativas | **Aprobado** |
| `ignore_escalation` no se modifica | **Aprobado** |
| Tiempo calendario 24/7, sin pausas | **Aprobado** (5G.3) |
| Inicio en `created_at`, fin en el primer `closed` | **Aprobado** (5G.3) |
| Congelamiento del compromiso al clasificar | **Aprobado** (5G.3) |
| Reclasificación registrada sin alterar el compromiso | **Aprobado** (5G.3) |
| 65 políticas con SLA, 5 sin evidencia | **Aprobado** (5G.2.1 y 5G.3) |
| Objetivo ≥ 80 %, ventana 01/04/2026–31/10/2026 | **Aprobado** |
| Sondeo API como mecanismo principal | **Propuesto** (CAP-01) |
| Confirmación de envío como criterio de primera respuesta | **Propuesto** (PR-03 a PR-08) |
| Alternativa A de reaperturas | **Propuesto** (REA-02) |
| Modelo de 9 tablas (reducido desde 11) | **Propuesto** |

### 1.2 Pendiente de aprobación

| ID | Pendiente | Prioridad | Recomendación |
|---|---|---|---|
| DP-01 | WhatsApp: ¿aceptación o entrega confirmada? | Crítica | Aceptación, entrega registrada |
| DP-02 | Alternativa A de ciclos en reapertura | Crítica | Aprobar A |
| DP-04 | Responsable del catálogo | Crítica | Designar |
| DP-03 | Alcance exacto del sondeo de 1 minuto | Alta | Solo primera respuesta pendiente |
| DP-05 | Tratamiento del 31,1 % fuera de catálogo | Alta | Respaldo provisional marcado |
| DP-06 | Las 5 combinaciones sin evidencia | Alta | Sin SLA, como aprobado |
| DP-07 | Persistencia de la política si cae el BFF | Alta | BFF más respaldo externo |
| DP-08 a DP-10 | Retención, nivel de reporte, motivo obligatorio | Media | Según documento de decisiones |

---

## 2. Arquitectura recomendada

```
C.O.S.E. ──► BFF ──► Motor SLA ──► Reportes y alertas
               │
               └── sondeo de solo lectura ──► Zammad (API REST)
```

| Elemento | Función |
|---|---|
| Sondeo por `updated_at` | Detecta tickets, artículos, estados y confirmaciones de entrega |
| Cola de eventos | Persiste antes de procesar; idempotencia por clave única |
| Compromiso inmutable | Snapshot de política, canal, categoría, subcategoría, tiempos y vencimientos |
| Ciclos | Ciclo 1 oficial; ciclos posteriores como indicador operativo |
| Reconciliación | Incremental cada 15 min y completa diaria |
| Auditoría | Cambios administrativos y decisiones del motor |

**Regla estructural:** el BFF no escribe en Zammad en ninguna fase.

---

## 3. Capacidad real de sondeo

### 3.1 Verificado en código

| Capacidad | Resultado |
|---|---|
| Búsqueda por `updated_at` | Disponible (`ticket.updated_at`, operador `after (absolute)`) |
| Máximo por página en búsqueda | 200 |
| Paginación | Por desplazamiento (`OFFSET`/`LIMIT`) |
| Total de resultados | Disponible |
| Artículos por ticket | Disponibles con `preferences` y `delivery_status` |
| Filtro por fecha en artículos | No existe en el endpoint por ticket |
| Historial | Completo por ticket, sin filtro de fecha |
| Límite de tasa en la API | No encontrado en el código revisado |

### 3.2 No verificado

| Punto | Por qué importa |
|---|---|
| Que un cambio de `delivery_status` eleve `ticket.updated_at` | Es la base de la detección |
| Que un rol de solo lectura impida escrituras | Es la base del token de sondeo |
| Límites del proxy o balanceador | Puede invalidar la estimación de carga |
| Formato exacto del valor de fecha en el selector | Afecta a la consulta incremental |

### 3.3 Estimación de carga

Supuestos declarados y **no medidos**: 2 %, 5 % y 15 % de tickets activos modificados por minuto.

| Tickets activos | 2 % | 5 % | 15 % |
|---|---:|---:|---:|
| 100 | ≈ 3 pet/min | ≈ 7 pet/min | ≈ 20 pet/min |
| 1.000 | ≈ 27 pet/min | ≈ 66 pet/min | ≈ 196 pet/min |
| 10.000 | ≈ 262 pet/min | ≈ 652 pet/min | ≈ 1.960 pet/min |

Lectura: carga baja hasta 1.000 tickets activos. A 10.000 con modificación alta, el escenario supera 30 peticiones por segundo sostenidas y **no está probado**. El cuello de botella es la consulta de artículos, reducible consultándolos solo cuando cambia el último artículo visto.

---

## 4. Modelo de datos

De 11 tablas propuestas en 5G.4.2 a **9**:

| Tabla | Función |
|---|---|
| `sla_policy_version` | Catálogo y versiones inmutables |
| `sla_commitment` | Snapshot por ticket (único por `ticket_id`) |
| `sla_cycle` | Ciclos de resolución (único abierto por compromiso) |
| `sla_event` | Hechos e idempotencia |
| `sla_article_delivery` | Estado de entrega por artículo |
| `sla_alert` | Alertas por umbral (75 % y 90 %) |
| `sla_audit` | Auditoría de cambios administrativos |
| `sla_divergence` | Divergencias detectadas por reconciliación |
| `sla_sync_run` | Marca de agua y ciclos de sondeo |

**Eliminadas:** `sla_ticket` (absorbida por `sla_commitment`), `sla_reopen` (derivada de `sla_cycle`), `sla_policy_audit` (fusionada en `sla_audit`).
**Renombrada:** `sla_reconciliation_run` → `sla_sync_run`.
**Añadida:** `sla_article_delivery`.

No se creó ninguna tabla.

---

## 5. Ciclos

| Escenario | Resultado |
|---|---|
| Cierre dentro del plazo | Ciclo 1 `met` |
| Cierre fuera del plazo | Ciclo 1 `missed` |
| Reapertura (si REA-02) | Ciclo 2 con nuevo `due_at`; el ciclo 1 no cambia |
| Re-cierre sin reapertura | Registro `reclose`; no crea ciclo |
| Fusionado | Cierra el ciclo abierto; no abre otro |

La métrica oficial de cumplimiento es el **ciclo 1**. Los ciclos posteriores se reportan como indicador operativo separado.

---

## 6. Seguridad

| Control | Diseño |
|---|---|
| Credencial de sondeo | Usuario y rol de solo lectura, sin permisos de escritura |
| Credencial administrativa de Zammad | **No se crea**; el catálogo vive en el BFF |
| Almacenamiento | Gestor de secretos; nunca en repositorio, logs ni URL |
| Rotación | Token cada 90 días con solapamiento de 24 h |
| Registro de accesos | En el BFF; `audit_logs` de Zammad no registra lecturas |
| Protección | TLS estricto, validación de entrada, sin SSRF, errores genéricos |

**Hallazgo relevante:** el token de Zammad no tiene un permiso de solo lectura. La restricción debe venir del rol y de los accesos de grupo, y debe probarse.

---

## 7. Plan por fases

| Fase | Contenido | Puerta de salida |
|---|---|---|
| 0 | Verificación de 9 capacidades de la API | Rol de lectura probado y confirmación eleva `updated_at` |
| 1 | Ingesta de solo lectura | 7 días sin pérdidas frente a reconciliación completa |
| 2 | Catálogo y snapshot | Reproduce la matriz 5G.2.1 exactamente |
| 3 | Compromisos y ciclos | Coincide con cálculo manual, incluidos feriados |
| 4 | Primera respuesta efectiva | Ticket 7 clasificado correctamente |
| 5 | Alertas y reportes | Denominador correcto y ≥ 80 % verificable |
| 6 | Reconciliación y operación | Caída de 2 h sin pérdidas |
| 7 (opcional) | Webhooks | No aporta `delivery_status`; solo latencia |

Ninguna fase está autorizada.

---

## 8. Riesgos

| Riesgo | Nivel | Mitigación |
|---|---|---|
| La confirmación de entrega no eleva `updated_at` | Alto | Prueba 0.6 antes de la fase 1; alternativa de sondeo por artículos |
| Pérdida de eventos por paginación por desplazamiento | Medio | Orden estable, solapamiento de 15 min, reconciliación completa |
| Token de sondeo con permisos de escritura | Alto | Rol de solo lectura probado; revisión trimestral |
| WhatsApp no operativo en producción | Alto | Verificar antes de la fase 4; no prometer el canal |
| Correo sin recibo más allá de SMTP | Medio | Criterio PR-03 acordado y documentado |
| Ticket clasificado tarde con vencimiento ya pasado | Medio | Marcar `late_classification` en divergencias |
| Pérdida de la base del BFF | Alto | Respaldo verificado y DP-07 |
| Clasificación fuera de catálogo (31,1 %) | Medio | Respaldo provisional marcado, nunca silencioso |
| Reaperturas sin regla aprobada | Alto | Sin REA-02 el motor no genera vencimientos de reapertura |

---

## 9. Documentos de esta etapa

| # | Documento |
|---:|---|
| 1 | `DECISIONES_FUNCIONALES_MOTOR_SLA_5G4_3.md` |
| 2 | `DISENO_SONDEO_INCREMENTAL_ZAMMAD_5G4_3.md` |
| 3 | `ARQUITECTURA_PROCESAMIENTO_EVENTOS_SLA_5G4_3.md` |
| 4 | `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` |
| 5 | `DISENO_CICLOS_Y_COMPROMISOS_SLA_5G4_3.md` |
| 6 | `SEGURIDAD_INTEGRACION_BFF_SLA_5G4_3.md` |
| 7 | `PLAN_IMPLEMENTACION_MOTOR_SLA_5G4_3.md` |
| 8 | `RESUMEN_EJECUTIVO_5G4_3.md` |

---

## 10. Confirmación de ausencia de modificaciones técnicas

| Restricción | Cumplimiento |
|---|---|
| No modificar código | **Cumplido.** Ningún archivo de código tocado |
| No modificar bases de datos | **Cumplido.** Ninguna escritura en Zammad |
| No crear tablas | **Cumplido.** Modelo solo conceptual |
| No crear atributos | **Cumplido** |
| No crear credenciales | **Cumplido.** Sin usuarios, roles ni tokens |
| No crear webhooks | **Cumplido.** Siguen en 0 |
| No crear triggers | **Cumplido.** Siguen en 3, todos inactivos |
| No crear políticas SLA | **Cumplido.** Siguen en 0 |
| No iniciar workers | **Cumplido.** Worker detenido |
| No conectar buzones | **Cumplido** |
| No modificar Zendesk | **Cumplido** |
| No modificar COSE | **Cumplido** |
| No instalar dependencias | **Cumplido** |
| No sobrescribir documentos anteriores | **Cumplido.** 40 documentos previos intactos |

Las únicas escrituras fueron los ocho documentos nuevos.

---

## 11. Próxima decisión

Antes de cualquier trabajo técnico se requiere:

1. Aprobar o rechazar DP-01, DP-02, DP-04 y DP-07.
2. Autorizar la fase 0 con su prueba crítica 0.6.
3. Designar responsable del catálogo y gestor de secretos.
4. Confirmar si la fase 7 queda fuera de alcance.

Sin esos cuatro puntos, el diseño está completo pero la implementación no puede comenzar.
