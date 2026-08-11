# Organisation des modèles

Trois couches, chacune configurée dans `dbt_project.yml` :

| Dossier      | Matérialisation | Rôle                                                                                                                                            |
| ------------ | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `staging/`   | `table`     | Un modèle par table source : import, nettoyage, typage et renommage. Uniquement des opérations techniques, aucune logique métier.                 |
| `core/`      | `table`         | Entités métier de référence : jointures, déduplication et règles de gestion partagées par plusieurs usages.                                       |
| `analytics/` | `table`         | Modèles finaux orientés usage : agrégats et indicateurs consommés par les analyses et les tableaux de bord.                                       |

Tous les modèles matérialisés sont créés dans le schéma `DBT_SCHEMA` (`dbt_dev` par
défaut).

## Conventions

- Nommage : `stg_<env>_<entite>` (ex. `stg_prod_organization`), puis un nom métier pour les core et analytics (`core_organizations`, `analytics_daily_executions`).
- Les sources sont déclarées dans `models/staging/_sources.yml` et référencées avec `{{ source(...) }}` uniquement depuis le staging.
- Partout ailleurs, on référence les modèles avec `{{ ref(...) }}`.
- Chaque modèle a une entrée dans le fichier `_<dossier>_models.yml` du dossier, avec au minimum une description et un test d'unicité + non-nullité sur la clé primaire.
