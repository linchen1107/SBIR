-- ============================================================
-- 步驟 2：遷移 Users 資料
-- 將 old_data.users 遷移到 web_app."User"
-- 日期：2025-12-26
-- 版本：v1.0
-- ============================================================

-- 設定搜尋路徑
SET search_path TO web_app, public;

-- ============================================================
-- 前置檢查
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'old_data' AND table_name = 'users') THEN
        RAISE EXCEPTION '錯誤：old_data.users 表不存在，請先執行 01_create_old_data_staging.sql 並匯入資料';
    END IF;
END $$;

-- ============================================================
-- 遷移 Users
-- ============================================================

-- 更新已存在的使用者（用真實資料覆蓋佔位符）
UPDATE web_app."User" u
SET 
    username = ou.username,
    email = ou.email,
    password_hash = ou.password_hash,
    english_code = ou.english_code,
    full_name = ou.full_name,
    department = ou.department,
    position = ou.position,
    phone = ou.phone,
    role = ou.role,
    is_active = ou.is_active,
    is_verified = ou.is_verified,
    email_verified_at = ou.email_verified_at,
    last_login_at = ou.last_login_at,
    failed_login_attempts = ou.failed_login_attempts,
    locked_until = ou.locked_until,
    date_created = ou.created_at,
    date_updated = ou.updated_at
FROM old_data.users ou
WHERE u.id = ou.id;

-- 插入不存在的使用者
INSERT INTO web_app."User" (
    id, username, email, password_hash, english_code, 
    full_name, department, position, phone, role, 
    is_active, is_verified, email_verified_at, last_login_at, 
    failed_login_attempts, locked_until, date_created, date_updated
)
SELECT 
    ou.id, ou.username, ou.email, ou.password_hash, ou.english_code,
    ou.full_name, ou.department, ou.position, ou.phone, ou.role,
    ou.is_active, ou.is_verified, ou.email_verified_at, ou.last_login_at,
    ou.failed_login_attempts, ou.locked_until, ou.created_at, ou.updated_at
FROM old_data.users ou
WHERE NOT EXISTS (SELECT 1 FROM web_app."User" u WHERE u.id = ou.id)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 驗證結果
-- ============================================================

SELECT 'Users 遷移完成' AS status;
SELECT 
    (SELECT COUNT(*) FROM old_data.users) AS "來源記錄數",
    (SELECT COUNT(*) FROM web_app."User") AS "目標記錄數";
