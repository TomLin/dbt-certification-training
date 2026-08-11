# Notes on dbt Shell Commands

## dbt run

```Shell
dbt run # rebuild all models
dbt run --select <model>
dbt run -s <model> # shortcut for `select`
```

```Shell
dbt run --empty # 使用 empty flag, 會創造 model，但是不會 populate data (table 裡面的資料是空的)，只是用來驗證logic正確
dbt run --fail-fast # 即便有多個 concurrent modle dag run at the same time，只要有一個 model fails，其它的也會直接停止
```

## dbt flags 也可以放在 dbt_project.yml 專案 level 上

參考連結：[docs.getdbt.com/reference/global-configs/about-global-configs?version=2.0](https://docs.getdbt.com/reference/global-configs/about-global-configs?version=2.0)

裡面也有 available flags 的 section，可以閱讀
