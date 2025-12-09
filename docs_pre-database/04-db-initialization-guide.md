# 資料庫初始化與重置指南 (Database Initialization & Reset Guide)

本文件說明如何初始化、重置與升級資料庫環境。

---

## 重置與初始化資料庫 (Reset & Initialize Database)

當您需要一個**絕對乾淨的全新資料庫環境**，請使用此流程。

**⚠️ 警告：此流程將會徹底刪除您的所有資料庫資料！**

### 指令流程

#### 步驟 1：徹底清除環境 (包含資料庫)
```bash
docker-compose down -v
```

#### 步驟 2：重新建置並啟動所有服務
```bash
docker-compose up -d --build
```

#### 步驟 3：初始化資料庫
```bash
# 3.1 建立 public schema 的所有表格
docker-compose exec web python sql/setup_database.py

# 3.2 匯入 public schema 的核心資料
docker-compose exec web python sql/data_import/import_database.py

# 3.3 建立 web_app schema 的所有表格 (初始化應用層表結構)
docker-compose exec web python sql/setup_web_app.py
```

#### 步驟 4：更新遷移狀態
```bash
# 告訴系統所有表格都已建立，讓它不要再嘗試執行遷移
docker-compose exec web flask db stamp head
```

#### 步驟 5：確保資料庫模型最新
```bash
# 執行與應用程式模型同步
docker-compose exec web flask db upgrade
```

---

## 設置管理員權限 (Admin Setup)

若需測試管理功能，可手動將使用者提升為管理員：

```bash
docker exec -it smartcodex-postgres psql -U postgres -d nsn_database
```

```sql
-- 設為管理員
UPDATE web_app.users SET role = 'admin' WHERE username = 'C112118237';

-- 恢復為一般使用者
UPDATE web_app.users SET role = 'user' WHERE username = 'C112118237';
```

---

## 資料庫備份與還原

請參閱 [05-backup-restore.md](05-backup-restore.md) 了解完整的備份還原流程。
