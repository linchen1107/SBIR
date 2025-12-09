-- ============================================
-- 資料庫結構調整 - 支援 EMU3000 資料導入
-- 資料庫: sbir_equipment_db_v2
-- 用途: 新增欄位以支援 EMU3000 維修物料清單
-- 建立日期: 2025-11-24
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. Item 表新增專案代碼
-- ============================================

ALTER TABLE "Item" ADD COLUMN IF NOT EXISTS project_code VARCHAR(20);
COMMENT ON COLUMN "Item".project_code IS '專案代碼: NAVY/EMU3000/...';
CREATE INDEX IF NOT EXISTS idx_item_project ON "Item"(project_code);

-- ============================================
-- 2. BOM 表新增工作表類型和維護週期
-- ============================================

ALTER TABLE "BOM" ADD COLUMN IF NOT EXISTS sheet_type VARCHAR(20);
COMMENT ON COLUMN "BOM".sheet_type IS '工作表類型: 定更件/定檢件';

ALTER TABLE "BOM" ADD COLUMN IF NOT EXISTS maintenance_period INT;
COMMENT ON COLUMN "BOM".maintenance_period IS '維護週期（月數）: 60/72/96/192/240';

CREATE INDEX IF NOT EXISTS idx_bom_sheet_type ON "BOM"(sheet_type);
CREATE INDEX IF NOT EXISTS idx_bom_maintenance_period ON "BOM"(maintenance_period);

-- ============================================
-- 3. BOM_LINE 表新增套件編號和 WEC 代碼
-- ============================================

ALTER TABLE "BOM_line" ADD COLUMN IF NOT EXISTS kit_no VARCHAR(50);
COMMENT ON COLUMN "BOM_line".kit_no IS '套件編號';

ALTER TABLE "BOM_line" ADD COLUMN IF NOT EXISTS wec_code VARCHAR(5);
COMMENT ON COLUMN "BOM_line".wec_code IS 'WEC代碼: A/B/C/D';

CREATE INDEX IF NOT EXISTS idx_bom_line_wec ON "BOM_line"(wec_code);

-- ============================================
-- 4. Item_Equipment_Ext 表新增裝備位置
-- ============================================

ALTER TABLE "Item_Equipment_Ext" ADD COLUMN IF NOT EXISTS equipment_location VARCHAR(50);
COMMENT ON COLUMN "Item_Equipment_Ext".equipment_location IS '裝備位置代碼: A01T0, A05.L 等';

CREATE INDEX IF NOT EXISTS idx_equip_ext_location ON "Item_Equipment_Ext"(equipment_location);

-- ============================================
-- 5. 建立 WEC 代碼說明表（可選）
-- ============================================

CREATE TABLE IF NOT EXISTS WEC_Code (
    wec_code VARCHAR(5) PRIMARY KEY,
    code_name_en VARCHAR(100),
    code_name_zh VARCHAR(100),
    description_en TEXT,
    description_zh TEXT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE WEC_Code IS 'WEC 代碼說明表（Work Element Code）';

-- 插入 WEC 代碼定義
INSERT INTO WEC_Code (wec_code, code_name_en, code_name_zh, description_en, description_zh) VALUES
('A', 'Always Replace', '拆卸後必須更換', 'These parts must always be replaced upon removal.', '這些零件拆卸後必須更換。'),
('B', 'Replace at Overhaul', '大修時必須更換', 'These parts must be replaced at every overhaul.', '這些零件在每次大修時必須更換。'),
('C', 'Replace if Worn', '磨損時更換', 'These parts must then be replaced or reconditioned if they have worn so severely that the unit cannot be guaranteed to function reliably with them until the next overhaul.', '這些零件如果磨損嚴重,以至於無法保證設備可靠運行到下次大修,則必須更換或修復。'),
('D', 'Replace at Service and Overhaul', '保養和大修時更換', 'These parts must be replaced at every service and every overhaul.', '這些零件在每次保養和大修時都必須更換。')
ON CONFLICT (wec_code) DO NOTHING;

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '資料庫結構調整完成！';
    RAISE NOTICE '已新增以下欄位：';
    RAISE NOTICE '- Item.project_code';
    RAISE NOTICE '- BOM.sheet_type';
    RAISE NOTICE '- BOM.maintenance_period';
    RAISE NOTICE '- BOM_LINE.kit_no';
    RAISE NOTICE '- BOM_LINE.wec_code';
    RAISE NOTICE '- Item_Equipment_Ext.equipment_location';
    RAISE NOTICE '已建立 WEC_Code 代碼說明表';
    RAISE NOTICE '已建立所有索引';
    RAISE NOTICE '=========================================';
END $$;
