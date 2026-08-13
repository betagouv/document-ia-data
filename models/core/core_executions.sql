with

events as (
    select * from {{ ref('stg_prod_event_store') }}
    union all
    select * from {{ ref('stg_staging_event_store') }}
    union all
    select * from {{ ref('stg_sandbox_event_store') }}
)

, lifecycle_events as (
    select
        env
        , execution_id
        , workflow_id
        , organization_id
        , event_type
        , created_at
    from events
    where event_type in (
        'WorkflowExecutionStarted'
        , 'WorkflowExecutionCompleted'
        , 'WorkflowExecutionFailed'
    )
)

, executions as (
    select
        env
        , execution_id
        , MAX(workflow_id) as workflow_id
        , (
            ARRAY_AGG(organization_id) filter (
                where organization_id is not null
            )
        )[1] as organization_id
        , MIN(created_at) filter (
            where event_type = 'WorkflowExecutionStarted'
        ) as started_at
        , MAX(created_at) filter (
            where event_type in (
                'WorkflowExecutionCompleted'
                , 'WorkflowExecutionFailed'
            )
        ) as ended_at
        , MAX(case
            when event_type = 'WorkflowExecutionFailed' then 'Failed'
            when event_type = 'WorkflowExecutionCompleted' then 'Succeeded'
        end) as status
    from lifecycle_events
    group by
        env
        , execution_id
)

select
    executions.env
    , executions.execution_id
    , executions.workflow_id
    , organizations.id as organization_id
    , organizations.name as organization_name
    , executions.started_at
    , executions.ended_at
    , executions.status
    , EXTRACT(epoch from (executions.ended_at - executions.started_at)) as duration_seconds
from executions
left join {{ ref('core_organizations') }} as organizations
    on
        executions.env = organizations.env
        and executions.organization_id = organizations.id
where
    executions.started_at is not null
    and executions.ended_at is not null
