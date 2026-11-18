# RESUMEN EJECUTIVO — SLA EXCLUSIVO EMAIL — 5G.4.4

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.4 — Corrección de alcance: SLA exclusivo Email
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Resultado:** cinco documentos de corrección. **Cero cambios técnicos.**

---

## 1. Alcance exclusivo Email: confirmado

| Dentro del alcance | Fuera del alcance |
|---|---|
| Correo electrónico en Zammad | WhatsApp |
| Motor SLA propio en el BFF | WHATMETA |
| Políticas de resolución por categoría y subcategoría | WHATICKET |
| Primera respuesta única de 24 h | Mensajería instantánea |
| Datos históricos de Zendesk (correo) | Cualquier otro canal |

**Consecuencias:**

- No hay SLA de primera respuesta por WhatsApp.
- No hay metas de resolución de WhatsApp.
- No hay sondeo diferenciado por canal.
- No hay eventos ni columnas de entrega de WhatsApp.
- La matriz oficial pasa de 70 filas a **30 filas, todas de correo**.

**Trazabilidad:** la evidencia histórica de WhatsApp, WHATMETA y WHATICKET **no se borra**. Se conserva en los documentos de 5G.2 a 5G.4.3, que no se editaron. La precedencia la fija `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md`.

---

## 2. Matriz oficial de resolución Email

**Fuente:** `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` (5G.2.1), filas `CORREO`, con la corrección de conteo de `CORRECCIONES_MATRIZ_SLA_5G2_1.md`. **Ningún valor fue recalculado.**

| Concepto | Valor |
|---|---:|
| Filas Email | **30** |
| Con SLA | **27** |
| Sin evidencia suficiente | **3** |
| Tickets con SLA asignable | **2.087** |
| Base Email con subcategoría homologada | **2.109** |
| Cobertura interna | **98,96 %** |
| Rango de metas | 24 h a 120 h |

### Distribución

| Meta | Combinaciones |
|---|---:|
| 24 h | 7 |
| 36 h | 6 |
| 48 h | 5 |
| 72 h | 6 |
| 96 h | 2 |
| 120 h | 1 |
| **Total** | **27** |

### Las 3 combinaciones sin evidencia

| Categoría | Subcategoría | n |
|---|---|---:|
| FACTURACION ELECTRONICA | Error FE por duplicidad | 9 |
| INTEGRACIONES | Solicitud de integracion sistemas contables | 9 |
| INTEGRACIONES | Error integracion | 4 |

Quedan **sin SLA** y fuera del denominador de cumplimiento, con motivo `insufficient_evidence`. No se rellenan con el respaldo de 36 h, porque el respaldo es para subcategorías **fuera de catálogo**, no para combinaciones conocidas con muestra insuficiente.

### Verificación de integridad

| Comprobación | Resultado |
|---|---|
| Suma de N de las 30 filas | 2.109 ✓ |
| Suma de N de las 27 con SLA | 2.087 ✓ |
| Suma de N de las 3 sin SLA | 22 ✓ |
| Todos los SLA son escalones de la escalera | 27 de 27 ✓ |
| Ningún SLA inferior a su P75 | 27 de 27 ✓ |
| Ningún salto de más de un escalón | 27 de 27 ✓ |

---

## 3. P75 confirmado como criterio estadístico

| Regla | Estado |
|---|---|
| Criterio = P75 de la propia combinación | **Confirmado** |
| Redondeo = primer escalón ≥ P75 | **Confirmado** |
| P75 no se sustituye por mediana | **Confirmado** |
| P75 no se sustituye por promedio | **Confirmado** |
| No se usa P90 | **Confirmado** |
| No se agregan subcategorías ni canales | **Confirmado** |
| n < 10 no tiene SLA | **Confirmado** |

**Prueba incluida en la matriz:** si se usara la mediana, las metas serían entre 5× y 8× más cortas. Ejemplo: `FE / Ajustes FE` tiene mediana 171 min, P75 1.111,2 min y meta oficial 1.440 min. El promedio (912,9) queda por debajo del P75 en todos los casos revisados.

---

## 4. Diferencias respecto de 5G.4.3

| Tema | 5G.4.3 | 5G.4.4 |
|---|---|---|
| Canales | WhatsApp y correo | **Solo correo** |
| Políticas con SLA | 65 | **27** |
| Combinaciones sin evidencia | 5 | **3** |
| Primera respuesta | 15 min WhatsApp / 24 h correo | **24 h correo, única** |
| Criterio de primera respuesta | WhatsApp por aceptación; correo por confirmación | **Confirmación de envío, único criterio** |
| Sondeo | 1 min crítico / 5 min resto | **5 min general + 2 min en ventana de 4 h** |
| Eventos de entrega | `accepted`, `delivered`, `read` | **`confirmed`, `failed`** |
| Columnas de entrega | `delivered_at`, `read_at`, `external_message_id` | **Eliminadas** |
| Respaldos | WhatsApp 90 min y correo 36 h | **Solo correo 36 h** |
| Modelo de datos | 9 tablas | **9 tablas**, 3 columnas menos y dominios reducidos |
| Decisiones pendientes | 17 | **12 nuevas, 4 cerradas, 6 heredadas** |
| Seguridad | Incluía teléfono WhatsApp | **Sin datos de mensajería** |

**Lo que no cambió:** arquitectura de motor propio, cero SLA nativos, calendario 24/7, inicio en `created_at`, fin en el primer `closed`, congelamiento al clasificar, reclasificación sin efecto, ≥ 80 %, ventana estadística y método P75.

---

## 5. Ajustes en sondeo y modelo de datos

### 5.1 Sondeo

**Hallazgo que justifica el cambio:** el motor mide con marcas de tiempo de Zammad (`created_at`, `delivery_status_date`, `close_at`), no con la hora de detección. Por tanto, la frecuencia de sondeo **no altera el valor medido**; solo altera la latencia de alerta y de cierre.

| Cadencia | Latencia sobre una meta de 24 h | Carga relativa |
|---|---:|---:|
| 1 minuto | 0,07 % | 5× |
| 2 minutos | 0,14 % | 2,5× |
| **5 minutos** | **0,35 %** | **1×** |

**Recomendación:** 5 minutos general, 2 minutos para tickets con primera respuesta pendiente y vencimiento a menos de 4 h.

### 5.2 Carga estimada (solo Email)

**ESTIMACIÓN**, no medida en esta instalación.

| Tickets Email activos | Modificados por ciclo de 5 min | Peticiones por ciclo | Por minuto |
|---|---:|---:|---:|
| 100 | 2 | ≈ 5 | ≈ 1 |
| 1.000 | 50 | ≈ 67 | ≈ 13 |
| 10.000 | 1.000 | ≈ 1.306 | ≈ 261 |

Con 1 minuto, las cifras se multiplicarían por 5.

### 5.3 Modelo de datos

Se **mantienen las 9 tablas**. Cada una tiene función propia y ninguna queda vacía en el alcance Email.

| Cambio | Detalle |
|---|---|
| Columnas eliminadas | `delivered_at`, `read_at`, `external_message_id` en `sla_article_delivery` |
| Dominio reducido | `delivery_state` de 5 a 3 valores: `sin_estado`, `aceptado`, `fallido` |
| Dominio restringido | `channel = 'email'` en política y compromiso |
| Tipos de divergencia | Se añade `late_classification`; se mantienen 6 |
| Eventos | De 14 a 11 obligatorios; se eliminan `delivered` y `read` |

### 5.4 Detección de la confirmación de envío

**Verificado en código:**

| Paso | Referencia |
|---|---|
| El job de correo guarda `delivery_status = success` y `delivery_status_date` | `app/jobs/ticket_article_communicate_email_job.rb` 103-108 |
| El fallo guarda `delivery_status = fail` | idem, 142-151 |
| Cada intento incrementa `delivery_retry`; tras 3 reintentos el fallo es definitivo | idem, 34-35 y 154 |
| Guardar el artículo dispara `after_commit :ticket_touch` | `app/models/ticket/article.rb` 49, 472-474 |
| La API expone `preferences` con `delivery_status` | `app/models/ticket/article/assets.rb` 47 |
| Los webhooks **no** ven cambios de artículo | `lib/transaction_dispatcher.rb` 148-150 |

**Qué prueba `success`:** que el servidor de salida aceptó el mensaje. **No** prueba que llegó a la bandeja ni que se leyó. Es el máximo que el correo permite y coincide con el requisito, pero no debe presentarse como "correo entregado".

**Pendiente crítico:** demostrar que la confirmación eleva `ticket.updated_at`. Está soportado por código, pero no probado con datos. Es la prueba 0.6 de la fase 0.

### 5.5 Ventaja inesperada del alcance Email

**Verificado:** `app/models/ticket/sets_close_time.rb` 14-32 fija `close_at` en el **primer** cierre y no lo reescribe; `last_close_at` se actualiza en cada transición. Eso significa que Zammad ya conserva la marca del primer cierre, que es exactamente lo que exige la regla de resolución. No hay que reconstruirla desde el historial en el caso normal.

---

## 6. Decisiones pendientes

### Críticas

| ID | Decisión | Recomendación |
|---|---|---|
| DP-E-01 | Aprobar la matriz de 27 políticas Email | Aprobar sin cambiar valores |
| DP-E-04 | Borde de 24 h: `≤ 1.440` o `< 1.440` | `≤ 1.440` |
| DP-E-05 | Tratamiento de `merged` | Divergencia, no cierre |
| DP-02 / REA-02 | Alternativa A de ciclos en reapertura | Aprobar A |
| DP-04 | Responsable administrativo del catálogo | Designar |

### Altas

| ID | Decisión | Recomendación |
|---|---|---|
| DP-E-02 | Respaldo 36 h solo para fuera de catálogo | Aprobar |
| DP-E-03 | Cadencia de sondeo | 5 min + banda de 2 min |
| DP-E-06 | `fail` definitivo solo tras 3 reintentos | Aprobar |
| DP-E-07 | Las 3 sin evidencia: sin SLA, revisión a 90 días | Aprobar |
| DP-E-08 | Medir el volumen Email fuera de catálogo | Obligatorio antes de fase 2 |
| DP-07 | Persistencia de la política si cae el BFF | BFF + respaldo externo |

### Medias

| ID | Decisión |
|---|---|
| DP-E-09 | Nivel de reporte: global y por categoría |
| DP-E-10 | Mantener `channel` con `CHECK ('email')` |
| DP-E-11 | Clasificación tardía |
| DP-E-12 | No almacenar cuerpos de correo |

---

## 7. Riesgos

| Riesgo | Nivel | Mitigación |
|---|---|---|
| La confirmación de envío no eleva `updated_at` | **Alto** | Prueba 0.6; barrido acotado de artículos sin confirmar |
| `success` se interpreta como "entregado" | **Alto** | Documentar que es aceptación de envío |
| Volumen fuera de catálogo en Email desconocido | **Alto** | Medir antes de la fase 2; respaldo marcado `provisional` |
| El respaldo de 36 h domina la medición | **Alto** | Medir su peso y revisar el catálogo |
| 27 políticas con base de 2.109 tickets | Medio | Confianza declarada por fila; revisión a 90 días de las 8 BAJA |
| Documentos antiguos citados como vigentes | Medio | Anexo de precedencia explícito |
| Ciclos en reapertura sin aprobar | Medio | El motor no genera vencimientos de reapertura hasta DP-02 |
| Reapertura automática del ticket por fallo de envío | Medio | Zammad crea una nota interna y lo deja en `default_follow_up`; se trata como reapertura real |
| Paginación por desplazamiento | Medio | Orden estable, solapamiento, reconciliación |

---

## 8. Plan ajustado

| Fase | Ajuste respecto de 5G.4.3 |
|---|---|
| 0 | Se elimina la verificación del canal WhatsApp; se mantiene la prueba 0.6 |
| 1 | Ingesta solo de correo; cadencia 5 min |
| 2 | Carga de **27** políticas, no 65; medir fuera de catálogo |
| 3 | Sin cambios, salvo el ejemplo de cálculo, que pasa a correo |
| 4 | Solo correo con `delivery_status = success`; sin rama WhatsApp |
| 5 | Reportes solo Email |
| 6 | Sin cambios |
| 7 | Webhooks siguen siendo opcionales y **no** resuelven la entrega |

**Estado:** ninguna fase autorizada.

---

## 9. Documentos de esta etapa

| # | Documento |
|---:|---|
| 1 | `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` |
| 2 | `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md` |
| 3 | `ARQUITECTURA_MOTOR_SLA_EMAIL_5G4_4.md` |
| 4 | `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` |
| 5 | `RESUMEN_EJECUTIVO_EMAIL_5G4_4.md` |

---

## 10. Confirmación de ausencia de modificaciones técnicas

| Restricción | Cumplimiento |
|---|---|
| No modificar código | **Cumplido** |
| No modificar base de datos | **Cumplido** |
| No modificar configuración de Zammad | **Cumplido** |
| No modificar calendarios | **Cumplido** |
| No modificar SLA nativos | **Cumplido.** Siguen en 0 |
| No modificar triggers | **Cumplido.** Siguen en 3, ninguno activo |
| No modificar webhooks | **Cumplido.** Siguen en 0 |
| No modificar usuarios ni permisos | **Cumplido.** 6 usuarios, sin cambios |
| No modificar buzones | **Cumplido** |
| No crear credenciales | **Cumplido** |
| No modificar Zendesk | **Cumplido** |
| No modificar COSE | **Cumplido** |
| No iniciar workers ni servicios | **Cumplido.** Worker detenido |
| No sobrescribir documentos anteriores | **Cumplido.** 48 documentos previos intactos |

Las únicas escrituras fueron los cinco documentos nuevos.

---

## 11. Próxima decisión

Aprobar, como mínimo:

1. **DP-E-01:** matriz oficial de 27 políticas Email.
2. **DP-E-04:** borde exacto de la meta de 24 h.
3. **DP-E-03:** cadencia de sondeo de 5 minutos con banda de 2.
4. **DP-E-08:** medir el volumen Email fuera de catálogo.

Después de eso, el diseño queda listo para autorizar la fase 0.
