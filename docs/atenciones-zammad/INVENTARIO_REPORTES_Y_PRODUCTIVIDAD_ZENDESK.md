# INVENTARIO DE REPORTES Y PRODUCTIVIDAD — ZENDESK

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con evidencia administrativa. Las capturas no incluyeron informes ni Explore.
**Modo:** solo lectura. No se ejecutaron exportaciones masivas.

---

## 1. Reportes: qué se sabe

El negocio indicó que usa informes de **volumen**, **cumplimiento de SLA en quintiles** y otros no detallados. No se confirmó si esos informes son:

- nativos de Zendesk,
- de Zendesk Explore,
- dashboards de COSE,
- exportaciones manuales.

**Estado:** `PENDIENTE_DE_VALIDACION`.

### 1.1 Evidencia administrativa del 14/11/2026

Las capturas compartidas cubren Equipo, Canales, Correo, Formularios, Campos, Estados, Comportamiento, Disparadores y Automatizaciones. **No incluyen informes, Explore, dashboards ni exportaciones.**

Lo que sí aportan al análisis de reportes:

- Existe un formulario con campos como PAÍS, Categoría de Soporte, Nivel de resolución, Tipo de resolución, Dominio y Grupo de canales, que son dimensiones potenciales de reporte.
- Existen 4 estados visibles (Nuevo, Abierto, Pendiente, Resuelto), lista incompleta.
- Existen 12 campos de ticket con ID y tipo, que pueden alimentar reportes si se usan.

**No se puede concluir** qué informes usa la jefatura, ni si “quintiles” es un informe nativo, de Explore o de COSE.

---

## 2. Reportes que COSE ya calcula

COSE tiene un módulo BI propio que lee `public.v_unificado_norm` y expone endpoints `/dashboard/*`.

| Endpoint COSE | Contenido | Evidencia | Fuente de datos |
|---|---|---|---|
| `GET /dashboard/zendesk` | Volumen, estados, primera respuesta, resolución, SLA | `Zendesk.tsx`, `dashboard.controller.ts` | `v_unificado_norm` |
| `GET /dashboard/sla` | Cumplimiento primera/resolución, por canal/país/asesor/categoría | `Sla.tsx`, `unificado.repository.ts` | `v_unificado_norm` |
| `GET /dashboard/operacion` | Operación por periodo | `Operacion.tsx` | `v_unificado_norm` |
| `GET /dashboard/asesores` | Productividad por asesor | `dashboard.routes.ts` | `v_unificado_norm` |
| `GET /dashboard/categorias` | Volumen por categoría | `dashboard.routes.ts` | `v_unificado_norm` |
| `GET /dashboard/clientes` | Clientes y seguimiento | `dashboard.routes.ts` | `v_unificado_norm` |
| `GET /dashboard/pais` | Desglose por país | `dashboard.routes.ts` | `v_unificado_norm` |
| `GET /dashboard/whatsapp` | Métricas WhatsApp | `dashboard.routes.ts` | `v_unificado_norm` |
| `GET /dashboard/quejas-devoluciones` | Métricas QyD | `dashboard.routes.ts` | `v_unificado_norm` |

### 2.1 KPIs verificados en el código

| KPI | Evidencia | Estado |
|---|---|---|
| Tickets totales | `Zendesk.tsx` (`totalTickets`) | `VERIFICADO_ACTIVO` |
| Cerrados / resueltos / abiertos / pendientes | `Zendesk.tsx` | `VERIFICADO_ACTIVO` |
| Primera respuesta: n, cobertura, mediana, p90, promedio, sin dato | `Zendesk.tsx` | `VERIFICADO_ACTIVO` |
| Resolución: n, cobertura, mediana, p90, promedio, excluidas | `Zendesk.tsx` | `VERIFICADO_ACTIVO` |
| Cumplimiento SLA primera respuesta | `Sla.tsx` | `VERIFICADO_ACTIVO` |
| Cumplimiento SLA resolución | `Sla.tsx` | `VERIFICADO_ACTIVO` |
| Desglose por canal | `Sla.tsx` (`porCanal`) | `VERIFICADO_ACTIVO` |
| Desglose por país | `Sla.tsx` (`porPaisWhatsapp`, `porPaisCorreo`) | `VERIFICADO_ACTIVO` |
| Desglose por asesor | `Sla.tsx` (`porAsesorWhatsapp`, `porAsesorCorreo`) | `VERIFICADO_ACTIVO` |
| Desglose por categoría | `Sla.tsx` (`porCategoriaWhatsapp`, `porCategoriaCorreo`) | `VERIFICADO_ACTIVO` |
| Comparación con periodo anterior | `Zendesk.tsx` (`totalAnterior`, `variacionAbs`) | `VERIFICADO_ACTIVO` |

### 2.2 Quintiles

El negocio menciona “quintiles”. El código de COSE usa:

- mediana (`PERCENTILE_CONT(0.5)`),
- p90 (`PERCENTILE_CONT(0.9)`),
- promedios y conteos.

No se encontró una implementación explícita de “quintiles” (5 tramos). **Estado:** `PENDIENTE_DE_VALIDACION`. Hay que aclarar si “quintiles” significa:

1. cinco tramos de cumplimiento SLA,
2. percentiles (p20/p40/p60/p80),
3. otra definición de la jefatura.

### 2.3 Fuente de datos y dependencia

`unificado.repository.ts` indica: “Repositorio: ÚNICO lugar que toca la base. Lee `v_unificado_norm`.”

Esto significa que el BI de COSE **no consulta Zendesk en vivo**: lee una vista local. Esa vista se alimenta de las fuentes históricas (Zendesk, WhatsApp, etc.). Si Zammad reemplaza a Zendesk, la vista debe alimentarse desde Zammad o desde un ETL/BFF; de lo contrario, los reportes se congelan.

**Riesgo P0:** continuidad del BI durante y después del reemplazo.

---

## 3. Reportes nativos de Zendesk

| Elemento | Estado | Evidencia |
|---|---|---|
| Reportes nativos | `PENDIENTE_DE_ACCESO` | No hay inventario |
| Explore | `PENDIENTE_DE_ACCESO` | No hay inventario |
| Dashboards de Zendesk | `PENDIENTE_DE_ACCESO` | No hay inventario |
| Informes programados | `PENDIENTE_DE_ACCESO` | No hay inventario |
| Exportaciones | `PENDIENTE_DE_ACCESO` | No hay inventario |
| Informes de jefatura | `PENDIENTE_DE_VALIDACION` | “Volumen, SLA en quintiles, etc.” |

---

## 4. Vistas y productividad

| Funcionalidad | Estado | Evidencia | Observación |
|---|---|---|---|
| Vistas de Zendesk | `EXISTE_PERO_NO_SE_USA` | COSE usa search; `ZendeskViewIds.ts` deprecado | No son fuente de la bandeja |
| Vistas de Soporte Especializado | `PENDIENTE_DE_ACCESO` | No hay inventario | — |
| Condiciones/columnas/orden | `PENDIENTE_DE_ACCESO` | No hay inventario | — |
| Filtros de bandeja | `VERIFICADO_ACTIVO` | `CompactInbox` | Canal, estado, “solo míos” |
| Búsqueda | `VERIFICADO_ACTIVO` | `searchTickets("type:ticket status<closed")` | — |
| Acciones masivas | `PENDIENTE_DE_VALIDACION` | No evidenciado | — |
| Colisiones entre agentes | `PENDIENTE_DE_VALIDACION` | No evidenciado | — |
| Actualización en tiempo real | `PENDIENTE_DE_VALIDACION` | No evidenciado | — |

---

## 5. Equivalencia en Zammad

| Capacidad | Zammad | Estado en nuestra instalación |
|---|---|---|
| Vistas/overviews | `Overview` | **13 overviews**; 3 personalizadas (`Pendientes`, `Fuera de SLA`, `Cerrados recientes`) |
| Búsqueda | `/tickets/search` con DSL | `VERIFICADO_ACTIVO` |
| Filtros | `condition` | `VERIFICADO_ACTIVO` |
| Reportes | `Report` | **`Report.enabled? = false`** |
| Dashboards nativos | No equivalente directo a Explore | `PENDIENTE_DE_VALIDACION` |
| Exportación | API/CSV | `PENDIENTE_DE_VALIDACION` |
| Quintiles/percentiles | No nativo | `PENDIENTE_DE_VALIDACION` |
| Productividad por agente | Reportes/API | `PENDIENTE_DE_VALIDACION` |
| Productividad por grupo | Reportes/API | `PENDIENTE_DE_VALIDACION` |

**Conclusión:** Zammad puede cubrir la **operación** (vistas, búsqueda, filtros), pero **no** es equivalente a Explore para reportes analíticos avanzados. La BI de COSE debe mantenerse o adaptarse.

### 5.1 Trazabilidad de fuentes

| Fuente | Tipo | Fecha | Uso |
|---|---|---|---|
| Código de COSE (`dashboard*`, `Sla.tsx`, `Zendesk.tsx`) | Evidencia técnica | 14/11/2026 | KPIs, endpoints y fuente `v_unificado_norm` |
| Zammad local | Evidencia técnica | 14/11/2026 | `Report.enabled? = false`, overviews |
| Capturas administrativas | Evidencia visual | 14/11/2026 | Campos/estados disponibles, **sin informes** |
| Respuesta del negocio | Evidencia verbal | 14/11/2026 | “Volumen, SLA en quintiles, etc.” |

---

## 6. Preguntas concretas para el administrador

1. ¿Qué **informes nativos** usa la jefatura? Nombre y frecuencia.
2. ¿Se usa **Explore**? ¿Qué dashboards?
3. ¿Qué significa “**quintiles**” en el informe de SLA? ¿Cinco tramos? ¿Percentiles?
4. ¿Qué **dimensiones** se usan: canal, grupo, asesor, categoría, país, cliente?
5. ¿Qué **exportaciones** se hacen y con qué frecuencia?
6. ¿Hay **informes programados** por correo?
7. ¿Qué **vistas** usa Soporte Especializado?
8. ¿Qué **acciones masivas** se usan?
9. ¿Se requiere **tiempo real** o basta una actualización periódica?
10. ¿Qué **KPIs** son obligatorios para el primer lanzamiento?

**Evidencia necesaria:** captura o exportación de la lista de informes, dashboards y vistas. No se requieren credenciales en el documento.

---

## 7. Conclusión

- COSE ya tiene un BI propio y verificable sobre `v_unificado_norm`.
- Zendesk tiene reportes cuya configuración **no se ha verificado**; las capturas del 14/11/2026 no incluyeron informes ni Explore.
- Zammad tiene reportes desactivados y no es equivalente a Explore.
- La continuidad del BI es un **riesgo P0** si Zammad reemplaza a Zendesk sin un plan de datos.
- La evidencia administrativa aporta dimensiones potenciales (PAÍS, Categoría de Soporte, Nivel/Tipo de resolución, Dominio, Grupo de canales), pero **no demuestra** qué informes se usan ni qué significa “quintiles”.
