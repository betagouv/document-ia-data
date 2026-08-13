{#
  Emits a WHERE clause that limits event_store rows by created_at.

  - target `dev`: only events from the last N months (default 1)
  - incremental runs: also apply the created_at watermark on {{ this }}
  - other targets: no lookback (full history), watermark only when incremental

  Predicates: boolean filter expressions collected into a list, then AND-joined
  into a single WHERE clause. Each applicable rule appends one predicate
  (dev lookback and/or incremental watermark). If the list stays empty
  (e.g. non-dev full refresh), no WHERE clause is emitted.
#}
{% macro limit_event_store_by_created_at(column_name='created_at') %}
    {%- set predicates = [] -%}

    {%- if target.name == 'dev' -%}
        {%- set lookback_months = var('dev_event_store_lookback_months', 1) | int -%}
        {%- do predicates.append(
            column_name ~ " >= (current_timestamp - interval '" ~ lookback_months ~ " months')"
        ) -%}
    {%- endif -%}

    {%- if is_incremental() -%}
        {%- do predicates.append(
            column_name ~ " >= (select max(" ~ column_name ~ ") from " ~ this ~ ")"
        ) -%}
    {%- endif -%}

    {%- if predicates -%}
where {{ predicates | join('\nand ') }}
    {%- endif -%}
{% endmacro %}
