## Table: item (Mapped to: 19M)
| Column | SQL Comment | Best Match in Excel | Status |
|---|---|---|---|
| item_id | 品項識別號 | 品項識別號 | ✅ Match |
| item_id_last5 | 品項識別碼(後五碼) |  | ❌ Mismatch |
| nsn | 國家料號 |  | ❌ Mismatch |
| item_category | 統一組類別 | 統一組類別 | ✅ Match |
| item_name_zh | 中文品名 | 中文品名 | ✅ Match |
| item_name_zh_short | 中文品名(9字內) | 中文品名 | ⚠️ Partial/Fuzzy |
| item_name_en | 英文品名 | 英文品名 | ✅ Match |
| item_code | 品名代號 | 品名代號 | ✅ Match |
| fiig | FIIG |  | ❌ Mismatch |
| weapon_system_code | 武器系統代號 | 武器系統代號 | ✅ Match |
| accounting_code | 會計編號 | 申請單位會計編號 | ⚠️ Partial/Fuzzy |
| issue_unit | 撥發單位 | 撥發單位 | ✅ Match |
| unit_price_usd | 美金單價 | 美金單價 | ✅ Match |
| package_qty | 單位包裝量 | 單位包裝量 | ✅ Match |
| weight_kg | 重量(KG) | 重量(KG) | ✅ Match |
| has_stock | 有無料號 |  | ❌ Mismatch |
| storage_life_code | 存儲壽限代號 | 存儲壽限代號 | ✅ Match |
| file_type_code | 檔別代號 | 檔別代號 | ✅ Match |
| file_type_category | 檔別區分 | 檔別區分 | ✅ Match |
| security_code | 機密性代號 | 機密性代號 | ✅ Match |
| consumable_code | 消耗性代號 | 消耗性代號 | ✅ Match |
| spec_indicator | 規格指示 | 規格指示 | ✅ Match |
| navy_source | 海軍軍品來源 |  | ❌ Mismatch |
| storage_type | 儲存型式 | 儲存型式 | ✅ Match |
| life_process_code | 壽限處理代號 |  | ❌ Mismatch |
| manufacturing_capacity | 製造能量 | 製造能量 | ✅ Match |
| repair_capacity | 修理能量 | 修理能量 | ✅ Match |
| source_code | 來源代號 | 來源代號 | ✅ Match |
| project_code | 專案代號 | 專案代號 | ✅ Match |
| created_at | 建立時間 |  | ❌ Mismatch |
| updated_at | 更新時間 |  | ❌ Mismatch |

## Table: equipment (Mapped to: 3M)
| Column | SQL Comment | Best Match in Excel | Status |
|---|---|---|---|
| equipment_id | 單機識別碼 | 單機識別碼 | ✅ Match |
| equipment_name_zh | 裝備中文名稱 | 裝備中文名稱 | ✅ Match |
| equipment_name_en | 裝備英文名稱 | 裝備英文名稱 | ✅ Match |
| equipment_type | 型式 |  | ❌ Mismatch |
| ship_type | 艦型 |  | ❌ Mismatch |
| parent_cid | 上層適用裝備單機識別碼CID | 單機識別碼 | ⚠️ Partial/Fuzzy |
| eswbs_code | 族群結構碼(ESWBS) |  | ❌ Mismatch |
| system_function_name | 系統功能名稱(中+英) (族群結構碼上的名稱) |  | ❌ Mismatch |
| installation_qty | 裝置數 |  | ❌ Mismatch |
| total_installation_qty | 全艦裝置數 |  | ❌ Mismatch |
| maintenance_level | 裝備維修等級代碼 | 裝備維修等級代碼 | ✅ Match |
| equipment_serial | 裝備識別編號 | 裝備識別編號 | ✅ Match |
| created_at | 建立時間 |  | ❌ Mismatch |
| updated_at | 更新時間 |  | ❌ Mismatch |
| specification | 裝備規格說明（原 EquipmentSpecification 表合併） |  | ❌ Mismatch |

## Table: supplier (Mapped to: 廠商主檔)
| Column | SQL Comment | Best Match in Excel | Status |
|---|---|---|---|
| supplier_id | 廠商ID（自動編號） |  | ❌ Mismatch |
| supplier_code | 廠商來源代號 |  | ❌ Mismatch |
| cage_code | 廠家登記代號 |  | ❌ Mismatch |
| supplier_name_en | 廠家製造商（英文） |  | ❌ Mismatch |
| supplier_name_zh | 廠商中文名稱 |  | ❌ Mismatch |
| supplier_type | 廠商類型（製造商/代理商） |  | ❌ Mismatch |
| country_code | 國家代碼 |  | ❌ Mismatch |
| created_at | 建立時間 |  | ❌ Mismatch |
| updated_at | 更新時間 |  | ❌ Mismatch |

## Table: part_number_xref (Mapped to: 20M)
| Column | SQL Comment | Best Match in Excel | Status |
|---|---|---|---|
| part_number_id | 零件號碼ID（自動編號） |  | ❌ Mismatch |
| part_number | 配件號碼 | 配件號碼 | ✅ Match |
| item_id | 品項識別碼 | 品項識別碼 | ✅ Match |
| supplier_id | 廠商ID |  | ❌ Mismatch |
| obtain_level | 參考號獲得程度 |  | ❌ Mismatch |
| obtain_source | 參考號獲得來源 |  | ❌ Mismatch |
| is_primary | 是否為主要零件號 |  | ❌ Mismatch |
| created_at | 建立時間 |  | ❌ Mismatch |
| updated_at | 更新時間 |  | ❌ Mismatch |

## Table: technicaldocument (Mapped to: 書籍檔)
| Column | SQL Comment | Best Match in Excel | Status |
|---|---|---|---|
| document_id | 文件ID（自動編號） |  | ❌ Mismatch |
| document_name | 書名 | 書名 | ✅ Match |
| document_version | 版次 | 版次 | ✅ Match |
| shipyard_drawing_no | 船廠圖號 |  | ❌ Mismatch |
| design_drawing_no | 設計圖號 |  | ❌ Mismatch |
| document_type | 資料類型 | 資料類型 | ✅ Match |
| document_category | 資料類別 | 資料類別 | ✅ Match |
| language | 語言 | 語言 | ✅ Match |
| security_level | 機密等級 | 機密等級 | ✅ Match |
| eswbs_code | 族群結構碼(ESWBS) | 族群結構碼(ESWBS) | ✅ Match |
| accounting_code | 會計編號 | 會計編號 | ✅ Match |
| created_at | 建立時間 |  | ❌ Mismatch |
| updated_at | 更新時間 |  | ❌ Mismatch |

## Table: applicationform (Mapped to: 無料號)
| Column | SQL Comment | Best Match in Excel | Status |
|---|---|---|---|
| form_id | 表單ID（自動編號） |  | ❌ Mismatch |
| form_no | 表單 編號 | 表單 編號 | ✅ Match |
| item_seq | 項次 | 項次 | ✅ Match |
| submit_status | 申編單 提送狀態 | 申編單 提送狀態 | ✅ Match |
| applicant_accounting_code | 申請單位會計編號 | 會計編號 | ⚠️ Partial/Fuzzy |
| item_id | 品項識別碼 | 品項識別碼 | ✅ Match |
| document_source | 文件來源 | 文件來源 | ✅ Match |
| created_date | 建立日期 |  | ❌ Mismatch |
| updated_date | 更新日期 |  | ❌ Mismatch |
| created_at | 建立時間 |  | ❌ Mismatch |
| updated_at | 更新時間 |  | ❌ Mismatch |
