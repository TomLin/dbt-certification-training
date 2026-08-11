{# 基本的 macro 練習 #}
{% macro eth_convert(column_name) %}
    sum({{ column_name }}) / 1e18
{% endmacro %}

{% macro stablecoin_convert(column_name) %}
    sum({{ column_name }}) / 1e6
{% endmacro %}

{# 更通用轉換的 macro，符合 don't repeat yourself 原則 #}
{% macro convert(column_name, factor) %}
    sum({{ column_name }}) / 1e{{ factor }}
{% endmacro %}




