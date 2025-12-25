-- ============================================================
-- 申編單資料遷移腳本
-- 從舊版 applications 格式遷移到 V3.2 Application 表
-- 來源檔案: applications_202512241401.sql
-- 目標: web_app."Application" (V3.2)
-- 日期: 2025-12-24
-- ============================================================

-- 開始交易
BEGIN;

-- 清除目標表中可能存在的重複資料（可選，謹慎使用）
-- DELETE FROM web_app."Application" WHERE id IN (SELECT id FROM temp_applications);

-- 插入資料，進行必要的欄位轉換
INSERT INTO web_app."Application" (
    id, user_id, item_uuid, form_serial_number, part_number,
    english_name, chinese_name, inc_code, fiig_code,
    accounting_unit_code, issue_unit, unit_price, spec_indicator,
    unit_pack_quantity, storage_life_months, storage_life_action_code,
    storage_type_code, secrecy_code, expendability_code,
    repairability_code, manufacturability_code, source_code,
    category_code, system_code, pn_acquisition_level, pn_acquisition_source,
    manufacturer, part_number_reference, manufacturer_name, agent_name,
    ship_type, cid_no, model_type, equipment_name, usage_location,
    quantity_per_unit, mrc_data, document_reference,
    applicant_unit, contact_info, apply_date,
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by,
    status, sub_status, closed_at, closed_by,
    date_created, date_updated, deleted_at
)
VALUES
-- Record 1
('bdf90221-e39f-4a9b-b678-45e069811e31'::uuid, '89ca46fa-906e-4272-b1d3-134c4f554778'::uuid, NULL, 'A0083', '4610YETL', 'WATER PURIFICATION UNIT, BASE MOUNTED', '逆滲透淡水製造機', '08331', 'T227-C', 'B21317', 'SE', 20000.00, 'E', '1', '0', '00', 'R', 'U', 'N', '0', 'E', '5', 'C', 'C35', '2', '3', 'B48811', 'SWR4000', '德相貿易股份有限公司', '無', 'FFG', '48NYE0096', 'B48811M01', '淡水製造機', NULL, '{"value": 1}'::json, '[{"mrc_code": "CLQL", "sort_order": 1, "mrc_name_en": "COLLOQUIAL NAME", "mrc_name_zh": "口語名稱", "mrc_value_en": "R.O. MEMBRANE TYPE FRESH WATER GENERATOR", "mrc_value_zh": "RO 系統逆滲透淡水製造機"}, {"mrc_code": "APZM", "sort_order": 2, "mrc_name_en": "POTABLE WATER CAPACITY", "mrc_name_zh": "製水量", "mrc_value_en": "15000–16000 L/day", "mrc_value_zh": "每日產水量 15000–16000 公升"}, {"mrc_code": "ACDC", "sort_order": 3, "mrc_name_en": "CURRENT TYPE", "mrc_name_zh": "電流類型", "mrc_value_en": "AC", "mrc_value_zh": "交流電"}, {"mrc_code": "ELEC", "sort_order": 4, "mrc_name_en": "VOLTAGE IN VOLTS", "mrc_name_zh": "電壓（伏特）", "mrc_value_en": "440V", "mrc_value_zh": "440 伏特"}, {"mrc_code": "ALTR", "sort_order": 5, "mrc_name_en": "FILTER TYPE", "mrc_name_zh": "濾芯類型", "mrc_value_en": "Cartridge and Membrane types (5μm, 20μm pre-filters; RO membranes)", "mrc_value_zh": "濾芯式與膜式濾心（包含5微米、20微米前置濾芯與RO膜濾芯）"}]'::json, '工作圖、操作手冊', '中信造船股份有限公司', '07-5713900', NULL, NULL, NULL, NULL, NULL, 'pending', 'admin_review', NULL, NULL, '2025-10-29 01:30:49.181455', '2025-10-29 02:12:20.956022', '2025-10-29 02:12:20.954268')
ON CONFLICT (id) DO NOTHING;

-- 提交交易
COMMIT;

-- ============================================================
-- 注意事項：
-- 1. usage_location 欄位已從 VARCHAR 轉換為 INT（非數字值設為 NULL）
-- 2. quantity_per_unit 欄位已從 INTEGER 轉換為 JSON 格式
-- 3. created_at → date_created, updated_at → date_updated
-- 4. item_uuid 設為 NULL，需後續建立關聯
-- 5. 使用 ON CONFLICT (id) DO NOTHING 避免重複插入
-- ============================================================
