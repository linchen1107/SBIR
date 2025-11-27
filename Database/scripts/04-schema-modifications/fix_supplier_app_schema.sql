-- ============================================
-- PostgreSQL 資料庫修復腳本
-- 用途: 重新建立 SupplierCodeApplication (修正 FK 類型錯誤)
-- ============================================

\c sbir_equipment_db_v2;

-- 確保清理舊的嘗試 (如果存在)
DROP TABLE IF EXISTS SupplierCodeApplication;

-- 重新建立 廠商代號申請表 (修正 supplier_id 類型)
CREATE TABLE SupplierCodeApplication (
    application_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    form_no VARCHAR(50) UNIQUE,
    applicant VARCHAR(50),
    supplier_id INT, -- 修正: 配合 Supplier.supplier_id (SERIAL/INT)
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
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE SET NULL
);

COMMENT ON TABLE SupplierCodeApplication IS '廠商代號申請表';
COMMENT ON COLUMN SupplierCodeApplication.application_uuid IS '申請單UUID';
COMMENT ON COLUMN SupplierCodeApplication.form_no IS '流水號';
COMMENT ON COLUMN SupplierCodeApplication.applicant IS '申請人';
COMMENT ON COLUMN SupplierCodeApplication.supplier_id IS '關聯廠商ID (可選)';
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
CREATE INDEX idx_supplier_app_supplier ON SupplierCodeApplication(supplier_id);

-- 建立自動更新時間戳觸發器
CREATE TRIGGER update_supplier_app_updated_at BEFORE UPDATE ON SupplierCodeApplication
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'SupplierCodeApplication 修復完成';
    RAISE NOTICE '已修正 FK 類型為 INT';
    RAISE NOTICE '=========================================';
END $$;
