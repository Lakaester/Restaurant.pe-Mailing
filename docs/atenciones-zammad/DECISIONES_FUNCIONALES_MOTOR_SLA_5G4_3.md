# DECISIONES FUNCIONALES DEL MOTOR SLA — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Estado del documento:** propuesta para aprobación. **Nada aplicado.**

---

## 1. Arquitectura adoptada como propuesta

| Componente | Responsable |
|---|---|
| Tickets, artículos, usuarios, grupos, estados, canales | Zammad (fuente de hechos) |
| Políticas, compromisos, vencimientos | Motor SLA propio en el BFF |
| Primera respuesta efectiva, ciclos, alertas, auditoría, cumplimiento | Motor SLA propio |
| Reconciliación | Motor SLA propio |

Restricciones de la arquitectura:

- El motor SLA nativo de Zammad **no** calcula compromisos.
- Cero políticas SLA nativas en Zammad.
- `ignore_escalation` **no** se modifica.
- Zammad no recibe escrituras del BFF.

Referencias de la decisión: `ARQUITECTURA_BFF_MOTOR_SLA_5G4_2.md` y `AUDITORIA_EVENTOS_ZAMMAD_5G4_2.md`.

---

## 2. Decisiones propuestas

Estado: **PROPUESTA** = pendiente de aprobación. **APROBADA** = heredada de 5G.3 sin cambios.

### 2.1 Captura

| ID | Decisión | Estado | Nota |
|---|---|---|---|
| CAP-01 | Sondeo API REST como mecanismo principal | PROPUESTA | Única vía que ve `delivery_status` (ver `DISENO_SONDEO_INCREMENTAL_ZAMMAD_5G4_3.md`) |
| CAP-02 | Frecuencia de 1 minuto para tickets con compromiso de primera respuesta pendiente | PROPUESTA | Ver §4 de sondeo: coste depende del volumen |
| CAP-03 | Frecuencia de 5 minutos para el resto de tickets abiertos | PROPUESTA | Reduce carga |
| CAP-04 | Webhooks como complemento futuro, no en la fase 1 | PROPUESTA | Requieren trigger y worker |
| CAP-05 | Reconciliación incremental cada 15 minutos y completa diaria | PROPUESTA | Corrige pérdidas |

### 2.2 Primera respuesta

| ID | Decisión | Estado | Nota |
|---|---|---|---|
| PR-01 | Solo cuenta un artículo público, emisor `Agent`, tipo de comunicación | APROBADA (5G.3) | Sin cambio |
| PR-02 | Notas internas no cuentan | APROBADA (5G.3) | Sin cambio |
| PR-03 | Correo: cuenta con `delivery_status = success` | PROPUESTA | Cambia el criterio de 5G.3, que no exigía envío |
| PR-04 | WhatsApp: cuenta con envío aceptado por el proveedor (`delivery_status = success`) | PROPUESTA | Verificado en código: `base_deliver.rb` 58-64 |
| PR-05 | WhatsApp: confirmación de entrega (`timestamp_delivered`) se registra cuando exista, sin ser condición para cumplir | PROPUESTA | Evita bloquear por falta de estado externo |
| PR-06 | No exigir lectura (`timestamp_read`) | PROPUESTA | Consistente con el requisito |
| PR-07 | Artículo con `delivery_status = fail` no cuenta; se evalúa el siguiente | PROPUESTA | |
| PR-08 | Artículo sin estado de envío no cuenta todavía | PROPUESTA | Queda en "pendiente de confirmación" |

**Punto que requiere atención:** PR-04 y PR-05 implican que WhatsApp "aceptado" cumple aunque la entrega nunca se confirme. Si se quiere exigir entrega en WhatsApp, cambia el criterio y debe aprobarse. Ver DP-01.

### 2.3 Resolución

| ID | Decisión | Estado |
|---|---|---|
| RES-01 | Inicio: creación del ticket (`created_at`) | APROBADA (5G.3) |
| RES-02 | Finalización: primer cierre del ciclo (transición a `closed`) | APROBADA (5G.3) |
| RES-03 | Sin pausas por ningún estado | APROBADA (5G.3) |
| RES-04 | Tiempo calendario 24/7 | APROBADA (5G.3) |
| RES-05 | Reasignación, cambio de prioridad y grupo no reinician el reloj | APROBADA (5G.3 y 5G.4) |
| RES-06 | Reclasificación no modifica el compromiso | APROBADA (5G.3) |

### 2.4 Reaperturas

| ID | Decisión | Estado |
|---|---|---|
| REA-01 | Conservar el primer ciclo y su resultado | APROBADA (requisito 5G.4) |
| REA-02 | Alternativa A: nuevo ciclo con nuevo vencimiento al reabrir | PROPUESTA (recomendada) |
| REA-03 | Histórico de cada ciclo | PROPUESTA |
| REA-04 | Métrica oficial de cumplimiento: ciclo 1 | PROPUESTA |
| REA-05 | Ciclos posteriores se reportan como indicador operativo separado | PROPUESTA |
| REA-06 | Primera respuesta solo en ciclo 1 | PROPUESTA |

Detalle en `DISENO_CICLOS_Y_COMPROMISOS_SLA_5G4_3.md`.

**Nota de decisión:** REA-02 es una decisión funcional nueva. El requisito aprobado no define el plazo del segundo ciclo. Hasta su aprobación, el motor no puede generar vencimientos de reapertura.

### 2.5 Congelamiento

| ID | Decisión | Estado |
|---|---|---|
| CON-01 | Snapshot inmutable al primer clasificado | APROBADA (5G.3) |
| CON-02 | Campos del snapshot (ver §3) | PROPUESTA |
| CON-03 | Ningún cambio posterior de política, calendario o clasificación modifica un snapshot | PROPUESTA |
| CON-04 | Una corrección administrativa de un snapshot exige registro de auditoría y aprobación explícita | PROPUESTA |

### 2.6 Políticas y matriz

| ID | Decisión | Estado |
|---|---|---|
| POL-01 | 65 combinaciones con SLA | APROBADA |
| POL-02 | 5 combinaciones sin evidencia: sin SLA hasta nueva evidencia | APROBADA |
| POL-03 | Valores de la matriz 5G.2.1 sin recálculo | APROBADA |
| POL-04 | Corrección de conteo por canal (WhatsApp 40/2/38; correo 30/3/27) | APROBADA (5G.3) |
| POL-05 | Respaldos provisionales WhatsApp 90 min y correo 36 h, solo para categorías o subcategorías fuera de catálogo | APROBADA (provisional) |
| POL-06 | Cumplimiento objetivo ≥ 80 % | APROBADA |
| POL-07 | Ventana estadística 01/04/2026–31/10/2026 | APROBADA |
| POL-08 | Revisión trimestral de la matriz | APROBADA |

### 2.7 Seguridad y operación

Detalle en `SEGURIDAD_INTEGRACION_BFF_SLA_5G4_3.md`.

---

## 3. Snapshot de compromiso (campos fijados al asignar)

| Campo | Descripción |
|---|---|
| `policy_key` | Clave de la política (ej. `20-MAIL-SOFTWARE-ERROR_WEB`) |
| `policy_version` | Versión de la matriz |
| `channel` | `whatsapp` o `correo` |
| `category` | Categoría original |
| `subcategory` | Subcategoría original |
| `first_response_minutes` | 15 o 1440, o provisional |
| `resolution_minutes` | Valor de la matriz |
| `provisional` | Booleano |
| `assigned_at` | Momento de asignación |
| `started_at` | `created_at` del ticket |
| `first_response_due_at` | `started_at + first_response_minutes` |
| `resolution_due_at` | `started_at + resolution_minutes` (calendario 24/7) |

Ningún campo del snapshot se actualiza después de crearse. Ver `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md`.

---

## 4. Decisiones pendientes

| ID | Pendiente | Prioridad | Recomendación |
|---|---|---|---|
| DP-01 | ¿WhatsApp cumple con aceptación o exige entrega confirmada? | **Crítica** | Aceptación (PR-04), entrega registrada |
| DP-02 | Aprobar alternativa A de reaperturas | **Crítica** | Aprobar A |
| DP-03 | Frecuencia de 1 minuto: alcance exacto | Alta | Solo tickets con primera respuesta pendiente |
| DP-04 | Responsable administrativo del catálogo (A-13) | **Crítica** | Designar |
| DP-05 | Tratamiento del 31,1 % fuera de catálogo | Alta | Respaldo provisional marcado |
| DP-06 | Tratamiento de las 5 combinaciones sin evidencia (sin SLA vs. respaldo) | Alta | Sin SLA, como aprobado |
| DP-07 | Dónde persistir la política aplicada si cae el BFF | Alta | BFF + respaldo externo |
| DP-08 | Retención de eventos y de payloads | Media | 2 años eventos; permanente compromisos |
| DP-09 | Nivel de cumplimiento por canal, categoría o global | Media | Por canal (pendiente de aprobación formal) |
| DP-10 | Motivo obligatorio en cambios de política | Media | Sí |

---

## 5. Confirmación

Este documento es una propuesta. No se aplicó ninguna decisión ni se modificó ningún sistema.
