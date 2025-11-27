-- =====================================================
-- 資料庫結構調整腳本
-- 版本：V2.4
-- 日期：2025-11-18
-- =====================================================

-- =====================================================
-- 1. 修改 SupplierApplication (廠商代號申請表)
-- =====================================================

-- 先刪除外鍵約束
ALTER TABLE SupplierApplication DROP CONSTRAINT IF EXISTS fk_supplier_application_supplier;

-- 刪除檢查約束
ALTER TABLE SupplierApplication DROP CONSTRAINT IF EXISTS chk_supplier_app_status;

-- 刪除索引
DROP INDEX IF EXISTS idx_supplier_app_status;
DROP INDEX IF EXISTS idx_supplier_app_date;
DROP INDEX IF EXISTS idx_supplier_app_applicant;

-- 刪除所有非 PK 欄位（保留 application_id, created_at, updated_at）
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS supplier_code;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS cage_code;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS supplier_name_en;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS supplier_name_zh;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS supplier_type;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS country_code;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS application_status;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS applicant_name;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS applicant_email;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS applicant_unit;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS application_date;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS review_date;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS reviewer_name;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS review_comment;
ALTER TABLE SupplierApplication DROP COLUMN IF EXISTS supplier_id;

-- 更新表格註解
COMMENT ON TABLE SupplierApplication IS '廠商代號申請表：管理廠商代號申請流程';

-- 新增欄位
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS seq_no INT;
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS equipment_name VARCHAR(200);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(200);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS address VARCHAR(500);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS phone VARCHAR(50);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS business_scope VARCHAR(500);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS cage_code VARCHAR(20);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS applicant_name VARCHAR(100);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS serial_number VARCHAR(50);
ALTER TABLE SupplierApplication ADD COLUMN IF NOT EXISTS supplier_id INT;

-- 添加欄位註解
COMMENT ON COLUMN SupplierApplication.seq_no IS '項次';
COMMENT ON COLUMN SupplierApplication.equipment_name IS '裝備名稱';
COMMENT ON COLUMN SupplierApplication.supplier_name IS '廠商名稱';
COMMENT ON COLUMN SupplierApplication.address IS '地址';
COMMENT ON COLUMN SupplierApplication.phone IS '電話';
COMMENT ON COLUMN SupplierApplication.business_scope IS '營業項目';
COMMENT ON COLUMN SupplierApplication.cage_code IS '廠家代號';
COMMENT ON COLUMN SupplierApplication.applicant_name IS '申請人';
COMMENT ON COLUMN SupplierApplication.serial_number IS '流水號';
COMMENT ON COLUMN SupplierApplication.supplier_id IS '關聯廠商ID';

-- 建立外鍵約束連結到 Supplier
ALTER TABLE SupplierApplication ADD CONSTRAINT fk_supplier_application_supplier
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE SET NULL;

-- 建立索引
CREATE INDEX idx_supplier_app_serial ON SupplierApplication(serial_number);
CREATE INDEX idx_supplier_app_cage ON SupplierApplication(cage_code);

-- =====================================================
-- 2. 修改 EquipmentApplication (CID申請表)
-- =====================================================

-- 先刪除外鍵約束
ALTER TABLE EquipmentApplication DROP CONSTRAINT IF EXISTS fk_equipment_app_equipment;
ALTER TABLE EquipmentApplication DROP CONSTRAINT IF EXISTS fk_equipment_app_parent;

-- 刪除檢查約束
ALTER TABLE EquipmentApplication DROP CONSTRAINT IF EXISTS chk_equipment_app_status;

-- 刪除索引
DROP INDEX IF EXISTS idx_equipment_app_status;
DROP INDEX IF EXISTS idx_equipment_app_date;
DROP INDEX IF EXISTS idx_equipment_app_applicant;
DROP INDEX IF EXISTS idx_equipment_app_cid;
DROP INDEX IF EXISTS idx_equipment_app_eswbs;

-- 刪除所有非 PK 欄位（保留 application_id, created_at, updated_at）
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS equipment_id;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS equipment_name_zh;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS equipment_name_en;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS equipment_type;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS ship_type;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS position;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS parent_equipment_zh;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS parent_equipment_en;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS parent_cid;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS eswbs_code;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS system_function_name;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS installation_qty;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS total_installation_qty;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS maintenance_level;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS equipment_serial;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS application_status;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS applicant_name;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS applicant_email;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS applicant_unit;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS application_date;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS review_date;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS reviewer_name;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS review_comment;
ALTER TABLE EquipmentApplication DROP COLUMN IF EXISTS approved_equipment_id;

-- 更新表格註解
COMMENT ON TABLE EquipmentApplication IS 'CID申請表：管理裝備識別碼申請流程';

-- 新增欄位
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS seq_no INT;
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS suggested_prefix VARCHAR(10);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS approved_cid VARCHAR(50);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS equipment_name_zh VARCHAR(100);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS equipment_name_en VARCHAR(200);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS cage_code VARCHAR(20);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS part_number VARCHAR(50);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS applicant_name VARCHAR(100);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS serial_number VARCHAR(50);
ALTER TABLE EquipmentApplication ADD COLUMN IF NOT EXISTS equipment_id VARCHAR(50);

-- 添加欄位註解
COMMENT ON COLUMN EquipmentApplication.seq_no IS '項次';
COMMENT ON COLUMN EquipmentApplication.suggested_prefix IS '建議前兩碼';
COMMENT ON COLUMN EquipmentApplication.approved_cid IS '核定CID';
COMMENT ON COLUMN EquipmentApplication.equipment_name_zh IS '裝備中文名稱';
COMMENT ON COLUMN EquipmentApplication.equipment_name_en IS '裝備英文名稱';
COMMENT ON COLUMN EquipmentApplication.cage_code IS '廠家代號';
COMMENT ON COLUMN EquipmentApplication.part_number IS '配件號碼';
COMMENT ON COLUMN EquipmentApplication.applicant_name IS '申請人';
COMMENT ON COLUMN EquipmentApplication.serial_number IS '流水號';
COMMENT ON COLUMN EquipmentApplication.equipment_id IS '關聯裝備ID';

-- 建立外鍵約束連結到 Equipment
ALTER TABLE EquipmentApplication ADD CONSTRAINT fk_equipment_application_equipment
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id) ON DELETE SET NULL;

-- 建立索引
CREATE INDEX idx_equipment_app_serial ON EquipmentApplication(serial_number);
CREATE INDEX idx_equipment_app_cage ON EquipmentApplication(cage_code);
CREATE INDEX idx_equipment_app_approved_cid ON EquipmentApplication(approved_cid);

-- =====================================================
-- 完成訊息
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '申請表結構修改完成！';
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'SupplierApplication (廠商代號申請表) 欄位：';
    RAISE NOTICE '  - application_id, seq_no, equipment_name';
    RAISE NOTICE '  - supplier_name, address, phone';
    RAISE NOTICE '  - business_scope, cage_code';
    RAISE NOTICE '  - applicant_name, serial_number, supplier_id';
    RAISE NOTICE '';
    RAISE NOTICE 'EquipmentApplication (CID申請表) 欄位：';
    RAISE NOTICE '  - application_id, seq_no, suggested_prefix';
    RAISE NOTICE '  - approved_cid, equipment_name_zh, equipment_name_en';
    RAISE NOTICE '  - cage_code, part_number';
    RAISE NOTICE '  - applicant_name, serial_number, equipment_id';
    RAISE NOTICE '=========================================';
END $$;
