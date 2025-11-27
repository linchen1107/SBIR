-- ============================================
-- PostgreSQL 資料庫註解更新腳本
-- 用途: 為 ApplicationForm, ApplicationFormDetail, TechnicalDocument, Item_Document_xref 加上中文註解
-- 建立日期: 2025-11-20
-- 版本: V3.2
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. ApplicationForm (申編單檔)
-- ============================================
COMMENT ON TABLE ApplicationForm IS '申編單檔';
COMMENT ON COLUMN ApplicationForm.form_id IS '表單ID (自動編號)';
COMMENT ON COLUMN ApplicationForm.form_no IS '表單編號';
COMMENT ON COLUMN ApplicationForm.submit_status IS '申編單提送狀態';
COMMENT ON COLUMN ApplicationForm.yetl IS 'YETL';
COMMENT ON COLUMN ApplicationForm.applicant_accounting_code IS '申請單位會計編號';
COMMENT ON COLUMN ApplicationForm.created_date IS '建立日期';
COMMENT ON COLUMN ApplicationForm.updated_date IS '更新日期';

-- ============================================
-- 2. ApplicationFormDetail (申編單明細檔)
-- ============================================
COMMENT ON TABLE ApplicationFormDetail IS '申編單明細檔';
COMMENT ON COLUMN ApplicationFormDetail.detail_id IS '明細ID (自動編號)';
COMMENT ON COLUMN ApplicationFormDetail.form_id IS '表單ID';
COMMENT ON COLUMN ApplicationFormDetail.item_seq IS '項次';
COMMENT ON COLUMN ApplicationFormDetail.item_id IS '品項識別碼';
COMMENT ON COLUMN ApplicationFormDetail.document_source IS '文件來源';
COMMENT ON COLUMN ApplicationFormDetail.image_path IS '圖片路徑';
COMMENT ON COLUMN ApplicationFormDetail.created_at IS '建立時間';
COMMENT ON COLUMN ApplicationFormDetail.updated_at IS '更新時間';

-- ============================================
-- 3. TechnicalDocument (技術文件檔)
-- ============================================
COMMENT ON TABLE TechnicalDocument IS '技術文件檔';
COMMENT ON COLUMN TechnicalDocument.document_id IS '文件ID (自動編號)';
COMMENT ON COLUMN TechnicalDocument.document_name IS '圖名/書名';
COMMENT ON COLUMN TechnicalDocument.document_version IS '版次';
COMMENT ON COLUMN TechnicalDocument.shipyard_drawing_no IS '船廠圖號';
COMMENT ON COLUMN TechnicalDocument.design_drawing_no IS '設計圖號';
COMMENT ON COLUMN TechnicalDocument.document_type IS '資料類型';
COMMENT ON COLUMN TechnicalDocument.document_category IS '資料類別';
COMMENT ON COLUMN TechnicalDocument.language IS '語言';
COMMENT ON COLUMN TechnicalDocument.security_level IS '機密等級';
COMMENT ON COLUMN TechnicalDocument.eswbs_code IS 'ESWBS';
COMMENT ON COLUMN TechnicalDocument.accounting_code IS '會計編號';
COMMENT ON COLUMN TechnicalDocument.created_at IS '建立時間';
COMMENT ON COLUMN TechnicalDocument.updated_at IS '更新時間';

-- ============================================
-- 4. Item_Document_xref (品項文件關聯檔)
-- ============================================
COMMENT ON TABLE Item_Document_xref IS '品項文件關聯檔';
COMMENT ON COLUMN Item_Document_xref.item_uuid IS '品項UUID';
COMMENT ON COLUMN Item_Document_xref.document_id IS '文件ID';
COMMENT ON COLUMN Item_Document_xref.created_at IS '建立時間';
COMMENT ON COLUMN Item_Document_xref.updated_at IS '更新時間';

-- ============================================
-- 完成訊息
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫註解更新完成 (V3.2)';
    RAISE NOTICE '已更新: ApplicationForm, ApplicationFormDetail, TechnicalDocument, Item_Document_xref';
    RAISE NOTICE '=========================================';
END $$;
