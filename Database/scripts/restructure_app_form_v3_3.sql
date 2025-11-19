-- ============================================
-- PostgreSQL 資料庫架構調整腳本
-- 用途: 調整 ApplicationForm 結構 (Item -> Form -> Detail)
-- 1. ApplicationForm 新增 item_id (FK)
-- 2. ApplicationFormDetail 移除 item_id
-- 建立日期: 2025-11-20
-- 版本: V3.3
-- ============================================

\c sbir_equipment_db_v2;

BEGIN;

-- 1. ApplicationForm: 新增 item_id 欄位
ALTER TABLE ApplicationForm 
ADD COLUMN item_id UUID;

-- 2. ApplicationForm: 建立外鍵關聯
ALTER TABLE ApplicationForm 
ADD CONSTRAINT fk_app_form_item 
FOREIGN KEY (item_id) REFERENCES Item(item_uuid) ON DELETE SET NULL;

-- 3. ApplicationForm: 建立索引
CREATE INDEX idx_app_form_item ON ApplicationForm(item_id);

-- 4. ApplicationForm: 加上註解
COMMENT ON COLUMN ApplicationForm.item_id IS '品項識別碼 (FK)';

-- 5. ApplicationFormDetail: 移除 item_id 欄位 (及其關聯的索引/外鍵)
-- Note: Dropping the column automatically drops the FK and Index associated with it
ALTER TABLE ApplicationFormDetail 
DROP COLUMN item_id;

COMMIT;

-- ============================================
-- 完成訊息
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫架構調整完成 (V3.3)';
    RAISE NOTICE '已將 item_id 從 ApplicationFormDetail 移至 ApplicationForm';
    RAISE NOTICE '=========================================';
END $$;
