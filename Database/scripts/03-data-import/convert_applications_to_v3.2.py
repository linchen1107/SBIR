"""
轉換 applications SQL 檔案從舊格式到 V3.2 格式

變更內容：
1. 表名: web_app.applications → web_app."Application"
2. 欄位: created_at → date_created
3. 欄位: updated_at → date_updated
4. 新增: item_uuid (在 user_id 後面，值為 NULL)

使用方式：
python convert_applications_to_v3.2.py input.sql output.sql
"""

import re
import sys
import os

def convert_applications_sql(input_file: str, output_file: str):
    """將舊格式的 applications SQL 轉換為 V3.2 格式"""
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. 替換表名
    content = content.replace(
        'INSERT INTO web_app.applications',
        'INSERT INTO web_app."Application"'
    )
    
    # 2. 替換欄位名列表 (在 INSERT 語句的欄位定義中)
    # 舊格式: (id,user_id,form_serial_number,...,created_at,updated_at,deleted_at,...)
    # 新格式: (id,user_id,item_uuid,form_serial_number,...,date_created,date_updated,deleted_at,...)
    
    # 首先替換欄位定義部分
    old_columns = '(id,user_id,form_serial_number,part_number,english_name,chinese_name,inc_code,fiig_code,status,sub_status,created_at,updated_at,deleted_at,accounting_unit_code,issue_unit,unit_price,spec_indicator,unit_pack_quantity,storage_life_months,storage_life_action_code,storage_type_code,secrecy_code,expendability_code,repairability_code,manufacturability_code,source_code,category_code,system_code,pn_acquisition_level,pn_acquisition_source,manufacturer,part_number_reference,ship_type,cid_no,model_type,equipment_name,usage_location,quantity_per_unit,mrc_data,document_reference,manufacturer_name,agent_name,applicant_unit,contact_info,apply_date,official_nsn_stamp,official_nsn_final,nsn_filled_at,nsn_filled_by,closed_at,closed_by)'
    
    new_columns = '(id,user_id,item_uuid,form_serial_number,part_number,english_name,chinese_name,inc_code,fiig_code,status,sub_status,date_created,date_updated,deleted_at,accounting_unit_code,issue_unit,unit_price,spec_indicator,unit_pack_quantity,storage_life_months,storage_life_action_code,storage_type_code,secrecy_code,expendability_code,repairability_code,manufacturability_code,source_code,category_code,system_code,pn_acquisition_level,pn_acquisition_source,manufacturer,part_number_reference,ship_type,cid_no,model_type,equipment_name,usage_location,quantity_per_unit,mrc_data,document_reference,manufacturer_name,agent_name,applicant_unit,contact_info,apply_date,official_nsn_stamp,official_nsn_final,nsn_filled_at,nsn_filled_by,closed_at,closed_by)'
    
    content = content.replace(old_columns, new_columns)
    
    # 3. 在 VALUES 中的每筆資料，需要在 user_id 後面加入 NULL
    # 舊格式: ('uuid'::uuid,'user_uuid'::uuid,'A0001',...)
    # 新格式: ('uuid'::uuid,'user_uuid'::uuid,NULL,'A0001',...)
    
    # 使用正則表達式找到並替換
    # 匹配模式: 'uuid1'::uuid,'uuid2'::uuid,'form_serial_number'
    pattern = r"(\('[0-9a-f-]+'::uuid,'[0-9a-f-]+'::uuid,)('[^']+',)"
    replacement = r"\1NULL,\2"
    
    content = re.sub(pattern, replacement, content)
    
    # 4. 寫入標頭註釋
    header = """-- =====================================================
-- applications 資料遷移腳本 (V3.2 格式)
-- 自動產生時間: 由 convert_applications_to_v3.2.py 轉換
-- 
-- 變更說明:
--   1. 表名: web_app.applications → web_app."Application"
--   2. 欄位: created_at → date_created
--   3. 欄位: updated_at → date_updated
--   4. 新增: item_uuid (NULL)
-- 
-- 執行方式:
--   psql -U postgres -d sbir_equipment_db_v3 -f {output_filename}
-- =====================================================

BEGIN;

""".format(output_filename=os.path.basename(output_file))
    
    footer = """

COMMIT;

-- 驗證結果
SELECT COUNT(*) AS total_count FROM web_app."Application";
SELECT id, form_serial_number, status, date_created 
FROM web_app."Application" 
ORDER BY date_created DESC 
LIMIT 5;
"""
    
    # 組合最終內容
    final_content = header + content + footer
    
    # 寫入輸出檔案
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(final_content)
    
    print(f"✅ 轉換完成!")
    print(f"   輸入: {input_file}")
    print(f"   輸出: {output_file}")
    
    # 統計轉換數量
    insert_count = content.count("::uuid,'")
    print(f"   預估資料筆數: ~{insert_count // 2} 筆")


def main():
    if len(sys.argv) < 3:
        # 預設值
        input_file = r"C:\Users\User\Downloads\applications_202512241401.sql"
        output_file = r"C:\github\SBIR\Database\scripts\03-data-import\applications_v3.2_converted.sql"
        
        print(f"使用預設路徑:")
        print(f"  輸入: {input_file}")
        print(f"  輸出: {output_file}")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"❌ 錯誤: 找不到輸入檔案 '{input_file}'")
        sys.exit(1)
    
    convert_applications_sql(input_file, output_file)


if __name__ == "__main__":
    main()
