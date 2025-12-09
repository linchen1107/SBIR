-- ============================================
-- 更新 Item_Equipment_Ext 和 Item_Material_Ext 表
-- 用途: 新增缺少的欄位以符合舊版 Equipment 和 Item 表結構
-- 執行日期: 2025-11-20
-- 版本: V3.1
-- ============================================

-- 連接到資料庫
\c sbir_equipment_db_v2;

-- ============================================
-- 更新 Item_Equipment_Ext (裝備擴展表)
-- ============================================

-- 新增父裝備中英文名稱欄位
ALTER TABLE Item_Equipment_Ext
ADD COLUMN IF NOT EXISTS parent_equipment_zh VARCHAR(100),
ADD COLUMN IF NOT EXISTS parent_equipment_en VARCHAR(200);

-- 新增欄位註解
COMMENT ON COLUMN Item_Equipment_Ext.parent_equipment_zh IS '上層適用裝備中文名稱';
COMMENT ON COLUMN Item_Equipment_Ext.parent_equipment_en IS '上層適用裝備英文名稱';

-- 更新現有欄位註解
COMMENT ON COLUMN Item_Equipment_Ext.equipment_type IS '裝備形式（裝備型號/型式）';
COMMENT ON COLUMN Item_Equipment_Ext.position IS '裝設地點（安裝位置）';
COMMENT ON COLUMN Item_Equipment_Ext.eswbs_code IS '族群結構碼HSC（ESWBS五碼）';
COMMENT ON COLUMN Item_Equipment_Ext.installation_qty IS '同一類型數量（單艦裝置數量）';
COMMENT ON COLUMN Item_Equipment_Ext.equipment_serial IS '裝備序號（裝備識別編號）';

-- ============================================
-- 更新 Item_Material_Ext (料件擴展表)
-- ============================================

-- 新增簡短中文名和撥發單位欄位
ALTER TABLE Item_Material_Ext
ADD COLUMN IF NOT EXISTS item_name_zh_short VARCHAR(20),
ADD COLUMN IF NOT EXISTS issue_unit VARCHAR(10);

-- 新增欄位註解
COMMENT ON COLUMN Item_Material_Ext.item_name_zh_short IS '中文品名（9字內）';
COMMENT ON COLUMN Item_Material_Ext.issue_unit IS '撥發單位（EA/SET/LOT等）';

-- 更新現有欄位註解
COMMENT ON COLUMN Item_Material_Ext.security_code IS '機密性代號（U/C/S等）';
COMMENT ON COLUMN Item_Material_Ext.consumable_code IS '消耗性代號（M/N等）';
COMMENT ON COLUMN Item_Material_Ext.life_process_code IS '處理代號（壽限處理）';

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Item_Equipment_Ext 表已更新: 新增 parent_equipment_zh, parent_equipment_en';
    RAISE NOTICE '✅ Item_Material_Ext 表已更新: 新增 item_name_zh_short, issue_unit';
    RAISE NOTICE '✅ 所有欄位註解已更新';
END $$;
