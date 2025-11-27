# Database Scripts 分類說明

## 📁 資料夾結構

### 01-database-creation/ (資料庫建立)
**用途**: 完整的資料庫建立腳本

| 檔案名稱 | 說明 | 版本 |
|---------|------|------|
| `create_database_v3.1.sql` | ⭐ **主要腳本** - 完整資料庫建立（18表） | V3.1 |
| `create_web_app_tables.sql` | Web 應用表獨立建立腳本（6表） | V3.1 |

**使用說明**:
```bash
# 建立完整資料庫 sbir_equipment_db_v3
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -f "01-database-creation/create_database_v3.1.sql"
```

---

### 02-test-data/ (測試資料)
**用途**: 測試資料插入腳本

| 檔案名稱 | 說明 |
|---------|------|
| `insert_電笛_data_v2.sql` | ⭐ 電笛系統測試資料（V2） |
| `insert_電笛_data.sql` | 電笛系統測試資料（舊版） |

**使用說明**:
```bash
# 插入電笛測試資料
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v3 -f "02-test-data/insert_電笛_data_v2.sql"
```

---

### 03-data-import/ (資料匯入)
**用途**: Excel/CSV 資料匯入腳本

| 檔案名稱 | 說明 | 類型 |
|---------|------|------|
| `import_emu3000_data.py` | ⭐ EMU3000 維修資料匯入 | Python |
| `import_excel_data.py` | Excel 通用資料匯入 | Python |
| `import_application_data.py` | 申編單資料匯入 | Python |

**使用說明**:
```bash
# 匯入 EMU3000 資料
python 03-data-import/import_emu3000_data.py
```

---

### 04-schema-modifications/ (架構修改)
**用途**: 資料庫架構調整與修改腳本

| 檔案名稱 | 說明 |
|---------|------|
| `alter_database_for_emu3000.sql` | EMU3000 架構調整 |
| `alter_ext_tables_v2.sql` | 擴展表修改 |
| `fix_supplier_app_schema.sql` | 廠商申請表修正 |
| `modify_application_tables.sql` | 申編單表修改 |
| `modify_database_structure.sql` | 資料庫結構修改 |
| `restructure_app_form_v3_3.sql` | 申編單重構 |
| `update_schema_v3_1.sql` | Schema V3.1 更新 |

⚠️ **注意**: 這些是增量修改腳本，需要在現有資料庫上執行

---

### 05-comments-updates/ (註解更新)
**用途**: 資料庫表與欄位註解更新

| 檔案名稱 | 說明 |
|---------|------|
| `update_comments_to_申編單.sql` | ⭐ 更新為「申編單」註解 |
| `update_comments_v3.sql` | V3 註解更新 |
| `add_comments_v3_2.sql` | V3.2 註解新增 |
| `update_comments.sql` | 通用註解更新 |

**使用說明**:
```bash
# 更新註解為「申編單」
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v3 -f "05-comments-updates/update_comments_to_申編單.sql"
```

---

### 06-nsn-integration/ (NSN整合)
**用途**: 海軍 NSN 系統整合腳本

| 檔案名稱 | 說明 |
|---------|------|
| `integrate_nsn_core_custom.sql` | ⭐ NSN 核心整合（自訂版） |
| `integrate_nsn_core.sql` | NSN 核心整合 |
| `create_nsn_views.sql` | NSN 視圖建立 |
| `validate_nsn_integration.sql` | NSN 整合驗證 |

**使用說明**:
```bash
# NSN 整合
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v3 -f "06-nsn-integration/integrate_nsn_core_custom.sql"

# 驗證整合
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v3 -f "06-nsn-integration/validate_nsn_integration.sql"
```

---

### 07-validation-tools/ (驗證工具)
**用途**: 資料驗證與分析工具

| 檔案名稱 | 說明 | 類型 |
|---------|------|------|
| `analyze_emu3000_files.py` | EMU3000 檔案分析 | Python |
| `verify_fields.py` | 欄位驗證工具 | Python |
| `verification_report.md` | 驗證報告 | Markdown |

**使用說明**:
```bash
# 分析 EMU3000 檔案
python 07-validation-tools/analyze_emu3000_files.py
```

---

### 08-archive/ (封存)
**用途**: 舊版本腳本封存

| 檔案名稱 | 說明 | 狀態 |
|---------|------|------|
| `create_database.sql` | V1.0 資料庫建立 | 已棄用 |
| `create_database_v2.sql` | V2.0 資料庫建立 | 已棄用 |
| `create_application_tables.sql` | 舊版申請表建立 | 已棄用 |

⚠️ **這些檔案僅供參考，請勿使用**

---

## 🚀 快速開始

### 1. 建立全新資料庫
```bash
cd Database/scripts
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -f "01-database-creation/create_database_v3.1.sql"
```

### 2. 插入測試資料
```bash
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v3 -f "02-test-data/insert_電笛_data_v2.sql"
```

### 3. 驗證資料庫
```bash
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v3 -c "\dt"
```

---

## 📌 重要提醒

1. **資料庫名稱**: 最新版本使用 `sbir_equipment_db_v3`
2. **時間戳命名**: 統一使用 `date_created` / `date_updated`
3. **申編單**: Application 表為「申編單」，非「申請單」
4. **總表數**: 18 個資料表（12 核心 + 6 Web）
5. **編碼**: UTF8

---

## 🔗 相關文件

- [完整架構文檔](../docs/00-整體架構/02-schema_v3.1_with_web_app.md)
- [資料匯入說明](../docs/20-EMU3000系統/)
- [NSN 系統說明](../docs/10-海軍NSN系統/)

---

**最後更新**: 2025-11-25
**資料庫版本**: V3.1
**總腳本數**: 28 個（8 個分類資料夾）
