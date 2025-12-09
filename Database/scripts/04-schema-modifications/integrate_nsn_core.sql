-- ================================================================
-- Schema 整合腳本: 重構 public → web_app + 建立 NSN 系統
-- 建立日期: 2025-12-08
-- 用途: 
--   1. 將現有的 public schema 更名為 web_app
--   2. 建立新的 public schema
--   3. 在新 public schema 中建立 NSN 申編系統表格 (15張核心表格)
-- ================================================================

SET client_encoding = 'UTF8';

-- ================================================================
-- 第一階段: Schema 重構
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '第一階段: Schema 重構';
    RAISE NOTICE '==============================================';
END $$;

-- 1. 將 public schema 更名為 web_app
ALTER SCHEMA public RENAME TO web_app;

-- 2. 建立新的 public schema
CREATE SCHEMA public;

-- 3. 設定新 public schema 的權限
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

DO $$
BEGIN
    RAISE NOTICE '✅ 舊 public schema 已更名為 web_app';
    RAISE NOTICE '✅ 已建立新的空 public schema';
END $$;

-- ================================================================
-- 第二階段: 在新 public schema 中建立 NSN 系統表格
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '第二階段: 建立 NSN 申編系統表格';
    RAISE NOTICE '==============================================';
END $$;

-- FSG/FSC 分類系統 (3張表格)
-- ================================================================

-- FSG (Federal Supply Group) - 聯邦補給群組
CREATE TABLE public.fsg (
    fsg_code VARCHAR(2) PRIMARY KEY,
    fsg_title TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FSC (Federal Supply Class) - 聯邦補給分類
CREATE TABLE public.fsc (
    fsc_code VARCHAR(4) PRIMARY KEY,
    fsg_code VARCHAR(2) NOT NULL REFERENCES public.fsg(fsg_code),
    fsc_title VARCHAR(255) NOT NULL,
    fsc_includes TEXT,
    fsc_excludes TEXT,
    fsc_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INC與FSC對應表
CREATE TABLE public.inc_fsc_xref (
    inc_code VARCHAR(15) NOT NULL,
    fsc_code VARCHAR(4) NOT NULL REFERENCES public.fsc(fsc_code),
    PRIMARY KEY (inc_code, fsc_code),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NATO H6 物品名稱系統 (2張表格)
-- ================================================================

-- NATO H6 物品名稱主檔
CREATE TABLE public.nato_h6_item_name (
    h6_record_id VARCHAR(20) PRIMARY KEY,
    nato_item_name VARCHAR(255) NOT NULL,
    english_description TEXT,
    country_code VARCHAR(3),
    status_code VARCHAR(1) DEFAULT 'A' CHECK (status_code IN ('A', 'I', 'P')),
    h6_number VARCHAR(20),
    created_date DATE,
    modified_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NATO H6 與 INC 對應表
CREATE TABLE public.nato_h6_inc_xref (
    h6_record_id VARCHAR(20) NOT NULL REFERENCES public.nato_h6_item_name(h6_record_id),
    inc_code VARCHAR(15) NOT NULL,
    relationship_type VARCHAR(10) DEFAULT 'EXACT',
    confidence_level INTEGER DEFAULT 100 CHECK (confidence_level BETWEEN 0 AND 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (h6_record_id, inc_code)
);

-- INC 物品名稱代碼系統 (2張表格)
-- ================================================================

-- INC (Item Name Code) - 物品名稱代碼
CREATE TABLE public.inc (
    inc_code VARCHAR(15) PRIMARY KEY,
    short_name TEXT,
    name_prefix TEXT,
    name_root_remainder TEXT,
    search_text VARCHAR(500),
    item_name_definition TEXT,
    status_code VARCHAR(1) DEFAULT 'A' CHECK (status_code IN ('A', 'I', 'P', 'S')),
    is_official BOOLEAN DEFAULT TRUE,
    effective_date DATE,
    obsolete_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 俗語INC對應表
CREATE TABLE public.colloquial_inc_xref (
    primary_inc_code VARCHAR(15) NOT NULL REFERENCES public.inc(inc_code),
    colloquial_inc_code VARCHAR(15) NOT NULL REFERENCES public.inc(inc_code),
    relationship_type VARCHAR(20) DEFAULT 'SYNONYM',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (primary_inc_code, colloquial_inc_code)
);

-- FIIG 識別指南系統 (2張表格)
-- ================================================================

-- FIIG (Federal Item Identification Guide) - 聯邦物品識別指南
CREATE TABLE public.fiig (
    fiig_code VARCHAR(10) PRIMARY KEY,
    fiig_description TEXT NOT NULL,
    status_code VARCHAR(1) DEFAULT 'A' CHECK (status_code IN ('A', 'I', 'S')),
    effective_date DATE,
    obsolete_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FIIG與INC對應表
CREATE TABLE public.fiig_inc_xref (
    fiig_code VARCHAR(10) NOT NULL REFERENCES public.fiig(fiig_code),
    inc_code VARCHAR(15) NOT NULL REFERENCES public.inc(inc_code),
    relationship_type VARCHAR(20) DEFAULT 'APPLIES_TO',
    sort_order INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fiig_code, inc_code)
);

-- MRC 需求代碼系統 (4張表格)
-- ================================================================

-- MRC群組
CREATE TABLE public.mrc_key_group (
    key_group_number VARCHAR(5) PRIMARY KEY,
    group_description TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MRC (Materiel Requirement Code) - 物料需求代碼
CREATE TABLE public.mrc (
    mrc_code VARCHAR(10) PRIMARY KEY,
    requirement_statement TEXT NOT NULL,
    key_group_number VARCHAR(5) REFERENCES public.mrc_key_group(key_group_number),
    data_type VARCHAR(20) DEFAULT 'TEXT',
    max_length INTEGER,
    is_required BOOLEAN DEFAULT FALSE,
    validation_pattern VARCHAR(255),
    help_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FIIG-INC-MRC 三元對應表 (申編核心)
CREATE TABLE public.fiig_inc_mrc_xref (
    fiig_code VARCHAR(10) NOT NULL REFERENCES public.fiig(fiig_code),
    inc_code VARCHAR(15) NOT NULL REFERENCES public.inc(inc_code),
    mrc_code VARCHAR(10) NOT NULL REFERENCES public.mrc(mrc_code),
    sort_num INTEGER NOT NULL DEFAULT 1,
    mrc_writable_indicator SMALLINT DEFAULT 9 CHECK (mrc_writable_indicator IN (1, 9)),
    tech_requirement_indicator VARCHAR(1) DEFAULT 'M' CHECK (tech_requirement_indicator IN ('M', 'O', 'X')),
    multiple_value_indicator VARCHAR(1) DEFAULT 'N' CHECK (multiple_value_indicator IN ('Y', 'N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fiig_code, inc_code, mrc_code)
);

-- 回應系統 (2張表格)
-- ================================================================

-- 回應表主檔
CREATE TABLE public.reply_table (
    reply_table_number VARCHAR(10) NOT NULL,
    reply_code VARCHAR(10) NOT NULL,
    reply_description TEXT NOT NULL,
    sort_order INTEGER DEFAULT 1,
    status_code VARCHAR(1) DEFAULT 'A' CHECK (status_code IN ('A', 'I')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (reply_table_number, reply_code)
);

-- MRC與回應表對應
CREATE TABLE public.mrc_reply_table_xref (
    mrc_code VARCHAR(10) NOT NULL REFERENCES public.mrc(mrc_code),
    reply_table_number VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (mrc_code, reply_table_number)
);

-- 模式碼編輯指南 (1張表格)
-- ================================================================

-- 模式碼編輯指南
CREATE TABLE public.mode_code_edit (
    mode_code VARCHAR(10) PRIMARY KEY,
    mode_description TEXT NOT NULL,
    edit_instructions TEXT,
    examples TEXT,
    status_code VARCHAR(1) DEFAULT 'A' CHECK (status_code IN ('A', 'I')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- 第三階段: 索引建立
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '第三階段: 建立索引';
    RAISE NOTICE '==============================================';
END $$;

-- FSG/FSC 索引
CREATE INDEX idx_fsc_fsg_code ON public.fsc(fsg_code);
CREATE INDEX idx_inc_fsc_xref_inc ON public.inc_fsc_xref(inc_code);
CREATE INDEX idx_inc_fsc_xref_fsc ON public.inc_fsc_xref(fsc_code);

-- NATO H6 索引
CREATE INDEX idx_nato_h6_item_name_search ON public.nato_h6_item_name(nato_item_name);
CREATE INDEX idx_nato_h6_item_name_status ON public.nato_h6_item_name(status_code);
CREATE INDEX idx_nato_h6_inc_xref_h6 ON public.nato_h6_inc_xref(h6_record_id);
CREATE INDEX idx_nato_h6_inc_xref_inc ON public.nato_h6_inc_xref(inc_code);

-- INC 索引
CREATE INDEX idx_inc_search ON public.inc(short_name, name_prefix, name_root_remainder);
CREATE INDEX idx_inc_search_text ON public.inc(search_text);
CREATE INDEX idx_inc_status ON public.inc(status_code);
CREATE INDEX idx_colloquial_inc_primary ON public.colloquial_inc_xref(primary_inc_code);

-- FIIG 索引
CREATE INDEX idx_fiig_status ON public.fiig(status_code);
CREATE INDEX idx_fiig_inc_xref_fiig ON public.fiig_inc_xref(fiig_code);
CREATE INDEX idx_fiig_inc_xref_inc ON public.fiig_inc_xref(inc_code);

-- MRC 索引
CREATE INDEX idx_mrc_key_group ON public.mrc(key_group_number);
CREATE INDEX idx_fiig_inc_mrc_xref_fiig_inc ON public.fiig_inc_mrc_xref(fiig_code, inc_code);
CREATE INDEX idx_fiig_inc_mrc_xref_sort ON public.fiig_inc_mrc_xref(sort_num);

-- 回應系統索引
CREATE INDEX idx_reply_table_sort ON public.reply_table(sort_order);
CREATE INDEX idx_mrc_reply_table_xref_mrc ON public.mrc_reply_table_xref(mrc_code);

-- ================================================================
-- 第四階段: 觸發器建立
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '第四階段: 建立觸發器';
    RAISE NOTICE '==============================================';
END $$;

-- 創建更新時間戳函數
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 為有 updated_at 欄位的表格添加觸發器
CREATE TRIGGER update_fsg_updated_at BEFORE UPDATE ON public.fsg
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_fsc_updated_at BEFORE UPDATE ON public.fsc
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_nato_h6_item_name_updated_at BEFORE UPDATE ON public.nato_h6_item_name
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_inc_updated_at BEFORE UPDATE ON public.inc
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_fiig_updated_at BEFORE UPDATE ON public.fiig
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_mrc_key_group_updated_at BEFORE UPDATE ON public.mrc_key_group
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_mrc_updated_at BEFORE UPDATE ON public.mrc
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_mode_code_edit_updated_at BEFORE UPDATE ON public.mode_code_edit
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ================================================================
-- 第五階段: 視圖建立
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '第五階段: 建立視圖';
    RAISE NOTICE '==============================================';
END $$;

-- H6→INC 完整對應視圖
CREATE VIEW public.v_h6_inc_mapping AS
SELECT 
    h.h6_record_id,
    h.nato_item_name,
    h.english_description,
    h.country_code,
    i.inc_code,
    COALESCE(i.short_name, '') || ' ' || 
    COALESCE(i.name_prefix, '') || ' ' || 
    COALESCE(i.name_root_remainder, '') as inc_full_name,
    i.item_name_definition,
    x.relationship_type,
    x.confidence_level
FROM public.nato_h6_item_name h
JOIN public.nato_h6_inc_xref x ON h.h6_record_id = x.h6_record_id
JOIN public.inc i ON x.inc_code = i.inc_code
WHERE h.status_code = 'A' AND i.status_code = 'A';

-- INC→FIIG 完整對應視圖
CREATE VIEW public.v_inc_fiig_mapping AS
SELECT 
    i.inc_code,
    COALESCE(i.short_name, '') || ' ' || 
    COALESCE(i.name_prefix, '') || ' ' || 
    COALESCE(i.name_root_remainder, '') as inc_full_name,
    f.fiig_code,
    f.fiig_description,
    x.relationship_type,
    x.sort_order
FROM public.inc i
JOIN public.fiig_inc_xref x ON i.inc_code = x.inc_code
JOIN public.fiig f ON x.fiig_code = f.fiig_code
WHERE i.status_code = 'A' AND f.status_code = 'A'
ORDER BY x.sort_order;

-- FIIG→MRC 申編需求視圖
CREATE VIEW public.v_fiig_mrc_requirements AS
SELECT 
    fim.fiig_code,
    fim.inc_code,
    fim.mrc_code,
    m.requirement_statement,
    fim.sort_num,
    fim.tech_requirement_indicator,
    fim.multiple_value_indicator,
    m.data_type,
    m.max_length,
    m.validation_pattern,
    m.help_text,
    kg.group_description as mrc_group_description
FROM public.fiig_inc_mrc_xref fim
JOIN public.mrc m ON fim.mrc_code = m.mrc_code
LEFT JOIN public.mrc_key_group kg ON m.key_group_number = kg.key_group_number
ORDER BY fim.sort_num;

-- MRC 回應選項視圖
CREATE VIEW public.v_mrc_reply_options AS
SELECT 
    m.mrc_code,
    m.requirement_statement,
    r.reply_table_number,
    r.reply_code,
    r.reply_description,
    r.sort_order
FROM public.mrc m
JOIN public.mrc_reply_table_xref x ON m.mrc_code = x.mrc_code
JOIN public.reply_table r ON x.reply_table_number = r.reply_table_number
WHERE r.status_code = 'A'
ORDER BY m.mrc_code, r.sort_order;

-- 完整申編流程視圖
CREATE VIEW public.v_application_flow AS
SELECT 
    h.h6_record_id,
    h.nato_item_name,
    i.inc_code,
    COALESCE(i.short_name, '') || ' ' || 
    COALESCE(i.name_prefix, '') || ' ' || 
    COALESCE(i.name_root_remainder, '') as inc_full_name,
    f.fiig_code,
    f.fiig_description,
    COUNT(fim.mrc_code) as required_mrc_count
FROM public.nato_h6_item_name h
JOIN public.nato_h6_inc_xref hix ON h.h6_record_id = hix.h6_record_id
JOIN public.inc i ON hix.inc_code = i.inc_code
JOIN public.fiig_inc_xref fix ON i.inc_code = fix.inc_code
JOIN public.fiig f ON fix.fiig_code = f.fiig_code
LEFT JOIN public.fiig_inc_mrc_xref fim ON f.fiig_code = fim.fiig_code AND i.inc_code = fim.inc_code
WHERE h.status_code = 'A' AND i.status_code = 'A' AND f.status_code = 'A'
GROUP BY h.h6_record_id, h.nato_item_name, i.inc_code, inc_full_name, f.fiig_code, f.fiig_description
ORDER BY h.nato_item_name, i.inc_code, f.fiig_code;

-- ================================================================
-- 第六階段: 註解和說明
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '第六階段: 新增表格註解';
    RAISE NOTICE '==============================================';
END $$;

-- 表格註解
COMMENT ON TABLE public.fsg IS 'FSG聯邦補給群組 - H2階層分類';
COMMENT ON TABLE public.fsc IS 'FSC聯邦補給分類 - H2階層分類';
COMMENT ON TABLE public.nato_h6_item_name IS 'NATO H6物品名稱主檔 - H6階層';
COMMENT ON TABLE public.nato_h6_inc_xref IS 'NATO H6與INC對應表 - H6→INC橋接';
COMMENT ON TABLE public.inc IS 'INC物品名稱代碼 - 申編核心';
COMMENT ON TABLE public.colloquial_inc_xref IS '俗語INC對應表 - INC變體管理';
COMMENT ON TABLE public.fiig IS 'FIIG聯邦物品識別指南 - 申編規格';
COMMENT ON TABLE public.fiig_inc_xref IS 'FIIG與INC對應表 - INC→FIIG橋接';
COMMENT ON TABLE public.mrc_key_group IS 'MRC群組分類';
COMMENT ON TABLE public.mrc IS 'MRC物料需求代碼 - 申編屬性';
COMMENT ON TABLE public.fiig_inc_mrc_xref IS 'FIIG-INC-MRC三元對應表 - 申編核心邏輯';
COMMENT ON TABLE public.reply_table IS '回應表主檔 - MRC選項值';
COMMENT ON TABLE public.mrc_reply_table_xref IS 'MRC與回應表對應';
COMMENT ON TABLE public.mode_code_edit IS '模式碼編輯指南';

-- 視圖註解
COMMENT ON VIEW public.v_h6_inc_mapping IS 'H6→INC完整對應視圖';
COMMENT ON VIEW public.v_inc_fiig_mapping IS 'INC→FIIG完整對應視圖';
COMMENT ON VIEW public.v_fiig_mrc_requirements IS 'FIIG→MRC申編需求視圖';
COMMENT ON VIEW public.v_mrc_reply_options IS 'MRC回應選項視圖';
COMMENT ON VIEW public.v_application_flow IS '完整申編流程視圖';

-- 更新統計資訊
ANALYZE;

-- ================================================================
-- 完成訊息
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Schema 整合完成！';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '✅ 第一階段: Schema 重構完成';
    RAISE NOTICE '   - 舊 public schema → web_app';
    RAISE NOTICE '   - 新建空白 public schema';
    RAISE NOTICE '';
    RAISE NOTICE '✅ 第二階段: NSN 系統表格建立完成';
    RAISE NOTICE '   - 15 張核心表格';
    RAISE NOTICE '   - FSG/FSC, H6, INC, FIIG, MRC 系統';
    RAISE NOTICE '';
    RAISE NOTICE '✅ 第三階段: 索引建立完成';
    RAISE NOTICE '   - 查詢效能優化';
    RAISE NOTICE '';
    RAISE NOTICE '✅ 第四階段: 觸發器建立完成';
    RAISE NOTICE '   - 自動時間戳更新';
    RAISE NOTICE '';
    RAISE NOTICE '✅ 第五階段: 視圖建立完成';
    RAISE NOTICE '   - 5 個查詢視圖';
    RAISE NOTICE '';
    RAISE NOTICE '📊 資料庫結構:';
    RAISE NOTICE '   - web_app schema: 裝備管理系統 + Web 應用';
    RAISE NOTICE '   - public schema: NSN 申編系統';
    RAISE NOTICE '';
    RAISE NOTICE '📝 下一步: 匯入 NSN 資料';
    RAISE NOTICE '==============================================';
END $$;
