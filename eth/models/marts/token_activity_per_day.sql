
{# 在jinja中，字串的concatenate 是用 ~ 符號 #}
{# 透過 var and alias 的使用，這一張表，在資料庫中的名稱會是 tron_activity_per_day #}
{{ config(tags=['token'], alias=var('token_name_var')~'_activity_per_day') }}

{# 使用 alias 的好處，可以參考這個Gemini回答：https://share.gemini.google/LMVLJ3uhFD8d #}

select
    t.date,
    t.token_address,
    {{ convert('t.value', var('token_decimals_var')) }} as total_value -- total value of token transfers, 和 eth 的值不一樣, 再轉換為 USD unit
from {{ ref('stg_token_transfers') }} t
where lower(t.token_address) = '{{ var("token_address_var") }}'
group by
    t.date,
    t.token_address
