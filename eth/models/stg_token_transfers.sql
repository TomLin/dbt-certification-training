{# Best practice: 每一個連接外部資料，都應該建立一個stage table，
讓dbt專案接下來的table，都是使用這一個stage table,
這樣當外部資料有變動時，dbt專案的table不需要修改，只需要修改stage table的定義即可。 #}

select
    *
from {{ source('eth', 'token_transfers') }}