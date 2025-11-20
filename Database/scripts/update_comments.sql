-- Update Item Table Comments
COMMENT ON COLUMN public.item.item_id IS '品項識別號';
COMMENT ON COLUMN public.item.item_id_last5 IS '品項識別碼(後五碼)';
COMMENT ON COLUMN public.item.nsn IS '國家料號';
COMMENT ON COLUMN public.item.item_name_zh_short IS '中文品名(9字內)';
COMMENT ON COLUMN public.item.item_name_en IS '英文品名';
COMMENT ON COLUMN public.item.weight_kg IS '重量(KG)';

-- Update Equipment Table Comments
COMMENT ON COLUMN public.equipment.equipment_id IS '單機識別碼';
COMMENT ON COLUMN public.equipment.parent_cid IS '上層適用裝備單機識別碼CID';
COMMENT ON COLUMN public.equipment.eswbs_code IS '族群結構碼(ESWBS)';
COMMENT ON COLUMN public.equipment.system_function_name IS '系統功能名稱(中+英) (族群結構碼上的名稱)';

-- Update Part Number Xref Table Comments
COMMENT ON COLUMN public.part_number_xref.part_number IS '配件號碼';
COMMENT ON COLUMN public.part_number_xref.obtain_level IS '參考號獲得程度';
COMMENT ON COLUMN public.part_number_xref.obtain_source IS '參考號獲得來源';

-- Update Technical Document Table Comments
COMMENT ON COLUMN public.technicaldocument.document_name IS '書名';
COMMENT ON COLUMN public.technicaldocument.document_version IS '版次';
COMMENT ON COLUMN public.technicaldocument.eswbs_code IS '族群結構碼(ESWBS)';

-- Update Application Form Table Comments
COMMENT ON COLUMN public.applicationform.form_no IS '表單 編號';
COMMENT ON COLUMN public.applicationform.submit_status IS '申編單 提送狀態';
