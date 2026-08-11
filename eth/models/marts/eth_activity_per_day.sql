{# 在這裡的tags，只會影響這個model，指令可以下 `dbt run --select tag:daily` #}
{{ config(
    tags=['daily']
) }}

select
    date,
    transaction_category,
    count(*) as ts_count, -- transaction count
    {{ convert('value', 18) }} as sum_eth_value, -- total value of transactions
from {{ ref('init_transactions_enriched') }}
group by
    date, transaction_category
