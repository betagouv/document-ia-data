# document-ia-data

Models de transformation de données pour Document-IA.

Projet [dbt Core](https://docs.getdbt.com/) avec l'adaptateur PostgreSQL, exécuté contre l'add-on PostgreSQL de l'application.

## Prérequis

- Python 3.10 ou plus
- Docker (pour la base PostgreSQL locale)

## Installation

```bash
make install          # virtualenv .venv + dépendances + packages dbt
cp .env.example .env  # variables de connexion (chargées automatiquement par dbt)
source .venv/bin/activate
```

## Développement en local

```bash
make db-up            # PostgreSQL local sur le port 5432
dbt debug             # vérifie la configuration et la connexion
dbt build             # seeds, modèles, snapshots et tests
dbt docs generate && dbt docs serve
```

## Exécution sur l'add-on PostgreSQL

Les identifiants ne sont jamais versionnés : `profiles.yml` lit uniquement des variables
d'environnement. Pour cibler l'add-on depuis un poste ou un one-off Scalingo :

```bash
eval "$(python scripts/db_url_to_env.py "$(scalingo --app <app> env-get SCALINGO_POSTGRESQL_URL)")"
DBT_TARGET=prod dbt build
```

La cible `prod` n'a aucune valeur par défaut : si une variable manque, dbt échoue
immédiatement plutôt que d'écrire dans la mauvaise base. Elle force par ailleurs
`sslmode=require`.

## Structure

| Chemin                | Contenu                                                            |
| --------------------- | ------------------------------------------------------------------ |
| `dbt_project.yml`     | Configuration du projet et des couches de modèles                  |
| `profiles.yml`        | Connexions `dev` (locale) et `prod` (add-on), pilotées par l'environnement |
| `packages.yml`        | Packages dbt (`dbt_utils`)                                         |
| `models/`             | Modèles, organisés en `staging` / `core` / `analytics` (voir [models/README.md](models/README.md)) |
| `macros/`             | Macros Jinja réutilisables                                         |
| `seeds/`              | Données de référence versionnées en CSV                            |
| `snapshots/`          | Historisation des tables sources                                   |
| `tests/`              | Tests SQL sur mesure                                               |
| `analyses/`           | Requêtes exploratoires, compilées mais non matérialisées           |
| `scripts/`            | Utilitaires (conversion d'URL de connexion en variables `DBT_*`)    |

Les modèles `staging`, `core` et `analytics` sont matérialisés en tables dans le schéma `DBT_SCHEMA`
(`dbt_dev` par défaut).

## Intégration continue

Le workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) exécute `dbt deps`,
`dbt debug` puis `dbt build` sur chaque pull request, contre un service PostgreSQL éphémère.
