-- 針對contract, token, and transaction 之間的關係介紹 https://share.gemini.google/a70LVbAVXzGL



{# Best practice: 每一個連接外部資料，都應該建立一個stage table，
讓dbt專案接下來的table，都是使用這一個stage table,
這樣當外部資料有變動時，dbt專案的table不需要修改，只需要修改stage table的定義即可。 #}


{# 在 dbt materialization 中，也可以在各自的 model 文件中指定 materialization 策略 #}
{# 在這個dbt的專案中，materialization是table，這裡可以改成view #}
{{ config(materialized='view')}}


select
    *
from {{ source('eth', 'contracts') }}