# 在 dbt Python 模型 (Python models) 中，每個模型都會定義一個 model(dbt, session) 函式，這兩個參數的定義與功用如下：

# dbt：由 dbt Core 編譯的類別（每個模型皆獨立專屬），讓你的 Python 程式碼能夠與 dbt 專案及 DAG 流程脈絡整合。
# 它提供了讀取上游模型（dbt.ref()）、資料來源（dbt.source()）、讀取設定參數（dbt.config.get()）以及判斷執行狀態（如 dbt.is_incremental、dbt.this）等功能。

# session：代表底層資料平台（Data Platform）連線至 Python 執行環境的連線類別。主要用於將資料庫內的表格讀取為 DataFrame，並在轉換完成後將 DataFrame 寫回資料庫表格中
# （例如在 Snowflake 為 Snowpark Session，在 Databricks/PySpark 則對應 SparkSession）。

# Not every Python function needs those two arguments(dbt and session).
# The requirement applies strictly to the main entry-point function named model(dbt, session):
# Entry-Point Function (def model(dbt, session)): Required.
# When you run dbt run, dbt explicitly expects a function named model that takes exactly these two arguments.

# Helper / Custom Functions: Not Required.
# Any auxiliary function you define inside the .py file (such as data-cleaning helpers or custom transformations)
# can take any arguments you define.


# 如果要在 dbt 的 python 當中使用套件，需要滿足兩個條件:
# 第一，是需要有 import section
# 第二，接著還是需要在 model 這個函數裡面的 dbt object, 進行 config, 讓 dbt 知道

# holidays 這一個套件，不在本機開發env中，而是在snowflake的資料平台裡面，所以Pylance會跳出warning，
# 找不到這個套件，可以利用 # type: ignore 的方式，讓Pylance忽略

import holidays # type: ignore

def is_holiday(date_col):
    french_holidays = holidays.France()
    is_holiday = (date_col in french_holidays)
    return is_holiday


def model(dbt, session):

    dbt.config(packages=['holidays', 'pandas', 'pyarrow'])

    # 這個 model 的 entry_point，結果會在資料庫中，建立一個 table `python_model``
    python_created_tbl = dbt.ref('stablecoin_activity_per_day')

    # 我們無法直接使用 print() 來看我們要的資訊，可以walk around by using `raise Exception`
    # raise Exception(type(python_created_tbl))

    python_created_tbl = python_created_tbl.to_pandas()
    python_created_tbl['is_holiday'] = python_created_tbl["DATE"].apply(is_holiday)

    return python_created_tbl