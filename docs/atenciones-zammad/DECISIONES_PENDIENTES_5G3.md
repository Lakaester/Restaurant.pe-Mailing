# DECISIONES PENDIENTES — SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño.
**Estado:** las decisiones marcadas **APROBADA** ya fueron tomadas. Las demás siguen abiertas.

---

## 1. Decisiones aprobadas

| ID | Decisión | Estado |
|---|---|---|
| A-01 | Tiempo calendario 24×7 | **APROBADA** |
| A-02 | Ningún estado pendiente pausa el SLA | **APROBADA** |
| A-03 | La resolución finaliza en `closed` | **APROBADA** |
| A-04 | `pending close` no finaliza ni pausa | **APROBADA** |
| A-05 | 65 combinaciones individuales | **APROBADA** |
| A-06 | Nombres con prefijo numérico | **APROBADA** |
| A-07 | Congelar el SLA inicial | **APROBADA** |
| A-08 | Registrar reclasificación sin alterar el SLA | **APROBADA** |
| A-09 | Respaldos provisionales 90 min / 36 h | **APROBADA (provisional)** |
| A-10 | Cumplimiento ≥ 80 % | **APROBADA** |
| A-11 | Ventana 01/04/2026–31/10/2026 | **APROBADA** |
| A-12 | Revisión trimestral | **APROBADA** |
| A-13 | Responsable administrativo | **PENDIENTE** |

---

## 2. Decisiones pendientes

### DP-5G3-01 — Responsable administrativo

**Situación.** A-13 quedó pendiente.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Un administrador de Zammad |
| B | Un supervisor de Soporte Especializado |
| C | Un rol compartido entre TI y Soporte |

**Recomendación:** B para la matriz y A para la infraestructura.

**Decisión requerida:** designar nombre y suplente.

---

### DP-5G3-02 — Calendario 24/7

**Situación.** El calendario `Soporte Especializado` (ID 2) cubre 92 de 168 horas. Para tiempo calendario se necesita un calendario 24/7.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Crear `SLA 24x7` con 00:00–23:59 todos los días |
| B | Reutilizar `Soporte Especializado` y escalar los valores |
| C | Motor propio sin calendario |

**Recomendación:** A. Requiere autorización de escritura.

**Decisión requerida:** autorizar la creación del calendario 24/7.

---

### DP-5G3-03 — Cambio de `ignore_escalation`

**Situación.** Hoy `pending reminder` y `pending close` pausan el reloj. Para cumplir A-02 hay que ponerlos en `false`.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Cambiar ambos a `false` |
| B | Cambiar solo `pending reminder` |
| C | No cambiar y usar motor propio |

**Recomendación:** A, en ventana de mantenimiento.

**Decisión requerida:** autorizar el cambio de estados.

---

### DP-5G3-04 — Mecanismo de congelamiento

**Situación.** El motor nativo recalcula el SLA al cambiar la categoría.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Atributo `sla_policy_key` + trigger |
| B | Tabla `sla_ticket_snapshot` |
| C | Addon con `preferences` |

**Recomendación:** A para el piloto.

**Decisión requerida:** elegir y autorizar el desarrollo.

---

### DP-5G3-05 — Condición por `categoria_subcategoria`

**Situación.** No se validó el operador exacto para `tree_select` en condiciones de SLA.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | `is` con el path completo |
| B | `contains` con el path |
| C | Atributo separado `sla_policy_key` |

**Recomendación:** C, coherente con el congelamiento.

**Decisión requerida:** validar con una prueba controlada.

---

### DP-5G3-06 — Política de respaldo

**Situación.** El fallback puede tener tiempos o no.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | `99-FALLBACK` sin tiempos (sin SLA) |
| B | `99-FALLBACK` con 90 min / 36 h |
| C | Dos fallbacks por canal |

**Recomendación:** B, marcado como provisional.

**Decisión requerida:** aprobar el contenido del fallback.

---

### DP-5G3-07 — Las 5 combinaciones sin evidencia

**Situación.** WhatsApp Devolución (8), WhatsApp Activación NV (9), Correo Error FE duplicidad (9), Correo Integración sistemas contables (9), Correo Error integración (4).

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Sin SLA hasta nueva muestra |
| B | Respaldo provisional del canal |
| C | Revisión manual caso a caso |

**Recomendación:** B para el piloto, A para producción.

**Decisión requerida:** elegir.

---

### DP-5G3-08 — 31,1 % fuera de catálogo

**Situación.** 4.842 tickets de servicio no tienen subcategoría oficial.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Respaldo provisional del canal |
| B | Revisar catálogo antes de publicar |
| C | Sin SLA |

**Recomendación:** A en piloto, B antes de producción.

**Decisión requerida:** aceptar cobertura parcial.

---

### DP-5G3-09 — Umbral de cumplimiento por dimensión

**Situación.** El 80 % está aprobado, pero no se definió si es global, por canal o por categoría.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Global |
| B | Por canal |
| C | Por canal y categoría |

**Recomendación:** B para el piloto.

**Decisión requerida:** definir.

---

### DP-5G3-10 — Alertas

**Situación.** No se verificó un mecanismo nativo de umbrales.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Job propio en BFF |
| B | Addon en Zammad |
| C | Solo indicadores nativos, sin alerta proactiva |

**Recomendación:** A.

**Decisión requerida:** autorizar el desarrollo.

---

### DP-5G3-11 — Reportes

**Situación.** `Report.enabled? = false`.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | COSE BI sobre `v_unificado_norm` |
| B | BFF con métricas de Zammad |
| C | Activar reportes de Zammad |

**Recomendación:** B para el piloto, A para producción.

**Decisión requerida:** elegir.

---

### DP-5G3-12 — Reaperturas

**Situación.** `close_at` conserva el primer cierre; `last_close_at` se actualiza.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Usar `close_at` como primer cumplimiento |
| B | Usar `last_close_at` como cumplimiento final |
| C | Reportar ambos |

**Recomendación:** C.

**Decisión requerida:** definir la métrica oficial.

---

### DP-5G3-13 — Auditoría nativa

**Situación.** `Sla` incluye `HasAuditLogs`, pero no se confirmó si guarda anterior/nuevo.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Usar la auditoría nativa |
| B | Tabla propia `sla_policy_audit` |
| C | Ambas |

**Recomendación:** B si la nativa no guarda anterior/nuevo.

**Decisión requerida:** validar la auditoría nativa.

---

### DP-5G3-14 — Retención

**Situación.** No hay política de retención de auditoría, alertas y versiones.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | 5 años |
| B | 2 años |
| C | Permanente |

**Recomendación:** A.

**Decisión requerida:** aprobar.

---

### DP-5G3-15 — Orden de implementación

**Situación.** Hay dependencias entre calendario, estados, políticas y congelamiento.

**Recomendación:**

1. Calendario 24/7.
2. Cambio de `ignore_escalation`.
3. Validación de condición.
4. 65 políticas.
5. Congelamiento.
6. Alertas.
7. Reportes.

**Decisión requerida:** aprobar el orden.

---

## 3. Resumen

| ID | Decisión | Prioridad |
|---|---|---|
| DP-5G3-01 | Responsable | Alta |
| DP-5G3-02 | Calendario 24/7 | **Crítica** |
| DP-5G3-03 | `ignore_escalation` | **Crítica** |
| DP-5G3-04 | Congelamiento | **Crítica** |
| DP-5G3-05 | Condición | **Crítica** |
| DP-5G3-06 | Fallback | Alta |
| DP-5G3-07 | 5 pendientes | Alta |
| DP-5G3-08 | 31,1 % fuera de catálogo | Alta |
| DP-5G3-09 | Umbral por dimensión | Media |
| DP-5G3-10 | Alertas | Media |
| DP-5G3-11 | Reportes | Media |
| DP-5G3-12 | Reaperturas | Media |
| DP-5G3-13 | Auditoría | Media |
| DP-5G3-14 | Retención | Baja |
| DP-5G3-15 | Orden | Alta |

---

## 4. Confirmación

Ninguna decisión pendiente fue aplicada. No se modificó ningún estado, calendario, SLA ni tabla.
