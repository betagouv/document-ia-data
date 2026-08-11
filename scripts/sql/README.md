# Permissions Postgres (add-on Scalingo)

Scripts SQL à appliquer une fois (ou après modification) pour poser les schémas
dbt et les droits associés.

## Modèle

| Schéma | Rôle |
| --- | --- |
| `public` | Config Metabase — réservé à l'admin, non modifié ici |
| `data_prod`, `data_staging`, `data_sandbox` | Landing anonymisé — **lecture seule** pour `dbt_dev` et `dbt_prod` |
| `dbt_dev` | Schéma d'écriture du rôle `dbt_dev` (full ownership) |
| `dbt_prod` | Schéma d'écriture du rôle `dbt_prod` — **lecture seule** pour `metabase` |

Les deux rôles dbt lisent les **trois** schémas landing (fusion des stats des
trois environnements applicatifs). Seul le schéma d'écriture les distingue.

Les `ALTER DEFAULT PRIVILEGES` font survivre les SELECT aux `dbt build` qui
recréent les tables.

## Ordre d'exécution

Trois connexions distinctes, dans cet ordre :

| Étape | Fichier | Utilisateur |
| --- | --- | --- |
| 1 | [`01_admin.sql`](01_admin.sql) | admin (`{{ document_ia_admin }}`) |
| 2 | [`02_dbt_dev.sql`](02_dbt_dev.sql) | `dbt_dev` |
| 3 | [`03_dbt_prod.sql`](03_dbt_prod.sql) | `dbt_prod` |

Pourquoi trois connexions ? L'admin n'est ni superuser ni membre des rôles dbt :
il ne peut donc ni faire `ALTER SCHEMA ... OWNER TO` (`must be able to SET ROLE`),
ni poser `ALTER DEFAULT PRIVILEGES FOR ROLE dbt_*`. Chaque rôle dbt crée donc son
propre schéma (ownership automatique) et pose ses propres default privileges.

## Comment se connecter

Via tunnel puis `psql` :

```bash
# Terminal 1 — tunnel vers l'add-on
scalingo --app <app> db-tunnel SCALINGO_POSTGRESQL_URL
# note le port local affiché (ex. 10000)

# Terminal 2 — admin
psql "postgres://{{document_ia_admin}}:<password>@127.0.0.1:<port>/<dbname>?sslmode=require" \
  -f scripts/sql/01_admin.sql

# Puis dbt_dev / dbt_prod de la même façon avec -f 02_dbt_dev.sql / 03_dbt_prod.sql
```
