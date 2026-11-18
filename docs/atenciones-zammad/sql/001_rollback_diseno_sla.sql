-- ============================================================================
-- EPIC-SLA-01 · ROLLBACK PROPUESTO DEL DISENO 001
--
-- PROPUESTA. NO EJECUTAR.
--
-- Elimina exclusivamente las 9 tablas sla_* creadas por
-- 001_diseno_esquema_sla.sql, en orden inverso al de creacion.
--
-- Advertencias:
--   1. DESTRUCTIVO: borra todos los datos del motor SLA.
--   2. Solo debe ejecutarse sobre `restaurant_bi_test`, nunca sobre produccion.
--   3. Requiere respaldo previo (paso R1/R2 del procedimiento de migracion).
--   4. No usa CASCADE: si aparece una dependencia inesperada, debe fallar en
--      lugar de arrastrar objetos ajenos al modulo.
--   5. No toca Zammad, public.v_unificado_norm ni tablas historicas de BI.
--
-- Se conserva como evidencia de reversibilidad; su ejecucion exige autorizacion
-- expresa junto con la de la migracion.
-- ============================================================================

BEGIN;

DO $$
BEGIN
  IF current_database() <> 'restaurant_bi_test' THEN
    RAISE EXCEPTION
      'Rollback SLA bloqueado: se esperaba la base restaurant_bi_test y la conexion apunta a "%".',
      current_database();
  END IF;

  IF current_user IN ('pgvector_user', 'postgres') THEN
    RAISE EXCEPTION
      'Rollback SLA bloqueado: el rol "%" es de produccion o administracion.',
      current_user;
  END IF;
END
$$;

-- Orden inverso al de creacion.
DROP TABLE IF EXISTS sla_sync_run;
DROP TABLE IF EXISTS sla_divergence;
DROP TABLE IF EXISTS sla_audit;
DROP TABLE IF EXISTS sla_alert;
DROP TABLE IF EXISTS sla_article_delivery;
DROP TABLE IF EXISTS sla_event;
DROP TABLE IF EXISTS sla_cycle;
DROP TABLE IF EXISTS sla_commitment;
DROP TABLE IF EXISTS sla_policy_version;

COMMIT;

-- Verificacion posterior: debe devolver 0 filas.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'sla\_%' ESCAPE '\'
ORDER BY table_name;

-- ============================================================================
-- FIN DEL ROLLBACK PROPUESTO. No se ejecuto.
-- ============================================================================
