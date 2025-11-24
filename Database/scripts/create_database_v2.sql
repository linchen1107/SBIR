-- ============================================
-- PostgreSQL 資料庫建立腳本
-- 資料庫名稱: sbir_equipment_db_v2
-- 用途: 海軍裝備管理系統
-- 建立日期: 2025-11-19
-- 版本: V3.0 (重構版 - Item自我關聯BOM結構)
-- ============================================

-- 建立資料庫
DROP DATABASE IF EXISTS sbir_equipment_db_v2;
CREATE DATABASE sbir_equipment_db_v2
    WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'Chinese (Traditional)_Taiwan.950'
    LC_CTYPE = 'Chinese (Traditional)_Taiwan.950'
    TEMPLATE = template0;

-- 連接到新資料庫
\c sbir_equipment_db_v2;

-- 啟用 UUID 擴充
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 第一階段：主表建立
-- ============================================

-- 1. 廠商主檔 (Supplier) - 保留不變
CREATE TABLE Supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(20) UNIQUE,
    cage_code VARCHAR(20) UNIQUE,
    supplier_name_en VARCHAR(200),
    supplier_name_zh VARCHAR(100),
    supplier_type VARCHAR(20),
    country_code VARCHAR(10),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Supplier IS '廠商主檔';
COMMENT ON COLUMN Supplier.supplier_id IS '廠商ID（自動編號）';
COMMENT ON COLUMN Supplier.supplier_code IS '廠商來源代號';
COMMENT ON COLUMN Supplier.cage_code IS '廠家登記代號';
COMMENT ON COLUMN Supplier.supplier_name_en IS '廠家製造商（英文）';
COMMENT ON COLUMN Supplier.supplier_name_zh IS '廠商中文名稱';
COMMENT ON COLUMN Supplier.supplier_type IS '廠商類型（製造商/代理商）';
COMMENT ON COLUMN Supplier.country_code IS '國家代碼';

-- 2. 品項主檔 (Item) ⭐ 核心表（UUID PK）
CREATE TABLE Item (
    item_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_code VARCHAR(50) UNIQUE NOT NULL,
    item_name_zh VARCHAR(100),
    item_name_en VARCHAR(200),
    item_type VARCHAR(10) CHECK (item_type IN ('FG', 'SEMI', 'RM')),
    uom VARCHAR(10),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Item IS '品項主檔（統一Equipment與Item）';
COMMENT ON COLUMN Item.item_uuid IS '品項UUID（主鍵）';
COMMENT ON COLUMN Item.item_code IS '統一識別碼（CID或NIIN）';
COMMENT ON COLUMN Item.item_name_zh IS '中文品名';
COMMENT ON COLUMN Item.item_name_en IS '英文品名';
COMMENT ON COLUMN Item.item_type IS '品項類型：FG(成品)/SEMI(半成品)/RM(原物料)';
COMMENT ON COLUMN Item.uom IS '基本計量單位';
COMMENT ON COLUMN Item.status IS '狀態：Active/Inactive';

-- 3. 裝備擴展表 (Item_Equipment_Ext)
CREATE TABLE Item_Equipment_Ext (
    item_uuid UUID PRIMARY KEY,
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
    equipment_serial VARCHAR(50) UNIQUE,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE Item_Equipment_Ext IS '裝備擴展表（FG類型專用）';
COMMENT ON COLUMN Item_Equipment_Ext.item_uuid IS '品項UUID';
COMMENT ON COLUMN Item_Equipment_Ext.equipment_type IS '裝備形式（裝備型號/型式）';
COMMENT ON COLUMN Item_Equipment_Ext.ship_type IS '艦型';
COMMENT ON COLUMN Item_Equipment_Ext.position IS '裝設地點（安裝位置）';
COMMENT ON COLUMN Item_Equipment_Ext.parent_equipment_zh IS '上層適用裝備中文名稱';
COMMENT ON COLUMN Item_Equipment_Ext.parent_equipment_en IS '上層適用裝備英文名稱';
COMMENT ON COLUMN Item_Equipment_Ext.parent_cid IS '上層適用裝備CID';
COMMENT ON COLUMN Item_Equipment_Ext.eswbs_code IS '族群結構碼HSC（ESWBS五碼）';
COMMENT ON COLUMN Item_Equipment_Ext.system_function_name IS '系統功能名稱';
COMMENT ON COLUMN Item_Equipment_Ext.installation_qty IS '同一類型數量（單艦裝置數量）';
COMMENT ON COLUMN Item_Equipment_Ext.total_installation_qty IS '全艦裝置數';
COMMENT ON COLUMN Item_Equipment_Ext.maintenance_level IS '裝備維修等級代碼';
COMMENT ON COLUMN Item_Equipment_Ext.equipment_serial IS '裝備序號（裝備識別編號）';

-- 4. 料件擴展表 (Item_Material_Ext)
CREATE TABLE Item_Material_Ext (
    item_uuid UUID PRIMARY KEY,
    item_id_last5 VARCHAR(5),
    item_name_zh_short VARCHAR(20),
    nsn VARCHAR(20) UNIQUE,
    item_category VARCHAR(10),
    item_code VARCHAR(10),
    fiig VARCHAR(10),
    weapon_system_code VARCHAR(20),
    accounting_code VARCHAR(20),
    issue_unit VARCHAR(10),
    unit_price_usd DECIMAL(10,2) CHECK (unit_price_usd >= 0),
    package_qty INT,
    weight_kg DECIMAL(10,3) CHECK (weight_kg >= 0),
    has_stock BOOLEAN DEFAULT FALSE,
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
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE Item_Material_Ext IS '料件擴展表（SEMI/RM類型專用）';
COMMENT ON COLUMN Item_Material_Ext.item_uuid IS '品項UUID';
COMMENT ON COLUMN Item_Material_Ext.item_id_last5 IS '品項識別碼（後五碼）';
COMMENT ON COLUMN Item_Material_Ext.item_name_zh_short IS '中文品名（9字內）';
COMMENT ON COLUMN Item_Material_Ext.nsn IS 'NSN/國家料號';
COMMENT ON COLUMN Item_Material_Ext.item_category IS '統一組類別';
COMMENT ON COLUMN Item_Material_Ext.item_code IS '品名代號';
COMMENT ON COLUMN Item_Material_Ext.fiig IS 'FIIG';
COMMENT ON COLUMN Item_Material_Ext.weapon_system_code IS '武器系統代號';
COMMENT ON COLUMN Item_Material_Ext.accounting_code IS '會計編號';
COMMENT ON COLUMN Item_Material_Ext.issue_unit IS '撥發單位（EA/SET/LOT等）';
COMMENT ON COLUMN Item_Material_Ext.unit_price_usd IS '美金單價';
COMMENT ON COLUMN Item_Material_Ext.package_qty IS '單位包裝量';
COMMENT ON COLUMN Item_Material_Ext.weight_kg IS '重量（KG）';
COMMENT ON COLUMN Item_Material_Ext.has_stock IS '有無料號';
COMMENT ON COLUMN Item_Material_Ext.storage_life_code IS '存儲壽限代號';
COMMENT ON COLUMN Item_Material_Ext.file_type_code IS '檔別代號';
COMMENT ON COLUMN Item_Material_Ext.file_type_category IS '檔別區分';
COMMENT ON COLUMN Item_Material_Ext.security_code IS '機密性代號（U/C/S等）';
COMMENT ON COLUMN Item_Material_Ext.consumable_code IS '消耗性代號（M/N等）';
COMMENT ON COLUMN Item_Material_Ext.spec_indicator IS '規格指示';
COMMENT ON COLUMN Item_Material_Ext.navy_source IS '海軍軍品來源';
COMMENT ON COLUMN Item_Material_Ext.storage_type IS '儲存型式';
COMMENT ON COLUMN Item_Material_Ext.life_process_code IS '處理代號（壽限處理）';
COMMENT ON COLUMN Item_Material_Ext.manufacturing_capacity IS '製造能量';
COMMENT ON COLUMN Item_Material_Ext.repair_capacity IS '修理能量';
COMMENT ON COLUMN Item_Material_Ext.source_code IS '來源代號';
COMMENT ON COLUMN Item_Material_Ext.project_code IS '專案代號';

-- ============================================
-- 第二階段：BOM 結構建立
-- ============================================

-- 5. BOM 主表
CREATE TABLE BOM (
    bom_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_uuid UUID NOT NULL,
    bom_code VARCHAR(50),
    revision VARCHAR(20),
    effective_from DATE,
    effective_to DATE,
    status VARCHAR(20) DEFAULT 'Draft' CHECK (status IN ('Released', 'Draft')),
    remark TEXT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE BOM IS 'BOM主表（版本控制）';
COMMENT ON COLUMN BOM.bom_uuid IS 'BOM UUID';
COMMENT ON COLUMN BOM.item_uuid IS '成品料號UUID';
COMMENT ON COLUMN BOM.bom_code IS 'BOM編號';
COMMENT ON COLUMN BOM.revision IS '版次';
COMMENT ON COLUMN BOM.effective_from IS '生效日';
COMMENT ON COLUMN BOM.effective_to IS '失效日';
COMMENT ON COLUMN BOM.status IS '狀態：Released/Draft';
COMMENT ON COLUMN BOM.remark IS '備註';

-- 6. BOM 明細行 (BOM_LINE) ⭐ 自我關聯
CREATE TABLE BOM_LINE (
    line_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bom_uuid UUID NOT NULL,
    line_no INT NOT NULL,
    component_item_uuid UUID NOT NULL,
    qty_per DECIMAL(10,4) NOT NULL,
    scrap_type VARCHAR(20),
    scrap_rate DECIMAL(5,4),
    uom VARCHAR(10),
    position VARCHAR(100),
    remark TEXT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bom_uuid) REFERENCES BOM(bom_uuid) ON DELETE CASCADE,
    FOREIGN KEY (component_item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE,
    CONSTRAINT unique_bom_line UNIQUE (bom_uuid, line_no)
);

COMMENT ON TABLE BOM_LINE IS 'BOM明細行（元件清單，Item自我關聯）';
COMMENT ON COLUMN BOM_LINE.line_uuid IS '行UUID';
COMMENT ON COLUMN BOM_LINE.bom_uuid IS 'BOM UUID';
COMMENT ON COLUMN BOM_LINE.line_no IS '行號';
COMMENT ON COLUMN BOM_LINE.component_item_uuid IS '元件料號UUID';
COMMENT ON COLUMN BOM_LINE.qty_per IS '單位用量';
COMMENT ON COLUMN BOM_LINE.scrap_type IS '損耗型態';
COMMENT ON COLUMN BOM_LINE.scrap_rate IS '損耗率';
COMMENT ON COLUMN BOM_LINE.uom IS '用量單位';
COMMENT ON COLUMN BOM_LINE.position IS '裝配位置';
COMMENT ON COLUMN BOM_LINE.remark IS '備註';

-- 7. MRC 品項規格表 ⭐ 新增
CREATE TABLE MRC (
    mrc_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_uuid UUID NOT NULL,
    spec_no INT,
    spec_abbr VARCHAR(20),
    spec_en VARCHAR(200),
    spec_zh VARCHAR(200),
    answer_en VARCHAR(200),
    answer_zh VARCHAR(200),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE MRC IS '品項規格表';
COMMENT ON COLUMN MRC.mrc_uuid IS 'MRC UUID（主鍵）';
COMMENT ON COLUMN MRC.item_uuid IS '品項UUID';
COMMENT ON COLUMN MRC.spec_no IS '規格順序';
COMMENT ON COLUMN MRC.spec_abbr IS '規格資料縮寫';
COMMENT ON COLUMN MRC.spec_en IS '規格資料英文';
COMMENT ON COLUMN MRC.spec_zh IS '規格資料翻譯';
COMMENT ON COLUMN MRC.answer_en IS '英答';
COMMENT ON COLUMN MRC.answer_zh IS '中答';

-- ============================================
-- 第三階段：關聯表建立
-- ============================================

-- 8. 零件號碼關聯檔 (Part_Number_xref)
CREATE TABLE Part_Number_xref (
    part_number_id SERIAL PRIMARY KEY,
    part_number VARCHAR(50),
    item_uuid UUID,
    supplier_id INT,
    obtain_level VARCHAR(10),
    obtain_source VARCHAR(50),
    is_primary BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE SET NULL,
    CONSTRAINT unique_part UNIQUE (part_number, item_uuid, supplier_id)
);

COMMENT ON TABLE Part_Number_xref IS '零件號碼關聯檔';
COMMENT ON COLUMN Part_Number_xref.part_number_id IS '零件號碼ID';
COMMENT ON COLUMN Part_Number_xref.part_number IS '配件號碼（P/N）';
COMMENT ON COLUMN Part_Number_xref.item_uuid IS '品項UUID';
COMMENT ON COLUMN Part_Number_xref.supplier_id IS '廠商ID';
COMMENT ON COLUMN Part_Number_xref.obtain_level IS 'P/N獲得程度';
COMMENT ON COLUMN Part_Number_xref.obtain_source IS 'P/N獲得來源';
COMMENT ON COLUMN Part_Number_xref.is_primary IS '是否為主要零件號';

-- ============================================
-- 第四階段：輔助資料建立
-- ============================================

-- 9. 技術文件檔 (TechnicalDocument)
CREATE TABLE TechnicalDocument (
    document_id SERIAL PRIMARY KEY,
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
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE TechnicalDocument IS '技術文件檔';

-- 10. 品項文件關聯檔 (Item_Document_xref)
CREATE TABLE Item_Document_xref (
    item_uuid UUID,
    document_id INT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (item_uuid, document_id),
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES TechnicalDocument(document_id) ON DELETE CASCADE
);

COMMENT ON TABLE Item_Document_xref IS '品項文件關聯檔';

-- 11. 申編單檔 (ApplicationForm)
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

-- 12. 申編單明細檔 (ApplicationFormDetail)
CREATE TABLE ApplicationFormDetail (
    detail_id SERIAL PRIMARY KEY,
    form_id INT,
    item_seq INT,
    item_uuid UUID,
    document_source VARCHAR(100),
    image_path VARCHAR(500),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (form_id) REFERENCES ApplicationForm(form_id) ON DELETE CASCADE,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE SET NULL
);

COMMENT ON TABLE ApplicationFormDetail IS '申編單明細檔';

-- ============================================
-- 索引建立
-- ============================================

-- Item 索引
CREATE INDEX idx_item_code ON Item(item_code);
CREATE INDEX idx_item_type ON Item(item_type);
CREATE INDEX idx_item_status ON Item(status);

-- 擴展表索引
CREATE INDEX idx_equip_ext_ship_type ON Item_Equipment_Ext(ship_type);
CREATE INDEX idx_equip_ext_eswbs ON Item_Equipment_Ext(eswbs_code);
CREATE INDEX idx_material_ext_nsn ON Item_Material_Ext(nsn);
CREATE INDEX idx_material_ext_category ON Item_Material_Ext(item_category);
CREATE INDEX idx_material_ext_accounting ON Item_Material_Ext(accounting_code);

-- BOM 索引
CREATE INDEX idx_bom_item ON BOM(item_uuid);
CREATE INDEX idx_bom_status ON BOM(status);
CREATE INDEX idx_bom_effective ON BOM(effective_from, effective_to);

-- BOM_LINE 索引
CREATE INDEX idx_bom_line_bom ON BOM_LINE(bom_uuid);
CREATE INDEX idx_bom_line_component ON BOM_LINE(component_item_uuid);

-- MRC 索引
CREATE INDEX idx_mrc_item ON MRC(item_uuid);
CREATE INDEX idx_mrc_abbr ON MRC(spec_abbr);

-- 零件號索引
CREATE INDEX idx_part_number ON Part_Number_xref(part_number);
CREATE INDEX idx_part_item ON Part_Number_xref(item_uuid);
CREATE INDEX idx_part_supplier ON Part_Number_xref(supplier_id);

-- 供應商索引
CREATE INDEX idx_supplier_code ON Supplier(supplier_code);
CREATE INDEX idx_supplier_cage ON Supplier(cage_code);

-- 技術文件索引
CREATE INDEX idx_tech_doc_eswbs ON TechnicalDocument(eswbs_code);

-- 申編單索引
CREATE INDEX idx_app_form_no ON ApplicationForm(form_no);
CREATE INDEX idx_app_detail_form ON ApplicationFormDetail(form_id);
CREATE INDEX idx_app_detail_item ON ApplicationFormDetail(item_uuid);

-- ============================================
-- 建立更新時間戳自動更新函數
-- ============================================

CREATE OR REPLACE FUNCTION update_date_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 為每個有 date_updated 欄位的表格建立觸發器
CREATE TRIGGER update_supplier_date_updated BEFORE UPDATE ON Supplier
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_item_date_updated BEFORE UPDATE ON Item
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_item_equip_ext_date_updated BEFORE UPDATE ON Item_Equipment_Ext
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_item_material_ext_date_updated BEFORE UPDATE ON Item_Material_Ext
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_bom_date_updated BEFORE UPDATE ON BOM
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_bom_line_date_updated BEFORE UPDATE ON BOM_LINE
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_mrc_date_updated BEFORE UPDATE ON MRC
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_part_number_date_updated BEFORE UPDATE ON Part_Number_xref
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_item_document_date_updated BEFORE UPDATE ON Item_Document_xref
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_technical_document_date_updated BEFORE UPDATE ON TechnicalDocument
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_app_form_detail_date_updated BEFORE UPDATE ON ApplicationFormDetail
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫建立完成！';
    RAISE NOTICE '資料庫名稱: sbir_equipment_db_v2';
    RAISE NOTICE '版本: V3.0 (重構版)';
    RAISE NOTICE '已建立 12 個資料表';
    RAISE NOTICE '- Item: 統一品項主表（UUID PK）';
    RAISE NOTICE '- Item_Equipment_Ext: 裝備擴展表';
    RAISE NOTICE '- Item_Material_Ext: 料件擴展表';
    RAISE NOTICE '- BOM: BOM主表（版本控制）';
    RAISE NOTICE '- BOM_LINE: BOM明細（Item自我關聯）';
    RAISE NOTICE '- MRC: 品項規格表（新增）';
    RAISE NOTICE '- 其他輔助表';
    RAISE NOTICE '已建立所有索引和約束';
    RAISE NOTICE '已建立自動更新時間戳觸發器';
    RAISE NOTICE '=========================================';
END $$;
