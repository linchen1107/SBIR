# 資料比對檔案索引

此目錄包含了完整的資料庫比對過程中產生的所有檔案。

## 📋 主要報告文件

### 1. [SUMMARY.md](SUMMARY.md)
**用途**: 執行摘要 - 快速瀏覽比對結果  
**內容**: 
- 比對結果摘要
- 發現的問題與修復方法
- 最終結論
- 驗證指令

### 2. [FINAL_COMPARISON_REPORT.txt](FINAL_COMPARISON_REPORT.txt)
**用途**: 完整詳細報告  
**內容**:
- 使用者資料比對
- 申請單資料比對
- 資料遷移狀態
- 詳細欄位驗證
- 已發現並修復的問題
- 資料表命名差異
- 整體評估
- 驗證指令

### 3. [field_comparison_report.txt](field_comparison_report.txt)
**用途**: 欄位級別比對報告  
**內容**:
- 各資料表的記錄數量
- 遷移狀態
- 生成的檔案列表

---

## 🔧 比對腳本

### 1. [compare_data_simple.ps1](compare_data_simple.ps1)
**功能**: 簡化版資料比對  
**執行**: `.\compare_data_simple.ps1`  
**輸出**:
- 使用者數量比對
- 申請單數量比對
- 遺漏/多餘的 ID 列表

### 2. [compare_fields_detailed.ps1](compare_fields_detailed.ps1)
**功能**: 詳細欄位級別比對  
**執行**: `.\compare_fields_detailed.ps1`  
**輸出**:
- 詳細欄位資料提取
- 完整比對報告

---

## 📊 資料提取檔案

### 使用者資料
- **db_users_data.txt** - 資料庫使用者詳細資料 (9 筆)
- **db_users_final.txt** - 最終使用者資料 (9 筆)

### 申請單 ID 列表
- **sql_app_ids.txt** - SQL 檔案中的申請單 ID (126 筆)
- **sql_applications_ids.txt** - 同上,另一版本
- **db_app_ids.txt** - 資料庫申請單 ID (121→126 筆)
- **db_applications_ids.txt** - 同上,另一版本
- **sql_app_ids_latest.txt** - 最新版 SQL 申請單 ID
- **db_app_ids_latest.txt** - 最新版資料庫申請單 ID

### 申請單詳細資料
- **db_olddata_applications.txt** - old_data.applications 詳細資料 (126 筆)
- **db_webapp_applications.txt** - web_app.application 詳細資料 (126 筆)

---

## 🔍 問題追蹤檔案

### 缺少的記錄
- **missing_ids.txt** - 5 個缺少的申請單 ID
  ```
  019a7f56-d378-73ec-b52f-a8bb6f8f720d
  019a56d6-e2c5-7d1d-aa0e-d22154b1b301
  019aec76-59e3-77a5-977b-a2b03d59c134
  019aec78-181c-7042-8f84-93babe51420a
  019aec90-075f-7475-b8fb-1e0e95711ea5
  ```

- **missing_application_ids.txt** - 同上,另一版本
- **missing_applications_ids.txt** - 同上,另一版本

### 修復檔案
- **missing_applications.sql** - 原始提取的 5 筆 INSERT (有問題)
- **missing_applications_fixed.sql** - 修復後的 5 筆 INSERT (已修復)
  - 修復內容: 將 INTEGER 欄位的空字串 '' 替換為 NULL

---

## 📁 遷移腳本 (Migration Scripts)

### 1. [01_create_v3_schema.sql](01_create_v3_schema.sql)
創建 v3.2 schema 結構

### 2. [02_migrate_users.sql](02_migrate_users.sql)
遷移使用者資料: old_data.users → web_app."User"

### 3. [03_migrate_applications.sql](03_migrate_applications.sql)
遷移申請單資料: old_data.applications → web_app.application

### 4. [04_verify_migration.sql](04_verify_migration.sql)
驗證遷移結果

---

## 📝 遷移文件

### [migration_guide.md](migration_guide.md)
完整的遷移指南,包含:
- 遷移步驟
- 執行指令
- 驗證方法
- 疑難排解

---

## 🗂️ 檔案組織結構

```
migrations/
├── 📋 報告文件
│   ├── SUMMARY.md ⭐ (執行摘要)
│   ├── FINAL_COMPARISON_REPORT.txt ⭐ (完整報告)
│   ├── field_comparison_report.txt
│   └── INDEX.md (本檔案)
│
├── 🔧 比對腳本
│   ├── compare_data_simple.ps1
│   ├── compare_data_detailed.ps1 (已棄用,有編碼問題)
│   └── compare_fields_detailed.ps1
│
├── 📊 資料提取檔案
│   ├── 使用者資料/
│   │   ├── db_users_data.txt
│   │   └── db_users_final.txt
│   │
│   ├── 申請單 ID/
│   │   ├── sql_app_ids.txt
│   │   ├── sql_applications_ids.txt
│   │   ├── db_app_ids.txt
│   │   ├── db_applications_ids.txt
│   │   ├── sql_app_ids_latest.txt
│   │   └── db_app_ids_latest.txt
│   │
│   └── 申請單詳細資料/
│       ├── db_olddata_applications.txt
│       └── db_webapp_applications.txt
│
├── 🔍 問題追蹤
│   ├── missing_ids.txt ⚠️
│   ├── missing_application_ids.txt
│   ├── missing_applications.sql (已棄用)
│   └── missing_applications_fixed.sql ✓
│
├── 📁 遷移腳本
│   ├── 01_create_v3_schema.sql
│   ├── 02_migrate_users.sql
│   ├── 03_migrate_applications.sql
│   └── 04_verify_migration.sql
│
└── 📝 文件
    └── migration_guide.md
```

---

## ⚡ 快速參考

### 重新執行完整比對
```powershell
cd C:\github\SBIR\Database\migrations
.\compare_data_simple.ps1
```

### 重新驗證資料
```powershell
$env:PGPASSWORD = "willlin07"
psql -U postgres -d sbir_equipment_db_v3 -f 04_verify_migration.sql
```

### 查看比對結果
```powershell
cat SUMMARY.md
```

### 查看完整報告
```powershell
cat FINAL_COMPARISON_REPORT.txt
```

---

## ✅ 比對結果總覽

| 項目 | SQL 檔案 | 資料庫 | 狀態 |
|------|---------|--------|------|
| 使用者 | 9 | 9 | ✅ 一致 |
| 申請單 (old_data) | 126 | 126 | ✅ 一致 |
| 申請單 (web_app) | 126 | 126 | ✅ 一致 |
| 未遷移記錄 | - | 0 | ✅ 完成 |
| 補齊記錄 | - | 5 | ✅ 完成 |

---

## 📞 聯絡資訊

如有任何問題,請查閱:
1. [SUMMARY.md](SUMMARY.md) - 執行摘要
2. [FINAL_COMPARISON_REPORT.txt](FINAL_COMPARISON_REPORT.txt) - 完整報告
3. [migration_guide.md](migration_guide.md) - 遷移指南

---

*最後更新: 2025-12-26 02:20*  
*執行人員: GitHub Copilot*
