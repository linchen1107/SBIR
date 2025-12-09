# 部署維運文檔

本目錄包含 Git 工作流程、伺服器部署、資料庫備份還原等維運相關文檔。

## 📚 文檔列表

| 檔案名稱 | 內容摘要 |
|----------|----------|
| [00-git-workflow.md](00-git-workflow.md) | Git 標準推送流程、GitHub/Gitea 雙遠端設定 |
| [01-gunicorn-deployment.md](01-gunicorn-deployment.md) | Gunicorn 伺服器部署設定與 WSGI 進入點的詳細說明 |
| [02-database-backup-restore.md](02-database-backup-restore.md) | **【重要】** 資料庫備份與還原完整指南，包含互動式/參數式匯出 |

## 🎯 常用操作

### Git 工作流程
```bash
# 1. 拉取最新程式碼
git pull origin main

# 2. 推送到 GitHub
git push origin main

# 3. 推送到 Gitea
git push gitea main
```
📖 [詳細說明](00-git-workflow.md)

### 資料庫備份
```bash
# 互動式匯出（推薦）
docker-compose exec web python scripts/export_to_sql.py
```
📖 [詳細說明](02-database-backup-restore.md)

### 更多常用指令
請參考 [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) 獲取完整的指令列表。

---

[返回文檔首頁](../README.md)
