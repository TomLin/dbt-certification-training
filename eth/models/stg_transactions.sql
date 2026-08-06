{# Best practice: 每一個連接外部資料，都應該建立一個stage table，
讓dbt專案接下來的table，都是使用這一個stage table,
這樣當外部資料有變動時，dbt專案的table不需要修改，只需要修改stage table的定義即可。 #}

{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hash') }}

select
    hash,
    block_number,
    date,
    from_address,
    to_address,
    value,
    receipt_contract_address,
    input
from {{ source('eth', 'transactions') }}

{% if is_incremental() %}
where date > (select max(date) from {{ this }})
{% endif %}