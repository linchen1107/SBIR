-- 更新 Application 表的註解（申請單 → 申編單）
COMMENT ON TABLE Application IS '申編單主表（完整版，取代舊的 ApplicationForm）';
COMMENT ON COLUMN Application.id IS '申編單UUID（主鍵）';
COMMENT ON COLUMN Application.status IS '申編單狀態';
COMMENT ON TABLE ApplicationAttachment IS '申編單附件表';
