 

# Notes on dbt Shell Commands

## dbt run

```Shell
dbt run # rebuild all models
dbt run --select <model>
dbt run -s <model> # shortcut for `select`
```

```Shell
dbt run --empty # 使用 empty flag, 會創造 model，但是不會 populate data (table 裡面的資料是空的)，只是用來驗證logic正確
dbt run --fail-fast # 即便有多個 concurrent model dag run at the same time，只要有一個 model fails，其它的也會直接停止
```

### dbt flags 也可以放在 dbt_project.yml 專案 level 上

參考連結：[docs.getdbt.com/reference/global-configs/about-global-configs?version=2.0](https://docs.getdbt.com/reference/global-configs/about-global-configs?version=2.0)

裡面也有 available flags 的 section，可以閱讀

### dbt run 也可以只執行某個資料夾下的models

```Shell
dbt run -s staging.* # 這樣就只會執行在 staging 下面的 models
```

## dbt compile -m <model_name>

這一個指令，是將 model 的 jinja template 轉譯成實際的 sql 指令，給資料庫執行，

上面的指令，也可以寫成

```Shell
dbt compile -s <model_name>
```

## dbt ls

這一個指令，可以將在專案下的dbt models, sources, seeds 資料夾的內容，還有dbt test 的欄位

```Shell
dbt ls --resource-type source # 只列出篩選的 sources 資料
```

## dbt clean

這個指令會把 target/ 下的東西，都清除，target folder 是存 dbt 在執行時(例如 dbt run, dbt compile, dbt docs generate))產生的 artifacts.

裡面的檔案會包含：

- manifest.json：整個專案編譯後的完整地圖，所有 models、sources、seeds、snapshots、tests、macros與相依關係（DAG）
- catalog.json：`dbt docs generate` 時去資料庫查回來的實際表格/欄位/型別 metadata，與 manifest.json 搭配組成文件網站
- run_results.json：最近一次執行的結果，哪些 model 成功/失敗/被跳過、各自執行時間、測試結果
- compiled/：每個 model 經 Jinja 渲染後（`ref()`、`source()`、macro 都已展開）的純 SQL，尚未加上 DDL 包裝，適合拿來 debug
- run/：真正送進資料庫執行的最終 SQL（例如包了 `create or replace table ... as (...)` 的完整語句）
- graph.gpickle/graph_summary.json：dbt 內部用 networkx 序列化的 DAG 物件，供內部運算使用，一般不會手動查看
- index.html：`dbt docs generate` 產生的靜態文件網站本體，`dbt docs serve` 用來顯示它

也會把 dbt_packages/ 資料夾下的東西，清掉。

dbt_packages/ 是 dbt 套件依賴的安裝目錄，功能類似 npm 的 node_modules/ 或 Python 的 venv/。

### 運作方式

1. 你在專案根目錄的 packages.yml（新版也可用 dependencies.yml）宣告要用的套件，例如：

```YAML
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

2. 執行 dbt deps 時，dbt 會把這些套件（通常是別人寫好的 dbt 專案，裡面有 macros / models）下載下來，解壓縮放進 dbt_packages/ 資料夾裡，每個套件一個子目錄。
3. 之後你就可以在自己的 SQL 裡呼叫套件提供的 macro，例如dbt_utils.generate_surrogate_key(...)、dbt_utils.date_spine(...) 等

### 重點提醒

* 跟 `target/` 一樣，是 **可重新產生的產物** ，不該進版控，通常會列在 `.gitignore` 裡
* 只要有 `packages.yml`，任何人 clone 專案後執行 `dbt deps` 就能重建這個資料夾，所以刪掉也沒關係

## dbt build

它會執行 dbt compile, dbt run, dbt test 等功能，簡化執行的指令

```Shell
dbt build -s eth_activity_per_day
```

## dbt tag

使用tag指令，可以讓我們篩選，只執行部份的resource

- 注意有comma 和沒有 comma 的差別，一個是and，一個是 or

```Shell
dbt run --select tag:eth tag:crypto # 這個是union (or)

# 這個是intersection (and) 要同時有兩個tags的model 才會執行
dbt run --select tag:eth,tag:crypto
```

另外我們也可以把資料夾和tag一起使用，進行篩選

```Shell
# 表示它只會執行在 marts 資料夾下，並且有stablecoin 這個 tag 的 model
dbt run -m marts.*,tag:stablecoin
```

- 另外tag也可以指定執行上、下游的dependent model，使用的符號是 +

```Shell
dbt run --select +tag:daily # 表示tag daily 和它上游的table 都會重新執行
dbt run --select 2+tag:daily # 表示tag daily 和它上游2層的table 都會重新執行

dbt run --select tag:daily+ # 表示tag daily 和它下游的table 都會重新執行
dbt run --select tag:daily+2 # 表示tag daily 和它下游2層的table 都會重新執行
```

- tag 好用的地方，例如和frequency 相關的table，就可以使用，例如 weekly，有了這個tag，就可以讓周更新的table，重新執行

## dbt 中 + 號的用法

這個 + 號用法很多元，也可以用在 model 上面

```Shell
dbt run --select model_name+ # 這個表示，在model下游的table，也會被執行

# 這個表示，向上、向下執行一層的 model
dbt run -m 1+eth_activity_per_day+1
```

## dbt exclude

使用 exclude，可以執行全部models，除了`XXXX`之外

```Shell

# 基本語法： dbt run --exclude my_model_to_exclude
# 下面的語法，會執行有任一個tag，但是會把 stablecoin_activity_per_day 這個模型給排除掉
dbt run -m tag:daily tag:stablecoin --exclude stablecoin_activity_per_day
```

## project YMAL

dbt 要啟動前，都需要讀 project ymal file。可以使用 `--project-dir`來指定ymal 所在的位置。

```Shell
dbt run --empty --project-dir <folder_name>
```

## ymal 當中的換行

在 YAML 規範裡，區塊純量（block scalar）有兩種摺疊方式：

- `|`（literal block）：保留換行符，逐行照抄。
- `>`（folded block）：把換行符號換成空格（除非該行是空白行，會變成一個換行），常用於把長字串拆成多行寫、但實際上想要它變成一行。

## dbt package 的用法

- 基本上 dbt 當中的 package，自己本身就是一個 dbt project，可以到 dbt package 的資料夾下，會看到有 dbt_project.yml 的檔案
- 除此之外，在 dbt 專案上，還會有 packages.yml and package-lock.yml (這個 lock 檔案，是用來鎖定package的特定版本的)) 的檔案
