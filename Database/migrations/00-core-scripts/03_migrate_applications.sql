-- ============================================================
-- 步驟 3：遷移 Applications 資料到正規化結構
-- 將 old_data.applications (51欄位) 拆分到多個正規化表格
-- 日期：2025-12-26
-- 版本：v1.1
-- ============================================================

-- 設定搜尋路徑
SET search_path TO web_app, public;

-- ============================================================
-- 前置檢查
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'old_data' AND table_name = 'applications') THEN
        RAISE EXCEPTION '錯誤：old_data.applications 表不存在，請先執行步驟 1 並匯入資料';
    END IF;
    
    -- 檢查是否已遷移 Users
    IF (SELECT COUNT(*) FROM web_app."User") = 0 THEN
        RAISE EXCEPTION '錯誤：web_app.User 表為空，請先執行步驟 2 遷移使用者';
    END IF;
END $$;

-- ============================================================
-- 階段 1：建立缺少的 User 記錄
-- 處理 applications 中的 user_id, closed_by, nsn_filled_by
-- ============================================================

INSERT INTO web_app."User" (id, username, email, password_hash, role)
SELECT uid, 
    'user_' || LEFT(uid::text, 8), 
    'user_' || LEFT(uid::text, 8) || '@temp.local', 
    'migrated_placeholder', 
    'user'
FROM (
    SELECT user_id AS uid FROM old_data.applications WHERE user_id IS NOT NULL
    UNION
    SELECT closed_by AS uid FROM old_data.applications WHERE closed_by IS NOT NULL
    UNION
    SELECT nsn_filled_by AS uid FROM old_data.applications WHERE nsn_filled_by IS NOT NULL
) AS all_users
WHERE uid NOT IN (SELECT id FROM web_app."User")
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 階段 2：建立 Item 記錄（品項主檔）
-- ============================================================

INSERT INTO web_app.item (
    item_uuid,
    item_code,
    item_name_zh,
    item_name_en,
    item_type,
    uom,
    status,
    date_created,
    date_updated
)
SELECT DISTINCT ON (a.part_number)
    gen_random_uuid(),
    a.part_number,
    a.chinese_name,
    a.english_name,
    'SEMI',
    COALESCE(a.issue_unit, 'EA'),
    'Active',
    COALESCE(a.created_at, NOW()),
    COALESCE(a.updated_at, NOW())
FROM old_data.applications a
WHERE a.part_number IS NOT NULL 
  AND a.part_number != ''
  AND NOT EXISTS (
      SELECT 1 FROM web_app.item i WHERE i.item_code = a.part_number
  )
ORDER BY a.part_number, a.created_at DESC;

-- ============================================================
-- 階段 3：建立 Item_Material_Ext 記錄（料件擴展）
-- ============================================================

INSERT INTO web_app.item_material_ext (
    item_uuid,
    inc_code,
    fiig_code,
    accounting_unit_code,
    issue_unit,
    unit_price,
    unit_pack_quantity,
    spec_indicator,
    storage_life_months,
    storage_life_action_code,
    storage_type_code,
    secrecy_code,
    expendability_code,
    repairability_code,
    manufacturability_code,
    source_code,
    category_code,
    date_created,
    date_updated
)
SELECT DISTINCT ON (i.item_uuid)
    i.item_uuid,
    a.inc_code,
    a.fiig_code,
    a.accounting_unit_code,
    a.issue_unit,
    a.unit_price,
    CASE 
        WHEN a.unit_pack_quantity ~ '^\d+$' THEN CAST(a.unit_pack_quantity AS INTEGER)
        ELSE NULL
    END,
    a.spec_indicator,
    a.storage_life_months,
    a.storage_life_action_code,
    a.storage_type_code,
    a.secrecy_code,
    a.expendability_code,
    a.repairability_code,
    a.manufacturability_code,
    a.source_code,
    a.category_code,
    COALESCE(a.created_at, NOW()),
    COALESCE(a.updated_at, NOW())
FROM old_data.applications a
JOIN web_app.item i ON i.item_code = a.part_number
WHERE a.part_number IS NOT NULL 
  AND a.part_number != ''
  AND NOT EXISTS (
      SELECT 1 FROM web_app.item_material_ext ime WHERE ime.item_uuid = i.item_uuid
  )
ORDER BY i.item_uuid, a.updated_at DESC;

-- ============================================================
-- 階段 4：建立 Item_Equipment_Ext 記錄（裝備擴展）
-- ============================================================

INSERT INTO web_app.item_equipment_ext (
    item_uuid,
    ship_type,
    usage_location,
    parent_equipment_zh,
    parent_equipment_en,
    cid_no,
    model_type,
    quantity_per_unit,
    date_created,
    date_updated
)
SELECT DISTINCT ON (i.item_uuid)
    i.item_uuid,
    a.ship_type,
    a.usage_location,
    a.equipment_name,
    NULL,
    a.cid_no,
    a.model_type,
    a.quantity_per_unit,
    COALESCE(a.created_at, NOW()),
    COALESCE(a.updated_at, NOW())
FROM old_data.applications a
JOIN web_app.item i ON i.item_code = a.part_number
WHERE a.part_number IS NOT NULL 
  AND a.part_number != ''
  AND (a.ship_type IS NOT NULL OR a.equipment_name IS NOT NULL OR a.cid_no IS NOT NULL)
  AND NOT EXISTS (
      SELECT 1 FROM web_app.item_equipment_ext iee WHERE iee.item_uuid = i.item_uuid
  )
ORDER BY i.item_uuid, a.updated_at DESC;

-- ============================================================
-- 階段 5：建立 Supplier 記錄
-- ============================================================

INSERT INTO web_app.supplier (supplier_name, supplier_type, date_created, date_updated)
SELECT DISTINCT 
    a.manufacturer_name,
    'manufacturer',
    MIN(a.created_at),
    MAX(a.updated_at)
FROM old_data.applications a
WHERE a.manufacturer_name IS NOT NULL 
  AND a.manufacturer_name != ''
  AND NOT EXISTS (
      SELECT 1 FROM web_app.supplier s WHERE s.supplier_name = a.manufacturer_name
  )
GROUP BY a.manufacturer_name
ON CONFLICT DO NOTHING;

INSERT INTO web_app.supplier (supplier_name, supplier_type, date_created, date_updated)
SELECT DISTINCT 
    a.agent_name,
    'agent',
    MIN(a.created_at),
    MAX(a.updated_at)
FROM old_data.applications a
WHERE a.agent_name IS NOT NULL 
  AND a.agent_name != ''
  AND NOT EXISTS (
      SELECT 1 FROM web_app.supplier s WHERE s.supplier_name = a.agent_name
  )
GROUP BY a.agent_name
ON CONFLICT DO NOTHING;

-- ============================================================
-- 階段 6：建立 TechnicalDocument 記錄
-- ============================================================

INSERT INTO web_app.technicaldocument (document_number, document_type, document_source, date_created, date_updated)
SELECT DISTINCT 
    a.document_reference,
    'reference',
    'migration',
    MIN(a.created_at),
    MAX(a.updated_at)
FROM old_data.applications a
WHERE a.document_reference IS NOT NULL 
  AND a.document_reference != ''
  AND NOT EXISTS (
      SELECT 1 FROM web_app.technicaldocument td WHERE td.document_number = a.document_reference
  )
GROUP BY a.document_reference
ON CONFLICT DO NOTHING;

-- ============================================================
-- 階段 7：建立 item_number_xref 記錄（參考料號）
-- ============================================================

INSERT INTO web_app.item_number_xref (part_number_reference, item_uuid, pn_acquisition_source)
SELECT DISTINCT 
    a.part_number_reference, 
    i.item_uuid, 
    'migration'
FROM old_data.applications a
JOIN web_app.item i ON i.item_code = a.part_number
WHERE a.part_number_reference IS NOT NULL 
  AND a.part_number_reference != ''
ON CONFLICT (part_number_reference, item_uuid, supplier_id) DO NOTHING;

-- ============================================================
-- 階段 8：建立 Application 記錄
-- ============================================================

INSERT INTO web_app.application (
    id, user_id, item_uuid, form_serial_number, system_code, 
    mrc_data, applicant_unit, contact_info, apply_date, 
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by, 
    closed_at, closed_by, status, sub_status, 
    created_at, updated_at, deleted_at, date_created, date_updated
)
SELECT 
    a.id, 
    a.user_id, 
    i.item_uuid, 
    a.form_serial_number, 
    a.system_code, 
    a.mrc_data, 
    a.applicant_unit, 
    a.contact_info, 
    a.apply_date, 
    a.official_nsn_stamp, 
    a.official_nsn_final, 
    a.nsn_filled_at, 
    a.nsn_filled_by, 
    a.closed_at, 
    a.closed_by, 
    COALESCE(a.status, 'draft'), 
    a.sub_status, 
    a.created_at, 
    a.updated_at, 
    a.deleted_at, 
    COALESCE(a.created_at, NOW()), 
    COALESCE(a.updated_at, NOW())
FROM old_data.applications a
LEFT JOIN web_app.item i ON i.item_code = a.part_number
WHERE NOT EXISTS (SELECT 1 FROM web_app.application app WHERE app.id = a.id)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 遷移完成報告
-- ============================================================

SELECT '=== 遷移完成 ===' AS status;
