# GUÍA DE OPERACIÓN — MOTOR SLA C.O.S.E.

**Entorno soportado:** `restaurant_bi_test` con roles `cope_test_migration` / `cope_test_runtime`. **Producción no soportada en esta etapa.**

## 1. Puesta en marcha (requiere aprobaciones previas)

1. DBA crea base y roles según `PLAN_MIGRACION_SLA.md` §2.
2. Responsable técnico resuelve D-03..D-08 y aprueba M1–M8.
3. Aplicar `001` con M6; verificar con M7; guardar evidencia M8.
4. Cargar políticas: 27 `matrix` (AP-01 condicional), 3 `no_policy`, 7 `inactive`; **28 fallback solo tras D-02**.
5. Configurar `.env` de pruebas con `DATABASE_URL` apuntando exclusivamente a `restaurant_bi_test`, `ZAMMAD_BASE_URL` y `ZAMMAD_API_TOKEN` de usuario de solo lectura. Nunca reutilizar credenciales productivas.

## 2. Operación diaria del asesor

1. Abrir **SLA** en el sidebar de C.O.S.E. (o `/sla`).
2. La bandeja muestra compromisos de correo con estado, política y tiempo restante.
3. Seleccionar un ticket y elegir categoría + subcategoría dependiente. El selector marca la clase de política y **no ofrece** las 7 excluidas.
4. Confirmar. Si el ticket ya estaba asignado, escribir un motivo (≥ 5 caracteres): se registra como reclasificación y el compromiso original queda intacto.
5. El detalle muestra compromiso original, clasificación vigente, ciclos, alertas y divergencias.

## 3. Reglas que el asesor debe conocer

- Un ticket sin clasificar **no tiene SLA de 36 h**: permanece `pending_classification`.
- Las 3 subcategorías sin evidencia quedan `no_policy`: no reciben SLA ni respaldo.
- El respaldo de 36 h está deshabilitado hasta la ratificación de Soporte; si intenta usarlo verá `FALLBACK_SIN_RATIFICACION`.
- `pending close` no detiene el reloj; `merged` no cuenta como cierre.
- Reabrir crea un ciclo nuevo con su propio vencimiento; la métrica oficial sigue siendo el ciclo 1.

## 4. Sincronización

- Solo la ejecuta un administrador desde `/api/sla/sincronizar`.
- Cadencia prevista: 5 min abiertos, 2 min si falta respuesta con vencimiento < 4 h, 15 min incremental con solape, diaria completa, semanal de integridad.
- El watermark avanza solo si el run termina `ok`. Si falla, se registra `status='failed'` y se conserva el watermark anterior.
- Los webhooks **no** se usan: no ven actualizaciones de artículo.

## 5. Monitoreo

| Señal | Dónde | Acción |
|---|---|---|
| Divergencias abiertas | `/sla/divergencias` y pestaña Administración | Revisar `catalog_mirror_mismatch` y decidir sobre el catálogo |
| Alertas pendientes | `/sla/alertas` | 75/90 % = riesgo; 100 % = vencido |
| Cumplimiento < 80 % | `/sla/indicadores` | Revisar denominador y excluidos antes de actuar |
| `health.tablas != 9` | `/sla/health` | Detener operaciones: entorno incorrecto |
| Error `BASE_SLA_INVALIDA` | logs | Detener: el repositorio rechazó escribir fuera de la base de pruebas |

## 6. Procedimiento prohibido

- Ejecutar `prisma db pull`, `db push`, `migrate` o `db execute` con SQL del módulo.
- Modificar `CategoryData.ts`, el catálogo exportado, Zammad ni `public.v_unificado_norm`.
- Crear bases, roles o elevar privilegios desde la aplicación.
- Publicar porcentajes sin denominador.
- Usar datos reales de clientes o enviar correos reales en pruebas.

## 7. Rollback

Según `PLAN_MIGRACION_SLA.md` §4. Solo en ventana autorizada, con respaldo previo y sin `CASCADE`. El `down` elimina las 9 tablas y, si se aprobara D-08, también el registro de migración: por eso la evidencia M8 debe conservarse fuera de la base.
