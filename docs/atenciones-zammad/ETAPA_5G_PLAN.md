# ETAPA 5G — CIERRE DE BRECHAS Y PREPARACIÓN DEL PILOTO

**Proyecto:** MAILING / C.O.S.E. sobre Zammad 7.2.3
**Fecha de inicio:** 14/11/2026
**Estado:** plan aprobado para ejecución; **sin cambios aplicados todavía**.
**Alcance:** cerrar las brechas P0/P1 identificadas en 5E/5F y dejar Zammad listo para un piloto controlado de correo.

---

## 0. Principios

1. Zammad es la fuente de verdad de tickets y conversaciones.
2. COSE conserva su lógica operativa (dominio, categoría, calificación, QyD, LocalBI, TicketBI).
3. No hay doble escritura sobre un mismo ticket.
4. No se conecta el buzón definitivo de Soporte Especializado en esta etapa.
5. No se toca Zendesk productivo.
6. No se implementa el BFF todavía; primero se cierran datos y configuración.
7. Toda decisión se documenta antes de aplicarla.

---

## 1. Línea base verificada (14/11/2026)

| Elemento | Valor actual | Lectura |
|---|---|---|
| `fqdn` / `http_type` | `localhost:3000` / `http` | No apto para producción |
| Tickets / artículos | 2 / 5 | Piloto |
| Usuarios / grupos | 6 / 3 | Piloto |
| SLA | **0** | No hay política operativa |
| Triggers | 3 definidos, **0 activos** | Sin automatizaciones activas |
| Macros | 1 definida, 1 activa | Revisar contenido |
| Overviews | 13 | 3 personalizadas |
| Reportes | `Report.enabled? = false` | Sin reportes nativos |
| Webhooks | 0 | Sin integraciones salientes |
| Canales | Email::Account 1, Google::Account 1, Email::Notification 2 | Piloto Gmail |
| Delayed::Job | 139 (default 138, blocked 1) | 1 trabajo de correo en `blocked` |
| Trabajos de correo procesables | **0** | Seguro para arrancar worker |
| Calendario | 1: `My Calendar`, `America/Los_Angeles`, L–V 09:00–17:00 | **No coincide** con el negocio |
| Feriados | Vacío | Pendiente |
| `categoria_subcategoria` | `tree_select`, 13 categorías / 65 subcategorías | Correcto |
| Worker | Detenido | No se arranca en esta etapa |

---

## 2. Brechas a cerrar

### P0 — bloquean el reemplazo

| # | Brecha | Estado | Qué falta | Responsable |
|---|---|---|---|---|
| P0-1 | SLA operativo | Abierta | Política, metas, calendario, feriados | Negocio + TI |
| P0-2 | Calendario laboral | Abierta | Crear calendario `America/Lima` con horario real | TI/Negocio |
| P0-3 | Condiciones/acciones de 6 disparadores | Abierta | Inventario Zendesk | Administrador Zendesk |
| P0-4 | Condiciones/acciones de 2 automatizaciones | Abierta | Inventario Zendesk | Administrador Zendesk |
| P0-5 | Buzón exclusivo de Soporte Especializado | Abierta | Localizarlo y asociarlo a grupo | TI |
| P0-6 | Canales activos y volumen | Abierta | Inventario Zendesk | Administrador Zendesk |
| P0-7 | Volumen e histórico | Abierta | Conteos y exportación | Administrador Zendesk |
| P0-8 | HTTPS/subdominio | Abierta | Subdominio y certificado | TI |
| P0-9 | Backups automáticos | Abierta | Política y prueba de restauración | TI |
| P0-10 | SMTP | Abierta | Servidor y credenciales | TI |
| P0-11 | Worker supervisado | Abierta | systemd/supervisor | TI |
| P0-12 | Continuidad del BI | Abierta | ETL/BFF desde Zammad | TI + COSE |
| P0-13 | Migración histórica | Abierta | Decisión importar vs empezar limpio | Negocio |

### P1 — necesarias para operar

| # | Brecha | Estado | Qué falta |
|---|---|---|---|
| P1-1 | Macros y respuestas predefinidas | Abierta | Inventario y decisión |
| P1-2 | Reglas de asignación/prioridad/escalamiento | Abierta | Inventario Zendesk |
| P1-3 | Vistas de Soporte Especializado | Abierta | Inventario y réplica en overviews |
| P1-4 | Informes de jefatura | Abierta | Listado y definición de “quintiles” |
| P1-5 | Opciones de campos desplegables | Abierta | Catálogos de Categoría, PAÍS, Nivel/Tipo de resolución |
| P1-6 | Lista completa de estados y prioridades | Abierta | Captura completa |
| P1-7 | CSAT | Abierta | Decisión y diseño |
| P1-8 | Mapeo de estados/prioridades/categorías | Abierta | Documento de mapeo |

---

## 3. Workstreams

### WS-1 — Inventario Zendesk (bloqueado por acceso)

**Objetivo:** completar condiciones, acciones, estado y alcance de disparadores/automatizaciones; SLA; vistas; informes; canales activos; volumen.

**Entregable:** actualización de `CATALOGO_AUTOMATIZACIONES_ZENDESK.md`, `INVENTARIO_CANALES_Y_SLA_ZENDESK.md`, `INVENTARIO_REPORTES_Y_PRODUCTIVIDAD_ZENDESK.md`.

**Dependencia:** administrador de Zendesk.

### WS-2 — Buzón dedicado (bloqueado por TI)

**Objetivo:** localizar el buzón exclusivo de Soporte Especializado, confirmar dirección, grupo y forma de acceso; no conectarlo todavía.

**Entregable:** ficha del buzón y plan de migración desde el piloto.

**Dependencia:** TI.

### WS-3 — Configuración de Zammad (requiere autorización de escritura)

**Objetivo:** crear calendario y SLA; ajustar overviews; preparar SMTP/HTTPS/backups/worker.

**Propuesta de calendario:**

| Campo | Valor |
|---|---|
| Nombre | Soporte Especializado |
| Zona horaria | `America/Lima` (pendiente confirmar) |
| Lunes a viernes | 09:00–23:00 |
| Sábados y domingos | 09:00–20:00 |
| Feriados | Pendiente de cargar |
| Predeterminado | Sí, si se aprueba |

**Propuesta de SLA:**

| Campo | Valor |
|---|---|
| Nombre | Soporte en Línea |
| Condición | Grupo Soporte Especializado |
| Primera respuesta | 1440 min (24 h) para correo, según COSE |
| Resolución | 1440 min (24 h), **provisional** |
| Calendario | Soporte Especializado |
| Escalamiento | Pendiente de decidir |

**Nota:** crear el calendario y el SLA son **escrituras**. No se aplican hasta autorización explícita.

### WS-4 — CSAT (decisión)

**Opciones:**

1. No implementar en el primer lanzamiento.
2. Implementar con atributo + trigger + formulario externo.
3. Implementar con desarrollo propio en COSE.
4. Evaluar extensión/paquete de Zammad.

**Recomendación:** fase posterior al piloto, salvo que el negocio lo considere P0.

### WS-5 — Continuidad del BI

**Problema:** COSE lee `public.v_unificado_norm`; si Zammad reemplaza a Zendesk, la vista debe alimentarse desde Zammad o desde un ETL/BFF.

**Opciones:**

1. ETL batch desde la API de Zammad a PostgreSQL de COSE.
2. BFF que exponga métricas y COSE las consuma.
3. Mantener la vista histórica y agregar una nueva fuente Zammad.
4. Replicar reportes en Zammad (no recomendado para Explore-like).

**Recomendación:** opción 1 o 2; decidir antes del piloto.

### WS-6 — Migración histórica

**Opciones:**

1. Importar tickets/artículos/adjuntos de Zendesk a Zammad con el importador nativo.
2. Importar solo metadatos y mantener el histórico en Zendesk como archivo.
3. Empezar limpio y conservar Zendesk en solo lectura.

**Recomendación:** dry-run con el importador nativo antes de decidir; no ejecutar importación masiva sin export real y ventana de mantenimiento.

### WS-7 — Mapeo de estados/prioridades/categorías

**Objetivo:** documentar la tabla de conversión y las reglas de transición.

**Base:** `MAPEO_COSE_ZAMMAD.md` + evidencia 5F.1.

**Corrección:** el catálogo es **13/65**, no 15/80; Zammad usa `categoria_subcategoria` (`tree_select`).

### WS-8 — BFF

**Estado:** diseño 5D propuesto; no implementado.

**Decisión:** implementar después de cerrar P0 y definir el alcance del piloto.

---

## 4. Decisiones que requieren aprobación

| # | Decisión | Opciones | Impacto |
|---|---|---|---|
| D-1 | Alcance del piloto | Solo correo / correo + WhatsApp | Define esfuerzo y canales |
| D-2 | ¿Dónde vive el SLA operativo? | Zammad / COSE / ambos | Evita duplicidad |
| D-3 | Zona horaria y feriados | `America/Lima` + calendario | SLA correcto |
| D-4 | Meta de primera respuesta | 24 h / otra | Paridad con COSE |
| D-5 | Meta de resolución | 24 h provisional / por categoría | Paridad real |
| D-6 | CSAT | Ahora / después / no | Alcance |
| D-7 | Migración histórica | Importar / archivo / limpio | Trazabilidad |
| D-8 | Continuidad BI | ETL / BFF / mixto | Reportes |
| D-9 | BFF | Ahora / después del piloto | Arquitectura |
| D-10 | Autorización de escritura en Zammad | Sí / No | Permite configurar calendario/SLA |

---

## 5. Plan de ejecución propuesto

### Fase 5G.0 — Decisiones (sin cambios)

- Revisar este plan.
- Aprobar D-1 a D-10.
- Confirmar si se autoriza escritura en Zammad para calendario/SLA.

**Salida:** decisiones firmadas.

### Fase 5G.1 — Configuración base de Zammad (con autorización)

- Crear calendario `Soporte Especializado`.
- Crear SLA `Soporte en Línea`.
- Revisar overviews.
- No activar triggers.
- No arrancar worker.

**Salida:** calendario y SLA creados; captura de verificación.

### Fase 5G.2 — Infraestructura (TI)

- Subdominio/HTTPS.
- SMTP.
- Backups automáticos.
- Supervisor del worker.
- Elasticsearch (si se decide).

**Salida:** entorno estable.

### Fase 5G.3 — Inventario Zendesk (administrador)

- Completar triggers/automatizaciones.
- SLA policies.
- Vistas e informes.
- Canales activos y volumen.
- Buzón dedicado.

**Salida:** inventario cerrado.

### Fase 5G.4 — Datos y BI

- Decidir migración.
- Dry-run del importador.
- Diseñar ETL/BFF para `v_unificado_norm`.

**Salida:** plan de datos aprobado.

### Fase 5G.5 — Piloto

- Correo real controlado.
- Criterios de aceptación.
- Métricas.
- Rollback.

**Salida:** piloto aceptado.

---

## 6. Criterios de aceptación del piloto

| # | Criterio | Cómo se verifica |
|---|---|---|
| 1 | Recepción de correo | Ticket creado en grupo correcto |
| 2 | Respuesta con firma | Artículo enviado, `delivery_status=success` |
| 3 | Seguimiento en el mismo ticket | Sin duplicado |
| 4 | Sin respuestas automáticas | 0 triggers activos no aprobados |
| 5 | SLA calculado | Primer response/resolution dentro del calendario |
| 6 | Categoría/dominio | Persisten y filtran |
| 7 | Adjuntos | Subida/descarga con control de acceso |
| 8 | Auditoría | Historial completo |
| 9 | BI | Métricas actualizadas |
| 10 | Rollback | Procedimiento probado |

---

## 7. Restricciones vigentes

- No conectar el buzón definitivo.
- No modificar Zendesk.
- No activar triggers ni automatizaciones sin inventario.
- No arrancar el worker hasta autorización.
- No implementar el BFF todavía.
- No ejecutar migraciones masivas.
- No cambiar `fqdn`/OAuth sin TI.
- No tocar COSE.

---

## 8. Primer paso inmediato

**Paso 1:** aprobar D-1 a D-10 y autorizar (o no) la creación del calendario y SLA en Zammad.

Sin esa autorización, la 5G queda en planificación y línea base; no se aplican cambios.

---

## 9. Ejecución 5G.1 — Calendario Soporte Especializado

**Fecha de ejecución:** 14/11/2026
**Autorización:** crear únicamente un calendario. Sin SLA, sin feriados, sin predeterminado.
**Estado:** **completado**.

### 9.1 Verificación previa

- No existía un calendario con nombre `Soporte Especializado`.
- El único calendario existente era `My Calendar` (ID 1, `America/Los_Angeles`, predeterminado).
- `Sla.count = 0`.
- `Calendar.count = 1`.

### 9.2 Creación

| Campo | Valor |
|---|---|
| ID | **2** |
| Nombre | `Soporte Especializado` |
| Zona horaria | `America/Lima` |
| Predeterminado | `false` |
| Feriados | `{}` (no definidos) |
| Lunes a viernes | 09:00–23:00 |
| Sábados y domingos | 09:00–20:00 |

### 9.3 Verificación posterior

| Comprobación | Resultado |
|---|---|
| Registro consultado de nuevo | ✅ ID 2, nombre y zona horaria correctos |
| Horarios L–V | ✅ 09:00–23:00 |
| Horarios S–D | ✅ 09:00–20:00 |
| `business_hours_to_hash` | ✅ Los 7 días con horario |
| `Calendar#biz` | ✅ Cálculo válido |
| `My Calendar` modificado | ❌ No; atributos idénticos |
| Calendario predeterminado | ✅ Sigue siendo `My Calendar` (ID 1) |
| SLA creado/modificado | ❌ No; `Sla.count = 0` |
| Triggers activos | ✅ 0 (sin cambios) |
| Macros | ✅ 1 (sin cambios) |
| Usuarios / grupos | ✅ 6 / 3 (sin cambios) |
| Canales | ✅ Sin cambios |
| Total calendarios | 2 (antes 1) |

### 9.4 Resultado

El calendario `Soporte Especializado` (ID 2) queda creado y verificado. No se creó ningún SLA, no se cargaron feriados y no se cambió el calendario predeterminado.

**Siguiente paso:** autorización separada para crear el SLA `Soporte en Línea` usando este calendario.
