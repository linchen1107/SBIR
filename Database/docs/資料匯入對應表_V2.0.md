# 📊 廚房滅火系統資料匯入對應表（V2.0 實際匯入版本）

## 📁 資料來源
- **Excel 檔案**：`廚房滅火系統ILS及APL_版4.1.xlsx`
- **資料庫**：`sbir_equipment_db` (PostgreSQL 16)
- **匯入日期**：2025-11-14
- **匯入工具**：`import_data_from_ils.py`

## 🎨 顏色標記說明
- 🟦 **Excel 欄位**（來源）
- 🟩 **資料庫欄位**（目標）
- ✅ **已成功匯入**
- ⚠️ **需特別處理**
- ❌ **未匯入**

---

## 📊 匯入統計結果

| 🟩 資料庫表 | 成功筆數 | 跳過筆數 | 錯誤筆數 | 🟦 Excel 來源工作表 |
|------------|---------|---------|---------|------------------|
| Supplier | 2 | 0 | 1 (重複) | 19M, 20M |
| Equipment | 1 | 0 | 0 | 2M, 3M |
| Item | 11 | 6 (重複) | 0 | 19M |
| Part_Number_xref | 68 | 0 | 0 | 19M, 20M |
| Equipment_Item_xref | 10 | 6 (重複) | 0 | 18M |
| TechnicalDocument | 1 | 16 (空白) | 0 | 書籍檔建置 |
| EquipmentSpecification | 2 | 0 | 0 | 16M |

**總計**：成功匯入 95 筆資料到 7 個表

---

## Excel 檔案結構說明

### 📋 工作表結構
每個 M 表工作表都有 3 行標題：
- **第 0 行**：中文欄位名稱（含備註）例如：`*異動方式\n(N新增、C修改、D刪除)`
- **第 1 行**：範例資料或分類標記 例如：`Class`, `出入`, `N00013`
- **第 2 行**：英文欄位代號 例如：`MODIFY_TYPE`, `IMPORT_ITEM_NUMBER`, `CID`
- **第 3 行起**：實際資料

### 🔧 讀取設定
```python
pd.read_excel(EXCEL_PATH, sheet_name='工作表名稱', header=0, skiprows=[1, 2])
```
- `header=0`：使用第 0 行中文欄位名稱作為欄位名
- `skiprows=[1, 2]`：跳過第 1, 2 行（範例和英文代號）

---

# 📋 詳細欄位對應

## 1️⃣ 🟩 Supplier（廠商主檔）

### 來源 A：🟦 19M（料號基本資料檔）
| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 廠商來源代號 | supplier_code | VARCHAR(20) | PK, UNIQUE |
| 廠家登記代號 | cage_code | VARCHAR(20) | UNIQUE |
| ⚠️ 固定值 '製造商' | supplier_type | VARCHAR(20) | 程式寫死 |

### 來源 B：🟦 20M（料號主要件號檔）
| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 廠商來源代號 | supplier_code | VARCHAR(20) | 補充來源 |
| 廠家登記代號 | cage_code | VARCHAR(20) | 補充來源 |

### 匯入邏輯
```python
# 1. 從 19M 和 20M 提取廠商資料
suppliers_19m = df_19m[['廠商來源代號', '廠家登記代號']].dropna().drop_duplicates()
suppliers_20m = df_20m[['廠商來源代號', '廠家登記代號']].dropna().drop_duplicates()

# 2. 合併並去重
suppliers = pd.concat([suppliers_19m, suppliers_20m]).drop_duplicates()

# 3. 使用 ON CONFLICT 避免重複
INSERT INTO Supplier (supplier_code, cage_code, supplier_type)
VALUES (%s, %s, '製造商')
ON CONFLICT (cage_code) DO NOTHING
```

### ✅ 匯入結果
- **成功**：2 筆新增
- **錯誤**：1 筆重複（supplier_code='A' 已存在）

---

## 2️⃣ 🟩 Equipment（裝備主檔）

### 來源 A：🟦 2M（單位構型檔）- 主要來源
| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 單機識別碼CID | equipment_id | VARCHAR(50) | PK |
| 中文名稱 | equipment_name_zh | VARCHAR(100) | |
| 英文名稱 | equipment_name_en | VARCHAR(200) | |
| 裝備形式 | equipment_type | VARCHAR(50) | |
| 艦型 | ship_type | VARCHAR(50) | |
| 裝設地點 | position | VARCHAR(100) | |
| 上層適用裝備單機識別碼CID | parent_cid | VARCHAR(50) | FK to Equipment |
| 族群結構碼HSC | eswbs_code | VARCHAR(20) | |
| 同一類型數量 | installation_qty | INT | |
| 全艦裝置數 | total_installation_qty | INT | |
| 裝備序號 | equipment_serial | VARCHAR(50) | UNIQUE |

### 來源 B：🟦 3M（單機資料檔）- 補充資料
| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 單機識別碼 | equipment_id | VARCHAR(50) | 用於 JOIN 更新 |
| 裝備維修等級代碼 | maintenance_level | VARCHAR(10) | 補充 2M 缺少的欄位 |

### 匯入邏輯
```python
# 步驟 1：從 2M 建立基本資料
INSERT INTO Equipment (
    equipment_id, equipment_name_zh, equipment_name_en,
    equipment_type, ship_type, position, parent_cid,
    eswbs_code, installation_qty, total_installation_qty,
    equipment_serial
) VALUES (...)

# 步驟 2：用 3M 補充 maintenance_level
UPDATE Equipment
SET maintenance_level = %s
WHERE equipment_id = %s
```

### ✅ 匯入結果
- **成功**：1 筆
- **設備 ID**：64NYE0002
- **名稱**：廚房通風煙道及油炸鍋滅火系統 (Wet Chemical System For Deep Fat Fryer)

---

## 3️⃣ 🟩 Item（品項主檔 - 含原 ItemAttribute 欄位）

### 來源：🟦 19M（料號基本資料檔）

| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 品項識別號 | item_id | VARCHAR(20) | PK |
| ⚠️ 取 item_id 後 5 碼 | item_id_last5 | VARCHAR(5) | 程式計算 |
| ⚠️ 無對應（NSN 無資料） | nsn | VARCHAR(20) | 設為 NULL |
| 統一組類別 | item_category | VARCHAR(10) | |
| 中文品名 | item_name_zh | VARCHAR(100) | |
| ⚠️ 取 item_name_zh 前 9 字 | item_name_zh_short | VARCHAR(20) | 程式計算 |
| 英文品名 | item_name_en | VARCHAR(200) | |
| 品名代號 | item_code | VARCHAR(10) | |
| ⚠️ 無對應 | fiig | VARCHAR(10) | 設為 NULL |
| 武器系統代號 | weapon_system_code | VARCHAR(20) | |
| 申請單位會計編號 | accounting_code | VARCHAR(20) | |
| 撥發單位 | issue_unit | VARCHAR(10) | |
| 美金單價 | unit_price_usd | NUMERIC(10,2) | |
| 單位包裝量 | package_qty | INT | |
| 重量(KG) | weight_kg | NUMERIC(10,3) | |
| ⚠️ 固定值 false | has_stock | BOOLEAN | 預設 false |
| 存儲壽限代號 | storage_life_code | VARCHAR(10) | |
| 檔別代號 | file_type_code | VARCHAR(10) | |
| 檔別區分 | file_type_category | VARCHAR(10) | |
| 機密性代號 | security_code | VARCHAR(10) | |
| 消耗性代號 | consumable_code | VARCHAR(10) | |
| 規格指示 | spec_indicator | VARCHAR(10) | |
| 來源代號 | navy_source | VARCHAR(50) | |
| 儲存型式 | storage_type | VARCHAR(20) | |
| 處理代號(壽限處理) | life_process_code | VARCHAR(10) | |
| 製造能量 | manufacturing_capacity | VARCHAR(10) | |
| 修理能量 | repair_capacity | VARCHAR(10) | |
| 來源代號 | source_code | VARCHAR(10) | |
| 專案代號 | project_code | VARCHAR(20) | |

### 匯入邏輯
```python
# 欄位計算
item_id_str = str(item_id) if item_id else ''
item_id_last5 = item_id_str[-5:] if len(item_id_str) >= 5 else item_id_str

item_name_zh_short = item_name_zh[:9] if item_name_zh else None

# 插入含 26 個欄位
INSERT INTO Item (
    item_id, item_id_last5, nsn, item_category, item_name_zh,
    item_name_zh_short, item_name_en, item_code, fiig,
    weapon_system_code, accounting_code, issue_unit,
    unit_price_usd, package_qty, weight_kg, has_stock,
    storage_life_code, file_type_code, file_type_category,
    security_code, consumable_code, spec_indicator,
    navy_source, storage_type, life_process_code,
    manufacturing_capacity, repair_capacity, source_code,
    project_code
) VALUES (...) ON CONFLICT (item_id) DO NOTHING
```

### ✅ 匯入結果
- **成功**：11 筆
- **跳過**：6 筆（已存在）
- **範例品項**：
  - `013699819`: 廚房用油鍋滅火系統
  - `YETL申請中`: 釋放箱含藥劑桶
  - `015448871`: 噴嘴 2W
  - `014408428`: 低pH濕式化學藥劑

---

## 4️⃣ 🟩 Part_Number_xref（零件號關聯）

### 來源 A：🟦 19M（料號基本資料檔）
| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 品項識別號 | item_id | VARCHAR(20) | FK to Item |
| 廠商來源代號 | supplier_code | VARCHAR(20) | 用於查詢 supplier_id |
| ⚠️ 查詢得到 | supplier_id | INT | FK to Supplier |
| 參考號碼(P/N) | part_number | VARCHAR(50) | 零件號 |
| 參考號獲得程度 | reference_degree | VARCHAR(10) | |

### 來源 B：🟦 20M（料號主要件號檔）
| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 品項識別號 | item_id | VARCHAR(20) | FK to Item |
| 廠商來源代號 | supplier_code | VARCHAR(20) | 用於查詢 supplier_id |
| ⚠️ 查詢得到 | supplier_id | INT | FK to Supplier |
| 參考號碼(P/N) | part_number | VARCHAR(50) | 零件號 |
| ⚠️ 固定值 'Primary' | reference_type | VARCHAR(20) | 程式寫死 |

### 匯入邏輯
```python
# 從 19M 匯入
for row in df_19m:
    # 查詢 supplier_id
    cursor.execute("""
        SELECT supplier_id FROM Supplier
        WHERE supplier_code = %s
    """, (supplier_code,))

    supplier_id = cursor.fetchone()[0] if cursor.rowcount > 0 else None

    # 插入零件號關聯
    INSERT INTO Part_Number_xref (
        item_id, supplier_id, part_number, reference_degree
    ) VALUES (%s, %s, %s, %s)

# 從 20M 匯入（標記為 Primary）
for row in df_20m:
    # 同樣查詢 supplier_id
    INSERT INTO Part_Number_xref (
        item_id, supplier_id, part_number, reference_type
    ) VALUES (%s, %s, %s, 'Primary')
```

### ✅ 匯入結果
- **成功**：68 筆（34 筆新增 + 34 筆來自前次匯入）
- **說明**：建立 Item 與 Supplier 的 N:M 關係，並記錄零件號

---

## 5️⃣ 🟩 Equipment_Item_xref（裝備品項關聯）

### 來源：🟦 18M（單機與料號關聯檔）

| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 單機識別碼CID | equipment_id | VARCHAR(50) | FK to Equipment, PK |
| 品項識別號 | item_id | VARCHAR(20) | FK to Item, PK |
| 品項數量 | installation_qty | INT | 每台裝備需要的數量 |
| 品項配賦單位 | installation_unit | VARCHAR(10) | |
| 供獲前時 | delivery_time | INT | 交期（天） |
| 百萬零件數失效率 | failure_rate_per_million | NUMERIC(10,4) | |
| 平均失效間隔工時MTBF | mtbf_hours | INT | |
| 平均修復時間MTTR | mttr_hours | NUMERIC(10,2) | |
| 可否修理 | is_repairable | CHAR(1) | Y/N |

### 匯入邏輯
```python
INSERT INTO Equipment_Item_xref (
    equipment_id, item_id, installation_qty, installation_unit,
    delivery_time, failure_rate_per_million, mtbf_hours,
    mttr_hours, is_repairable
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (equipment_id, item_id) DO NOTHING
```

### ✅ 匯入結果
- **成功**：10 筆
- **跳過**：6 筆（已存在）
- **說明**：建立 Equipment 與 Item 的 BOM 關係

### 📋 範例資料
| Equipment ID | Item ID | 數量 | 說明 |
|-------------|---------|-----|------|
| 64NYE0002 | YETL申請中 | 1 | 釋放箱含藥劑桶 |
| 64NYE0002 | 015448871 | 1 | 噴嘴 2W |
| 64NYE0002 | 014408428 | 1 | 低pH濕式化學藥劑 |
| 64NYE0002 | 015974145 | 2 | 熱融片剪式聯動夾 |
| 64NYE0002 | 014485107 | 2 | 聯動夾 |

---

## 6️⃣ 🟩 TechnicalDocument（技術文件）

### 來源：🟦 書籍檔建置

| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 書籍編號 | document_id | VARCHAR(10) | PK |
| 書籍名稱 | document_title | VARCHAR(200) | |
| 書籍類別 | document_type | VARCHAR(50) | |
| ⚠️ 無對應 | document_number | VARCHAR(100) | 設為 NULL |
| ⚠️ 無對應 | revision | VARCHAR(20) | 設為 NULL |
| ⚠️ 無對應 | publish_date | DATE | 設為 NULL |

### 匯入邏輯
```python
# 跳過空白的書籍編號
if pd.isna(doc_id) or doc_id == '':
    continue

INSERT INTO TechnicalDocument (
    document_id, document_title, document_type
) VALUES (%s, %s, %s)
ON CONFLICT (document_id) DO NOTHING
```

### ✅ 匯入結果
- **成功**：1 筆
- **跳過**：16 筆（書籍編號為空白）
- **說明**：V2.0 中 TechnicalDocument 改為 N:M 關係，需要額外的 Equipment_Document_xref 表

---

## 7️⃣ 🟩 Equipment_Document_xref（裝備文件關聯）

### 來源：🟦 手動建立或書籍檔建置

| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| ⚠️ 需手動建立 | equipment_id | VARCHAR(50) | FK to Equipment, PK |
| 書籍編號 | document_id | VARCHAR(10) | FK to TechnicalDocument, PK |

### ✅ 匯入結果
- **成功**：0 筆
- **說明**：書籍檔建置工作表中沒有明確的 equipment_id 關聯，需要另外建立

---

## 8️⃣ 🟩 EquipmentSpecification（裝備特性）

### 來源：🟦 16M（單機特性檔）

| 🟦 Excel 欄位 | 🟩 資料庫欄位 | 資料型別 | 處理說明 |
|-------------|-------------|---------|---------|
| 單機識別碼CID | equipment_id | VARCHAR(50) | FK to Equipment, PK |
| 單機特性編號 | spec_seq_no | INT | PK (序號) |
| 單機特性敘述 | spec_description | TEXT | |

### 匯入邏輯
```python
INSERT INTO EquipmentSpecification (
    equipment_id, spec_seq_no, spec_description
) VALUES (%s, %s, %s)
ON CONFLICT (equipment_id, spec_seq_no) DO NOTHING
```

### ✅ 匯入結果
- **成功**：2 筆
- **說明**：記錄裝備的技術特性和規格描述

---

## ❌ 未匯入的表

### 9️⃣ ItemSpecification（品項規格）
- **原因**：19M 的「規格說明」欄位資料不完整
- **建議**：後續手動補充或從其他來源匯入

### 🔟 ApplicationForm（申編單主檔）
- **原因**：使用者要求「申編單先不用」
- **狀態**：暫不匯入

### 1️⃣1️⃣ ApplicationFormDetail（申編單明細）
- **原因**：使用者要求「申編單先不用」
- **狀態**：暫不匯入

---

## 🔧 匯入程式關鍵設定

### 資料庫連線
```python
DB_PARAMS = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db',
    'user': 'postgres',
    'password': 'willlin07'
}
```

### Excel 讀取設定
```python
# 關鍵：跳過第 1, 2 行（範例和英文代號）
df = pd.read_excel(
    EXCEL_PATH,
    sheet_name='工作表名稱',
    header=0,           # 使用第 0 行中文欄位名稱
    skiprows=[1, 2]     # 跳過第 1, 2 行
)

# 清理欄位名稱（移除 * 和換行符）
df.columns = df.columns.str.replace(r'^\*', '', regex=True)
df.columns = df.columns.str.replace(r'\n.*', '', regex=True)
df.columns = df.columns.str.strip()
```

### 交易管理
```python
try:
    # 執行所有匯入
    import_supplier(conn, df_19m, df_20m)
    import_equipment(conn, df_2m, df_3m)
    # ... 其他匯入 ...

    # 提交所有變更
    conn.commit()
    print("✓ 所有變更已提交到資料庫")

except Exception as e:
    # 發生錯誤時回滾
    conn.rollback()
    print("✗ 所有變更已回滾")
    raise
finally:
    conn.close()
```

---

## 📝 注意事項

### 1. Excel 檔案格式
- 所有 M 表都有 3 行標題（中文、範例、英文代號）
- 必須使用 `skiprows=[1, 2]` 跳過第 1, 2 行
- 欄位名稱需要清理（移除 `*` 和 `\n` 後的內容）

### 2. 重複資料處理
- 使用 `ON CONFLICT DO NOTHING` 避免主鍵衝突
- Supplier 表使用 `cage_code` 作為唯一鍵
- Item 表使用 `item_id` 作為唯一鍵
- 關聯表使用複合主鍵

### 3. 外鍵查詢
- Part_Number_xref 需要查詢 Supplier 表獲取 `supplier_id`
- Equipment_Item_xref 依賴 Equipment 和 Item 表已匯入

### 4. 資料品質
- 某些品項的 `item_id` 為 "YETL申請中"，表示還在申請 NSN
- 書籍檔建置工作表中大部分記錄的書籍編號為空白
- 需要額外維護 Equipment_Document_xref 關聯

---

## 🎯 後續工作建議

1. **補充 Supplier 詳細資訊**
   - 查詢 CAGE Code 對應的廠商英文名稱
   - 補充廠商中文名稱
   - 從 CAGE Code 推導國家代碼

2. **建立 Equipment_Document_xref 關聯**
   - 確定哪些技術文件屬於哪個裝備
   - 手動或透過規則建立關聯

3. **補充 ItemSpecification**
   - 從 19M 的「規格說明」欄位提取規格資料
   - 建立品項規格描述

4. **資料驗證**
   - 檢查 Equipment_Item_xref 的數量是否合理
   - 驗證 Part_Number_xref 的零件號格式
   - 確認所有外鍵關係正確

5. **未來匯入申編單**
   - 當需要時，從申編單相關工作表匯入
   - 建立 ApplicationForm 和 ApplicationFormDetail 資料

---

**文件版本**：V2.0
**最後更新**：2025-11-14
**維護人員**：Claude Code