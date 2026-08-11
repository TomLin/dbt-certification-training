# dbt Jinja 中的 Python 式語法與 Macro 封裝指南
# Python-like Syntax and Macro Encapsulation in dbt Jinja

本文整理了在 dbt Jinja 中常用的 Python 式資料結構與操作語法，並示範如何將這些技巧封裝為可重複使用的 dbt Macro。

---

## 第一部分：dbt Jinja 中的 Python 式語法 (Python-like Syntax in dbt Jinja)

### 繁體中文說明 (Traditional Chinese)

在 dbt 所使用的 Jinja 範本引擎中，語法深度融合了許多 Python 的資料結構與操作習慣。以下以**循序漸進（Step-by-Step）**的方式介紹可以在 dbt Jinja 中使用的 Python 式語法與範例。

#### 步驟 1：陣列／清單（Lists `[]`）

Jinja 支援與 Python 相同的 List 語法，可用來定義清單、提取索引元素，以及透過 `in` 檢查元素是否存在。

**代碼示範：**

```jinja
{% set macro_platforms = ['facebook', 'google', 'tiktok'] %}

-- 1. 存取指定索引 (0-indexed)
SELECT '{{ macro_platforms[0] }}' AS primary_platform

-- 2. 判斷元素是否存在 (in)
{% if 'google' in macro_platforms %}
  , 'Google is included' AS check_result
{% endif %}
```

#### 步驟 2：字典／關聯陣列（Dictionaries `{}`）

與 Python 的 `dict` 相同，可以使用 Key-Value 結構儲存映射資料，並支援使用 `['key']` 或 `.key` 存取數值，以及使用 `.items()` 進行迴圈迭代。

**代碼示範：**

```jinja
{% set column_mappings = {'usr_id': 'user_id', 'created_at': 'registered_at'} %}

-- 1. 存取鍵值
SELECT 
  usr_id AS {{ column_mappings['usr_id'] }},
  created_at AS {{ column_mappings.created_at }}

-- 2. 使用 .items() 進行迴圈迭代
SELECT
{% for old_col, new_col in column_mappings.items() %}
  {{ old_col }} AS {{ new_col }}{% if not loop.last %},{% endif %}
{% endfor %}
```

#### 步驟 3：字串與物件方法（String & Object Methods）

在 Jinja 中可以直接調用許多原生 Python 字串與物件的方法，例如 `.upper()`, `.lower()`, `.replace()`, `.startswith()`, `.split()` 等。

**代碼示範：**

```jinja
{% set raw_table_name = "stg_customers_v1" %}

-- 1. 原生 Python 字串方法
SELECT 
  '{{ raw_table_name.upper() }}' AS upper_name,
  '{{ raw_table_name.replace("stg_", "fct_") }}' AS target_table

-- 2. 字串開頭與切割檢查
{% if raw_table_name.startswith("stg_") %}
  -- 取得切割後的第二個單詞
  {% set parts = raw_table_name.split("_") %}
  -- parts[1] 會拿到 "customers"
{% endif %}
```

#### 步驟 4：三元運算子（Ternary Operator）

Python 的條件單行寫法 `A if condition else B` 可以在 Jinja 表達式 `{{ ... }}` 中直接使用。

**代碼示範：**

```jinja
{% set target_env = target.name %}

-- 根據環境動態決定限制筆數 (Ternary Expression)
SELECT * 
FROM {{ ref('raw_orders') }}
LIMIT {{ 100 if target_env == 'dev' else 1000000 }}
```

#### 步驟 5：內建函數與迴圈範圍（`range()`）

Jinja 提供與 Python 類似的 `range()` 函數用於生成數字序列，並可搭配內建 Filter 或 Python 的 `.length` 概念（Jinja 使用 `| length`）來進行長度計算。

**代碼示範：**

```jinja
{% set month_count = 3 %}

-- 使用 range(start, stop) 產生數字迴圈
{% for i in range(1, month_count + 1) %}
SELECT {{ i }} AS month_number UNION ALL
{% endfor %}
```

---

### English Explanation

In dbt's Jinja templating engine, many syntax behaviors and data structures are directly borrowed from Python. Here is a **step-by-step** breakdown of Python-like usages in dbt Jinja with clean macro/SQL examples.

#### Step 1: Lists / Arrays (`[]`)

Jinja supports Python-style lists. You can define lists, access elements using zero-based indexing, and check membership using the `in` operator.

**Code Demo:**

```jinja
{% set macro_platforms = ['facebook', 'google', 'tiktok'] %}

-- 1. Access by index (0-indexed)
SELECT '{{ macro_platforms[0] }}' AS primary_platform

-- 2. Check membership using 'in'
{% if 'google' in macro_platforms %}
  , 'Google is included' AS check_result
{% endif %}
```

#### Step 2: Dictionaries (`{}`)

Just like Python dictionaries, you can use key-value mappings in Jinja. You can retrieve values using bracket `['key']` or dot `.key` notation, and iterate over items using `.items()`.

**Code Demo:**

```jinja
{% set column_mappings = {'usr_id': 'user_id', 'created_at': 'registered_at'} %}

-- 1. Key access
SELECT 
  usr_id AS {{ column_mappings['usr_id'] }},
  created_at AS {{ column_mappings.created_at }}

-- 2. Iterating with .items()
SELECT
{% for old_col, new_col in column_mappings.items() %}
  {{ old_col }} AS {{ new_col }}{% if not loop.last %},{% endif %}
{% endfor %}
```

#### Step 3: String and Object Methods

Many native Python string and object methods can be invoked directly inside Jinja expressions, such as `.upper()`, `.lower()`, `.replace()`, `.startswith()`, and `.split()`.

**Code Demo:**

```jinja
{% set raw_table_name = "stg_customers_v1" %}

-- 1. Native Python string methods
SELECT 
  '{{ raw_table_name.upper() }}' AS upper_name,
  '{{ raw_table_name.replace("stg_", "fct_") }}' AS target_table

-- 2. Method checks and splitting
{% if raw_table_name.startswith("stg_") %}
  -- Splitting string into list: parts[1] yields "customers"
  {% set parts = raw_table_name.split("_") %}
{% endif %}
```

#### Step 4: Ternary Expressions

Python's ternary expression format `X if condition else Y` works natively inside Jinja output blocks `{{ ... }}`.

**Code Demo:**

```jinja
{% set target_env = target.name %}

-- Dynamically assign limit based on environment
SELECT * 
FROM {{ ref('raw_orders') }}
LIMIT {{ 100 if target_env == 'dev' else 1000000 }}
```

#### Step 5: Built-in Range Function (`range()`)

Jinja provides the `range()` function, identical to Python, for generating sequences of numbers in loops.

**Code Demo:**

```jinja
{% set month_count = 3 %}

-- Using range(start, stop) in loops
{% for i in range(1, month_count + 1) %}
SELECT {{ i }} AS month_number UNION ALL
{% endfor %}
```

---

## 第二部分：將技巧封裝為 Macro (Encapsulating into dbt Macros)

### 繁體中文說明 (Traditional Chinese)

在 dbt 中，將上述類 Python 的 Jinja 技巧封裝成可重複使用的 **Macro**，可以大幅提升程式碼的重用性與模組化程度。以下透過**循序漸進（Step-by-Step）**的方式，示範如何建立三個常見且實用的 Macro 範例。

#### 步驟 1：基礎清單處理（List & String Handling Macro）

**目標：** 傳入欄位名稱清單與前綴（Prefix），自動生成加上前綴並重命名（Alias）欄位的 SQL 片段。

**建立 Macro 檔案 (`macros/prefix_columns.sql`)：**

```jinja
{% macro prefix_columns(columns, prefix) %}
  {# 1. 使用 List comprehension 或循環，搭配 Python 變數技巧 #}
  {% set prefixed_cols = [] %}
  
  {% for col in columns %}
    {# 使用 Python 字串方法 .startswith() 進行檢查 #}
    {% if not col.startswith(prefix) %}
      {% set new_col = prefix ~ '_' ~ col %}
    {% else %}
      {% set new_col = col %}
    {% endif %}
    
    {# 使用 List .append() 方法（Jinja 內需搭配 do 指令） #}
    {% do prefixed_cols.append(col ~ ' AS ' ~ new_col) %}
  {% endfor %}

  {# 使用 Jinja | join 組合結果 #}
  {{ prefixed_cols | join(',\n  ') }}
{% endmacro %}
```

**在 dbt Model 中使用：**

```sql
SELECT
  {{ prefix_columns(['id', 'stg_name', 'created_at'], 'user') }}
FROM {{ ref('stg_users') }}
```

**編譯後的 SQL：**

```sql
SELECT
  id AS user_id,
  stg_name AS stg_name,
  created_at AS user_created_at
FROM analytics.stg_users
```

#### 步驟 2：字典映射與循環轉換（Dictionary Iteration Macro）

**目標：** 傳入欄位與轉型型態的 Dictionary，自動生成型態轉換（CAST）的 SQL 指令。

**建立 Macro 檔案 (`macros/cast_columns.sql`)：**

```jinja
{% macro cast_columns(column_type_map) %}
  {# 使用 Python Dict .items() 方法轉化為 (key, value) 迴圈 #}
  {% for col, datatype in column_type_map.items() %}
    {# 使用 Python 字串方法 .upper() 轉換型態名稱 #}
    CAST({{ col }} AS {{ datatype.upper() }}) AS {{ col }}{% if not loop.last %},{% endif %}
  {% endfor %}
{% endmacro %}
```

**在 dbt Model 中使用：**

```sql
SELECT
  {{ cast_columns({
      'user_id': 'integer',
      'signup_date': 'date',
      'amount': 'numeric(10, 2)'
  }) }}
FROM {{ ref('raw_transactions') }}
```

**編譯後的 SQL：**

```sql
SELECT
  CAST(user_id AS INTEGER) AS user_id,
  CAST(signup_date AS DATE) AS signup_date,
  CAST(amount AS NUMERIC(10, 2)) AS amount
FROM analytics.raw_transactions
```

#### 步驟 3：綜合技巧——三元運算與動態生成（Dynamic Range & Ternary Macro）

**目標：** 根據環境（dev / prod）動態生成近 N 個月的聯集查詢（UNION ALL），並使用 Ternary Operator 控制範圍。

**建立 Macro 檔案 (`macros/generate_month_series.sql`)：**

```jinja
{% macro generate_month_series(default_months=12) %}
  {# 使用 Ternary Operator (A if condition else B) 根據環境決定長度 #}
  {% set months = 2 if target.name == 'dev' else default_months %}

  {# 使用 Python range() 函數迴圈生成序列 #}
  {% for i in range(0, months) %}
    SELECT 
      DATEADD(month, -{{ i }}, CURRENT_DATE()) AS month_start
    {% if not loop.last %}
    UNION ALL
    {% endif %}
  {% endfor %}
{% endmacro %}
```

**在 dbt Model 中使用：**

```sql
WITH month_spine AS (
  {{ generate_month_series(default_months=6) }}
)
SELECT * FROM month_spine
```

---

### English Explanation

Encapsulating Python-like Jinja techniques into reusable **Macros** allows you to build modular, maintainable dbt projects. Here is a **step-by-step** guide demonstrating how to create three production-grade dbt macros.

#### Step 1: List & String Handling Macro

**Objective:** Pass a list of column names and a prefix string to dynamically generate aliased SQL columns.

**Macro Definition (`macros/prefix_columns.sql`):**

```jinja
{% macro prefix_columns(columns, prefix) %}
  {% set prefixed_cols = [] %}
  
  {% for col in columns %}
    {# Using Python string method .startswith() #}
    {% if not col.startswith(prefix) %}
      {% set new_col = prefix ~ '_' ~ col %}
    {% else %}
      {% set new_col = col %}
    {% endif %}
    
    {# Appending to list using the Jinja 'do' statement #}
    {% do prefixed_cols.append(col ~ ' AS ' ~ new_col) %}
  {% endfor %}

  {{ prefixed_cols | join(',\n  ') }}
{% endmacro %}
```

**Model Usage:**

```sql
SELECT
  {{ prefix_columns(['id', 'stg_name', 'created_at'], 'user') }}
FROM {{ ref('stg_users') }}
```

#### Step 2: Dictionary Iteration Macro

**Objective:** Take a dictionary mapping column names to target data types and generate SQL `CAST` statements.

**Macro Definition (`macros/cast_columns.sql`):**

```jinja
{% macro cast_columns(column_type_map) %}
  {# Iterating over dict key-value pairs using .items() #}
  {% for col, datatype in column_type_map.items() %}
    {# Using Python string method .upper() #}
    CAST({{ col }} AS {{ datatype.upper() }}) AS {{ col }}{% if not loop.last %},{% endif %}
  {% endfor %}
{% endmacro %}
```

**Model Usage:**

```sql
SELECT
  {{ cast_columns({
      'user_id': 'integer',
      'signup_date': 'date',
      'amount': 'numeric(10, 2)'
  }) }}
FROM {{ ref('raw_transactions') }}
```

#### Step 3: Range & Ternary Macro

**Objective:** Combine `range()` and ternary expressions to create a dynamic date-spine query that alters batch size based on execution environment (`dev` vs `prod`).

**Macro Definition (`macros/generate_month_series.sql`):**

```jinja
{% macro generate_month_series(default_months=12) %}
  {# Python ternary operator: X if condition else Y #}
  {% set months = 2 if target.name == 'dev' else default_months %}

  {# Python range() sequence generator #}
  {% for i in range(0, months) %}
    SELECT 
      DATEADD(month, -{{ i }}, CURRENT_DATE()) AS month_start
    {% if not loop.last %}
    UNION ALL
    {% endif %}
  {% endfor %}
{% endmacro %}
```

**Model Usage:**

```sql
WITH month_spine AS (
  {{ generate_month_series(default_months=6) }}
)
SELECT * FROM month_spine
