-- ============================================
-- PostgreSQL 資料庫建立腳本
-- 資料庫名稱: sbir_equipment_db_v3
-- 用途: 海軍裝備管理系統 + Web 應用整合
-- 建立日期: 2025-11-25
-- 版本: V3.1 (整合 Web 應用系統)
--
-- 變更說明:
-- - 保留 V3.0 的 12 個核心裝備表
-- - 新增 6 個 Web 應用表
-- - Application 表取代舊的 ApplicationForm
-- - 統一使用 date_created/date_updated 時間戳命名
-- - 總計：18 個資料表
-- ============================================

-- 建立資料庫
DROP DATABASE IF EXISTS sbir_equipment_db_v3;
CREATE DATABASE sbir_equipment_db_v3
    WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'Chinese (Traditional)_Taiwan.950'
    LC_CTYPE = 'Chinese (Traditional)_Taiwan.950'
    TEMPLATE = template0;

-- 連接到新資料庫
\c sbir_equipment_db_v3;

-- 啟用 UUID 擴充
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 第一階段：主表建立（核心裝備表）
-- ============================================

-- 1. 廠商主檔 (Supplier)
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

-- 7. MRC 品項規格表
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
-- 第四階段：輔助資料建立（核心表）
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

-- 11. 廠商代號申請表 (SupplierCodeApplication) - 保留不變
CREATE TABLE SupplierCodeApplication (
    application_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    form_no VARCHAR(50) UNIQUE,
    applicant VARCHAR(50),
    supplier_id INT,
    supplier_name VARCHAR(200),
    address VARCHAR(200),
    phone VARCHAR(50),
    business_items VARCHAR(200),
    supplier_code VARCHAR(20),
    equipment_name VARCHAR(200),
    custom_fields JSONB,
    status VARCHAR(20),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE SET NULL
);

COMMENT ON TABLE SupplierCodeApplication IS '廠商代號申請表';
COMMENT ON COLUMN SupplierCodeApplication.application_uuid IS '申請單UUID';
COMMENT ON COLUMN SupplierCodeApplication.form_no IS '流水號';
COMMENT ON COLUMN SupplierCodeApplication.custom_fields IS '自定義欄位（JSONB）';

-- 12. CID申請單 (CIDApplication) - 保留不變
CREATE TABLE CIDApplication (
    application_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    form_no VARCHAR(50) UNIQUE,
    applicant VARCHAR(50),
    item_uuid UUID,
    suggested_prefix VARCHAR(2),
    approved_cid VARCHAR(50),
    equipment_name_zh VARCHAR(100),
    equipment_name_en VARCHAR(200),
    supplier_code VARCHAR(20),
    part_number VARCHAR(50),
    status VARCHAR(20),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE SET NULL
);

COMMENT ON TABLE CIDApplication IS 'CID申請單';
COMMENT ON COLUMN CIDApplication.application_uuid IS '申請單UUID';
COMMENT ON COLUMN CIDApplication.form_no IS '流水號';
COMMENT ON COLUMN CIDApplication.suggested_prefix IS '建議前兩碼';
COMMENT ON COLUMN CIDApplication.approved_cid IS '核定CID';

-- ============================================
-- 第五階段：Web 應用表建立 ⭐
-- ============================================

-- 13. User 表（使用者管理）
CREATE TABLE "User" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    english_code VARCHAR(10),
    full_name VARCHAR(100),
    department VARCHAR(100),
    position VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    failed_login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE "User" IS '系統使用者資料表';
COMMENT ON COLUMN "User".id IS '使用者UUID（主鍵）';
COMMENT ON COLUMN "User".username IS '使用者帳號';
COMMENT ON COLUMN "User".email IS '電子郵件';
COMMENT ON COLUMN "User".password_hash IS '密碼雜湊值';
COMMENT ON COLUMN "User".role IS '角色權限（admin/user/viewer等）';
COMMENT ON COLUMN "User".is_active IS '帳號啟用狀態';
COMMENT ON COLUMN "User".is_verified IS '電子郵件驗證狀態';

-- 14. Application 表（取代 ApplicationForm）
CREATE TABLE Application (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES "User"(id),
    item_uuid UUID REFERENCES Item(item_uuid) ON DELETE SET NULL,
    form_serial_number VARCHAR(50),
    part_number VARCHAR(50),
    english_name VARCHAR(255),
    chinese_name VARCHAR(255),
    inc_code VARCHAR(20),
    fiig_code VARCHAR(20),
    accounting_unit_code VARCHAR(50),
    issue_unit VARCHAR(10),
    unit_price NUMERIC(10, 2),
    spec_indicator VARCHAR(10),
    unit_pack_quantity VARCHAR(10),
    storage_life_months VARCHAR(10),
    storage_life_action_code VARCHAR(10),
    storage_type_code VARCHAR(10),
    secrecy_code VARCHAR(10),
    expendability_code VARCHAR(10),
    repairability_code VARCHAR(10),
    manufacturability_code VARCHAR(10),
    source_code VARCHAR(10),
    category_code VARCHAR(10),
    system_code VARCHAR(100),
    pn_acquisition_level VARCHAR(100),
    pn_acquisition_source VARCHAR(100),
    manufacturer VARCHAR(255),
    part_number_reference VARCHAR(255),
    manufacturer_name VARCHAR(255),
    agent_name VARCHAR(100),
    ship_type VARCHAR(100),
    cid_no VARCHAR(100),
    model_type VARCHAR(255),
    equipment_name VARCHAR(255),
    usage_location INT,
    quantity_per_unit JSON,
    mrc_data VARCHAR(255),
    document_reference VARCHAR(255),
    applicant_unit VARCHAR(100),
    contact_info VARCHAR(100),
    apply_date DATE,
    official_nsn_stamp VARCHAR(10),
    official_nsn_final VARCHAR(20),
    nsn_filled_at TIMESTAMP,
    nsn_filled_by UUID REFERENCES "User"(id),
    status VARCHAR(50),
    sub_status VARCHAR(50),
    closed_at TIMESTAMP,
    closed_by UUID REFERENCES "User"(id),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

COMMENT ON TABLE Application IS '申編單主表（完整版，取代舊的 ApplicationForm）';
COMMENT ON COLUMN Application.id IS '申編單UUID（主鍵）';
COMMENT ON COLUMN Application.user_id IS '申請人（外鍵至User表）';
COMMENT ON COLUMN Application.item_uuid IS '關聯的品項UUID（外鍵至Item表）';
COMMENT ON COLUMN Application.form_serial_number IS '表單序號';
COMMENT ON COLUMN Application.status IS '申編單狀態';
COMMENT ON COLUMN Application.deleted_at IS '軟刪除時間戳';

-- 15. ApplicationAttachment 表（附件管理）
CREATE TABLE ApplicationAttachment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES Application(id) ON DELETE CASCADE,
    user_id UUID REFERENCES "User"(id),
    file_data BYTEA,
    filename VARCHAR(255),
    original_filename VARCHAR(255),
    mimetype VARCHAR(100),
    file_type VARCHAR(20),
    page_selection VARCHAR(200),
    sort_order INT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ApplicationAttachment IS '申編單附件表';
COMMENT ON COLUMN ApplicationAttachment.file_data IS '檔案二進制資料（BYTEA）';
COMMENT ON COLUMN ApplicationAttachment.filename IS '儲存檔名';
COMMENT ON COLUMN ApplicationAttachment.original_filename IS '原始檔名';

-- 16. UserSession 表（工作階段管理）
CREATE TABLE UserSession (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id UUID REFERENCES "User"(id) ON DELETE CASCADE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    remember_me BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP
);

COMMENT ON TABLE UserSession IS '使用者工作階段';
COMMENT ON COLUMN UserSession.session_id IS 'Session ID（主鍵）';
COMMENT ON COLUMN UserSession.expires_at IS 'Session過期時間';

-- 17. ApplicationLog 表（應用程式日誌）
CREATE TABLE ApplicationLog (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    level VARCHAR(10),
    logger VARCHAR(100),
    message TEXT,
    request_id VARCHAR(36),
    method VARCHAR(10),
    path VARCHAR(500),
    status_code INT,
    elapsed_time_ms NUMERIC(10, 2),
    user_id UUID,
    remote_addr INET,
    user_agent TEXT,
    module VARCHAR(100),
    function VARCHAR(100),
    line INT,
    exception_type VARCHAR(100),
    exception_message TEXT,
    exception_traceback JSONB,
    extra_fields JSONB,
    created_date DATE DEFAULT CURRENT_DATE
);

COMMENT ON TABLE ApplicationLog IS '應用程式日誌紀錄表';
COMMENT ON COLUMN ApplicationLog.timestamp IS '日誌時間戳（TIMESTAMPTZ）';
COMMENT ON COLUMN ApplicationLog.elapsed_time_ms IS '請求處理時間（毫秒）';
COMMENT ON COLUMN ApplicationLog.exception_traceback IS '異常堆疊追蹤（JSONB）';

-- 18. AuditLog 表（稽核日誌）
CREATE TABLE AuditLog (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES "User"(id),
    action VARCHAR(100),
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN,
    error_message TEXT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE AuditLog IS '稽核日誌（Audit Trail）';
COMMENT ON COLUMN AuditLog.action IS '操作動作（CREATE/UPDATE/DELETE等）';
COMMENT ON COLUMN AuditLog.resource_type IS '資源類型（Application/Item等）';
COMMENT ON COLUMN AuditLog.old_values IS '修改前舊值（JSON）';
COMMENT ON COLUMN AuditLog.new_values IS '修改後新值（JSON）';

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

-- 申請表索引
CREATE INDEX idx_supplier_app_form_no ON SupplierCodeApplication(form_no);
CREATE INDEX idx_cid_app_form_no ON CIDApplication(form_no);

-- Web 應用表索引
CREATE INDEX idx_user_email ON "User"(email);
CREATE INDEX idx_user_username ON "User"(username);
CREATE INDEX idx_user_role ON "User"(role);
CREATE INDEX idx_user_is_active ON "User"(is_active);

CREATE INDEX idx_app_user_id ON Application(user_id);
CREATE INDEX idx_app_item_uuid ON Application(item_uuid);
CREATE INDEX idx_app_form_serial ON Application(form_serial_number);
CREATE INDEX idx_app_status ON Application(status);
CREATE INDEX idx_app_part_number ON Application(part_number);
CREATE INDEX idx_app_nsn ON Application(official_nsn_final);
CREATE INDEX idx_app_date_created ON Application(date_created);
CREATE INDEX idx_app_deleted_at ON Application(deleted_at) WHERE deleted_at IS NOT NULL;

CREATE INDEX idx_attachment_app_id ON ApplicationAttachment(application_id);
CREATE INDEX idx_attachment_user_id ON ApplicationAttachment(user_id);
CREATE INDEX idx_attachment_type ON ApplicationAttachment(file_type);

CREATE INDEX idx_session_user_id ON UserSession(user_id);
CREATE INDEX idx_session_expires_at ON UserSession(expires_at);
CREATE INDEX idx_session_is_active ON UserSession(is_active) WHERE is_active = TRUE;

CREATE INDEX idx_app_log_timestamp ON ApplicationLog(timestamp);
CREATE INDEX idx_app_log_level ON ApplicationLog(level);
CREATE INDEX idx_app_log_user_id ON ApplicationLog(user_id);
CREATE INDEX idx_app_log_created_date_timestamp ON ApplicationLog(created_date, timestamp);

CREATE INDEX idx_audit_user_id ON AuditLog(user_id);
CREATE INDEX idx_audit_action ON AuditLog(action);
CREATE INDEX idx_audit_resource ON AuditLog(resource_type, resource_id);
CREATE INDEX idx_audit_date_created ON AuditLog(date_created);

-- ============================================
-- 建立更新時間戳自動更新函數（統一命名）
-- ============================================

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

-- ============================================
-- 為核心表建立觸發器
-- ============================================

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

CREATE TRIGGER update_supplier_app_date_updated BEFORE UPDATE ON SupplierCodeApplication
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_cid_app_date_updated BEFORE UPDATE ON CIDApplication
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

-- ============================================
-- 為 Web 應用表建立觸發器
-- ============================================

CREATE TRIGGER update_user_updated_at BEFORE UPDATE ON "User"
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_application_updated_at BEFORE UPDATE ON Application
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

CREATE TRIGGER update_attachment_updated_at BEFORE UPDATE ON ApplicationAttachment
    FOR EACH ROW EXECUTE FUNCTION update_date_updated_column();

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫建立完成！';
    RAISE NOTICE '資料庫名稱: sbir_equipment_db_v3';
    RAISE NOTICE '版本: V3.1 (整合 Web 應用系統)';
    RAISE NOTICE '';
    RAISE NOTICE '已建立 18 個資料表：';
    RAISE NOTICE '';
    RAISE NOTICE '核心裝備管理表（12個）：';
    RAISE NOTICE '  1. Supplier - 廠商主檔';
    RAISE NOTICE '  2. Item - 品項主檔（UUID PK）';
    RAISE NOTICE '  3. Item_Equipment_Ext - 裝備擴展表';
    RAISE NOTICE '  4. Item_Material_Ext - 料件擴展表';
    RAISE NOTICE '  5. BOM - BOM主表（版本控制）';
    RAISE NOTICE '  6. BOM_LINE - BOM明細（Item自我關聯）';
    RAISE NOTICE '  7. MRC - 品項規格表';
    RAISE NOTICE '  8. Part_Number_xref - 零件號碼關聯檔';
    RAISE NOTICE '  9. TechnicalDocument - 技術文件檔';
    RAISE NOTICE '  10. Item_Document_xref - 品項文件關聯檔';
    RAISE NOTICE '  11. SupplierCodeApplication - 廠商代號申請表';
    RAISE NOTICE '  12. CIDApplication - CID申請單';
    RAISE NOTICE '';
    RAISE NOTICE 'Web 應用表（6個）：';
    RAISE NOTICE '  13. User - 使用者管理';
    RAISE NOTICE '  14. Application - 申編單主表（取代舊的 ApplicationForm）';
    RAISE NOTICE '  15. ApplicationAttachment - 附件管理';
    RAISE NOTICE '  16. UserSession - 工作階段';
    RAISE NOTICE '  17. ApplicationLog - 應用程式日誌';
    RAISE NOTICE '  18. AuditLog - 稽核日誌';
    RAISE NOTICE '';
    RAISE NOTICE '時間戳命名: 統一使用 date_created/date_updated';
    RAISE NOTICE '已建立所有索引和約束';
    RAISE NOTICE '已建立自動更新時間戳觸發器';
    RAISE NOTICE '=========================================';
END $$;
