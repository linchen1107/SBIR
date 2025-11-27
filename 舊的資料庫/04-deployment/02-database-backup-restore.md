# 資料庫備份與還原指南

本文件說明如何使用 SmartCodexAI 的資料庫匯出與匯入工具，適用於資料備份、環境遷移、開發測試等場景。

---

## 目錄

1. [快速開始](#快速開始)
2. [工具概覽](#工具概覽)
3. [資料匯出（Export）](#資料匯出export)
4. [資料匯入（Import）](#資料匯入import)
5. [完整工作流程範例](#完整工作流程範例)
6. [與部署流程整合](#與部署流程整合)
7. [常見問題與排除](#常見問題與排除)
8. [最佳實踐建議](#最佳實踐建議)
9. [相關資源](#相關資源)

---

## 快速開始

### 🚀 最簡單：互動式使用（推薦）

**不需要記參數，跟著選單選擇即可！**

```bash
# 匯出資料
docker-compose exec web python scripts/export_to_sql.py

# 匯入資料
docker-compose exec web python scripts/import_from_sql.py
```

**特點**：
- ✅ 自動掃描資料庫中所有 schema 和 table
- ✅ 顯示每張表的資料筆數
- ✅ 資料庫結構變動時自動適應
- ✅ 友善的中文介面
- ✅ 執行完成後自動顯示複製指令

---

## 工具概覽

### 匯出工具：`scripts/export_to_sql.py`

**功能：**
- 將 PostgreSQL 資料庫的表資料匯出為 SQL INSERT 語句
- 支援互動式選單選擇 schema 和表
- 可排除特定表
- 可選擇性輸出 JSONL 格式（用於資料分析）
- 自動處理序列（sequence）重置

**輸出檔案：**
- SQL 檔案：包含 `BEGIN`, `INSERT`, `COMMIT` 和序列重置語句
- JSONL 檔案（可選）：每行一筆 JSON 資料

### 匯入工具：`scripts/import_from_sql.py`

**功能：**
- 執行從 `export_to_sql.py` 匯出的 SQL 檔案
- 自動掃描並顯示可用的 SQL 檔案
- 執行前預覽 SQL 內容（INSERT 語句數、涉及的表）
- Transaction 安全執行（失敗自動 rollback）
- 匯入後驗證資料變更

---

## 資料匯出（Export）

### 1. 互動模式（推薦）

在 Docker 環境中執行（無需任何參數）：

```bash
docker-compose exec web python scripts/export_to_sql.py
```

**互動流程：**

**步驟 1：選擇 Schema**
```
📦 步驟 1️⃣: 選擇要匯出的 Schema
============================================================
  [1] web_app (15 張表)
  [2] public (3 張表)
  [3] 全部匯出 (18 張表)
  [Q] 離開

請選擇 [1-3]: 1
```

**步驟 2：選擇匯出方式**
```
📦 步驟 2️⃣: 選擇匯出方式
============================================================
  [1] 匯出全部 15 張表
  [2] 排除特定表後匯出（選擇要排除的表）
  [Q] 返回上一步

請選擇 [1-2]: 2
```

**步驟 3：選擇要排除的表（如果選擇步驟 2 的選項 2）**
```
📦 步驟 3️⃣: 選擇要排除的資料表（可多選）
============================================================
  [1] ☐ users (1,234 筆)
  [2] ☐ documents (5,678 筆)
  [3] ☐ logs (10,000 筆)
  ...

請輸入要排除的表編號（逗號分隔，如 1,3,5）: 3
```

**步驟 4：輸出設定**
```
📦 步驟 4️⃣: 輸出設定
============================================================
  [1] 只輸出 SQL
  [2] 同時輸出 SQL + JSONL

請選擇 [1-2]: 1
```

**步驟 5：輸入檔名前綴**
```
📦 步驟 5️⃣: 輸入檔名前綴
============================================================
檔名前綴（按 Enter 使用預設 'export'）: backup_20250109
```

**最後確認：**
```
📋 匯出摘要
============================================================
Schema: web_app
排除表: 1 張
  ✗ web_app.logs

輸出格式: SQL only
檔案名稱: backup_20250109.sql
儲存位置: /app/sql_exports/backup_20250109.sql
============================================================

確認執行？ [Y/n]: Y
```

**完成後顯示：**
```
✅ 匯出完成！

📁 檔案位置: /app/sql_exports/backup_20250109.sql

📋 複製到主機的指令：
docker cp smartcodex-web:/app/sql_exports/backup_20250109.sql ./sql_exports/backup_20250109.sql
```

---

### 2. 命令列模式

#### 📋 常用指令（可直接複製）

**匯出整個 web_app schema**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --skip-json --prefix web_app_dump
docker cp smartcodex-web:/app/sql_exports/web_app_dump.sql ./sql_exports/
```

**匯出 web_app 但排除特定表**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --exclude-table web_app.alembic_version --exclude-table web_app.cache_table --skip-json --prefix web_app_clean
docker cp smartcodex-web:/app/sql_exports/web_app_clean.sql ./sql_exports/
```

**只匯出特定資料表（單張）**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --include-table web_app.users --skip-json --prefix users_only
docker cp smartcodex-web:/app/sql_exports/users_only.sql ./sql_exports/
```

**只匯出特定資料表（多張）**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --include-table web_app.users --include-table web_app.applications --skip-json --prefix users_and_apps
docker cp smartcodex-web:/app/sql_exports/users_and_apps.sql ./sql_exports/
```

**匯出 public schema**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema public --skip-json --prefix public_dump
docker cp smartcodex-web:/app/sql_exports/public_dump.sql ./sql_exports/
```

**匯出所有 schema**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --schema public --skip-json --prefix full_backup
docker cp smartcodex-web:/app/sql_exports/full_backup.sql ./sql_exports/
```

**同時輸出 SQL + JSONL**
```bash
docker-compose exec web python scripts/export_to_sql.py --schema web_app --prefix web_app_with_json
docker cp smartcodex-web:/app/sql_exports/web_app_with_json.sql ./sql_exports/
docker cp smartcodex-web:/app/sql_exports/web_app_with_json.jsonl ./sql_exports/
```

---

### 3. 參數說明

| 參數 | 說明 | 必填 | 範例 |
|------|------|------|------|
| `--schema <name>` | 指定要匯出的 schema，可重複使用 | ❌ | `--schema web_app` |
| `--include-table <rule>` | **只匯出**指定的資料表，可重複使用 | ❌ | `--include-table web_app.users` |
| `--exclude-table <rule>` | 排除資料表，可重複使用 | ❌ | `--exclude-table web_app.alembic_version` |
| `--prefix <text>` | 輸出檔名前綴（固定檔名，自動覆蓋舊檔） | ❌ | `--prefix web_app_dump` |
| `--skip-json` | 僅輸出 SQL，不產生 JSONL | ❌ | `--skip-json` |
| `--output-dir <path>` | 輸出目錄（預設 sql_exports） | ❌ | `--output-dir /app/backups` |
| `--db-uri <uri>` | 覆寫資料庫連線字串 | ❌ | `--db-uri "postgresql://..."` |

#### 參數組合邏輯

- **無參數**：進入互動模式
- **只用 `--schema`**：匯出整個 schema 的所有資料表
- **`--schema` + `--include-table`**：只匯出指定的資料表
- **`--schema` + `--exclude-table`**：匯出 schema 但排除指定的資料表
- **`--include-table` + `--exclude-table`**：先篩選要包含的表，再排除部分表（較少使用）

#### 檔案輸出規則

- **容器內位置**：`/app/sql_exports/<prefix>.sql`
- **主機位置**（需手動複製）：`./sql_exports/<prefix>.sql`
- **自動刪除舊檔案**：執行前會自動刪除相同 prefix 的舊檔案
- **固定檔名**：不含時間戳，方便管理

---

## 資料匯入（Import）

### 1. 互動模式（推薦）

在 Docker 環境中執行（無需任何參數）：

```bash
docker-compose exec web python scripts/import_from_sql.py
```

**互動流程：**

**步驟 1：掃描並選擇 SQL 檔案**
```
📥 SQL 資料匯入工具（互動模式）
============================================================

🔍 掃描 /app/sql_exports 目錄...
找到 3 個 SQL 檔案

📂 可用的 SQL 檔案
============================================================
  [1] backup_20250109.sql
      大小: 15.23 MB | 修改時間: 2025-01-09 14:30:45
  [2] export.sql
      大小: 8.67 MB | 修改時間: 2025-01-08 10:15:22
  [3] full_dump.sql
      大小: 25.41 MB | 修改時間: 2025-01-07 09:00:00
  [Q] 離開

請選擇要匯入的檔案 [1-3]: 1
```

**步驟 2：預覽並確認**
```
🔍 分析 backup_20250109.sql...

📋 匯入預覽
============================================================

檔案: backup_20250109.sql
大小: 15.23 MB

統計資訊:
  總行數: 45,678
  INSERT 語句數: 12,345

涉及的表 (14 個):
  - web_app.users
  - web_app.documents
  - web_app.nsn_records
  - web_app.templates
  ...

============================================================

確認執行匯入？ [Y/n]: Y
```

**步驟 3：執行匯入**
```
============================================================
📥 開始匯入
============================================================

🔍 讀取 SQL 檔案...
📊 取得匯入前的資料狀態...
🔗 連接資料庫...
✅ 連接成功

📥 執行 SQL 匯入...
   這可能需要幾分鐘，請稍候...

✅ 匯入成功！

🔍 驗證匯入結果...

📊 資料變更統計:
   ✅ web_app.users: 0 → 1,234 (+1,234)
   ✅ web_app.documents: 0 → 5,678 (+5,678)
   ✅ web_app.nsn_records: 0 → 3,456 (+3,456)
   ...

============================================================
✅ 匯入完成！
============================================================
```

---

### 2. 命令列模式

**基本使用：**

```bash
# 指定 SQL 檔案（檔名）
docker-compose exec web python scripts/import_from_sql.py \
  --sql-file backup_20250109.sql

# 指定 SQL 檔案（絕對路徑）
docker-compose exec web python scripts/import_from_sql.py \
  --sql-file /app/sql_exports/export.sql

# 自動化模式（跳過確認提示）
docker-compose exec web python scripts/import_from_sql.py \
  --sql-file export.sql \
  --yes

# 指定自訂的 SQL 檔案目錄
docker-compose exec web python scripts/import_from_sql.py \
  --exports-dir /app/backups \
  --sql-file my_backup.sql
```

**參數說明：**

| 參數 | 說明 | 範例 |
|------|------|------|
| `--sql-file` | SQL 檔案路徑或檔名 | `--sql-file export.sql` |
| `--exports-dir` | SQL 檔案所在目錄 | `--exports-dir /app/backups` |
| `--yes` | 跳過確認提示（自動化用） | `--yes` |
| `--db-uri` | 資料庫連線字串 | `--db-uri postgresql://...` |

---

## 完整工作流程範例

### 場景 1：備份生產環境資料到本地

**步驟 1：在生產環境匯出資料**
```bash
# 進入生產環境容器
docker-compose exec web python scripts/export_to_sql.py

# 選擇要匯出的 schema 和表
# 設定檔名前綴：production_backup_20250109
```

**步驟 2：將 SQL 檔案複製到本地**
```bash
# 在主機執行
docker cp smartcodex-web:/app/sql_exports/production_backup_20250109.sql ./backups/
```

**步驟 3：在本地開發環境匯入**
```bash
# 先將檔案複製到本地容器
docker cp ./backups/production_backup_20250109.sql smartcodex-web-dev:/app/sql_exports/

# 在本地容器執行匯入
docker-compose exec web python scripts/import_from_sql.py --sql-file production_backup_20250109.sql
```

---

### 場景 2：只匯出特定功能的資料

假設您只想備份使用者和文件相關的表：

```bash
docker-compose exec web python scripts/export_to_sql.py \
  --schema web_app \
  --include-table web_app.users \
  --include-table web_app.user_profiles \
  --include-table web_app.documents \
  --include-table web_app.document_versions \
  --prefix users_docs_backup \
  --skip-json
```

---

### 場景 3：自動化每日備份腳本

建立一個每日備份腳本 `scripts/daily_backup.sh`：

```bash
#!/bin/bash
# 每日自動備份腳本

DATE=$(date +%Y%m%d)
BACKUP_NAME="daily_backup_${DATE}"

# 匯出資料
docker-compose exec -T web python scripts/export_to_sql.py --schema web_app --exclude-table web_app.logs --prefix "${BACKUP_NAME}" --skip-json

# 複製到主機備份目錄
docker cp smartcodex-web:/app/sql_exports/${BACKUP_NAME}.sql ./backups/

# 刪除 7 天前的備份
find ./backups -name "daily_backup_*.sql" -mtime +7 -delete

echo "✅ 備份完成: ${BACKUP_NAME}.sql"
```

設定 crontab 每日執行：
```bash
0 2 * * * /path/to/scripts/daily_backup.sh
```

---

## 與部署流程整合

本章節說明如何將資料庫備份還原整合到部署流程中。

### 1. 開發環境完全重置並還原資料

當您需要**徹底重建容器和 Volume，但想保留並還原舊資料**時，請使用此流程。

**完整流程概覽**：備份 → 清除 → 重建 → 初始化 → 升級 → 還原

詳細步驟請參閱 [開發工作流程指南 - 模式四](00_Development_Workflows.md#模式四完全更新並備份還原資料-complete-update-with-data-backup--restore)

---

### 2. 正式環境部署前備份 SOP

**在執行任何正式環境更新前，務必先備份資料！**

#### 步驟 1：部署前備份
```bash
# 設定備份檔名（使用日期標記）
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="pre_deploy_${DATE}"

# 匯出完整資料
docker-compose exec web python scripts/export_to_sql.py --schema web_app --schema public --prefix "${BACKUP_NAME}" --skip-json

# 複製到安全位置
docker cp smartcodex-web:/app/sql_exports/${BACKUP_NAME}.sql ./backups/production/
```

#### 步驟 2：執行部署
```bash
# 情境 A：無資料庫結構變更
docker-compose up -d --build

# 情境 B：有資料庫結構變更
docker-compose up -d --build
docker-compose exec web flask db upgrade
```

#### 步驟 3：驗證部署
```bash
# 檢查服務狀態
docker-compose ps

# 檢查日誌
docker-compose logs --tail=100 web

# 測試關鍵功能
# （依據您的應用程式進行測試）
```

#### 步驟 4：如果需要回滾
```bash
# 停止服務
docker-compose down

# 還原備份
docker cp ./backups/production/${BACKUP_NAME}.sql smartcodex-web:/app/sql_exports/
docker-compose up -d
docker-compose exec web python scripts/import_from_sql.py --sql-file ${BACKUP_NAME}.sql --yes
```

---

### 3. Docker Volume 自動同步配置

**避免每次都需要 docker cp，讓匯出的檔案自動出現在主機！**

在 `docker-compose.yml` 的 `web` 服務加上：

```yaml
services:
  web:
    volumes:
      - ./sql_exports:/app/sql_exports
```

重啟容器：
```bash
docker-compose up -d web
```

之後匯出的檔案會直接出現在主機的 `./sql_exports/` 目錄。

---

### 4. CI/CD 整合範例

將備份流程整合到 CI/CD pipeline 中：

**GitHub Actions 範例**：

```yaml
name: Deploy with Backup

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Backup database
        run: |
          ssh user@server "cd /app && docker-compose exec -T web python scripts/export_to_sql.py --schema web_app --prefix pre_deploy_$(date +%Y%m%d_%H%M%S) --skip-json"

      - name: Deploy application
        run: |
          ssh user@server "cd /app && docker-compose up -d --build"

      - name: Run migrations
        run: |
          ssh user@server "cd /app && docker-compose exec -T web flask db upgrade"

      - name: Verify deployment
        run: |
          ssh user@server "cd /app && docker-compose ps"
```

---

## 常見問題與排除

### Q1: 匯入時出現「PRIMARY KEY 重複」錯誤

**原因：** 目標資料庫已有相同的資料

**解決方案：**
1. 清空目標表後再匯入：
   ```sql
   TRUNCATE TABLE web_app.users CASCADE;
   ```
2. 或使用 `ON CONFLICT` 處理（需修改 SQL 檔案）

---

### Q2: 匯入後序列（sequence）沒有正確更新

**原因：** SQL 檔案中已包含序列重置語句，但可能被跳過

**檢查方式：**
```sql
-- 查看當前序列值
SELECT currval('web_app.users_id_seq');

-- 手動重置序列
SELECT setval('web_app.users_id_seq', (SELECT MAX(id) FROM web_app.users), true);
```

---

### Q3: 無法連接資料庫

**檢查項目：**
1. 環境變數是否設定：
   ```bash
   docker-compose exec web env | grep DATABASE
   ```

2. 資料庫是否運行：
   ```bash
   docker-compose ps db
   ```

3. 連線字串格式：
   ```
   postgresql://username:password@host:port/database
   ```

---

### Q4: 匯出/匯入時檔案過大導致記憶體不足

**解決方案：**

1. **匯出時排除大型表：**
   ```bash
   docker-compose exec web python scripts/export_to_sql.py \
     --schema web_app \
     --exclude-table web_app.large_logs \
     --prefix partial_export
   ```

2. **分批匯出：**
   ```bash
   # 先匯出小表
   docker-compose exec web python scripts/export_to_sql.py \
     --include-table web_app.users \
     --prefix batch1

   # 再匯出大表
   docker-compose exec web python scripts/export_to_sql.py \
     --include-table web_app.documents \
     --prefix batch2
   ```

---

### Q5: 如何驗證匯入是否完整？

**方法 1：使用匯入工具的內建驗證**
匯入工具會自動顯示匯入前後的資料變更統計

**方法 2：手動查詢筆數比對**
```sql
-- 在匯出環境執行
SELECT table_name,
       (SELECT COUNT(*) FROM web_app.users) as count
FROM information_schema.tables
WHERE table_schema = 'web_app';

-- 在匯入環境執行相同查詢，比對結果
```

**方法 3：使用 JSONL 檔案比對**
```bash
# 匯出時加上 JSONL
docker-compose exec web python scripts/export_to_sql.py --schema web_app --prefix verify

# 使用 jq 工具分析 JSONL
jq -s 'group_by(.table) | map({table: .[0].table, count: length})' verify.jsonl
```

---

### Q6: 如何在本地環境（非 Docker）使用這些工具？

**前提：**
- 安裝 Python 3.8+
- 安裝依賴：`pip install sqlalchemy psycopg2-binary`
- 有 `config.py` 檔案設定資料庫連線

**使用方式：**
```bash
# 匯出
python scripts/export_to_sql.py

# 匯入
python scripts/import_from_sql.py --sql-file sql_exports/export.sql
```

---

### Q7: 匯出的 SQL 檔案可以在其他 PostgreSQL 版本使用嗎？

**通常可以**，但需注意：

1. **向上相容性較好**：從舊版本匯出，匯入新版本通常沒問題
2. **向下相容性需測試**：從新版本匯出，匯入舊版本可能有問題
3. **特殊資料型別**：JSONB、陣列等進階型別需注意版本支援

**建議：** 在正式遷移前，先在測試環境驗證

---

### Q8: 如何處理大型 BLOB/二進位資料？

**目前工具的處理方式：**
- 使用 `LargeBinary` 型別處理
- 以十六進位編碼儲存在 SQL 中

**限制：**
- 非常大的二進位資料可能導致 SQL 檔案過大
- 建議單獨備份檔案系統中的附件

**替代方案：**
```bash
# 只匯出元資料（排除 BLOB 欄位）
# 需自行修改 export_to_sql.py 加入欄位過濾
```

---

### Q9: 複製檔案失敗怎麼辦？

**錯誤訊息**：`Could not find the file sql_exports/xxx.sql in container`

**解決方法：**
1. 檢查容器名稱是否正確
   ```bash
   docker ps
   ```

2. 檢查檔案是否存在
   ```bash
   docker-compose exec web ls -la /app/sql_exports/
   ```

3. 使用完整路徑
   ```bash
   docker cp smartcodex-web:/app/sql_exports/檔名.sql ./sql_exports/
   ```

---

### Q10: PowerShell 找不到路徑怎麼辦？

**錯誤訊息**：`Could not find a part of the path`

**解決方法**：先建立目錄
```powershell
New-Item -ItemType Directory -Force -Path sql_exports
```

---

### Q11: 資料庫連線失敗怎麼辦？

**錯誤訊息**：`Database URI not provided`

**解決方法：**
```bash
# 方法 1：直接指定 URI
docker-compose exec web python scripts/export_to_sql.py --db-uri "postgresql://postgres:postgres@postgres:5432/nsn_database" --schema web_app --skip-json

# 方法 2：檢查環境變數
docker-compose exec web bash -c "echo $DATABASE_URL"
```

---

### Q12: 如何查看資料庫有哪些 schema 和 table？

**使用互動模式**：執行後會自動顯示所有可用的 schema 和 table
```bash
docker-compose exec web python scripts/export_to_sql.py
```

**手動查詢**：
```bash
# 查看所有 schema
docker-compose exec postgres psql -U postgres -d nsn_database -c "\dn"

# 查看 web_app schema 的所有表
docker-compose exec postgres psql -U postgres -d nsn_database -c "\dt web_app.*"
```

---

## 最佳實踐建議

### 1. 定期備份策略
- **每日備份**：排除日誌表，保留 7 天
- **每週完整備份**：包含所有表，保留 4 週
- **每月歸檔備份**：完整備份，長期保存

### 2. 檔名命名規範
```
{環境}_{用途}_{日期}.sql
```
範例：
- `production_daily_20250109.sql`
- `staging_feature_test_20250109.sql`
- `dev_user_data_20250109.sql`

### 3. 安全性考量
- ❌ 不要將包含敏感資料的 SQL 檔案提交到版本控制
- ✅ 使用加密儲存備份檔案
- ✅ 定期檢查備份檔案的存取權限

### 4. 測試備份的可用性
```bash
# 定期在測試環境驗證備份可用性
docker-compose exec web-test python scripts/import_from_sql.py \
  --sql-file production_backup.sql \
  --yes
```

### 5. UUID 資料完整性
- ✅ 匯出的 SQL 會完整保留所有 UUID
- ✅ 外鍵關聯不會斷裂
- ✅ 資料完整性得到保證

### 6. Schema 變更處理
- `flask db upgrade` 會自動處理新增的欄位
- 如果新增**必填欄位**（NOT NULL without DEFAULT），建議在 migration 中設定預設值
- 或手動調整 SQL 檔案加入預設值

### 7. JSONL 檔案用途
- 除了 SQL 檔案，也會產生 JSONL 格式（如果未使用 `--skip-json`）
- 可用於其他資料轉換工具或腳本
- 如不需要，可在匯出時加 `--skip-json` 參數

---

## 相關資源

- **Export 工具原始碼**：[scripts/export_to_sql.py](../../scripts/export_to_sql.py)
- **Import 工具原始碼**：[scripts/import_from_sql.py](../../scripts/import_from_sql.py)
- **開發工作流程指南**：[00_Development_Workflows.md](00_Development_Workflows.md)
- **Gunicorn 部署指南**：[01_Gunicorn_Deployment.md](01_Gunicorn_Deployment.md)
- **PostgreSQL 官方文件**：https://www.postgresql.org/docs/

---

## 更新歷史

| 日期 | 版本 | 說明 |
|------|------|------|
| 2025-01-10 | 2.0 | 整合 `sql_import_export_guide.md` 和 `export_to_sql_usage.md`，新增部署流程整合章節 |
| 2025-01-09 | 1.0 | 初版發布（原 `sql_import_export_guide.md`） |
| 2025-10-27 | - | 新增互動式選單模式（原 `export_to_sql_usage.md`） |
