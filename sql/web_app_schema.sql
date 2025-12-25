-- ====================================================================
--  Schema: web_app
--  Description: Contains all tables related to the web application,
--               such as users, sessions, and application forms.
--  Generated from: Alembic migration scripts
-- ====================================================================

-- Extensions and helper functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    unix_ts_ms BIGINT;
    rand_bytes BYTEA;
    result BYTEA := decode(repeat('00', 16), 'hex');
BEGIN
    unix_ts_ms := floor(EXTRACT(EPOCH FROM clock_timestamp()) * 1000)::BIGINT;
    rand_bytes := gen_random_bytes(10);

    result := set_byte(result, 0, ((unix_ts_ms >> 40) & 255)::int);
    result := set_byte(result, 1, ((unix_ts_ms >> 32) & 255)::int);
    result := set_byte(result, 2, ((unix_ts_ms >> 24) & 255)::int);
    result := set_byte(result, 3, ((unix_ts_ms >> 16) & 255)::int);
    result := set_byte(result, 4, ((unix_ts_ms >> 8) & 255)::int);
    result := set_byte(result, 5, (unix_ts_ms & 255)::int);

    result := set_byte(result, 6, (112 | (get_byte(rand_bytes, 0) & 15))::int);
    result := set_byte(result, 7, get_byte(rand_bytes, 1));

    result := set_byte(result, 8, (128 | (get_byte(rand_bytes, 2) & 63))::int);
    result := set_byte(result, 9, get_byte(rand_bytes, 3));
    result := set_byte(result, 10, get_byte(rand_bytes, 4));
    result := set_byte(result, 11, get_byte(rand_bytes, 5));
    result := set_byte(result, 12, get_byte(rand_bytes, 6));
    result := set_byte(result, 13, get_byte(rand_bytes, 7));
    result := set_byte(result, 14, get_byte(rand_bytes, 8));
    result := set_byte(result, 15, get_byte(rand_bytes, 9));

    RETURN encode(result, 'hex')::uuid;
END;
$$;

--
-- Table structure for table system_settings
--
-- CREATE TABLE web_app.system_settings (
    setting_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(50),
    description TEXT,
    is_public BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (setting_id)
);
CREATE INDEX ix_web_app_system_settings_is_public ON web_app.system_settings (is_public);
CREATE UNIQUE INDEX ix_web_app_system_settings_setting_key ON web_app.system_settings (setting_key);

--
-- Table structure for table system_statistics
--
-- CREATE TABLE web_app.system_statistics (
    stat_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    stat_date DATE NOT NULL,
    total_users INTEGER,
    active_users INTEGER,
    total_searches INTEGER,
    avg_response_time_ms NUMERIC(10, 2),
    popular_search_terms JSON,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (stat_id)
);
CREATE UNIQUE INDEX ix_web_app_system_statistics_stat_date ON web_app.system_statistics (stat_date);

--
-- Table structure for table users
--
CREATE TABLE web_app.users (
    id UUID NOT NULL DEFAULT uuid_generate_v7(),
    username VARCHAR(80) NOT NULL,
    email VARCHAR(120) NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    english_code VARCHAR(10),
    full_name VARCHAR(100),
    department VARCHAR(100),
    position VARCHAR(100),
    phone VARCHAR(50),
    role VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL,
    is_verified BOOLEAN,
    email_verified_at TIMESTAMP WITHOUT TIME ZONE,
    last_login_at TIMESTAMP WITHOUT TIME ZONE,
    failed_login_attempts INTEGER,
    locked_until TIMESTAMP WITHOUT TIME ZONE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    PRIMARY KEY (id)
);
CREATE INDEX ix_web_app_users_created_at ON web_app.users (created_at);
CREATE UNIQUE INDEX ix_web_app_users_email ON web_app.users (email);
CREATE UNIQUE INDEX ix_web_app_users_english_code ON web_app.users (english_code);
CREATE UNIQUE INDEX ix_web_app_users_username ON web_app.users (username);

--
-- Table structure for table applications
--
CREATE TABLE web_app.applications (
    id UUID NOT NULL DEFAULT uuid_generate_v7(),
    user_id UUID NOT NULL,
    form_serial_number VARCHAR(50),
    part_number VARCHAR(50),
    english_name VARCHAR(255),
    chinese_name VARCHAR(255),
    inc_code VARCHAR(20),
    fiig_code VARCHAR(20),
    status VARCHAR(50),
    sub_status VARCHAR(50), -- 新增：用於存儲更細微的流程狀態
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    deleted_at TIMESTAMP WITHOUT TIME ZONE,
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
    ship_type VARCHAR(100),
    cid_no VARCHAR(100),
    model_type VARCHAR(100),
    equipment_name VARCHAR(255),
    usage_location VARCHAR(255),
    quantity_per_unit INTEGER,
    mrc_data JSON,
    document_reference VARCHAR(255),
    manufacturer_name VARCHAR(255),
    agent_name VARCHAR(255),
    applicant_unit VARCHAR(100),
    contact_info VARCHAR(100),
    apply_date DATE,
    -- NSN 正式料號相關欄位
    official_nsn_stamp VARCHAR(10), -- 蓋章碼（預留彈性，目前為5碼數字）
    official_nsn_final VARCHAR(20), -- 完整正式料號
    nsn_filled_at TIMESTAMP WITHOUT TIME ZONE, -- NSN 填寫時間
    nsn_filled_by UUID, -- NSN 填寫者
    -- 已結單狀態相關欄位
    closed_at TIMESTAMP WITHOUT TIME ZONE, -- 結單時間
    closed_by UUID, -- 結單者
    PRIMARY KEY (id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id),
    FOREIGN KEY(nsn_filled_by) REFERENCES web_app.users (id),
    FOREIGN KEY(closed_by) REFERENCES web_app.users (id)
);
CREATE INDEX ix_web_app_applications_created_at ON web_app.applications (created_at);
CREATE INDEX ix_web_app_applications_deleted_at ON web_app.applications (deleted_at);
CREATE INDEX ix_web_app_applications_form_serial_number ON web_app.applications (form_serial_number);
CREATE INDEX ix_web_app_applications_official_nsn_stamp ON web_app.applications (official_nsn_stamp);
CREATE INDEX ix_web_app_applications_official_nsn_final ON web_app.applications (official_nsn_final);
CREATE INDEX ix_web_app_applications_status ON web_app.applications (status);
CREATE INDEX ix_web_app_applications_sub_status ON web_app.applications (sub_status);
CREATE INDEX ix_web_app_applications_user_id ON web_app.applications (user_id);

--
-- Table structure for table audit_logs
--
CREATE TABLE web_app.audit_logs (
    log_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN,
    error_message TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (log_id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id)
);
CREATE INDEX ix_web_app_audit_logs_action ON web_app.audit_logs (action);
CREATE INDEX ix_web_app_audit_logs_created_at ON web_app.audit_logs (created_at);
CREATE INDEX ix_web_app_audit_logs_user_id ON web_app.audit_logs (user_id);

--
-- Table structure for table search_history
--
-- CREATE TABLE web_app.search_history (
    search_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    user_id UUID,
    session_id VARCHAR(255),
    search_query TEXT NOT NULL,
    search_type VARCHAR(50),
    search_filters JSON,
    results_count INTEGER,
    execution_time_ms INTEGER,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (search_id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id)
);
CREATE INDEX ix_web_app_search_history_created_at ON web_app.search_history (created_at);
CREATE INDEX ix_web_app_search_history_search_type ON web_app.search_history (search_type);
CREATE INDEX ix_web_app_search_history_user_id ON web_app.search_history (user_id);

--
-- Table structure for table user_favorites
--
-- CREATE TABLE web_app.user_favorites (
    favorite_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    user_id UUID NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    item_code VARCHAR(100) NOT NULL,
    item_name TEXT,
    item_description TEXT,
    notes TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (favorite_id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id)
);
CREATE INDEX idx_favorites_type_code ON web_app.user_favorites (item_type, item_code);
CREATE UNIQUE INDEX idx_favorites_unique ON web_app.user_favorites (user_id, item_type, item_code);
CREATE INDEX ix_web_app_user_favorites_user_id ON web_app.user_favorites (user_id);

--
-- Table structure for table user_sessions
--
CREATE TABLE web_app.user_sessions (
    session_id VARCHAR(255) NOT NULL,
    user_id UUID NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN,
    remember_me BOOLEAN,
    expires_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    last_activity_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (session_id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id)
);
CREATE INDEX ix_web_app_user_sessions_expires_at ON web_app.user_sessions (expires_at);
CREATE INDEX ix_web_app_user_sessions_is_active ON web_app.user_sessions (is_active);
CREATE INDEX ix_web_app_user_sessions_user_id ON web_app.user_sessions (user_id);

--
-- Table structure for table user_settings
--
-- CREATE TABLE web_app.user_settings (
    setting_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    user_id UUID NOT NULL,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (setting_id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id)
);
CREATE UNIQUE INDEX idx_user_settings_unique ON web_app.user_settings (user_id, setting_key);
CREATE INDEX ix_web_app_user_settings_user_id ON web_app.user_settings (user_id);

--
-- Table structure for table application_attachments
--
CREATE TABLE web_app.application_attachments (
    id UUID NOT NULL DEFAULT uuid_generate_v7(),
    application_id UUID NOT NULL,
    user_id UUID NOT NULL,
    file_data BYTEA NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    mimetype VARCHAR(100) NOT NULL,
    file_type VARCHAR(20) NOT NULL DEFAULT 'other', -- 'image' / 'pdf' / 'other'
    page_selection VARCHAR(200), -- PDF 頁碼選擇 (例如: "1-3,5,7-9")
    sort_order INTEGER DEFAULT 0, -- PDF 合併順序
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY(application_id) REFERENCES web_app.applications (id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id)
);
CREATE INDEX ix_web_app_application_attachments_application_id ON web_app.application_attachments (application_id);
CREATE INDEX ix_web_app_application_attachments_file_type ON web_app.application_attachments (file_type);
CREATE INDEX ix_web_app_application_attachments_sort_order ON web_app.application_attachments (application_id, sort_order);

--
-- Table structure for table application_logs
--
CREATE TABLE web_app.application_logs (
    log_id UUID NOT NULL DEFAULT uuid_generate_v7(),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    level VARCHAR(10) NOT NULL,
    logger VARCHAR(100),
    message TEXT NOT NULL,
    -- 請求相關資訊
    request_id VARCHAR(36),
    method VARCHAR(10),
    path VARCHAR(500),
    status_code INTEGER,
    elapsed_time_ms NUMERIC(10, 2),
    -- 用戶資訊
    user_id UUID,
    remote_addr INET,
    user_agent TEXT,
    -- 模組資訊
    module VARCHAR(100),
    function VARCHAR(100),
    line INTEGER,
    -- Exception 資訊
    exception_type VARCHAR(100),
    exception_message TEXT,
    exception_traceback JSONB,
    -- 額外欄位
    extra_fields JSONB,
    -- 由觸發器填入的 UTC 日期欄位（用於分區和索引）
    created_date DATE,
    PRIMARY KEY (log_id),
    FOREIGN KEY(user_id) REFERENCES web_app.users (id) ON DELETE SET NULL
);

-- 索引
CREATE INDEX idx_app_logs_timestamp ON web_app.application_logs (timestamp DESC);
CREATE INDEX idx_app_logs_level ON web_app.application_logs (level);
CREATE INDEX idx_app_logs_request_id ON web_app.application_logs (request_id);
CREATE INDEX idx_app_logs_user_id ON web_app.application_logs (user_id);
CREATE INDEX idx_app_logs_created_date ON web_app.application_logs (created_date);

-- 全文搜尋索引
CREATE INDEX idx_app_logs_message_fts ON web_app.application_logs USING gin(to_tsvector('simple', message));

-- 觸發器函數：根據 timestamp (UTC) 填入 created_date
CREATE OR REPLACE FUNCTION web_app.set_application_log_created_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_date IS NULL THEN
        NEW.created_date := (NEW."timestamp" AT TIME ZONE 'UTC')::DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 觸發器：確保新增或更新時自動填入 created_date
CREATE TRIGGER trg_application_logs_set_created_date
BEFORE INSERT OR UPDATE ON web_app.application_logs
FOR EACH ROW EXECUTE FUNCTION web_app.set_application_log_created_date();

-- 若資料表已存在舊資料，回填 created_date
UPDATE web_app.application_logs
SET created_date = ("timestamp" AT TIME ZONE 'UTC')::DATE
WHERE created_date IS NULL;

-- 清理舊日誌的函數
CREATE OR REPLACE FUNCTION web_app.cleanup_old_logs(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM web_app.application_logs
    WHERE timestamp < NOW() - (days_to_keep || ' days')::INTERVAL;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 註解
COMMENT ON TABLE web_app.application_logs IS '應用程式日誌記錄表';
COMMENT ON COLUMN web_app.application_logs.log_id IS '日誌 ID（UUID v7 主鍵）';
COMMENT ON COLUMN web_app.application_logs.timestamp IS '日誌時間戳（UTC）';
COMMENT ON COLUMN web_app.application_logs.level IS '日誌級別（DEBUG, INFO, WARNING, ERROR, CRITICAL）';
COMMENT ON COLUMN web_app.application_logs.request_id IS '請求 ID（UUID），用於追蹤單一請求';
COMMENT ON COLUMN web_app.application_logs.elapsed_time_ms IS '請求處理時間（毫秒）';
COMMENT ON FUNCTION web_app.cleanup_old_logs IS '清理超過指定天數的舊日誌';
