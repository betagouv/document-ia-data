# Organisation des modèles

Trois couches, chacune configurée dans `dbt_project.yml` :

| Dossier      | Matérialisation | Rôle                                                                                                                                            |
| ------------ | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `staging/`   | `table`         | Un modèle par table source : import, nettoyage, typage et renommage. Uniquement des opérations techniques, aucune logique métier.                 |
| `core/`      | `table`         | Entités métier de référence : jointures, déduplication et règles de gestion partagées par plusieurs usages.                                       |
| `analytics/` | `table`         | Modèles finaux orientés usage : agrégats et indicateurs consommés par les analyses et les tableaux de bord.                                       |

Exception : `stg_*_event_store` surcharge en `incremental` (`delete+insert` sur
`id`, watermark sur `created_at`). En cible `dev`, la macro
`limit_event_store_by_created_at` restreint en plus aux N derniers mois
(variable `dev_event_store_lookback_months`, défaut 1).

Tous les modèles matérialisés sont créés dans le schéma `DBT_SCHEMA` de
l'add-on PostgreSQL Scalingo : `dbt_dev` en cible `dev` (dbt lancé en local via
le tunnel, rôle `dbt_dev`), `dbt_prod` en cible `prod` (rôle `dbt_prod`).

## Modèles actuels

| Modèle | Grain | Sources |
| --- | --- | --- |
| `stg_{prod,staging,sandbox}_organization` | `id` | `data_*.organization` + colonne `env` |
| `stg_{prod,staging,sandbox}_event_store` | `id` | `data_*.event_store` + colonne `env` |
| `core_organizations` | `(env, id)` | Union des trois `stg_*_organization` |
| `core_executions` | `(env, execution_id)` | Union des `stg_*_event_store`, événements Started / Completed / Failed, jointure `core_organizations` |
| `analytics_daily_executions` | `(execution_date, env, workflow_id, organization_id, organization_name, status)` | Agrégat de `core_executions` |

Les sources landing sont déclarées dans `_sources.yml` : `organization` et
`event_store` dans `data_prod`, `data_staging` et `data_sandbox`.

## Conventions

- Nommage : `stg_<env>_<entite>` (ex. `stg_prod_organization`), puis un nom métier pour les core et analytics (`core_organizations`, `analytics_daily_executions`).
- Colonne `env` (`prod` / `staging` / `sandbox`) dès le staging, car les couches core et analytics consolident les trois environnements.
- Les sources sont déclarées dans `models/staging/_sources.yml` et référencées avec `{{ source(...) }}` uniquement depuis le staging.
- Partout ailleurs, on référence les modèles avec `{{ ref(...) }}`.
- Chaque modèle a une entrée dans le fichier `_<dossier>_models.yml` du dossier, avec au minimum une description et un test d'unicité + non-nullité sur la clé primaire.
