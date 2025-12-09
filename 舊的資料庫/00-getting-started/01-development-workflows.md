# 開發工作流程指南 (Development Workflows Guide)

本文件提供兩種核心開發工作流程的指令，方便您在不同情境下快速複製和執行。

---

## 模式一：日常開發 (Daily Development)

當您**只修改了 Python 程式碼 (`.py` 檔案)**，並且**不想清空資料庫**時，請使用此流程。這是最快、最常用的開發方式。

### 指令

```bash
docker-compose up -d --build
```

### 流程說明
1.  `--build`: Docker 會聰明地利用快取，只重新建置有變動的程式碼層，速度很快。
2.  `-d`: 在背景啟動服務。
3.  **資料庫會被完整保留**，所有現有資料都不會遺失。

---

## 模式二：徹底重置 (Complete Reset)

當您需要一個**絕對乾淨的全新環境**（例如，模擬新成員加入專案，或資料庫狀態混亂需要從零開始），請使用此流程。

**⚠️ 警告：此流程將會徹底刪除您的所有資料庫資料！**

### 指令

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

# 3.3 建立 web_app schema 的所有表格
docker-compose exec web python sql/setup_web_app.py
```

#### 步驟 4：更新遷移狀態
```bash
# 告訴系統所有表格都已建立，讓它不要再嘗試執行遷移
docker-compose exec web flask db stamp head
```

#### 升級資料庫
```bash
docker-compose exec web flask db upgrade
```


#### 設置管理員
```bash
docker exec -it smartcodex-postgres psql -U postgres -d nsn_database
```
```sql
UPDATE web_app.users SET role = 'admin' WHERE username = 'C112118237';
```
#### 設為一般使用者
```sql
UPDATE web_app.users SET role = 'user' WHERE username = 'C112118237';
```

---

## 模式三：正式環境部署 (Production Deployment)

此流程用於將更新部署到正式（Production）伺服器。您的部署方式是手動複製檔案，因此以下指令假設您已經將最新的程式碼放置到正確的位置。

### 情境 A：無資料庫結構變更 (No Database Schema Changes)

當您的程式碼變更**不涉及**資料庫模型 (`models.py`) 的修改時，使用此流程。

#### 指令
```bash
docker-compose up -d --build
```
**說明**：此指令會重建本地服務映像檔，並在背景重新啟動服務。現有資料將被保留。

### 情境 B：有資料庫結構變更 (With Database Schema Changes)

當您的程式碼變更**包含**資料庫模型 (`models.py`) 的修改時（例如，新增欄位、修改資料表），必須執行資料庫遷移。

#### 步驟 1：重新建置並啟動服務
```bash
docker-compose up -d --build
```

#### 步驟 2：執行資料庫遷移
```bash
docker-compose exec web flask db upgrade
```
**重要說明**：`flask db upgrade` 是 Flask-Migrate 的標準指令，用於安全地更新**現有**的資料庫結構，它只會應用新的變更且**不會清除任何資料**，是正式環境更新的標準做法。這與 `setup_database.py` 等初始化腳本不同，後者僅用於從零開始建立全新的資料庫。

---
**文檔版本**: v2.2 (Updated Data Backup & Restore reference)
**更新日期**: 2025年01月10日

---

## 模式四：完全更新並備份還原資料 (Complete Update with Data Backup & Restore)

📚 **詳細說明**：完整的備份還原指南請參閱 [資料庫備份與還原指南](02_Database_Backup_Restore.md)

當您需要**徹底重建容器和 Volume，但想保留並還原舊資料**時，請使用此流程。

**使用場景**：
- 日常開發中需要完全重建環境但保留資料
- 更新 Docker 映像或容器設定
- 清除舊的 Volume 但保留重要資料
- 將資料從舊環境遷移到新環境

**完整流程概覽**：備份 → 清除 → 重建 → 初始化 → 升級 → 還原

---

### 步驟 1：匯出資料

在執行 `docker-compose down -v` 之前，先將資料匯出：

#### 互動式匯出（推薦）
```bash
# 啟動互動式選單，可選擇要匯出的 schema 和表
docker-compose exec web python scripts/export_to_sql.py
```

互動式選單會引導您：
1. 選擇要匯出的 schema（或全部匯出）
2. 選擇是否排除特定表
3. 選擇輸出格式（SQL only 或 SQL + JSONL）
4. 輸入檔名前綴

#### 參數式匯出
```bash
# 匯出 web_app schema，檔名前綴為 backup_20250106
docker-compose exec web python scripts/export_to_sql.py \
    --schema web_app \
    --prefix backup_20250106 \
    --skip-json

# 匯出所有 schema
docker-compose exec web python scripts/export_to_sql.py \
    --schema public \
    --schema web_app \
    --prefix full_backup
```

**匯出檔案位置**：`sql_exports/` 目錄

---

### 步驟 2：重建環境

```bash
# 停止並刪除所有容器和 Volume（資料會被清空）
docker-compose down -v

# 重新建置並啟動所有服務
docker-compose up -d --build

# 等待資料庫啟動完成（約 5-10 秒）
sleep 10
```

---

### 步驟 3：初始化資料庫 Schema

**重要**：在匯入資料前，必須先建立資料庫的表結構（schema）。

```bash
# 建立 public schema 的所有表格
docker-compose exec web python sql/setup_database.py

# 匯入 public schema 的核心資料（NSN、FSC、INC 等）
docker-compose exec web python sql/data_import/import_database.py

# 建立 web_app schema 的所有表格
docker-compose exec web python sql/setup_web_app.py

# 標記資料庫遷移狀態（避免重複執行遷移）
docker-compose exec web flask db stamp head
```

---

### 步驟 4：升級資料庫

```bash
# 執行資料庫遷移（應用最新的 schema 變更）
docker-compose exec web flask db upgrade
```

**說明**：此步驟確保資料庫結構與最新的程式碼模型同步。

---

### 步驟 5：還原資料

選擇以下任一方式匯入資料：

#### 方法 A：使用 psql 直接匯入（推薦，速度快）

```bash
# 透過 db 容器執行（適用於大部分情況）
docker-compose exec -T db psql -U postgres -d nsn_database < sql_exports/export.sql

# 或透過 web 容器執行
docker-compose exec web psql $DATABASE_URL -f /app/sql_exports/export.sql
```

**優點**：
- 速度快，直接使用 PostgreSQL 原生工具
- 適合大量資料匯入
- 標準做法，穩定可靠

---

### 步驟 6：驗證資料（可選）

```bash
# 進入資料庫檢查資料
docker exec -it smartcodex-postgres psql -U postgres -d nsn_database
```

```sql
-- 檢查 web_app schema 的使用者數量
SELECT COUNT(*) FROM web_app.users;

-- 檢查申編單數量
SELECT COUNT(*) FROM web_app.applications;

-- 列出所有表及其筆數
SELECT
    schemaname,
    tablename,
    n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY schemaname, tablename;
```

---

### 重要注意事項

1. **UUID 保持不變**：
   - 匯出的 SQL 會完整保留所有 UUID
   - 外鍵關聯不會斷裂
   - 資料完整性得到保證

2. **執行順序很重要**：
   - 必須按照：備份 → 清除 → 重建 → 初始化 → **升級** → 還原
   - 特別注意步驟 4 的 `flask db upgrade` 必須在還原資料之前執行

3. **Schema 變更處理**：
   - `flask db upgrade` 會自動處理新增的欄位
   - 如果新增**必填欄位**（NOT NULL without DEFAULT），建議在 migration 中設定預設值
   - 或手動調整 SQL 檔案加入預設值

4. **JSONL 檔案用途**：
   - 除了 SQL 檔案，也會產生 JSONL 格式
   - 可用於其他資料轉換工具或腳本
   - 如不需要，可在匯出時加 `--skip-json` 參數

---

### 完整範例：一鍵備份還原腳本

將以下內容儲存為 `backup_restore.sh`：

```bash
#!/bin/bash
set -e

echo "=== 步驟 1：匯出資料 ==="
docker-compose exec web python scripts/export_to_sql.py \
    --schema web_app \
    --prefix backup \
    --skip-json

echo -e "\n=== 步驟 2：重建環境 ==="
docker-compose down -v
docker-compose up -d --build
sleep 10

echo -e "\n=== 步驟 3：初始化 Schema ==="
docker-compose exec web python sql/setup_database.py
docker-compose exec web python sql/data_import/import_database.py
docker-compose exec web python sql/setup_web_app.py
docker-compose exec web flask db stamp head

echo -e "\n=== 步驟 4：升級資料庫 ==="
docker-compose exec web flask db upgrade

echo -e "\n=== 步驟 5：還原資料 ==="
docker-compose exec -T db psql -U postgres -d nsn_database < sql_exports/backup.sql

echo -e "\n✅ 完全更新並還原完成！"
```


---

## 附註：PDF 轉檔環境需求

- 申編單 PDF 下載會呼叫 LibreOffice headless 進行 DOCX→PDF 轉換，Docker 映像已預先安裝 `libreoffice`、`libreoffice-writer` 與 `fonts-noto-cjk`。
- 若在自訂環境執行（非官方 Docker 映像），請手動安裝相同套件，或確保系統有能夠將 Word 模板轉成 PDF 的 CLI 工具，否則下載 PDF 會回報「找不到 LibreOffice」的錯誤。
