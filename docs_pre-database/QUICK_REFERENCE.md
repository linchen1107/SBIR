# 快速指令參考手冊

> 這是資料庫操作的指令中心，收錄最常用的資料庫建置、還原與維護指令。

**最後更新**: 2025-12-08

---

## 🔄 [徹底重置與初始化](04-db-initialization-guide.md#重置與初始化資料庫-reset--initialize-database)

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

📖 [詳細說明](04-db-initialization-guide.md#重置與初始化資料庫-reset--initialize-database)

---

## 💾 [備份與還原](05-backup-restore.md)

### 匯出資料（互動式）
```bash
docker-compose exec web python scripts/export_to_sql.py
```
📖 [詳細說明](05-backup-restore.md)

### 匯出 web_app schema
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --prefix backup --skip-json
```
📖 [詳細說明](05-backup-restore.md)

### 還原資料（互動式）
```bash
docker-compose exec web python scripts/import_from_sql.py
```
📖 [詳細說明](05-backup-restore.md)

### 還原資料（指定檔案）
```bash
docker-compose exec web python scripts/import_from_sql.py --sql-file export.sql --yes
```
📖 [詳細說明](05-backup-restore.md)

---

## 📚 相關文檔

- [資料庫初始化指南](04-db-initialization-guide.md)
- [資料庫備份與還原](05-backup-restore.md)
- [核心架構說明](00-architecture.md)
- [Public Schema 定義](01-schema-public.md)

