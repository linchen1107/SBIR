-- =====================================================================
-- 檔案名稱: create_public_schema.sql
-- 用途: 建立 public schema（NSN 申編搜尋系統）
-- 資料庫: sbir_equipment_db_v3
-- Schema: public
-- 版本: V3.2
-- 建立日期: 2025-12-26
-- 
-- 說明:
--   此腳本建立 NSN 申編搜尋系統的所有表格和視圖
--   包含 15 個核心表格 + 5 個查詢視圖
--   總資料量: 超過 50 萬筆記錄
-- =====================================================================

-- 設定客戶端編碼
SET client_encoding = 'UTF8';

-- 確保 public schema 存在
CREATE SCHEMA IF NOT EXISTS public;

-- 設定搜尋路徑
SET search_path TO public;

-- =====================================================================
-- 建立觸發器函數：自動更新 date_updated 時間戳
-- =====================================================================

CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.update_timestamp() IS '自動更新 date_updated 欄位的觸發器函數';

-- =====================================================================
-- FSG/FSC 分類系統（3 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. fsg - FSG 聯邦補給群組
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.fsg (
    fsg_code VARCHAR(2) PRIMARY KEY,
    fsg_name VARCHAR(200),
    description TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.fsg IS 'FSG 聯邦補給群組分類表';
COMMENT ON COLUMN public.fsg.fsg_code IS 'FSG 代碼（2 位數字，主鍵）';
COMMENT ON COLUMN public.fsg.fsg_name IS 'FSG 名稱';
COMMENT ON COLUMN public.fsg.description IS 'FSG 說明';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_fsg_name ON public.fsg(fsg_name);

-- 建立觸發器
CREATE TRIGGER trigger_fsg_update_timestamp
    BEFORE UPDATE ON public.fsg
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 2. fsc - FSC 聯邦補給分類
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.fsc (
    fsc_code VARCHAR(4) PRIMARY KEY,
    fsg_code VARCHAR(2) REFERENCES public.fsg(fsg_code),
    fsc_name VARCHAR(200),
    description TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.fsc IS 'FSC 聯邦補給分類表';
COMMENT ON COLUMN public.fsc.fsc_code IS 'FSC 代碼（4 位數字，主鍵）';
COMMENT ON COLUMN public.fsc.fsg_code IS 'FSG 代碼（外鍵）';
COMMENT ON COLUMN public.fsc.fsc_name IS 'FSC 名稱';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_fsc_fsg ON public.fsc(fsg_code);
CREATE INDEX IF NOT EXISTS idx_fsc_name ON public.fsc(fsc_name);

-- 建立觸發器
CREATE TRIGGER trigger_fsc_update_timestamp
    BEFORE UPDATE ON public.fsc
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 3. inc_fsc_xref - INC-FSC 對應表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.inc_fsc_xref (
    inc_code VARCHAR(5) NOT NULL,
    fsc_code VARCHAR(4) NOT NULL,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (inc_code, fsc_code)
);

COMMENT ON TABLE public.inc_fsc_xref IS 'INC 與 FSC 的對應關係表（多對多）';
COMMENT ON COLUMN public.inc_fsc_xref.inc_code IS 'INC 代碼（外鍵）';
COMMENT ON COLUMN public.inc_fsc_xref.fsc_code IS 'FSC 代碼（外鍵）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_inc_fsc_inc ON public.inc_fsc_xref(inc_code);
CREATE INDEX IF NOT EXISTS idx_inc_fsc_fsc ON public.inc_fsc_xref(fsc_code);

-- 建立觸發器
CREATE TRIGGER trigger_inc_fsc_xref_update_timestamp
    BEFORE UPDATE ON public.inc_fsc_xref
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- NATO H6 系統（2 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 4. nato_h6_item_name - NATO H6 物品名稱
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.nato_h6_item_name (
    h6_code VARCHAR(6) PRIMARY KEY,
    item_name_en VARCHAR(200) NOT NULL,
    status_code VARCHAR(1),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.nato_h6_item_name IS 'NATO H6 標準物品名稱主檔';
COMMENT ON COLUMN public.nato_h6_item_name.h6_code IS 'NATO H6 代碼（6 位，主鍵）';
COMMENT ON COLUMN public.nato_h6_item_name.item_name_en IS '物品名稱（英文）';
COMMENT ON COLUMN public.nato_h6_item_name.status_code IS '狀態代碼（A=Active, I=Inactive）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_h6_item_name ON public.nato_h6_item_name(item_name_en);
CREATE INDEX IF NOT EXISTS idx_h6_status ON public.nato_h6_item_name(status_code);

-- 建立觸發器
CREATE TRIGGER trigger_nato_h6_update_timestamp
    BEFORE UPDATE ON public.nato_h6_item_name
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 5. nato_h6_inc_xref - H6-INC 對應表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.nato_h6_inc_xref (
    h6_code VARCHAR(6) NOT NULL,
    inc_code VARCHAR(5) NOT NULL,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (h6_code, inc_code)
);

COMMENT ON TABLE public.nato_h6_inc_xref IS 'NATO H6 與 INC 的對應關係表（多對多）';
COMMENT ON COLUMN public.nato_h6_inc_xref.h6_code IS 'NATO H6 代碼（外鍵）';
COMMENT ON COLUMN public.nato_h6_inc_xref.inc_code IS 'INC 代碼（外鍵）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_h6_inc_h6 ON public.nato_h6_inc_xref(h6_code);
CREATE INDEX IF NOT EXISTS idx_h6_inc_inc ON public.nato_h6_inc_xref(inc_code);

-- 建立觸發器
CREATE TRIGGER trigger_h6_inc_xref_update_timestamp
    BEFORE UPDATE ON public.nato_h6_inc_xref
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- INC 系統（2 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 6. inc - INC 物品名稱代碼
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.inc (
    inc_code VARCHAR(5) PRIMARY KEY,
    noun VARCHAR(100),
    approved_item_name VARCHAR(200),
    status_code VARCHAR(1),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.inc IS 'INC 物品名稱代碼主檔';
COMMENT ON COLUMN public.inc.inc_code IS 'INC 代碼（5 位，主鍵）';
COMMENT ON COLUMN public.inc.noun IS '名詞';
COMMENT ON COLUMN public.inc.approved_item_name IS '核准物品名稱';
COMMENT ON COLUMN public.inc.status_code IS '狀態代碼（A=Active, I=Inactive）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_inc_noun ON public.inc(noun);
CREATE INDEX IF NOT EXISTS idx_inc_item_name ON public.inc(approved_item_name);
CREATE INDEX IF NOT EXISTS idx_inc_status ON public.inc(status_code);

-- 建立觸發器
CREATE TRIGGER trigger_inc_update_timestamp
    BEFORE UPDATE ON public.inc
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 7. colloquial_inc_xref - 俗語-INC 對應表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.colloquial_inc_xref (
    colloquial_name VARCHAR(200) NOT NULL,
    inc_code VARCHAR(5) NOT NULL,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (colloquial_name, inc_code)
);

COMMENT ON TABLE public.colloquial_inc_xref IS '俗語/別名與 INC 的對應關係表（支援模糊搜尋）';
COMMENT ON COLUMN public.colloquial_inc_xref.colloquial_name IS '俗語/別名';
COMMENT ON COLUMN public.colloquial_inc_xref.inc_code IS 'INC 代碼（外鍵）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_colloquial_inc_name ON public.colloquial_inc_xref(colloquial_name);
CREATE INDEX IF NOT EXISTS idx_colloquial_inc_inc ON public.colloquial_inc_xref(inc_code);

-- 建立觸發器
CREATE TRIGGER trigger_colloquial_inc_xref_update_timestamp
    BEFORE UPDATE ON public.colloquial_inc_xref
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- FIIG 系統（2 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 8. fiig - FIIG 識別指南
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.fiig (
    fiig_code VARCHAR(4) PRIMARY KEY,
    fiig_name VARCHAR(200),
    description TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.fiig IS 'FIIG 聯邦物品識別指南主檔';
COMMENT ON COLUMN public.fiig.fiig_code IS 'FIIG 代碼（4 位，主鍵）';
COMMENT ON COLUMN public.fiig.fiig_name IS 'FIIG 名稱';
COMMENT ON COLUMN public.fiig.description IS 'FIIG 說明';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_fiig_name ON public.fiig(fiig_name);

-- 建立觸發器
CREATE TRIGGER trigger_fiig_update_timestamp
    BEFORE UPDATE ON public.fiig
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 9. fiig_inc_xref - FIIG-INC 對應表
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.fiig_inc_xref (
    fiig_code VARCHAR(4) NOT NULL,
    inc_code VARCHAR(5) NOT NULL,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fiig_code, inc_code)
);

COMMENT ON TABLE public.fiig_inc_xref IS 'FIIG 與 INC 的對應關係表（多對多）';
COMMENT ON COLUMN public.fiig_inc_xref.fiig_code IS 'FIIG 代碼（外鍵）';
COMMENT ON COLUMN public.fiig_inc_xref.inc_code IS 'INC 代碼（外鍵）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_fiig_inc_fiig ON public.fiig_inc_xref(fiig_code);
CREATE INDEX IF NOT EXISTS idx_fiig_inc_inc ON public.fiig_inc_xref(inc_code);

-- 建立觸發器
CREATE TRIGGER trigger_fiig_inc_xref_update_timestamp
    BEFORE UPDATE ON public.fiig_inc_xref
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- MRC 系統（4 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 10. mrc_key_group - MRC 群組
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.mrc_key_group (
    key_group VARCHAR(3) PRIMARY KEY,
    group_name VARCHAR(200),
    description TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.mrc_key_group IS 'MRC 群組分類表';
COMMENT ON COLUMN public.mrc_key_group.key_group IS 'MRC 群組代碼（3 位，主鍵）';
COMMENT ON COLUMN public.mrc_key_group.group_name IS '群組名稱';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_mrc_key_group_name ON public.mrc_key_group(group_name);

-- 建立觸發器
CREATE TRIGGER trigger_mrc_key_group_update_timestamp
    BEFORE UPDATE ON public.mrc_key_group
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 11. mrc - MRC 需求代碼
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.mrc (
    mrc_code VARCHAR(5) PRIMARY KEY,
    characteristic VARCHAR(200),
    key_group VARCHAR(3) REFERENCES public.mrc_key_group(key_group),
    seq_no INTEGER,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.mrc IS 'MRC 物料需求代碼主檔（定義申編表單必填欄位）';
COMMENT ON COLUMN public.mrc.mrc_code IS 'MRC 代碼（5 位，主鍵）';
COMMENT ON COLUMN public.mrc.characteristic IS '特性說明';
COMMENT ON COLUMN public.mrc.key_group IS 'MRC 群組代碼（外鍵）';
COMMENT ON COLUMN public.mrc.seq_no IS '順序號碼';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_mrc_key_group ON public.mrc(key_group);
CREATE INDEX IF NOT EXISTS idx_mrc_characteristic ON public.mrc(characteristic);

-- 建立觸發器
CREATE TRIGGER trigger_mrc_update_timestamp
    BEFORE UPDATE ON public.mrc
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 12. fiig_inc_mrc_xref - FIIG-INC-MRC 對應表（核心表）
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.fiig_inc_mrc_xref (
    id SERIAL PRIMARY KEY,
    fiig_code VARCHAR(4) NOT NULL,
    inc_code VARCHAR(5) NOT NULL,
    mrc_code VARCHAR(5) NOT NULL,
    required_flag BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.fiig_inc_mrc_xref IS 'FIIG-INC-MRC 三元對應表（定義每個品項的申編需求）- 170萬筆核心資料';
COMMENT ON COLUMN public.fiig_inc_mrc_xref.id IS '自動編號主鍵';
COMMENT ON COLUMN public.fiig_inc_mrc_xref.fiig_code IS 'FIIG 代碼';
COMMENT ON COLUMN public.fiig_inc_mrc_xref.inc_code IS 'INC 代碼';
COMMENT ON COLUMN public.fiig_inc_mrc_xref.mrc_code IS 'MRC 代碼';
COMMENT ON COLUMN public.fiig_inc_mrc_xref.required_flag IS '是否必填';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_fiig_inc_mrc_fiig ON public.fiig_inc_mrc_xref(fiig_code);
CREATE INDEX IF NOT EXISTS idx_fiig_inc_mrc_inc ON public.fiig_inc_mrc_xref(inc_code);
CREATE INDEX IF NOT EXISTS idx_fiig_inc_mrc_mrc ON public.fiig_inc_mrc_xref(mrc_code);
CREATE INDEX IF NOT EXISTS idx_fiig_inc_mrc_combo ON public.fiig_inc_mrc_xref(fiig_code, inc_code);

-- 建立觸發器
CREATE TRIGGER trigger_fiig_inc_mrc_xref_update_timestamp
    BEFORE UPDATE ON public.fiig_inc_mrc_xref
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- ---------------------------------------------------------------------
-- 13. mrc_reply_table_xref - MRC-回應表對應
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.mrc_reply_table_xref (
    mrc_code VARCHAR(5) NOT NULL,
    reply_table_id INTEGER NOT NULL,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (mrc_code, reply_table_id)
);

COMMENT ON TABLE public.mrc_reply_table_xref IS 'MRC 與回應選項的對應關係表';
COMMENT ON COLUMN public.mrc_reply_table_xref.mrc_code IS 'MRC 代碼（外鍵）';
COMMENT ON COLUMN public.mrc_reply_table_xref.reply_table_id IS '回應表 ID（外鍵）';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_mrc_reply_mrc ON public.mrc_reply_table_xref(mrc_code);
CREATE INDEX IF NOT EXISTS idx_mrc_reply_reply ON public.mrc_reply_table_xref(reply_table_id);

-- 建立觸發器
CREATE TRIGGER trigger_mrc_reply_xref_update_timestamp
    BEFORE UPDATE ON public.mrc_reply_table_xref
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- 回應系統（1 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 14. reply_table - 回應表主檔
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.reply_table (
    id SERIAL PRIMARY KEY,
    reply VARCHAR(200),
    meaning TEXT,
    reply_code VARCHAR(20),
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.reply_table IS '申編表單回應選項主檔（下拉選單內容）- 16萬筆';
COMMENT ON COLUMN public.reply_table.id IS '自動編號主鍵';
COMMENT ON COLUMN public.reply_table.reply IS '回應內容';
COMMENT ON COLUMN public.reply_table.meaning IS '意義說明';
COMMENT ON COLUMN public.reply_table.reply_code IS '回應代碼';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_reply_code ON public.reply_table(reply_code);
CREATE INDEX IF NOT EXISTS idx_reply_text ON public.reply_table(reply);

-- 建立觸發器
CREATE TRIGGER trigger_reply_table_update_timestamp
    BEFORE UPDATE ON public.reply_table
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- 其他（1 個表）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 15. mode_code_edit - 模式碼編輯指南
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.mode_code_edit (
    mode_code VARCHAR(2) PRIMARY KEY,
    mode_name VARCHAR(100),
    description TEXT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.mode_code_edit IS '模式碼編輯規則表';
COMMENT ON COLUMN public.mode_code_edit.mode_code IS '模式代碼（2 位，主鍵）';
COMMENT ON COLUMN public.mode_code_edit.mode_name IS '模式名稱';
COMMENT ON COLUMN public.mode_code_edit.description IS '編輯規則說明';

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_mode_code_name ON public.mode_code_edit(mode_name);

-- 建立觸發器
CREATE TRIGGER trigger_mode_code_edit_update_timestamp
    BEFORE UPDATE ON public.mode_code_edit
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================
-- 建立外鍵約束（延遲到所有表格建立後）
-- =====================================================================

-- INC-FSC 外鍵
ALTER TABLE public.inc_fsc_xref
    ADD CONSTRAINT fk_inc_fsc_inc FOREIGN KEY (inc_code) REFERENCES public.inc(inc_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_inc_fsc_fsc FOREIGN KEY (fsc_code) REFERENCES public.fsc(fsc_code) ON DELETE CASCADE;

-- NATO H6-INC 外鍵
ALTER TABLE public.nato_h6_inc_xref
    ADD CONSTRAINT fk_h6_inc_h6 FOREIGN KEY (h6_code) REFERENCES public.nato_h6_item_name(h6_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_h6_inc_inc FOREIGN KEY (inc_code) REFERENCES public.inc(inc_code) ON DELETE CASCADE;

-- FIIG-INC 外鍵
ALTER TABLE public.fiig_inc_xref
    ADD CONSTRAINT fk_fiig_inc_fiig FOREIGN KEY (fiig_code) REFERENCES public.fiig(fiig_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_fiig_inc_inc FOREIGN KEY (inc_code) REFERENCES public.inc(inc_code) ON DELETE CASCADE;

-- FIIG-INC-MRC 外鍵
ALTER TABLE public.fiig_inc_mrc_xref
    ADD CONSTRAINT fk_fiig_inc_mrc_fiig FOREIGN KEY (fiig_code) REFERENCES public.fiig(fiig_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_fiig_inc_mrc_inc FOREIGN KEY (inc_code) REFERENCES public.inc(inc_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_fiig_inc_mrc_mrc FOREIGN KEY (mrc_code) REFERENCES public.mrc(mrc_code) ON DELETE CASCADE;

-- MRC-Reply 外鍵
ALTER TABLE public.mrc_reply_table_xref
    ADD CONSTRAINT fk_mrc_reply_mrc FOREIGN KEY (mrc_code) REFERENCES public.mrc(mrc_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_mrc_reply_reply FOREIGN KEY (reply_table_id) REFERENCES public.reply_table(id) ON DELETE CASCADE;

-- =====================================================================
-- 建立查詢視圖（5 個）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 視圖 1: v_h6_inc_mapping - H6→INC 完整對應
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_h6_inc_mapping AS
SELECT 
    h6.h6_code,
    h6.item_name_en AS h6_item_name,
    h6.status_code AS h6_status,
    xref.inc_code,
    inc.noun AS inc_noun,
    inc.approved_item_name AS inc_approved_name,
    inc.status_code AS inc_status
FROM public.nato_h6_item_name h6
INNER JOIN public.nato_h6_inc_xref xref ON h6.h6_code = xref.h6_code
INNER JOIN public.inc inc ON xref.inc_code = inc.inc_code;

COMMENT ON VIEW public.v_h6_inc_mapping IS 'NATO H6 轉 INC 完整對應視圖';

-- ---------------------------------------------------------------------
-- 視圖 2: v_inc_fiig_mapping - INC→FIIG 完整對應
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_inc_fiig_mapping AS
SELECT 
    inc.inc_code,
    inc.noun AS inc_noun,
    inc.approved_item_name AS inc_approved_name,
    xref.fiig_code,
    fiig.fiig_name,
    fiig.description AS fiig_description
FROM public.inc inc
INNER JOIN public.fiig_inc_xref xref ON inc.inc_code = xref.inc_code
INNER JOIN public.fiig fiig ON xref.fiig_code = fiig.fiig_code;

COMMENT ON VIEW public.v_inc_fiig_mapping IS 'INC 轉 FIIG 完整對應視圖';

-- ---------------------------------------------------------------------
-- 視圖 3: v_fiig_mrc_requirements - FIIG→MRC 申編需求
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_fiig_mrc_requirements AS
SELECT 
    xref.fiig_code,
    fiig.fiig_name,
    xref.inc_code,
    inc.approved_item_name AS inc_name,
    xref.mrc_code,
    mrc.characteristic AS mrc_characteristic,
    mrc.key_group,
    kg.group_name AS key_group_name,
    xref.required_flag,
    mrc.seq_no
FROM public.fiig_inc_mrc_xref xref
INNER JOIN public.fiig fiig ON xref.fiig_code = fiig.fiig_code
INNER JOIN public.inc inc ON xref.inc_code = inc.inc_code
INNER JOIN public.mrc mrc ON xref.mrc_code = mrc.mrc_code
LEFT JOIN public.mrc_key_group kg ON mrc.key_group = kg.key_group
ORDER BY xref.fiig_code, xref.inc_code, mrc.seq_no;

COMMENT ON VIEW public.v_fiig_mrc_requirements IS 'FIIG-INC 申編 MRC 需求查詢視圖';

-- ---------------------------------------------------------------------
-- 視圖 4: v_mrc_reply_options - MRC 回應選項
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_mrc_reply_options AS
SELECT 
    mrc.mrc_code,
    mrc.characteristic AS mrc_characteristic,
    mrc.key_group,
    rt.id AS reply_id,
    rt.reply,
    rt.meaning AS reply_meaning,
    rt.reply_code
FROM public.mrc mrc
INNER JOIN public.mrc_reply_table_xref xref ON mrc.mrc_code = xref.mrc_code
INNER JOIN public.reply_table rt ON xref.reply_table_id = rt.id
ORDER BY mrc.mrc_code, rt.id;

COMMENT ON VIEW public.v_mrc_reply_options IS 'MRC 回應選項查詢視圖（下拉選單內容）';

-- ---------------------------------------------------------------------
-- 視圖 5: v_application_flow - 完整申編流程
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_application_flow AS
SELECT 
    h6.h6_code,
    h6.item_name_en AS h6_name,
    h6_inc.inc_code,
    inc.approved_item_name AS inc_name,
    inc_fiig.fiig_code,
    fiig.fiig_name,
    fim.mrc_code,
    mrc.characteristic AS mrc_characteristic,
    mrc.key_group,
    fim.required_flag,
    mrc.seq_no
FROM public.nato_h6_item_name h6
INNER JOIN public.nato_h6_inc_xref h6_inc ON h6.h6_code = h6_inc.h6_code
INNER JOIN public.inc inc ON h6_inc.inc_code = inc.inc_code
INNER JOIN public.fiig_inc_xref inc_fiig ON inc.inc_code = inc_fiig.inc_code
INNER JOIN public.fiig fiig ON inc_fiig.fiig_code = fiig.fiig_code
INNER JOIN public.fiig_inc_mrc_xref fim ON fiig.fiig_code = fim.fiig_code AND inc.inc_code = fim.inc_code
INNER JOIN public.mrc mrc ON fim.mrc_code = mrc.mrc_code
ORDER BY h6.h6_code, inc.inc_code, fiig.fiig_code, mrc.seq_no;

COMMENT ON VIEW public.v_application_flow IS '端到端申編流程視圖（H6→INC→FIIG→MRC）';

-- =====================================================================
-- 完成訊息
-- =====================================================================

DO $$ 
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'public schema 建立完成！';
    RAISE NOTICE '========================================';
    RAISE NOTICE '已建立:';
    RAISE NOTICE '  - 15 個核心表格';
    RAISE NOTICE '  - 5 個查詢視圖';
    RAISE NOTICE '  - 所有索引與外鍵約束';
    RAISE NOTICE '  - 時間戳自動更新觸發器';
    RAISE NOTICE '========================================';
    RAISE NOTICE '下一步: 匯入 NSN 資料';
    RAISE NOTICE '========================================';
END $$;
