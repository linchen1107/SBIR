# 快速指令參考手冊

> 這是你的個人化指令中心，收錄最常用的指令。點擊標題可跳轉到完整文檔。

**最後更新**: 2025-01-10

---

## 🚀 [日常開發](00-getting-started/01-development-workflows.md#模式一日常開發-daily-development)

### 修改 Python 程式碼後重啟
```bash
docker-compose up -d --build
```
📖 [詳細說明](00-getting-started/01-development-workflows.md#模式一日常開發-daily-development)

---

## 🔄 [徹底重置環境](00-getting-started/01-development-workflows.md#模式二徹底重置-complete-reset)

### 1. 清除所有容器和資料
```bash
docker-compose down -v
```

### 2. 重建並啟動
```bash
docker-compose up -d --build
```

### 3. 初始化資料庫
```bash
# 建立 public schema 的所有表格
docker-compose exec web python sql/setup_database.py

# 匯入 public schema 的核心資料
docker-compose exec web python sql/data_import/import_database.py

# 建立 web_app schema 的所有表格
docker-compose exec web python sql/setup_web_app.py

# 標記資料庫遷移狀態
docker-compose exec web flask db stamp head

# 執行資料庫遷移
docker-compose exec web flask db upgrade
```

### 4. 設置管理員
```bash
docker exec -it smartcodex-postgres psql -U postgres -d nsn_database
```
```sql
UPDATE web_app.users SET role = 'admin' WHERE username = 'C112118237';
```
```sql
UPDATE web_app.users SET role = 'user' WHERE username = 'C112118237';
```

📖 [詳細說明](00-getting-started/01-development-workflows.md#模式二徹底重置-complete-reset)

---

## 💾 [備份與還原](04-deployment/02-database-backup-restore.md)

### 匯出資料（互動式）
```bash
docker-compose exec web python scripts/export_to_sql.py
```
📖 [詳細說明](04-deployment/02-database-backup-restore.md)

### 匯出 web_app schema
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --prefix backup --skip-json
```
📖 [詳細說明](04-deployment/02-database-backup-restore.md)

### 還原資料（互動式）
```bash
docker-compose exec web python scripts/import_from_sql.py
```
📖 [詳細說明](04-deployment/02-database-backup-restore.md)

### 還原資料（指定檔案）
```bash
docker-compose exec web python scripts/import_from_sql.py --sql-file export.sql --yes
```
📖 [詳細說明](04-deployment/02-database-backup-restore.md)

### 完整備份還原流程
```bash
# 1. 匯出資料
docker-compose exec web python scripts/export_to_sql.py

# 2. 重建環境
docker-compose down -v
docker-compose up -d --build

# 3. 等待資料庫啟動（約 10 秒）
timeout /t 10

# 4. 初始化 Schema
docker-compose exec web python sql/setup_database.py
docker-compose exec web python sql/data_import/import_database.py
docker-compose exec web python sql/setup_web_app.py
docker-compose exec web flask db stamp head

# 5. 升級資料庫
docker-compose exec web flask db upgrade

# 6. 還原資料
docker-compose exec web python scripts/import_from_sql.py
```
📖 [詳細說明](00-getting-started/01-development-workflows.md#模式四完全更新並備份還原資料-complete-update-with-data-backup--restore)

---

## 🔀 [Git 工作流程](04-deployment/00-git-workflow.md)

### 標準推送流程
```bash
# 1. 拉取最新程式碼
git pull origin main

# 2. 推送到 GitHub
git push origin main

# 3. 推送到 Gitea
git push gitea main
```
📖 [詳細說明](04-deployment/00-git-workflow.md#完整提交流程)

### 首次設定 Gitea Remote
```bash
# 檢查目前 remote
git remote -v

# 新增 Gitea remote
git remote add gitea http://163.18.22.51:3000/CIL-Team/SmartCodexAI.git

# 首次推送
git push -u gitea main
```
📖 [詳細說明](04-deployment/00-git-workflow.md#初始設定新增-gitea-為-remote)

---

## 🔍 [日誌系統查詢](05-development/01-logging-system.md)

### 查看應用程式日誌
```bash
# 即時查看日誌
docker-compose logs -f web

# 查看最後 100 行
docker-compose logs --tail=100 web

# 查看資料庫日誌
docker-compose logs -f db
```

📖 [詳細說明](05-development/01-logging-system.md)

---

## 📚 文檔導覽

### 完整文檔索引
📖 [查看 README.md](README.md) - 完整的文檔導覽

### 常用文檔快速連結
- [開發工作流程](00-getting-started/01-development-workflows.md)
- [資料庫架構](02-database/00-architecture.md)
- [INC 搜尋使用指南](06-user-guides/00-inc-search-guide.md)
- [測試策略](05-development/00-testing-strategy.md)

---

**使用提示**:
- 點擊 📖 圖示後的連結可跳轉到原始文檔的具體段落
- 所有指令都經過測試，可直接複製使用
- 如需更詳細的說明，請參考完整文檔
