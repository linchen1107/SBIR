# 日常開發標準流程 (GitHub 為主)

**最佳實踐：** 在推送 (`push`) 任何程式碼之前，永遠先拉取 (`pull`) 遠端的最新變更，確保您的本地版本是最新的。這樣可以避免許多不必要的衝突。

### 完整提交流程

1.  **從 GitHub 拉取最新程式碼**
    ```bash
    git pull origin main
    ```

2.  **推送到 GitHub (您的主要倉庫)**
    ```bash
    git push origin main
    ```

3.  **接著，再推送到 Gitea (您的備份或次要倉庫)**
    ```bash
    git push gitea main
    ```
---

# 初始設定：新增 Gitea 為 Remote

如果你是第一次設定，需要先將 Gitea 加入為遠端倉庫。

### ✅ 設定步驟：

1.  **先檢查目前 remote** (應該只有 GitHub 的 `origin`)
    ```bash
    git remote -v
    ```

2.  **新增 Gitea 這個 remote** (取名叫 `gitea`，避免衝突)
    ```bash
    git remote add gitea http://163.18.22.51:3000/CIL-Team/SmartCodexAI.git
    ```

3.  **(可選) 首次推送 main branch 到 Gitea**
    ```bash
    git push -u gitea main
    ```
---

# 其他推送方式

### 選項 A：分開推送 (建議)

這就是我們建議的標準流程，指令明確，不易出錯。

```bash
# 推到 GitHub
git push origin main

# 推到 Gitea
git push gitea main
```

### 選項 B：一次性同時推送

如果你希望一次 `push` 就同時更新 GitHub 和 Gitea，可以為 `origin` 設定多個推送 URL。

1.  **為 `origin` 新增 Gitea 的推送 URL**
    ```bash
    git remote set-url --add --push origin http://163.18.22.51:3000/CIL-Team/SmartCodexAI.git
    ```
    *(註：執行此指令前，請確保 `origin` 已指向您的 GitHub 倉庫)*

2.  **檢查設定**
    ```bash
    git remote -v
    ```
    你應該會看到 `origin` 有兩個 `(push)` 的 URL。

3.  **以後只要執行一次 push**
    ```bash
    git push origin main
    ```
    就會同時推送到 GitHub 和 Gitea 🎉
