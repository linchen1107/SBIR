-- =====================================================================
-- 檔案名稱: create_web_app_schema.sql
-- 用途: 建立 web_app schema（裝備管理系統 + Web 應用）
-- 資料庫: sbir_equipment_db_v3
-- Schema: web_app
-- 版本: V3.2
-- 建立日期: 2025-12-26
-- 
-- 說明:
--   此腳本建立裝備管理系統與 Web 應用的所有表格
--   包含 19 個表格（13 個裝備管理表 + 6 個 Web 應用表）
-- =====================================================================

-- 設定客戶端編碼
SET client_encoding = 'UTF8';

-- 建立 web_app schema
CREATE SCHEMA IF NOT EXISTS web_app;

-- 設定搜尋路徑
SET search_path TO web_app, public;

-- =====================================================================
-- 建立觸發器函數：自動更新 date_updated 時間戳
-- =====================================================================

CREATE OR REPLACE FUNCTION web_app.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION web_app.update_timestamp() IS '自動更新 date_updated 欄位的觸發器函數';

-- =====================================================================
-- 裝備管理表（13 個）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. supplier - 廠商主檔
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(20) UNIQUE,
    cage_code VARCHAR(20) UNIQUE,
    supplier_name_en VARCHAR(200) NOT NULL,
    supplier_name_zh VARCHAR(100),
    agent_name VARCHAR(255),
    country_code VARCHAR(10),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE web_app.supplier IS '廠商主檔（供應商/製造商基本資料）';
COMMENT ON COLUMN web_app.supplier.supplier_id IS '廠商 ID（自動編號主鍵）';
COMMENT ON COLUMN web_app.supplier.supplier_code IS '廠商來源代號';
COMMENT ON COLUMN web_app.supplier.cage_code IS '廠家登記代號（CAGE CODE）';
COMMENT ON COLUMN web_app.supplier.supplier_name_en IS '廠家製造商（英文）';
COMMENT ON COLUMN web_app.supplier.supplier_name_zh IS '廠商中文名稱';
COMMENT ON COLUMN web_app.supplier.agent_name IS '代理商名稱（製造商填 NULL，代理商填入名稱）';
COMMENT ON COLUMN web_app.supplier.country_code IS '國家代碼';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_supplier_code ON web_app.supplier(supplier_code);
CREATE INDEX IF NOT EXISTS idx_supplier_cage ON web_app.supplier(cage_code);

-- 建立觸發器
CREATE TRIGGER trigger_supplier_update_timestamp
    BEFORE UPDATE ON web_app.supplier
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 2. item - 品項主檔（核心表）
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.item (
    item_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_code VARCHAR(50) UNIQUE NOT NULL,
    item_name_zh VARCHAR(100) NOT NULL,
    item_name_en VARCHAR(200) NOT NULL,
    item_type VARCHAR(10) NOT NULL CHECK (item_type IN ('FG', 'SEMI', 'RM')),
    uom VARCHAR(10),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE web_app.item IS '品項主檔（統一管理所有品項：成品/半成品/原物料）';
COMMENT ON COLUMN web_app.item.item_uuid IS '品項 UUID（主鍵）';
COMMENT ON COLUMN web_app.item.item_code IS '統一識別碼（CID 或 NIIN）';
COMMENT ON COLUMN web_app.item.item_name_zh IS '中文品名';
COMMENT ON COLUMN web_app.item.item_name_en IS '英文品名';
COMMENT ON COLUMN web_app.item.item_type IS '品項類型：FG(成品)/SEMI(半成品)/RM(原物料)';
COMMENT ON COLUMN web_app.item.uom IS '基本計量單位（EA/SET/LOT 等）';
COMMENT ON COLUMN web_app.item.status IS '狀態：Active/Inactive';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_item_code ON web_app.item(item_code);
CREATE INDEX IF NOT EXISTS idx_item_type ON web_app.item(item_type);
CREATE INDEX IF NOT EXISTS idx_item_status ON web_app.item(status);

-- 建立觸發器
CREATE TRIGGER trigger_item_update_timestamp
    BEFORE UPDATE ON web_app.item
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 3. item_equipment_ext - 裝備擴展表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.item_equipment_ext (
    item_uuid UUID PRIMARY KEY,
    equipment_type VARCHAR(50),
    ship_type VARCHAR(50),
    usage_location VARCHAR(100),
    parent_equipment_zh VARCHAR(100),
    parent_equipment_en VARCHAR(200),
    parent_cid VARCHAR(50),
    eswbs_code VARCHAR(20),
    system_function_name VARCHAR(200),
    installation_qty INTEGER,
    total_installation_qty INTEGER,
    maintenance_level VARCHAR(10),
    equipment_serial VARCHAR(50) UNIQUE,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_equipment_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.item_equipment_ext IS '裝備擴展表（FG 類型專用欄位）';
COMMENT ON COLUMN web_app.item_equipment_ext.item_uuid IS '品項 UUID（主鍵 + 外鍵）';
COMMENT ON COLUMN web_app.item_equipment_ext.equipment_type IS '裝備形式（裝備型號/型式）';
COMMENT ON COLUMN web_app.item_equipment_ext.ship_type IS '艦型';
COMMENT ON COLUMN web_app.item_equipment_ext.usage_location IS '裝設地點（安裝位置）';
COMMENT ON COLUMN web_app.item_equipment_ext.parent_equipment_zh IS '上層適用裝備中文名稱';
COMMENT ON COLUMN web_app.item_equipment_ext.parent_equipment_en IS '上層適用裝備英文名稱';
COMMENT ON COLUMN web_app.item_equipment_ext.parent_cid IS '上層適用裝備 CID';
COMMENT ON COLUMN web_app.item_equipment_ext.eswbs_code IS '族群結構碼 HSC（ESWBS 五碼）';
COMMENT ON COLUMN web_app.item_equipment_ext.system_function_name IS '系統功能名稱';
COMMENT ON COLUMN web_app.item_equipment_ext.installation_qty IS '同一類型數量（單艦裝置數量）';
COMMENT ON COLUMN web_app.item_equipment_ext.total_installation_qty IS '全艦裝置數';
COMMENT ON COLUMN web_app.item_equipment_ext.maintenance_level IS '裝備維修等級代碼';
COMMENT ON COLUMN web_app.item_equipment_ext.equipment_serial IS '裝備序號（裝備識別編號）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_equip_ext_ship_type ON web_app.item_equipment_ext(ship_type);
CREATE INDEX IF NOT EXISTS idx_equip_ext_eswbs ON web_app.item_equipment_ext(eswbs_code);

-- 建立觸發器
CREATE TRIGGER trigger_item_equipment_ext_update_timestamp
    BEFORE UPDATE ON web_app.item_equipment_ext
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 4. item_material_ext - 料件擴展表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.item_material_ext (
    item_uuid UUID PRIMARY KEY,
    item_id_last5 VARCHAR(5),
    item_name_zh_short VARCHAR(20),
    nsn VARCHAR(20) UNIQUE,
    category_code VARCHAR(10),
    item_code VARCHAR(10),
    fiig VARCHAR(10),
    weapon_system_code VARCHAR(20),
    accounting_unit_code VARCHAR(20),
    issue_unit VARCHAR(10),
    unit_price NUMERIC(10,2),
    unit_pack_quantity INTEGER,
    weight_kg NUMERIC(10,3),
    has_stock BOOLEAN,
    storage_life_months VARCHAR(10),
    file_type_code VARCHAR(10),
    file_type_category VARCHAR(10),
    secrecy_code VARCHAR(10),
    expendability_code VARCHAR(10),
    spec_indicator VARCHAR(10),
    navy_source VARCHAR(50),
    storage_type_code VARCHAR(20),
    storage_life_action_code VARCHAR(10),
    manufacturability_code VARCHAR(10),
    repairability_code VARCHAR(10),
    source_code VARCHAR(10),
    project_code VARCHAR(20),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    inc_code VARCHAR(20),
    fiig_code VARCHAR(20),
    CONSTRAINT fk_item_material_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.item_material_ext IS '料件擴展表（SEMI/RM 類型專用欄位）';
COMMENT ON COLUMN web_app.item_material_ext.item_uuid IS '品項 UUID（主鍵 + 外鍵）';
COMMENT ON COLUMN web_app.item_material_ext.item_id_last5 IS '品項識別碼（後五碼）';
COMMENT ON COLUMN web_app.item_material_ext.item_name_zh_short IS '中文品名（9 字內）';
COMMENT ON COLUMN web_app.item_material_ext.nsn IS 'NSN/國家料號';
COMMENT ON COLUMN web_app.item_material_ext.category_code IS '統一組類別';
COMMENT ON COLUMN web_app.item_material_ext.item_code IS '品名代號（INC 品名代號）';
COMMENT ON COLUMN web_app.item_material_ext.fiig IS 'FIIG（聯邦品項識別指南）';
COMMENT ON COLUMN web_app.item_material_ext.weapon_system_code IS '武器系統代號';
COMMENT ON COLUMN web_app.item_material_ext.accounting_unit_code IS '會計編號';
COMMENT ON COLUMN web_app.item_material_ext.issue_unit IS '撥發單位（EA/SET/LOT 等）';
COMMENT ON COLUMN web_app.item_material_ext.unit_price IS '美金單價';
COMMENT ON COLUMN web_app.item_material_ext.unit_pack_quantity IS '單位包裝量';
COMMENT ON COLUMN web_app.item_material_ext.weight_kg IS '重量（KG）';
COMMENT ON COLUMN web_app.item_material_ext.has_stock IS '有無料號';
COMMENT ON COLUMN web_app.item_material_ext.storage_life_months IS '存儲壽限代號';
COMMENT ON COLUMN web_app.item_material_ext.file_type_code IS '檔別代號';
COMMENT ON COLUMN web_app.item_material_ext.file_type_category IS '檔別區分';
COMMENT ON COLUMN web_app.item_material_ext.secrecy_code IS '機密性代號（U/C/S 等）';
COMMENT ON COLUMN web_app.item_material_ext.expendability_code IS '消耗性代號（M/N 等）';
COMMENT ON COLUMN web_app.item_material_ext.spec_indicator IS '規格指示';
COMMENT ON COLUMN web_app.item_material_ext.navy_source IS '海軍軍品來源';
COMMENT ON COLUMN web_app.item_material_ext.storage_type_code IS '儲存型式';
COMMENT ON COLUMN web_app.item_material_ext.storage_life_action_code IS '處理代號（壽限處理）';
COMMENT ON COLUMN web_app.item_material_ext.manufacturability_code IS '製造能量';
COMMENT ON COLUMN web_app.item_material_ext.repairability_code IS '修理能量';
COMMENT ON COLUMN web_app.item_material_ext.source_code IS '來源代號';
COMMENT ON COLUMN web_app.item_material_ext.project_code IS '專案代號';
COMMENT ON COLUMN web_app.item_material_ext.inc_code IS 'INC 代碼（與 public.inc 表關聯）';
COMMENT ON COLUMN web_app.item_material_ext.fiig_code IS 'FIIG 代碼（與 public.fiig 表關聯）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_material_ext_nsn ON web_app.item_material_ext(nsn);
CREATE INDEX IF NOT EXISTS idx_material_ext_category_code ON web_app.item_material_ext(category_code);
CREATE INDEX IF NOT EXISTS idx_material_ext_accounting_unit_code ON web_app.item_material_ext(accounting_unit_code);

-- 建立觸發器
CREATE TRIGGER trigger_item_material_ext_update_timestamp
    BEFORE UPDATE ON web_app.item_material_ext
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 5. bom - BOM 主表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.bom (
    bom_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_uuid UUID NOT NULL,
    bom_code VARCHAR(50),
    revision VARCHAR(20),
    effective_from DATE,
    effective_to DATE,
    status VARCHAR(20) CHECK (status IN ('Released', 'Draft')),
    remark TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bom_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.bom IS 'BOM 主表（BOM 版本控制）';
COMMENT ON COLUMN web_app.bom.bom_uuid IS 'BOM UUID（主鍵）';
COMMENT ON COLUMN web_app.bom.item_uuid IS '成品料號 UUID（外鍵至 item 表）';
COMMENT ON COLUMN web_app.bom.bom_code IS 'BOM 編號';
COMMENT ON COLUMN web_app.bom.revision IS '版次（1.0, 1.1...）';
COMMENT ON COLUMN web_app.bom.effective_from IS '生效日';
COMMENT ON COLUMN web_app.bom.effective_to IS '失效日';
COMMENT ON COLUMN web_app.bom.status IS '狀態：Released/Draft';
COMMENT ON COLUMN web_app.bom.remark IS '備註';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_bom_item ON web_app.bom(item_uuid);
CREATE INDEX IF NOT EXISTS idx_bom_status ON web_app.bom(status);
CREATE INDEX IF NOT EXISTS idx_bom_effective ON web_app.bom(effective_from, effective_to);

-- 建立觸發器
CREATE TRIGGER trigger_bom_update_timestamp
    BEFORE UPDATE ON web_app.bom
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 6. bom_line - BOM 明細行
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.bom_line (
    line_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bom_uuid UUID NOT NULL,
    line_no VARCHAR(50) NOT NULL,
    component_item_uuid UUID NOT NULL,
    qty_per NUMERIC(10,4) NOT NULL,
    scrap_type VARCHAR(20),
    scrap_rate NUMERIC(5,4),
    uom VARCHAR(10),
    position VARCHAR(100),
    remark TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bom_line_bom FOREIGN KEY (bom_uuid) REFERENCES web_app.bom(bom_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_bom_line_component FOREIGN KEY (component_item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE,
    CONSTRAINT unique_bom_line UNIQUE (bom_uuid, line_no)
);

COMMENT ON TABLE web_app.bom_line IS 'BOM 明細行（item 自我關聯 - 元件清單）';
COMMENT ON COLUMN web_app.bom_line.line_uuid IS '行 UUID（主鍵）';
COMMENT ON COLUMN web_app.bom_line.bom_uuid IS 'BOM UUID（外鍵）';
COMMENT ON COLUMN web_app.bom_line.line_no IS '行號（排序用）';
COMMENT ON COLUMN web_app.bom_line.component_item_uuid IS '元件料號 UUID（外鍵至 item 表）';
COMMENT ON COLUMN web_app.bom_line.qty_per IS '單位用量（每單位成品需要數量）';
COMMENT ON COLUMN web_app.bom_line.scrap_type IS '損耗型態';
COMMENT ON COLUMN web_app.bom_line.scrap_rate IS '損耗率';
COMMENT ON COLUMN web_app.bom_line.uom IS '用量單位（預設跟元件 UOM 一致）';
COMMENT ON COLUMN web_app.bom_line.position IS '裝配位置/站別';
COMMENT ON COLUMN web_app.bom_line.remark IS '備註';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_bom_line_bom ON web_app.bom_line(bom_uuid);
CREATE INDEX IF NOT EXISTS idx_bom_line_component ON web_app.bom_line(component_item_uuid);

-- 建立觸發器
CREATE TRIGGER trigger_bom_line_update_timestamp
    BEFORE UPDATE ON web_app.bom_line
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 7. mrc - 品項規格表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.mrc (
    mrc_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_uuid UUID NOT NULL,
    spec_no INTEGER,
    spec_abbr VARCHAR(20),
    spec_en VARCHAR(200),
    spec_zh VARCHAR(200),
    answer_en VARCHAR(200),
    answer_zh VARCHAR(200),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mrc_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.mrc IS '品項規格表（記錄品項的規格資料）';
COMMENT ON COLUMN web_app.mrc.mrc_uuid IS 'MRC UUID（主鍵）';
COMMENT ON COLUMN web_app.mrc.item_uuid IS '品項 UUID（外鍵）';
COMMENT ON COLUMN web_app.mrc.spec_no IS '規格順序';
COMMENT ON COLUMN web_app.mrc.spec_abbr IS '規格資料縮寫';
COMMENT ON COLUMN web_app.mrc.spec_en IS '規格資料英文';
COMMENT ON COLUMN web_app.mrc.spec_zh IS '規格資料翻譯';
COMMENT ON COLUMN web_app.mrc.answer_en IS '英答';
COMMENT ON COLUMN web_app.mrc.answer_zh IS '中答';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_mrc_item ON web_app.mrc(item_uuid);
CREATE INDEX IF NOT EXISTS idx_mrc_abbr ON web_app.mrc(spec_abbr);

-- 建立觸發器
CREATE TRIGGER trigger_mrc_update_timestamp
    BEFORE UPDATE ON web_app.mrc
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 8. item_number_xref - 零件號碼關聯檔
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.item_number_xref (
    part_number_id SERIAL PRIMARY KEY,
    part_number_reference VARCHAR(50) NOT NULL,
    item_uuid UUID NOT NULL,
    supplier_id INTEGER,
    pn_acquisition_level VARCHAR(10),
    pn_acquisition_source VARCHAR(50),
    is_primary BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_part_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_part_supplier FOREIGN KEY (supplier_id) REFERENCES web_app.supplier(supplier_id) ON DELETE SET NULL,
    CONSTRAINT unique_part UNIQUE (part_number_reference, item_uuid, supplier_id)
);

COMMENT ON TABLE web_app.item_number_xref IS '零件號碼關聯檔（品項-零件號-廠商的多對多關聯）';
COMMENT ON COLUMN web_app.item_number_xref.part_number_id IS '零件號碼 ID（自動編號主鍵）';
COMMENT ON COLUMN web_app.item_number_xref.part_number_reference IS '配件號碼（P/N）';
COMMENT ON COLUMN web_app.item_number_xref.item_uuid IS '品項 UUID（外鍵）';
COMMENT ON COLUMN web_app.item_number_xref.supplier_id IS '廠商 ID（外鍵）';
COMMENT ON COLUMN web_app.item_number_xref.pn_acquisition_level IS 'P/N 獲得程度（取得難易度）';
COMMENT ON COLUMN web_app.item_number_xref.pn_acquisition_source IS 'P/N 獲得來源（取得管道）';
COMMENT ON COLUMN web_app.item_number_xref.is_primary IS '是否為主要零件號';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_part_item ON web_app.item_number_xref(item_uuid);
CREATE INDEX IF NOT EXISTS idx_part_supplier ON web_app.item_number_xref(supplier_id);
CREATE INDEX IF NOT EXISTS idx_part_number ON web_app.item_number_xref(part_number_reference);

-- 建立觸發器
CREATE TRIGGER trigger_item_number_xref_update_timestamp
    BEFORE UPDATE ON web_app.item_number_xref
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 9. technicaldocument - 技術文件檔
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.technicaldocument (
    document_id SERIAL PRIMARY KEY,
    document_reference VARCHAR(200) NOT NULL,
    document_version VARCHAR(20),
    shipyard_drawing_no VARCHAR(50),
    design_drawing_no VARCHAR(50),
    document_type VARCHAR(20),
    document_category VARCHAR(20),
    language VARCHAR(10),
    security_level VARCHAR(10),
    eswbs_code VARCHAR(20),
    accounting_code VARCHAR(20),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE web_app.technicaldocument IS '技術文件檔（管理技術文件與圖面資料）';
COMMENT ON COLUMN web_app.technicaldocument.document_id IS '文件 ID（自動編號主鍵）';
COMMENT ON COLUMN web_app.technicaldocument.document_reference IS '圖名/書名';
COMMENT ON COLUMN web_app.technicaldocument.document_version IS '版次';
COMMENT ON COLUMN web_app.technicaldocument.shipyard_drawing_no IS '船廠圖號';
COMMENT ON COLUMN web_app.technicaldocument.design_drawing_no IS '設計圖號';
COMMENT ON COLUMN web_app.technicaldocument.document_type IS '資料類型';
COMMENT ON COLUMN web_app.technicaldocument.document_category IS '資料類別';
COMMENT ON COLUMN web_app.technicaldocument.language IS '語言（中文/英文）';
COMMENT ON COLUMN web_app.technicaldocument.security_level IS '機密等級';
COMMENT ON COLUMN web_app.technicaldocument.eswbs_code IS 'ESWBS（五碼）裝備分類碼';
COMMENT ON COLUMN web_app.technicaldocument.accounting_code IS '會計編號';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_tech_doc_eswbs ON web_app.technicaldocument(eswbs_code);

-- 建立觸發器
CREATE TRIGGER trigger_technicaldocument_update_timestamp
    BEFORE UPDATE ON web_app.technicaldocument
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 10. item_document_xref - 品項文件關聯檔
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.item_document_xref (
    item_uuid UUID NOT NULL,
    document_id INTEGER NOT NULL,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (item_uuid, document_id),
    CONSTRAINT fk_item_doc_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_item_doc_document FOREIGN KEY (document_id) REFERENCES web_app.technicaldocument(document_id) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.item_document_xref IS '品項文件關聯檔（品項-技術文件多對多關聯）';
COMMENT ON COLUMN web_app.item_document_xref.item_uuid IS '品項 UUID（複合主鍵 + 外鍵）';
COMMENT ON COLUMN web_app.item_document_xref.document_id IS '文件 ID（複合主鍵 + 外鍵）';

-- 建立觸發器
CREATE TRIGGER trigger_item_document_xref_update_timestamp
    BEFORE UPDATE ON web_app.item_document_xref
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 11. application_suppliercode - 廠商代號申請表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.application_suppliercode (
    application_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_no VARCHAR(50) UNIQUE NOT NULL,
    applicant VARCHAR(50),
    supplier_id INTEGER,
    supplier_name VARCHAR(200),
    address VARCHAR(200),
    phone VARCHAR(50),
    business_items VARCHAR(200),
    supplier_code VARCHAR(20),
    equipment_name VARCHAR(200),
    custom_fields JSONB,
    status VARCHAR(20),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_supplier_code_app_supplier FOREIGN KEY (supplier_id) REFERENCES web_app.supplier(supplier_id) ON DELETE SET NULL
);

COMMENT ON TABLE web_app.application_suppliercode IS '廠商代號申請表';
COMMENT ON COLUMN web_app.application_suppliercode.application_uuid IS '申請單 UUID（主鍵）';
COMMENT ON COLUMN web_app.application_suppliercode.form_no IS '流水號';
COMMENT ON COLUMN web_app.application_suppliercode.applicant IS '申請人';
COMMENT ON COLUMN web_app.application_suppliercode.supplier_id IS '廠商 ID（外鍵）';
COMMENT ON COLUMN web_app.application_suppliercode.supplier_name IS '廠商名稱';
COMMENT ON COLUMN web_app.application_suppliercode.address IS '地址';
COMMENT ON COLUMN web_app.application_suppliercode.phone IS '電話';
COMMENT ON COLUMN web_app.application_suppliercode.business_items IS '營業項目';
COMMENT ON COLUMN web_app.application_suppliercode.supplier_code IS '廠家代號（申請或現有代號）';
COMMENT ON COLUMN web_app.application_suppliercode.equipment_name IS '相關裝備名稱';
COMMENT ON COLUMN web_app.application_suppliercode.custom_fields IS '自定義欄位（JSONB）';
COMMENT ON COLUMN web_app.application_suppliercode.status IS '狀態（Draft/Submitted 等）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_supplier_app_form_no ON web_app.application_suppliercode(form_no);

-- 建立觸發器
CREATE TRIGGER trigger_application_suppliercode_update_timestamp
    BEFORE UPDATE ON web_app.application_suppliercode
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 12. cidapplication - CID 申請單
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.cidapplication (
    application_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_no VARCHAR(50) UNIQUE NOT NULL,
    applicant VARCHAR(50),
    item_uuid UUID,
    suggested_prefix VARCHAR(2),
    approved_cid VARCHAR(50),
    equipment_name_zh VARCHAR(100),
    equipment_name_en VARCHAR(200),
    supplier_code VARCHAR(20),
    part_number VARCHAR(50),
    status VARCHAR(20),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cid_app_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE SET NULL
);

COMMENT ON TABLE web_app.cidapplication IS 'CID 申請單';
COMMENT ON COLUMN web_app.cidapplication.application_uuid IS '申請單 UUID（主鍵）';
COMMENT ON COLUMN web_app.cidapplication.form_no IS '流水號';
COMMENT ON COLUMN web_app.cidapplication.applicant IS '申請人';
COMMENT ON COLUMN web_app.cidapplication.item_uuid IS '品項 UUID（外鍵，可選）';
COMMENT ON COLUMN web_app.cidapplication.suggested_prefix IS '建議前兩碼';
COMMENT ON COLUMN web_app.cidapplication.approved_cid IS '核定 CID';
COMMENT ON COLUMN web_app.cidapplication.equipment_name_zh IS '裝備中文名稱';
COMMENT ON COLUMN web_app.cidapplication.equipment_name_en IS '裝備英文名稱';
COMMENT ON COLUMN web_app.cidapplication.supplier_code IS '相關廠商代號';
COMMENT ON COLUMN web_app.cidapplication.part_number IS '配件號碼（P/N）';
COMMENT ON COLUMN web_app.cidapplication.status IS '狀態（Draft/Submitted 等）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_cid_app_form_no ON web_app.cidapplication(form_no);

-- 建立觸發器
CREATE TRIGGER trigger_cidapplication_update_timestamp
    BEFORE UPDATE ON web_app.cidapplication
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 13. item_emu3000_maintenance_ext - EMU3000 維修物料擴展表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.item_emu3000_maintenance_ext (
    ext_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_uuid UUID,
    part VARCHAR(255),
    quantity NUMERIC(10,4),
    unit VARCHAR(50),
    name VARCHAR(255),
    wec VARCHAR(100),
    notes TEXT,
    kit_no VARCHAR(100),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_emu3000_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.item_emu3000_maintenance_ext IS 'EMU3000 維修物料清單專屬欄位';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.ext_uuid IS '擴展表 UUID（主鍵）';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.item_uuid IS '品項 UUID（外鍵）';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.part IS '項次/行號（原始資料 Item No/Part）';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.quantity IS '數量';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.unit IS '單位（Pce, SET 等）';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.name IS '品名（原始品名）';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.wec IS 'WEC 編碼（WEC Code）';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.notes IS '備註說明';
COMMENT ON COLUMN web_app.item_emu3000_maintenance_ext.kit_no IS '套件編號（Kit Number）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_emu3000_item_uuid ON web_app.item_emu3000_maintenance_ext(item_uuid);

-- 建立觸發器
CREATE TRIGGER trigger_item_emu3000_update_timestamp
    BEFORE UPDATE ON web_app.item_emu3000_maintenance_ext
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- =====================================================================
-- Web 應用表（6 個）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 14. User - 使用者管理
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app."User" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    english_code VARCHAR(10),
    full_name VARCHAR(100),
    department VARCHAR(100),
    position VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP WITHOUT TIME ZONE,
    last_login_at TIMESTAMP WITHOUT TIME ZONE,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP WITHOUT TIME ZONE,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE web_app."User" IS '使用者管理（系統使用者帳號管理）';
COMMENT ON COLUMN web_app."User".id IS '使用者 UUID（主鍵）';
COMMENT ON COLUMN web_app."User".username IS '使用者帳號';
COMMENT ON COLUMN web_app."User".email IS '電子郵件';
COMMENT ON COLUMN web_app."User".password_hash IS '密碼雜湊值';
COMMENT ON COLUMN web_app."User".english_code IS '英文代碼';
COMMENT ON COLUMN web_app."User".full_name IS '全名';
COMMENT ON COLUMN web_app."User".department IS '部門';
COMMENT ON COLUMN web_app."User".position IS '職位';
COMMENT ON COLUMN web_app."User".phone IS '電話';
COMMENT ON COLUMN web_app."User".role IS '角色權限（admin/user/viewer 等）';
COMMENT ON COLUMN web_app."User".is_active IS '帳號啟用狀態';
COMMENT ON COLUMN web_app."User".is_verified IS '電子郵件驗證狀態';
COMMENT ON COLUMN web_app."User".email_verified_at IS '電子郵件驗證時間';
COMMENT ON COLUMN web_app."User".last_login_at IS '最後登入時間';
COMMENT ON COLUMN web_app."User".failed_login_attempts IS '登入失敗次數';
COMMENT ON COLUMN web_app."User".locked_until IS '帳號鎖定至';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_user_email ON web_app."User"(email);
CREATE INDEX IF NOT EXISTS idx_user_username ON web_app."User"(username);
CREATE INDEX IF NOT EXISTS idx_user_role ON web_app."User"(role);
CREATE INDEX IF NOT EXISTS idx_user_is_active ON web_app."User"(is_active);

-- 建立觸發器
CREATE TRIGGER trigger_user_update_timestamp
    BEFORE UPDATE ON web_app."User"
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 15. application - 申編單主表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.application (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    item_uuid UUID,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITHOUT TIME ZONE,
    form_serial_number VARCHAR(50),
    system_code VARCHAR(100),
    mrc_data JSON,
    applicant_unit VARCHAR(100),
    contact_info VARCHAR(100),
    apply_date DATE,
    official_nsn_stamp VARCHAR(10),
    official_nsn_final VARCHAR(20),
    nsn_filled_at TIMESTAMP WITHOUT TIME ZONE,
    closed_at TIMESTAMP WITHOUT TIME ZONE,
    status VARCHAR(50),
    sub_status VARCHAR(50),
    nsn_filled_by UUID,
    closed_by UUID,
    CONSTRAINT fk_app_user FOREIGN KEY (user_id) REFERENCES web_app."User"(id) ON DELETE SET NULL,
    CONSTRAINT fk_app_item FOREIGN KEY (item_uuid) REFERENCES web_app.item(item_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_app_nsn_filled_by FOREIGN KEY (nsn_filled_by) REFERENCES web_app."User"(id) ON DELETE SET NULL,
    CONSTRAINT fk_app_closed_by FOREIGN KEY (closed_by) REFERENCES web_app."User"(id) ON DELETE SET NULL
);

COMMENT ON TABLE web_app.application IS '申編單主表（申編單核心資料管理）';
COMMENT ON COLUMN web_app.application.id IS '申編單 UUID（主鍵）';
COMMENT ON COLUMN web_app.application.user_id IS '申請人（外鍵至 User 表）';
COMMENT ON COLUMN web_app.application.item_uuid IS '關聯品項 UUID（外鍵至 item 表）';
COMMENT ON COLUMN web_app.application.deleted_at IS '軟刪除時間戳';
COMMENT ON COLUMN web_app.application.form_serial_number IS '表單序號（申編單編號）';
COMMENT ON COLUMN web_app.application.system_code IS '系統代碼';
COMMENT ON COLUMN web_app.application.mrc_data IS 'MRC 資料（JSON 格式）';
COMMENT ON COLUMN web_app.application.applicant_unit IS '申請單位';
COMMENT ON COLUMN web_app.application.contact_info IS '聯絡資訊';
COMMENT ON COLUMN web_app.application.apply_date IS '申請日期';
COMMENT ON COLUMN web_app.application.official_nsn_stamp IS '正式 NSN 印章';
COMMENT ON COLUMN web_app.application.official_nsn_final IS '最終正式 NSN';
COMMENT ON COLUMN web_app.application.nsn_filled_at IS 'NSN 填寫時間';
COMMENT ON COLUMN web_app.application.closed_at IS '結案時間';
COMMENT ON COLUMN web_app.application.status IS '申編單狀態（pending/approved 等）';
COMMENT ON COLUMN web_app.application.sub_status IS '申編單子狀態';
COMMENT ON COLUMN web_app.application.nsn_filled_by IS 'NSN 填寫者（外鍵至 User 表）';
COMMENT ON COLUMN web_app.application.closed_by IS '結案者（外鍵至 User 表）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_app_user_id ON web_app.application(user_id);
CREATE INDEX IF NOT EXISTS idx_app_item_uuid ON web_app.application(item_uuid);
CREATE INDEX IF NOT EXISTS idx_app_status ON web_app.application(status);
CREATE INDEX IF NOT EXISTS idx_app_date_created ON web_app.application(date_created);
CREATE INDEX IF NOT EXISTS idx_app_deleted_at ON web_app.application(deleted_at) WHERE deleted_at IS NULL;

-- 建立觸發器
CREATE TRIGGER trigger_application_update_timestamp
    BEFORE UPDATE ON web_app.application
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 16. applicationattachment - 附件管理
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.applicationattachment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL,
    user_id UUID,
    file_data BYTEA,
    filename VARCHAR(255),
    original_filename VARCHAR(255),
    mimetype VARCHAR(100),
    file_type VARCHAR(20),
    page_selection VARCHAR(200),
    sort_order INTEGER,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attachment_app FOREIGN KEY (application_id) REFERENCES web_app.application(id) ON DELETE CASCADE,
    CONSTRAINT fk_attachment_user FOREIGN KEY (user_id) REFERENCES web_app."User"(id) ON DELETE SET NULL
);

COMMENT ON TABLE web_app.applicationattachment IS '附件管理（申編單附件 - BYTEA 儲存）';
COMMENT ON COLUMN web_app.applicationattachment.id IS '附件 UUID（主鍵）';
COMMENT ON COLUMN web_app.applicationattachment.application_id IS '申編單 ID（外鍵）';
COMMENT ON COLUMN web_app.applicationattachment.user_id IS '上傳者（外鍵）';
COMMENT ON COLUMN web_app.applicationattachment.file_data IS '檔案二進制資料（BYTEA）';
COMMENT ON COLUMN web_app.applicationattachment.filename IS '儲存檔名（系統儲存檔名）';
COMMENT ON COLUMN web_app.applicationattachment.original_filename IS '原始檔名（使用者上傳檔名）';
COMMENT ON COLUMN web_app.applicationattachment.mimetype IS 'MIME 類型';
COMMENT ON COLUMN web_app.applicationattachment.file_type IS '檔案類型（PDF/PNG/JPG 等）';
COMMENT ON COLUMN web_app.applicationattachment.page_selection IS '頁面選擇（PDF 多頁時選擇）';
COMMENT ON COLUMN web_app.applicationattachment.sort_order IS '排序順序';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_attachment_app_id ON web_app.applicationattachment(application_id);
CREATE INDEX IF NOT EXISTS idx_attachment_user_id ON web_app.applicationattachment(user_id);
CREATE INDEX IF NOT EXISTS idx_attachment_type ON web_app.applicationattachment(file_type);

-- 建立觸發器
CREATE TRIGGER trigger_applicationattachment_update_timestamp
    BEFORE UPDATE ON web_app.applicationattachment
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- ---------------------------------------------------------------------
-- 17. usersession - 工作階段管理
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.usersession (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id UUID NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    remember_me BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITHOUT TIME ZONE,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES web_app."User"(id) ON DELETE CASCADE
);

COMMENT ON TABLE web_app.usersession IS '工作階段管理（使用者登入 Session 管理）';
COMMENT ON COLUMN web_app.usersession.session_id IS 'Session ID（主鍵）';
COMMENT ON COLUMN web_app.usersession.user_id IS '使用者 ID（外鍵）';
COMMENT ON COLUMN web_app.usersession.ip_address IS 'IP 位址（登入 IP）';
COMMENT ON COLUMN web_app.usersession.user_agent IS '使用者代理字串（瀏覽器 UA）';
COMMENT ON COLUMN web_app.usersession.is_active IS '是否啟用（Session 是否有效）';
COMMENT ON COLUMN web_app.usersession.remember_me IS '記住我功能';
COMMENT ON COLUMN web_app.usersession.expires_at IS 'Session 過期時間';
COMMENT ON COLUMN web_app.usersession.last_activity_at IS '最後活動時間';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_session_user_id ON web_app.usersession(user_id);
CREATE INDEX IF NOT EXISTS idx_session_is_active ON web_app.usersession(is_active);
CREATE INDEX IF NOT EXISTS idx_session_expires_at ON web_app.usersession(expires_at);

-- ---------------------------------------------------------------------
-- 18. applicationlog - 應用程式日誌
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.applicationlog (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    level VARCHAR(10),
    logger VARCHAR(100),
    message TEXT,
    request_id VARCHAR(36),
    method VARCHAR(10),
    path VARCHAR(500),
    status_code INTEGER,
    elapsed_time_ms NUMERIC(10,2),
    user_id UUID,
    remote_addr INET,
    user_agent TEXT,
    module VARCHAR(100),
    function VARCHAR(100),
    line INTEGER,
    exception_type VARCHAR(100),
    exception_message TEXT,
    exception_traceback JSONB,
    extra_fields JSONB,
    created_date DATE DEFAULT CURRENT_DATE
);

COMMENT ON TABLE web_app.applicationlog IS '應用程式日誌（應用程式運行日誌）';
COMMENT ON COLUMN web_app.applicationlog.log_id IS '日誌 UUID（主鍵）';
COMMENT ON COLUMN web_app.applicationlog.timestamp IS '日誌時間戳（TIMESTAMPTZ 含時區）';
COMMENT ON COLUMN web_app.applicationlog.level IS '日誌等級（DEBUG/INFO/WARNING/ERROR）';
COMMENT ON COLUMN web_app.applicationlog.logger IS '日誌記錄器名稱';
COMMENT ON COLUMN web_app.applicationlog.message IS '日誌訊息';
COMMENT ON COLUMN web_app.applicationlog.request_id IS '請求 ID（請求追蹤 ID）';
COMMENT ON COLUMN web_app.applicationlog.method IS 'HTTP 方法（GET/POST/PUT/DELETE 等）';
COMMENT ON COLUMN web_app.applicationlog.path IS '請求路徑（API 路徑）';
COMMENT ON COLUMN web_app.applicationlog.status_code IS 'HTTP 狀態碼（200/404/500 等）';
COMMENT ON COLUMN web_app.applicationlog.elapsed_time_ms IS '請求處理時間（毫秒）';
COMMENT ON COLUMN web_app.applicationlog.user_id IS '使用者 ID（相關使用者）';
COMMENT ON COLUMN web_app.applicationlog.remote_addr IS '遠端 IP 位址（客戶端 IP）';
COMMENT ON COLUMN web_app.applicationlog.user_agent IS '使用者代理字串（瀏覽器 UA）';
COMMENT ON COLUMN web_app.applicationlog.module IS '模組名稱（Python 模組）';
COMMENT ON COLUMN web_app.applicationlog.function IS '函數名稱';
COMMENT ON COLUMN web_app.applicationlog.line IS '行號（程式碼行號）';
COMMENT ON COLUMN web_app.applicationlog.exception_type IS '異常類型（Exception 類別）';
COMMENT ON COLUMN web_app.applicationlog.exception_message IS '異常訊息（錯誤訊息）';
COMMENT ON COLUMN web_app.applicationlog.exception_traceback IS '異常堆疊追蹤（JSONB 完整 Traceback）';
COMMENT ON COLUMN web_app.applicationlog.extra_fields IS '額外欄位（JSONB 自定義欄位）';
COMMENT ON COLUMN web_app.applicationlog.created_date IS '日誌日期（用於分區）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_app_log_timestamp ON web_app.applicationlog(timestamp);
CREATE INDEX IF NOT EXISTS idx_app_log_level ON web_app.applicationlog(level);
CREATE INDEX IF NOT EXISTS idx_app_log_user_id ON web_app.applicationlog(user_id);
CREATE INDEX IF NOT EXISTS idx_app_log_created_date_timestamp ON web_app.applicationlog(created_date, timestamp);

-- ---------------------------------------------------------------------
-- 19. auditlog - 稽核日誌
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS web_app.auditlog (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    action VARCHAR(100),
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN,
    error_message TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES web_app."User"(id) ON DELETE SET NULL
);

COMMENT ON TABLE web_app.auditlog IS '稽核日誌（操作審計追蹤）';
COMMENT ON COLUMN web_app.auditlog.log_id IS '日誌 UUID（主鍵）';
COMMENT ON COLUMN web_app.auditlog.user_id IS '使用者 ID（外鍵）';
COMMENT ON COLUMN web_app.auditlog.action IS '操作動作（CREATE/UPDATE/DELETE 等）';
COMMENT ON COLUMN web_app.auditlog.resource_type IS '資源類型（Application/Item 等）';
COMMENT ON COLUMN web_app.auditlog.resource_id IS '資源 ID（被操作資源的 ID）';
COMMENT ON COLUMN web_app.auditlog.old_values IS '修改前舊值（JSON）';
COMMENT ON COLUMN web_app.auditlog.new_values IS '修改後新值（JSON）';
COMMENT ON COLUMN web_app.auditlog.ip_address IS 'IP 位址（操作者 IP）';
COMMENT ON COLUMN web_app.auditlog.user_agent IS '使用者代理字串（瀏覽器 UA）';
COMMENT ON COLUMN web_app.auditlog.success IS '操作是否成功';
COMMENT ON COLUMN web_app.auditlog.error_message IS '錯誤訊息（失敗原因）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_audit_user_id ON web_app.auditlog(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_action ON web_app.auditlog(action);
CREATE INDEX IF NOT EXISTS idx_audit_resource ON web_app.auditlog(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_date_created ON web_app.auditlog(date_created);

-- 建立觸發器
CREATE TRIGGER trigger_auditlog_update_timestamp
    BEFORE UPDATE ON web_app.auditlog
    FOR EACH ROW
    EXECUTE FUNCTION web_app.update_timestamp();

-- =====================================================================
-- 完成訊息
-- =====================================================================

DO $$ 
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'web_app schema 建立完成！';
    RAISE NOTICE '========================================';
    RAISE NOTICE '已建立:';
    RAISE NOTICE '  - 19 個核心表格';
    RAISE NOTICE '    * 13 個裝備管理表';
    RAISE NOTICE '    * 6 個 Web 應用表';
    RAISE NOTICE '  - 所有索引與外鍵約束';
    RAISE NOTICE '  - 時間戳自動更新觸發器';
    RAISE NOTICE '========================================';
    RAISE NOTICE '下一步: 建立初始資料與測試資料';
    RAISE NOTICE '========================================';
END $$;
