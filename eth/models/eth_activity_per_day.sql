select
    date,
    transaction_category,
    count(*) as ts_count, -- transaction count
    sum(value)/1e18 as sum_eth_value, -- total value of transactions
from {{ ref('transactions_enriched') }}
group by
    date, transaction_category
