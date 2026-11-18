# PENDIENTES PARA EL ADMINISTRADOR DE ZENDESK

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con las capturas administrativas compartidas por Victor.
**Modo:** solo lectura. Este documento no contiene credenciales ni datos sensibles.

---

## 1. Objetivo

Listar con precisión la información que falta para cerrar el inventario de Zendesk y poder decidir qué replicar en Zammad.

**Regla:** no se comparten contraseñas, tokens ni secretos en este documento. Si se requiere acceso, debe hacerse por un canal seguro y con permisos de solo lectura.

---

## 2. Estado de acceso

| Mecanismo | Estado |
|---|---|
| Acceso administrativo por navegador | No proporcionado en esta sesión |
| API con credenciales de COSE | No autorizada para esta auditoría |
| Exportaciones | No entregadas |
| Capturas/documentación | **Sí, 14/11/2026** (capturas del Centro de administración) |
| Respuestas del negocio | Parciales |

**Solicitud:** acceso de **solo lectura** (rol de visualización o exportaciones), nunca credenciales en el chat.

### 2.1 Evidencia recibida el 14/11/2026

- 10 integrantes visibles en Equipo.
- 3 grupos: Administrador (2), Costumer Support (10, predeterminado), DEV Team Follow Up (3).
- 2 roles de sistema: Administrador (5), Colaborador (0).
- Menú de Canales: Text, Facebook, X, Talk, Email, Web Widget, SDK móvil.
- Dirección de correo visible: `clientes@restaurant.pe`.
- Configuración global de correo (11 preferencias).
- 1 formulario de ticket con 9 campos.
- 12 campos de ticket con ID y tipo.
- 4 estados visibles: Nuevo, Abierto, Pendiente, Resuelto.
- Configuración de comportamiento de tickets (11 preferencias).
- 6 disparadores visibles en la categoría inicial; 0 en “Asignaciones de tickets”.
- 2 automatizaciones visibles en Activas, con el mismo nombre.

### 2.2 Preguntas respondidas parcialmente

| # | Pregunta | Lo que ya se sabe | Lo que falta |
|---|---|---|---|
| A2 | ¿Cuántos agentes/administradores? | 10 integrantes visibles; rol Administrador 5 | Total histórico, usuarios finales |
| A3 | ¿Qué grupos y miembros? | 3 grupos y conteos | Detalle de pertenencia por persona |
| A4 | ¿Qué roles/permisos? | Administrador y Colaborador | Permisos efectivos por grupo |
| B1 | ¿Qué canales están habilitados? | 7 opciones de menú | Cuáles están activos |
| B3 | ¿Dirección/identidad de canal? | `clientes@restaurant.pe` | Buzón dedicado y otros canales |
| B5 | ¿WhatsApp/chat/Talk/redes? | Opciones visibles | Uso real y configuración |
| C1 | ¿Estados/prioridades activos? | 4 estados visibles | Lista completa y prioridades |
| C3 | ¿Campos personalizados? | 12 campos con ID; 3 personalizados | Opciones internas de los desplegables |
| C8 | ¿Adjuntos/límites? | Apartado visible | Configuración interna no inspeccionada |
| D1 | ¿Qué triggers existen? | 6 nombres visibles | Condiciones, acciones, estado |
| D2 | ¿Qué automations existen? | 2 nombres y fechas | Condiciones, acciones, duplicidad |
| F1 | ¿Qué vistas usa Soporte? | No observadas | Listado y condiciones |
| G1 | ¿Se usan organizaciones? | No observado | Uso y modelo |
| H1 | ¿Qué informes usa jefatura? | “Volumen, SLA en quintiles” | Listado y definición |
| I1 | ¿CSAT activo? | Deseo de implementarlo | Estado y configuración |
| J1 | ¿Apps/integraciones? | No observadas | Listado |
| K1 | ¿Autenticación/SSO? | No observado | Configuración |
| L1 | ¿Volumen/histórico? | No observado | Conteos y exportación |

---

## 3. Información faltante por área

> Las tablas siguientes conservan el detalle de las preguntas. Las que ya tienen evidencia parcial están resumidas en §2.2; las que no aparecen allí siguen completamente abiertas.

### A. Plan, licencias y usuarios

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| A1 | ¿Qué plan está contratado? | Captura de facturación/plan | Determina límites y funciones disponibles |
| A2 | ¿Cuántos agentes y administradores hay? | Listado de usuarios | Dimensionar Zammad |
| A3 | ¿Qué grupos existen y quién pertenece a cada uno? | Listado de grupos y miembros | Replicar aislamiento |
| A4 | ¿Qué roles/permisos tiene cada perfil? | Captura de roles | Replicar permisos |
| A5 | ¿Hay restricciones de acceso por IP/SSO? | Captura de seguridad | Replicar seguridad |
| A6 | ¿Cuántos usuarios finales hay? | Conteo | Dimensionar datos |

### B. Canales

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| B1 | ¿Qué canales están habilitados? | Captura de canales | Saber qué migrar |
| B2 | ¿Cuáles se usan realmente? | Volumen por canal | Evitar migrar canales muertos |
| B3 | ¿Qué dirección/identidad tiene cada canal? | Captura (sin credenciales) | Configurar Zammad |
| B4 | ¿Qué grupo recibe cada canal? | Configuración de canales | Enrutamiento |
| B5 | ¿Hay WhatsApp, chat, formularios, Talk o redes? | Captura | Alcance |
| B6 | ¿Cuál es el volumen mensual por canal? | Reporte de volumen | Dimensionar |

### C. Tickets y conversaciones

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| C1 | ¿Qué estados y prioridades están activos? | Captura de configuración | Mapear a Zammad |
| C2 | ¿Qué tipos de ticket se usan? | Captura | Mapear |
| C3 | ¿Qué campos personalizados existen? | Listado con tipo/opciones | Replicar atributos |
| C4 | ¿Se usan tickets relacionados, duplicados, fusión o división? | Captura/uso | Alcance |
| C5 | ¿Se reabren tickets? ¿Con qué regla? | Configuración | Replicar reapertura |
| C6 | ¿Se transfieren tickets entre grupos? | Configuración/uso | Replicar transferencia |
| C7 | ¿Hay reglas de colisión entre agentes? | Configuración | Replicar concurrencia |
| C8 | ¿Qué adjuntos se usan y con qué límite? | Configuración | Dimensionar almacenamiento |

### D. Automatizaciones

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| D1 | ¿Qué triggers existen? | Exportación/captura con nombre, condición, acción, estado | Replicar o descartar |
| D2 | ¿Qué automations existen? | Igual | Replicar o descartar |
| D3 | ¿Qué macros usan los asesores? | Listado | Productividad |
| D4 | ¿Hay reglas de asignación? | Configuración | Enrutamiento |
| D5 | ¿Hay reglas de prioridad? | Configuración | Criticidad |
| D6 | ¿Hay reglas de escalamiento? | Configuración | SLA |
| D7 | ¿Hay reglas de reapertura? | Configuración | Operación |
| D8 | ¿Hay reglas por canal/horario? | Configuración | Operación |
| D9 | ¿Qué notificaciones se envían? | Configuración | Evitar duplicados |

### E. SLA y horarios

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| E1 | ¿Qué políticas SLA existen? | Captura con métricas y metas | Replicar |
| E2 | ¿La política “Soporte en Línea” está en Zendesk? | Captura | Confirmar |
| E3 | ¿Qué horario y zona horaria usa? | Captura | Configurar calendario |
| E4 | ¿Qué feriados están cargados? | Listado | Configurar calendario |
| E5 | ¿Hay pausas/suspensiones? | Configuración | Replicar |
| E6 | ¿Hay escalamiento por SLA? | Configuración | Replicar |
| E7 | ¿Qué grupos/canales afecta? | Configuración | Alcance |

### F. Vistas y productividad

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| F1 | ¿Qué vistas usa Soporte Especializado? | Captura con condiciones/columnas | Replicar overviews |
| F2 | ¿Qué filtros y ordenamientos? | Captura | Replicar |
| F3 | ¿Se usan acciones masivas? | Uso | Alcance |
| F4 | ¿Se requiere tiempo real? | Requisito | Arquitectura |
| F5 | ¿Cómo se evitan colisiones entre agentes? | Configuración | Concurrencia |

### G. Clientes y organizaciones

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| G1 | ¿Se usan organizaciones? | Captura/uso | Modelo de datos |
| G2 | ¿Qué campos de cliente/organización? | Listado | Replicar |
| G3 | ¿Cómo se identifican clientes/dominios? | Reglas | Replicar |
| G4 | ¿Hay duplicados? ¿Cómo se gestionan? | Uso | Calidad |
| G5 | ¿Qué relación hay entre ticket y cliente? | Modelo | Mapeo |

### H. Reportes

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| H1 | ¿Qué informes usa la jefatura? | Listado | Replicar |
| H2 | ¿Se usa Explore? | Captura | Alcance |
| H3 | ¿Qué significa “quintiles”? | Definición | Implementar |
| H4 | ¿Qué dimensiones se usan? | Listado | BI |
| H5 | ¿Qué exportaciones se hacen? | Listado | BI |
| H6 | ¿Hay informes programados? | Configuración | Automatización |
| H7 | ¿Qué KPIs son obligatorios? | Listado | Priorización |

### I. Calidad y CSAT

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| I1 | ¿CSAT está activo en Zendesk? | Captura | Decidir |
| I2 | ¿Qué encuesta se envía? | Configuración | Replicar |
| I3 | ¿En qué momento se envía? | Configuración | Replicar |
| I4 | ¿Qué escala se usa? | Configuración | Replicar |
| I5 | ¿Se usan Guide/portal? | Captura | Alcance |
| I6 | ¿Se usan formularios de autoservicio? | Captura | Alcance |

### J. Integraciones

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| J1 | ¿Qué apps/integraciones están instaladas? | Listado | Replicar |
| J2 | ¿Hay webhooks? | Listado | Replicar |
| J3 | ¿Qué tokens/OAuth existen? | Solo existencia y tipo; **nunca valores** | Inventario |
| J4 | ¿Cómo se integra COSE? | Diagrama | Reemplazo |
| J5 | ¿Hay integración con WhatsApp/Meta? | Configuración | Alcance |
| J6 | ¿Hay integración con BI? | Configuración | Continuidad |
| J7 | ¿Hay herramientas externas? | Listado | Alcance |

### K. Administración y seguridad

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| K1 | ¿Cómo se autentican los agentes? | Configuración | Replicar |
| K2 | ¿Hay SSO? | Configuración | Replicar |
| K3 | ¿Hay restricciones por IP? | Configuración | Seguridad |
| K4 | ¿Qué política de contraseñas? | Configuración | Seguridad |
| K5 | ¿Qué auditoría existe? | Configuración | Trazabilidad |
| K6 | ¿Qué retención de datos? | Política | Conservación |
| K7 | ¿Dónde se almacenan los adjuntos? | Configuración | Migración |
| K8 | ¿Cómo se exportan los datos? | Procedimiento | Migración |
| K9 | ¿Qué política de eliminación? | Política | Conservación |
| K10 | ¿Cómo se protege la API? | Configuración | Seguridad |

### L. Volumen e histórico

| # | Pregunta | Evidencia necesaria | Por qué |
|---|---|---|---|
| L1 | ¿Cuántos tickets hay en total? | Conteo | Dimensionar |
| L2 | ¿Cuántos por año/mes? | Reporte | Dimensionar |
| L3 | ¿Cuántos abiertos/pendientes/cerrados? | Reporte | Migración |
| L4 | ¿Cuántos por canal/grupo/agente? | Reporte | Dimensionar |
| L5 | ¿Cuántos artículos? | Conteo | Migración |
| L6 | ¿Cuántos adjuntos y qué volumen? | Conteo | Almacenamiento |
| L7 | ¿Cuál es la antigüedad del histórico? | Fecha de inicio | Alcance |
| L8 | ¿Se puede exportar el histórico? | Procedimiento | Migración |

---

## 4. Formato de entrega sugerido

Para cada automatización, vista o SLA:

```text
Nombre:
Tipo: trigger | automation | macro | SLA | vista | informe
Estado: activo | inactivo
Condición:
Acción:
Alcance: grupo | canal | todos
Evidencia: captura | exportación | descripción
```

Para canales y volumen:

```text
Canal:
Dirección/identidad:
Grupo:
Volumen mensual:
Estado: activo | inactivo | no usado
```

---

## 5. Prioridad de la información

| Prioridad | Información | Bloquea |
|---|---|---|
| P0 | SLA policies + horarios + feriados | Reemplazo operativo |
| P0 | Volumen e histórico + exportación | Migración |
| P0 | Canales realmente usados | Alcance |
| P1 | Triggers/automations/macros | Paridad operativa |
| P1 | Vistas e informes de jefatura | Productividad |
| P1 | Campos personalizados | Datos |
| P2 | CSAT/Guide/portal | Experiencia |
| P2 | Integraciones/webhooks | Ecosistema |
| P3 | Seguridad avanzada | Administración |

### 5.1 Preguntas que siguen abiertas (priorizadas)

**P0 — bloquean el reemplazo:**

1. Políticas SLA de Zendesk: nombre, métricas, metas, horario, zona horaria, feriados, pausas y escalamiento.
2. Volumen e histórico: tickets totales/por año/mes, artículos, adjuntos, antigüedad y exportación.
3. Canales realmente activos y volumen mensual; ubicación del buzón exclusivo de Soporte Especializado y su grupo.
4. Condiciones, acciones y estado activo/inactivo de los **6 disparadores** y de las **2 automatizaciones**.

**P1 — necesarias para operar:**

5. Macros, reglas de asignación, prioridad, escalamiento y reapertura.
6. Vistas de Soporte Especializado: condiciones, columnas y orden.
7. Informes de jefatura y definición de “quintiles”.
8. Opciones internas de los desplegables: Categoría de Soporte, PAÍS, Nivel de resolución, Tipo de resolución, Ticket status.
9. Lista completa de estados y prioridades.
10. Configuración de adjuntos, CC/seguidores, asignaciones/notificaciones, estados personalizados y etiquetas.

**P2 — mejoras:**

11. CSAT/Guide/portal: estado y configuración.
12. Integraciones, webhooks y apps.
13. Organizaciones y campos de cliente.

**P3 — administración:**

14. SSO, restricciones por IP, política de contraseñas, retención y auditoría.

---

## 6. Nota de seguridad

No incluir en las respuestas:

- contraseñas,
- tokens de API,
- secretos OAuth,
- cookies de sesión,
- datos personales de clientes.

Si se requiere acceso, usar un gestor de secretos o un canal seguro, con permisos de solo lectura y vigencia limitada.
