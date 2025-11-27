-- ============================================
-- 申編單表結構修改腳本
-- 版本: V2.4
-- 修改日期: 2025-11-18
-- 修改內容:
--   1. 合併 ApplicationForm 和 ApplicationFormDetail 為單一表
--   2. 移除 YETL 欄位
--   3. 新增 ApplicationAttachment 附件檔表
-- ============================================

-- 連接到資料庫
\c sbir_equipment_db;

-- ============================================
-- 步驟 1: 備份現有資料（如有需要）
-- ============================================

-- 建立備份表（可選）
-- CREATE TABLE ApplicationForm_backup AS SELECT * FROM ApplicationForm;
-- CREATE TABLE ApplicationFormDetail_backup AS SELECT * FROM ApplicationFormDetail;

-- ============================================
-- 步驟 2: 刪除舊的申編單相關表
-- ============================================

-- 先刪除有外鍵依賴的表
DROP TABLE IF EXISTS ApplicationFormDetail CASCADE;
DROP TABLE IF EXISTS ApplicationForm CASCADE;

-- 刪除相關索引（如果存在）
DROP INDEX IF EXISTS idx_app_form_no;
DROP INDEX IF EXISTS idx_app_detail_form;
DROP INDEX IF EXISTS idx_app_detail_item;

-- ============================================
-- 步驟 3: 建立新的申編單表（合併版）
-- ============================================

CREATE TABLE ApplicationForm (
    form_id SERIAL PRIMARY KEY,
    form_no VARCHAR(50),
    item_seq INT,
    submit_status VARCHAR(20),
    applicant_accounting_code VARCHAR(20),
    item_id VARCHAR(20),
    document_source VARCHAR(100),
    created_date DATE DEFAULT CURRENT_DATE,
    updated_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES Item(item_id) ON DELETE SET NULL
);

-- 表格註解
COMMENT ON TABLE ApplicationForm IS '申編單檔（合併版 V2.4）';
COMMENT ON COLUMN ApplicationForm.form_id IS '表單ID（自動編號）';
COMMENT ON COLUMN ApplicationForm.form_no IS '表單編號';
COMMENT ON COLUMN ApplicationForm.item_seq IS '項次';
COMMENT ON COLUMN ApplicationForm.submit_status IS '申編單提送狀態';
COMMENT ON COLUMN ApplicationForm.applicant_accounting_code IS '申請單位會計編號';
COMMENT ON COLUMN ApplicationForm.item_id IS '品項識別碼';
COMMENT ON COLUMN ApplicationForm.document_source IS '文件來源';
COMMENT ON COLUMN ApplicationForm.created_date IS '建立日期';
COMMENT ON COLUMN ApplicationForm.updated_date IS '更新日期';
COMMENT ON COLUMN ApplicationForm.created_at IS '建立時間';
COMMENT ON COLUMN ApplicationForm.updated_at IS '更新時間';

-- ============================================
-- 步驟 4: 建立新的附件檔表
-- ============================================

CREATE TABLE ApplicationAttachment (
    attachment_id SERIAL PRIMARY KEY,
    form_id INT NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_type VARCHAR(20),
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    description VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (form_id) REFERENCES ApplicationForm(form_id) ON DELETE CASCADE
);

-- 表格註解
COMMENT ON TABLE ApplicationAttachment IS '申編單附件檔';
COMMENT ON COLUMN ApplicationAttachment.attachment_id IS '附件ID（自動編號）';
COMMENT ON COLUMN ApplicationAttachment.form_id IS '表單ID';
COMMENT ON COLUMN ApplicationAttachment.file_name IS '檔案名稱';
COMMENT ON COLUMN ApplicationAttachment.file_type IS '檔案類型（PDF/PNG/JPG等）';
COMMENT ON COLUMN ApplicationAttachment.file_path IS '檔案路徑';
COMMENT ON COLUMN ApplicationAttachment.file_size IS '檔案大小（bytes）';
COMMENT ON COLUMN ApplicationAttachment.description IS '附件說明';
COMMENT ON COLUMN ApplicationAttachment.created_at IS '建立時間';
COMMENT ON COLUMN ApplicationAttachment.updated_at IS '更新時間';

-- ============================================
-- 步驟 5: 建立索引
-- ============================================

-- 申編單索引
CREATE INDEX idx_app_form_no ON ApplicationForm(form_no);
CREATE INDEX idx_app_form_item ON ApplicationForm(item_id);
CREATE INDEX idx_app_form_status ON ApplicationForm(submit_status);

-- 附件檔索引
CREATE INDEX idx_attachment_form ON ApplicationAttachment(form_id);
CREATE INDEX idx_attachment_type ON ApplicationAttachment(file_type);

-- ============================================
-- 步驟 6: 建立觸發器
-- ============================================

-- 申編單更新時間觸發器
DROP TRIGGER IF EXISTS update_app_form_updated_at ON ApplicationForm;
CREATE TRIGGER update_app_form_updated_at
    BEFORE UPDATE ON ApplicationForm
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 附件檔更新時間觸發器
CREATE TRIGGER update_attachment_updated_at
    BEFORE UPDATE ON ApplicationAttachment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '申編單表結構修改完成！';
    RAISE NOTICE '版本: V2.4';
    RAISE NOTICE '';
    RAISE NOTICE '變更內容:';
    RAISE NOTICE '1. 合併 ApplicationForm + ApplicationFormDetail';
    RAISE NOTICE '2. 移除 YETL 欄位';
    RAISE NOTICE '3. 新增 ApplicationAttachment 附件檔表';
    RAISE NOTICE '';
    RAISE NOTICE '新表結構:';
    RAISE NOTICE '- ApplicationForm: 申編單（合併版）';
    RAISE NOTICE '- ApplicationAttachment: 附件檔（PDF/圖片）';
    RAISE NOTICE '=========================================';
END $$;
