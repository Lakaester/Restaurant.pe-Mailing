# MATRIZ DE TRAZABILIDAD — EPIC-SLA-01

**Cadena exigida:** Contrato → Historia → Implementación → Prueba → Evidencia.

| Req / Regla | Contrato | Implementación | Prueba | Evidencia | Estado |
|---|---|---|---|---|---|
| Solo email (BR-01) | EPIC §5.1 L278 | `SlaService.registrarTicket` rechaza otro canal | QA-U-29 | `sla.service.test.ts` | Cubierto |
| Sin escritura en Zammad (BR-05) | EPIC §5.1 L282 | `zammad.client.ts`: solo `get()` privado | Sin ejecutar | Revisión de código | Cubierto en código |
| Sin cuerpos/datos de contacto (BR-06) | EPIC §5.1 L283 | Cliente lee solo campos enumerados | Sin ejecutar | Revisión de código | Cubierto en código |
| Clasificación manual (BR-07) | EPIC §5.2 L289 | `clasificar` exige par explícito; sin IA | QA-U-19/21 | `engine.test.ts`, `sla.service.test.ts` | Cubierto |
| Catálogo de 65 por par (BR-08/09) | EPIC §5.2 L290-291 | `validarPar` + `matriz-oficial.generated.ts` | QA-U-01/03/19 | `engine.test.ts` | Cubierto |
| `pending_classification` sin 36 h (BR-10/11) | EPIC §5.2 L292-293 | Compromiso sin vencimiento; fallback bloqueado | QA-U-22 | `sla.service.test.ts` | Cubierto |
| Compromiso inmutable (BR-13/14) | EPIC §5.2 L295-296 | `asignarCompromiso` solo desde pending; `contarReclasificacion` | QA-U-21/25 | `sla.service.test.ts` | Cubierto |
| 24/7 (BR-16) | EPIC §5.3 L305 | Cálculo en milisegundos, sin calendario | QA-U-05/11 | `engine.test.ts` | Cubierto |
| `< 86.400 s` (BR-23) | EPIC §5.4 L317 | `PRIMERA_RESPUESTA_LIMITE_MS` con `<` | QA-U-05 | `engine.test.ts` | Cubierto |
| 5 condiciones del artículo (BR-25) | EPIC §5.4 L319 | Filtros `channel/isPublic/authorIsAgent/status/fecha` | QA-U-04/07 | `engine.test.ts` | Cubierto |
| Fecha `delivery_status_date` (BR-26/27) | EPIC §5.4 L320-321 | `fechaSource` y fallback | QA-U-06 | `engine.test.ts` | Cubierto |
| Fallo provisional/definitivo (BR-29) | EPIC §5.4 L323 | `clasificarEntrega` | QA-U-08 | `engine.test.ts` | Cubierto |
| Primer cierre `closed` (BR-32) | EPIC §5.5 L331 | `esCierreValido` + `reconstruirCiclos` | QA-U-11/13 | `engine.test.ts` | Cubierto |
| `merged` excluido (BR-34) | EPIC §5.5 L333 | `outcome='excluded'` + divergencia | QA-U-10 | `engine.test.ts` | Cubierto |
| Reapertura A (BR-36..40) | EPIC §5.5 L335-339; ciclos §4.2 | `reconstruirCiclos` con ciclo N+1 | QA-U-12/13 | `engine.test.ts` | Cubierto en código; firma D-01 pendiente |
| Borde inclusivo resolución (BR-33) | Ciclos §2 L50-52 | `closedAt <= dueAt` | QA-U-11 | `engine.test.ts` | Cubierto |
| Clasificación tardía (BR-44) | EPIC §5.6 L348 | `esClasificacionTardiva` + `missed_at_birth` | QA-U-20/26 | ambas pruebas | Cubierto |
| 27/3/28/7 (BR-41..43/65) | Matriz oficial + DEC-05 | Matriz generada y validada | QA-U-18/19 | `engine.test.ts` | Cubierto |
| Objetivo ≥ 80 % (BR-48) | EPIC §5.7 L357 | `calcularCumplimiento` | QA-U-17 | `engine.test.ts` | Cubierto |
| Alertas 75/90/100 (BR-54) | EPIC §5.7 L363 | `calcularAlertas` | QA-U-16/28 | ambas pruebas | Cubierto en código; D-05 sin confirmar |
| Auditabilidad (BR-59) | EPIC §5.8 L373 | `repo.auditar` con reason obligatorio | QA-U-21/25 | `sla.service.test.ts` | Cubierto |
| Idempotencia (BR-61) | EPIC §5.8 L375 | `claveIdempotencia` sha256 | QA-U-15/27 | ambas pruebas | Cubierto |
| Watermark solo si ok (BR-62) | EPIC §5.8 L376 | `sincronizarDesdeZammad` try/catch | Sin ejecutar | Revisión de código | Cubierto en código |
| Espejo opcional (BR-66) | EPIC §5.9 L385 | `espejoCoincide` + divergencia | QA-U-26 | `sla.service.test.ts` | Cubierto en código; D-06 sin confirmar |
| Selector 65/7 (BR-67) | EPIC §5.9 L386 | `/sla/catalogo` + `Clasificador` | Sin ejecutar en navegador | Código | Cubierto en código |
| Guarda de entorno | DDL + PLAN M1/M3 | `verificarEntorno` en cada escritura | Sin ejecutar | Revisión de código | Cubierto en código |
| Frontera Prisma | PAQUETE §8 | Sin modelos `sla_*`; SQL crudo | Verificación previa 0 errores | verificador estructural | Cubierto |
| D-02 sin ratificar | PAQUETE D-02 | `FALLBACK_SIN_RATIFICACION` | QA-U-22/23 | `sla.service.test.ts` | Cubierto |
| D-07 no aprobada | PAQUETE §6 | Sin `sla_classification`; auditoría como fuente | Verificador: tabla ausente en `001` | validación | Cubierto |
| D-08 no aprobada | PAQUETE §7 | Sin `sla_schema_migration` | Verificador: tabla ausente en `001` | validación | Cubierto |

**Leyenda:** «Cubierto en código» significa que la implementación existe y compila; no implica prueba ejecutada contra base o integración.
