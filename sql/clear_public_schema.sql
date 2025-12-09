-- ===================================================================================
--  清空 Public Schema 資料表
--  說明:
--      此腳本專門用來清除 'public' schema 中所有核心料件資料表的資料。
--      它使用 TRUNCATE ... CASCADE 指令，可以高效地清空表格，並自動處理
--      所有外部鍵(foreign key)的關聯，同時重設所有自動增長的序列 (IDENTITY)。
--
--      此操作不會影響到 'web_app' schema 中的任何使用者資料。
--      主要用於系統上線後的資料更新流程。
-- ===================================================================================

TRUNCATE TABLE 
    public.fsg,
    public.mrc_key_group,
    public.reply_table,
    public.fsc,
    public.nato_h6_item_name,
    public.inc,
    public.mrc,
    public.mode_code_edit,
    public.inc_fsc_xref,
    public.nato_h6_inc_xref,
    public.colloquial_inc_xref,
    public.fiig,
    public.mrc_reply_table_xref,
    public.fiig_inc_xref,
    public.fiig_inc_mrc_xref
RESTART IDENTITY CASCADE;

-- RESTART IDENTITY: 重設所有與這些表格相關的序列(如: auto-increment ID)。
-- CASCADE:          自動將清空操作延伸到所有參考這些表格的子表格。

-- 執行完畢 