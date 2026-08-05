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
    end) as transaction_category
from {{ source('eth', 'transactions') }} t
left join (
    select
        transaction_hash,
        count(*) as token_transfer_count
    from {{ source('eth', 'token_transfers') }}
    group by transaction_hash
    ) tt
on t.hash = tt.transaction_hash

