# SBIR 裝備資料庫中英文對照表 (V3.1)

## 📊 資料庫資訊

- **資料庫名稱**: sbir_equipment_db_v3
- **版本**: V3.1
- **用途**: 海軍裝備管理系統 + Web 應用整合
- **編碼**: UTF8
- **建立日期**: 2025-11-25
- **最後更新**: 2025-11-27
- **架構特點**:
  - Item 自我關聯 BOM 結構
  - UUID 主鍵
  - 擴展表設計
  - 整合 Web 應用使用者與申編單管理系統
  - 統一時間戳命名（date_created/date_updated）
- **總表數**: 18 個資料表

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
- [V3.1 整合變更說明](#v31-整合變更說明)
- [核心裝備管理表（12個）](#核心裝備管理表12個)
  - [Supplier - 廠商主檔](#1-supplier-廠商主檔)
  - [Item - 品項主檔](#2-item-品項主檔)
  - [Item_Equipment_Ext - 裝備擴展表](#3-item_equipment_ext-裝備擴展表)
  - [Item_Material_Ext - 料件擴展表](#4-item_material_ext-料件擴展表)
  - [BOM - BOM主表](#5-bom-bom主表)
  - [BOM_LINE - BOM明細行](#6-bom_line-bom明細行)
  - [MRC - 品項規格表](#7-mrc-品項規格表)
  - [item_number_xref - 零件號碼關聯檔](#8-item_number_xref-零件號碼關聯檔)
  - [TechnicalDocument - 技術文件檔](#9-technicaldocument-技術文件檔)
  - [Item_Document_xref - 品項文件關聯檔](#10-item_document_xref-品項文件關聯檔)
  - [SupplierCodeApplication - 廠商代號申請表](#11-suppliercodeapplication-廠商代號申請表)
  - [CIDApplication - CID申請單](#12-cidapplication-cid申請單)
- [Web 應用表（6個）](#web-應用表6個)
  - [User - 使用者管理](#13-user-使用者管理)
  - [Application - 申編單主表](#14-application-申編單主表)
  - [ApplicationAttachment - 附件管理](#15-applicationattachment-附件管理)
  - [UserSession - 工作階段管理](#16-usersession-工作階段管理)
  - [ApplicationLog - 應用程式日誌](#17-applicationlog-應用程式日誌)
  - [AuditLog - 稽核日誌](#18-auditlog-稽核日誌)
- [資料表關聯圖](#資料表關聯圖)
- [時間戳命名策略](#時間戳命名策略)

---

## 資料表總覽

| 編號 | 英文表名 | 中文名稱 | 主鍵類型 | 時間戳命名 | 用途 |
|------|---------|---------|---------|-----------|------|
| **核心裝備管理表（12個）** | | | | | |
| 1 | Supplier | 廠商主檔 | SERIAL | date_created | 供應商/製造商基本資料 |
| 2 | Item | 品項主檔 ⭐ | UUID | date_created | 統一品項資料（核心表） |
| 3 | Item_Equipment_Ext | 裝備擴展表 | UUID (FK) | date_created | 裝備類型專用欄位 |
| 4 | Item_Material_Ext | 料件擴展表 | UUID (FK) | date_created | 料件類型專用欄位 |
| 5 | BOM | BOM主表 | UUID | date_created | BOM版本控制 |
| 6 | BOM_LINE | BOM明細行 ⭐ | UUID | date_created | Item自我關聯（元件清單） |
| 7 | MRC | 品項規格表 | UUID | date_created | 品項規格資料 |
| 8 | item_number_xref | 零件號碼關聯檔 | SERIAL | date_created | 品項-零件號-廠商多對多關聯 |
| 9 | TechnicalDocument | 技術文件檔 | SERIAL | date_created | 技術文件/手冊主檔 |
| 10 | Item_Document_xref | 品項文件關聯檔 | 複合鍵 | date_created | 品項-技術文件多對多關聯 |
| 11 | SupplierCodeApplication | 廠商代號申請表 | UUID | date_created | 廠商代號申請 |
| 12 | CIDApplication | CID申請單 | UUID | date_created | CID申請 |
| **Web 應用表（6個）** ⭐ | | | | | |
| 13 | User | 使用者管理 | UUID | date_created | 系統使用者帳號管理 |
| 14 | Application | 申編單主表 | UUID | date_created | 申編單完整資料（取代ApplicationForm） |
| 15 | ApplicationAttachment | 附件管理 | UUID | date_created | 申編單附件（BYTEA儲存） |
| 16 | UserSession | 工作階段管理 | VARCHAR | date_created | 使用者登入Session |
| 17 | ApplicationLog | 應用程式日誌 | UUID | timestamp | 應用程式運行日誌 |
| 18 | AuditLog | 稽核日誌 | UUID | date_created | 操作審計追蹤 |

**總計**: 18 個資料表（12 核心 + 6 Web）

---

## V3.1 整合變更說明

### 🔄 主要變更

#### 1. ✅ 整合 Web 應用系統（新增 6 個表）

**理由**:
- 提供完整的使用者管理系統
- 詳細的申編單管理（50+ 欄位 vs 原本 7 欄位）
- 附件管理（BYTEA 儲存）
- 完整的審計追蹤

**影響**:
- 新增 User 表（使用者管理）
- Application 表取代舊的 ApplicationForm
- 新增 ApplicationAttachment（附件管理）
- 新增 UserSession（工作階段管理）
- 新增 ApplicationLog（應用程式日誌）
- 新增 AuditLog（稽核日誌）

#### 2. ✅ 統一時間戳命名

**理由**:
- 所有表統一使用 date_created/date_updated 命名
- 保持資料庫命名一致性
- 簡化觸發器函數邏輯

**影響**:
- Web 應用表改用 date_created/date_updated
- 統一的觸發器函數
- 整個資料庫使用相同的時間戳命名規範

#### 3. ✅ Application 與 Item 表關聯

**理由**:
- 申編單需要關聯到具體的品項
- 支援申編單的完整生命週期管理

**影響**:
- Application 表新增 item_uuid 欄位
- 外鍵關聯到 Item 表

---

## 核心裝備管理表（12個）

### 1. Supplier（廠商主檔）

**用途**: 管理供應商/製造商基本資料
**來源**: 19M, 20M

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| supplier_id | 廠商ID | SERIAL | 🔑🔄 | 自動編號 |
| supplier_code | 廠商來源代號 | VARCHAR(20) | UNIQUE | 廠商代碼 |
| cage_code | 廠家登記代號 | VARCHAR(20) | UNIQUE | CAGE CODE |
| supplier_name_en | 廠家製造商（英文） | VARCHAR(200) | ⭐ | 英文廠商名稱 |
| supplier_name_zh | 廠商中文名稱 | VARCHAR(100) | 📝 | 中文廠商名稱 |
| supplier_type | 廠商類型 | VARCHAR(20) | 📝 | 製造商/代理商 |
| country_code | 國家代碼 | VARCHAR(10) | 📝 | 國別代碼 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | 記錄建立時間 |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | 記錄更新時間 |

---

### 2. Item（品項主檔）⭐

**用途**: 統一管理所有品項（成品/半成品/原物料）
**V3.0 變更**: 合併 Equipment，使用 UUID 主鍵

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| item_uuid | 品項UUID | UUID | 🔑🔄 | 自動生成 UUID |
| item_code | 統一識別碼 | VARCHAR(50) | ⭐ UNIQUE | CID 或 NIIN |
| item_name_zh | 中文品名 | VARCHAR(100) | ⭐ | 品項中文名稱 |
| item_name_en | 英文品名 | VARCHAR(200) | ⭐ | 品項英文名稱 |
| item_type | 品項類型 | VARCHAR(10) | ⭐ | FG/SEMI/RM |
| uom | 基本計量單位 | VARCHAR(10) | 📝 | EA/SET/LOT等 |
| status | 狀態 | VARCHAR(20) | 📝 | Active/Inactive |
| date_created | 建立時間 | TIMESTAMP | 🔄 | 記錄建立時間 |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | 記錄更新時間 |

**約束**:
- `item_type IN ('FG', 'SEMI', 'RM')`
- `status IN ('Active', 'Inactive')`

**索引**:
- `idx_item_code` - 識別碼索引
- `idx_item_type` - 類型索引
- `idx_item_status` - 狀態索引

---

### 3. Item_Equipment_Ext（裝備擴展表）

**用途**: 裝備類型專用欄位（FG 類型）
**來源**: 原 Equipment 表

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| item_uuid | 品項UUID | UUID | 🔑🔗 | 外鍵連結至 Item |
| equipment_type | 裝備形式 | VARCHAR(50) | 📝 | 裝備型號/型式 |
| ship_type | 艦型 | VARCHAR(50) | 📝 | 適用艦型 |
| position | 裝設地點 | VARCHAR(100) | 📝 | 安裝位置 |
| parent_equipment_zh | 上層適用裝備中文名稱 | VARCHAR(100) | 📝 | 父裝備中文名 |
| parent_equipment_en | 上層適用裝備英文名稱 | VARCHAR(200) | 📝 | 父裝備英文名 |
| parent_cid | 上層CID | VARCHAR(50) | 📝 | 父裝備識別碼 |
| eswbs_code | 族群結構碼HSC | VARCHAR(20) | 📝 | ESWBS（五碼） |
| system_function_name | 系統功能名稱 | VARCHAR(200) | 📝 | 系統功能說明 |
| installation_qty | 同一類型數量 | INT | 📝 | 單艦裝置數量 |
| total_installation_qty | 全艦裝置數 | INT | 📝 | 全艦總數 |
| maintenance_level | 裝備維修等級代碼 | VARCHAR(10) | 📝 | 維修等級 |
| equipment_serial | 裝備序號 | VARCHAR(50) | UNIQUE | 裝備識別編號 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

**外鍵關聯**:
- `item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

---

### 4. Item_Material_Ext（料件擴展表）

**用途**: 料件類型專用欄位（SEMI/RM 類型）
**來源**: 原 Item 表屬性欄位

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| item_uuid | 品項UUID | UUID | 🔑🔗 | 外鍵連結至 Item |
| item_id_last5 | 品項識別碼(後五碼) | VARCHAR(5) | 📝 | 快速識別用 |
| item_name_zh_short | 中文品名（9字內） | VARCHAR(20) | 📝 | 簡短中文名 |
| nsn | NSN/國家料號 | VARCHAR(20) | UNIQUE | NATO Stock Number |
| item_category | 統一組類別 | VARCHAR(10) | 📝 | 品項分類代碼 |
| item_code | 品名代號 | VARCHAR(10) | 📝 | INC品名代號 |
| fiig | FIIG | VARCHAR(10) | 📝 | 聯邦品項識別指南 |
| weapon_system_code | 武器系統代號 | VARCHAR(20) | 📝 | 所屬武器系統 |
| accounting_code | 會計編號 | VARCHAR(20) | 📝 | 會計科目代號 |
| issue_unit | 撥發單位 | VARCHAR(10) | 📝 | EA/SET/LOT等 |
| unit_price_usd | 美金單價 | DECIMAL(10,2) | 📝 | 單位價格（美金） |
| package_qty | 單位包裝量 | INT | 📝 | 包裝數量 |
| weight_kg | 重量(KG) | DECIMAL(10,3) | 📝 | 單位重量（公斤） |
| has_stock | 有無料號 | BOOLEAN | 📝 | 是否有庫存料號 |
| storage_life_code | 存儲壽限代號 | VARCHAR(10) | 📝 | 儲存期限代碼 |
| file_type_code | 檔別代號 | VARCHAR(10) | 📝 | 檔案類型代號 |
| file_type_category | 檔別區分 | VARCHAR(10) | 📝 | 檔案分類 |
| security_code | 機密性代號 | VARCHAR(10) | 📝 | 機密等級（U/C/S等） |
| consumable_code | 消耗性代號 | VARCHAR(10) | 📝 | 消耗品分類（M/N等） |
| spec_indicator | 規格指示 | VARCHAR(10) | 📝 | 規格指標 |
| navy_source | 海軍軍品來源 | VARCHAR(50) | 📝 | 來源說明 |
| storage_type | 儲存型式 | VARCHAR(20) | 📝 | 儲存方式 |
| life_process_code | 處理代號 (壽限處理) | VARCHAR(10) | 📝 | 壽限管理代號 |
| manufacturing_capacity | 製造能量 | VARCHAR(10) | 📝 | 製造能力 |
| repair_capacity | 修理能量 | VARCHAR(10) | 📝 | 修理能力 |
| source_code | 來源代號 | VARCHAR(10) | 📝 | 來源分類 |
| project_code | 專案代號 | VARCHAR(20) | 📝 | 所屬專案 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

### 5. BOM（BOM主表）

**用途**: BOM 版本控制
**V3.0 新增**: 支援版本管理和歷史追溯

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| bom_uuid | BOM UUID | UUID | 🔑🔄 | 自動生成 UUID |
| item_uuid | 成品料號 | UUID | 🔗⭐ | 外鍵連結至 Item |
| bom_code | BOM編號 | VARCHAR(50) | 📝 | BOM 識別碼 |
| revision | 版次 | VARCHAR(20) | 📝 | 版本號 (1.0, 1.1...) |
| effective_from | 生效日 | DATE | 📝 | 開始生效日期 |
| effective_to | 失效日 | DATE | 📝 | 結束生效日期 |
| status | 狀態 | VARCHAR(20) | 📝 | Released/Draft |
| remark | 備註 | TEXT | 📝 | 備註說明 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

### 6. BOM_LINE（BOM明細行）⭐

**用途**: BOM 元件清單（Item 自我關聯）
**V3.0 核心**: 實現多層級 BOM 結構

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| line_uuid | 行UUID | UUID | 🔑🔄 | 自動生成 UUID |
| bom_uuid | BOM UUID | UUID | 🔗⭐ | 外鍵連結至 BOM |
| line_no | 行號 | INT | ⭐ | 排序用 |
| component_item_uuid | 元件料號 | UUID | 🔗⭐ | 外鍵連結至 Item（元件） |
| qty_per | 單位用量 | DECIMAL(10,4) | ⭐ | 每單位成品需要數量 |
| scrap_type | 損耗型態 | VARCHAR(20) | 📝 | 損耗計算方式 |
| scrap_rate | 損耗率 | DECIMAL(5,4) | 📝 | 損耗百分比 |
| uom | 用量單位 | VARCHAR(10) | 📝 | 預設跟元件UOM一致 |
| position | 裝配位置 | VARCHAR(100) | 📝 | 裝配位置/站別 |
| remark | 備註 | TEXT | 📝 | 備註說明 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

**外鍵關聯**:
- `bom_uuid` → `BOM.bom_uuid` (ON DELETE CASCADE)
- `component_item_uuid` → `Item.item_uuid` (ON DELETE CASCADE)

---

### 7. MRC（品項規格表）

**用途**: 記錄品項的規格資料
**V3.0 變更**: 取代 ItemSpecification，使用 UUID 主鍵

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| mrc_uuid | MRC UUID | UUID | 🔑🔄 | 自動生成 UUID |
| item_uuid | 品項UUID | UUID | 🔗⭐ | 外鍵連結至 Item |
| spec_no | 規格順序 | INT | 📝 | 順序編號 |
| spec_abbr | 規格資料縮寫 | VARCHAR(20) | 📝 | 規格簡稱 |
| spec_en | 規格資料英文 | VARCHAR(200) | 📝 | 規格項目英文 |
| spec_zh | 規格資料翻譯 | VARCHAR(200) | 📝 | 規格項目中文 |
| answer_en | 英答 | VARCHAR(200) | 📝 | 規格值英文 |
| answer_zh | 中答 | VARCHAR(200) | 📝 | 規格值中文 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

### 8. item_number_xref（零件號碼關聯檔）

**用途**: 品項-零件號-廠商的多對多關聯
**來源**: 20M_料號主要件號檔
**表名**: 實際資料庫表名為 `item_number_xref`（小寫，底線分隔）

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| part_number_id | 零件號碼ID | SERIAL | 🔑🔄 | 自動編號 |
| part_number | 配件號碼 | VARCHAR(50) | ⭐ | P/N |
| item_uuid | 品項UUID | UUID | 🔗⭐ | 外鍵連結至 Item |
| supplier_id | 廠商ID | INT | 🔗 | 外鍵連結至 Supplier |
| obtain_level | 參考號獲得程度 | VARCHAR(10) | 📝 | 取得難易度 |
| obtain_source | 參考號獲得來源 | VARCHAR(50) | 📝 | 取得管道 |
| is_primary | 是否為主要零件號 | BOOLEAN | 📝 | 主/替代零件號 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

### 9. TechnicalDocument（技術文件檔）

**用途**: 管理技術文件與圖面資料

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| document_id | 文件ID | SERIAL | 🔑🔄 | 自動編號 |
| document_name | 圖名/書名 | VARCHAR(200) | ⭐ | 文件名稱 |
| document_version | 版次 | VARCHAR(20) | 📝 | 版本號 |
| shipyard_drawing_no | 船廠圖號 | VARCHAR(50) | 📝 | 船廠圖面編號 |
| design_drawing_no | 設計圖號 | VARCHAR(50) | 📝 | 設計圖面編號 |
| document_type | 資料類型 | VARCHAR(20) | 📝 | 文件類型 |
| document_category | 資料類別 | VARCHAR(20) | 📝 | 文件分類 |
| language | 語言 | VARCHAR(10) | 📝 | 中文/英文 |
| security_level | 機密等級 | VARCHAR(10) | 📝 | 機密分級 |
| eswbs_code | ESWBS（五碼） | VARCHAR(20) | 📝 | 裝備分類碼 |
| accounting_code | 會計編號 | VARCHAR(20) | 📝 | 會計科目 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

### 10. Item_Document_xref（品項文件關聯檔）

**用途**: 品項-技術文件多對多關聯
**V3.0 變更**: 從 Equipment_Document_xref 改為 Item_Document_xref

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| item_uuid | 品項UUID | UUID | 🔑🔗⭐ | 外鍵連結至 Item |
| document_id | 文件ID | INT | 🔑🔗⭐ | 外鍵連結至 TechnicalDocument |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

**複合主鍵**: (item_uuid, document_id)

---

### 11. SupplierCodeApplication（廠商代號申請表）

**用途**: 廠商代號申請表單
**V3.1 保留**: 與 Application 表用途不同，繼續保留

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| application_uuid | 申編單UUID | UUID | 🔑🔄 | 自動生成 UUID |
| form_no | 流水號 | VARCHAR(50) | UNIQUE | 申請單流水號 |
| applicant | 申請人 | VARCHAR(50) | 📝 | 申請人姓名 |
| supplier_id | 廠商ID | INT | 🔗 | 外鍵連結至 Supplier (可選) |
| supplier_name | 廠商名稱 | VARCHAR(200) | 📝 | 廠商名稱 |
| address | 地址 | VARCHAR(200) | 📝 | 廠商地址 |
| phone | 電話 | VARCHAR(50) | 📝 | 聯絡電話 |
| business_items | 營業項目 | VARCHAR(200) | 📝 | 營業項目說明 |
| supplier_code | 廠家代號 | VARCHAR(20) | 📝 | 申請或現有代號 |
| equipment_name | 裝備名稱 | VARCHAR(200) | 📝 | 相關裝備名稱 |
| custom_fields | 自定義欄位 | JSONB | 📝 | 動態擴充欄位 |
| status | 狀態 | VARCHAR(20) | 📝 | Draft/Submitted等 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

### 12. CIDApplication（CID申請單）

**用途**: CID 申請表單
**V3.1 保留**: 與 Application 表用途不同，繼續保留

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| application_uuid | 申編單UUID | UUID | 🔑🔄 | 自動生成 UUID |
| form_no | 流水號 | VARCHAR(50) | UNIQUE | 申請單流水號 |
| applicant | 申請人 | VARCHAR(50) | 📝 | 申請人姓名 |
| item_uuid | 品項UUID | UUID | 🔗 | 外鍵連結至 Item (可選) |
| suggested_prefix | 建議前兩碼 | VARCHAR(2) | 📝 | 建議CID前綴 |
| approved_cid | 核定CID | VARCHAR(50) | 📝 | 核定後的CID |
| equipment_name_zh | 裝備中文名稱 | VARCHAR(100) | 📝 | 中文名稱 |
| equipment_name_en | 裝備英文名稱 | VARCHAR(200) | 📝 | 英文名稱 |
| supplier_code | 廠家代號 | VARCHAR(20) | 📝 | 相關廠商代號 |
| part_number | 配件號碼 | VARCHAR(50) | 📝 | P/N |
| status | 狀態 | VARCHAR(20) | 📝 | Draft/Submitted等 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | |

---

## Web 應用表（6個）

### 13. User（使用者管理）⭐

**用途**: 系統使用者帳號管理
**V3.1 新增**: Web 應用核心表

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| id | 使用者UUID | UUID | 🔑🔄 | 自動生成 UUID |
| username | 使用者帳號 | VARCHAR(80) | ⭐ UNIQUE | 登入帳號 |
| email | 電子郵件 | VARCHAR(120) | ⭐ UNIQUE | 電子郵件地址 |
| password_hash | 密碼雜湊值 | VARCHAR(256) | ⭐ | 加密後的密碼 |
| english_code | 英文代碼 | VARCHAR(10) | 📝 | 英文代號 |
| full_name | 全名 | VARCHAR(100) | 📝 | 完整姓名 |
| department | 部門 | VARCHAR(100) | 📝 | 所屬部門 |
| position | 職位 | VARCHAR(100) | 📝 | 職稱 |
| phone | 電話 | VARCHAR(20) | 📝 | 聯絡電話 |
| role | 角色權限 | VARCHAR(50) | 📝 | admin/user/viewer等 |
| is_active | 帳號啟用狀態 | BOOLEAN | 📝 | 帳號是否啟用 |
| is_verified | 電子郵件驗證狀態 | BOOLEAN | 📝 | Email是否已驗證 |
| email_verified_at | 電子郵件驗證時間 | TIMESTAMP | 📝 | 驗證時間戳 |
| last_login_at | 最後登入時間 | TIMESTAMP | 📝 | 最後登入時間戳 |
| failed_login_attempts | 登入失敗次數 | INT | 📝 | 連續失敗次數 |
| locked_until | 帳號鎖定至 | TIMESTAMP | 📝 | 鎖定解除時間 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | 記錄建立時間 |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | 記錄更新時間 |

**索引**:
- `idx_user_email` - Email索引
- `idx_user_username` - 使用者名稱索引
- `idx_user_role` - 角色索引
- `idx_user_is_active` - 啟用狀態索引

---

### 14. Application（申編單主表）⭐

**用途**: 申編單完整資料（取代舊的 ApplicationForm）
**V3.1 新增**: 50+ 欄位的完整申編單管理

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| id | 申編單UUID | UUID | 🔑🔄 | 自動生成 UUID |
| user_id | 申請人 | UUID | 🔗 | 外鍵至User表 |
| item_uuid | 關聯品項UUID | UUID | 🔗 | 外鍵至Item表 ⭐ |
| form_serial_number | 表單序號 | VARCHAR(50) | 📝 | 申編單編號 |
| part_number | 料號 | VARCHAR(50) | 📝 | 零件料號 |
| english_name | 英文品名 | VARCHAR(255) | 📝 | 品項英文名稱 |
| chinese_name | 中文品名 | VARCHAR(255) | 📝 | 品項中文名稱 |
| inc_code | INC代碼 | VARCHAR(20) | 📝 | INC分類碼 |
| fiig_code | FIIG代碼 | VARCHAR(20) | 📝 | FIIG碼 |
| accounting_unit_code | 會計單位代碼 | VARCHAR(50) | 📝 | 會計科目 |
| issue_unit | 發放單位 | VARCHAR(10) | 📝 | 發放單位 |
| unit_price | 單價 | NUMERIC(10,2) | 📝 | 單位價格 |
| spec_indicator | 規格指示 | VARCHAR(10) | 📝 | 規格指標 |
| unit_pack_quantity | 單位包裝量 | VARCHAR(10) | 📝 | 包裝數量 |
| storage_life_months | 儲存壽命（月） | VARCHAR(10) | 📝 | 儲存期限 |
| storage_life_action_code | 儲存壽命處理代碼 | VARCHAR(10) | 📝 | 壽限處理 |
| storage_type_code | 儲存型式代碼 | VARCHAR(10) | 📝 | 儲存方式 |
| secrecy_code | 機密性代碼 | VARCHAR(10) | 📝 | 機密等級 |
| expendability_code | 消耗性代碼 | VARCHAR(10) | 📝 | 消耗品分類 |
| repairability_code | 修理能力代碼 | VARCHAR(10) | 📝 | 修理能力 |
| manufacturability_code | 製造能力代碼 | VARCHAR(10) | 📝 | 製造能力 |
| source_code | 來源代碼 | VARCHAR(10) | 📝 | 來源分類 |
| category_code | 類別代碼 | VARCHAR(10) | 📝 | 品項類別 |
| system_code | 系統代碼 | VARCHAR(100) | 📝 | 系統分類 |
| pn_acquisition_level | 零件號獲得程度 | VARCHAR(100) | 📝 | P/N取得難度 |
| pn_acquisition_source | 零件號獲得來源 | VARCHAR(100) | 📝 | P/N取得管道 |
| manufacturer | 製造商 | VARCHAR(255) | 📝 | 製造廠商 |
| part_number_reference | 參考零件號碼 | VARCHAR(255) | 📝 | 參考P/N |
| manufacturer_name | 製造商名稱 | VARCHAR(255) | 📝 | 廠商全名 |
| agent_name | 代理商名稱 | VARCHAR(100) | 📝 | 代理商 |
| ship_type | 艦型 | VARCHAR(100) | 📝 | 適用艦型 |
| cid_no | CID編號 | VARCHAR(100) | 📝 | CID碼 |
| model_type | 型式 | VARCHAR(255) | 📝 | 裝備型式 |
| equipment_name | 裝備名稱 | VARCHAR(255) | 📝 | 裝備名稱 |
| usage_location | 使用地點 | INT | 📝 | 使用位置 |
| quantity_per_unit | 單位數量 | JSON | 📝 | 數量（JSON格式） |
| mrc_data | MRC資料 | JSON | 📝 | 規格資料（JSON格式） |
| document_reference | 文件參考 | VARCHAR(255) | 📝 | 參考文件 |
| applicant_unit | 申請單位 | VARCHAR(100) | 📝 | 申請部門 |
| contact_info | 聯絡資訊 | VARCHAR(100) | 📝 | 聯絡方式 |
| apply_date | 申請日期 | DATE | 📝 | 申請日 |
| official_nsn_stamp | 正式NSN印章 | VARCHAR(10) | 📝 | NSN章戳 |
| official_nsn_final | 最終正式NSN | VARCHAR(20) | 📝 | 正式NSN號碼 |
| nsn_filled_at | NSN填寫時間 | TIMESTAMP | 📝 | NSN填寫時間戳 |
| nsn_filled_by | NSN填寫人 | UUID | 🔗 | 外鍵至User表 |
| status | 申編單狀態 | VARCHAR(50) | 📝 | 狀態（待審/已核准等） |
| sub_status | 申編單子狀態 | VARCHAR(50) | 📝 | 詳細狀態 |
| closed_at | 結案時間 | TIMESTAMP | 📝 | 結案時間戳 |
| closed_by | 結案人 | UUID | 🔗 | 外鍵至User表 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | 記錄建立時間 |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | 記錄更新時間 |
| deleted_at | 軟刪除時間戳 | TIMESTAMP | 📝 | 軟刪除標記 |

**外鍵關聯**:
- `user_id` → `User.id`
- `item_uuid` → `Item.item_uuid` (ON DELETE SET NULL) ⭐
- `nsn_filled_by` → `User.id`
- `closed_by` → `User.id`

**索引**:
- `idx_app_user_id` - 使用者索引
- `idx_app_item_uuid` - 品項索引 ⭐
- `idx_app_form_serial` - 表單序號索引
- `idx_app_status` - 狀態索引
- `idx_app_part_number` - 料號索引
- `idx_app_nsn` - NSN索引
- `idx_app_date_created` - 建立時間索引
- `idx_app_deleted_at` - 軟刪除索引（部分索引）

---

### 15. ApplicationAttachment（附件管理）

**用途**: 申編單附件（BYTEA儲存）
**V3.1 新增**: 支援二進制檔案儲存

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| id | 附件UUID | UUID | 🔑🔄 | 自動生成 UUID |
| application_id | 申編單ID | UUID | 🔗⭐ | 外鍵至Application表 |
| user_id | 上傳者 | UUID | 🔗 | 外鍵至User表 |
| file_data | 檔案二進制資料 | BYTEA | 📝 | 檔案內容（二進制） |
| filename | 儲存檔名 | VARCHAR(255) | 📝 | 系統儲存檔名 |
| original_filename | 原始檔名 | VARCHAR(255) | 📝 | 使用者上傳檔名 |
| mimetype | MIME類型 | VARCHAR(100) | 📝 | 檔案類型 |
| file_type | 檔案類型 | VARCHAR(20) | 📝 | PDF/PNG/JPG等 |
| page_selection | 頁面選擇 | VARCHAR(200) | 📝 | PDF多頁時選擇 |
| sort_order | 排序順序 | INT | 📝 | 附件排序 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | 上傳時間 |
| date_updated | 更新時間 | TIMESTAMP | 🔄 | 更新時間 |

**外鍵關聯**:
- `application_id` → `Application.id` (ON DELETE CASCADE)
- `user_id` → `User.id`

---

### 16. UserSession（工作階段管理）

**用途**: 使用者登入Session管理
**V3.1 新增**: 支援 remember_me 功能

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| session_id | Session ID | VARCHAR(255) | 🔑 | Session識別碼 |
| user_id | 使用者ID | UUID | 🔗⭐ | 外鍵至User表 |
| ip_address | IP位址 | VARCHAR(45) | 📝 | 登入IP |
| user_agent | 使用者代理字串 | TEXT | 📝 | 瀏覽器UA |
| is_active | 是否啟用 | BOOLEAN | 📝 | Session是否有效 |
| remember_me | 記住我功能 | BOOLEAN | 📝 | 是否記住登入 |
| expires_at | Session過期時間 | TIMESTAMP | 📝 | 過期時間戳 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | Session建立時間 |
| last_activity_at | 最後活動時間 | TIMESTAMP | 📝 | 最後活動時間戳 |

**外鍵關聯**:
- `user_id` → `User.id` (ON DELETE CASCADE)

---

### 17. ApplicationLog（應用程式日誌）

**用途**: 應用程式運行日誌
**V3.1 新增**: 支援完整的日誌記錄與除錯

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| log_id | 日誌UUID | UUID | 🔑🔄 | 自動生成 UUID |
| timestamp | 日誌時間戳 | TIMESTAMPTZ | 🔄 | 時間戳（含時區） |
| level | 日誌等級 | VARCHAR(10) | 📝 | DEBUG/INFO/WARNING/ERROR |
| logger | 日誌記錄器名稱 | VARCHAR(100) | 📝 | Logger名稱 |
| message | 日誌訊息 | TEXT | 📝 | 日誌內容 |
| request_id | 請求ID | VARCHAR(36) | 📝 | 請求追蹤ID |
| method | HTTP方法 | VARCHAR(10) | 📝 | GET/POST/PUT/DELETE等 |
| path | 請求路徑 | VARCHAR(500) | 📝 | API路徑 |
| status_code | HTTP狀態碼 | INT | 📝 | 200/404/500等 |
| elapsed_time_ms | 請求處理時間（毫秒） | NUMERIC(10,2) | 📝 | 執行時間 |
| user_id | 使用者ID | UUID | 📝 | 相關使用者 |
| remote_addr | 遠端IP位址 | INET | 📝 | 客戶端IP |
| user_agent | 使用者代理字串 | TEXT | 📝 | 瀏覽器UA |
| module | 模組名稱 | VARCHAR(100) | 📝 | Python模組 |
| function | 函數名稱 | VARCHAR(100) | 📝 | 函數名稱 |
| line | 行號 | INT | 📝 | 程式碼行號 |
| exception_type | 異常類型 | VARCHAR(100) | 📝 | Exception類別 |
| exception_message | 異常訊息 | TEXT | 📝 | 錯誤訊息 |
| exception_traceback | 異常堆疊追蹤 | JSONB | 📝 | 完整Traceback（JSON） |
| extra_fields | 額外欄位 | JSONB | 📝 | 自定義欄位（JSON） |
| created_date | 日誌日期 | DATE | 🔄 | 日期（用於分區） |

**索引**:
- `idx_app_log_timestamp` - 時間戳索引
- `idx_app_log_level` - 日誌等級索引
- `idx_app_log_user_id` - 使用者索引
- `idx_app_log_created_date_timestamp` - 複合索引（日期+時間）

---

### 18. AuditLog（稽核日誌）

**用途**: 操作審計追蹤
**V3.1 新增**: 完整的 Audit Trail 功能

| 英文欄位名 | 中文名稱 | 資料類型 | 標記 | 說明 |
|-----------|---------|---------|------|------|
| log_id | 日誌UUID | UUID | 🔑🔄 | 自動生成 UUID |
| user_id | 使用者ID | UUID | 🔗 | 外鍵至User表 |
| action | 操作動作 | VARCHAR(100) | 📝 | CREATE/UPDATE/DELETE等 |
| resource_type | 資源類型 | VARCHAR(50) | 📝 | Application/Item等 |
| resource_id | 資源ID | VARCHAR(100) | 📝 | 被操作資源的ID |
| old_values | 修改前舊值 | JSON | 📝 | 修改前的資料（JSON） |
| new_values | 修改後新值 | JSON | 📝 | 修改後的資料（JSON） |
| ip_address | IP位址 | VARCHAR(45) | 📝 | 操作者IP |
| user_agent | 使用者代理字串 | TEXT | 📝 | 瀏覽器UA |
| success | 操作是否成功 | BOOLEAN | 📝 | 操作結果 |
| error_message | 錯誤訊息 | TEXT | 📝 | 失敗原因 |
| date_created | 建立時間 | TIMESTAMP | 🔄 | 操作時間 |

**外鍵關聯**:
- `user_id` → `User.id`

**索引**:
- `idx_audit_user_id` - 使用者索引
- `idx_audit_action` - 操作動作索引
- `idx_audit_resource` - 資源類型+ID複合索引
- `idx_audit_date_created` - 建立時間索引

---

## 資料表關聯圖

### 完整系統架構圖

```
┌────────────────────────────────────────────────────────┐
│              核心裝備管理系統（V3.0）                  │
│          (使用 date_created/date_updated)               │
│                                                         │
│  Supplier ─┬─ item_number_xref ─┬─ Item ⭐ ─┬─ Item_Equipment_Ext
│            │                      │           ├─ Item_Material_Ext
│            └─ SupplierCodeApplication        ├─ BOM → BOM_LINE (自我關聯)
│                                              ├─ MRC
│                                              ├─ Item_Document_xref → TechnicalDocument
│                                              └─ CIDApplication
└────────────────────────────────────────────────────────┘
                                                 │
                                                 │ item_uuid (FK) ⭐
                                                 ↓
┌────────────────────────────────────────────────────────┐
│              Web 應用系統（V3.1 新增）                 │
│          (統一使用 date_created/date_updated)           │
│                                                         │
│  User ─┬─ UserSession                                  │
│        ├─ Application ────┬─ ApplicationAttachment     │
│        │   (取代ApplicationForm) │                     │
│        │                  └─→ Item (FK) ⭐             │
│        ├─ AuditLog                                     │
│        └─ ApplicationLog (無FK，記錄user_id)           │
└────────────────────────────────────────────────────────┘
```

### Application 表的關聯重點

```
Application (申編單主表)
├─ user_id → User (申請人)
├─ item_uuid → Item (關聯品項) ⭐ 核心整合點
├─ nsn_filled_by → User (NSN填寫人)
├─ closed_by → User (結案人)
└─ 1:N → ApplicationAttachment (附件)
```

---

## 時間戳命名策略

### 統一命名規範

**所有表（18個）**: 統一使用 `date_created`, `date_updated`

**核心裝備表（12個）**:
- Supplier, Item, Item_Equipment_Ext, Item_Material_Ext
- BOM, BOM_LINE, MRC, item_number_xref
- TechnicalDocument, Item_Document_xref
- SupplierCodeApplication, CIDApplication

**Web 應用表（6個）**:
- User, Application, ApplicationAttachment, UserSession
- ApplicationLog（特殊：使用 `timestamp` + `created_date`）
- AuditLog

**優點**:
- 整個資料庫保持命名一致性
- 簡化觸發器函數邏輯
- 降低開發人員記憶負擔

### 觸發器函數統一處理

```sql
CREATE OR REPLACE FUNCTION update_date_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    -- 所有表統一使用 date_updated 欄位
    IF to_jsonb(NEW) ? 'date_updated' THEN
        NEW.date_updated = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';
```

---

## 版本演進

### V3.0（12 個核心表）
- Item 自我關聯 BOM 結構
- UUID 主鍵設計
- 擴展表設計（減少 NULL 欄位）
- BOM 版本控制

### V3.1（18 個表：12 核心 + 6 Web）⭐ 最新版本
- 整合 Web 應用系統
- 完整使用者管理
- 詳細申編單管理（50+ 欄位）
- 附件管理（BYTEA 儲存）
- 完整審計追蹤
- 應用程式日誌記錄
- Application 與 Item 表整合

---

## 主鍵類型說明

### UUID 主鍵（10個表）
- Item, BOM, BOM_LINE, MRC
- SupplierCodeApplication, CIDApplication
- User, Application, ApplicationAttachment
- ApplicationLog, AuditLog

### 自動編號主鍵 SERIAL（3個表）
- Supplier
- item_number_xref
- TechnicalDocument

### 字串主鍵（1個表）
- UserSession (session_id)

### 複合主鍵（1個表）
- Item_Document_xref (item_uuid, document_id)

**說明**：Item_Equipment_Ext 和 Item_Material_Ext 雖然使用 item_uuid 作為主鍵，但不是複合主鍵，而是單一主鍵（同時也是外鍵）

---

## 🎯 關鍵整合點

### Application ↔ Item 關聯 ⭐

```sql
-- Application 表的 item_uuid 欄位
item_uuid UUID REFERENCES Item(item_uuid) ON DELETE SET NULL

-- 查詢範例：找出某個 Item 的所有申編單
SELECT a.*
FROM Application a
WHERE a.item_uuid = '某個Item的UUID'
AND a.deleted_at IS NULL;  -- 排除已刪除的申編單

-- 查詢範例：申編單關聯品項資訊
SELECT
    a.form_serial_number,
    a.status,
    i.item_code,
    i.item_name_zh,
    u.username AS applicant
FROM Application a
LEFT JOIN Item i ON a.item_uuid = i.item_uuid
LEFT JOIN "User" u ON a.user_id = u.id
WHERE a.deleted_at IS NULL;
```

---

## 📊 效能與擴展性

### ✅ 優���
- 支援多層級 BOM 結構
- BOM 版本控制（歷史追溯）
- 擴展表減少 NULL 欄��
- UUID 主鍵防止 ID 猜測
- 完整的使用者管理系統
- 軟刪除支援（deleted_at）
- 完整的審計追蹤
- 適合大量資料擴展

### 📈 索引策略
- 外鍵欄位都有索引
- 常用查詢欄位有索引
- 部分索引（如 deleted_at）減少索引大小
- 複合索引支援常見查詢模式

---

**文件版本**: 3.1.0
**最後更新**: 2025-11-27
**維護單位**: SBIR 專案團隊
**資料表總數**: ✅ 18 個表（12 核心 + 6 Web）
**主要變更**: 整合 Web 應用使用者與申編單管理系統
