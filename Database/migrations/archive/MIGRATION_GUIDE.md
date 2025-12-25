# Web App 資料遷移指南

## 概述

本遷移將舊的 51 欄位 `applications` 表和 `users` 表遷移到 v3.2 正規化資料庫結構。

## 遷移前後對照

### 來源表（舊結構）
| 表名 | 說明 |
|------|------|
| `web_app.users` | 使用者表 (18 欄位) |
| `web_app.applications` | 申請單表 (51 欄位，非正規化) |

### 目標表（v3.2 正規化結構）
| 表名 | 說明 | 遷移欄位來源 |
|------|------|-------------|
| `web_app.User` | 使用者主檔 | users 全部欄位 |
| `web_app.item` | 品項主檔 | part_number, chinese_name, english_name |
| `web_app.item_material_ext` | 料件擴展 | inc_code, fiig_code, 各種代碼欄位 |
| `web_app.item_equipment_ext` | 裝備擴展 | ship_type, equipment_name, cid_no |
| `web_app.application` | 申請單 | 申請流程相關欄位 |
| `web_app.supplier` | 供應商 | manufacturer_name, agent_name |
| `web_app.technicaldocument` | 技術文件 | document_reference |
| `web_app.item_number_xref` | 料號對照 | part_number_reference |

## 遷移步驟

### 步驟 1：建立暫存結構

```bash
psql -U postgres -d sbir_equipment_db_v3 -f 01_create_old_data_staging.sql
```

建立 `old_data` schema 及 `users`, `applications` 暫存表。

### 步驟 2：匯入舊資料

從匯出檔案中擷取 INSERT 語句，修改 schema 後匯入：

```powershell
# 擷取 users INSERT 語句
Select-String -Path "export.sql" -Pattern "^INSERT INTO web_app\.users" | 
    ForEach-Object { $_.Line -replace "web_app\.users", "old_data.users" } | 
    Out-File -FilePath "temp_users.sql" -Encoding UTF8

# 擷取 applications INSERT 語句
Select-String -Path "export.sql" -Pattern "^INSERT INTO web_app\.applications" | 
    ForEach-Object { $_.Line -replace "web_app\.applications", "old_data.applications" } | 
    Out-File -FilePath "temp_applications.sql" -Encoding UTF8

# 匯入
psql -U postgres -d sbir_equipment_db_v3 -f temp_users.sql
psql -U postgres -d sbir_equipment_db_v3 -f temp_applications.sql
```

### 步驟 3：遷移 Users

```bash
psql -U postgres -d sbir_equipment_db_v3 -f 02_migrate_users.sql
```

### 步驟 4：遷移 Applications 到正規化結構

```bash
psql -U postgres -d sbir_equipment_db_v3 -f 03_migrate_applications.sql
```

此步驟會：
1. 建立缺少的 User 記錄（處理外鍵約束）
2. 建立 Item 記錄
3. 建立 Item_Material_Ext 記錄
4. 建立 Item_Equipment_Ext 記錄
5. 建立 Supplier 記錄
6. 建立 TechnicalDocument 記錄
7. 建立 item_number_xref 記錄
8. 建立 Application 記錄

### 步驟 5：驗證與清理

```bash
psql -U postgres -d sbir_equipment_db_v3 -f 04_verify_and_cleanup.sql
```

## 遷移結果（2025-12-26 執行）

| 表名 | 記錄數 |
|------|--------|
| old_data.users (來源) | 9 |
| old_data.applications (來源) | 121 |
| web_app.User | 9 |
| web_app.item | 1,001 |
| web_app.item_material_ext | 38 |
| web_app.item_equipment_ext | 38 |
| web_app.application | 121 |
| web_app.supplier | 4 |
| web_app.technicaldocument | 1 |
| web_app.item_number_xref | 61 |

## 已遷移使用者

| 使用者名稱 | 電子郵件 | 角色 |
|------------|----------|------|
| C112118237 | c112118237@nkust.edu.tw | admin |
| yjjchen | yjjchen@nkust.edu.tw | user |
| chaohui | chaohui@nkust.edu.tw | user |
| yuan6112 | yuan6112@sh-logistics.com.tw | user |
| Zi_Ching | chingluo9999@gmail.com | user |
| tim | timguanzhi@gmail.com | user |
| ChenTsungLung | yosafireandfroze@gmail.com | user |
| jonaschiu | jonaschiu0809@outlook.com | user |
| test1111 | fafa@gmail.com | user |

## 注意事項

1. **UUID 類型**：舊表的 `id` 欄位為 UUID 類型，非 SERIAL
2. **外鍵約束**：Application 表有 user_id, closed_by, nsn_filled_by 三個外鍵指向 User 表
3. **重複資料**：遷移腳本使用 `ON CONFLICT DO NOTHING` 處理重複
4. **編碼問題**：Windows 環境下使用 PowerShell pipe 執行 SQL 可能遇到 BIG5/UTF8 編碼問題

## 回滾

如需回滾，可以：

```sql
-- 刪除已遷移的資料（依照外鍵順序）
DELETE FROM web_app.application WHERE id IN (SELECT id FROM old_data.applications);
DELETE FROM web_app.item_number_xref WHERE pn_acquisition_source = 'migration';
DELETE FROM web_app.technicaldocument WHERE document_source = 'migration';
DELETE FROM web_app.supplier WHERE supplier_type IN ('manufacturer', 'agent');
-- ... 依序刪除其他表

-- 最後刪除暫存 schema
DROP SCHEMA old_data CASCADE;
```

## 檔案結構

```
migrations/
├── 01_create_old_data_staging.sql   # 建立暫存結構
├── 02_migrate_users.sql             # 遷移使用者
├── 03_migrate_applications.sql      # 遷移申請單（主要遷移）
├── 04_verify_and_cleanup.sql        # 驗證與清理
└── MIGRATION_GUIDE.md               # 本指南
```
