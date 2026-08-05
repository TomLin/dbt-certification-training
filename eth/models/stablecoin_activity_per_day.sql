select
    date,
    token_address,
    sum(value/1e6) as total_usd_value -- total value of token transfers, 和 eth 的值不一樣, 再轉換為 USD unit
from {{ source('eth', 'token_transfers') }}
where lower(token_address) in ('0xdac17f958d2ee523a2206206994597c13d831ec7', '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48')
group by
    date, token_address