{% macro random_macro()%}

    {# 如果是單行的字串內容，就不需要加上 endset #}
    {# {% set my_string = "hello world" %} #}


    {# 如果是多行的字串內容，就需要加上 endset #}
    {# 下面是組成一個 query 的 string #}
    {% set query %}
    select distinct
        token_address
        from {{ ref('stg_token_transfers') }}
        limit 5
    {% endset %}

    {% if execute %}
    {% set results = run_query(query) %}
    {% set result_list = results.columns[0].values() %}
    {% else %}
    {% set result_list = [] %}
    {% endif %}

    {% set sql_result = [] %}
    {% for item in result_list %}
        {% do sql_result.append("BEGIN"~item~"END") %} -- 這邊 ~ 是 jinja2 的字串連接符號，會把 BEGIN、item、END 連成一個字串
    {% endfor %}

    {{ log(sql_result, info=True) }}  -- 這裡的 log() 是 jinja2 的 function，會把 log 訊息印在 dbt 的 log 裡面，方便 debug

    {# 這裡的 join(', ') 是把 list 轉成 string，並用逗號隔開,
       而 | 在這裡是 filter，下面的寫法，會像是  join(sql_result, ', ') #}
    {{ log(sql_result | join(', '), info=True) }}

    {{ return(result_list) }} -- 這裡的 return() 是 jinja2 的 function，會回傳一個 list 如果沒有用 return()，就會回傳一個 string

{% endmacro %}

{# 補充: 如果只是單純要執行 macro，看它的結果，
   可以使用 dbt run-operation macro #}
