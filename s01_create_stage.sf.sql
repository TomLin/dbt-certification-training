CREATE DATABASE ETH;
CREATE SCHEMA ETH.ETH_SCHEMA;

-- Set up pointer to AWS S3 bucket
CREATE OR REPLACE STAGE ETH.ETH_SCHEMA.CONTRACTS_STAGE
    URL = 's3://aws-public-blockchain/v1.0/eth/contracts'
    FILE_FORMAT = (TYPE = 'PARQUET');

CREATE OR REPLACE STAGE ETH.ETH_SCHEMA.TOKEN_TRANSFERS
    URL = 's3://aws-public-blockchain/v1.0/eth/token_transfers'
    FILE_FORMAT = (TYPE = 'PARQUET');

CREATE OR REPLACE STAGE ETH.ETH_SCHEMA.TRANSACTIONS
    URL = 's3://aws-public-blockchain/v1.0/eth/transactions'
    FILE_FORMAT = (TYPE = 'PARQUET');


-- Copy AWS S3 data into table
CREATE OR REPLACE TABLE ETH.ETH_SCHEMA.CONTRACTS (
    address string,
    block_hash string,
    block_number int,
    block_timestamp TIMESTAMP,
    bytecode string,
    date date,
    last_modified TIMESTAMP
);


CREATE OR REPLACE TABLE ETH.ETH_SCHEMA.TOKEN_TRANSFERS (
    BLOCK_HASH STRING,
    BLOCK_NUMBER INT,
    BLOCK_TIMESTAMP TIMESTAMP,
    DATE DATE,
    FROM_ADDRESS STRING,
    TO_ADDRESS STRING,
    LAST_MODIFIED TIMESTAMP,
    LOG_INDEX INT,
    TOKEN_ADDRESS STRING,
    TRANSACTION_HASH STRING,
    VALUE FLOAT
);

CREATE OR REPLACE TABLE ETH.ETH_SCHEMA.TRANSACTIONS (
    BLOCK_HASH STRING,
    BLOCK_NUMBER INT,
    BLOCK_TIMESTAMP TIMESTAMP,
    DATE DATE,
    FROM_ADDRESS STRING,
    GAS INT,
    GAS_PRICE STRING,
    HASH STRING,
    INPUT STRING,
    LAST_MODIFIED TIMESTAMP,
    MAX_FEE_PER_GAS STRING,
    MAX_PRIORITY_FEE_PER_GAS STRING,
    NONCE STRING,
    RECEIPT_CONTRACT_ADDRESS STRING,
    RECEIPT_CUMULATIVE_GAS_USED INT,
    RECEIPT_EFFECTIVE_GAS_PRICE STRING,
    RECEIPT_GAS_USED INT,
    RECEIPT_STATUS INT,
    TO_ADDRESS STRING,
    TRANSACTION_INDEX INT,
    TRANSACTION_TYPE INT,
    VALUE FLOAT
);

-- set up a month variable
-- SET CURRENT_MONTH_PATTERN = (
--   Select CONCAT('.*date=',TO_VARCHAR(CURRENT_DATE(),'YYYY-MM'),'.*')
-- );

-- (exception case: on day 1 of the month, we use last month data)
SET CURRENT_MONTH_PATTERN = (
    SELECT CONCAT(
        '.*date=', TO_VARCHAR(CURRENT_DATE() - 3, 'YYYY-MM'), '.*'
    )
);
SELECT $CURRENT_MONTH_PATTERN; -- return: .*date=2026-07.*


-- 使用 LIST 指令加上 PATTERN 參數測試配對
LIST @ETH.ETH_SCHEMA.CONTRACTS_STAGE PATTERN = $CURRENT_MONTH_PATTERN; -- noqa:

-- Commands used to populate the 3 tables
-- created with the data coming from the Stages:

COPY INTO ETH.ETH_SCHEMA.CONTRACTS
    FROM(
    select
    t.$1:address,
    t.$1:block_hash,
    t.$1:block_number,
    t.$1:block_timestamp,
    t.$1:bytecode,
    t.$1:date,
    t.$1:last_modified
    from @ETH.ETH_SCHEMA.CONTRACTS_STAGE t
    )
    PATTERN = $CURRENT_MONTH_PATTERN;

COPY INTO ETH.ETH_SCHEMA.TOKEN_TRANSFERS
    FROM (
    select
    t.$1:block_hash,
    t.$1:block_number,
    t.$1:block_timestamp,
    t.$1:date,
    t.$1:from_address,
    t.$1:to_address,
    t.$1:last_modified,
    t.$1:log_index,
    t.$1:token_address,
    t.$1:transaction_hash,
    t.$1:value

    from @ETH.ETH_SCHEMA.TOKEN_TRANSFERS t
    )
    PATTERN = $CURRENT_MONTH_PATTERN;

COPY INTO ETH.ETH_SCHEMA.TRANSACTIONS
    FROM (
    select
    t.$1:block_hash,
    t.$1:block_number,
    t.$1:block_timestamp,
    t.$1:date,
    t.$1:from_address,
    t.$1:gas,
    t.$1:gas_price,
    t.$1:hash,
    t.$1:input,
    t.$1:last_modified,
    t.$1:max_fee_per_gas,
    t.$1:max_priority_fee_per_gas,
    t.$1:nonce,
    t.$1:receipt_contract_address,
    t.$1:receipt_cumulative_gas_used,
    t.$1:receipt_effective_gas_price,
    t.$1:receipt_gas_used,
    t.$1:receipt_status,
    t.$1:to_address,
    t.$1:transaction_index,
    t.$1:transaction_type,
    t.$1:value

    from @ETH.ETH_SCHEMA.TRANSACTIONS t
    )
    PATTERN = $CURRENT_MONTH_PATTERN;