-- =====================================================
-- 申請表建立腳本 (Application Tables)
-- 用途：管理廠商代號申請和CID申請流程
-- 版本：V1.0
-- 日期：2025-11-17
-- =====================================================

-- 啟用 UUID 擴展（如果尚未啟用）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. SupplierApplication (廠商代號申請表)
-- =====================================================
-- 用途：管理廠商代號的申請流程
-- 申請通過後會在 Supplier 表中建立正式記錄

CREATE TABLE IF NOT EXISTS SupplierApplication (
    -- 主鍵
    application_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- 時間戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 添加註解
COMMENT ON TABLE SupplierApplication IS '廠商代號申請表：管理廠商代號申請流程';
COMMENT ON COLUMN SupplierApplication.application_id IS '申請單ID (UUID)';

-- =====================================================
-- 2. EquipmentApplication (CID申請表)
-- =====================================================
-- 用途：管理CID（裝備識別碼）的申請流程
-- 申請通過後會在 Equipment 表中建立正式記錄

CREATE TABLE IF NOT EXISTS EquipmentApplication (
    -- 主鍵
    application_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- 時間戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 添加註解
COMMENT ON TABLE EquipmentApplication IS 'CID申請表：管理裝備識別碼申請流程';
COMMENT ON COLUMN EquipmentApplication.application_id IS '申請單ID (UUID)';

-- =====================================================
-- 3. 建立觸發器：自動更新 updated_at
-- =====================================================

-- SupplierApplication 觸發器
CREATE TRIGGER update_supplier_application_updated_at
BEFORE UPDATE ON SupplierApplication
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- EquipmentApplication 觸發器
CREATE TRIGGER update_equipment_application_updated_at
BEFORE UPDATE ON EquipmentApplication
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 4. 建立審核狀態變更記錄表（可選）
-- =====================================================
-- 用途：記錄申請單的狀態變更歷史

CREATE TABLE IF NOT EXISTS ApplicationStatusHistory (
    history_id SERIAL PRIMARY KEY,
    application_type VARCHAR(20) NOT NULL,  -- 'supplier' 或 'equipment'
    application_id UUID NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    change_comment TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_app_type
        CHECK (application_type IN ('supplier', 'equipment'))
);

CREATE INDEX idx_status_history_app_id ON ApplicationStatusHistory(application_id);
CREATE INDEX idx_status_history_type ON ApplicationStatusHistory(application_type);

COMMENT ON TABLE ApplicationStatusHistory IS '申請單狀態變更歷史記錄';

-- =====================================================
-- 完成訊息
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '申請表建立完成！';
    RAISE NOTICE '=========================================';
    RAISE NOTICE '已建立以下表：';
    RAISE NOTICE '1. SupplierApplication (廠商申請表)';
    RAISE NOTICE '2. EquipmentApplication (CID申請表)';
    RAISE NOTICE '3. ApplicationStatusHistory (狀態變更歷史)';
    RAISE NOTICE '=========================================';
END $$;
