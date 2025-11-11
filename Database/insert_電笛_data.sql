-- ===================================
-- 電笛系統完整資料匯入腳本
-- 使用正確的表名稱：Equipment_Item_xref, BOM
-- ===================================

-- 1. 廠商主檔 (Supplier)
INSERT INTO Supplier (supplier_code, cage_code, supplier_name_en, supplier_name_zh, supplier_type, country_code) VALUES
('B', '2H845', 'Federal Signal Corporation', '聯邦信號公司', '製造商', 'US');

-- 2. 裝備主檔 (Equipment)
INSERT INTO Equipment (equipment_id, equipment_name_zh, equipment_name_en, equipment_type, ship_type, position,
                       parent_cid, eswbs_code, installation_qty, total_installation_qty, maintenance_level, equipment_serial) VALUES
('27NYE0901', '電笛系統', 'Electric Whistle System', 'EWS-100', 'FFG', '駕駛台/甲板',
 '0', '43251', 1, 2, 'O', '0901');

-- 3. 品項主檔 (Item)
INSERT INTO Item (item_id, item_id_last5, nsn, item_category, item_name_zh, item_name_zh_short,
                  item_name_en, item_code, weapon_system_code, accounting_code, issue_unit,
                  unit_price_usd, package_qty, weight_kg, has_stock) VALUES
-- 品項1: 電笛系統主機
('YETL23001', '23001', '6350YETL23001', '6350', '電笛系統主機', '電笛主機',
 'ELECTRIC WHISTLE SYSTEM', '45678', 'C35', 'B21317', 'EA', 85000.00, 1, 25.500, true),

-- 品項2: 電笛喇叭
('YETL23002', '23002', '6350YETL23002', '6350', '電笛喇叭', '電笛喇叭',
 'ELECTRIC WHISTLE HORN', '45679', 'C35', 'B21317', 'EA', 3500.00, 1, 8.200, true),

-- 品項3: 控制面板
('YETL23003', '23003', '6350YETL23003', '6350', '電笛控制面板', '控制面板',
 'CONTROL PANEL', '45680', 'C35', 'B21317', 'EA', 2800.00, 1, 3.500, true),

-- 品項4: 擴大機模組
('YETL23004', '23004', '6350YETL23004', '6350', '擴大機模組', '擴大機',
 'AMPLIFIER MODULE', '45681', 'C35', 'B21317', 'EA', 1500.00, 1, 2.100, true),

-- 品項5: 電源供應器
('YETL23005', '23005', '6350YETL23005', '6350', '電源供應器', '電源',
 'POWER SUPPLY UNIT', '45682', 'C35', 'B21317', 'EA', 800.00, 1, 1.800, true);

-- 4. 品項屬性檔 (ItemAttribute)
INSERT INTO ItemAttribute (item_id, storage_life_code, file_type_code, file_type_category,
                           security_code, consumable_code, spec_indicator, navy_source,
                           storage_type, life_process_code, manufacturing_capacity, repair_capacity,
                           source_code, project_code) VALUES
-- 品項1屬性
('YETL23001', '0', 'E', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4'),

-- 品項2屬性
('YETL23002', '0', 'C', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4'),

-- 品項3屬性
('YETL23003', '0', 'C', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4'),

-- 品項4屬性
('YETL23004', '0', 'C', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4'),

-- 品項5屬性
('YETL23005', '0', 'C', 'C', 'U', 'M', 'E', 'C', 'A', '00', 'E', '0', 'C', '4');

-- 5. 零件號碼檔 (PartNumber)
-- 使用子查詢取得廠商 ID
INSERT INTO PartNumber (part_number, item_id, supplier_id, obtain_level, obtain_source, is_primary) VALUES
-- 品項1零件號
('EWS-100-MAIN', 'YETL23001', (SELECT supplier_id FROM Supplier WHERE cage_code = '2H845'), '2', '3', true),

-- 品項2零件號
('EWS-100-HORN', 'YETL23002', (SELECT supplier_id FROM Supplier WHERE cage_code = '2H845'), '2', '3', true),

-- 品項3零件號
('EWS-100-CP', 'YETL23003', (SELECT supplier_id FROM Supplier WHERE cage_code = '2H845'), '2', '3', true),

-- 品項4零件號
('EWS-100-AMP', 'YETL23004', (SELECT supplier_id FROM Supplier WHERE cage_code = '2H845'), '2', '3', true),

-- 品項5零件號
('EWS-100-PSU', 'YETL23005', (SELECT supplier_id FROM Supplier WHERE cage_code = '2H845'), '2', '3', true);

-- 6. 裝備品項關聯檔 (Equipment_Item_xref) ⭐ 更新表名
INSERT INTO Equipment_Item_xref (equipment_id, item_id, installation_qty, installation_unit) VALUES
-- 電笛系統 (27NYE0901) 包含的零附件配置
('27NYE0901', 'YETL23002', 2, 'EA'),  -- 需要 2 個電笛喇叭
('27NYE0901', 'YETL23003', 1, 'EA'),  -- 需要 1 個控制面板
('27NYE0901', 'YETL23004', 1, 'EA'),  -- 需要 1 個擴大機模組
('27NYE0901', 'YETL23005', 1, 'EA');  -- 需要 1 個電源供應器

-- 7. BOM結構檔 (BOM) - 品項組成結構 ⭐ 更新為品項自關聯
INSERT INTO BOM (parent_item_id, child_item_id, item_no_plsin, quantity, unit,
                 delivery_time, failure_rate_per_million, mtbf_hours, mttr_hours, is_repairable) VALUES
-- 電笛系統主機 (YETL23001) 的組成零件 BOM
('YETL23001', 'YETL23002', 'PLSIN-001', 2, 'EA', 90, 5.5000, 50000, 2.5, 'Y'),  -- 主機包含 2 個喇叭
('YETL23001', 'YETL23003', 'PLSIN-002', 1, 'EA', 60, 3.2000, 80000, 1.5, 'Y'),  -- 主機包含 1 個控制面板
('YETL23001', 'YETL23004', 'PLSIN-003', 1, 'EA', 75, 8.5000, 30000, 3.0, 'Y'),  -- 主機包含 1 個擴大機
('YETL23001', 'YETL23005', 'PLSIN-004', 1, 'EA', 45, 12.0000, 20000, 2.0, 'Y'); -- 主機包含 1 個電源供應器

-- 8. 技術文件檔 (TechnicalDocument)
INSERT INTO TechnicalDocument (equipment_id, document_name, document_version, shipyard_drawing_no,
                               design_drawing_no, document_type, document_category, language,
                               security_level, eswbs_code, accounting_code) VALUES
-- 電笛系統技術文件
('27NYE0901', '電笛系統安裝手冊', 'V1.0', 'SD-901-001', 'DD-901-001', '安裝手冊', '技術手冊', 'ZH', 'U', '43251', 'B21317'),
('27NYE0901', '電笛系統維護手冊', 'V1.0', 'SD-901-002', 'DD-901-002', '維護手冊', '技術手冊', 'ZH', 'U', '43251', 'B21317'),
('27NYE0901', 'Electric Whistle System Technical Manual', 'V1.0', 'SD-901-003', 'DD-901-003', 'Technical Manual', 'Manual', 'EN', 'U', '43251', 'B21317'),
('27NYE0901', '電笛系統電路圖', 'V1.2', 'SD-901-004', 'DD-901-004', '電路圖', '工程圖', 'ZH', 'U', '43251', 'B21317');

-- 9. 裝備特性說明檔 (EquipmentSpecification)
INSERT INTO EquipmentSpecification (equipment_id, spec_seq_no, spec_description) VALUES
('27NYE0901', 1, '電笛系統，用於艦上訊號通知'),
('27NYE0901', 2, '工作電壓: AC 115V/60Hz'),
('27NYE0901', 3, '音壓輸出: 125dB @ 1m'),
('27NYE0901', 4, '頻率範圍: 200-2000Hz'),
('27NYE0901', 5, '工作溫度: -20°C ~ +55°C');

-- 10. 品項規格檔 (ItemSpecification)
INSERT INTO ItemSpecification (item_id, spec_no, spec_abbr, spec_en, spec_zh, answer_en, answer_zh) VALUES
-- 品項1規格
('YETL23001', 1, 'TYPE', 'Type', '型式', 'EWS-100', 'EWS-100'),
('YETL23001', 2, 'POWER', 'Power Rating', '功率', '500W', '500瓦'),
('YETL23001', 3, 'VOLTAGE', 'Input Voltage', '輸入電壓', '115VAC 60Hz', '115伏特交流 60赫茲'),

-- 品項2規格
('YETL23002', 1, 'SPL', 'Sound Pressure Level', '音壓', '125dB @ 1m', '125分貝@1公尺'),
('YETL23002', 2, 'FREQ', 'Frequency Range', '頻率範圍', '200-2000Hz', '200-2000赫茲'),
('YETL23002', 3, 'WEIGHT', 'Weight', '重量', '8.2kg', '8.2公斤'),

-- 品項3規格
('YETL23003', 1, 'INPUT', 'Input Voltage', '輸入電壓', '115VAC', '115伏特交流'),
('YETL23003', 2, 'DISPLAY', 'Display Type', '顯示類型', 'LED', 'LED顯示'),

-- 品項4規格
('YETL23004', 1, 'OUTPUT', 'Output Power', '輸出功率', '500W', '500瓦'),
('YETL23004', 2, 'THD', 'Total Harmonic Distortion', '總諧波失真', '<1%', '小於1%'),

-- 品項5規格
('YETL23005', 1, 'VOLTAGE', 'Output Voltage', '輸出電壓', '24VDC', '24伏特直流'),
('YETL23005', 2, 'CURRENT', 'Output Current', '輸出電流', '20A', '20安培');

-- 11. 申編單檔 (ApplicationForm)
INSERT INTO ApplicationForm (form_no, submit_status, yetl, applicant_accounting_code) VALUES
('YETL-2024-002', '已送', 'YETL', 'B21317');

-- 12. 申編單明細檔 (ApplicationFormDetail)
-- 使用子查詢取得剛新增的 form_id
INSERT INTO ApplicationFormDetail (form_id, item_seq, item_id, document_source) VALUES
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-002'), 1, 'YETL23001', '電笛系統-ILS及APL_版4.1'),
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-002'), 2, 'YETL23002', '電笛系統-ILS及APL_版4.1'),
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-002'), 3, 'YETL23003', '電笛系統-ILS及APL_版4.1'),
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-002'), 4, 'YETL23004', '電笛系統-ILS及APL_版4.1'),
((SELECT form_id FROM ApplicationForm WHERE form_no = 'YETL-2024-002'), 5, 'YETL23005', '電笛系統-ILS及APL_版4.1');

-- ===================================
-- 資料匯入完成
-- ===================================
