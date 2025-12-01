-- =====================================================
-- EMU3000 維修物料擴展表
-- =====================================================
-- 用途：儲存 EMU3000 系統的維修物料清單資料
-- 建立日期：2025-12-01
-- 資料來源：EMU 3000 維修物料清單 Excel 檔案
-- =====================================================

-- 先刪除現有表（如果存在）
DROP TABLE IF EXISTS Item_EMU3000_Maintenance_Ext CASCADE;

-- 創建 Item_EMU3000_Maintenance_Ext 表
CREATE TABLE Item_EMU3000_Maintenance_Ext (
    -- 主鍵（外鍵連結至 Item）
    item_uuid UUID PRIMARY KEY REFERENCES Item(item_uuid) ON DELETE CASCADE,

    -- Excel 原始欄位
    part VARCHAR(50),              -- Part (零件序號，如 "1", "2", "5"...)
    quantity DECIMAL(10,2),        -- Quantity (數量)
    unit VARCHAR(20),              -- Unit (單位：Pee, EA, SET...)
    name VARCHAR(255),             -- Name (零件名稱)
    wec VARCHAR(10),               -- WEC 代碼 (A/B/C)
    notes TEXT,                    -- Notes (備註)
    kit_no VARCHAR(50),            -- Kit No (套件編號，如 C20T0)

    -- 時間戳
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 創建索引
CREATE INDEX IF NOT EXISTS idx_emu3000_part ON Item_EMU3000_Maintenance_Ext(part);
CREATE INDEX IF NOT EXISTS idx_emu3000_kit_no ON Item_EMU3000_Maintenance_Ext(kit_no);
CREATE INDEX IF NOT EXISTS idx_emu3000_wec ON Item_EMU3000_Maintenance_Ext(wec);

-- 創建觸發器（自動更新 date_updated）
CREATE TRIGGER update_emu3000_date_updated
    BEFORE UPDATE ON Item_EMU3000_Maintenance_Ext
    FOR EACH ROW
    EXECUTE FUNCTION update_date_updated_column();

-- 新增註釋
COMMENT ON TABLE Item_EMU3000_Maintenance_Ext IS 'EMU3000維修物料擴展表';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.item_uuid IS '主鍵（外鍵連結至 Item 表）';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.part IS '零件序號';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.quantity IS '數量';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.unit IS '單位';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.name IS '零件名稱';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.wec IS 'WEC代碼 (A/B/C)';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.notes IS '備註';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.kit_no IS '套件編號';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.date_created IS '建立時間';
COMMENT ON COLUMN Item_EMU3000_Maintenance_Ext.date_updated IS '更新時間';

-- 完成訊息
SELECT 'Item_EMU3000_Maintenance_Ext 表創建完成' AS status;
