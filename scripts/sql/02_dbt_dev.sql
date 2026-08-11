-- Permissions Postgres — à exécuter en tant que dbt_dev.
-- Prérequis : 01_admin.sql a déjà accordé CREATE ON DATABASE à dbt_dev.
--
-- Objectifs :
--   1. Créer le schéma dbt_dev (propriétaire = dbt_dev automatiquement)
--   2. Retirer les droits implicites de PUBLIC sur ce schéma

CREATE SCHEMA IF NOT EXISTS dbt_dev;

REVOKE ALL ON SCHEMA dbt_dev FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA dbt_dev TO dbt_dev;
