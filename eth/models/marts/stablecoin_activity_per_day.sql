select
    date,
    token_address,
    {{ convert('value', 6) }} as total_usd_value -- total value of token transfers, 和 eth 的值不一樣, 再轉換為 USD unit
from {{ ref('stg_token_transfers') }}
where lower(token_address) in ('0xdac17f958d2ee523a2206206994597c13d831ec7', '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48')
    {# or lower(token_address) in {{ random_macro() }} -- 這裡會直接回傳一個 ('xxx', 'yyy', 'zzz') 的 tuple，這樣就可以直接放在 in 的條件裡面 #}
group by
    date, token_address