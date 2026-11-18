# DECISIONES PENDIENTES — 5G.4.2

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.2
**Fecha:** 16/11/2026
**Modo:** diseño.
**Estado:** ninguna decisión de este documento está aplicada.

---

## 1. Decisiones ya aprobadas (5G.3)

Se mantienen vigentes y no se reabren:

| ID | Decisión |
|---|---|
| A-01 | Tiempo calendario 24×7 |
| A-02 | Ningún estado pendiente pausa el SLA |
| A-03 | La resolución finaliza en `closed` |
| A-04 | `pending close` no finaliza ni pausa |
| A-05 | 65 combinaciones individuales |
| A-06 | Nombres con prefijo numérico |
| A-07 | Congelar el SLA inicial |
| A-08 | Registrar reclasificación sin alterar el SLA |
| A-09 | Respaldos provisionales 90 min / 36 h |
| A-10 | Cumplimiento ≥ 80 % |
| A-11 | Ventana 01/04/2026–31/10/2026 |
| A-12 | Revisión trimestral |
| A-13 | Responsable administrativo — **pendiente** |

---

## 2. Decisiones nuevas

### D-5G42-01 — Mecanismo de captura inicial

**Situación.** El webhook requiere trigger y worker. El sondeo no requiere nada y además es el único que ve la confirmación de envío.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Solo sondeo por API |
| B | Híbrido: webhook + sondeo |
| C | Solo webhook |

**Recomendación:** A para la primera fase; B más adelante si se exige latencia menor a 1 minuto.

**Justificación:** evita activar worker y crear triggers; cubre la entrega; no modifica Zammad.

**Estado:** PENDIENTE.

---

### D-5G42-02 — Criterio de primera respuesta

**Situación.** El criterio aprobado en 5G.3 ("respuesta pública de agente") no exige envío. La evidencia muestra que se puede marcar una respuesta que nunca se envió.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Mantener el criterio actual (solo artículo público) |
| B | Exigir envío confirmado (`delivery_status=success`) |
| C | Exigir recepción confirmada (solo posible en WhatsApp) |

**Recomendación:** B, con C cuando el canal lo permita.

**Impacto:** cambia la definición funcional aprobada. Requiere aprobación explícita.

**Estado:** PENDIENTE.

---

### D-5G42-03 — Nivel de confirmación por canal

**Situación.** El correo solo confirma aceptación SMTP. WhatsApp confirma entrega y lectura.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Correo: aceptado. WhatsApp: aceptado |
| B | Correo: aceptado. WhatsApp: entregado |
| C | Ambos: entregado, y correo queda sin medición |

**Recomendación:** B.

**Estado:** PENDIENTE.

---

### D-5G42-04 — Alternativa de ciclos en reaperturas

**Situación.** Ver `DISENO_CICLOS_RESOLUCION_SLA_5G4_2.md`.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Nuevo ciclo con nuevo compromiso; ciclo 1 es la métrica oficial |
| B | Sin nuevo compromiso; solo se registra la reapertura |

**Recomendación:** A, con el ciclo 1 como métrica oficial.

**Estado:** PENDIENTE — **crítica**.

---

### D-5G42-05 — Primera respuesta en ciclos posteriores

**Situación.** Un ticket reabierto no tiene una "primera respuesta" natural.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | No medir primera respuesta en ciclos > 1 |
| B | Medir "primera respuesta del ciclo" |

**Recomendación:** A.

**Estado:** PENDIENTE.

---

### D-5G42-06 — Persistencia de la política aplicada

**Situación.** Si el BFF pierde su base, el compromiso no se puede reconstruir con exactitud salvo que la política aplicada esté persistida en otro lugar.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Solo en el BFF, con respaldo diario |
| B | BFF + atributo en Zammad |
| C | BFF + etiqueta en Zammad |
| D | BFF + almacenamiento externo (S3, base aparte) |

**Recomendación:** A + D. **No** usar B ni C, porque implican escribir en Zammad.

**Estado:** PENDIENTE.

---

### D-5G42-07 — Frecuencia de sondeo

**Opciones:** 30 s, 1 min, 5 min.

**Recomendación:** 1 min para tickets abiertos; 5 min para cerrados.

**Estado:** PENDIENTE.

---

### D-5G42-08 — Ventana de solapamiento

**Opciones:** 5, 15, 30 min.

**Recomendación:** 15 min.

**Estado:** PENDIENTE.

---

### D-5G42-09 — Reconciliación completa

**Opciones:** diaria, semanal, mensual.

**Recomendación:** diaria, fuera del horario de mayor carga.

**Estado:** PENDIENTE.

---

### D-5G42-10 — Retención de eventos

**Opciones:** 1, 2, 5 años, permanente.

**Recomendación:** 2 años para eventos; permanente para compromisos y ciclos.

**Estado:** PENDIENTE.

---

### D-5G42-11 — Alertas

**Situación.** No existe mecanismo nativo verificado con umbrales.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Solo indicadores, sin alerta proactiva |
| B | Alertas por correo |
| C | Alertas internas + webhook |

**Recomendación:** C, con umbrales 75 % y 90 %.

**Estado:** PENDIENTE.

---

### D-5G42-12 — Cinco combinaciones sin evidencia

Se mantiene lo aprobado en 5G.3: sin SLA hasta nueva evidencia. **PENDIENTE** la decisión definitiva (sin SLA, respaldo provisional o revisión manual).

---

### D-5G42-13 — 31,1 % fuera de catálogo

Se mantiene lo aprobado en 5G.3 como respaldo provisional. **PENDIENTE** la decisión de producción.

---

### D-5G42-14 — Responsable del catálogo (A-13)

**PENDIENTE.** Sin responsable no hay mantenimiento de las 65 políticas.

---

### D-5G42-15 — Credencial de lectura de Zammad

**Situación.** El BFF necesita leer la API.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Token de API de un usuario dedicado con rol de solo lectura |
| B | Token del administrador |
| C | Usuario y contraseña |

**Recomendación:** A. Nunca B.

**Estado:** PENDIENTE.

---

### D-5G42-16 — Motor nativo de Zammad

**Situación.** La instalación tiene 0 SLA y `ignore_escalation` sin cambios.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Dejar el motor nativo inactivo |
| B | Configurarlo en paralelo |

**Recomendación:** A. Mantener 0 SLA y no tocar `ignore_escalation`.

**Estado:** PENDIENTE de confirmación formal.

---

### D-5G42-17 — Worker de Zammad

**Situación.** El worker está detenido.

**Opciones.**

| Opción | Descripción |
|---|---|
| A | Mantenerlo detenido |
| B | Activarlo |

**Recomendación:** A durante el piloto del motor propio. Activarlo solo si se aprueba el modo híbrido.

**Estado:** PENDIENTE.

---

## 3. Resumen

| ID | Decisión | Prioridad | Recomendación |
|---|---|---|---|
| D-5G42-01 | Mecanismo de captura | **Crítica** | Solo sondeo |
| D-5G42-02 | Primera respuesta | **Crítica** | Exigir envío |
| D-5G42-03 | Nivel de confirmación | Alta | Correo aceptado / WhatsApp entregado |
| D-5G42-04 | Ciclos | **Crítica** | Alternativa A |
| D-5G42-05 | Primera respuesta en ciclos | Media | No medir |
| D-5G42-06 | Persistencia de política | Alta | BFF + externo |
| D-5G42-07 | Frecuencia de sondeo | Media | 1 min |
| D-5G42-08 | Solapamiento | Baja | 15 min |
| D-5G42-09 | Reconciliación completa | Baja | Diaria |
| D-5G42-10 | Retención | Baja | 2 años |
| D-5G42-11 | Alertas | Media | Internas + webhook |
| D-5G42-12 | 5 combinaciones | Alta | Ya aprobado: sin SLA |
| D-5G42-13 | 31,1 % fuera de catálogo | Alta | Provisional |
| D-5G42-14 | Responsable | Alta | Designar |
| D-5G42-15 | Credencial | Alta | Token de solo lectura |
| D-5G42-16 | Motor nativo | Media | Inactivo |
| D-5G42-17 | Worker | Media | Detenido |

---

## 4. Confirmación

Ninguna decisión fue aplicada. No se modificó ningún sistema.
