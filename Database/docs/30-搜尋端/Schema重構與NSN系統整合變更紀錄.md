# Schema 重構與 NSN 系統整合變更紀錄

**文件編號**: 30
**主題**: 搜尋端 - Schema 重構與 NSN 系統整合
**日期**: 2025-12-08 ~ 2025-12-09
**執行人**: 系統管理員
**資料庫**: sbir_equipment_db_v3

---

## 📋 變更摘要

本次變更將原有的單一 schema 架構重構為雙 schema 架構，並完整整合 NSN（NATO Stock Number）申編系統。

**核心變更**：

1. ✅ 將 `public` schema 更名為 `web_app`
2. ✅ 建立新的 `public` schema 用於 NSN 系統
3. ✅ 建立 15 個 NSN 核心表格 + 5 個查詢視圖
4. ✅ 匯入超過 50 萬筆 NSN 資料

---

## 🔄 第一階段：Schema 架構重構

### 變更內容

#### 1. Schema 重新命名

**原架構**：

```
sbir_equipment_db_v3
└─ public schema
   └─ 19 個表格（裝備管理 + Web 應用混合）
```

```
sbir_equipment_db_v3
├─ web_app schema (原 public)
│  └─ 19 個表格（裝備管理系統 + Web 應用）
│
└─ public schema (新建)
   ├─ 15 個 NSN 系統表格
   └─ 5 個查詢視圖
```

#### 2. web_app Schema 內容（19 個表格）

**裝備管理核心表（13 個）**：

- `supplier` - 廠商主檔
- `item` - 品項主檔（核心表，UUID 主鍵）
- `item_equipment_ext` - 裝備擴展表
- `item_material_ext` - 料件擴展表
- `item_emu3000_maintenance_ext` - EMU3000 維修物料擴展
- `bom` - BOM 主表
- `bom_line` - BOM 明細行（Item 自我關聯）
- `mrc` - 品項規格表
- `item_number_xref` - 零件號碼關聯檔
- `technicaldocument` - 技術文件檔
- `item_document_xref` - 品項文件關聯檔
- `suppliercodeapplication` - 廠商代號申請表
- `cidapplication` - CID 申請單

**Web 應用表（6 個）**：

- `User` - 使用者管理
- `application` - 申編單主表（50+ 欄位）
- `applicationattachment` - 附件管理（BYTEA 儲存）
- `usersession` - 工作階段管理
- `applicationlog` - 應用程式日誌
- `auditlog` - 稽核日誌

#### 3. public Schema 內容（15 個表格 + 5 個視圖）

**FSG/FSC 分類系統（3 個表格）**：

- `fsg` - FSG 聯邦補給群組
- `fsc` - FSC 聯邦補給分類
- `inc_fsc_xref` - INC 與 FSC 對應表

**NATO H6 物品名稱系統（2 個表格）**：

- `nato_h6_item_name` - NATO H6 物品名稱主檔
- `nato_h6_inc_xref` - NATO H6 與 INC 對應表

**INC 物品名稱代碼系統（2 個表格）**：

- `inc` - INC 物品名稱代碼
- `colloquial_inc_xref` - 俗語 INC 對應表

**FIIG 識別指南系統（2 個表格）**：

- `fiig` - FIIG 聯邦物品識別指南
- `fiig_inc_xref` - FIIG 與 INC 對應表

**MRC 需求代碼系統（4 個表格）**：

- `mrc_key_group` - MRC 群組
- `mrc` - MRC 物料需求代碼
- `fiig_inc_mrc_xref` - FIIG-INC-MRC 三元對應表（核心）
- `mrc_reply_table_xref` - MRC 與回應表對應

**回應系統（1 個表格）**：

- `reply_table` - 回應表主檔

**其他（1 個表格）**：

- `mode_code_edit` - 模式碼編輯指南

**查詢視圖（5 個）**：

- `v_h6_inc_mapping` - H6→INC 完整對應視圖
- `v_inc_fiig_mapping` - INC→FIIG 完整對應視圖
- `v_fiig_mrc_requirements` - FIIG→MRC 申編需求視圖
- `v_mrc_reply_options` - MRC 回應選項視圖
- `v_application_flow` - 完整申編流程視圖

### 執行腳本

**主腳本**：

- 檔案路徑：[`Database/scripts/04-schema-modifications/integrate_nsn_core.sql`](file:///c:/github/SBIR/Database/scripts/04-schema-modifications/integrate_nsn_core.sql)
- 功能：Schema 重構 + NSN 表格建立 + 索引 + 觸發器 + 視圖

**執行器**：

- 批次檔：[`run_integrate_nsn_core.bat`](file:///c:/github/SBIR/Database/scripts/04-schema-modifications/run_integrate_nsn_core.bat)
- Python 腳本：[`execute_integrate_nsn_core.py`](file:///c:/github/SBIR/Database/scripts/04-schema-modifications/execute_integrate_nsn_core.py)

**驗證工具**：

- [`verify_schema.py`](file:///c:/github/SBIR/Database/scripts/04-schema-modifications/verify_schema.py)

### 執行結果

✅ **執行時間**：2025-12-08 23:25✅ **執行狀態**：成功✅ **驗證結果**：

- web_app schema：19 個表格
- public schema：15 個表格 + 5 個視圖
- 所有索引和觸發器已建立

---

## 📥 第二階段：NSN 資料匯入

### 變更內容

將完整的 NSN 系統資料匯入到新建立的 `public` schema。

### 匯入資料清單

| 順序 | SQL 檔案                               | 大小     | 目標表格                 | 說明                      | 狀態 |
| ---- | -------------------------------------- | -------- | ------------------------ | ------------------------- | ---- |
| 1    | `00_import_fsg.sql`                  | 0.01 MB  | `fsg`                  | FSG 聯邦補給群組（80 筆） | ✅   |
| 2    | `01_import_mrc_key_group.sql`        | 0.00 MB  | `mrc_key_group`        | MRC 群組分類              | ✅   |
| 3    | `02_import_reply_table.sql`          | 16.3 MB  | `reply_table`          | 回應表主檔                | ✅   |
| 4    | `03_import_fsc.sql`                  | 0.3 MB   | `fsc`                  | FSC 聯邦補給分類          | ✅   |
| 5    | `04_import_nato_h6_item_name.sql`    | 8.4 MB   | `nato_h6_item_name`    | NATO H6 物品名稱          | ✅   |
| 6    | `05_import_inc.sql`                  | 25.0 MB  | `inc`                  | INC 物品名稱代碼          | ✅   |
| 7    | `06_import_mrc.sql`                  | 6.0 MB   | `mrc`                  | MRC 物料需求代碼          | ✅   |
| 8    | `07_import_mode_code_edit.sql`       | 0.00 MB  | `mode_code_edit`       | 模式碼編輯指南            | ✅   |
| 9    | `08_import_inc_fsc_xref.sql`         | 3.8 MB   | `inc_fsc_xref`         | INC-FSC 對應關係          | ✅   |
| 10   | `09_import_nato_h6_inc_xref.sql`     | 2.5 MB   | `nato_h6_inc_xref`     | H6-INC 對應關係           | ✅   |
| 11   | `10_import_colloquial_inc_xref.sql`  | 5.0 MB   | `colloquial_inc_xref`  | 俗語 INC 對應             | ✅   |
| 12   | `11_import_fiig.sql`                 | 0.5 MB   | `fiig`                 | FIIG 識別指南             | ✅   |
| 13   | `12_import_mrc_reply_table_xref.sql` | 2.6 MB   | `mrc_reply_table_xref` | MRC-回應表對應            | ✅   |
| 14   | `13_import_fiig_inc_xref.sql`        | 2.7 MB   | `fiig_inc_xref`        | FIIG-INC 對應             | ✅   |
| 15   | `14_import_fiig_inc_mrc_xref.sql`    | 233.8 MB | `fiig_inc_mrc_xref`    | FIIG-INC-MRC 三元對應     | ✅   |

**總計**：15 個檔案，306.8 MB

### 執行腳本

**主腳本**：

- 檔案路徑：[`Database/scripts/03-data-import/import_nsn_data.py`](file:///c:/github/SBIR/Database/scripts/03-data-import/import_nsn_data.py)
- 功能：自動順序執行 15 個 SQL 檔案，支援斷點續傳

**執行器**：

- 批次檔：[`run_import_nsn_data.bat`](file:///c:/github/SBIR/Database/scripts/03-data-import/run_import_nsn_data.bat)

**輔助工具**：

- 環境測試：[`test_import_environment.py`](file:///c:/github/SBIR/Database/scripts/03-data-import/test_import_environment.py)
- 匯入驗證：[`verify_nsn_import.py`](file:///c:/github/SBIR/Database/scripts/03-data-import/verify_nsn_import.py)

### 執行結果

✅ **執行時間**：2025-12-09 00:38 ~ 00:44（約 6 分鐘）
✅ **執行狀態**：全部成功
✅ **總記錄數**：超過 500,000 筆
✅ **驗證結果**：所有表格資料完整

---

## 🛠️ 建立的工具與腳本

### Schema 重構工具（4 個）

1. **integrate_nsn_core.sql**

   - 路徑：`Database/scripts/04-schema-modifications/`
   - 功能：完整的 schema 重構 + NSN 系統建立
   - 大小：約 50 KB
   - 內容：Schema 重構、建立 15 個表格、索引、觸發器、視圖、註解
2. **run_integrate_nsn_core.bat**

   - 路徑：`Database/scripts/04-schema-modifications/`
   - 功能：批次執行 schema 重構腳本
   - 特點：自動輸入密碼、顯示執行進度
3. **execute_integrate_nsn_core.py**

   - 路徑：`Database/scripts/04-schema-modifications/`
   - 功能：Python 執行器，支援命令列參數
   - 特點：互動式密碼輸入、錯誤處理
4. **verify_schema.py**

   - 路徑：`Database/scripts/04-schema-modifications/`
   - 功能：驗證 schema 重構結果
   - 輸出：Schema 列表、表格統計、關鍵表格檢查

### NSN 資料匯入工具（4 個）

1. **import_nsn_data.py**

   - 路徑：`Database/scripts/03-data-import/`
   - 功能：客製化 NSN 資料匯入工具
   - 特點：
     - 自動順序執行 15 個 SQL 檔案
     - 支援斷點續傳（--start-from 參數）
     - 完整的錯誤處理和日誌記錄
     - 匯入後自動驗證
2. **run_import_nsn_data.bat**

   - 路徑：`Database/scripts/03-data-import/`
   - 功能：批次執行 NSN 資料匯入
   - 特點：簡化執行流程
3. **test_import_environment.py**

   - 路徑：`Database/scripts/03-data-import/`
   - 功能：執行前環境檢查
   - 檢查項目：
     - 資料庫連接測試
     - SQL 檔案完整性
     - 路徑驗證
     - 檔案大小統計
4. **verify_nsn_import.py**

   - 路徑：`Database/scripts/03-data-import/`
   - 功能：驗證 NSN 資料匯入結果
   - 輸出：各表格資料筆數、視圖列表

---

## 📊 資料庫最終狀態

### Schema 架構圖

```
sbir_equipment_db_v3
│
├─ web_app schema (原 public)
│  │
│  ├─ 裝備管理核心（13 個表格）
│  │  ├─ supplier (廠商主檔)
│  │  ├─ item (品項主檔) ⭐
│  │  ├─ item_equipment_ext (裝備擴展)
│  │  ├─ item_material_ext (料件擴展)
│  │  ├─ item_emu3000_maintenance_ext (EMU3000 維修物料)
│  │  ├─ bom (BOM 主表)
│  │  ├─ bom_line (BOM 明細行)
│  │  ├─ mrc (品項規格表)
│  │  ├─ item_number_xref (零件號碼關聯)
│  │  ├─ technicaldocument (技術文件)
│  │  ├─ item_document_xref (品項文件關聯)
│  │  ├─ suppliercodeapplication (廠商代號申請)
│  │  └─ cidapplication (CID 申請單)
│  │
│  └─ Web 應用（6 個表格）
│     ├─ User (使用者管理)
│     ├─ application (申編單主表)
│     ├─ applicationattachment (附件管理)
│     ├─ usersession (工作階段)
│     ├─ applicationlog (應用程式日誌)
│     └─ auditlog (稽核日誌)
│
└─ public schema (新建)
   │
   ├─ NSN 申編系統（15 個表格）
   │  ├─ FSG/FSC 分類
   │  │  ├─ fsg
   │  │  ├─ fsc
   │  │  └─ inc_fsc_xref
   │  │
   │  ├─ NATO H6 系統
   │  │  ├─ nato_h6_item_name
   │  │  └─ nato_h6_inc_xref
   │  │
   │  ├─ INC 系統
   │  │  ├─ inc
   │  │  └─ colloquial_inc_xref
   │  │
   │  ├─ FIIG 系統
   │  │  ├─ fiig
   │  │  └─ fiig_inc_xref
   │  │
   │  ├─ MRC 系統
   │  │  ├─ mrc_key_group
   │  │  ├─ mrc
   │  │  ├─ fiig_inc_mrc_xref ⭐
   │  │  └─ mrc_reply_table_xref
   │  │
   │  ├─ 回應系統
   │  │  └─ reply_table
   │  │
   │  └─ 其他
   │     └─ mode_code_edit
   │
   └─ 查詢視圖（5 個）
      ├─ v_h6_inc_mapping
      ├─ v_inc_fiig_mapping
      ├─ v_fiig_mrc_requirements
      ├─ v_mrc_reply_options
      └─ v_application_flow
```

### 資料庫連接配置

**更新後的連接設定**：

```python
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'dbname': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'your_password',
    'options': '-c search_path=web_app,public'  # 同時存取兩個 schema
}
```

---

## 🔍 NSN 申編流程說明

### 資料流程

```
NATO H6 物品名稱
    ↓ (nato_h6_inc_xref)
INC 物品名稱代碼
    ↓ (fiig_inc_xref)
FIIG 識別指南
    ↓ (fiig_inc_mrc_xref)
MRC 物料需求代碼
    ↓ (mrc_reply_table_xref)
回應表選項
```

### 關鍵查詢視圖

**1. v_application_flow - 完整申編流程視圖**

```sql
SELECT * FROM public.v_application_flow
WHERE nato_item_name LIKE '%pump%'
LIMIT 10;
```

**2. v_fiig_mrc_requirements - 查詢特定 FIIG 的 MRC 需求**

```sql
SELECT * FROM public.v_fiig_mrc_requirements
WHERE fiig_code = 'YOUR_FIIG_CODE';
```

**3. v_h6_inc_mapping - H6 與 INC 對應**

```sql
SELECT * FROM public.v_h6_inc_mapping
WHERE nato_item_name LIKE '%valve%';
```

---

## ⚠️ 注意事項與影響

### 應用程式需要更新的部分

1. **資料庫連接字串**

   - 必須更新 `search_path` 為 `web_app,public`
   - 確保能同時存取兩個 schema
2. **SQL 查詢**

   - 原有查詢不需修改（預設使用 web_app）
   - 新的 NSN 查詢需指定 schema：`public.table_name`
3. **ORM 配置**

   - 如使用 SQLAlchemy 等 ORM，需更新 schema 設定

### 資料完整性

- ✅ 所有原有資料保持完整（在 web_app schema）
- ✅ NSN 資料已完整匯入（超過 50 萬筆）
- ✅ 所有外鍵關聯正常
- ✅ 索引和觸發器已建立

### 效能考量

- 建議為常用查詢建立額外索引
- 定期執行 `VACUUM ANALYZE` 維護統計資訊
- 大量查詢時考慮使用查詢視圖

---

## 📝 相關文件

1. **資料庫結構文檔**

   - [01-資料庫結構_v3.2.md](file:///c:/github/SBIR/Database/docs/00-整體架構/01-資料庫結構_v3.2.md)
2. **操作手冊**

   - Schema 重構腳本：[`integrate_nsn_core.sql`](file:///c:/github/SBIR/Database/scripts/04-schema-modifications/integrate_nsn_core.sql)
   - 資料匯入腳本：[`import_nsn_data.py`](file:///c:/github/SBIR/Database/scripts/03-data-import/import_nsn_data.py)

---

**文件建立日期**: 2025-12-09
**文件版本**: 1.0
**最後更新**: 2025-12-09 18:52
