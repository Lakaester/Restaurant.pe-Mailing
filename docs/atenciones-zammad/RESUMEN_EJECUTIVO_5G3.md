# RESUMEN EJECUTIVO — SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño y auditoría. **No implementado.**

---

## 1. Qué se hizo

Se completó el diseño funcional y técnico del administrador de SLA:

- Panel general.
- Administración de primera respuesta.
- Administración de resolución con 65 combinaciones.
- Excepciones y pendientes.
- Historial y auditoría.
- Alertas.
- Reportes.
- Arquitectura nativa vs. motor propio.
- Reglas de medición en tiempo calendario.
- Corrección de la matriz 5G.2.1.

No se creó ningún SLA, calendario, estado, tabla, atributo ni pantalla.

---

## 2. Decisiones aprobadas

1. Tiempo calendario 24×7.
2. Sin pausas.
3. Resolución al pasar a `closed`.
4. `pending close` no finaliza ni pausa.
5. 65 combinaciones individuales.
6. Nombres con prefijo numérico.
7. Congelar el SLA inicial.
8. Registrar reclasificación sin alterar el SLA.
9. Respaldos provisionales 90 min / 36 h.
10. Cumplimiento ≥ 80 %.
11. Ventana 01/04/2026–31/10/2026.
12. Revisión trimestral.
13. Responsable: pendiente.

---

## 3. Arquitectura recomendada

**Motor nativo de Zammad con ajustes:**

| Componente | Propuesta | Estado |
|---|---|---|
| Calendario | `SLA 24x7`, `America/Lima`, 00:00–23:59 | **PROPUESTA** |
| Estados | `pending reminder` y `pending close` con `ignore_escalation=false` | **PROPUESTA** |
| Políticas | 65 con prefijo numérico | **PROPUESTA** |
| Primera respuesta | 15 min WhatsApp / 1.440 min correo en cada política | **APROBADA** |
| Congelamiento | `sla_policy_key` + trigger | **PROPUESTA** |
| Reapertura | `close_at` + `last_close_at` + contador | **PROPUESTA** |
| Auditoría | `HasAuditLogs` o tabla propia | **PENDIENTE** |
| Alertas | Job propio | **PROPUESTA** |
| Reportes | COSE BI / BFF | **PROPUESTA** |

---

## 4. Comparación nativo vs. propio

| Criterio | Nativo | Propio |
|---|---|---|
| Tiempo calendario | Calendario 24/7 | Por diseño |
| Pausas | Cambiar estados | Control total |
| Precedencia | Alfabética | Definible |
| Congelamiento | Atributo + trigger | Tabla propia |
| Reapertura | `close_at` nativo | Tabla propia |
| Indicadores | Nativos | Desarrollo |
| Mantenimiento | Bajo | Alto |
| Riesgo | Precedencia/condición | Desalineación |

**Recomendación:** nativo, sujeto a validación de los cuatro puntos críticos.

---

## 5. Reglas clave

- Inicio: `created_at`.
- Primera respuesta: primer artículo público de agente; nota interna no cuenta.
- Resolución: `closed`.
- `pending close`: no finaliza.
- Sin pausas.
- Sin reinicio por reasignación, prioridad, grupo o espera.
- Sin SLA ≠ incumplido.
- Cerrado ≠ cumplido.

---

## 6. Corrección de matriz

| Canal | Filas | Sin SLA | Con SLA |
|---|---:|---:|---:|
| WhatsApp | 40 | 2 | 38 |
| Correo | 30 | 3 | 27 |
| **Total** | **70** | **5** | **65** |

La matriz original dice 37/28; el conteo real de filas es 40/30. Se corrige en documento aparte, sin sobrescribir.

---

## 7. Riesgos

| Riesgo | Nivel |
|---|---|
| Calendario 24/7 no se comporta como tiempo calendario | Alto |
| Cambiar `ignore_escalation` afecta tickets en curso | Alto |
| Condición por `categoria_subcategoria` no validada | Alto |
| Congelamiento se sobrescribe | Alto |
| Precedencia alfabética | Medio |
| Auditoría sin anterior/nuevo | Medio |
| Alertas no nativas | Medio |
| Reportes desactivados | Medio |
| 65 políticas difíciles de mantener | Medio |

---

## 8. Funcionalidades verificadas y no verificadas

### Verificadas en código o base

- `first_response_at` se fija con artículo público de agente.
- `close_at` se fija al pasar a `closed`.
- `last_close_at` se actualiza.
- `Sla` usa `calendar.biz`.
- `Sla.for_ticket` ordena por nombre.
- `ignore_escalation` existe y está activo en `pending reminder` y `pending close`.
- `Sla` incluye `HasAuditLogs`.
- Calendario 2 existe con el horario aprobado.
- 0 SLA en la instalación.

### No verificadas

- Que el calendario 24/7 mida tiempo calendario puro.
- Que `ignore_escalation=false` no tenga efectos colaterales.
- Que la condición por `categoria_subcategoria` funcione.
- Que el congelamiento por atributo funcione.
- Que la auditoría guarde anterior/nuevo.
- Que existan alertas nativas con umbrales.
- Que los reportes puedan activarse sin impacto.

---

## 9. Decisiones pendientes

- Responsable administrativo.
- Calendario 24/7.
- Cambio de estados.
- Mecanismo de congelamiento.
- Condición de las políticas.
- Fallback.
- 5 combinaciones sin evidencia.
- 31,1 % fuera de catálogo.
- Umbral por dimensión.
- Alertas.
- Reportes.
- Reaperturas.
- Auditoría.
- Retención.
- Orden de implementación.

---

## 10. Siguiente paso

1. Aprobar las decisiones críticas: calendario 24/7, estados, congelamiento y condición.
2. Ejecutar una prueba controlada con tickets sintéticos.
3. Si la prueba pasa, generar las 65 políticas.
4. Si no pasa, evaluar el motor propio.

No se inicia la implementación sin autorización expresa.

---

## 11. Confirmación

No se modificó código, configuración, estados, calendarios, SLA, tablas, workers, buzones, Zendesk ni COSE. Solo se crearon documentos de diseño.
