    # 資料庫逆向工程分析報告

## 一、現有表格分析

根據提供的Excel表格結構，這些表格是SQL查詢後的結果，包含大量重複欄位。我們需要識別共同項目並推導出原始的正規化資料表結構。

### 共同欄位分析

以下是在多個表格中重複出現的關鍵欄位：

1. **品項識別碼** - 出現在基本資料、有料號、無料號、18M、19M、20M
2. **配件號碼(P/N)** - 出現在基本資料、有料號、無料號、BOM表、20M
3. **單機識別碼(CID)** - 出現在有料號、無料號、3M、16M、18M
4. **會計編號** - 出現在基本資料、有料號、無料號、2M、19M、書籍檔
5. **武器系統代號** - 出現在基本資料、有料號、無料號、19M
6. **廠商來源代號** - 出現在基本資料、有料號、無料號、3M、19M、20M
7. **廠家登記代號** - 出現在基本資料、有料號、無料號、19M、20M

## 二、推導的原始資料表結構

基於正規化原則(1NF, 2NF, 3NF)，推導出以下原始資料表：

### 1. 裝備主檔 (Equipment)
```sql
CREATE TABLE Equipment (
    equipment_id VARCHAR(50) PRIMARY KEY,  -- 單機識別碼(CID)
    equipment_name_zh VARCHAR(100),        -- 裝備中文名稱
    equipment_name_en VARCHAR(200),        -- 裝備英文名稱
    equipment_type VARCHAR(50),            -- 型式
    ship_type VARCHAR(50),                 -- 艦型
    position VARCHAR(100),                 -- 位置
    parent_equipment_zh VARCHAR(100),      -- 上一層裝備(中)
    parent_equipment_en VARCHAR(200),      -- 上一層裝備(英)
    parent_cid VARCHAR(50),               -- 上層適用裝備單機識別碼
    eswbs_code VARCHAR(20),               -- ESWBS(五碼)/族群結構碼
    system_function_name VARCHAR(200),     -- 系統功能名稱
    installation_qty INT,                  -- 裝置數
    total_installation_qty INT,            -- 全艦裝置數
    maintenance_level VARCHAR(10),         -- 裝備維修等級代碼
    equipment_serial VARCHAR(50)           -- 裝備識別編號
);
```

### 2. 品項主檔 (Item)
```sql
CREATE TABLE Item (
    item_id VARCHAR(20) PRIMARY KEY,       -- 品項識別碼
    item_id_last5 VARCHAR(5),             -- 品項識別碼(後五碼)
    nsn VARCHAR(20) UNIQUE,               -- NSN/國家料號
    item_category VARCHAR(10),            -- 統一組類別
    item_name_zh VARCHAR(100),            -- 中文品名
    item_name_zh_short VARCHAR(20),       -- 中文品名(9字內)
    item_name_en VARCHAR(200),            -- 英文品名/INC英文品名
    item_code VARCHAR(10),                -- 品名代號
    fiig VARCHAR(10),                     -- FIIG
    weapon_system_code VARCHAR(20),       -- 武器系統代號
    accounting_code VARCHAR(20),          -- 會計編號
    issue_unit VARCHAR(10),               -- 撥發單位
    unit_price_usd DECIMAL(10,2),        -- 美金單價
    package_qty INT,                      -- 單位包裝量
    weight_kg DECIMAL(10,3),              -- 重量(KG)
    has_stock BOOLEAN                     -- 有無料號
);
```

### 3. 品項屬性檔 (ItemAttribute)
```sql
CREATE TABLE ItemAttribute (
    item_id VARCHAR(20) PRIMARY KEY,
    storage_life_code VARCHAR(10),        -- 存儲壽限代號
    file_type_code VARCHAR(10),          -- 檔別代號
    file_type_category VARCHAR(10),      -- 檔別區分
    security_code VARCHAR(10),           -- 機密性代號
    consumable_code VARCHAR(10),         -- 消耗性代號
    spec_indicator VARCHAR(10),          -- 規格指示
    navy_source VARCHAR(50),             -- 海軍軍品來源
    storage_type VARCHAR(20),            -- 儲存型式
    life_process_code VARCHAR(10),       -- 壽限處理代號
    manufacturing_capacity VARCHAR(10),   -- 製造能量
    repair_capacity VARCHAR(10),         -- 修理能量
    source_code VARCHAR(10),             -- 來源代號
    project_code VARCHAR(20),            -- 專案代號
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);
```

### 4. 廠商主檔 (Supplier)
```sql
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_code VARCHAR(20) UNIQUE,     -- 廠商來源代號
    cage_code VARCHAR(20),                -- 廠家登記代號
    supplier_name_en VARCHAR(200),        -- 廠家製造商(英文)
    supplier_name_zh VARCHAR(100),        -- 廠商中文名稱
    supplier_type VARCHAR(20),            -- 廠商類型(製造商/代理商)
    country_code VARCHAR(10)              -- 國家代碼
);
```

### 5. 零件號碼檔 (PartNumber)
```sql
CREATE TABLE PartNumber (
    part_number_id INT PRIMARY KEY AUTO_INCREMENT,
    part_number VARCHAR(50),              -- 配件號碼(P/N)
    item_id VARCHAR(20),                  -- 品項識別碼
    supplier_id INT,                      -- 廠商ID
    obtain_level VARCHAR(10),             -- P/N獲得程度/參考號獲得程度
    obtain_source VARCHAR(50),            -- P/N獲得來源/參考號獲得來源
    is_primary BOOLEAN,                   -- 是否為主要零件號
    FOREIGN KEY (item_id) REFERENCES Item(item_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    UNIQUE KEY unique_part (part_number, item_id, supplier_id)
);
```

### 6. BOM結構檔 (BOM)
```sql
CREATE TABLE BOM (
    bom_id INT PRIMARY KEY AUTO_INCREMENT,
    parent_equipment_id VARCHAR(50),      -- 父裝備單機識別碼
    child_item_id VARCHAR(20),            -- 子品項識別碼
    item_no_plsin VARCHAR(20),           -- ITEM NO PLSIN
    quantity INT,                         -- 數量
    unit VARCHAR(10),                    -- 單位
    delivery_time INT,                    -- 交貨時間(天)
    failure_rate_per_million DECIMAL(10,4), -- 每百萬小時預估故障次數
    mtbf_hours INT,                       -- 平均故障間隔(小時)
    mttr_hours DECIMAL(10,2),           -- 平均修護時間(小時)
    is_repairable CHAR(1),               -- 是否為可修件(Y/N)
    FOREIGN KEY (parent_equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (child_item_id) REFERENCES Item(item_id)
);
```

### 7. 裝備品項關聯檔 (EquipmentItem)
```sql
CREATE TABLE EquipmentItem (
    equipment_id VARCHAR(50),             -- 單機識別碼
    item_id VARCHAR(20),                  -- 品項識別碼
    installation_qty INT,                 -- 單機零附件裝置數
    installation_unit VARCHAR(10),        -- 單機零附件裝置單位
    PRIMARY KEY (equipment_id, item_id),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);
```

### 8. 技術文件檔 (TechnicalDocument)
```sql
CREATE TABLE TechnicalDocument (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    equipment_id VARCHAR(50),             -- 單機識別碼
    document_name VARCHAR(200),           -- 圖名/書名
    document_version VARCHAR(20),         -- 技術文件版別/版次
    shipyard_drawing_no VARCHAR(50),      -- 船廠圖號
    design_drawing_no VARCHAR(50),        -- 設計圖號
    document_type VARCHAR(20),           -- 資料類型
    document_category VARCHAR(20),        -- 資料類別
    language VARCHAR(10),                -- 語言
    security_level VARCHAR(10),          -- 機密等級
    eswbs_code VARCHAR(20),              -- ESWBS(五碼)
    accounting_code VARCHAR(20),          -- 會計編號
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);
```

### 9. 裝備特性說明檔 (EquipmentSpecification)
```sql
CREATE TABLE EquipmentSpecification (
    equipment_id VARCHAR(50),             -- 單機識別碼
    spec_seq_no INT,                     -- 單機特性說明序號
    spec_description TEXT,                -- 單機特性說明
    PRIMARY KEY (equipment_id, spec_seq_no),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);
```

### 10. 品項規格檔 (ItemSpecification)
```sql
CREATE TABLE ItemSpecification (
    spec_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id VARCHAR(20),                  -- 品項識別碼
    spec_no INT,                          -- 規格編號(1-5)
    spec_abbr VARCHAR(20),                -- 規格資料縮寫
    spec_en VARCHAR(200),                 -- 規格資料英文
    spec_zh VARCHAR(200),                 -- 規格資料翻譯
    answer_en VARCHAR(200),               -- 英答
    answer_zh VARCHAR(200),               -- 中答
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);
```

### 11. 申編單檔 (ApplicationForm)
```sql
CREATE TABLE ApplicationForm (
    form_id INT PRIMARY KEY AUTO_INCREMENT,
    form_no VARCHAR(50) UNIQUE,          -- 表單編號
    submit_status VARCHAR(20),           -- 申編單提送狀態
    yetl VARCHAR(20),                    -- YETL
    applicant_accounting_code VARCHAR(20), -- 申請單位會計編號
    created_date DATE,
    updated_date DATE
);
```

### 12. 申編單明細檔 (ApplicationFormDetail)
```sql
CREATE TABLE ApplicationFormDetail (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    form_id INT,                         -- 表單ID
    item_seq INT,                        -- 項次
    item_id VARCHAR(20),                 -- 品項識別碼
    document_source VARCHAR(100),        -- 文件來源
    image_path VARCHAR(500),             -- 圖片路徑
    FOREIGN KEY (form_id) REFERENCES ApplicationForm(form_id),
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);
```

## 三、關聯圖說明

### 主要關聯關係：

1. **Equipment (裝備)** 為中心實體
   - 與 Item 透過 EquipmentItem 形成多對多關係
   - 與 TechnicalDocument 形成一對多關係
   - 與 EquipmentSpecification 形成一對多關係
   - 與 BOM 形成階層式關係（自我參照）

2. **Item (品項)** 為核心實體
   - 與 ItemAttribute 形成一對一關係
   - 與 PartNumber 形成一對多關係
   - 與 ItemSpecification 形成一對多關係
   - 與 Supplier 透過 PartNumber 形成多對多關係

3. **Supplier (廠商)** 管理供應商資訊
   - 與 Item 透過 PartNumber 形成多對多關係

4. **ApplicationForm (申編單)** 管理申請流程
   - 與 Item 透過 ApplicationFormDetail 形成多對多關係

## 四、資料正規化優勢

### 1. 消除資料冗餘
- 將重複的廠商資訊集中到 Supplier 表
- 品項基本資訊與屬性分離
- 裝備與品項關聯獨立管理

### 2. 維護資料一致性
- 使用外鍵約束確保參照完整性
- 避免更新異常和刪除異常
- 統一代碼管理

### 3. 提升查詢效率
- 適當的索引設計
- 減少JOIN操作的複雜度
- 支援多維度查詢

### 4. 擴充性佳
- 容易新增屬性欄位
- 支援新的關聯關係
- 模組化設計便於維護

## 五、資料遷移建議

### 第一階段：基礎主檔建立
1. 先建立 Supplier 表
2. 建立 Equipment 表
3. 建立 Item 及 ItemAttribute 表

### 第二階段：關聯資料建立
1. 建立 PartNumber 表
2. 建立 EquipmentItem 表
3. 建立 BOM 表

### 第三階段：輔助資料建立
1. 建立技術文件相關表
2. 建立規格說明相關表
3. 建立申編單相關表

## 六、索引建議

```sql
-- 常用查詢索引
CREATE INDEX idx_item_nsn ON Item(nsn);
CREATE INDEX idx_item_category ON Item(item_category);
CREATE INDEX idx_part_number ON PartNumber(part_number);
CREATE INDEX idx_equipment_eswbs ON Equipment(eswbs_code);
CREATE INDEX idx_bom_parent ON BOM(parent_equipment_id);
CREATE INDEX idx_bom_child ON BOM(child_item_id);

-- 複合索引
CREATE INDEX idx_equipment_item ON EquipmentItem(equipment_id, item_id);
CREATE INDEX idx_part_supplier ON PartNumber(part_number, supplier_id);
```

## 七、資料完整性約束

```sql
-- 檢查約束範例
ALTER TABLE Item ADD CONSTRAINT chk_price CHECK (unit_price_usd >= 0);
ALTER TABLE BOM ADD CONSTRAINT chk_qty CHECK (quantity > 0);
ALTER TABLE BOM ADD CONSTRAINT chk_repairable CHECK (is_repairable IN ('Y','N'));

-- 唯一約束
ALTER TABLE Equipment ADD CONSTRAINT uk_equipment_serial UNIQUE (equipment_serial);
ALTER TABLE Supplier ADD CONSTRAINT uk_cage_code UNIQUE (cage_code);
```

## 八、總結

透過逆向工程分析，我們成功地從現有的非正規化Excel表格推導出12個正規化的資料表。這個設計遵循第三正規化形式(3NF)，有效地：

1. **消除了資料冗餘** - 相同資料只存儲一次
2. **確保了資料一致性** - 透過外鍵約束維護參照完整性
3. **提高了維護效率** - 模組化設計便於後續修改
4. **支援了複雜查詢** - 合理的關聯設計支援各種業務需求

此資料庫設計適合用於海軍裝備管理系統，涵蓋了從裝備、品項、廠商到技術文件的完整管理需求。
