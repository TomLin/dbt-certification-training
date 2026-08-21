{# 下面是範例，說明怎麼說使用 codegen 套件的 macro #}
{# {{ codegen.generate_source(schema_name='eth_schema', database_name='eth', include_schema=True) }} #}


{# 下面的範例，是用 dbt_utils.star 來說明怎麼列出部份的欄位 #}

{# select
    {{ dbt_utils.star(
        from = ref('init_transactions_enriched'),
        except = ['new_field'],
        quote_identifiers=False,
        prefix = 'init_') }}

from {{ ref('init_transactions_enriched') }} #}

{# 下面的範例，則是說明怎麼用 audit_helper 來幫忙比對資料(row-wise) #}

