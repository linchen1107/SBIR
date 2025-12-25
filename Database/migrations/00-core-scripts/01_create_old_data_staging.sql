-- ============================================================
-- 步驟 1：建立舊資料暫存 Schema 和表
-- 用於從匯出檔案匯入舊 applications 和 users 資料
-- 日期：2025-12-26
-- 版本：v1.1 (修正 id 為 UUID 類型)
-- ============================================================

-- 設定搜尋路徑
SET search_path TO web_app, public;

-- 建立暫存 schema（如果不存在）
CREATE SCHEMA IF NOT EXISTS old_data;

-- ============================================================
-- 1. 建立舊 users 表結構
-- ============================================================

DROP TABLE IF EXISTS old_data.users CASCADE;

CREATE TABLE old_data.users (
    id UUID PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    email VARCHAR(120) NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    english_code VARCHAR(10),
    full_name VARCHAR(100),
    department VARCHAR(100),
    position VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE INDEX idx_old_users_email ON old_data.users(email);
CREATE INDEX idx_old_users_username ON old_data.users(username);

COMMENT ON TABLE old_data.users IS '舊資料庫 users 表的暫存副本，用於資料遷移';

-- ============================================================
-- 2. 建立舊 applications 表結構（51 欄位）
-- 注意：id 為 UUID 類型（非 SERIAL）
-- ============================================================

DROP TABLE IF EXISTS old_data.applications CASCADE;

CREATE TABLE old_data.applications (
    id UUID PRIMARY KEY,  -- 重要：UUID 類型
    user_id UUID,
    form_serial_number VARCHAR(100),
    part_number VARCHAR(100),
    english_name VARCHAR(500),
    chinese_name VARCHAR(500),
    inc_code VARCHAR(50),
    fiig_code VARCHAR(50),
    status VARCHAR(50),
    sub_status VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    accounting_unit_code VARCHAR(50),
    issue_unit VARCHAR(50),
    unit_price DECIMAL(15,2),
    spec_indicator VARCHAR(10),
    unit_pack_quantity VARCHAR(50),
    storage_life_months INTEGER,
    storage_life_action_code VARCHAR(10),
    storage_type_code VARCHAR(10),
    secrecy_code VARCHAR(10),
    expendability_code VARCHAR(10),
    repairability_code VARCHAR(10),
    manufacturability_code VARCHAR(10),
    source_code VARCHAR(10),
    category_code VARCHAR(10),
    system_code VARCHAR(100),
    pn_acquisition_level VARCHAR(10),
    pn_acquisition_source VARCHAR(50),
    manufacturer VARCHAR(100),
    part_number_reference VARCHAR(200),
    ship_type VARCHAR(100),
    cid_no VARCHAR(100),
    model_type VARCHAR(100),
    equipment_name VARCHAR(200),
    usage_location VARCHAR(200),
    quantity_per_unit INTEGER,
    mrc_data JSONB,
    document_reference VARCHAR(500),
    manufacturer_name VARCHAR(200),
    agent_name VARCHAR(200),
    applicant_unit VARCHAR(200),
    contact_info VARCHAR(200),
    apply_date DATE,
    official_nsn_stamp VARCHAR(100),
    official_nsn_final VARCHAR(100),
    nsn_filled_at TIMESTAMP,
    nsn_filled_by UUID,
    closed_at TIMESTAMP,
    closed_by UUID
);

-- 建立索引以加速遷移查詢
CREATE INDEX idx_old_applications_part_number ON old_data.applications(part_number);
CREATE INDEX idx_old_applications_user_id ON old_data.applications(user_id);
CREATE INDEX idx_old_applications_manufacturer_name ON old_data.applications(manufacturer_name);
CREATE INDEX idx_old_applications_document_reference ON old_data.applications(document_reference);

COMMENT ON TABLE old_data.applications IS '舊資料庫 applications 表的暫存副本，用於資料遷移（51欄位→v3.2正規化結構）';

-- ============================================================
-- 執行完成提示
-- ============================================================
SELECT '步驟 1 完成：old_data schema 已建立' AS status;
SELECT 'old_data.users' AS table_name, '準備匯入使用者資料' AS next_step
UNION ALL
SELECT 'old_data.applications' AS table_name, '準備匯入申請單資料' AS next_step;
