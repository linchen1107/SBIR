-- ====================================================================
--  Migration: Add attachment fields for enhanced PDF management
--  Date: 2025-01-14
--  Description: Adds file_type, page_selection, and sort_order fields
--               to application_attachments table
-- ====================================================================

-- Add new columns to application_attachments table
ALTER TABLE web_app.application_attachments
ADD COLUMN IF NOT EXISTS file_type VARCHAR(20) NOT NULL DEFAULT 'other',
ADD COLUMN IF NOT EXISTS page_selection VARCHAR(200),
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Add comment to columns
COMMENT ON COLUMN web_app.application_attachments.file_type IS '附件類型: image / pdf / other';
COMMENT ON COLUMN web_app.application_attachments.page_selection IS 'PDF 頁碼選擇 (例如: 1-3,5,7-9)';
COMMENT ON COLUMN web_app.application_attachments.sort_order IS 'PDF 合併順序 (數字越小越前面)';

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS ix_web_app_application_attachments_file_type
ON web_app.application_attachments (file_type);

CREATE INDEX IF NOT EXISTS ix_web_app_application_attachments_sort_order
ON web_app.application_attachments (application_id, sort_order);

-- Update existing records based on mimetype
UPDATE web_app.application_attachments
SET file_type = 'image'
WHERE mimetype LIKE 'image/%' AND file_type = 'other';

UPDATE web_app.application_attachments
SET file_type = 'pdf'
WHERE mimetype = 'application/pdf' AND file_type = 'other';

-- Set default sort_order for existing PDFs (by creation date)
WITH ranked_pdfs AS (
    SELECT
        id,
        ROW_NUMBER() OVER (PARTITION BY application_id ORDER BY created_at) - 1 AS new_order
    FROM web_app.application_attachments
    WHERE file_type = 'pdf' AND sort_order = 0
)
UPDATE web_app.application_attachments a
SET sort_order = r.new_order
FROM ranked_pdfs r
WHERE a.id = r.id;

-- Verification query (optional - uncomment to run)
-- SELECT
--     id,
--     application_id,
--     original_filename,
--     file_type,
--     page_selection,
--     sort_order
-- FROM web_app.application_attachments
-- ORDER BY application_id, sort_order;
