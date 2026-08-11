{# incremental 策略的官方說明: https://docs.getdbt.com/docs/build/incremental-strategy #}
{# 當table被設定為incremental時，第一次執行時會建立新的table，之後會追加新資料，除非加上 --full-refresh 的參數 #}

{# 在 config() 需要設定為 incremental #}
{# 並且設定 on_schema_change='sync_all_columns'，
    如果 schema 有變動時會自動同步所有欄位，
    但是舊資料的 new field 會是 null，
    如果新的資料有刪除欄位，那麼資料表的欄位也會被移除 #}
{{ config(materialized='incremental', incremental_strategy='append', on_schema_change='sync_all_columns') }}

with token_transfer_agg as (
    select
        transaction_hash,
        count(*) as token_transfer_count
    from {{ ref('stg_token_transfers') }}
    group by transaction_hash
)

select
    t.hash,
    t.block_number,
    t.date,
    t.from_address,
    t.to_address,
    t.value,
    t.receipt_contract_address,
    t.input,
    tt.token_transfer_count,
    (case
        when t.receipt_contract_address != '' then 'contract_creation'
        when tt.transaction_hash is not null then 'token_transfer' -- 透過 token_transfers 表中是否有紀錄來判斷是否為 token transfer
        when t.input = '0x' and t.value > 0 then 'plain_eth_transfer' -- input 值是 0x 表示空的，沒有呼叫任何合約，且 value 大於 0 表示是純粹的 ETH 轉帳
        else 'other'
    end) as transaction_category,
    1 as new_field -- 新增欄位，測試 on_schema_change='sync_all_columns' 的功能
from {{ ref('stg_transactions') }} t
left join token_transfer_agg tt
on t.hash = tt.transaction_hash

{# incremental table 也需要加上 incremental logic #}
{% if is_incremental() %}
where t.date > (select max(date) from {{ this }})
{% endif %}