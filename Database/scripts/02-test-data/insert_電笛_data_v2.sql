-- ============================================
-- 電笛系統測試資料匯入腳本
-- 資料庫: sbir_equipment_db_v2
-- 版本: V3.0
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. 廠商資料
-- ============================================

INSERT INTO Supplier (
    supplier_code, cage_code, supplier_name_en, supplier_name_zh,
    supplier_type, country_code
) VALUES (
    'B', '2H845', 'Federal Signal Corporation', '聯邦信號公司',
    '製造商', 'US'
);

-- ============================================
-- 2. 品項資料 (Item)
-- ============================================

-- 2.1 電笛系統 (FG - 成品/裝備)
INSERT INTO Item (
    item_uuid, item_code, item_name_zh, item_name_en,
    item_type, uom, status
) VALUES (
    'a0000001-0000-0000-0000-000000000001', '27NYE0901', '電笛系統', 'Electric Whistle System',
    'FG', 'SET', 'Active'
);

-- 2.2 電笛系統主機 (SEMI - 半成品)
INSERT INTO Item (
    item_uuid, item_code, item_name_zh, item_name_en,
    item_type, uom, status
) VALUES (
    'a0000001-0000-0000-0000-000000000002', 'YETL23001', '電笛系統主機', 'ELECTRIC WHISTLE SYSTEM',
    'SEMI', 'EA', 'Active'
);

-- 2.3 電笛喇叭 (RM - 原物料)
INSERT INTO Item (
    item_uuid, item_code, item_name_zh, item_name_en,
    item_type, uom, status
) VALUES (
    'a0000001-0000-0000-0000-000000000003', 'YETL23002', '電笛喇叭', 'ELECTRIC WHISTLE HORN',
    'RM', 'EA', 'Active'
);

-- 2.4 電笛控制面板 (RM)
INSERT INTO Item (
    item_uuid, item_code, item_name_zh, item_name_en,
    item_type, uom, status
) VALUES (
    'a0000001-0000-0000-0000-000000000004', 'YETL23003', '電笛控制面板', 'CONTROL PANEL',
    'RM', 'EA', 'Active'
);

-- 2.5 擴大機模組 (RM)
INSERT INTO Item (
    item_uuid, item_code, item_name_zh, item_name_en,
    item_type, uom, status
) VALUES (
    'a0000001-0000-0000-0000-000000000005', 'YETL23004', '擴大機模組', 'AMPLIFIER MODULE',
    'RM', 'EA', 'Active'
);

-- 2.6 電源供應器 (RM)
INSERT INTO Item (
    item_uuid, item_code, item_name_zh, item_name_en,
    item_type, uom, status
) VALUES (
    'a0000001-0000-0000-0000-000000000006', 'YETL23005', '電源供應器', 'POWER SUPPLY UNIT',
    'RM', 'EA', 'Active'
);

-- ============================================
-- 3. 裝備擴展資料 (Item_Equipment_Ext)
-- ============================================

INSERT INTO Item_Equipment_Ext (
    item_uuid, equipment_type, ship_type, position, parent_cid,
    eswbs_code, system_function_name, installation_qty,
    total_installation_qty, maintenance_level, equipment_serial
) VALUES (
    'a0000001-0000-0000-0000-000000000001',
    'EWS-100', 'FFG', '駕駛台/甲板', '0',
    '43251', '電笛系統', 1,
    2, 'O', '0901'
);

-- ============================================
-- 4. 料件擴展資料 (Item_Material_Ext)
-- ============================================

-- 4.1 電笛系統主機
INSERT INTO Item_Material_Ext (
    item_uuid, item_id_last5, nsn, item_category, item_code,
    weapon_system_code, accounting_code, unit_price_usd,
    weight_kg, has_stock
) VALUES (
    'a0000001-0000-0000-0000-000000000002',
    '23001', '6350-01-XXX-0001', '6350', 'EWS',
    'C35', 'B21317', 85000.00,
    25.500, TRUE
);

-- 4.2 電笛喇叭
INSERT INTO Item_Material_Ext (
    item_uuid, item_id_last5, nsn, item_category, item_code,
    weapon_system_code, accounting_code, unit_price_usd,
    weight_kg, has_stock
) VALUES (
    'a0000001-0000-0000-0000-000000000003',
    '23002', '6350-01-XXX-0002', '6350', 'HRN',
    'C35', 'B21317', 3500.00,
    8.200, TRUE
);

-- 4.3 電笛控制面板
INSERT INTO Item_Material_Ext (
    item_uuid, item_id_last5, nsn, item_category, item_code,
    weapon_system_code, accounting_code, unit_price_usd,
    weight_kg, has_stock
) VALUES (
    'a0000001-0000-0000-0000-000000000004',
    '23003', '6350-01-XXX-0003', '6350', 'PNL',
    'C35', 'B21317', 2800.00,
    3.500, TRUE
);

-- 4.4 擴大機模組
INSERT INTO Item_Material_Ext (
    item_uuid, item_id_last5, nsn, item_category, item_code,
    weapon_system_code, accounting_code, unit_price_usd,
    weight_kg, has_stock
) VALUES (
    'a0000001-0000-0000-0000-000000000005',
    '23004', '6350-01-XXX-0004', '6350', 'AMP',
    'C35', 'B21317', 1500.00,
    2.100, TRUE
);

-- 4.5 電源供應器
INSERT INTO Item_Material_Ext (
    item_uuid, item_id_last5, nsn, item_category, item_code,
    weapon_system_code, accounting_code, unit_price_usd,
    weight_kg, has_stock
) VALUES (
    'a0000001-0000-0000-0000-000000000006',
    '23005', '6350-01-XXX-0005', '6350', 'PSU',
    'C35', 'B21317', 800.00,
    1.800, TRUE
);

-- ============================================
-- 5. BOM 資料
-- ============================================

-- 5.1 電笛系統 BOM
INSERT INTO BOM (
    bom_uuid, item_uuid, bom_code, revision,
    effective_from, effective_to, status, remark
) VALUES (
    'b0000001-0000-0000-0000-000000000001',
    'a0000001-0000-0000-0000-000000000001',
    'BOM-EWS-001', '1.0',
    '2025-01-01', NULL, 'Released', '電笛系統初版BOM'
);

-- 5.2 電笛系統主機 BOM
INSERT INTO BOM (
    bom_uuid, item_uuid, bom_code, revision,
    effective_from, effective_to, status, remark
) VALUES (
    'b0000001-0000-0000-0000-000000000002',
    'a0000001-0000-0000-0000-000000000002',
    'BOM-MAIN-001', '1.0',
    '2025-01-01', NULL, 'Released', '電笛主機初版BOM'
);

-- ============================================
-- 6. BOM_LINE 資料 (自我關聯)
-- ============================================

-- 6.1 電笛系統 → 電笛系統主機
INSERT INTO BOM_LINE (
    line_uuid, bom_uuid, line_no, component_item_uuid,
    qty_per, uom, position, remark
) VALUES (
    'c0000001-0000-0000-0000-000000000001',
    'b0000001-0000-0000-0000-000000000001', 1,
    'a0000001-0000-0000-0000-000000000002',
    1.0000, 'EA', '主機艙', '主機組件'
);

-- 6.2 電笛系統主機 → 電笛喇叭 (2個)
INSERT INTO BOM_LINE (
    line_uuid, bom_uuid, line_no, component_item_uuid,
    qty_per, uom, position, remark
) VALUES (
    'c0000001-0000-0000-0000-000000000002',
    'b0000001-0000-0000-0000-000000000002', 1,
    'a0000001-0000-0000-0000-000000000003',
    2.0000, 'EA', '甲板', '左右各一'
);

-- 6.3 電笛系統主機 → 電笛控制面板
INSERT INTO BOM_LINE (
    line_uuid, bom_uuid, line_no, component_item_uuid,
    qty_per, uom, position, remark
) VALUES (
    'c0000001-0000-0000-0000-000000000003',
    'b0000001-0000-0000-0000-000000000002', 2,
    'a0000001-0000-0000-0000-000000000004',
    1.0000, 'EA', '駕駛台', '控制面板'
);

-- 6.4 電笛系統主機 → 擴大機模組
INSERT INTO BOM_LINE (
    line_uuid, bom_uuid, line_no, component_item_uuid,
    qty_per, uom, position, remark
) VALUES (
    'c0000001-0000-0000-0000-000000000004',
    'b0000001-0000-0000-0000-000000000002', 3,
    'a0000001-0000-0000-0000-000000000005',
    1.0000, 'EA', '主機艙', '擴大機'
);

-- 6.5 電笛系統主機 → 電源供應器
INSERT INTO BOM_LINE (
    line_uuid, bom_uuid, line_no, component_item_uuid,
    qty_per, uom, position, remark
) VALUES (
    'c0000001-0000-0000-0000-000000000005',
    'b0000001-0000-0000-0000-000000000002', 4,
    'a0000001-0000-0000-0000-000000000006',
    1.0000, 'EA', '主機艙', '電源供應'
);

-- ============================================
-- 7. MRC 規格資料 (範例)
-- ============================================

-- 電笛喇叭規格
INSERT INTO MRC (
    item_uuid, spec_no, spec_abbr, spec_en, spec_zh,
    answer_en, answer_zh
) VALUES (
    'a0000001-0000-0000-0000-000000000003',
    1, 'CLQL', 'COLLOQUIAL NAME', '口語名稱',
    'ELECTRIC WHISTLE HORN', '電笛喇叭'
);

INSERT INTO MRC (
    item_uuid, spec_no, spec_abbr, spec_en, spec_zh,
    answer_en, answer_zh
) VALUES (
    'a0000001-0000-0000-0000-000000000003',
    2, 'VOLT', 'VOLTAGE RATING', '額定電壓',
    '24V DC', '直流24伏特'
);

-- 電源供應器規格
INSERT INTO MRC (
    item_uuid, spec_no, spec_abbr, spec_en, spec_zh,
    answer_en, answer_zh
) VALUES (
    'a0000001-0000-0000-0000-000000000006',
    1, 'CLQL', 'COLLOQUIAL NAME', '口語名稱',
    'POWER SUPPLY UNIT', '電源供應器'
);

INSERT INTO MRC (
    item_uuid, spec_no, spec_abbr, spec_en, spec_zh,
    answer_en, answer_zh
) VALUES (
    'a0000001-0000-0000-0000-000000000006',
    2, 'OUTP', 'OUTPUT POWER', '輸出功率',
    '500W', '500瓦'
);

-- ============================================
-- 8. 零件號碼資料 (Part_Number_xref)
-- ============================================

INSERT INTO Part_Number_xref (
    part_number, item_uuid, supplier_id,
    obtain_level, obtain_source, is_primary
) VALUES (
    'EWS-100-MAIN',
    'a0000001-0000-0000-0000-000000000002',
    1, 'A', 'CATALOG', TRUE
);

INSERT INTO Part_Number_xref (
    part_number, item_uuid, supplier_id,
    obtain_level, obtain_source, is_primary
) VALUES (
    'HRN-200-24V',
    'a0000001-0000-0000-0000-000000000003',
    1, 'A', 'CATALOG', TRUE
);

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '電笛系統測試資料匯入完成！';
    RAISE NOTICE '已匯入資料：';
    RAISE NOTICE '- Supplier: 1 筆';
    RAISE NOTICE '- Item: 6 筆 (1 FG, 1 SEMI, 4 RM)';
    RAISE NOTICE '- Item_Equipment_Ext: 1 筆';
    RAISE NOTICE '- Item_Material_Ext: 5 筆';
    RAISE NOTICE '- BOM: 2 筆';
    RAISE NOTICE '- BOM_LINE: 5 筆';
    RAISE NOTICE '- MRC: 4 筆';
    RAISE NOTICE '- Part_Number_xref: 2 筆';
    RAISE NOTICE '=========================================';
END $$;
