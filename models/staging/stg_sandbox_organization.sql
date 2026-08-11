with source as (
    select * from {{ source('data_sandbox', 'organization') }}
)

select
    id,
    contact_email,
    name,
    platform_role,
    created_at,
    updated_at,
    'sandbox'::varchar as env
from source
