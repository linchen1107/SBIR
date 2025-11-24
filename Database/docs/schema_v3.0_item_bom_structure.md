# SBIR 裝備資料庫中英文對照表 (V3.0)

## 📊 資料庫資訊

- **資料庫名稱**: sbir_equipment_db_v2
- **版本**: V3.0
- **用途**: 海軍裝備管理系統
- **編碼**: UTF8
- **建立日期**: 2025-11-19
- **最後更新**: 2025-11-19
- **資料來源**: 電笛系統各M表
- **架構特點**: Item 自我關聯 BOM 結構，UUID 主鍵，擴展表設計
- **總表數**: 14 個資料表

---

## 📋 欄位對照說明圖例

- 🔑 = 主鍵 (Primary Key)
- 🔗 = 外鍵 (Foreign Key)
- ⭐ = 必填欄位 (Required)
- 📝 = 選填欄位 (Optional)
- 🔄 = 自動產生 (Auto Generated)

---

## 📑 目錄

- [資料表總覽](#資料表總覽)
- [V3.0 重構變更說明](#v30-重構變更說明)
- [第一階段：主表](#第一階段主表)
  - [1. Supplier (廠商主檔)](#1-supplier-廠商主檔)
  - [2. Item (品項主檔)](#2-item-品項主檔)
  - [3. Item_Equipment_Ext (裝備擴展表)](#3-item_equipment_ext-裝備擴展表)
  - [4. Item_Material_Ext (料件擴展表)](#4-item_material_ext-料件擴展表)
- [第二階段：BOM 結構](#第二階段bom-結構)
  - [5. BOM (BOM主表)](#5-bom-bom主表)
  - [6. BOM_LINE (BOM明細行)](#6-bom_line-bom明細行)
  - [7. MRC (品項規格表)](#7-mrc-品項規格表)
- [第三階段：關聯表](#第三階段關聯表)
  - [8. Item_Supplier_xref (品項廠商關聯檔)](#8-item_supplier_xref-品項廠商關聯檔)
- [第四階段：輔助資料](#第四階段輔助資料)
  - [9. TechnicalDocument (技術文件檔)](#9-technicaldocument-技術文件檔)
  - [10. Item_Document_xref (品項文件關聯檔)](#10-item_document_xref-品項文件關聯檔)
  - [11. ApplicationFormDetail (申編單明細檔)](#11-applicationformdetail-申編單明細檔)
  - [12. ApplicationForm (申編單檔)](#12-applicationform-申編單檔)
  - [13. SupplierCodeApplication (廠商代號申請表)](#13-suppliercodeapplication-廠商代號申請表)
  - [14. CIDApplication (CID申請單)](#14-cidapplication-cid申請單)

---

## 資料表總覽

| 編號               | 英文表名                | 中文名稱       | 主鍵類型  | 用途                       |
| ------------------ | ----------------------- | -------------- | --------- | -------------------------- |
| **主表**     |                         |                |           |                            |
| 1                  | Supplier                | 廠商主檔       | SERIAL    | 供應商/製造商基本資料      |
| 2                  | Item                    | 品項主檔 ⭐    | UUID      | 統一品項資料（核心表）     |
| 3                  | Item_Equipment_Ext      | 裝備擴展表     | UUID (FK) | 裝備類型專用欄位           |
| 4                  | Item_Material_Ext       | 料件擴展表     | UUID (FK) | 料件類型專用欄位           |
| **BOM 結構** |                         |                |           |                            |
| 5                  | BOM                     | BOM主表        | UUID      | BOM版本控制                |
| 6                  | BOM_LINE                | BOM明細行 ⭐   | UUID      | Item自我關聯（元件清單）   |
| 7                  | MRC                     | 品項規格表     | UUID      | 品項規格資料               |
| **關聯表**   |                         |                |           |                            |
| 8                  | Item_Supplier_xref      | 品項廠商關聯檔 | SERIAL    | 品項-零件號-廠商多對多關聯 |
| **輔助資料** |                         |                |           |                            |
| 9                  | TechnicalDocument       | 技術文件檔     | SERIAL    | 技術文件/手冊主檔          |
| 10                 | Item_Document_xref      | 品項文件關聯檔 | 複合鍵    | 品項-技術文件多對多關聯    |
| 11                 | ApplicationFormDetail   | 申編單明細檔   | SERIAL    | 申編單明細                 |
| 12                 | ApplicationForm         | 申編單檔       | SERIAL    | 申編單主檔                 |
| 13                 | SupplierCodeApplication | 廠商代號申請表 | UUID      | 廠商代號申請               |
| 14                 | CIDApplication          | CID申請單      | UUID      | CID申請                    |

**總計**: 14 個資料表（4主表 + 3 BOM結構 + 1關聯表 + 6輔助表）

---

## 📥 資料匯入說明

### 匯入工具概述

專案提供兩個 Python 匯入腳本，支援不同格式的資料匯入：

| 腳本名稱 | 用途 | 來源格式 | 位置 |
|---------|------|---------|------|
| `import_application_data.py` | 料號申編單匯入 | JSONL | `Database/scripts/` |
| `import_excel_data.py` | ILS總表匯入 | Excel (.xlsx) | `Database/scripts/` |

---

### 1. JSONL 格式匯入（料號申編單）

**來源**: 舊版資料庫匯出的 `export.jsonl` 檔案
**腳本**: `Database/scripts/import_application_data.py`

#### 使用方式

```bash
# 執行匯入
cd Database/scripts
python import_application_data.py
```

#### 欄位對應表

**來源表**: `web_app.applications` (舊版資料庫)

##### → Item 表
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| part_number | item_code | 料號 |
| chinese_name | item_name_zh | 中文品名 |
| english_name | item_name_en | 英文品名 |
| (自動判斷) | item_type | FG/SEMI/RM |

**item_type 判斷邏輯**:
- 有 `ship_type` / `cid_no` / `equipment_name` → FG (成品)
- 有 `inc_code` / `fiig_code` → RM (原物料)
- 其他 → RM (預設)

##### → Item_Equipment_Ext 表 (FG類型)
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| ship_type | ship_type | 艦型 |
| cid_no | parent_cid | CID編號 |
| usage_location | installation_location | 裝設地點 |
| equipment_name | parent_equipment_zh | 裝備中文名 |
| english_name | parent_equipment_en | 裝備英文名 |
| quantity_per_unit | installation_qty | 安裝數量 |

##### → Item_Material_Ext 表 (SEMI/RM類型)
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| official_nsn_final | nsn | NSN料號 |
| inc_code / accounting_unit_code | accounting_code | 會計編號 |
| fiig_code | fiig | FIIG碼 |
| unit_price | unit_price_usd | 單價(USD) |
| issue_unit | issue_unit | 發放單位 |
| spec_indicator | spec_indicator | 規格指標 |

##### → MRC 表 (規格資料)
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| mrc_data[].mrc_code | spec_abbr | MRC代碼 |
| mrc_data[].mrc_name_en | spec_en | 規格名稱(英) |
| mrc_data[].mrc_name_zh | spec_zh | 規格名稱(中) |
| mrc_data[].mrc_value_en | answer_en | 規格值(英) |
| mrc_data[].mrc_value_zh | answer_zh | 規格值(中) |
| mrc_data[].sort_order | spec_no | 排序 |

##### → Supplier 表
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| manufacturer | cage_code | CAGE碼 |
| manufacturer_name | supplier_name_zh | 廠商名稱 |
| agent_name | (備註) | 代理商 |

##### → ApplicationForm 表
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| form_serial_number | form_no | 申編單號 |
| part_number | yetl | YETL料號 |
| status | submission_state | 提送狀態 |
| accounting_unit_code | applicant_accounting_code | 申請單位 |

##### → Item_Supplier_xref 表
| 來源欄位 | 目標欄位 | 說明 |
|---------|---------|------|
| part_number_reference | part_number | 參考料號 |
| (supplier_id) | supplier_id | 供應商ID |
| TRUE | is_primary | 主要料號 |

---

### 2. Excel 格式匯入（ILS總表）

**來源**: ILS 總表 Excel 檔案（如：廚房滅火系統ILS及APL_版4.1.xlsx）
**腳本**: `Database/scripts/import_excel_data.py`
**工作表**: 項碼資料（第3個工作表，索引2）

#### 使用方式

```bash
# 修改腳本中的檔案路徑
# import_file = 'path/to/your/excel.xlsx'

cd Database/scripts
python import_excel_data.py
```

#### Excel 欄位對應表

**註**: 使用欄位索引避免中文編碼問題

##### → Item 表
| Excel欄位索引 | Excel欄位名 | 目標欄位 | 處理邏輯 |
|-------------|-----------|---------|---------|
| 3 | 料號分類號碼 | item_code | 取前4碼+YETL (如: 1369YETL) |
| 5 | 英文品名 | item_name_en | 英文名稱 |
| 6 | 中文品名 | item_name_zh | 中文名稱 |
| (固定) | - | item_type | 'RM' (預設原物料) |

**料號生成規則**:
- 有NSN → 取前4碼 + "YETL" (如: 13699819 → 1369YETL)
- 無NSN但有序號 → "ITEM" + 序號 (如: ITEM0001)

##### → Item_Material_Ext 表
| Excel欄位索引 | Excel欄位名 | 目標欄位 | 說明 |
|-------------|-----------|---------|------|
| 3 | 料號分類號碼 | nsn | 格式化為 NNNN-NN-NNN-NNNN |
| 2 | 儲備會計號碼 | accounting_code | INC碼 |
| 13 | 類別號碼 | fiig | FIIG碼 |
| 7 | 會計編號 | (accounting_code備用) | 會計編號 |
| 8 | 發放單位 | issue_unit | 發放單位 |
| 9 | 單位價格 | unit_price_usd | 單價 |
| 12 | 規格號碼 | spec_indicator | 規格指標 |

##### → Supplier 表
| Excel欄位索引 | Excel欄位名 | 目標欄位 | 說明 |
|-------------|-----------|---------|------|
| 24 | 廠商代號 | cage_code | CAGE碼 |

---

### 資料清除與重新匯入

如需清除資料庫重新匯入，請執行以下指令：

```sql
-- 清除所有表資料（保留結構）
TRUNCATE TABLE applicationform_detail CASCADE;
TRUNCATE TABLE applicationform CASCADE;
TRUNCATE TABLE mrc CASCADE;
TRUNCATE TABLE item_supplier_xref CASCADE;
TRUNCATE TABLE item_equipment_ext CASCADE;
TRUNCATE TABLE item_material_ext CASCADE;
TRUNCATE TABLE bom_line CASCADE;
TRUNCATE TABLE bom CASCADE;
TRUNCATE TABLE item CASCADE;
TRUNCATE TABLE supplier RESTART IDENTITY CASCADE;
```

或使用 psql 指令：

```bash
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" \
  -U postgres -h localhost -p 5432 -d sbir_equipment_db_v2 \
  -c "TRUNCATE TABLE item CASCADE; TRUNCATE TABLE supplier RESTART IDENTITY CASCADE;"
```

---

### 常見問題處理

#### Q1: 編碼問題（亂碼）
**解決方案**:
- Python 腳本已設定 UTF-8 編碼
- PostgreSQL 使用 `conn.set_client_encoding('UTF8')`
- Excel 匯入使用欄位索引而非欄位名

#### Q2: 重複資料
**解決方案**:
- 腳本會自動檢查 `item_code` 是否存在
- 使用 `ON CONFLICT DO NOTHING` 或 `DO UPDATE` 處理衝突

#### Q3: 外鍵錯誤
**解決方案**:
- 確保 Supplier 在 Item 之前建立
- 確保 Item 在 MRC/BOM 之前建立
- 匯入順序: Supplier → Item → Ext表 → MRC → ApplicationForm

#### Q4: UUID vs SERIAL 主鍵
- Item/BOM/BOM_LINE: 使用 UUID (腳本自動生成)
- Supplier/MRC/ApplicationForm: 使用 SERIAL (資料庫自動編號，不需提供)

---

## V3.0 重構變更說明

### 🔄 重構目標

- ✅ Item 自我關聯的 BOM 結構（支援多層級）
- ✅ UUID 主鍵設計
- ✅ 擴展表設計（減少 NULL 欄位）
- ✅ BOM 版本控制（支援歷史追溯）
- ✅ 統一 Equipment 和 Item 為單一 Item 表

### 📦 主要變更

#### 1. ✅ Equipment + Item 合併為 Item (UUID PK)

**原因**:

- 統一品項管理，使用 item_type 區分類型
- 支援 BOM 自我關聯結構

**影響**:

- Item 使用 UUID 作為主鍵
- item_type: FG(成品) / SEMI(半成品) / RM(原物料)
- 原 Equipment 欄位移至 Item_Equipment_Ext
- 原 Item 屬性欄位移至 Item_Material_Ext

#### 2. ✅ 新增擴展表設計

**原因**:

- 減少主表寬度和 NULL 欄位
- 依類型分別管理專屬欄位

**影響**:

- Item_Equipment_Ext: 裝備專用（艦型、ESWBS等）
- Item_Material_Ext: 料件專用（NSN、單價等）

#### 3. ✅ BOM + BOM_LINE 取代 BOM_xref

**原因**:

- 支援 BOM 版本控制（revision, effective_from/to）
- 支援 Item 自我關聯的多層級結構
- 支援歷史追溯（餅乾公司追溯問題）

**影響**:

- BOM: 版本控制主表
- BOM_LINE: 元件明細（component_item_uuid → Item）

#### 4. ✅ Item_Supplier_xref 取代 Part_Number_xref

**原因**:

- 更準確反映表的用途：品項-廠商關聯
- 與其他 xref 表命名一致

#### 5. ✅ MRC 取代 ItemSpecification

**原因**:

- 統一規格表命名
- 使用 mrc_id (SERIAL) 作為主鍵

---

## 第一階段：主表

### 1. Supplier (廠商主檔)

**用途**: 管理供應商/製造商基本資料
**來源**: 19M, 20M

| 英文欄位名       | 中文名稱           | 資料類型     | 標記   | 說明          |
| ---------------- | ------------------ | ------------ | ------ | ------------- |
| supplier_id      | 廠商ID             | SERIAL       | 🔑🔄   | 自動編號      |
| supplier_code    | 廠商來源代號       | VARCHAR(20)  | UNIQUE | 廠商代碼      |
| cage_code        | 廠家登記代號       | VARCHAR(20)  | UNIQUE | CAGE CODE     |
| supplier_name_en | 廠家製造商（英文） | VARCHAR(200) | ⭐     | 英文廠商名稱  |
| supplier_name_zh | 廠商中文名稱       | VARCHAR(100) | 📝     | 中文廠商名稱  |
| supplier_type    | 廠商類型           | VARCHAR(20)  | 📝     | 製造商/代理商 |
| country_code     | 國家代碼           | VARCHAR(10)  | 📝     | 國別代碼      |
| date_created       | 建立時間           | TIMESTAMP    | 🔄     | 記錄建立時間  |
| date_updated       | 更新時間           | TIMESTAMP    | 🔄     | 記錄更新時間  |

---

### 2. Item (品項主檔) ⭐

**用途**: 統一管理所有品項（成品/半成品/原物料）
**V3.0 變更**: 合併 Equipment，使用 UUID 主鍵

| 英文欄位名   | 中文名稱     | 資料類型     | 標記      | 說明            |
| ------------ | ------------ | ------------ | --------- | --------------- |
| item_uuid    | 品項UUID     | UUID         | 🔑🔄      | 自動生成 UUID   |
| item_code    | 統一識別碼   | VARCHAR(50)  | ⭐ UNIQUE | CID 或 NIIN     |
| item_name_zh | 中文品名     | VARCHAR(100) | ⭐        | 品項中文名稱    |
| item_name_en | 英文品名     | VARCHAR(200) | ⭐        | 品項英文名稱    |
| item_type    | 品項類型     | VARCHAR(10)  | ⭐        | FG/SEMI/RM      |
| uom          | 基本計量單位 | VARCHAR(10)  | 📝        | EA/SET/LOT等    |
| state        | 狀態         | VARCHAR(20)  | 📝        | Active/Inactive |
| date_created   | 建立時間     | TIMESTAMP    | 🔄        | 記錄建立時間    |
| date_updated   | 更新時間     | TIMESTAMP    | 🔄        | 記錄更新時間    |

**約束**:

- `item_type IN ('FG', 'SEMI', 'RM')`
- `state IN ('Active', 'Inactive')`

**索引**:

- `idx_item_code` - 識別碼索引
- `idx_item_type` - 類型索引
- `idx_item_state` - 狀態索引

---

### 3. Item_Equipment_Ext (裝備擴展表)

**用途**: 裝備類型專用欄位（FG 類型）
**來源**: 原 Equipment 表

| 英文欄位名             | 中文名稱             | 資料類型     | 標記   | 說明            |
| ---------------------- | -------------------- | ------------ | ------ | --------------- |
| item_uuid              | 品項UUID             | UUID         | 🔑🔗   | 外鍵連結至 Item |
| equipment_type         | 裝備形式             | VARCHAR(50)  | 📝     | 裝備型號/型式   |
| ship_type              | 艦型                 | VARCHAR(50)  | 📝     | 適用艦型        |
| installation_location  | 裝設地點             | VARCHAR(100) | 📝     | 安裝位置        |
| parent_equipment_zh    | 上層適用裝備中文名稱 | VARCHAR(100) | 📝     | 父裝備中文名    |
| parent_equipment_en    | 上層適用裝備英文名稱 | VARCHAR(200) | 📝     | 父裝備英文名    |
| parent_cid             | 上層CID              | VARCHAR(50)  | 📝     | 父裝備識別碼    |
| eswbs_code             | 族群結構碼HSC        | VARCHAR(20)  | 📝     | ESWBS（五碼）   |
| system_function_name   | 系統功能名稱         | VARCHAR(200) | 📝     | 系統功能說明    |
| installation_qty       | 同一類型數量         | INT          | 📝     | 單艦裝置數量    |
| total_installation_qty | 全艦裝置數           | INT          | 📝     | 全艦總數        |
| maintenance_level      | 裝備維修等級代碼     | VARCHAR(10)  | 📝     | 維修等級        |
| equipment_serial       | 裝備序號             | VARCHAR(50)  | UNIQUE | 裝備識別編號    |
| date_created             | 建立時間             | TIMESTAMP    | 🔄     |                 |
| date_updated             | 更新時間             | TIMESTAMP    | 🔄     |                 |

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

**索引**:

- `idx_equip_ext_ship_type` - 艦型索引
- `idx_equip_ext_eswbs` - ESWBS碼索引

---

### 4. Item_Material_Ext (料件擴展表)

**用途**: 料件類型專用欄位（SEMI/RM 類型）
**來源**: 原 Item 表屬性欄位

| 英文欄位名             | 中文名稱             | 資料類型      | 標記   | 說明                    |
| ---------------------- | -------------------- | ------------- | ------ | ----------------------- |
| item_uuid              | 品項UUID             | UUID          | 🔑🔗   | 外鍵連結至 Item         |
| item_id_last5          | 品項識別碼(後五碼) | VARCHAR(5)    | 📝     | 快速識別用              |
| item_name_zh_short     | 中文品名（9字內）    | VARCHAR(20)   | 📝     | 簡短中文名              |
| nsn                    | NSN/國家料號         | VARCHAR(20)   | UNIQUE | NATO Stock Number       |
| item_category          | 統一組類別           | VARCHAR(10)   | 📝     | 品項分類代碼            |
| item_code              | 品名代號             | VARCHAR(10)   | 📝     | INC品名代號             |
| fiig                   | FIIG                 | VARCHAR(10)   | 📝     | 聯邦品項識別指南        |
| weapon_system_code     | 武器系統代號         | VARCHAR(20)   | 📝     | 所屬武器系統            |
| accounting_code        | 會計編號             | VARCHAR(20)   | 📝     | 會計科目代號            |
| issue_unit             | 撥發單位             | VARCHAR(10)   | 📝     | 撥發單位（EA/SET/LOT等）|
| unit_price_usd         | 美金單價             | DECIMAL(10,2) | 📝     | 單位價格（美金）        |
| package_qty            | 單位包裝量           | INT           | 📝     | 包裝數量                |
| weight_kg              | 重量(KG)             | DECIMAL(10,3) | 📝     | 單位重量（公斤）        |
| has_stock              | 有無料號             | BOOLEAN       | 📝     | 是否有庫存料號          |
| storage_life_code      | 存儲壽限代號         | VARCHAR(10)   | 📝     | 儲存期限代碼            |
| file_type_code         | 檔別代號             | VARCHAR(10)   | 📝     | 檔案類型代號            |
| file_type_category     | 檔別區分             | VARCHAR(10)   | 📝     | 檔案分類                |
| security_code          | 機密性代號           | VARCHAR(10)   | 📝     | 機密等級（U/C/S等）     |
| consumable_code        | 消耗性代號           | VARCHAR(10)   | 📝     | 消耗品分類（M/N等）     |
| spec_indicator         | 規格指示             | VARCHAR(10)   | 📝     | 規格指標                |
| navy_source            | 海軍軍品來源         | VARCHAR(50)   | 📝     | 來源說明                |
| storage_type           | 儲存型式             | VARCHAR(20)   | 📝     | 儲存方式                |
| life_process_code      | 處理代號 (壽限處理)   | VARCHAR(10)   | 📝     | 壽限管理代號            |
| manufacturing_capacity | 製造能量             | VARCHAR(10)   | 📝     | 製造能力                |
| repair_capacity        | 修理能量             | VARCHAR(10)   | 📝     | 修理能力                |
| source_code            | 來源代號             | VARCHAR(10)   | 📝     | 來源分類                |
| project_code           | 專案代號             | VARCHAR(20)   | 📝     | 所屬專案                |
| date_created             | 建立時間             | TIMESTAMP     | 🔄     |                         |
| date_updated             | 更新時間             | TIMESTAMP     | 🔄     |                         |

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

**約束**:

- `unit_price_usd >= 0`
- `weight_kg >= 0`

**索引**:

- `idx_material_ext_nsn` - NSN索引
- `idx_material_ext_category` - 分類索引
- `idx_material_ext_accounting` - 會計編號索引

---

## 第二階段：BOM 結構

### 為什麼需要 BOM 和 BOM_LINE？

**BOM（版本控制）**：
- 管理產品配方的「版本」資訊（版本號、生效日期、狀態）
- 支援歷史追溯：可查詢某日期使用的 BOM 版本
- 一個品項可有多個版本（草稿/正式版）

**BOM_LINE（零件清單）**：
- 記錄「這個產品由哪些零件組成」
- **核心功能**：`component_item_uuid` 欄位連回 `Item` 表，實現自我關聯
- 一個 BOM 可包含多個零件（1:N 關係）

**為何分兩表？**
- **職責分離**：BOM 管版本，BOM_LINE 管零件清單
- **支援多階結構**：零件本身也可以有 BOM（電笛系統主機 → BOM → 喇叭、面板等）
- **可擴展**：零件數量不受限制

```
Item (電笛系統) → BOM v1.0 → BOM_LINE → Item (電笛系統主機)
                                              ↓
                                         BOM v1.0 → BOM_LINE → Item (喇叭) x2
                                                              → Item (面板)
```

---

### 5. BOM (BOM主表)

**用途**: BOM 版本控制
**V3.0 新增**: 支援版本管理和歷史追溯

| 英文欄位名     | 中文名稱 | 資料類型    | 標記 | 說明                 |
| -------------- | -------- | ----------- | ---- | -------------------- |
| bom_uuid       | BOM UUID | UUID        | 🔑🔄 | 自動生成 UUID        |
| item_uuid      | 成品料號 | UUID        | 🔗⭐ | 外鍵連結至 Item      |
| bom_code       | BOM編號  | VARCHAR(50) | 📝   | BOM 識別碼           |
| revision       | 版次     | VARCHAR(20) | 📝   | 版本號 (1.0, 1.1...) |
| effective_from | 生效日   | DATE        | 📝   | 開始生效日期         |
| effective_to   | 失效日   | DATE        | 📝   | 結束生效日期         |
| state          | 狀態     | VARCHAR(20) | 📝   | Released/Draft       |
| notes          | 備註     | TEXT        | 📝   | 備註說明             |
| date_created     | 建立時間 | TIMESTAMP   | 🔄   |                      |
| date_updated     | 更新時間 | TIMESTAMP   | 🔄   |                      |

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

**約束**:

- `state IN ('Released', 'Draft')`

**索引**:

- `idx_bom_item` - 品項索引
- `idx_bom_state` - 狀態索引
- `idx_bom_effective` - 生效日期索引

---

### 6. BOM_LINE (BOM明細行) ⭐

**用途**: BOM 元件清單（Item 自我關聯）
**V3.0 核心**: 實現多層級 BOM 結構

| 英文欄位名          | 中文名稱 | 資料類型      | 標記 | 說明                    |
| ------------------- | -------- | ------------- | ---- | ----------------------- |
| line_uuid           | 行UUID   | UUID          | 🔑🔄 | 自動生成 UUID           |
| bom_uuid            | BOM UUID | UUID          | 🔗⭐ | 外鍵連結至 BOM          |
| line_no             | 行號     | INT           | ⭐   | 排序用                  |
| component_item_uuid | 元件料號 | UUID          | 🔗⭐ | 外鍵連結至 Item（元件） |
| qty_per             | 單位用量 | DECIMAL(10,4) | ⭐   | 每單位成品需要數量      |
| scrap_type          | 損耗型態 | VARCHAR(20)   | 📝   | 損耗計算方式            |
| scrap_rate          | 損耗率   | DECIMAL(5,4)  | 📝   | 損耗百分比              |
| uom                 | 用量單位 | VARCHAR(10)   | 📝   | 預設跟元件UOM一致       |
| assembly_position   | 裝配位置 | VARCHAR(100)  | 📝   | 裝配位置/站別           |
| notes               | 備註     | TEXT          | 📝   | 備註說明                |
| date_created          | 建立時間 | TIMESTAMP     | 🔄   |                         |
| date_updated          | 更新時間 | TIMESTAMP     | 🔄   |                         |

**外鍵關聯**:

- `bom_uuid` → `BOM.bom_uuid` (ON DELETE CASCADE)
- `component_item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

**約束**:

- `unique_bom_line` - (bom_uuid, line_no) 組合唯一

**索引**:

- `idx_bom_line_bom` - BOM索引
- `idx_bom_line_component` - 元件索引

**設計說明**:

- 一個 BOM 可有多個 BOM_LINE
- component_item_uuid 指向另一個 Item（元件）
- 這就是 Item 自我關聯的核心

---

### 7. MRC (品項規格表)

**用途**: 記錄品項的規格資料
**V3.0 變更**: 取代 ItemSpecification，使用 UUID 主鍵

| 英文欄位名 | 中文名稱     | 資料類型     | 標記 | 說明            |
| ---------- | ------------ | ------------ | ---- | --------------- |
| mrc_uuid   | MRC UUID     | UUID         | 🔑🔄 | 自動生成 UUID   |
| item_uuid  | 品項UUID     | UUID         | 🔗⭐ | 外鍵連結至 Item |
| spec_no    | 規格順序     | INT          | 📝   | 順序編號        |
| spec_abbr  | 規格資料縮寫 | VARCHAR(20)  | 📝   | 規格簡稱        |
| spec_en    | 規格資料英文 | VARCHAR(200) | 📝   | 規格項目英文    |
| spec_zh    | 規格資料翻譯 | VARCHAR(200) | 📝   | 規格項目中文    |
| answer_en  | 英答         | VARCHAR(200) | 📝   | 規格值英文      |
| answer_zh  | 中答         | VARCHAR(200) | 📝   | 規格值中文      |
| date_created | 建立時間     | TIMESTAMP    | 🔄   |                 |
| date_updated | 更新時間     | TIMESTAMP    | 🔄   |                 |

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

**索引**:

- `idx_mrc_item` - 品項索引
- `idx_mrc_abbr` - 縮寫索引

---

## 第三階段：關聯表

### 8. Item_Supplier_xref (品項廠商關聯檔)

**用途**: 品項-零件號-廠商的多對多關聯
**來源**: 20M_料號主要件號檔
**V3.1 變更**: 從 Part_Number_xref 改名為 Item_Supplier_xref

| 英文欄位名             | 中文名稱         | 資料類型    | 標記 | 說明                |
| ---------------------- | ---------------- | ----------- | ---- | ------------------- |
| part_number_id         | 零件號碼ID       | SERIAL      | 🔑🔄 | 自動編號            |
| part_number            | 配件號碼         | VARCHAR(50) | ⭐   | P/N                 |
| item_uuid              | 品項UUID         | UUID        | 🔗⭐ | 外鍵連結至 Item     |
| supplier_id            | 廠商ID           | INT         | 🔗   | 外鍵連結至 Supplier |
| acquisition_difficulty | 參考號獲得程度   | VARCHAR(10) | 📝   | 取得難易度          |
| acquisition_channel    | 參考號獲得來源   | VARCHAR(50) | 📝   | 取得管道            |
| is_primary             | 是否為主要零件號 | BOOLEAN     | 📝   | 主/替代零件號       |
| date_created             | 建立時間         | TIMESTAMP   | 🔄   |                     |
| date_updated             | 更新時間         | TIMESTAMP   | 🔄   |                     |

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)
- `supplier_id` → `Supplier.supplier_id` (ON DELETE SET NULL)

**約束**:

- `unique_item_supplier` - (part_number, item_uuid, supplier_id) 組合唯一

**索引**:

- `idx_item_supplier_part_number` - 零件號索引
- `idx_item_supplier_item` - 品項索引
- `idx_item_supplier_supplier` - 廠商索引

---

## 第四階段：輔助資料

### 9. TechnicalDocument (技術文件檔)

**用途**: 管理技術文件與圖面資料

| 英文欄位名          | 中文名稱      | 資料類型     | 標記 | 說明         |
| ------------------- | ------------- | ------------ | ---- | ------------ |
| document_id         | 文件ID        | SERIAL       | 🔑🔄 | 自動編號     |
| document_name       | 圖名/書名     | VARCHAR(200) | ⭐   | 文件名稱     |
| document_version    | 版次          | VARCHAR(20)  | 📝   | 版本號       |
| shipyard_drawing_no | 船廠圖號      | VARCHAR(50)  | 📝   | 船廠圖面編號 |
| design_drawing_no   | 設計圖號      | VARCHAR(50)  | 📝   | 設計圖面編號 |
| document_type       | 資料類型      | VARCHAR(20)  | 📝   | 文件類型     |
| document_category   | 資料類別      | VARCHAR(20)  | 📝   | 文件分類     |
| language            | 語言          | VARCHAR(10)  | 📝   | 中文/英文    |
| security_level      | 機密等級      | VARCHAR(10)  | 📝   | 機密分級     |
| eswbs_code          | ESWBS（五碼） | VARCHAR(20)  | 📝   | 裝備分類碼   |
| accounting_code     | 會計編號      | VARCHAR(20)  | 📝   | 會計科目     |
| date_created          | 建立時間      | TIMESTAMP    | 🔄   |              |
| date_updated          | 更新時間      | TIMESTAMP    | 🔄   |              |

**索引**:

- `idx_tech_doc_eswbs` - ESWBS碼索引

---

### 10. Item_Document_xref (品項文件關聯檔)

**用途**: 品項-技術文件多對多關聯
**V3.0 變更**: 從 Equipment_Document_xref 改為 Item_Document_xref

| 英文欄位名  | 中文名稱 | 資料類型  | 標記   | 說明                         |
| ----------- | -------- | --------- | ------ | ---------------------------- |
| item_uuid   | 品項UUID | UUID      | 🔑🔗⭐ | 外鍵連結至 Item              |
| document_id | 文件ID   | INT       | 🔑🔗⭐ | 外鍵連結至 TechnicalDocument |
| date_created  | 建立時間 | TIMESTAMP | 🔄     |                              |
| date_updated  | 更新時間 | TIMESTAMP | 🔄     |                              |

**複合主鍵**: (item_uuid, document_id)

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)
- `document_id` → `TechnicalDocument.document_id` (ON DELETE CASCADE)

---

### 11. ApplicationFormDetail (申編單明細檔)

**用途**: 申編單明細資料

| 英文欄位名      | 中文名稱   | 資料類型     | 標記 | 說明                       |
| --------------- | ---------- | ------------ | ---- | -------------------------- |
| detail_id       | 明細ID     | SERIAL       | 🔑🔄 | 自動編號                   |
| form_id         | 表單ID     | INT          | 🔗⭐ | 外鍵連結至 ApplicationForm |
| line_number     | 項次       | INT          | 📝   | 明細序號                   |
| document_source | 文件來源   | VARCHAR(100) | 📝   | 資料來源文件               |
| attachment_path | 圖片路徑   | VARCHAR(500) | 📝   | 附件路徑                   |
| date_created      | 建立時間   | TIMESTAMP    | 🔄   |                            |
| date_updated      | 更新時間   | TIMESTAMP    | 🔄   |                            |

**外鍵關聯**:

- `form_id` → `ApplicationForm.form_id` (ON DELETE CASCADE)

**索引**:

- `idx_app_detail_form` - 表單ID索引

---

### 12. ApplicationForm (申編單檔)

**用途**: 管理申編單資料

| 英文欄位名                | 中文名稱         | 資料類型    | 標記   | 說明             |
| ------------------------- | ---------------- | ----------- | ------ | ---------------- |
| form_id                   | 表單ID           | SERIAL      | 🔑🔄   | 自動編號         |
| form_no                   | 表單編號         | VARCHAR(50) | UNIQUE | 申編單號         |
| submission_state          | 提送狀態         | VARCHAR(20) | 📝     | 待送/已送/核准等 |
| yetl                      | YETL             | VARCHAR(20) | 📝     | 專案代號         |
| applicant_accounting_code | 申請單位會計編號 | VARCHAR(20) | 📝     | 申請單位         |
| item_id                   | 品項識別碼       | UUID        | 🔗     | 外鍵連結至 Item  |
| created_date              | 建立日期         | DATE        | 🔄     | 表單建立日       |
| updated_date              | 更新日期         | DATE        | 🔄     | 表單更新日       |

**外鍵關聯**:

- `item_id` → `Item.item_uuid` (ON DELETE SET NULL)

**索引**:

- `idx_app_form_no` - 表單編號索引
- `idx_app_form_item` - 品項ID索引

---

### 13. SupplierCodeApplication (廠商代號申請表)

**用途**: 廠商代號申請表單
**V3.1 新增**: 支援動態欄位 (JSONB)

| 英文欄位名       | 中文名稱   | 資料類型     | 標記   | 說明                       |
| ---------------- | ---------- | ------------ | ------ | -------------------------- |
| application_uuid | 申請單UUID | UUID         | 🔑🔄   | 自動生成 UUID              |
| form_no          | 流水號     | VARCHAR(50)  | UNIQUE | 申請單流水號               |
| applicant        | 申請人     | VARCHAR(50)  | 📝     | 申請人姓名                 |
| supplier_id      | 廠商ID     | INT          | 🔗     | 外鍵連結至 Supplier (可選) |
| supplier_name    | 廠商名稱   | VARCHAR(200) | 📝     | 廠商名稱                   |
| address          | 地址       | VARCHAR(200) | 📝     | 廠商地址                   |
| phone            | 電話       | VARCHAR(50)  | 📝     | 聯絡電話                   |
| business_items   | 營業項目   | VARCHAR(200) | 📝     | 營業項目說明               |
| supplier_code    | 廠家代號   | VARCHAR(20)  | 📝     | 申請或現有代號             |
| equipment_name   | 裝備名稱   | VARCHAR(200) | 📝     | 相關裝備名稱               |
| custom_fields    | 自定義欄位 | JSONB        | 📝     | 動態擴充欄位               |
| state            | 狀態       | VARCHAR(20)  | 📝     | Draft/Submitted等          |
| date_created       | 建立時間   | TIMESTAMP    | 🔄     |                            |
| date_updated       | 更新時間   | TIMESTAMP    | 🔄     |                            |

**外鍵關聯**:

- `supplier_id` → `Supplier.supplier_id` (ON DELETE SET NULL)

**索引**:

- `idx_supplier_app_form_no` - 流水號索引
- `idx_supplier_app_supplier` - 廠商ID索引

---

### 14. CIDApplication (CID申請單)

**用途**: CID 申請表單

| 英文欄位名        | 中文名稱     | 資料類型     | 標記   | 說明                   |
| ----------------- | ------------ | ------------ | ------ | ---------------------- |
| application_uuid  | 申請單UUID   | UUID         | 🔑🔄   | 自動生成 UUID          |
| form_no           | 流水號       | VARCHAR(50)  | UNIQUE | 申請單流水號           |
| applicant         | 申請人       | VARCHAR(50)  | 📝     | 申請人姓名             |
| item_uuid         | 品項UUID     | UUID         | 🔗     | 外鍵連結至 Item (可選) |
| suggested_prefix  | 建議前兩碼   | VARCHAR(2)   | 📝     | 建議CID前綴            |
| approved_cid      | 核定CID      | VARCHAR(50)  | 📝     | 核定後的CID            |
| equipment_name_zh | 裝備中文名稱 | VARCHAR(100) | 📝     | 中文名稱               |
| equipment_name_en | 裝備英文名稱 | VARCHAR(200) | 📝     | 英文名稱               |
| supplier_code     | 廠家代號     | VARCHAR(20)  | 📝     | 相關廠商代號           |
| part_number       | 配件號碼     | VARCHAR(50)  | 📝     | P/N                    |
| state             | 狀態         | VARCHAR(20)  | 📝     | Draft/Submitted等      |
| date_created        | 建立時間     | TIMESTAMP    | 🔄     |                        |
| date_updated        | 更新時間     | TIMESTAMP    | 🔄     |                        |

**外鍵關聯**:

- `item_uuid` → `Item.item_uuid` (ON DELETE SET NULL)

**索引**:

- `idx_cid_app_form_no` - 流水號索引
- `idx_cid_app_item` - 品項UUID索引

---

## 📊 資料表關聯圖 (V3.0)

```
                    ┌─────────────────────────────┐
                    │                             │
                    │      SUPPLIER (廠商)        │
                    │                             │
                    └─────────────────────────────┘
                                  │
                                  │ 1:N
                                  ↓
                         Item_Supplier_xref
                                  │
                                  │ N:1
                                  ↓
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │                 ITEM (品項主檔) ⭐                  │
    │              UUID 主鍵，核心表                      │
    │         FG(成品) / SEMI(半成品) / RM(原料)          │
    │                                                     │
    └─────────────────────────────────────────────────────┘
         │           │           │           │           │
         │ 1:1       │ 1:1       │ 1:N       │ 1:N       │ N:M
         ↓           ↓           ↓           ↓           ↓
    Item_Equip  Item_Material   BOM        MRC    Item_Document_xref
      _Ext         _Ext          │                       │
                                 │ 1:N                   │ N:M
                                 ↓                       ↓
                            BOM_LINE            TechnicalDocument
                                 │
                                 │ N:1 (自我關聯)
                                 ↓
                              ITEM
```

### BOM 自我關聯說明

#### 基本概念

在 V3.0 架構中，**同一個 Item 可以同時扮演兩個角色**：
- **父項（爸爸）**：有自己的 BOM，包含其他子項
- **子項（兒子）**：出現在其他 Item 的 BOM 中

這就是「Item 自己對自己多對多」的設計，透過 BOM + BOM_LINE 實現。

#### 電笛系統範例（測試資料）

```
電笛系統 (FG)
  └── BOM v1.0
        └── BOM_LINE → 電笛系統主機 (SEMI) ⭐ 既是兒子也是爸爸
                          └── BOM v1.0
                                ├── BOM_LINE → 電笛喇叭 x2 (RM)
                                ├── BOM_LINE → 電笛控制面板 (RM)
                                ├── BOM_LINE → 擴大機模組 (RM)
                                └── BOM_LINE → 電源供應器 (RM)
```

#### 實際案例：往復式泵組（當前資料）

從資料庫實際資料可見，**往復式泵組 (4320YETL)** 完美展示了這個概念：

##### 1️⃣ 往復式泵組當「兒子」
它是逆滲透淡水製造機的子項：
```sql
-- 查詢結果
SELECT parent_i.item_name_zh, bl.qty_per
FROM "BOM_line" bl
JOIN "BOM" b ON bl.bom_uuid = b.bom_uuid
JOIN "ITEM" parent_i ON b.item_uuid = parent_i.item_uuid
WHERE bl.component_item_uuid = (
    SELECT item_uuid FROM "ITEM" WHERE item_code = '4320YETL'
);

-- 結果
      parent      |  qty
------------------+--------
 逆滲透淡水製造機 | 1.0000
 逆滲透淡水製造機 | 2.0000
```

##### 2️⃣ 往復式泵組當「爸爸」
它也有自己的 BOM，包含更小的零組件：
```sql
-- 查詢結果
SELECT bl.line_no, child_i.item_name_zh, bl.qty_per
FROM "BOM" b
JOIN "BOM_line" bl ON b.bom_uuid = bl.bom_uuid
JOIN "ITEM" child_i ON bl.component_item_uuid = child_i.item_uuid
WHERE b.item_uuid = (
    SELECT item_uuid FROM "ITEM" WHERE item_code = '4320YETL'
)
ORDER BY bl.line_no;

-- 結果
line_no |   child    | qty_per
---------+------------+---------
       1 | 交流電動機 |  1.0000
       2 | 電源供應器 |  1.0000
       3 | 按鈕開關   |  2.0000
```

##### 完整階層結構
```
逆滲透淡水製造機 (4610YETL) [FG]
  ├─ 往復式泵組 (4320YETL) [FG] ⭐ 關鍵角色
  │    ├─ 交流電動機 (6105YETL) [FG]
  │    ├─ 電源供應器 (6120YETL) [FG]
  │    └─ 按鈕開關 (5930YETL) [FG] x2
  ├─ 電磁繼電器 (5945YETL) [FG]
  ├─ 端子箱 (5940YETL) [FG]
  └─ 蜂鳴器 (6350YETL) [FG]
```

---

### 如何插入 BOM 自我參照資料

#### 步驟 1：建立所有 Item

```sql
-- 頂層裝備（滅火系統）
INSERT INTO "ITEM" (item_uuid, item_code, item_name_zh, item_type, uom)
VALUES (
    '11111111-0000-0000-0000-000000000001',
    'FIRE-SYS-001',
    '滅火系統',
    'FG',
    'SET'
);

-- 中間裝備（引擎）⭐ 既是兒子也是爸爸
INSERT INTO "ITEM" (item_uuid, item_code, item_name_zh, item_type, uom)
VALUES (
    '22222222-0000-0000-0000-000000000002',
    'ENGINE-001',
    '引擎',
    'SEMI',
    'EA'
);

-- 底層零件（活塞、汽缸、曲軸）
INSERT INTO "ITEM" (item_uuid, item_code, item_name_zh, item_type, uom)
VALUES
    ('33333333-0000-0000-0000-000000000003', 'PISTON-001', '活塞', 'RM', 'EA'),
    ('44444444-0000-0000-0000-000000000004', 'CYLINDER-001', '汽缸', 'RM', 'EA'),
    ('55555555-0000-0000-0000-000000000005', 'CRANKSHAFT-001', '曲軸', 'RM', 'EA');
```

#### 步驟 2：建立 BOM（版本控制）

```sql
-- 滅火系統的 BOM
INSERT INTO "BOM" (bom_uuid, item_uuid, bom_code, revision, state)
VALUES (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',  -- 滅火系統 UUID
    'BOM-FIRE-SYS-V1',
    '1.0',
    'Released'
);

-- 引擎的 BOM ⭐ 關鍵：中間層也有自己的 BOM
INSERT INTO "BOM" (bom_uuid, item_uuid, bom_code, revision, state)
VALUES (
    'bbbbbbbb-0000-0000-0000-000000000002',
    '22222222-0000-0000-0000-000000000002',  -- 引擎 UUID
    'BOM-ENGINE-V1',
    '1.0',
    'Released'
);
```

#### 步驟 3：建立 BOM_LINE（父子關係）

```sql
-- ========== 第一層關係：滅火系統 → 引擎 ==========
-- 引擎在這裡是「兒子」
INSERT INTO "BOM_line" (line_uuid, bom_uuid, line_no, component_item_uuid, qty_per, uom)
VALUES (
    'cccccccc-0000-0000-0000-000000000001',
    'aaaaaaaa-0000-0000-0000-000000000001',  -- 滅火系統的 BOM
    1,
    '22222222-0000-0000-0000-000000000002',  -- 引擎 UUID ⬅️ 引擎是子項
    1.0000,
    'EA'
);

-- ========== 第二層關係：引擎 → 零組件 ==========
-- 引擎在這裡是「爸爸」
INSERT INTO "BOM_line" (line_uuid, bom_uuid, line_no, component_item_uuid, qty_per, uom)
VALUES
    -- 引擎 → 活塞
    ('dddddddd-0000-0000-0000-000000000002',
     'bbbbbbbb-0000-0000-0000-000000000002',  -- 引擎的 BOM ⬅️ 引擎當爸爸
     1,
     '33333333-0000-0000-0000-000000000003',  -- 活塞 UUID
     6.0000,
     'EA'),
    -- 引擎 → 汽缸
    ('eeeeeeee-0000-0000-0000-000000000003',
     'bbbbbbbb-0000-0000-0000-000000000002',
     2,
     '44444444-0000-0000-0000-000000000004',  -- 汽缸 UUID
     6.0000,
     'EA'),
    -- 引擎 → 曲軸
    ('ffffffff-0000-0000-0000-000000000004',
     'bbbbbbbb-0000-0000-0000-000000000002',
     3,
     '55555555-0000-0000-0000-000000000005',  -- 曲軸 UUID
     1.0000,
     'EA');
```

---

### 如何查詢父子關係

#### 查詢 1：找出某個 Item 當「兒子」時的父項

```sql
-- 引擎的父項是誰？
SELECT
    parent_i.item_name_zh AS parent_item,
    parent_i.item_code,
    bl.qty_per
FROM "BOM_line" bl
JOIN "BOM" b ON bl.bom_uuid = b.bom_uuid
JOIN "ITEM" parent_i ON b.item_uuid = parent_i.item_uuid
WHERE bl.component_item_uuid = (
    SELECT item_uuid FROM "ITEM" WHERE item_code = 'ENGINE-001'
);
```

#### 查詢 2：找出某個 Item 當「爸爸」時的子項

```sql
-- 引擎包含哪些子項？
SELECT
    bl.line_no,
    child_i.item_name_zh AS child_item,
    child_i.item_code,
    bl.qty_per
FROM "BOM" b
JOIN "BOM_line" bl ON b.bom_uuid = bl.bom_uuid
JOIN "ITEM" child_i ON bl.component_item_uuid = child_i.item_uuid
WHERE b.item_uuid = (
    SELECT item_uuid FROM "ITEM" WHERE item_code = 'ENGINE-001'
)
ORDER BY bl.line_no;
```

#### 查詢 3：完整多層 BOM 展開（遞迴查詢）

```sql
-- 從頂層展開完整的 BOM 階層結構
WITH RECURSIVE bom_tree AS (
    -- 起始層：頂層裝備
    SELECT
        i.item_uuid,
        i.item_code,
        i.item_name_zh,
        i.item_type,
        CAST(NULL AS DECIMAL(10,4)) AS qty_per,
        1 AS level,
        i.item_name_zh AS path
    FROM "ITEM" i
    WHERE i.item_code = 'FIRE-SYS-001'

    UNION ALL

    -- 遞迴部分：找子項
    SELECT
        child.item_uuid,
        child.item_code,
        child.item_name_zh,
        child.item_type,
        bl.qty_per,
        parent.level + 1,
        parent.path || ' → ' || child.item_name_zh
    FROM bom_tree parent
    JOIN "BOM" b ON parent.item_uuid = b.item_uuid
    JOIN "BOM_line" bl ON b.bom_uuid = bl.bom_uuid
    JOIN "ITEM" child ON bl.component_item_uuid = child.item_uuid
    WHERE parent.level < 10  -- 防止無限遞迴
)
SELECT
    level,
    REPEAT('  ', level - 1) || item_name_zh AS hierarchy,
    item_code,
    item_type,
    COALESCE(qty_per::TEXT, '-') AS qty
FROM bom_tree
ORDER BY path, level;
```

---

### 資料庫表結構關係

```
ITEM 表
┌─────────────┐
│ item_uuid   │ ← 主鍵
│ item_code   │
│ item_name_zh│
│ item_type   │
└─────────────┘
      ↑ ↓
      │ │ 自我參照透過 BOM + BOM_LINE
      │ │
      ↓ ↑
┌─────────────┐       ┌──────────────────┐
│ BOM         │       │ BOM_LINE         │
├─────────────┤  1:N  ├──────────────────┤
│ bom_uuid    │◄──────┤ bom_uuid         │
│ item_uuid   │───┐   │ component_item_uuid│─┐
└─────────────┘   │   └──────────────────┘  │
                  │                          │
                  └──────────────────────────┘
                    兩個 FK 都指向 ITEM.item_uuid
```

### 💡 關鍵理解

1. **BOM.item_uuid**：這個 Item 是「爸爸」（父項）
2. **BOM_LINE.component_item_uuid**：這個 Item 是「兒子」（子項）
3. **同一個 Item** 可以同時出現在：
   - 某個 BOM 的 `item_uuid`（當爸爸）
   - 某個 BOM_LINE 的 `component_item_uuid`（當兒子）

這就是「自己對自己多對多」的實現方式！

---

## 🔑 主鍵類型說明

### UUID 主鍵

| 資料表   | 主鍵欄位  | 說明     |
| -------- | --------- | -------- |
| Item     | item_uuid | 品項UUID |
| BOM      | bom_uuid  | BOM UUID |
| BOM_LINE | line_uuid | 行UUID   |
| MRC      | mrc_uuid  | MRC UUID |

### 自動編號主鍵 (SERIAL)

| 資料表                  | 主鍵欄位         | 說明       |
| ----------------------- | ---------------- | ---------- |
| Supplier                | supplier_id      | 廠商ID     |
| Item_Supplier_xref      | part_number_id   | 零件號碼ID |
| TechnicalDocument       | document_id      | 文件ID     |
| ApplicationFormDetail   | detail_id        | 明細ID     |
| ApplicationForm         | form_id          | 表單ID     |
| SupplierCodeApplication | application_uuid | 申請單UUID |
| CIDApplication          | application_uuid | 申請單UUID |

### 複合主鍵

| 資料表             | 主鍵欄位                 | 說明          |
| ------------------ | ------------------------ | ------------- |
| Item_Equipment_Ext | item_uuid                | 品項UUID (FK) |
| Item_Material_Ext  | item_uuid                | 品項UUID (FK) |
| Item_Document_xref | (item_uuid, document_id) | 品項-文件組合 |

---

## ⚙️ 自動觸發器

所有包含 `date_updated` 欄位的資料表都設有自動更新觸發器：

**觸發器清單** (V3.1 共 13 個):

1. update_supplier_date_updated (Supplier表)
2. update_item_date_updated (Item表)
3. update_item_equip_ext_date_updated (Item_Equipment_Ext表)
4. update_item_material_ext_date_updated (Item_Material_Ext表)
5. update_bom_date_updated (BOM表)
6. update_bom_line_date_updated (BOM_LINE表)
7. update_mrc_date_updated (MRC表)
8. update_item_supplier_date_updated (Item_Supplier_xref表)
9. update_item_document_date_updated (Item_Document_xref表)
10. update_technical_document_date_updated (TechnicalDocument表)
11. update_app_form_detail_date_updated (ApplicationFormDetail表)
12. update_supplier_app_date_updated (SupplierCodeApplication表)
13. update_cid_app_date_updated (CIDApplication表)

---

## 📝 常用代號說明

### 品項類型

- **FG**: Finished Goods (成品/裝備)
- **SEMI**: Semi-finished (半成品)
- **RM**: Raw Material (原物料)

### 裝備相關

- **CID**: Configuration Item ID (單機識別碼)
- **ESWBS**: Enhanced Ship Work Breakdown Structure (艦艇工作分解結構碼)

### 品項相關

- **NSN**: NATO Stock Number (北約料號)
- **NIIN**: National Item Identification Number (國家品項識別號)
- **FIIG**: Federal Item Identification Guide (聯邦品項識別指南)
- **P/N**: Part Number (零件號碼)
- **CAGE CODE**: Commercial And Government Entity Code (商業及政府實體代碼)

---

## 📊 資料庫演進總結

### V2.x：以 Equipment 為中心

- Equipment + Item 分離
- BOM_xref 連接 Equipment-Item

### V3.0：Item 自我關聯 BOM 結構 ⭐ 最新版本

- Equipment 合併到 Item（使用 item_type 區分）
- 擴展表設計（Item_Equipment_Ext, Item_Material_Ext）
- BOM + BOM_LINE 支援多層級結構和版本控制
- MRC 取代 ItemSpecification
- UUID 主鍵設計

### 效能與擴展性

- ✅ 支援多層級 BOM 結構
- ✅ BOM 版本控制（歷史追溯）
- ✅ 擴展表減少 NULL 欄位
- ✅ UUID 主鍵防止 ID 猜測
- ✅ 適合大量資料擴展

---

## 📊 資料庫現況統計

### 資料表資料量統計

**統計時間**: 2025-11-20

| 資料表 | 記錄數 | 說明 |
|--------|--------|------|
| **主表** | | |
| Supplier | 4 | 供應商資料 |
| Item | 24 | 品項資料（合併電笛系統+申編單+廚房滅火系統） |
| Item_Equipment_Ext | 13 | 裝備延伸資料（FG類型） |
| Item_Material_Ext | 10 | 物料延伸資料（RM類型） |
| **BOM結構** | | |
| BOM | 5 | BOM版本（電笛系統） |
| BOM_LINE | 7 | BOM明細行 |
| MRC | 75 | 規格資料 |
| **關聯表** | | |
| Item_Supplier_xref | 1 | 料號交叉參照 |
| **輔助資料** | | |
| TechnicalDocument | 0 | 技術文件 |
| Item_Document_xref | 0 | 品項文件關聯 |
| ApplicationForm | 22 | 申編單（來自export.jsonl） |
| ApplicationFormDetail | 0 | 申編單明細 |
| SupplierCodeApplication | 0 | 廠商代號申請 |
| CIDApplication | 0 | CID申請單 |

**總計**: 161 筆資料記錄

---

### 已匯入資料來源

#### 1. 電笛系統測試資料
**來源**: `Database/scripts/insert_電笛_data_v2.sql`
**數量**:
- 5 個 Item（電笛系統、主機、喇叭、面板、擴大機、電源）
- 2 個 BOM 版本（系統 v1.0、主機 v1.0）
- 7 個 BOM_LINE（主機1個+元件4個x2）
- 1 個 Supplier（聯邦信號公司）

**特色**: 展示多層級 BOM 結構

#### 2. 料號申編單資料
**來源**: `Database/export/export.jsonl`（27筆記錄）
**匯入腳本**: `import_application_data.py`
**數量**:
- 15 個 Item（往復式泵組及相關零件）
- 22 個 ApplicationForm
- 75 個 MRC（每個Item約5筆規格）
- 13 個 Item_Equipment_Ext
- 3 個 Supplier（德相貿易、DESMI、聯邦信號）

**包含設備**:
- 4610YETL - 逆滲透淡水製造機（2個申編單）
- 4320YETL - 往復式泵組（3個申編單）
- 1650YETL - 外殼（3個申編單）
- 其他泵浦相關零件

#### 3. 廚房滅火系統資料
**來源**: `1017-SBIR內部會議/總表-範例/廚房滅火系統ILS及APL_版4.1.xlsx`
**匯入腳本**: `import_excel_data.py`
**數量**:
- 9 個新 Item（重複1個）
- 9 個 Item_Material_Ext（含單價資訊）
- 1 個 Supplier

**包含設備** (部分):
- 1369YETL - 廚房用油鍋滅火系統 ($15,000)
- 1544YETL - 噴嘴 2W ($250)
- 1440YETL - 低pH濕式化學藥劑 ($200)
- 1597YETL - 熱融片剪式聯動夾 ($300)
- 1678YETL - 遠端手動釋放站 ($450)

---

### 資料特徵分析

#### Item 分布

| item_type | 數量 | 百分比 | 說明 |
|-----------|------|--------|------|
| FG | 14 | 58.3% | 成品/裝備 |
| SEMI | 1 | 4.2% | 半成品 |
| RM | 9 | 37.5% | 原物料/零件 |
| **總計** | **24** | **100%** | |

#### 供應商分布

| CAGE碼 | 供應商名稱 | Item數量 |
|--------|-----------|---------|
| 2H845 | 聯邦信號公司 | 1 |
| B48811 | 德相貿易股份有限公司 | 1 |
| U3006 | DESMI Pumping Technology A/S | 1 |
| 3670 | (廚房滅火系統供應商) | 1 |

#### 資料完整度

| 項目 | 有資料 | 無資料 | 完整度 |
|------|--------|--------|--------|
| Item 中文名 | 22 | 2 | 91.7% |
| Item 英文名 | 24 | 0 | 100% |
| NSN | 0 | 24 | 0% |
| 單價資訊 | 9 | 15 | 37.5% |
| MRC 規格 | 15 | 9 | 62.5% |

---

### 資料品質指標

#### ✅ 良好
- Item 主表完整（100% 有英文名）
- MRC 規格豐富（75筆）
- BOM 結構完整（展示多層級）
- 外鍵關聯正確

#### ⚠️ 待改善
- NSN 欄位全部為空（0%）
- 單價資訊不完整（37.5%）
- 技術文件未匯入（0筆）
- Item_Supplier_xref 資料稀少（1筆）

#### 📋 建議
1. 補充 NSN 資料（從 ILS 總表）
2. 匯入更多 Excel 工作表資料
3. 建立技術文件與品項關聯
4. 補充料號交叉參照資料

---

### 匯入歷史記錄

| 日期 | 操作 | 數據源 | 結果 |
|------|------|--------|------|
| 2025-11-19 | 建立測試資料 | insert_電笛_data_v2.sql | ✅ 5 Items, 2 BOMs |
| 2025-11-20 | 匯入申編單 | export.jsonl | ✅ 27 records (15 Items) |
| 2025-11-20 | 匯入ILS總表 | 廚房滅火系統.xlsx | ✅ 10 records (9 Items) |

---

**文件版本**: 3.2.0
**最後更新**: 2025-11-20
**V3.2.0 變更**: 優化所有欄位英文命名（status→state, remark→notes, position→installation_location/assembly_position, obtain_level→acquisition_difficulty, obtain_source→acquisition_channel, item_seq→line_number, image_path→attachment_path, submit_status→submission_state, extra_fields→custom_fields）
**維護單位**: SBIR 專案團隊
**資料表總數**: ✅ 14 個表（4主表 + 3 BOM結構 + 1關聯表 + 6輔助表）
**資料記錄數**: ✅ 161 筆（Item: 24, ApplicationForm: 22, MRC: 75）
