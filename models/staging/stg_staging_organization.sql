with source as (
    select * from {{ source('data_staging', 'organization') }}
)

select
    id
    , contact_email
    , name
    , platform_role
    , created_at
    , updated_at
    , 'staging'::VARCHAR as env
from source
