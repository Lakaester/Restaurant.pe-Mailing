# DISEÑO DE INTERFAZ — ADMINISTRADOR SLA 5G.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No implementado.**

---

## 1. Principios de interfaz

1. Separar primera respuesta y resolución.
2. Mostrar siempre el estado de la política: activa, inactiva o pendiente.
3. No ocultar las 5 combinaciones sin SLA.
4. Toda edición debe pedir motivo y quedar auditada.
5. El panel debe ser legible para supervisor y administrador.
6. No mostrar valores inventados.

---

## 2. Navegación propuesta

```
Administrador SLA
├── 1. Resumen SLA
├── 2. Primera respuesta
├── 3. Resolución
│   ├── Matriz canal × categoría × subcategoría
│   └── Detalle de política
├── 4. Excepciones y pendientes
├── 5. Historial de cambios
├── 6. Alertas
└── 7. Reportes de cumplimiento
```

---

## 3. Pantalla 1 — Resumen SLA

### 3.1 Tarjetas superiores

| Tarjeta | Contenido |
|---|---|
| Políticas activas | Número y variación |
| Políticas inactivas | Número |
| Canales cubiertos | WhatsApp / Correo |
| Combinaciones cubiertas | 65 / 70 |
| Pendientes | 5 |

### 3.2 Indicadores operativos

| Indicador | Primera respuesta | Resolución |
|---|---|---|
| Dentro del SLA | N | N |
| Próximos a vencer | N | N |
| Incumplidos | N | N |
| Cumplidos | N | N |
| Sin SLA | N | N |
| Cumplimiento | % | % |

### 3.3 Filtros

- Rango de fechas.
- Canal.
- Categoría.
- Subcategoría.
- Grupo.
- Agente.
- Estado.

### 3.4 Gráficos

- Cumplimiento por canal.
- Cumplimiento por categoría.
- Evolución mensual.
- Distribución de estados.

---

## 4. Pantalla 2 — Primera respuesta

### 4.1 Tabla

| Canal | Objetivo | Minutos | Estado | Última modificación | Usuario |
|---|---|---:|---|---|---|
| WhatsApp | < 15 min | 15 | Activa | — | — |
| Correo | < 24 h | 1.440 | Activa | — | — |

### 4.2 Acciones

- Editar objetivo.
- Ver historial.
- Ver tickets afectados.

### 4.3 Modal de edición

Campos:

- Canal (solo lectura).
- Valor actual.
- Valor nuevo.
- Motivo (obligatorio).
- Confirmación.

Validaciones:

- Valor > 0.
- Valor entero.
- Motivo no vacío.
- No puede quedar igual al actual.

---

## 5. Pantalla 3 — Resolución

### 5.1 Matriz

Columnas:

| Columna | Descripción |
|---|---|
| Canal | WhatsApp / Correo |
| Categoría | 13 valores |
| Subcategoría | 65 valores |
| N | Muestra |
| P75 | Percentil |
| Confianza | ALTA / MEDIA / BAJA / INSUFICIENTE |
| SLA | Minutos |
| Estado | Activa / Inactiva / Pendiente |
| Versión | Matriz |
| Acciones | Editar / Historial |

### 5.2 Filtros

- Canal.
- Categoría.
- Subcategoría.
- Confianza.
- Estado.
- Solo pendientes.

### 5.3 Detalle de política

Muestra:

- Nombre de la política.
- Condición.
- `first_response_time`.
- `solution_time`.
- Calendario.
- Origen estadístico.
- Fecha de corte.
- Confianza.
- Historial de cambios.
- Tickets afectados.

### 5.4 Edición

- Cambiar minutos.
- Activar/desactivar.
- Motivo obligatorio.
- Confirmación.
- Registro de auditoría.

### 5.5 Pendientes

Las 5 combinaciones sin evidencia se muestran en una sección aparte:

| Canal | Categoría | Subcategoría | n | Estado |
|---|---|---|---:|---|
| WhatsApp | DEVOLUCIÓN | Solicitud de devolución | 8 | Pendiente |
| WhatsApp | FACTURACIÓN | Activación NV | 9 | Pendiente |
| Correo | FACTURACIÓN | Error FE por duplicidad | 9 | Pendiente |
| Correo | INTEGRACIONES | Integración sistemas contables | 9 | Pendiente |
| Correo | INTEGRACIONES | Error integración | 4 | Pendiente |

No se permite asignar un SLA desde la interfaz sin una decisión explícita.

---

## 6. Pantalla 4 — Excepciones

### 6.1 Reglas

| Escenario | Comportamiento visual |
|---|---|
| Sin categoría | “Sin SLA hasta clasificar” |
| Sin subcategoría | “Sin SLA hasta clasificar” |
| Categoría no homologada | “Respaldo provisional” |
| Subcategoría nueva | “Respaldo provisional” |
| Canal no contemplado | “Sin SLA” |
| Política desactivada | “Sin SLA” |
| Reclasificación | “SLA original conservado” |

### 6.2 Acciones

- Ver tickets afectados.
- Revisar regla.
- Solicitar cambio.

---

## 7. Pantalla 5 — Historial de cambios

### 7.1 Tabla

| Fecha | Usuario | Política | Campo | Anterior | Nuevo | Motivo |
|---|---|---|---|---|---|---|

### 7.2 Filtros

- Fecha.
- Usuario.
- Política.
- Campo.
- Versión.

### 7.3 Exportación

- CSV.
- API.

---

## 8. Pantalla 6 — Alertas

### 8.1 Configuración

| Canal | Primera respuesta | Resolución |
|---|---|---|
| WhatsApp | 75 % | 75 % / 90 % |
| Correo | 75 % | 75 % / 90 % |

### 8.2 Destinatarios

- Agente asignado.
- Supervisor.
- Grupo.

### 8.3 Canales de notificación

- Correo.
- Notificación interna.
- Webhook (futuro).

**HIPÓTESIS:** requiere desarrollo; no se verificó un mecanismo nativo de umbrales.

---

## 9. Pantalla 7 — Reportes

### 9.1 Reportes

- Cumplimiento por canal.
- Cumplimiento por categoría.
- Cumplimiento por subcategoría.
- Productividad por agente.
- Backlog.
- Reincidencias.
- Exportación.

### 9.2 Filtros

- Fecha.
- Canal.
- Categoría.
- Grupo.
- Agente.

### 9.3 Fuente

**PROPUESTA:** COSE BI o BFF. Zammad tiene `Report.enabled? = false`.

---

## 10. Ubicación de cada componente

| Componente | Dónde | Motivo |
|---|---|---|
| Resumen SLA | COSE o BFF | Requiere métricas y filtros |
| Primera respuesta | Zammad Admin o BFF | Configuración de SLA |
| Resolución | Zammad Admin o BFF | 65 políticas |
| Excepciones | BFF | Lógica de respaldo |
| Historial | BFF o tabla propia | Auditoría enriquecida |
| Alertas | BFF/job | No nativo |
| Reportes | COSE BI | Fuente `v_unificado_norm` |

**PROPUESTA:** una interfaz propia en COSE/BFF que consuma `/api/v1/slas` con un token `admin.sla`. La administración nativa de Zammad puede usarse como respaldo.

---

## 11. Componentes reutilizables

- Tabla con filtros.
- Modal de edición con motivo.
- Diff de valores.
- Badge de estado.
- Indicador de confianza.
- Exportador CSV.

---

## 12. Accesibilidad y usabilidad

- Etiquetas claras.
- No usar solo color para el estado.
- Confirmación en cambios destructivos.
- Historial visible.
- Mensajes de error concretos.
- No permitir ediciones sin motivo.

---

## 13. Confirmación

No se implementó ninguna pantalla. Este documento es diseño.
