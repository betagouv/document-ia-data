-- Permissions Postgres — à exécuter en tant que dbt_prod.
-- Prérequis : 01_admin.sql a déjà accordé CREATE ON DATABASE à dbt_prod.
--
-- Objectifs :
--   1. Créer le schéma dbt_prod (propriétaire = dbt_prod automatiquement)
--   2. Donner à metabase l'accès lecture (tables existantes + futures)
--
-- Les ALTER DEFAULT PRIVILEGES FOR ROLE dbt_prod doivent être exécutés par
-- dbt_prod lui-même : l'admin n'est pas membre de ce rôle.

CREATE SCHEMA IF NOT EXISTS dbt_prod;

REVOKE ALL ON SCHEMA dbt_prod FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA dbt_prod TO dbt_prod;

-- Metabase : lecture seule sur tout le schéma dbt_prod (phase 1).
-- Phase 2 prévue : restreindre aux couches core_* / analytics_* via +grants dbt.
GRANT USAGE ON SCHEMA dbt_prod TO metabase;
GRANT SELECT ON ALL TABLES IN SCHEMA dbt_prod TO metabase;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA dbt_prod TO metabase;

ALTER DEFAULT PRIVILEGES FOR ROLE dbt_prod IN SCHEMA dbt_prod
  GRANT SELECT ON TABLES TO metabase;
ALTER DEFAULT PRIVILEGES FOR ROLE dbt_prod IN SCHEMA dbt_prod
  GRANT SELECT ON SEQUENCES TO metabase;
