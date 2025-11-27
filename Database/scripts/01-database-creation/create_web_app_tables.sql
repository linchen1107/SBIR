-- ============================================
-- Web 應用資料表建立腳本
-- 版本: V3.1
-- 建立日期: 2025-11-25
-- 用途: 整合 Web 應用使用者與申編單管理系統
--
-- 說明:
-- - 此腳本假設核心裝備表（V3.0）已存在
-- - 新增 6 個 Web 應用表
-- - 統一使用 date_created/date_updated 時間戳命名
-- - 全部整合到 public schema
-- ============================================

-- 連接到資料庫（如需要）
-- \c sbir_equipment_db_v2;

-- ============================================
-- 階段 1：清理舊表結構
-- ============================================

-- 刪除舊的申編單表（順序很重要）
DROP TABLE IF EXISTS ApplicationFormDetail CASCADE;
DROP TABLE IF EXISTS ApplicationForm CASCADE;
DROP TABLE IF EXISTS ApplicationAttachment CASCADE;  -- 如果存在舊版

-- ============================================
-- 階段 2：建立 Web 應用核心表
-- ============================================

-- 1. User 表（使用者管理）
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
COMMENT ON COLUMN "User".english_code IS '英文代碼';
COMMENT ON COLUMN "User".full_name IS '全名';
COMMENT ON COLUMN "User".department IS '部門';
COMMENT ON COLUMN "User".position IS '職位';
COMMENT ON COLUMN "User".phone IS '電話';
COMMENT ON COLUMN "User".role IS '角色權限（admin/user/viewer等）';
COMMENT ON COLUMN "User".is_active IS '帳號啟用狀態';
COMMENT ON COLUMN "User".is_verified IS '電子郵件驗證狀態';
COMMENT ON COLUMN "User".email_verified_at IS '電子郵件驗證時間';
COMMENT ON COLUMN "User".last_login_at IS '最後登入時間';
COMMENT ON COLUMN "User".failed_login_attempts IS '登入失敗次數';
COMMENT ON COLUMN "User".locked_until IS '帳號鎖定至';
COMMENT ON COLUMN "User".date_created IS '建立時間';
COMMENT ON COLUMN "User".date_updated IS '更新時間';

-- 2. Application 表（取代 ApplicationForm）
CREATE TABLE Application (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES "User"(id),

    -- 與 Item 表的關聯（新增）
    item_uuid UUID REFERENCES Item(item_uuid) ON DELETE SET NULL,

    -- 基本資訊
    form_serial_number VARCHAR(50),
    part_number VARCHAR(50),
    english_name VARCHAR(255),
    chinese_name VARCHAR(255),

    -- 料號分類資訊
    inc_code VARCHAR(20),
    fiig_code VARCHAR(20),
    accounting_unit_code VARCHAR(50),
    issue_unit VARCHAR(10),
    unit_price NUMERIC(10, 2),
    spec_indicator VARCHAR(10),
    unit_pack_quantity VARCHAR(10),

    -- 儲存與分類代碼
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

    -- 零件號碼資訊
    pn_acquisition_level VARCHAR(100),
    pn_acquisition_source VARCHAR(100),
    manufacturer VARCHAR(255),
    part_number_reference VARCHAR(255),
    manufacturer_name VARCHAR(255),
    agent_name VARCHAR(100),

    -- 裝備相關
    ship_type VARCHAR(100),
    cid_no VARCHAR(100),
    model_type VARCHAR(255),
    equipment_name VARCHAR(255),
    usage_location INT,
    quantity_per_unit JSON,

    -- 規格與文件
    mrc_data VARCHAR(255),
    document_reference VARCHAR(255),

    -- 申請單位資訊
    applicant_unit VARCHAR(100),
    contact_info VARCHAR(100),
    apply_date DATE,

    -- NSN 相關
    official_nsn_stamp VARCHAR(10),
    official_nsn_final VARCHAR(20),
    nsn_filled_at TIMESTAMP,
    nsn_filled_by UUID REFERENCES "User"(id),

    -- 狀態管理
    status VARCHAR(50),
    sub_status VARCHAR(50),
    closed_at TIMESTAMP,
    closed_by UUID REFERENCES "User"(id),

    -- 時間戳與軟刪除
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

COMMENT ON TABLE Application IS '申編單主表（完整版，取代舊的 ApplicationForm）';
COMMENT ON COLUMN Application.id IS '申編單UUID（主鍵）';
COMMENT ON COLUMN Application.user_id IS '申請人（外鍵至User表）';
COMMENT ON COLUMN Application.item_uuid IS '關聯的品項UUID（外鍵至Item表）';
COMMENT ON COLUMN Application.form_serial_number IS '表單序號';
COMMENT ON COLUMN Application.part_number IS '料號';
COMMENT ON COLUMN Application.english_name IS '英文品名';
COMMENT ON COLUMN Application.chinese_name IS '中文品名';
COMMENT ON COLUMN Application.inc_code IS 'INC代碼';
COMMENT ON COLUMN Application.fiig_code IS 'FIIG代碼';
COMMENT ON COLUMN Application.accounting_unit_code IS '會計單位代碼';
COMMENT ON COLUMN Application.issue_unit IS '發放單位';
COMMENT ON COLUMN Application.unit_price IS '單價';
COMMENT ON COLUMN Application.spec_indicator IS '規格指示';
COMMENT ON COLUMN Application.unit_pack_quantity IS '單位包裝量';
COMMENT ON COLUMN Application.storage_life_months IS '儲存壽命（月）';
COMMENT ON COLUMN Application.storage_life_action_code IS '儲存壽命處理代碼';
COMMENT ON COLUMN Application.storage_type_code IS '儲存型式代碼';
COMMENT ON COLUMN Application.secrecy_code IS '機密性代碼';
COMMENT ON COLUMN Application.expendability_code IS '消耗性代碼';
COMMENT ON COLUMN Application.repairability_code IS '修理能力代碼';
COMMENT ON COLUMN Application.manufacturability_code IS '製造能力代碼';
COMMENT ON COLUMN Application.source_code IS '來源代碼';
COMMENT ON COLUMN Application.category_code IS '類別代碼';
COMMENT ON COLUMN Application.system_code IS '系統代碼';
COMMENT ON COLUMN Application.pn_acquisition_level IS '零件號獲得程度';
COMMENT ON COLUMN Application.pn_acquisition_source IS '零件號獲得來源';
COMMENT ON COLUMN Application.manufacturer IS '製造商';
COMMENT ON COLUMN Application.part_number_reference IS '參考零件號碼';
COMMENT ON COLUMN Application.manufacturer_name IS '製造商名稱';
COMMENT ON COLUMN Application.agent_name IS '代理商名稱';
COMMENT ON COLUMN Application.ship_type IS '艦型';
COMMENT ON COLUMN Application.cid_no IS 'CID編號';
COMMENT ON COLUMN Application.model_type IS '型式';
COMMENT ON COLUMN Application.equipment_name IS '裝備名稱';
COMMENT ON COLUMN Application.usage_location IS '使用地點';
COMMENT ON COLUMN Application.quantity_per_unit IS '單位數量（JSON）';
COMMENT ON COLUMN Application.mrc_data IS 'MRC資料';
COMMENT ON COLUMN Application.document_reference IS '文件參考';
COMMENT ON COLUMN Application.applicant_unit IS '申請單位';
COMMENT ON COLUMN Application.contact_info IS '聯絡資訊';
COMMENT ON COLUMN Application.apply_date IS '申請日期';
COMMENT ON COLUMN Application.official_nsn_stamp IS '正式NSN印章';
COMMENT ON COLUMN Application.official_nsn_final IS '最終正式NSN';
COMMENT ON COLUMN Application.nsn_filled_at IS 'NSN填寫時間';
COMMENT ON COLUMN Application.nsn_filled_by IS 'NSN填寫人（外鍵至User表）';
COMMENT ON COLUMN Application.status IS '申編單狀態';
COMMENT ON COLUMN Application.sub_status IS '申編單子狀態';
COMMENT ON COLUMN Application.closed_at IS '結案時間';
COMMENT ON COLUMN Application.closed_by IS '結案人（外鍵至User表）';
COMMENT ON COLUMN Application.date_created IS '建立時間';
COMMENT ON COLUMN Application.date_updated IS '更新時間';
COMMENT ON COLUMN Application.deleted_at IS '軟刪除時間戳';

-- ============================================
-- 階段 3：建立附屬表
-- ============================================

-- 3. ApplicationAttachment 表（附件管理）
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
COMMENT ON COLUMN ApplicationAttachment.id IS '附件UUID（主鍵）';
COMMENT ON COLUMN ApplicationAttachment.application_id IS '申編單ID（外鍵至Application表）';
COMMENT ON COLUMN ApplicationAttachment.user_id IS '上傳者（外鍵至User表）';
COMMENT ON COLUMN ApplicationAttachment.file_data IS '檔案二進制資料（BYTEA）';
COMMENT ON COLUMN ApplicationAttachment.filename IS '儲存檔名';
COMMENT ON COLUMN ApplicationAttachment.original_filename IS '原始檔名';
COMMENT ON COLUMN ApplicationAttachment.mimetype IS 'MIME類型';
COMMENT ON COLUMN ApplicationAttachment.file_type IS '檔案類型';
COMMENT ON COLUMN ApplicationAttachment.page_selection IS '頁面選擇（PDF多頁時）';
COMMENT ON COLUMN ApplicationAttachment.sort_order IS '排序順序';
COMMENT ON COLUMN ApplicationAttachment.date_created IS '建立時間';
COMMENT ON COLUMN ApplicationAttachment.date_updated IS '更新時間';

-- 4. UserSession 表（工作階段管理）
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
COMMENT ON COLUMN UserSession.user_id IS '使用者ID（外鍵至User表）';
COMMENT ON COLUMN UserSession.ip_address IS 'IP位址';
COMMENT ON COLUMN UserSession.user_agent IS '使用者代理字串';
COMMENT ON COLUMN UserSession.is_active IS '是否啟用';
COMMENT ON COLUMN UserSession.remember_me IS '記住我功能';
COMMENT ON COLUMN UserSession.expires_at IS 'Session過期時間';
COMMENT ON COLUMN UserSession.date_created IS '建立時間';
COMMENT ON COLUMN UserSession.last_activity_at IS '最後活動時間';

-- 5. ApplicationLog 表（應用程式日誌）
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
COMMENT ON COLUMN ApplicationLog.log_id IS '日誌UUID（主鍵）';
COMMENT ON COLUMN ApplicationLog.timestamp IS '日誌時間戳（TIMESTAMPTZ）';
COMMENT ON COLUMN ApplicationLog.level IS '日誌等級（DEBUG/INFO/WARNING/ERROR）';
COMMENT ON COLUMN ApplicationLog.logger IS '日誌記錄器名稱';
COMMENT ON COLUMN ApplicationLog.message IS '日誌訊息';
COMMENT ON COLUMN ApplicationLog.request_id IS '請求ID';
COMMENT ON COLUMN ApplicationLog.method IS 'HTTP方法';
COMMENT ON COLUMN ApplicationLog.path IS '請求路徑';
COMMENT ON COLUMN ApplicationLog.status_code IS 'HTTP狀態碼';
COMMENT ON COLUMN ApplicationLog.elapsed_time_ms IS '請求處理時間（毫秒）';
COMMENT ON COLUMN ApplicationLog.user_id IS '使用者ID';
COMMENT ON COLUMN ApplicationLog.remote_addr IS '遠端IP位址';
COMMENT ON COLUMN ApplicationLog.user_agent IS '使用者代理字串';
COMMENT ON COLUMN ApplicationLog.module IS '模組名稱';
COMMENT ON COLUMN ApplicationLog.function IS '函數名稱';
COMMENT ON COLUMN ApplicationLog.line IS '行號';
COMMENT ON COLUMN ApplicationLog.exception_type IS '異常類型';
COMMENT ON COLUMN ApplicationLog.exception_message IS '異常訊息';
COMMENT ON COLUMN ApplicationLog.exception_traceback IS '異常堆疊追蹤（JSONB）';
COMMENT ON COLUMN ApplicationLog.extra_fields IS '額外欄位（JSONB）';
COMMENT ON COLUMN ApplicationLog.created_date IS '日誌日期（用於分區）';

-- 6. AuditLog 表（稽核日誌）
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
COMMENT ON COLUMN AuditLog.log_id IS '日誌UUID（主鍵）';
COMMENT ON COLUMN AuditLog.user_id IS '使用者ID（外鍵至User表）';
COMMENT ON COLUMN AuditLog.action IS '操作動作（CREATE/UPDATE/DELETE等）';
COMMENT ON COLUMN AuditLog.resource_type IS '資源類型（Application/Item等）';
COMMENT ON COLUMN AuditLog.resource_id IS '資源ID';
COMMENT ON COLUMN AuditLog.old_values IS '修改前舊值（JSON）';
COMMENT ON COLUMN AuditLog.new_values IS '修改後新值（JSON）';
COMMENT ON COLUMN AuditLog.ip_address IS 'IP位址';
COMMENT ON COLUMN AuditLog.user_agent IS '使用者代理字串';
COMMENT ON COLUMN AuditLog.success IS '操作是否成功';
COMMENT ON COLUMN AuditLog.error_message IS '錯誤訊息';
COMMENT ON COLUMN AuditLog.date_created IS '建立時間';

-- ============================================
-- 階段 4：建立索引
-- ============================================

-- User 索引
CREATE INDEX idx_user_email ON "User"(email);
CREATE INDEX idx_user_username ON "User"(username);
CREATE INDEX idx_user_role ON "User"(role);
CREATE INDEX idx_user_is_active ON "User"(is_active);

-- Application 索引
CREATE INDEX idx_app_user_id ON Application(user_id);
CREATE INDEX idx_app_item_uuid ON Application(item_uuid);
CREATE INDEX idx_app_form_serial ON Application(form_serial_number);
CREATE INDEX idx_app_status ON Application(status);
CREATE INDEX idx_app_part_number ON Application(part_number);
CREATE INDEX idx_app_nsn ON Application(official_nsn_final);
CREATE INDEX idx_app_date_created ON Application(date_created);
CREATE INDEX idx_app_deleted_at ON Application(deleted_at) WHERE deleted_at IS NOT NULL;

-- ApplicationAttachment 索引
CREATE INDEX idx_attachment_app_id ON ApplicationAttachment(application_id);
CREATE INDEX idx_attachment_user_id ON ApplicationAttachment(user_id);
CREATE INDEX idx_attachment_type ON ApplicationAttachment(file_type);

-- UserSession 索引
CREATE INDEX idx_session_user_id ON UserSession(user_id);
CREATE INDEX idx_session_expires_at ON UserSession(expires_at);
CREATE INDEX idx_session_is_active ON UserSession(is_active) WHERE is_active = TRUE;

-- ApplicationLog 索引
CREATE INDEX idx_app_log_timestamp ON ApplicationLog(timestamp);
CREATE INDEX idx_app_log_level ON ApplicationLog(level);
CREATE INDEX idx_app_log_user_id ON ApplicationLog(user_id);
CREATE INDEX idx_app_log_created_date_timestamp ON ApplicationLog(created_date, timestamp);

-- AuditLog 索引
CREATE INDEX idx_audit_user_id ON AuditLog(user_id);
CREATE INDEX idx_audit_action ON AuditLog(action);
CREATE INDEX idx_audit_resource ON AuditLog(resource_type, resource_id);
CREATE INDEX idx_audit_date_created ON AuditLog(date_created);

-- ============================================
-- 階段 5：建立/更新觸發器函數
-- ============================================

-- 統一的時間戳更新函數
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

-- 為 Web 應用表建立觸發器

-- User 表更新時間觸發器
CREATE TRIGGER update_user_updated_at
    BEFORE UPDATE ON "User"
    FOR EACH ROW
    EXECUTE FUNCTION update_date_updated_column();

-- Application 表更新時間觸發器
CREATE TRIGGER update_application_updated_at
    BEFORE UPDATE ON Application
    FOR EACH ROW
    EXECUTE FUNCTION update_date_updated_column();

-- ApplicationAttachment 表更新時間觸發器
CREATE TRIGGER update_attachment_updated_at
    BEFORE UPDATE ON ApplicationAttachment
    FOR EACH ROW
    EXECUTE FUNCTION update_date_updated_column();

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'Web 應用資料表建立完成！';
    RAISE NOTICE '版本: V3.1';
    RAISE NOTICE '';
    RAISE NOTICE '已建立 6 個 Web 應用表：';
    RAISE NOTICE '1. User - 使用者管理';
    RAISE NOTICE '2. Application - 申編單主表（取代 ApplicationForm）';
    RAISE NOTICE '3. ApplicationAttachment - 附件管理';
    RAISE NOTICE '4. UserSession - 工作階段';
    RAISE NOTICE '5. ApplicationLog - 應用程式日誌';
    RAISE NOTICE '6. AuditLog - 稽核日誌';
    RAISE NOTICE '';
    RAISE NOTICE '時間戳命名: 統一使用 date_created/date_updated';
    RAISE NOTICE '已建立所有索引和觸發器';
    RAISE NOTICE '=========================================';
END $$;
