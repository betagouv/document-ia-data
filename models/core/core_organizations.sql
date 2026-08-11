with

organizations as (
    select * from {{ ref('stg_prod_organization') }}
    union all
    select * from {{ ref('stg_staging_organization') }}
    union all
    select * from {{ ref('stg_sandbox_organization') }}
)

select
    id
    , contact_email
    , name
    , platform_role
    , created_at
    , updated_at
    , env
from organizations
