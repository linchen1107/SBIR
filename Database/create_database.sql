-- ============================================
-- PostgreSQL 資料庫建立腳本
-- 資料庫名稱: sbir_equipment_db
-- 用途: 海軍裝備管理系統
-- 建立日期: 2025-11-11
-- 版本: V2.0 (重構版 - 以Equipment為中心)
-- ============================================

-- 建立資料庫
DROP DATABASE IF EXISTS sbir_equipment_db;
CREATE DATABASE sbir_equipment_db
    WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'Chinese (Traditional)_Taiwan.950'
    LC_CTYPE = 'Chinese (Traditional)_Taiwan.950'
    TEMPLATE = template0;

-- 連接到新資料庫
\c sbir_equipment_db;

-- ============================================
-- 第一階段：三大主表建立
-- ============================================

-- 1. 廠商主檔 (Supplier)
CREATE TABLE Supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(20) UNIQUE,
    cage_code VARCHAR(20),
    supplier_name_en VARCHAR(200),
    supplier_name_zh VARCHAR(100),
    supplier_type VARCHAR(20),
    country_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Supplier IS '廠商主檔';
COMMENT ON COLUMN Supplier.supplier_id IS '廠商ID（自動編號）';
COMMENT ON COLUMN Supplier.supplier_code IS '廠商來源代號';
COMMENT ON COLUMN Supplier.cage_code IS '廠家登記代號';
COMMENT ON COLUMN Supplier.supplier_name_en IS '廠家製造商（英文）';
COMMENT ON COLUMN Supplier.supplier_name_zh IS '廠商中文名稱';
COMMENT ON COLUMN Supplier.supplier_type IS '廠商類型（製造商/代理商）';
COMMENT ON COLUMN Supplier.country_code IS '國家代碼';

-- 2. 裝備主檔 (Equipment) ⭐ 核心表
CREATE TABLE Equipment (
    equipment_id VARCHAR(50) PRIMARY KEY,
    equipment_name_zh VARCHAR(100),
    equipment_name_en VARCHAR(200),
    equipment_type VARCHAR(50),
    ship_type VARCHAR(50),
    position VARCHAR(100),
    parent_equipment_zh VARCHAR(100),
    parent_equipment_en VARCHAR(200),
    parent_cid VARCHAR(50),
    eswbs_code VARCHAR(20),
    system_function_name VARCHAR(200),
    installation_qty INT,
    total_installation_qty INT,
    maintenance_level VARCHAR(10),
    equipment_serial VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Equipment IS '裝備主檔（核心表）';
COMMENT ON COLUMN Equipment.equipment_id IS '單機識別碼（CID）';
COMMENT ON COLUMN Equipment.equipment_name_zh IS '裝備中文名稱';
COMMENT ON COLUMN Equipment.equipment_name_en IS '裝備英文名稱';
COMMENT ON COLUMN Equipment.equipment_type IS '型式';
COMMENT ON COLUMN Equipment.ship_type IS '艦型';
COMMENT ON COLUMN Equipment.position IS '位置';
COMMENT ON COLUMN Equipment.parent_equipment_zh IS '上一層裝備（中）';
COMMENT ON COLUMN Equipment.parent_equipment_en IS '上一層裝備（英）';
COMMENT ON COLUMN Equipment.parent_cid IS '上層適用裝備單機識別碼';
COMMENT ON COLUMN Equipment.eswbs_code IS 'ESWBS（五碼）/族群結構碼';
COMMENT ON COLUMN Equipment.system_function_name IS '系統功能名稱';
COMMENT ON COLUMN Equipment.installation_qty IS '裝置數';
COMMENT ON COLUMN Equipment.total_installation_qty IS '全艦裝置數';
COMMENT ON COLUMN Equipment.maintenance_level IS '裝備維修等級代碼';
COMMENT ON COLUMN Equipment.equipment_serial IS '裝備識別編號';

-- 3. 品項主檔 (Item) ⭐ 核心表（合併ItemAttribute）
CREATE TABLE Item (
    item_id VARCHAR(20) PRIMARY KEY,
    item_id_last5 VARCHAR(5),
    nsn VARCHAR(20) UNIQUE,
    item_category VARCHAR(10),
    item_name_zh VARCHAR(100),
    item_name_zh_short VARCHAR(20),
    item_name_en VARCHAR(200),
    item_code VARCHAR(10),
    fiig VARCHAR(10),
    weapon_system_code VARCHAR(20),
    accounting_code VARCHAR(20),
    issue_unit VARCHAR(10),
    unit_price_usd DECIMAL(10,2),
    package_qty INT,
    weight_kg DECIMAL(10,3),
    has_stock BOOLEAN DEFAULT FALSE,
    -- 以下欄位來自原 ItemAttribute 表
    storage_life_code VARCHAR(10),
    file_type_code VARCHAR(10),
    file_type_category VARCHAR(10),
    security_code VARCHAR(10),
    consumable_code VARCHAR(10),
    spec_indicator VARCHAR(10),
    navy_source VARCHAR(50),
    storage_type VARCHAR(20),
    life_process_code VARCHAR(10),
    manufacturing_capacity VARCHAR(10),
    repair_capacity VARCHAR(10),
    source_code VARCHAR(10),
    project_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Item IS '品項主檔（合併ItemAttribute）';
COMMENT ON COLUMN Item.item_id IS '品項識別碼';
COMMENT ON COLUMN Item.item_id_last5 IS '品項識別碼（後五碼）';
COMMENT ON COLUMN Item.nsn IS 'NSN/國家料號';
COMMENT ON COLUMN Item.item_category IS '統一組類別';
COMMENT ON COLUMN Item.item_name_zh IS '中文品名';
COMMENT ON COLUMN Item.item_name_zh_short IS '中文品名（9字內）';
COMMENT ON COLUMN Item.item_name_en IS '英文品名/INC英文品名';
COMMENT ON COLUMN Item.item_code IS '品名代號';
COMMENT ON COLUMN Item.fiig IS 'FIIG';
COMMENT ON COLUMN Item.weapon_system_code IS '武器系統代號';
COMMENT ON COLUMN Item.accounting_code IS '會計編號';
COMMENT ON COLUMN Item.issue_unit IS '撥發單位';
COMMENT ON COLUMN Item.unit_price_usd IS '美金單價';
COMMENT ON COLUMN Item.package_qty IS '單位包裝量';
COMMENT ON COLUMN Item.weight_kg IS '重量（KG）';
COMMENT ON COLUMN Item.has_stock IS '有無料號';
-- 原 ItemAttribute 欄位註解
COMMENT ON COLUMN Item.storage_life_code IS '存儲壽限代號';
COMMENT ON COLUMN Item.file_type_code IS '檔別代號';
COMMENT ON COLUMN Item.file_type_category IS '檔別區分';
COMMENT ON COLUMN Item.security_code IS '機密性代號';
COMMENT ON COLUMN Item.consumable_code IS '消耗性代號';
COMMENT ON COLUMN Item.spec_indicator IS '規格指示';
COMMENT ON COLUMN Item.navy_source IS '海軍軍品來源';
COMMENT ON COLUMN Item.storage_type IS '儲存型式';
COMMENT ON COLUMN Item.life_process_code IS '壽限處理代號';
COMMENT ON COLUMN Item.manufacturing_capacity IS '製造能量';
COMMENT ON COLUMN Item.repair_capacity IS '修理能量';
COMMENT ON COLUMN Item.source_code IS '來源代號';
COMMENT ON COLUMN Item.project_code IS '專案代號';

-- ============================================
-- 第二階段：關聯表建立
-- ============================================

-- 4. 零件號碼關聯檔 (Part_Number_xref)
CREATE TABLE Part_Number_xref (
    part_number_id SERIAL PRIMARY KEY,
    part_number VARCHAR(50),
    item_id VARCHAR(20),
    supplier_id INT,
    obtain_level VARCHAR(10),
    obtain_source VARCHAR(50),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES Item(item_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE SET NULL,
    CONSTRAINT unique_part UNIQUE (part_number, item_id, supplier_id)
);

COMMENT ON TABLE Part_Number_xref IS '零件號碼關聯檔（品項-供應商多對多）';
COMMENT ON COLUMN Part_Number_xref.part_number_id IS '零件號碼ID（自動編號）';
COMMENT ON COLUMN Part_Number_xref.part_number IS '配件號碼（P/N）';
COMMENT ON COLUMN Part_Number_xref.item_id IS '品項識別碼';
COMMENT ON COLUMN Part_Number_xref.supplier_id IS '廠商ID';
COMMENT ON COLUMN Part_Number_xref.obtain_level IS 'P/N獲得程度/參考號獲得程度';
COMMENT ON COLUMN Part_Number_xref.obtain_source IS 'P/N獲得來源/參考號獲得來源';
COMMENT ON COLUMN Part_Number_xref.is_primary IS '是否為主要零件號';

-- 5. 裝備品項關聯檔 (Equipment_Item_xref) ⭐ 合併BOM可靠度資料
CREATE TABLE Equipment_Item_xref (
    equipment_id VARCHAR(50),
    item_id VARCHAR(20),
    installation_qty INT,
    installation_unit VARCHAR(10),
    -- 以下欄位來自原 BOM 表
    delivery_time INT,
    failure_rate_per_million DECIMAL(10,4),
    mtbf_hours INT,
    mttr_hours DECIMAL(10,2),
    is_repairable CHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (equipment_id, item_id),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Item(item_id) ON DELETE CASCADE,
    CONSTRAINT chk_is_repairable CHECK (is_repairable IN ('Y','N') OR is_repairable IS NULL)
);

COMMENT ON TABLE Equipment_Item_xref IS '裝備品項關聯檔（裝備-品項多對多，含可靠度資料）';
COMMENT ON COLUMN Equipment_Item_xref.equipment_id IS '單機識別碼';
COMMENT ON COLUMN Equipment_Item_xref.item_id IS '品項識別碼';
COMMENT ON COLUMN Equipment_Item_xref.installation_qty IS '單機零附件裝置數';
COMMENT ON COLUMN Equipment_Item_xref.installation_unit IS '單機零附件裝置單位';
-- 原 BOM 欄位註解
COMMENT ON COLUMN Equipment_Item_xref.delivery_time IS '交貨時間（天）';
COMMENT ON COLUMN Equipment_Item_xref.failure_rate_per_million IS '每百萬小時預估故障次數';
COMMENT ON COLUMN Equipment_Item_xref.mtbf_hours IS '平均故障間隔（小時）';
COMMENT ON COLUMN Equipment_Item_xref.mttr_hours IS '平均修護時間（小時）';
COMMENT ON COLUMN Equipment_Item_xref.is_repairable IS '是否為可修件（Y/N）';

-- ============================================
-- 第三階段：輔助資料建立
-- ============================================

-- 6. 技術文件檔 (TechnicalDocument)
CREATE TABLE TechnicalDocument (
    document_id SERIAL PRIMARY KEY,
    equipment_id VARCHAR(50),
    document_name VARCHAR(200),
    document_version VARCHAR(20),
    shipyard_drawing_no VARCHAR(50),
    design_drawing_no VARCHAR(50),
    document_type VARCHAR(20),
    document_category VARCHAR(20),
    language VARCHAR(10),
    security_level VARCHAR(10),
    eswbs_code VARCHAR(20),
    accounting_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id) ON DELETE CASCADE
);

COMMENT ON TABLE TechnicalDocument IS '技術文件檔';
COMMENT ON COLUMN TechnicalDocument.document_id IS '文件ID（自動編號）';
COMMENT ON COLUMN TechnicalDocument.equipment_id IS '單機識別碼';
COMMENT ON COLUMN TechnicalDocument.document_name IS '圖名/書名';
COMMENT ON COLUMN TechnicalDocument.document_version IS '技術文件版別/版次';
COMMENT ON COLUMN TechnicalDocument.shipyard_drawing_no IS '船廠圖號';
COMMENT ON COLUMN TechnicalDocument.design_drawing_no IS '設計圖號';
COMMENT ON COLUMN TechnicalDocument.document_type IS '資料類型';
COMMENT ON COLUMN TechnicalDocument.document_category IS '資料類別';
COMMENT ON COLUMN TechnicalDocument.language IS '語言';
COMMENT ON COLUMN TechnicalDocument.security_level IS '機密等級';
COMMENT ON COLUMN TechnicalDocument.eswbs_code IS 'ESWBS（五碼）';
COMMENT ON COLUMN TechnicalDocument.accounting_code IS '會計編號';

-- 7. 裝備特性說明檔 (EquipmentSpecification)
CREATE TABLE EquipmentSpecification (
    equipment_id VARCHAR(50),
    spec_seq_no INT,
    spec_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (equipment_id, spec_seq_no),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id) ON DELETE CASCADE
);

COMMENT ON TABLE EquipmentSpecification IS '裝備特性說明檔';
COMMENT ON COLUMN EquipmentSpecification.equipment_id IS '單機識別碼';
COMMENT ON COLUMN EquipmentSpecification.spec_seq_no IS '單機特性說明序號';
COMMENT ON COLUMN EquipmentSpecification.spec_description IS '單機特性說明';

-- 8. 品項規格檔 (ItemSpecification)
CREATE TABLE ItemSpecification (
    spec_id SERIAL PRIMARY KEY,
    item_id VARCHAR(20),
    spec_no INT,
    spec_abbr VARCHAR(20),
    spec_en VARCHAR(200),
    spec_zh VARCHAR(200),
    answer_en VARCHAR(200),
    answer_zh VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES Item(item_id) ON DELETE CASCADE
);

COMMENT ON TABLE ItemSpecification IS '品項規格檔';
COMMENT ON COLUMN ItemSpecification.spec_id IS '規格ID（自動編號）';
COMMENT ON COLUMN ItemSpecification.item_id IS '品項識別碼';
COMMENT ON COLUMN ItemSpecification.spec_no IS '規格編號（1-5）';
COMMENT ON COLUMN ItemSpecification.spec_abbr IS '規格資料縮寫';
COMMENT ON COLUMN ItemSpecification.spec_en IS '規格資料英文';
COMMENT ON COLUMN ItemSpecification.spec_zh IS '規格資料翻譯';
COMMENT ON COLUMN ItemSpecification.answer_en IS '英答';
COMMENT ON COLUMN ItemSpecification.answer_zh IS '中答';

-- 9. 申編單檔 (ApplicationForm)
CREATE TABLE ApplicationForm (
    form_id SERIAL PRIMARY KEY,
    form_no VARCHAR(50) UNIQUE,
    submit_status VARCHAR(20),
    yetl VARCHAR(20),
    applicant_accounting_code VARCHAR(20),
    created_date DATE DEFAULT CURRENT_DATE,
    updated_date DATE DEFAULT CURRENT_DATE
);

COMMENT ON TABLE ApplicationForm IS '申編單檔';
COMMENT ON COLUMN ApplicationForm.form_id IS '表單ID（自動編號）';
COMMENT ON COLUMN ApplicationForm.form_no IS '表單編號';
COMMENT ON COLUMN ApplicationForm.submit_status IS '申編單提送狀態';
COMMENT ON COLUMN ApplicationForm.yetl IS 'YETL';
COMMENT ON COLUMN ApplicationForm.applicant_accounting_code IS '申請單位會計編號';
COMMENT ON COLUMN ApplicationForm.created_date IS '建立日期';
COMMENT ON COLUMN ApplicationForm.updated_date IS '更新日期';

-- 10. 申編單明細檔 (ApplicationFormDetail)
CREATE TABLE ApplicationFormDetail (
    detail_id SERIAL PRIMARY KEY,
    form_id INT,
    item_seq INT,
    item_id VARCHAR(20),
    document_source VARCHAR(100),
    image_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (form_id) REFERENCES ApplicationForm(form_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Item(item_id) ON DELETE SET NULL
);

COMMENT ON TABLE ApplicationFormDetail IS '申編單明細檔';
COMMENT ON COLUMN ApplicationFormDetail.detail_id IS '明細ID（自動編號）';
COMMENT ON COLUMN ApplicationFormDetail.form_id IS '表單ID';
COMMENT ON COLUMN ApplicationFormDetail.item_seq IS '項次';
COMMENT ON COLUMN ApplicationFormDetail.item_id IS '品項識別碼';
COMMENT ON COLUMN ApplicationFormDetail.document_source IS '文件來源';
COMMENT ON COLUMN ApplicationFormDetail.image_path IS '圖片路徑';

-- ============================================
-- 索引建立
-- ============================================

-- 品項主檔索引
CREATE INDEX idx_item_nsn ON Item(nsn);
CREATE INDEX idx_item_category ON Item(item_category);
CREATE INDEX idx_item_accounting_code ON Item(accounting_code);
CREATE INDEX idx_item_weapon_system_code ON Item(weapon_system_code);

-- 零件號索引
CREATE INDEX idx_part_number ON Part_Number_xref(part_number);
CREATE INDEX idx_part_supplier ON Part_Number_xref(part_number, supplier_id);

-- 裝備主檔索引
CREATE INDEX idx_equipment_eswbs ON Equipment(eswbs_code);
CREATE INDEX idx_equipment_ship_type ON Equipment(ship_type);

-- 廠商索引
CREATE INDEX idx_supplier_code ON Supplier(supplier_code);
CREATE INDEX idx_supplier_cage_code ON Supplier(cage_code);

-- 裝備品項關聯索引
CREATE INDEX idx_equipment_item ON Equipment_Item_xref(equipment_id, item_id);

-- 品項規格索引
CREATE INDEX idx_item_spec ON ItemSpecification(item_id, spec_no);

-- 技術文件索引
CREATE INDEX idx_tech_doc_equipment ON TechnicalDocument(equipment_id);
CREATE INDEX idx_tech_doc_eswbs ON TechnicalDocument(eswbs_code);

-- 申編單索引
CREATE INDEX idx_app_form_no ON ApplicationForm(form_no);
CREATE INDEX idx_app_detail_form ON ApplicationFormDetail(form_id);
CREATE INDEX idx_app_detail_item ON ApplicationFormDetail(item_id);

-- ============================================
-- 額外約束
-- ============================================

-- 價格檢查約束
ALTER TABLE Item ADD CONSTRAINT chk_price CHECK (unit_price_usd >= 0);

-- 重量檢查約束
ALTER TABLE Item ADD CONSTRAINT chk_weight CHECK (weight_kg >= 0);

-- 裝備序號唯一約束
ALTER TABLE Equipment ADD CONSTRAINT uk_equipment_serial UNIQUE (equipment_serial);

-- 廠商 CAGE CODE 唯一約束
ALTER TABLE Supplier ADD CONSTRAINT uk_cage_code UNIQUE (cage_code);

-- ============================================
-- 建立更新時間戳自動更新函數
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 為每個有 updated_at 欄位的表格建立觸發器
CREATE TRIGGER update_supplier_updated_at BEFORE UPDATE ON Supplier
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON Equipment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_updated_at BEFORE UPDATE ON Item
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_part_number_updated_at BEFORE UPDATE ON Part_Number_xref
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_item_updated_at BEFORE UPDATE ON Equipment_Item_xref
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_technical_document_updated_at BEFORE UPDATE ON TechnicalDocument
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_spec_updated_at BEFORE UPDATE ON EquipmentSpecification
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_spec_updated_at BEFORE UPDATE ON ItemSpecification
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_app_form_detail_updated_at BEFORE UPDATE ON ApplicationFormDetail
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫建立完成！';
    RAISE NOTICE '資料庫名稱: sbir_equipment_db';
    RAISE NOTICE '版本: V2.0 (重構版)';
    RAISE NOTICE '已建立 10 個資料表（三大主表架構）';
    RAISE NOTICE '- 刪除: BOM（合併到Equipment_Item_xref）';
    RAISE NOTICE '- 刪除: ItemAttribute（合併到Item）';
    RAISE NOTICE '- 重命名: PartNumber → Part_Number_xref';
    RAISE NOTICE '已建立所有索引和約束';
    RAISE NOTICE '已建立自動更新時間戳觸發器';
    RAISE NOTICE '=========================================';
END $$;
