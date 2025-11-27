-- ============================================
-- NSN 料號申編系統 - 核心整合腳本（客製化版）
-- 資料庫: sbir_equipment_db_v2
-- 適配: 大寫表格名稱
-- 建立日期: 2025-11-24
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 步驟 1：重命名現有 MRC 表（保留現有資料）
-- ============================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'MRC') THEN
        -- 重命名表格
        ALTER TABLE "MRC" RENAME TO "Item_MRC_Answer";

        -- 更新註解
        COMMENT ON TABLE "Item_MRC_Answer" IS '品項MRC答案表（儲存已填寫的規格答案）';

        -- 重命名索引
        ALTER INDEX IF EXISTS idx_mrc_item RENAME TO idx_item_mrc_answer_item;
        ALTER INDEX IF EXISTS idx_mrc_abbr RENAME TO idx_item_mrc_answer_abbr;

        -- 重命名觸發器
        DROP TRIGGER IF EXISTS update_mrc_updated_at ON "Item_MRC_Answer";
        CREATE TRIGGER update_item_mrc_answer_updated_at
            BEFORE UPDATE ON "Item_MRC_Answer"
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

        RAISE NOTICE '✓ MRC 表已重命名為 Item_MRC_Answer';
    ELSE
        RAISE NOTICE '⊘ MRC 表不存在或已重命名';
    END IF;
END $$;

-- ============================================
-- 步驟 2：建立 INC 物品代碼系統（2張表）
-- ============================================

-- 2.1 INC 主檔
CREATE TABLE IF NOT EXISTS NSN_INC (
    inc_code VARCHAR(10) PRIMARY KEY,
    short_name VARCHAR(50),
    name_prefix VARCHAR(50),
    name_root_remainder VARCHAR(100),
    item_name_definition TEXT,
    status_code VARCHAR(2) DEFAULT 'A' CHECK (status_code IN ('A', 'I', 'C')),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE NSN_INC IS 'INC 物品名稱代碼主檔（NSN系統）';
COMMENT ON COLUMN NSN_INC.inc_code IS 'INC代碼（5位數字，例：00009）';
COMMENT ON COLUMN NSN_INC.short_name IS 'INC簡稱';
COMMENT ON COLUMN NSN_INC.name_prefix IS '名稱前綴';
COMMENT ON COLUMN NSN_INC.name_root_remainder IS '名稱主體';
COMMENT ON COLUMN NSN_INC.item_name_definition IS '物品名稱完整定義';
COMMENT ON COLUMN NSN_INC.status_code IS '狀態：A=Active, I=Inactive, C=Cancelled';

-- 索引
CREATE INDEX IF NOT EXISTS idx_nsn_inc_status ON NSN_INC(status_code);
CREATE INDEX IF NOT EXISTS idx_nsn_inc_short_name ON NSN_INC(short_name);

-- 2.2 俗名 INC 對應表（選配）
CREATE TABLE IF NOT EXISTS NSN_Colloquial_INC_xref (
    primary_inc_code VARCHAR(10),
    colloquial_inc_code VARCHAR(10),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (primary_inc_code, colloquial_inc_code),
    FOREIGN KEY (primary_inc_code) REFERENCES NSN_INC(inc_code) ON DELETE CASCADE,
    FOREIGN KEY (colloquial_inc_code) REFERENCES NSN_INC(inc_code) ON DELETE CASCADE
);

COMMENT ON TABLE NSN_Colloquial_INC_xref IS 'INC俗名對應表（俗名INC對應到正式INC）';

-- ============================================
-- 步驟 3：建立 FSC/FSG 分類系統（3張表）
-- ============================================

-- 3.1 FSG 主檔
CREATE TABLE IF NOT EXISTS NSN_FSG (
    fsg_code VARCHAR(2) PRIMARY KEY,
    fsg_title VARCHAR(200),
    fsg_title_zh VARCHAR(100),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE NSN_FSG IS 'FSG 聯邦補給群組（NSN系統）';
COMMENT ON COLUMN NSN_FSG.fsg_code IS 'FSG代碼（2位數，例：59）';
COMMENT ON COLUMN NSN_FSG.fsg_title IS 'FSG英文名稱';
COMMENT ON COLUMN NSN_FSG.fsg_title_zh IS 'FSG中文名稱';

-- 3.2 FSC 主檔
CREATE TABLE IF NOT EXISTS NSN_FSC (
    fsc_code VARCHAR(4) PRIMARY KEY,
    fsg_code VARCHAR(2),
    fsc_title VARCHAR(200),
    fsc_title_zh VARCHAR(100),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fsg_code) REFERENCES NSN_FSG(fsg_code) ON DELETE SET NULL
);

COMMENT ON TABLE NSN_FSC IS 'FSC 聯邦補給分類（NSN系統）';
COMMENT ON COLUMN NSN_FSC.fsc_code IS 'FSC代碼（4位數，例：5995）';
COMMENT ON COLUMN NSN_FSC.fsg_code IS '所屬FSG代碼';
COMMENT ON COLUMN NSN_FSC.fsc_title IS 'FSC英文名稱';
COMMENT ON COLUMN NSN_FSC.fsc_title_zh IS 'FSC中文名稱';

-- 索引
CREATE INDEX IF NOT EXISTS idx_nsn_fsc_fsg ON NSN_FSC(fsg_code);

-- 3.3 INC-FSC 對應表
CREATE TABLE IF NOT EXISTS NSN_INC_FSC_xref (
    inc_code VARCHAR(10),
    fsc_code VARCHAR(4),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (inc_code, fsc_code),
    FOREIGN KEY (inc_code) REFERENCES NSN_INC(inc_code) ON DELETE CASCADE,
    FOREIGN KEY (fsc_code) REFERENCES NSN_FSC(fsc_code) ON DELETE CASCADE
);

COMMENT ON TABLE NSN_INC_FSC_xref IS 'INC與FSC對應關係（多對多）';

-- ============================================
-- 步驟 4：建立 FIIG 識別指南系統（2張表）
-- ============================================

-- 4.1 FIIG 主檔
CREATE TABLE IF NOT EXISTS NSN_FIIG (
    fiig_code VARCHAR(10) PRIMARY KEY,
    fiig_description TEXT,
    fiig_description_zh TEXT,
    status_code VARCHAR(2) DEFAULT 'A' CHECK (status_code IN ('A', 'I')),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE NSN_FIIG IS 'FIIG 物品識別指南主檔（NSN系統）';
COMMENT ON COLUMN NSN_FIIG.fiig_code IS 'FIIG代碼（例：A001A0）';
COMMENT ON COLUMN NSN_FIIG.fiig_description IS 'FIIG英文描述';
COMMENT ON COLUMN NSN_FIIG.fiig_description_zh IS 'FIIG中文描述';
COMMENT ON COLUMN NSN_FIIG.status_code IS '狀態：A=Active, I=Inactive';

-- 索引
CREATE INDEX IF NOT EXISTS idx_nsn_fiig_status ON NSN_FIIG(status_code);

-- 4.2 FIIG-INC 對應表
CREATE TABLE IF NOT EXISTS NSN_FIIG_INC_xref (
    fiig_code VARCHAR(10),
    inc_code VARCHAR(10),
    sort_order INT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fiig_code, inc_code),
    FOREIGN KEY (fiig_code) REFERENCES NSN_FIIG(fiig_code) ON DELETE CASCADE,
    FOREIGN KEY (inc_code) REFERENCES NSN_INC(inc_code) ON DELETE CASCADE
);

COMMENT ON TABLE NSN_FIIG_INC_xref IS 'FIIG與INC對應關係（多對多）';

-- 索引
CREATE INDEX IF NOT EXISTS idx_nsn_fiig_inc_xref_inc ON NSN_FIIG_INC_xref(inc_code);
CREATE INDEX IF NOT EXISTS idx_nsn_fiig_inc_xref_fiig ON NSN_FIIG_INC_xref(fiig_code);

-- ============================================
-- 步驟 5：建立 MRC 需求代碼系統（1張表）
-- ============================================

CREATE TABLE IF NOT EXISTS NSN_MRC (
    mrc_code VARCHAR(10) PRIMARY KEY,
    requirement_statement TEXT,
    requirement_statement_zh TEXT,
    data_type VARCHAR(20) DEFAULT 'TEXT' CHECK (data_type IN ('TEXT', 'NUMBER', 'SELECT', 'DATE', 'BOOLEAN')),
    is_required BOOLEAN DEFAULT TRUE,
    key_group_number VARCHAR(10),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE NSN_MRC IS 'MRC 需求代碼主檔（問題定義）';
COMMENT ON COLUMN NSN_MRC.mrc_code IS 'MRC代碼（例：AAPE）';
COMMENT ON COLUMN NSN_MRC.requirement_statement IS 'MRC問題陳述（英文）';
COMMENT ON COLUMN NSN_MRC.requirement_statement_zh IS 'MRC問題陳述（中文）';
COMMENT ON COLUMN NSN_MRC.data_type IS '資料類型：TEXT/NUMBER/SELECT/DATE/BOOLEAN';
COMMENT ON COLUMN NSN_MRC.is_required IS '是否必填';
COMMENT ON COLUMN NSN_MRC.key_group_number IS 'MRC分組編號';

-- 索引
CREATE INDEX IF NOT EXISTS idx_nsn_mrc_key_group ON NSN_MRC(key_group_number);

-- ============================================
-- 步驟 6：修改 item_material_ext 表（建立外鍵）
-- ============================================

DO $$
BEGIN
    -- 檢查是否需要新增 inc_code 欄位
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'item_material_ext'
        AND column_name = 'inc_code'
    ) THEN
        ALTER TABLE item_material_ext ADD COLUMN inc_code VARCHAR(10);
        COMMENT ON COLUMN item_material_ext.inc_code IS 'NSN INC代碼（關聯到NSN_INC）';
        CREATE INDEX idx_item_material_inc ON item_material_ext(inc_code);

        RAISE NOTICE '✓ 已新增 item_material_ext.inc_code 欄位';
    ELSE
        RAISE NOTICE '⊘ item_material_ext.inc_code 欄位已存在';
    END IF;
END $$;

-- ============================================
-- 步驟 7：建立自動更新觸發器
-- ============================================

-- 確保更新函數存在
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- NSN_INC
DROP TRIGGER IF EXISTS update_nsn_inc_date_updated ON NSN_INC;
CREATE TRIGGER update_nsn_inc_date_updated BEFORE UPDATE ON NSN_INC
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- NSN_FSG
DROP TRIGGER IF EXISTS update_nsn_fsg_date_updated ON NSN_FSG;
CREATE TRIGGER update_nsn_fsg_date_updated BEFORE UPDATE ON NSN_FSG
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- NSN_FSC
DROP TRIGGER IF EXISTS update_nsn_fsc_date_updated ON NSN_FSC;
CREATE TRIGGER update_nsn_fsc_date_updated BEFORE UPDATE ON NSN_FSC
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- NSN_FIIG
DROP TRIGGER IF EXISTS update_nsn_fiig_date_updated ON NSN_FIIG;
CREATE TRIGGER update_nsn_fiig_date_updated BEFORE UPDATE ON NSN_FIIG
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- NSN_MRC
DROP TRIGGER IF EXISTS update_nsn_mrc_date_updated ON NSN_MRC;
CREATE TRIGGER update_nsn_mrc_date_updated BEFORE UPDATE ON NSN_MRC
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 步驟 8：插入測試資料（範例）
-- ============================================

-- 8.1 FSG/FSC 範例資料
INSERT INTO NSN_FSG (fsg_code, fsg_title, fsg_title_zh) VALUES
    ('63', 'ALARM, SIGNAL, AND SECURITY DETECTION SYSTEMS', '警報、信號與安全偵測系統'),
    ('59', 'ELECTRICAL AND ELECTRONIC EQUIPMENT COMPONENTS', '電氣電子設備元件')
ON CONFLICT (fsg_code) DO NOTHING;

INSERT INTO NSN_FSC (fsc_code, fsg_code, fsc_title, fsc_title_zh) VALUES
    ('6350', '63', 'MISCELLANEOUS ALARM, SIGNAL, AND SECURITY DETECTION SYSTEMS', '雜項警報信號系統'),
    ('5995', '59', 'CABLE, CORD, AND WIRE ASSEMBLIES: COMMUNICATION EQUIPMENT', '通訊設備線纜組件')
ON CONFLICT (fsc_code) DO NOTHING;

-- 8.2 INC 範例資料
INSERT INTO NSN_INC (inc_code, short_name, name_prefix, name_root_remainder, item_name_definition, status_code) VALUES
    ('00009', 'CABLE', 'ELECTRIC', 'CABLE ASSEMBLY', 'ELECTRIC CABLE ASSEMBLY', 'A'),
    ('17566', 'EJECTOR', '', 'JET EJECTOR', 'JET EJECTOR DEVICE', 'A'),
    ('28901', 'PUMP', 'WATER', 'WATER PUMP', 'WATER PUMPING DEVICE', 'A')
ON CONFLICT (inc_code) DO NOTHING;

-- 8.3 INC-FSC 關聯
INSERT INTO NSN_INC_FSC_xref (inc_code, fsc_code) VALUES
    ('00009', '5995'),
    ('17566', '6350'),
    ('28901', '6350')
ON CONFLICT (inc_code, fsc_code) DO NOTHING;

-- 8.4 FIIG 範例資料
INSERT INTO NSN_FIIG (fiig_code, fiig_description, fiig_description_zh, status_code) VALUES
    ('A001A0', 'CABLE ASSEMBLY, POWER, ELECTRICAL', '電力線纜組件', 'A'),
    ('A123B5', 'EJECTOR, JET TYPE', '噴射式噴射器', 'A')
ON CONFLICT (fiig_code) DO NOTHING;

-- 8.5 FIIG-INC 關聯
INSERT INTO NSN_FIIG_INC_xref (fiig_code, inc_code, sort_order) VALUES
    ('A001A0', '00009', 1),
    ('A123B5', '17566', 1)
ON CONFLICT (fiig_code, inc_code) DO NOTHING;

-- 8.6 MRC 範例資料
INSERT INTO NSN_MRC (mrc_code, requirement_statement, requirement_statement_zh, data_type, is_required) VALUES
    ('CLQL', 'COLLOQUIAL NAME', '口語名稱', 'TEXT', FALSE),
    ('VOLT', 'VOLTAGE RATING', '額定電壓', 'TEXT', TRUE),
    ('OUTP', 'OUTPUT POWER', '輸出功率', 'NUMBER', TRUE),
    ('COLR', 'COLOR', '顏色', 'SELECT', FALSE)
ON CONFLICT (mrc_code) DO NOTHING;

-- ============================================
-- 完成訊息與統計
-- ============================================

DO $$
DECLARE
    table_count INT;
    item_count INT;
    mrc_answer_count INT;
BEGIN
    -- 計算 NSN 表格數量
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name LIKE 'nsn_%';

    -- 取得品項與MRC答案數量
    SELECT COUNT(*) INTO item_count FROM "ITEM";
    SELECT COUNT(*) INTO mrc_answer_count FROM "Item_MRC_Answer";

    RAISE NOTICE '=========================================';
    RAISE NOTICE 'NSN 核心系統整合完成！';
    RAISE NOTICE '=========================================';
    RAISE NOTICE '已建立 NSN 表格數: %', table_count;
    RAISE NOTICE '現有品項數量: %', item_count;
    RAISE NOTICE '現有 MRC 答案數: %', mrc_answer_count;
    RAISE NOTICE '';
    RAISE NOTICE '新增表格清單：';
    RAISE NOTICE '  ✓ NSN_INC - INC物品代碼主檔';
    RAISE NOTICE '  ✓ NSN_Colloquial_INC_xref - INC俗名對應';
    RAISE NOTICE '  ✓ NSN_FSG - FSG補給群組';
    RAISE NOTICE '  ✓ NSN_FSC - FSC補給分類';
    RAISE NOTICE '  ✓ NSN_INC_FSC_xref - INC-FSC對應';
    RAISE NOTICE '  ✓ NSN_FIIG - FIIG識別指南';
    RAISE NOTICE '  ✓ NSN_FIIG_INC_xref - FIIG-INC對應';
    RAISE NOTICE '  ✓ NSN_MRC - MRC需求代碼（問題定義）';
    RAISE NOTICE '';
    RAISE NOTICE '修改表格：';
    RAISE NOTICE '  ✓ MRC → Item_MRC_Answer（已重命名）';
    RAISE NOTICE '  ✓ item_material_ext（已新增 inc_code 欄位）';
    RAISE NOTICE '';
    RAISE NOTICE '已插入測試資料：';
    RAISE NOTICE '  - FSG: 2 筆';
    RAISE NOTICE '  - FSC: 2 筆';
    RAISE NOTICE '  - INC: 3 筆';
    RAISE NOTICE '  - FIIG: 2 筆';
    RAISE NOTICE '  - MRC: 4 筆';
    RAISE NOTICE '';
    RAISE NOTICE '下一步：';
    RAISE NOTICE '  1. 執行驗證腳本確認整合成功';
    RAISE NOTICE '  2. 更新現有品項的 inc_code 欄位';
    RAISE NOTICE '  3. 建立實用視圖與查詢函數';
    RAISE NOTICE '=========================================';
END $$;
