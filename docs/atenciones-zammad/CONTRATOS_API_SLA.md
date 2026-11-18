# CONTRATOS DE LA API SLA — EPIC-SLA-01

**Base:** `/api/sla` · **Fecha:** 17/11/2026
**Autenticación:** cookie de sesión existente (`requireAuth`). Todas las rutas la requieren.
** Autorización:** lectura para cualquier sesión autenticada; `/alertas/generar` y `/sincronizar` exigen `requirePermission("Configuracion","administrar")`. No se inventó un rol SLA: no existe evidencia de uno (OBS-04).
**Formato:** éxito `{ "ok": true, "data": ... }`; error `{ ok:false, error, code, type, timestamp }`.
**Nota:** OpenAPI no está implementado en el repositorio; este documento es la especificación contractual.

## 1. Endpoints

| Método | Ruta | Body / Query | Respuesta | Idempotencia |
|---|---|---|---|---|
| GET | `/health` | — | `{ok,database,user,tablas,ejecutado}` | Sí |
| GET | `/catalogo` | — | 13 categorías, 65 subcategorías con `policyClass` | Sí |
| GET | `/politicas` | — | 27 políticas + flag `cargable` | Sí |
| POST | `/tickets` | `{ticketId,ticketNumber,channel:"email",createdAt,state,catalogMirror?}` | `{ticketId}` | Sí (UPSERT por ticket) |
| POST | `/clasificar` | `{ticketId,categoria,subcategoria,espejo?,actorId?,requestId?}` | `{compromisoId,policyKey,reclasificado}` | Si ya está asignado, delega en reclasificar |
| POST | `/reclasificar` | `{ticketId,categoria,subcategoria,reason(≥5),actorId?,requestId?}` | `{compromisoId,reclassifiedCount}` | No: cada llamada cuenta y audita |
| GET | `/compromisos` | `limit(1..200),offset,estado?,ticketId?` | `CompromisoSLA[]` | Sí |
| GET | `/compromisos/:ticketId` | — | `CompromisoSLA` o 404 | Sí |
| GET | `/compromisos/:ticketId/ciclos` | — | `CicloSLA[]` | Sí |
| GET | `/compromisos/:ticketId/clasificacion` | — | `{categoria,subcategoria,origen}` | Sí |
| GET | `/eventos?ticketId=` | `ticketId` obligatorio, paginación | `EventoSLA[]` | Sí |
| POST | `/eventos` | `{ticketId,eventType,source,occurredAt,payload}` | `{duplicado,ciclosActualizados,divergencias}` 200/201 | **Sí**, por clave sha256 |
| POST | `/articulos/evaluar` | `{ticketId,articulos[1..200]}` | `{estado,articuloId}` | Sí: primera respuesta inmutable |
| POST | `/alertas/generar` | `{commitmentId(uuid),cycleNumber,openedAt,resolutionMinutes}` | `{creadas:3}` | Sí, UNIQUE por umbral |
| GET | `/alertas` | paginación, `estado?` | `sla_alert[]` | Sí |
| GET | `/auditoria` | paginación, `estado?` (= action) | `sla_audit[]` | Sí |
| GET | `/divergencias` | paginación, `ticketId?` | divergencias abiertas | Sí |
| GET | `/indicadores` | `desde?`, `hasta?` (ISO) | KPIs + `{cumplimiento:{total,cumplidos,porcentaje,alcanzaObjetivo}}` | Sí |
| GET | `/sincronizacion` | — | `{watermark}` | Sí |
| POST | `/sincronizar` | `{kind:"incremental"\|"open_tickets"}` | `{runId,tickets,eventos,watermark}` | Watermark solo avanza si `ok` |

## 2. Esquemas Zod

`dto.ts` define 8 esquemas: `clasificarSchema`, `reclasificarSchema`, `registrarTicketSchema`, `eventoSchema`, `articulosSchema`, `alertasSchema`, `listadoQuerySchema`, `metricasQuerySchema`. Errores de validación → `400` con `detail` de issues.

`eventType` admite los 15 tipos del DDL. `source` admite `poll | reconcile | manual` (sin `webhook`).

## 3. Códigos de error del motor

| `code` | HTTP | Significado |
|---|---:|---|
| `PAR_NO_OFICIAL` | 422/400 | Categoría o subcategoría fuera del catálogo de 65 |
| `CANAL_FUERA_DE_ALCANCE` | 422 | Canal distinto de email |
| `FALLBACK_SIN_RATIFICACION` | 409 | D-02 no firmada; no se asignan 36 h |
| `EXCLUIDO_NO_SERVICIO` | 422 | DEC-05; sin compromiso |
| `SIN_EVIDENCIA` | 422 | Una de las 3 combinaciones con n<10 |
| `COMPROMISO_NO_ENCONTRADO` | 404 | Ticket sin compromiso |
| `ZAMMAD_NO_CONFIGURADO` | 503 | Faltan variables de solo lectura |
| `BASE_SLA_INVALIDA` / `ROL_SLA_INVALIDO` | 500 | Guarda de entorno; aborta toda escritura |

## 4. Ejemplos

### Clasificar

```http
POST /api/sla/clasificar
Content-Type: application/json

{ "ticketId": 7, "categoria": "FACTURACIÓN ELECTRÓNICA", "subcategoria": "Ajustes FE" }
```

```json
{ "ok": true, "data": { "compromisoId": "…", "policyKey": "20-MAIL-FACTURACION_ELECTRONICA-AJUSTES_FE", "reclasificado": false } }
```

### Evento repetido

La segunda llamada con el mismo `(ticket, tipo, entity_id, occurred_at)` devuelve `200` y `duplicado:true`; no inserta fila ni ciclo.

### Indicadores

```json
{ "ok": true, "data": { "desde": "…", "hasta": "…", "cumplimiento": { "total": 5, "cumplidos": 4, "porcentaje": 80, "alcanzaObjetivo": true } } }
```

## 5. Reglas que el consumidor debe respetar

- Mostrar el denominador junto a cualquier porcentaje (BR-53).
- No presentar `delivery_status=success` como «correo entregado»: es «envío aceptado por servidor de salida» (BR-28).
- No mezclar WhatsApp/WHATMETA/WHATICKET.
- No editar compromisos históricos: para corregir, usar `/reclasificar` con motivo.
