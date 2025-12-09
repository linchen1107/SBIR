-- ============================================
-- Schema 重構腳本: public -> web_app
-- 建立日期: 2025-12-08
-- 用途: 將現有的 public schema 更名為 web_app，並建立新的 public schema
-- ============================================

-- 1. 將 public schema 更名為 web_app
ALTER SCHEMA public RENAME TO web_app;

-- 2. 建立新的 public schema
CREATE SCHEMA public;

-- 3. 設定新 public schema 的權限 (與標準 PostgreSQL 安裝一致)
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- 4. 輸出完成訊息
DO $$
BEGIN
    RAISE NOTICE 'Schema 重構完成:';
    RAISE NOTICE '1. 舊 public schema 已更名為 web_app';
    RAISE NOTICE '2. 已建立新的空 public schema';
END $$;
