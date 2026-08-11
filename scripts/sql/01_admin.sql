-- Permissions Postgres — à exécuter en tant que l'utilisateur admin de l'add-on.
-- Voir README.md pour l'ordre d'exécution.
--
-- Objectifs :
--   1. CONNECT (et CREATE pour les rôles dbt) sur la base
--   2. Lecture seule de data_prod / data_staging / data_sandbox pour dbt_dev et dbt_prod
--   3. Default privileges pour que les tables landing futures restent lisibles
--
-- Les schémas dbt_dev / dbt_prod sont créés par leurs propriétaires dans
-- 02_dbt_dev.sql / 03_dbt_prod.sql. L'admin ne peut pas faire
-- ALTER SCHEMA ... OWNER TO (erreur : must be able to SET ROLE).

-- ---------------------------------------------------------------------------
-- Base : CONNECT pour tous, CREATE pour que chaque rôle dbt crée son schéma
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  EXECUTE format(
    'GRANT CONNECT ON DATABASE %I TO dbt_dev, dbt_prod, metabase',
    current_database()
  );
  EXECUTE format(
    'GRANT CREATE ON DATABASE %I TO dbt_dev, dbt_prod',
    current_database()
  );
END $$;

-- ---------------------------------------------------------------------------
-- Landing : USAGE + SELECT existant + SELECT futur (créateur = admin)
-- ---------------------------------------------------------------------------
GRANT USAGE ON SCHEMA data_prod, data_staging, data_sandbox
  TO dbt_dev, dbt_prod;

GRANT SELECT ON ALL TABLES IN SCHEMA data_prod TO dbt_dev, dbt_prod;
GRANT SELECT ON ALL TABLES IN SCHEMA data_staging TO dbt_dev, dbt_prod;
GRANT SELECT ON ALL TABLES IN SCHEMA data_sandbox TO dbt_dev, dbt_prod;

GRANT SELECT ON ALL SEQUENCES IN SCHEMA data_prod TO dbt_dev, dbt_prod;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA data_staging TO dbt_dev, dbt_prod;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA data_sandbox TO dbt_dev, dbt_prod;

ALTER DEFAULT PRIVILEGES FOR ROLE {{ document_ia_admin }} IN SCHEMA data_prod
  GRANT SELECT ON TABLES TO dbt_dev, dbt_prod;
ALTER DEFAULT PRIVILEGES FOR ROLE {{ document_ia_admin }} IN SCHEMA data_staging
  GRANT SELECT ON TABLES TO dbt_dev, dbt_prod;
ALTER DEFAULT PRIVILEGES FOR ROLE {{ document_ia_admin }} IN SCHEMA data_sandbox
  GRANT SELECT ON TABLES TO dbt_dev, dbt_prod;
