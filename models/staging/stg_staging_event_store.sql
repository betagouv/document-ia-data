{{
    config(
        materialized='incremental',
        unique_key='id',
        incremental_strategy='delete+insert',
    )
}}

select
    id
    , workflow_id
    , execution_id
    , created_at
    , event_type
    , organization_id
    , 'staging'::VARCHAR as env
from {{ source('data_staging', 'event_store') }}
{{ limit_event_store_by_created_at('created_at') }}
