## 使用 seed

- 使用時機：通常是靜態表
- 將csv等檔案，放到dbt專案的seed資料夾
- 之後執行 dbt seed，就會看到database裡面，已經建立了相應的table
- 在seed資料夾中，只有csv的檔案，才會被存入資料庫
- 在snowflake裡面，table name 是不能使用 dash 符號
