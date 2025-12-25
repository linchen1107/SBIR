-- =====================================================
-- applications_202512241401.sql 資料遷移腳本 → V3.2 格式
-- 目標：插入資料到 web_app."Application" (PascalCase)
-- 
-- 重要變更：
--   1. 表名: web_app.applications → web_app."Application"
--   2. 欄位: created_at → date_created
--   3. 欄位: updated_at → date_updated  
--   4. 新增: item_uuid (設為 NULL)
--   5. usage_location: 保留原始 VARCHAR 值 (V3.2 已改回 VARCHAR)
--   6. quantity_per_unit: 保留原始值 (V3.2 保留為 INTEGER)
--
-- 執行方式：
--   psql -U postgres -d sbir_equipment_db_v3 -f insert_applications_v3.2.sql
-- =====================================================

-- 開始交易
BEGIN;

-- 插入資料
INSERT INTO web_app."Application" (
    id, user_id, item_uuid,
    form_serial_number, part_number, english_name, chinese_name,
    inc_code, fiig_code, status, sub_status,
    date_created, date_updated, deleted_at,
    accounting_unit_code, issue_unit, unit_price, spec_indicator,
    unit_pack_quantity, storage_life_months, storage_life_action_code,
    storage_type_code, secrecy_code, expendability_code,
    repairability_code, manufacturability_code, source_code,
    category_code, system_code, pn_acquisition_level, pn_acquisition_source,
    manufacturer, part_number_reference, ship_type, cid_no,
    model_type, equipment_name, usage_location, quantity_per_unit,
    mrc_data, document_reference, manufacturer_name, agent_name,
    applicant_unit, contact_info, apply_date,
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by,
    closed_at, closed_by
) VALUES
	 ('bdf90221-e39f-4a9b-b678-45e069811e31'::uuid,'89ca46fa-906e-4272-b1d3-134c4f554778'::uuid,NULL,'A0083','4610YETL','WATER PURIFICATION UNIT, BASE MOUNTED','逆滲透淡水製造機','08331','T227-C','pending','admin_review','2025-10-29 01:30:49.181455','2025-10-29 02:12:20.956022','2025-10-29 02:12:20.954268','B21317','SE',20000.00,'E','1','0','00','R','U','N','0','E','5','C','C35','2','3','B48811','SWR4000','FFG','48NYE0096','B48811M01','淡水製造機','後輔機艙',1,'[{"mrc_code": "CLQL", "sort_order": 1, "mrc_name_en": "COLLOQUIAL NAME", "mrc_name_zh": "口語名稱", "mrc_value_en": "R.O. MEMBRANE TYPE FRESH WATER GENERATOR", "mrc_value_zh": "RO 系統逆滲透淡水製造機"}, {"mrc_code": "APZM", "sort_order": 2, "mrc_name_en": "POTABLE WATER CAPACITY", "mrc_name_zh": "製水量", "mrc_value_en": "15000–16000 L/day", "mrc_value_zh": "每日產水量 15000–16000 公升"}, {"mrc_code": "ACDC", "sort_order": 3, "mrc_name_en": "CURRENT TYPE", "mrc_name_zh": "電流類型", "mrc_value_en": "AC", "mrc_value_zh": "交流電"}, {"mrc_code": "ELEC", "sort_order": 4, "mrc_name_en": "VOLTAGE IN VOLTS", "mrc_name_zh": "電壓（伏特）", "mrc_value_en": "440V", "mrc_value_zh": "440 伏特"}, {"mrc_code": "ALTR", "sort_order": 5, "mrc_name_en": "FILTER TYPE", "mrc_name_zh": "濾芯類型", "mrc_value_en": "Cartridge and Membrane types (5μm, 20μm pre-filters; RO membranes)", "mrc_value_zh": "濾芯式與膜式濾心（包含5微米、20微米前置濾芯與RO膜濾芯）"}]','工作圖、操作手冊','德相貿易股份有限公司','無','中信造船股份有限公司','07-5713900',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('e14ff6f3-b3f2-475d-9bcf-6379b967f711'::uuid,'89ca46fa-906e-4272-b1d3-134c4f554778'::uuid,NULL,'A0001','4610YETL','WATER PURIFICATION UNIT, BASE MOUNTED','逆滲透淡水製造機','08331','T227-C','pending','admin_review','2025-10-29 02:46:04.661004','2025-10-29 02:48:22.94992','2025-10-29 02:48:22.947713','B21317','SE',20000.00,'E','1','0','00','R','U','N','0','E','5','C','C35','2','3','B48811','SWR4000','FFG','48NYE0096','B48811M01','淡水製造機','後輔機艙',1,'[{"mrc_code": "CLQL", "sort_order": 1, "mrc_name_en": "COLLOQUIAL NAME", "mrc_name_zh": "口語名稱", "mrc_value_en": "R.O. MEMBRANE TYPE FRESH WATER GENERATOR", "mrc_value_zh": "RO 系統逆滲透淡水製造機"}, {"mrc_code": "ALTR", "sort_order": 2, "mrc_name_en": "FILTER TYPE", "mrc_name_zh": "濾芯類型", "mrc_value_en": "Cartridge and Membrane types (5μm, 20μm pre-filters; RO membranes)", "mrc_value_zh": "濾芯式與膜式濾心（包含 5 微米、20 微米前置濾芯與 RO 膜濾芯）"}, {"mrc_code": "APZM", "sort_order": 3, "mrc_name_en": "POTABLE WATER CAPACITY", "mrc_name_zh": "製水量", "mrc_value_en": "15000–16000 L/day", "mrc_value_zh": "每日產水量 15000–16000 公升"}, {"mrc_code": "ACDC", "sort_order": 4, "mrc_name_en": "CURRENT TYPE", "mrc_name_zh": "電流類型", "mrc_value_en": "AC", "mrc_value_zh": "交流電"}, {"mrc_code": "ELEC", "sort_order": 5, "mrc_name_en": "VOLTAGE IN VOLTS", "mrc_name_zh": "電壓（伏特）", "mrc_value_en": "440V", "mrc_value_zh": "440 伏特"}]','工作圖、操作手冊','德相貿易股份有限公司','無','中信造船股份有限公司','07-713900',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('6450823d-d869-48f0-9e4a-b7d11e87c26f'::uuid,'89ca46fa-906e-4272-b1d3-134c4f554778'::uuid,NULL,'A0001','4610YETL','WATER PURIFICATION UNIT, BASE MOUNTED','逆滲透淡水製造機','08331','T227-C','pending','admin_review','2025-10-29 03:04:02.398438','2025-10-29 03:07:07.744301','2025-10-29 03:07:07.742601','B21317','',20000.00,'E','1','0','00','R','U','N','0','E','5','E','C35','2','3','B48811','SWR4000','FFG','48NYE0096','B48811M01','淡水製造機','後輔機艙',1,'[{"mrc_code": "CLQL", "sort_order": 1, "mrc_name_en": "COLLOQUIAL NAME", "mrc_name_zh": "口語名稱", "mrc_value_en": "RO 系統逆滲透淡水製造機", "mrc_value_zh": "R.O. MEMBRANE TYPE FRESH WATER GENERATOR"}, {"mrc_code": "ALTR", "sort_order": 2, "mrc_name_en": "FILTER TYPE", "mrc_name_zh": "濾芯類型", "mrc_value_en": "Cartridge and Membrane types (5μm, 20μm pre-filters; RO membranes)", "mrc_value_zh": "濾芯式與膜式濾心（包含 5 微米、20 微米前置濾芯與 RO 膜濾芯）"}, {"mrc_code": "APZM", "sort_order": 3, "mrc_name_en": "POTABLE WATER CAPACITY", "mrc_name_zh": "製水量", "mrc_value_en": "15000–16000 L/day", "mrc_value_zh": "每日產水量 15000–16000 公升"}, {"mrc_code": "ACDC", "sort_order": 4, "mrc_name_en": "CURRENT TYPE", "mrc_name_zh": "電流類型", "mrc_value_en": "AC", "mrc_value_zh": "交流電"}, {"mrc_code": "ELEC", "sort_order": 5, "mrc_name_en": "VOLTAGE IN VOLTS", "mrc_name_zh": "電壓（伏特）", "mrc_value_en": "440V", "mrc_value_zh": "440 伏特"}]','工作圖、操作手冊','德相貿易股份有限公司','無','中信造船股份有限公司','07-713900',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('e8700f24-7f41-4b92-8c75-3d4fff9580a0'::uuid,'89ca46fa-906e-4272-b1d3-134c4f554778'::uuid,NULL,'A0001','4610YETL','WATER PURIFICATION UNIT, BASE MOUNTED','逆滲透淡水製造機','08331','T227-C','approved','completed','2025-10-29 03:15:51.543507','2025-11-06 05:27:56.690136','2025-11-06 05:27:56.689158','B21317','SE',20000.00,'E','0','0','00','R','U','N','0','E','5','E','C35','2','3','B48811','SWR4000','FFG','48NYE0096','B48811M01','淡水製造機','後輔機艙',1,'[{"mrc_code": "CLQL", "sort_order": 1, "mrc_name_en": "COLLOQUIAL NAME", "mrc_name_zh": "口語名稱", "mrc_value_en": "RO 系統逆滲透淡水製造機", "mrc_value_zh": "R.O. MEMBRANE TYPE FRESH WATER GENERATOR"}, {"mrc_code": "ALTR", "sort_order": 2, "mrc_name_en": "FILTER TYPE", "mrc_name_zh": "濾芯類型", "mrc_value_en": "Cartridge and Membrane types (5μm, 20μm pre-filters; RO membranes)", "mrc_value_zh": "濾芯式與膜式濾心（包含 5 微米、20 微米前置濾芯與 RO 膜濾芯）"}, {"mrc_code": "APZM", "sort_order": 3, "mrc_name_en": "POTABLE WATER CAPACITY", "mrc_name_zh": "製水量", "mrc_value_en": "15000–16000 L/day", "mrc_value_zh": "每日產水量 15000–16000 公升"}, {"mrc_code": "ACDC", "sort_order": 4, "mrc_name_en": "CURRENT TYPE", "mrc_name_zh": "電流類型", "mrc_value_en": "AC", "mrc_value_zh": "交流電"}, {"mrc_code": "ELEC", "sort_order": 5, "mrc_name_en": "VOLTAGE IN VOLTS", "mrc_name_zh": "電壓（伏特）", "mrc_value_en": "440V", "mrc_value_zh": "440 伏特"}]','工作圖、操作手冊','德相貿易股份有限公司','無','中信造船股份有限公司','07-713900',NULL,'12345','4610YETL12345','2025-10-31 03:28:57.880739','89ca46fa-906e-4272-b1d3-134c4f554778'::uuid,'2025-10-31 03:29:13.126854','22c41871-d829-42a7-bb25-2f8d9c685206'::uuid)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    form_serial_number = EXCLUDED.form_serial_number,
    part_number = EXCLUDED.part_number,
    english_name = EXCLUDED.english_name,
    chinese_name = EXCLUDED.chinese_name,
    inc_code = EXCLUDED.inc_code,
    fiig_code = EXCLUDED.fiig_code,
    status = EXCLUDED.status,
    sub_status = EXCLUDED.sub_status,
    date_updated = EXCLUDED.date_updated;

-- 由於原始資料太多，建議分批插入
-- 以下是剩餘資料的插入語句 (需要從原始檔案複製完整資料)

-- 提交交易
COMMIT;

-- 驗證插入結果
SELECT COUNT(*) AS total_applications FROM web_app."Application";
