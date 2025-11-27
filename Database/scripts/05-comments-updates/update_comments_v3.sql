-- ============================================
-- 更新所有表格和欄位的中文註解
-- 參考: before_database.md (V2.1)
-- 執行日期: 2025-11-20
-- 版本: V3.1
-- ============================================

\c sbir_equipment_db_v2;

-- ============================================
-- 1. Supplier (廠商主檔)
-- ============================================
COMMENT ON TABLE Supplier IS '廠商主檔';
COMMENT ON COLUMN Supplier.supplier_id IS '廠商ID（自動編號）';
COMMENT ON COLUMN Supplier.supplier_code IS '廠商來源代號';
COMMENT ON COLUMN Supplier.cage_code IS '廠家登記代號（CAGE CODE）';
COMMENT ON COLUMN Supplier.supplier_name_en IS '廠家製造商（英文）';
COMMENT ON COLUMN Supplier.supplier_name_zh IS '廠商中文名稱';
COMMENT ON COLUMN Supplier.supplier_type IS '廠商類型（製造商/代理商）';
COMMENT ON COLUMN Supplier.country_code IS '國家代碼';
COMMENT ON COLUMN Supplier.created_at IS '建立時間';
COMMENT ON COLUMN Supplier.updated_at IS '更新時間';

-- ============================================
-- 2. Item (品項主檔)
-- ============================================
COMMENT ON TABLE Item IS '品項主檔';
COMMENT ON COLUMN Item.item_uuid IS '品項UUID（主鍵）';
COMMENT ON COLUMN Item.item_code IS '統一識別碼（CID 或 NIIN）';
COMMENT ON COLUMN Item.item_name_zh IS '中文品名';
COMMENT ON COLUMN Item.item_name_en IS '英文品名';
COMMENT ON COLUMN Item.item_type IS '品項類型：FG(成品)/SEMI(半成品)/RM(原物料)';
COMMENT ON COLUMN Item.uom IS '基本計量單位（EA/SET/LOT等）';
COMMENT ON COLUMN Item.status IS '狀態：Active/Inactive';
COMMENT ON COLUMN Item.created_at IS '建立時間';
COMMENT ON COLUMN Item.updated_at IS '更新時間';

-- ============================================
-- 3. Item_Equipment_Ext (裝備擴展表)
-- ============================================
COMMENT ON TABLE Item_Equipment_Ext IS '裝備擴展表';
COMMENT ON COLUMN Item_Equipment_Ext.item_uuid IS '品項UUID';
COMMENT ON COLUMN Item_Equipment_Ext.equipment_type IS '裝備形式（裝備型號/型式）';
COMMENT ON COLUMN Item_Equipment_Ext.ship_type IS '艦型';
COMMENT ON COLUMN Item_Equipment_Ext.position IS '裝備安裝位置';
COMMENT ON COLUMN Item_Equipment_Ext.parent_equipment_zh IS '上層適用裝備中文名稱';
COMMENT ON COLUMN Item_Equipment_Ext.parent_equipment_en IS '上層適用裝備英文名稱';
COMMENT ON COLUMN Item_Equipment_Ext.parent_cid IS '上層適用裝備單機識別碼CID';
COMMENT ON COLUMN Item_Equipment_Ext.eswbs_code IS '族群結構碼HSC（ESWBS五碼）';
COMMENT ON COLUMN Item_Equipment_Ext.system_function_name IS '系統功能名稱';
COMMENT ON COLUMN Item_Equipment_Ext.installation_qty IS '同一類型數量（單艦裝置數量）';
COMMENT ON COLUMN Item_Equipment_Ext.total_installation_qty IS '全艦裝置數';
COMMENT ON COLUMN Item_Equipment_Ext.maintenance_level IS '裝備維修等級代碼';
COMMENT ON COLUMN Item_Equipment_Ext.equipment_serial IS '裝備序號（裝備識別編號）';
COMMENT ON COLUMN Item_Equipment_Ext.created_at IS '建立時間';
COMMENT ON COLUMN Item_Equipment_Ext.updated_at IS '更新時間';

-- ============================================
-- 4. Item_Material_Ext (料件擴展表)
-- ============================================
COMMENT ON TABLE Item_Material_Ext IS '料件擴展表';
COMMENT ON COLUMN Item_Material_Ext.item_uuid IS '品項UUID';
COMMENT ON COLUMN Item_Material_Ext.item_id_last5 IS '品項識別碼（後五碼）';
COMMENT ON COLUMN Item_Material_Ext.item_name_zh_short IS '中文品名（9字內）';
COMMENT ON COLUMN Item_Material_Ext.nsn IS 'NSN';
COMMENT ON COLUMN Item_Material_Ext.item_category IS '統一組類別';
COMMENT ON COLUMN Item_Material_Ext.item_code IS '品名代號（INC品名代號）';
COMMENT ON COLUMN Item_Material_Ext.fiig IS 'FIIG（聯邦品項識別指南）';
COMMENT ON COLUMN Item_Material_Ext.weapon_system_code IS '武器系統代號';
COMMENT ON COLUMN Item_Material_Ext.accounting_code IS '會計編號';
COMMENT ON COLUMN Item_Material_Ext.issue_unit IS '撥發單位';
COMMENT ON COLUMN Item_Material_Ext.unit_price_usd IS '美金單價';
COMMENT ON COLUMN Item_Material_Ext.package_qty IS '單位包裝量';
COMMENT ON COLUMN Item_Material_Ext.weight_kg IS '重量(KG)';
COMMENT ON COLUMN Item_Material_Ext.has_stock IS '有無料號';
COMMENT ON COLUMN Item_Material_Ext.storage_life_code IS '存儲壽限代號';
COMMENT ON COLUMN Item_Material_Ext.file_type_code IS '檔別代號';
COMMENT ON COLUMN Item_Material_Ext.file_type_category IS '檔別區分';
COMMENT ON COLUMN Item_Material_Ext.security_code IS '機密性代號（U/C/S等）';
COMMENT ON COLUMN Item_Material_Ext.consumable_code IS '消耗性代號（M/N等）';
COMMENT ON COLUMN Item_Material_Ext.spec_indicator IS '規格指示';
COMMENT ON COLUMN Item_Material_Ext.navy_source IS '海軍軍品來源';
COMMENT ON COLUMN Item_Material_Ext.storage_type IS '儲存型式';
COMMENT ON COLUMN Item_Material_Ext.life_process_code IS '處理代號（壽限處理）';
COMMENT ON COLUMN Item_Material_Ext.manufacturing_capacity IS '製造能量';
COMMENT ON COLUMN Item_Material_Ext.repair_capacity IS '修理能量';
COMMENT ON COLUMN Item_Material_Ext.source_code IS '來源代號';
COMMENT ON COLUMN Item_Material_Ext.project_code IS '專案代號';
COMMENT ON COLUMN Item_Material_Ext.created_at IS '建立時間';
COMMENT ON COLUMN Item_Material_Ext.updated_at IS '更新時間';

-- ============================================
-- 5. BOM (BOM主表)
-- ============================================
COMMENT ON TABLE BOM IS 'BOM主表（版本控制）';
COMMENT ON COLUMN BOM.bom_uuid IS 'BOM UUID';
COMMENT ON COLUMN BOM.item_uuid IS '成品料號UUID';
COMMENT ON COLUMN BOM.bom_code IS 'BOM編號';
COMMENT ON COLUMN BOM.revision IS '版次（版本號）';
COMMENT ON COLUMN BOM.effective_from IS '生效日（開始生效日期）';
COMMENT ON COLUMN BOM.effective_to IS '失效日（結束生效日期）';
COMMENT ON COLUMN BOM.status IS '狀態：Released/Draft';
COMMENT ON COLUMN BOM.remark IS '備註';
COMMENT ON COLUMN BOM.created_at IS '建立時間';
COMMENT ON COLUMN BOM.updated_at IS '更新時間';

-- ============================================
-- 6. BOM_LINE (BOM明細行)
-- ============================================
COMMENT ON TABLE BOM_LINE IS 'BOM明細行（BOM元件清單，Item自我關聯）';
COMMENT ON COLUMN BOM_LINE.line_uuid IS '行UUID';
COMMENT ON COLUMN BOM_LINE.bom_uuid IS 'BOM UUID';
COMMENT ON COLUMN BOM_LINE.line_no IS '行號（排序用）';
COMMENT ON COLUMN BOM_LINE.component_item_uuid IS '元件料號UUID（外鍵連結至Item）';
COMMENT ON COLUMN BOM_LINE.qty_per IS '單位用量（每單位成品需要數量）';
COMMENT ON COLUMN BOM_LINE.scrap_type IS '損耗型態';
COMMENT ON COLUMN BOM_LINE.scrap_rate IS '損耗率';
COMMENT ON COLUMN BOM_LINE.uom IS '用量單位（預設跟元件UOM一致）';
COMMENT ON COLUMN BOM_LINE.position IS '裝配位置';
COMMENT ON COLUMN BOM_LINE.remark IS '備註';
COMMENT ON COLUMN BOM_LINE.created_at IS '建立時間';
COMMENT ON COLUMN BOM_LINE.updated_at IS '更新時間';

-- ============================================
-- 7. MRC (品項規格表)
-- ============================================
COMMENT ON TABLE MRC IS '品項規格表（記錄品項的規格資料）';
COMMENT ON COLUMN MRC.mrc_id IS 'MRC ID（自動編號）';
COMMENT ON COLUMN MRC.item_uuid IS '品項UUID';
COMMENT ON COLUMN MRC.spec_no IS '規格順序';
COMMENT ON COLUMN MRC.spec_abbr IS '規格資料縮寫';
COMMENT ON COLUMN MRC.spec_en IS '規格資料英文';
COMMENT ON COLUMN MRC.spec_zh IS '規格資料翻譯）';
COMMENT ON COLUMN MRC.answer_en IS '英答';
COMMENT ON COLUMN MRC.answer_zh IS '中答';
COMMENT ON COLUMN MRC.created_at IS '建立時間';
COMMENT ON COLUMN MRC.updated_at IS '更新時間';

-- ============================================
-- 8. Part_Number_xref (零件號碼關聯檔)
-- ============================================
COMMENT ON TABLE Part_Number_xref IS '零件號碼關聯檔（品項-零件號-廠商多對多關聯）';
COMMENT ON COLUMN Part_Number_xref.part_number_id IS '零件號碼ID';
COMMENT ON COLUMN Part_Number_xref.part_number IS '配件號碼（P/N）';
COMMENT ON COLUMN Part_Number_xref.item_uuid IS '品項UUID';
COMMENT ON COLUMN Part_Number_xref.supplier_id IS '廠商ID';
COMMENT ON COLUMN Part_Number_xref.obtain_level IS '參考號獲得程度';
COMMENT ON COLUMN Part_Number_xref.obtain_source IS '參考號獲得來源';
COMMENT ON COLUMN Part_Number_xref.is_primary IS '是否為主要零件號（主/替代零件號）';
COMMENT ON COLUMN Part_Number_xref.created_at IS '建立時間';
COMMENT ON COLUMN Part_Number_xref.updated_at IS '更新時間';

-- ============================================
-- 9. TechnicalDocument (技術文件檔)
-- ============================================
COMMENT ON TABLE TechnicalDocument IS '技術文件檔（管理技術文件與圖面資料）';
COMMENT ON COLUMN TechnicalDocument.document_id IS '文件ID（自動編號）';
COMMENT ON COLUMN TechnicalDocument.document_name IS '圖名/書名';
COMMENT ON COLUMN TechnicalDocument.document_version IS '版本號';
COMMENT ON COLUMN TechnicalDocument.shipyard_drawing_no IS '船廠圖號';
COMMENT ON COLUMN TechnicalDocument.design_drawing_no IS '設計圖號';
COMMENT ON COLUMN TechnicalDocument.document_type IS '資料類型）';
COMMENT ON COLUMN TechnicalDocument.document_category IS '資料類別';
COMMENT ON COLUMN TechnicalDocument.language IS '語言（中文/英文）';
COMMENT ON COLUMN TechnicalDocument.security_level IS '機密等級（機密分級）';
COMMENT ON COLUMN TechnicalDocument.eswbs_code IS 'ESWBS（五碼）';
COMMENT ON COLUMN TechnicalDocument.accounting_code IS '會計編號';
COMMENT ON COLUMN TechnicalDocument.created_at IS '建立時間';
COMMENT ON COLUMN TechnicalDocument.updated_at IS '更新時間';

-- ============================================
-- 10. Item_Document_xref (品項文件關聯檔)
-- ============================================
COMMENT ON TABLE Item_Document_xref IS '品項文件關聯檔（品項-技術文件多對多關聯）';
COMMENT ON COLUMN Item_Document_xref.item_uuid IS '品項UUID';
COMMENT ON COLUMN Item_Document_xref.document_id IS '文件ID';
COMMENT ON COLUMN Item_Document_xref.created_at IS '建立時間';
COMMENT ON COLUMN Item_Document_xref.updated_at IS '更新時間';

-- ============================================
-- 11. ApplicationForm (申編單檔)
-- ============================================
COMMENT ON TABLE ApplicationForm IS '申編單檔（管理申編單主檔資料）';
COMMENT ON COLUMN ApplicationForm.form_id IS '表單ID（自動編號）';
COMMENT ON COLUMN ApplicationForm.form_no IS '表單編號（申編單號）';
COMMENT ON COLUMN ApplicationForm.submit_status IS '申編單提送狀態（待送/已送/核准等）';
COMMENT ON COLUMN ApplicationForm.yetl IS 'YETL';
COMMENT ON COLUMN ApplicationForm.applicant_accounting_code IS '申請單位會計編號';
COMMENT ON COLUMN ApplicationForm.item_id IS '品項識別碼';
COMMENT ON COLUMN ApplicationForm.created_date IS '建立日期';
COMMENT ON COLUMN ApplicationForm.updated_date IS '更新日期';

-- ============================================
-- 12. ApplicationFormDetail (申編單明細檔)
-- ============================================
COMMENT ON TABLE ApplicationFormDetail IS '申編單明細檔（申編單明細資料）';
COMMENT ON COLUMN ApplicationFormDetail.detail_id IS '明細ID（自動編號）';
COMMENT ON COLUMN ApplicationFormDetail.form_id IS '表單ID';
COMMENT ON COLUMN ApplicationFormDetail.item_seq IS '項次（明細序號）';
COMMENT ON COLUMN ApplicationFormDetail.document_source IS '文件來源（資料來源文件）';
COMMENT ON COLUMN ApplicationFormDetail.image_path IS '圖片路徑（附件路徑）';
COMMENT ON COLUMN ApplicationFormDetail.created_at IS '建立時間';
COMMENT ON COLUMN ApplicationFormDetail.updated_at IS '更新時間';

-- ============================================
-- 13. application_suppliercode (廠商代號申請表)
-- ============================================
COMMENT ON TABLE application_suppliercode IS '廠商代號申請表（廠商代號申請表單）';
COMMENT ON COLUMN application_suppliercode.application_uuid IS '申請單UUID';
COMMENT ON COLUMN application_suppliercode.form_no IS '流水號（申請單流水號）';
COMMENT ON COLUMN application_suppliercode.applicant IS '申請人（申請人姓名）';
COMMENT ON COLUMN application_suppliercode.supplier_id IS '廠商ID';
COMMENT ON COLUMN application_suppliercode.supplier_name IS '廠商名稱';
COMMENT ON COLUMN application_suppliercode.address IS '地址（廠商地址）';
COMMENT ON COLUMN application_suppliercode.phone IS '電話（聯絡電話）';
COMMENT ON COLUMN application_suppliercode.business_items IS '營業項目（營業項目說明）';
COMMENT ON COLUMN application_suppliercode.supplier_code IS '廠家代號（申請或現有代號）';
COMMENT ON COLUMN application_suppliercode.equipment_name IS '裝備名稱（相關裝備名稱）';
COMMENT ON COLUMN application_suppliercode.extra_fields IS '自定義欄位（動態擴充欄位）';
COMMENT ON COLUMN application_suppliercode.status IS '狀態（Draft/Submitted等）';
COMMENT ON COLUMN application_suppliercode.created_at IS '建立時間';
COMMENT ON COLUMN application_suppliercode.updated_at IS '更新時間';

-- ============================================
-- 14. application_cid (CID申請單)
-- ============================================
COMMENT ON TABLE application_cid IS 'CID申請單（CID申請表單）';
COMMENT ON COLUMN application_cid.application_uuid IS '申請單UUID';
COMMENT ON COLUMN application_cid.form_no IS '流水號（申請單流水號）';
COMMENT ON COLUMN application_cid.applicant IS '申請人（申請人姓名）';
COMMENT ON COLUMN application_cid.item_uuid IS '品項UUID';
COMMENT ON COLUMN application_cid.suggested_prefix IS '建議前兩碼（建議CID前綴）';
COMMENT ON COLUMN application_cid.approved_cid IS '核定CID（核定後的CID）';
COMMENT ON COLUMN application_cid.equipment_name_zh IS '裝備中文名稱';
COMMENT ON COLUMN application_cid.equipment_name_en IS '裝備英文名稱';
COMMENT ON COLUMN application_cid.supplier_code IS '廠家代號（相關廠商代號）';
COMMENT ON COLUMN application_cid.part_number IS '配件號碼（P/N）';
COMMENT ON COLUMN application_cid.state IS '狀態（Draft/Submitted等）';
COMMENT ON COLUMN application_cid.created_at IS '建立時間';
COMMENT ON COLUMN application_cid.updated_at IS '更新時間';

-- ============================================
-- 完成訊息
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ 所有表格和欄位的中文註解已更新完成';
    RAISE NOTICE '✅ 共更新 14 個資料表的 COMMENT';
    RAISE NOTICE '✅ 參考來源: before_database.md (V2.1)';
END $$;