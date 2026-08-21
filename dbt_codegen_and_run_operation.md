# dbt Codegen 與 run-operation

## 如何把 codegen 產出的 YAML 輸出到一個檔案

在 dbt 中，`dbt-codegen` 產生的 YAML 是印到終端機（stdout / log），本身不會自動存成檔案，所以要輸出到檔案通常用以下幾種方式：

### 1. 用 shell 重導向（推薦，dbt Core 1.5+）

加上全域的 `--quiet` 旗標，把多餘的 log 訊息關掉，只留下 macro 印出的 YAML，再重導向到檔案：

```bash
dbt --quiet run-operation generate_source --args '{"schema_name": "raw"}' > models/staging/_sources.yml
```

或是產 model 的 schema：

```bash
dbt --quiet run-operation generate_model_yaml --args '{"model_names": ["stg_transactions"]}' > models/staging/_stg_transactions.yml
```

> 注意：`--quiet` 要放在 `dbt` 後面（global flag），不是放在 `run-operation` 後面。

### 2. 舊版 dbt（沒有 `--quiet`）

沒有 `--quiet` 的話，重導向會把 "Running with dbt=..." 等訊息也一起寫進檔案，變成不是純 YAML。這時通常是：

- 直接在終端機看輸出，手動複製貼上到新的 `.yml` 檔，或
- 去看 `logs/dbt.log`，裡面會有完整內容，用文字編輯器把 YAML 區塊複製出來。

### 3. dbt Cloud IDE

在 IDE 執行 `dbt run-operation ...` 後，結果面板會顯示產生的 YAML，可以直接點選複製，貼到新建的 `.yml` 檔案中。

實務上最常見流程是「用 codegen 產生 → 複製/重導向存成 `.yml` → 再依需求手動微調（加 description、tests 等）」，因為 codegen 產出的通常是骨架，還是要人工補充文件說明。

## run-operation 是什麼

`dbt run-operation` 是 dbt CLI 的一個指令，用來**手動執行一個 macro**，而不是用來跑 model。

### 背景概念

dbt 的 macro 本質上就是用 Jinja 寫的函式，平常大多是在編譯 SQL 時被 dbt 自動呼叫（例如 `ref()`、`source()`，或你自訂的 macro 被某個 model 呼叫）。但有些 macro 並不是拿來組 SQL 給 model 用的，而是拿來做「一次性的操作」，例如：

- 產生 YAML（`dbt-codegen` 的 `generate_source`、`generate_model_yaml`）
- 建立/刪除 schema
- 授權（grants）
- 清理過期的資料表
- 執行任意一段自訂邏輯

這類 macro 沒有對應的 model 可以觸發它們，所以 dbt 提供了 `run-operation` 這個指令，讓你可以**直接呼叫任何一個 macro**。

### 語法

```bash
dbt run-operation <macro_name> --args '{"key": "value"}'
```

例如：

```bash
dbt run-operation generate_source --args '{"schema_name": "raw", "database_name": "analytics"}'
```

這裡：

- `generate_source` 是 macro 名稱（來自 `dbt-codegen` package）
- `--args` 是傳給這個 macro 的參數，用 YAML/JSON 格式的字典表示，對應 macro 定義裡的參數名稱

### 跟一般執行 model 的差異

| | `dbt run` | `dbt run-operation` |
|---|---|---|
| 執行對象 | model（`.sql` 檔） | 任意 macro |
| 目的 | 產生資料表/視圖 | 執行任意邏輯（產文件、DDL、清理等） |
| 有沒有回傳結果集 | 有（存進資料庫） | 通常是印出訊息/log，或執行 side effect（如 grant、drop） |

簡單說：**model 是資料轉換的邏輯，會被 `dbt run` 執行；macro 若不是被 model 呼叫，而是想單獨執行一次，就用 `dbt run-operation`。**
</content>
