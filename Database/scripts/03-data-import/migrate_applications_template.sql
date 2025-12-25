-- ============================================================
-- 申編單資料遷移腳本 (完整版)
-- 從舊版 applications 表格式遷移到 V3.2 Application 表
-- 來源: applications_202512241401.sql 的資料
-- 目標: web_app."Application" (V3.2)
-- 日期: 2025-12-24
-- ============================================================

-- 如果要直接執行原始 SQL 檔案中的資料，
-- 需要先建立一個臨時表來接收舊格式的資料

-- 步驟 1：建立臨時表（使用舊格式的欄位結構）
DROP TABLE IF EXISTS temp_old_applications;

CREATE TEMP TABLE temp_old_applications (
    id UUID PRIMARY KEY,
    user_id UUID,
    form_serial_number VARCHAR(50),
    part_number VARCHAR(50),
    english_name VARCHAR(255),
    chinese_name VARCHAR(255),
    inc_code VARCHAR(20),
    fiig_code VARCHAR(20),
    status VARCHAR(50),
    sub_status VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    accounting_unit_code VARCHAR(50),
    issue_unit VARCHAR(10),
    unit_price NUMERIC(10,2),
    spec_indicator VARCHAR(10),
    unit_pack_quantity VARCHAR(10),
    storage_life_months VARCHAR(10),
    storage_life_action_code VARCHAR(10),
    storage_type_code VARCHAR(10),
    secrecy_code VARCHAR(10),
    expendability_code VARCHAR(10),
    repairability_code VARCHAR(10),
    manufacturability_code VARCHAR(10),
    source_code VARCHAR(10),
    category_code VARCHAR(10),
    system_code VARCHAR(100),
    pn_acquisition_level VARCHAR(100),
    pn_acquisition_source VARCHAR(100),
    manufacturer VARCHAR(255),
    part_number_reference VARCHAR(255),
    ship_type VARCHAR(100),
    cid_no VARCHAR(100),
    model_type VARCHAR(255),
    equipment_name VARCHAR(255),
    usage_location VARCHAR(255),
    quantity_per_unit INTEGER,
    mrc_data JSON,
    document_reference VARCHAR(255),
    manufacturer_name VARCHAR(255),
    agent_name VARCHAR(255),
    applicant_unit VARCHAR(100),
    contact_info VARCHAR(100),
    apply_date DATE,
    official_nsn_stamp VARCHAR(10),
    official_nsn_final VARCHAR(20),
    nsn_filled_at TIMESTAMP,
    nsn_filled_by UUID,
    closed_at TIMESTAMP,
    closed_by UUID
);

-- 步驟 2：將原始 SQL 資料插入臨時表
-- （這裡貼上原始檔案的 INSERT 語句，但改為插入 temp_old_applications）

INSERT INTO temp_old_applications (id,user_id,form_serial_number,part_number,english_name,chinese_name,inc_code,fiig_code,status,sub_status,created_at,updated_at,deleted_at,accounting_unit_code,issue_unit,unit_price,spec_indicator,unit_pack_quantity,storage_life_months,storage_life_action_code,storage_type_code,secrecy_code,expendability_code,repairability_code,manufacturability_code,source_code,category_code,system_code,pn_acquisition_level,pn_acquisition_source,manufacturer,part_number_reference,ship_type,cid_no,model_type,equipment_name,usage_location,quantity_per_unit,mrc_data,document_reference,manufacturer_name,agent_name,applicant_unit,contact_info,apply_date,official_nsn_stamp,official_nsn_final,nsn_filled_at,nsn_filled_by,closed_at,closed_by) VALUES
	 ('bdf90221-e39f-4a9b-b678-45e069811e31'::uuid,'89ca46fa-906e-4272-b1d3-134c4f554778'::uuid,'A0083','4610YETL','WATER PURIFICATION UNIT, BASE MOUNTED','逆滲透淡水製造機','08331','T227-C','pending','admin_review','2025-10-29 01:30:49.181455','2025-10-29 02:12:20.956022','2025-10-29 02:12:20.954268','B21317','SE',20000.00,'E','1','0','00','R','U','N','0','E','5','C','C35','2','3','B48811','SWR4000','FFG','48NYE0096','B48811M01','淡水製造機','後輔機艙',1,'[{"mrc_code": "CLQL", "sort_order": 1, "mrc_name_en": "COLLOQUIAL NAME", "mrc_name_zh": "口語名稱", "mrc_value_en": "R.O. MEMBRANE TYPE FRESH WATER GENERATOR", "mrc_value_zh": "RO 系統逆滲透淡水製造機"}, {"mrc_code": "APZM", "sort_order": 2, "mrc_name_en": "POTABLE WATER CAPACITY", "mrc_name_zh": "製水量", "mrc_value_en": "15000–16000 L/day", "mrc_value_zh": "每日產水量 15000–16000 公升"}, {"mrc_code": "ACDC", "sort_order": 3, "mrc_name_en": "CURRENT TYPE", "mrc_name_zh": "電流類型", "mrc_value_en": "AC", "mrc_value_zh": "交流電"}, {"mrc_code": "ELEC", "sort_order": 4, "mrc_name_en": "VOLTAGE IN VOLTS", "mrc_name_zh": "電壓（伏特）", "mrc_value_en": "440V", "mrc_value_zh": "440 伏特"}, {"mrc_code": "ALTR", "sort_order": 5, "mrc_name_en": "FILTER TYPE", "mrc_name_zh": "濾芯類型", "mrc_value_en": "Cartridge and Membrane types (5μm, 20μm pre-filters; RO membranes)", "mrc_value_zh": "濾芯式與膜式濾心（包含5微米、20微米前置濾芯與RO膜濾芯）"}]','工作圖、操作手冊','德相貿易股份有限公司','無','中信造船股份有限公司','07-5713900',NULL,NULL,NULL,NULL,NULL,NULL,NULL);

-- ============================================================
-- 步驟 3：從臨時表遷移到正式的 V3.2 Application 表
-- ============================================================
BEGIN;

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
SELECT 
    id, 
    user_id, 
    NULL AS item_uuid,  -- 新欄位，預設為 NULL
    form_serial_number, 
    part_number,
    english_name, 
    chinese_name, 
    inc_code, 
    fiig_code,
    accounting_unit_code, 
    issue_unit, 
    unit_price, 
    spec_indicator,
    unit_pack_quantity, 
    storage_life_months, 
    storage_life_action_code,
    storage_type_code, 
    secrecy_code, 
    expendability_code,
    repairability_code, 
    manufacturability_code, 
    source_code,
    category_code, 
    system_code, 
    pn_acquisition_level, 
    pn_acquisition_source,
    manufacturer, 
    part_number_reference, 
    manufacturer_name, 
    LEFT(agent_name, 100) AS agent_name,  -- 截斷至 100 字元
    ship_type, 
    cid_no, 
    model_type, 
    equipment_name, 
    -- usage_location: VARCHAR → INT 轉換
    CASE 
        WHEN usage_location ~ '^\d+$' THEN usage_location::INT 
        ELSE NULL 
    END AS usage_location,
    -- quantity_per_unit: INTEGER → JSON 轉換
    CASE 
        WHEN quantity_per_unit IS NOT NULL THEN json_build_object('value', quantity_per_unit)
        ELSE NULL 
    END AS quantity_per_unit,
    mrc_data, 
    document_reference,
    applicant_unit, 
    contact_info, 
    apply_date,
    official_nsn_stamp, 
    official_nsn_final, 
    nsn_filled_at, 
    nsn_filled_by,
    status, 
    sub_status, 
    closed_at, 
    closed_by,
    created_at AS date_created,  -- 欄位重命名
    updated_at AS date_updated,  -- 欄位重命名
    deleted_at
FROM temp_old_applications
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

COMMIT;

-- 步驟 4：清理臨時表
DROP TABLE IF EXISTS temp_old_applications;

-- ============================================================
-- 驗證遷移結果
-- ============================================================
SELECT 
    'Application' AS table_name, 
    COUNT(*) AS count 
FROM web_app."Application";
