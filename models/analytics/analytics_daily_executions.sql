select
    DATE(started_at) as execution_date
    , env
    , workflow_id
    , organization_id
    , organization_name
    , status
    , COUNT(*) as execution_count
    , SUM(duration_seconds) as total_duration_seconds
from {{ ref('core_executions') }}
group by
    DATE(started_at)
    , env
    , workflow_id
    , organization_id
    , organization_name
    , status
