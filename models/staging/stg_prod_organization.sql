with source as (
    select * from {{ source('data_prod', 'organization') }}
)

select
    id
    , contact_email
    , name
    , platform_role
    , created_at
    , updated_at
    , 'prod'::VARCHAR as env
from source
