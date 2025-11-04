-- ===================================
-- 聲力電話系統完整資料匯入腳本
-- ===================================

-- 1. 廠商主檔 (Supplier)
INSERT INTO Supplier (supplier_code, cage_code, supplier_name_en, supplier_name_zh, supplier_type, country_code) VALUES
('A', '1973B', 'Manufacturer Name', '廠商名稱', '製造商', 'US');

-- 2. 裝備主檔 (Equipment)
INSERT INTO Equipment (equipment_id, equipment_name_zh, equipment_name_en, equipment_type, ship_type, position,
                       parent_cid, eswbs_code, installation_qty, total_installation_qty, maintenance_level, equipment_serial) VALUES
('27NYE0823', '聲力電話系統', 'Acoustic Telephone System', 'TA-4CI', 'FFG', '前/後機艙',
 '0', '43212', 1, 1, 'O', '0823');

-- 3. 品項主檔 (Item)
INSERT INTO Item (item_id, item_id_last5, nsn, item_category, item_name_zh, item_name_zh_short,
                  item_name_en, item_code, weapon_system_code, accounting_code, issue_unit,
                  unit_price_usd, package_qty, weight_kg, has_stock) VALUES
-- 品項1: 聲力電話系統
('YETL22090', '22090', '5805YETL22090', '5805', '聲力電話系統', '聲力電話',
 'TELEPHONE SYSTEM', '35522', 'C35', 'B21317', 'EA', 530000.00, 1, 0.000, true),

-- 品項2: 12站壁掛式聲力電話
('YETL22088', '22088', '5805YETL22088', '5805', '12站壁掛式聲力電話', '12站電話',
 'TELEPHONE SET', '00307', 'C35', 'B21317', 'EA', 1200.00, 1, 0.000, true),

-- 品項3: 24站壁掛式聲力電話
('YETL22087', '22087', '5805YETL22087', '5805', '24站壁掛式聲力電話', '24站電話',
 'TELEPHONE SET', '00307', 'C35', 'B21317', 'EA', 1200.00, 1, 0.000, true);

-- 4. 品項屬性檔 (ItemAttribute)
INSERT INTO ItemAttribute (item_id, storage_life_code, file_type_code, file_type_category,
                           security_code, consumable_code, spec_indicator, navy_source,
                           storage_type, life_process_code, manufacturing_capacity, repair_capacity,
                           source_code, project_code) VALUES
-- 品項1屬性
('YETL22090', '0', 'E', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4'),

-- 品項2屬性
('YETL22088', '0', 'C', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4'),

-- 品項3屬性
('YETL22087', '0', 'C', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4');

-- 5. 零件號碼檔 (PartNumber)
-- 使用子查詢取得廠商 ID
INSERT INTO PartNumber (part_number, item_id, supplier_id, obtain_level, obtain_source, is_primary) VALUES
-- 品項1零件號
('TA-4CI', 'YETL22090', (SELECT supplier_id FROM Supplier WHERE cage_code = '1973B'), '2', '3', true),

-- 品項2零件號
('455.029.4.21H', 'YETL22088', (SELECT supplier_id FROM Supplier WHERE cage_code = '1973B'), '2', '3', true),

-- 品項3零件號
('455.031.4.16H', 'YETL22087', (SELECT supplier_id FROM Supplier WHERE cage_code = '1973B'), '2', '3', true);

-- 6. 裝備品項關聯檔 (EquipmentItem)
INSERT INTO EquipmentItem (equipment_id, item_id, installation_qty, installation_unit) VALUES
('27NYE0823', 'YETL22088', 1, 'EA'),
('27NYE0823', 'YETL22087', 1, 'EA');

-- 7. 裝備特性說明檔 (EquipmentSpecification)
INSERT INTO EquipmentSpecification (equipment_id, spec_seq_no, spec_description) VALUES
('27NYE0823', 1, '聲力電話系統，用於艦上通訊');

-- 8. 品項規格檔 (ItemSpecification)
INSERT INTO ItemSpecification (item_id, spec_no, spec_abbr, spec_en, spec_zh, answer_en, answer_zh) VALUES
('YETL22090', 1, 'TYPE', 'Type', '型式', 'TA-4CI', 'TA-4CI'),
('YETL22088', 1, 'STATIONS', 'Number of Stations', '站數', '12', '12站'),
('YETL22087', 1, 'STATIONS', 'Number of Stations', '站數', '24', '24站');

-- 9. 申編單檔 (ApplicationForm)
INSERT INTO ApplicationForm (form_no, submit_status, applicant_accounting_code) VALUES
('YETL-2024-001', '待送', 'B21317');

-- 10. 申編單明細檔 (ApplicationFormDetail)
-- 使用子查詢取得剛新增的 form_id
INSERT INTO ApplicationFormDetail (form_id, item_seq, item_id, document_source) VALUES
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-001'), 1, 'YETL22090', '聲力電話-ILS及APL_版4.1'),
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-001'), 2, 'YETL22088', '聲力電話-ILS及APL_版4.1'),
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-001'), 3, 'YETL22087', '聲力電話-ILS及APL_版4.1');
