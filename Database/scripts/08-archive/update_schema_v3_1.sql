-- ============================================
-- PostgreSQL 資料庫更新腳本
-- 資料庫名稱: sbir_equipment_db_v2
-- 用途: 新增廠商代號申請表、CID申請單，修改申編單明細
-- 建立日期: 2025-11-19
-- 版本: V3.1
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. 新增 廠商代號申請表 (SupplierCodeApplication)
-- ============================================
CREATE TABLE SupplierCodeApplication (
    application_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    form_no VARCHAR(50) UNIQUE,
    applicant VARCHAR(50),
    supplier_uuid UUID,
    supplier_name VARCHAR(200),
    address VARCHAR(200),
    phone VARCHAR(50),
    business_items VARCHAR(200),
    supplier_code VARCHAR(20),
    equipment_name VARCHAR(200),
    extra_fields JSONB DEFAULT '{}'::jsonb,
    status VARCHAR(20) DEFAULT 'Draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_uuid) REFERENCES Supplier(supplier_id) ON DELETE SET NULL
);

COMMENT ON TABLE SupplierCodeApplication IS '廠商代號申請表';
COMMENT ON COLUMN SupplierCodeApplication.application_uuid IS '申請單UUID';
COMMENT ON COLUMN SupplierCodeApplication.form_no IS '流水號';
COMMENT ON COLUMN SupplierCodeApplication.applicant IS '申請人';
COMMENT ON COLUMN SupplierCodeApplication.supplier_uuid IS '關聯廠商ID (可選)';
COMMENT ON COLUMN SupplierCodeApplication.supplier_name IS '廠商名稱';
COMMENT ON COLUMN SupplierCodeApplication.address IS '地址';
COMMENT ON COLUMN SupplierCodeApplication.phone IS '電話';
COMMENT ON COLUMN SupplierCodeApplication.business_items IS '營業項目';
COMMENT ON COLUMN SupplierCodeApplication.supplier_code IS '廠家代號';
COMMENT ON COLUMN SupplierCodeApplication.equipment_name IS '裝備名稱';
COMMENT ON COLUMN SupplierCodeApplication.extra_fields IS '自定義欄位 (JSONB)';
COMMENT ON COLUMN SupplierCodeApplication.status IS '狀態';

-- 建立索引
CREATE INDEX idx_supplier_app_form_no ON SupplierCodeApplication(form_no);
CREATE INDEX idx_supplier_app_supplier ON SupplierCodeApplication(supplier_uuid);

-- 建立自動更新時間戳觸發器
CREATE TRIGGER update_supplier_app_updated_at BEFORE UPDATE ON SupplierCodeApplication
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- 2. 新增 CID申請單 (CIDApplication)
-- ============================================
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
    status VARCHAR(20) DEFAULT 'Draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_uuid) REFERENCES Item(item_uuid) ON DELETE SET NULL
);

COMMENT ON TABLE CIDApplication IS 'CID申請單';
COMMENT ON COLUMN CIDApplication.application_uuid IS '申請單UUID';
COMMENT ON COLUMN CIDApplication.form_no IS '流水號';
COMMENT ON COLUMN CIDApplication.applicant IS '申請人';
COMMENT ON COLUMN CIDApplication.item_uuid IS '關聯品項UUID (可選)';
COMMENT ON COLUMN CIDApplication.suggested_prefix IS '建議前兩碼';
COMMENT ON COLUMN CIDApplication.approved_cid IS '核定CID';
COMMENT ON COLUMN CIDApplication.equipment_name_zh IS '裝備中文名稱';
COMMENT ON COLUMN CIDApplication.equipment_name_en IS '裝備英文名稱';
COMMENT ON COLUMN CIDApplication.supplier_code IS '廠家代號';
COMMENT ON COLUMN CIDApplication.part_number IS '配件號碼';
COMMENT ON COLUMN CIDApplication.status IS '狀態';

-- 建立索引
CREATE INDEX idx_cid_app_form_no ON CIDApplication(form_no);
CREATE INDEX idx_cid_app_item ON CIDApplication(item_uuid);

-- 建立自動更新時間戳觸發器
CREATE TRIGGER update_cid_app_updated_at BEFORE UPDATE ON CIDApplication
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- 3. 修改 申編單明細檔 (ApplicationFormDetail)
-- ============================================

-- 重新命名 item_uuid 為 item_id
ALTER TABLE ApplicationFormDetail RENAME COLUMN item_uuid TO item_id;

COMMENT ON COLUMN ApplicationFormDetail.item_id IS '品項識別碼 (UUID)';

-- ============================================
-- 完成訊息
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫更新完成 (V3.1)';
    RAISE NOTICE '已新增: SupplierCodeApplication (廠商代號申請表)';
    RAISE NOTICE '已新增: CIDApplication (CID申請單)';
    RAISE NOTICE '已修改: ApplicationFormDetail (item_uuid -> item_id)';
    RAISE NOTICE '=========================================';
END $$;
