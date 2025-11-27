-- ============================================
-- NSN 系統實用視圖建立腳本
-- 用途：建立常用查詢視圖，簡化複雜關聯查詢
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. 視圖：完整 Item 資訊（含 NSN 分類）
-- ============================================

CREATE OR REPLACE VIEW v_item_nsn_full AS
SELECT
    -- Item 基本資訊
    i.item_uuid,
    i.item_code,
    i.item_name_zh,
    i.item_name_en,
    i.item_type,
    i.uom,
    i.status,

    -- Material Ext 資訊
    im.nsn,
    im.inc_code,
    im.fiig AS fiig_code,
    im.unit_price_usd,
    im.item_category,

    -- INC 資訊
    inc.short_name AS inc_short_name,
    inc.item_name_definition AS inc_definition,
    inc.status_code AS inc_status,

    -- FIIG 資訊
    fiig.fiig_description,
    fiig.fiig_description_zh,
    fiig.status_code AS fiig_status,

    -- 時間戳記
    i.date_created,
    i.date_updated
FROM Item i
LEFT JOIN Item_Material_Ext im ON i.item_uuid = im.item_uuid
LEFT JOIN NSN_INC inc ON im.inc_code = inc.inc_code
LEFT JOIN NSN_FIIG fiig ON im.fiig = fiig.fiig_code
WHERE i.item_type IN ('SEMI', 'RM');

COMMENT ON VIEW v_item_nsn_full IS '完整品項資訊視圖（含NSN分類）';

-- ============================================
-- 2. 視圖：INC 完整分類資訊
-- ============================================

CREATE OR REPLACE VIEW v_inc_classification AS
SELECT
    inc.inc_code,
    inc.short_name AS inc_name,
    inc.item_name_definition AS inc_definition,
    inc.status_code AS inc_status,

    -- FSC 資訊
    fsc.fsc_code,
    fsc.fsc_title,
    fsc.fsc_title_zh,

    -- FSG 資訊
    fsg.fsg_code,
    fsg.fsg_title,
    fsg.fsg_title_zh,

    -- 統計：使用此 INC 的品項數量
    (
        SELECT COUNT(*)
        FROM Item_Material_Ext
        WHERE inc_code = inc.inc_code
    ) AS item_count

FROM NSN_INC inc
LEFT JOIN NSN_INC_FSC_xref xref ON inc.inc_code = xref.inc_code
LEFT JOIN NSN_FSC fsc ON xref.fsc_code = fsc.fsc_code
LEFT JOIN NSN_FSG fsg ON fsc.fsg_code = fsg.fsg_code;

COMMENT ON VIEW v_inc_classification IS 'INC完整分類資訊（含FSC/FSG）';

-- ============================================
-- 3. 視圖：FIIG-INC 對應關係
-- ============================================

CREATE OR REPLACE VIEW v_fiig_inc_mapping AS
SELECT
    fiig.fiig_code,
    fiig.fiig_description,
    fiig.fiig_description_zh,
    fiig.status_code AS fiig_status,

    inc.inc_code,
    inc.short_name AS inc_name,
    inc.item_name_definition AS inc_definition,

    xref.sort_order,

    -- 統計：使用此 FIIG+INC 組合的品項數量
    (
        SELECT COUNT(*)
        FROM Item_Material_Ext im
        WHERE im.fiig = fiig.fiig_code
        AND im.inc_code = inc.inc_code
    ) AS item_count

FROM NSN_FIIG fiig
JOIN NSN_FIIG_INC_xref xref ON fiig.fiig_code = xref.fiig_code
JOIN NSN_INC inc ON xref.inc_code = inc.inc_code;

COMMENT ON VIEW v_fiig_inc_mapping IS 'FIIG-INC對應關係視圖';

-- ============================================
-- 4. 視圖：品項 MRC 問答清單
-- ============================================

CREATE OR REPLACE VIEW v_item_mrc_qa AS
SELECT
    i.item_uuid,
    i.item_code,
    i.item_name_zh,

    -- MRC 問題
    mrc.mrc_code,
    mrc.requirement_statement AS question_en,
    mrc.requirement_statement_zh AS question_zh,
    mrc.data_type,
    mrc.is_required,

    -- MRC 答案
    ans.spec_no AS answer_order,
    ans.answer_en,
    ans.answer_zh,

    -- 時間戳記
    ans.date_created AS answered_at,
    ans.date_updated AS updated_at

FROM Item i
JOIN Item_MRC_Answer ans ON i.item_uuid = ans.item_uuid
LEFT JOIN NSN_MRC mrc ON ans.spec_abbr = mrc.mrc_code
ORDER BY i.item_code, ans.spec_no;

COMMENT ON VIEW v_item_mrc_qa IS '品項MRC問答清單（問題定義+答案）';

-- ============================================
-- 5. 視圖：FSC 分類統計
-- ============================================

CREATE OR REPLACE VIEW v_fsc_statistics AS
SELECT
    fsg.fsg_code,
    fsg.fsg_title,
    fsg.fsg_title_zh,

    fsc.fsc_code,
    fsc.fsc_title,
    fsc.fsc_title_zh,

    -- 統計：此 FSC 下的 INC 數量
    COUNT(DISTINCT xref.inc_code) AS inc_count,

    -- 統計：此 FSC 下的品項數量
    (
        SELECT COUNT(DISTINCT im.item_uuid)
        FROM Item_Material_Ext im
        JOIN NSN_INC inc ON im.inc_code = inc.inc_code
        JOIN NSN_INC_FSC_xref x ON inc.inc_code = x.inc_code
        WHERE x.fsc_code = fsc.fsc_code
    ) AS item_count

FROM NSN_FSG fsg
JOIN NSN_FSC fsc ON fsg.fsg_code = fsc.fsg_code
LEFT JOIN NSN_INC_FSC_xref xref ON fsc.fsc_code = xref.fsc_code
GROUP BY fsg.fsg_code, fsg.fsg_title, fsg.fsg_title_zh,
         fsc.fsc_code, fsc.fsc_title, fsc.fsc_title_zh
ORDER BY fsg.fsg_code, fsc.fsc_code;

COMMENT ON VIEW v_fsc_statistics IS 'FSC分類統計（INC及品項數量）';

-- ============================================
-- 6. 視圖：品項完整 BOM 結構（含 NSN 分類）
-- ============================================

CREATE OR REPLACE VIEW v_bom_nsn_detail AS
SELECT
    -- BOM 主表資訊
    bom.bom_uuid,
    bom.bom_code,
    bom.revision,
    bom.status AS bom_status,

    -- 成品資訊
    parent_item.item_code AS parent_item_code,
    parent_item.item_name_zh AS parent_item_name,

    -- BOM 行資訊
    bl.line_no,
    bl.qty_per,
    bl.uom AS line_uom,
    bl.position,

    -- 元件資訊
    comp_item.item_code AS component_code,
    comp_item.item_name_zh AS component_name,
    comp_item.item_type AS component_type,

    -- 元件 NSN 資訊
    comp_mat.nsn AS component_nsn,
    comp_mat.inc_code AS component_inc,
    comp_mat.fiig AS component_fiig,
    comp_inc.short_name AS component_inc_name

FROM BOM bom
JOIN Item parent_item ON bom.item_uuid = parent_item.item_uuid
JOIN BOM_LINE bl ON bom.bom_uuid = bl.bom_uuid
JOIN Item comp_item ON bl.component_item_uuid = comp_item.item_uuid
LEFT JOIN Item_Material_Ext comp_mat ON comp_item.item_uuid = comp_mat.item_uuid
LEFT JOIN NSN_INC comp_inc ON comp_mat.inc_code = comp_inc.inc_code
ORDER BY bom.bom_code, bl.line_no;

COMMENT ON VIEW v_bom_nsn_detail IS 'BOM結構明細（含元件NSN分類）';

-- ============================================
-- 7. 實用函數：搜尋 INC（模糊比對）
-- ============================================

CREATE OR REPLACE FUNCTION fn_search_inc(keyword TEXT)
RETURNS TABLE (
    inc_code VARCHAR(10),
    inc_name VARCHAR(50),
    inc_definition TEXT,
    fsc_code VARCHAR(4),
    fsc_title VARCHAR(200),
    status_code VARCHAR(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        inc.inc_code,
        inc.short_name,
        inc.item_name_definition,
        fsc.fsc_code,
        fsc.fsc_title,
        inc.status_code
    FROM NSN_INC inc
    LEFT JOIN NSN_INC_FSC_xref xref ON inc.inc_code = xref.inc_code
    LEFT JOIN NSN_FSC fsc ON xref.fsc_code = fsc.fsc_code
    WHERE
        inc.short_name ILIKE '%' || keyword || '%'
        OR inc.item_name_definition ILIKE '%' || keyword || '%'
        OR inc.inc_code = keyword
    ORDER BY inc.inc_code;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_search_inc IS 'INC模糊搜尋函數（關鍵字比對）';

-- ============================================
-- 8. 實用函數：取得品項的所有 MRC 問題
-- ============================================

CREATE OR REPLACE FUNCTION fn_get_item_mrc_questions(p_item_uuid UUID)
RETURNS TABLE (
    mrc_code VARCHAR(10),
    question TEXT,
    question_zh TEXT,
    data_type VARCHAR(20),
    is_required BOOLEAN,
    current_answer TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        mrc.mrc_code,
        mrc.requirement_statement,
        mrc.requirement_statement_zh,
        mrc.data_type,
        mrc.is_required,
        ans.answer_zh
    FROM NSN_MRC mrc
    LEFT JOIN Item_MRC_Answer ans
        ON mrc.mrc_code = ans.spec_abbr
        AND ans.item_uuid = p_item_uuid
    ORDER BY ans.spec_no NULLS LAST, mrc.mrc_code;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_get_item_mrc_questions IS '取得品項的所有MRC問題及答案';

-- ============================================
-- 完成訊息
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'NSN 視圖與函數建立完成！';
    RAISE NOTICE '=========================================';
    RAISE NOTICE '';
    RAISE NOTICE '已建立視圖：';
    RAISE NOTICE '  ✓ v_item_nsn_full - 完整品項資訊（含NSN）';
    RAISE NOTICE '  ✓ v_inc_classification - INC完整分類';
    RAISE NOTICE '  ✓ v_fiig_inc_mapping - FIIG-INC對應';
    RAISE NOTICE '  ✓ v_item_mrc_qa - 品項MRC問答';
    RAISE NOTICE '  ✓ v_fsc_statistics - FSC統計';
    RAISE NOTICE '  ✓ v_bom_nsn_detail - BOM結構（含NSN）';
    RAISE NOTICE '';
    RAISE NOTICE '已建立函數：';
    RAISE NOTICE '  ✓ fn_search_inc(keyword) - INC搜尋';
    RAISE NOTICE '  ✓ fn_get_item_mrc_questions(uuid) - 取得MRC問題';
    RAISE NOTICE '';
    RAISE NOTICE '使用範例：';
    RAISE NOTICE '  SELECT * FROM v_item_nsn_full LIMIT 10;';
    RAISE NOTICE '  SELECT * FROM fn_search_inc(''cable'');';
    RAISE NOTICE '=========================================';
END $$;
