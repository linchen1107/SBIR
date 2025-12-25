# Database Migration & Comparison Files

資料庫遷移與比對檔案目錄

---

## 📁 目錄結構

```
migrations/
├── 📋 README.md                    (本檔案 - 快速導覽)
├── 📂 00-core-scripts/             核心遷移腳本
├── 📂 reports/                     詳細報告文件
├── 📂 tools/                       比對工具與修復檔案
├── 📂 data-extracts/               資料提取結果
└── 📂 archive/                     已棄用檔案
```

---

## 🚀 快速開始

### 查看比對結果
```powershell
cat reports\SUMMARY.md
```

### 執行資料比對
```powershell
.\tools\compare_data_simple.ps1
```

### 執行遷移
```powershell
$env:PGPASSWORD = "willlin07"
psql -U postgres -d sbir_equipment_db_v3 -f 00-core-scripts\01_create_old_data_staging.sql
psql -U postgres -d sbir_equipment_db_v3 -f 00-core-scripts\02_migrate_users.sql
psql -U postgres -d sbir_equipment_db_v3 -f 00-core-scripts\03_migrate_applications.sql
psql -U postgres -d sbir_equipment_db_v3 -f 00-core-scripts\04_verify_and_cleanup.sql
```

---

## 📂 目錄說明

### 00-core-scripts/ - 核心遷移腳本

**用途**: 資料庫遷移的核心 SQL 腳本  
**執行順序**:
1. `01_create_old_data_staging.sql` - 建立 old_data schema
2. `02_migrate_users.sql` - 遷移使用者資料
3. `03_migrate_applications.sql` - 遷移申請單資料
4. `04_verify_and_cleanup.sql` - 驗證與清理

### reports/ - 報告文件

**包含檔案**:
- **SUMMARY.md** ⭐ - 執行摘要 (建議先看這個)
- **FINAL_COMPARISON_REPORT.txt** - 完整詳細報告
- **INDEX.md** - 完整檔案索引
- **MIGRATION_GUIDE.md** - 遷移操作指南
- **field_comparison_report.txt** - 欄位比對報告

**推薦閱讀順序**:
1. SUMMARY.md (快速了解結果)
2. FINAL_COMPARISON_REPORT.txt (詳細資訊)
3. MIGRATION_GUIDE.md (操作指南)

### tools/ - 工具檔案

**比對工具**:
- `compare_data_simple.ps1` - 簡易資料比對腳本
- `compare_fields_detailed.ps1` - 詳細欄位比對腳本

**修復檔案**:
- `missing_applications_fixed.sql` - 補齊遺漏資料的 SQL

### data-extracts/ - 資料提取結果

**包含內容**:
- 使用者資料提取檔案 (db_users_*.txt)
- 申請單 ID 列表 (db_app_ids.txt, sql_app_ids.txt)
- 遺漏記錄 ID (missing_ids.txt, missing_application_ids.txt)
- 詳細資料提取 (db_olddata_applications.txt, db_webapp_applications.txt)

**用途**: 比對過程中產生的中間資料,用於驗證與追蹤

### archive/ - 已棄用檔案

**包含內容**:
- 有編碼問題的舊腳本 (compare_data_detailed.ps1)
- 測試檔案 (test_insert_1.sql)
- 已修復的問題檔案 (missing_applications.sql)

**說明**: 這些檔案已不再使用,保留僅供參考

---

## ✅ 比對結果摘要

| 項目 | SQL 檔案 | 資料庫 | 狀態 |
|------|---------|--------|------|
| 使用者 | 9 | 9 | ✅ 完全一致 |
| 申請單 (old_data) | 126 | 126 | ✅ 完全一致 |
| 申請單 (web_app) | 126 | 126 | ✅ 完全一致 |
| 未遷移記錄 | - | 0 | ✅ 全部完成 |

**結論**: 所有資料已完整匯入,無任何遺漏!

---

## 🔍 常用驗證指令

### 檢查資料數量
```sql
-- 使用者 (預期: 9)
SELECT COUNT(*) FROM web_app."User";

-- 申請單 (預期: 126)
SELECT COUNT(*) FROM web_app.application;
SELECT COUNT(*) FROM old_data.applications;

-- 未遷移記錄 (預期: 0)
SELECT COUNT(*) 
FROM old_data.applications o
LEFT JOIN web_app.application w ON o.id = w.id
WHERE w.id IS NULL;
```

### PowerShell 快速驗證
```powershell
$env:PGPASSWORD = "willlin07"
$sql = @'
SELECT 'Users' AS item, COUNT(*) as count FROM web_app."User"
UNION ALL
SELECT 'Applications (web_app)', COUNT(*) FROM web_app.application
UNION ALL
SELECT 'Applications (old_data)', COUNT(*) FROM old_data.applications;
'@
$sql | psql -U postgres -d sbir_equipment_db_v3
```

---

## 📊 資料庫資訊

- **資料庫名稱**: sbir_equipment_db_v3
- **PostgreSQL 版本**: 16
- **使用者**: postgres
- **密碼**: willlin07
- **Schema**: 
  - `old_data` - 原始資料 (51 欄位格式)
  - `web_app` - 新版資料 (v3.2 正規化格式)

---

## 🔧 疑難排解

### 問題 1: 執行 PowerShell 腳本時出現編碼錯誤

**解決**:
```powershell
# 使用 UTF8 編碼執行
Get-Content .\tools\compare_data_simple.ps1 -Raw -Encoding UTF8 | Invoke-Expression
```

### 問題 2: psql 命令找不到

**解決**:
```powershell
# 使用完整路徑
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d sbir_equipment_db_v3
```

### 問題 3: 權限不足

**解決**:
```powershell
# 設定環境變數
$env:PGPASSWORD = "willlin07"
```

---

## 📞 需要幫助?

1. **查看執行摘要**: `reports\SUMMARY.md`
2. **查看完整報告**: `reports\FINAL_COMPARISON_REPORT.txt`
3. **查看遷移指南**: `reports\MIGRATION_GUIDE.md`
4. **查看檔案索引**: `reports\INDEX.md`

---

## 📅 最後更新

- **日期**: 2025-12-26
- **執行人員**: GitHub Copilot
- **狀態**: ✅ 所有資料驗證完成

---

## 🎯 關鍵結論

✅ **資料完整性**: 100%  
✅ **遷移成功率**: 100% (126/126 筆申請單, 9/9 個使用者)  
✅ **資料一致性**: SQL 檔案與資料庫完全一致  
✅ **問題修復**: 5 筆遺漏記錄已全部補齊

**所有資料的每一筆記錄、每一個欄位、每一個內容都已詳細比對,確認完全一致!**
