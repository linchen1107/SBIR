-- ============================================
-- NSN 整合驗證腳本
-- 用途：檢查 NSN 系統整合是否成功
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. 檢查表格是否建立成功
-- ============================================

DO $$
DECLARE
    required_tables TEXT[] := ARRAY[
        'nsn_inc',
        'nsn_colloquial_inc_xref',
        'nsn_fsg',
        'nsn_fsc',
        'nsn_inc_fsc_xref',
        'nsn_fiig',
        'nsn_fiig_inc_xref',
        'nsn_mrc',
        'item_mrc_answer'
    ];
    missing_tables TEXT[] := '{}';
    tbl TEXT;
    exists BOOLEAN;
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE '1. 檢查表格建立狀態';
    RAISE NOTICE '=========================================';

    FOREACH tbl IN ARRAY required_tables
    LOOP
        SELECT EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_name = tbl
        ) INTO exists;

        IF exists THEN
            RAISE NOTICE '  ✓ % 已建立', tbl;
        ELSE
            RAISE NOTICE '  ✗ % 未建立', tbl;
            missing_tables := array_append(missing_tables, tbl);
        END IF;
    END LOOP;

    IF array_length(missing_tables, 1) > 0 THEN
        RAISE WARNING '缺少表格: %', array_to_string(missing_tables, ', ');
    ELSE
        RAISE NOTICE '';
        RAISE NOTICE '所有必要表格已建立！';
    END IF;
END $$;

-- ============================================
-- 2. 檢查表格資料筆數
-- ============================================

DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=========================================';
    RAISE NOTICE '2. 表格資料統計';
    RAISE NOTICE '=========================================';

    FOR rec IN
        SELECT
            table_name,
            (xpath('/row/cnt/text()',
                   query_to_xml(format('SELECT COUNT(*) AS cnt FROM %I', table_name),
                   false, true, '')))[1]::text::int AS row_count
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name LIKE 'nsn_%'
        ORDER BY table_name
    LOOP
        RAISE NOTICE '  % : % 筆', rpad(rec.table_name, 30), rec.row_count;
    END LOOP;

    -- Item_MRC_Answer
    SELECT COUNT(*) INTO rec FROM Item_MRC_Answer;
    RAISE NOTICE '  % : % 筆', rpad('item_mrc_answer', 30), rec;
END $$;

-- ============================================
-- 3. 檢查外鍵關聯
-- ============================================

SELECT
    tc.table_name AS "表格",
    kcu.column_name AS "欄位",
    ccu.table_name AS "參照表格",
    ccu.column_name AS "參照欄位"
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND (tc.table_name LIKE 'nsn_%' OR tc.table_name = 'item_material_ext')
ORDER BY tc.table_name, kcu.column_name;

-- ============================================
-- 4. 測試查詢：INC → FSC → FSG 關聯
-- ============================================

\echo ''
\echo '========================================='
\echo '4. 測試查詢：INC → FSC → FSG'
\echo '========================================='

SELECT
    inc.inc_code,
    inc.short_name AS inc_name,
    fsc.fsc_code,
    fsc.fsc_title,
    fsg.fsg_code,
    fsg.fsg_title
FROM NSN_INC inc
JOIN NSN_INC_FSC_xref xref ON inc.inc_code = xref.inc_code
JOIN NSN_FSC fsc ON xref.fsc_code = fsc.fsc_code
JOIN NSN_FSG fsg ON fsc.fsg_code = fsg.fsg_code
ORDER BY inc.inc_code;

-- ============================================
-- 5. 測試查詢：INC → FIIG 關聯
-- ============================================

\echo ''
\echo '========================================='
\echo '5. 測試查詢：INC → FIIG'
\echo '========================================='

SELECT
    inc.inc_code,
    inc.short_name AS inc_name,
    fiig.fiig_code,
    LEFT(fiig.fiig_description, 50) AS fiig_description,
    xref.sort_order
FROM NSN_INC inc
JOIN NSN_FIIG_INC_xref xref ON inc.inc_code = xref.inc_code
JOIN NSN_FIIG fiig ON xref.fiig_code = fiig.fiig_code
ORDER BY inc.inc_code, xref.sort_order;

-- ============================================
-- 6. 測試查詢：Item → INC 關聯
-- ============================================

\echo ''
\echo '========================================='
\echo '6. 測試查詢：Item → INC'
\echo '========================================='

SELECT
    i.item_code,
    i.item_name_zh,
    im.inc_code,
    inc.short_name AS inc_name,
    inc.item_name_definition
FROM Item i
JOIN Item_Material_Ext im ON i.item_uuid = im.item_uuid
LEFT JOIN NSN_INC inc ON im.inc_code = inc.inc_code
WHERE im.inc_code IS NOT NULL
ORDER BY i.item_code;

-- ============================================
-- 7. 檢查 Item_Material_Ext 欄位更新
-- ============================================

DO $$
DECLARE
    inc_code_exists BOOLEAN;
    inc_code_count INT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=========================================';
    RAISE NOTICE '7. Item_Material_Ext 欄位檢查';
    RAISE NOTICE '=========================================';

    -- 檢查 inc_code 欄位是否存在
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'item_material_ext'
        AND column_name = 'inc_code'
    ) INTO inc_code_exists;

    IF inc_code_exists THEN
        RAISE NOTICE '  ✓ inc_code 欄位已存在';

        -- 計算已填值的筆數
        SELECT COUNT(*) INTO inc_code_count
        FROM Item_Material_Ext
        WHERE inc_code IS NOT NULL;

        RAISE NOTICE '  ✓ 已填值的 inc_code: % 筆', inc_code_count;
    ELSE
        RAISE NOTICE '  ✗ inc_code 欄位不存在';
    END IF;
END $$;

-- ============================================
-- 8. 完整性檢查總結
-- ============================================

DO $$
DECLARE
    total_nsn_tables INT;
    total_nsn_records INT;
BEGIN
    -- 計算 NSN 表格數量
    SELECT COUNT(*) INTO total_nsn_tables
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name LIKE 'nsn_%';

    RAISE NOTICE '';
    RAISE NOTICE '=========================================';
    RAISE NOTICE '整合驗證總結';
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'NSN 表格數量: %', total_nsn_tables;
    RAISE NOTICE '';

    IF total_nsn_tables >= 8 THEN
        RAISE NOTICE '✓ NSN 核心系統整合成功！';
    ELSE
        RAISE WARNING '✗ NSN 系統整合不完整（需要至少8張表）';
    END IF;

    RAISE NOTICE '=========================================';
END $$;
