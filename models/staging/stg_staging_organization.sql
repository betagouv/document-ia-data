with source as (
    select * from {{ source('data_staging', 'organization') }}
)

select
    id,
    contact_email,
    name,
    platform_role,
    created_at,
    updated_at,
    'staging'::varchar as env
from source
