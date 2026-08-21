
# 意外在 local master 直接 commit，之後透過 PR 合併回 origin/master 的歷史變化

## 情境重建

假設保護規則要求所有進入 `origin/master` 的變更都必須透過 Pull Request。

### Step 1 — 原本同步

```
origin/master:  A
local master:   A
```

### Step 2 — 不小心在 local master 上直接 commit

```
local master:   A---B---C
origin/master:  A
```

### Step 3 — 發現錯誤，切出新分支

因為新分支是從目前的 local master（A-B-C）切出來的，所以新分支天生就「同步」了，不需要額外動作：

```
fix-branch:     A---B---C   (從 local master 切出，內容相同)
local master:   A---B---C
origin/master:  A
```

### Step 4 — push fix-branch，開 PR，merge 進 origin/master

這裡的結果取決於 remote 上 PR 的 merge 策略（GitHub/GitLab 設定）：

| Merge 策略                     | origin/master 結果 | 說明                                         |
| ------------------------------ | ------------------ | -------------------------------------------- |
| **Merge commit**（預設） | `A---B---C---M`  | B、C 原封不動保留，多一個 merge commit M     |
| **Squash and merge**     | `A---S`          | B、C 被壓成一個新 commit S，雜湊（hash）不同 |
| **Rebase and merge**     | `A---B'---C'`    | B、C 被重放，內容一樣但 commit hash 通常會變 |

## 關鍵重點：local master 會跟 origin/master「分岔」

不管哪種策略，**你的 local master（A-B-C）幾乎不會跟 merge 後的 origin/master 完全一致**（除非剛好是 fast-forward，但那只有在完全沒開 PR、直接 push 才會發生——這裡走了 PR 流程通常不會是這種情況）。

也就是說 merge 完之後：

```
origin/master:  A---B---C---M      (或 A---S，或 A---B'---C')
local master:   A---B---C          (還停在舊狀態，不知道 M/S/B'C' 的存在)
```

如果這時候直接在 local master 上繼續工作或 `git pull`，可能會出現：

- **Merge commit 策略**：`git pull` 通常可以順利 fast-forward 或小 merge，因為 B、C 的內容（不是新的，只是多了 M）還在。
- **Squash / Rebase 策略**：local 的 B、C 和 remote 的 S/B'C' 是「內容相同但 hash 不同」的重複提交，`git pull` 會產生沒必要的 merge commit，甚至衝突。

## 建議收尾動作

PR merge 完成後，清理本地的 master，讓它跟 remote 對齊：

```bash
git fetch origin
git checkout master
git reset --hard origin/master   # 丟掉本地那份舊的 A-B-C，改用乾淨的 origin 版本
git branch -d fix-branch          # 已經 merge 完，分支可以刪了
```

這樣 local master 才會跟 origin/master 的真實歷史（不管是 merge commit、squash 還是 rebase 產生的）完全一致，避免之後重複 commit 或衝突。
