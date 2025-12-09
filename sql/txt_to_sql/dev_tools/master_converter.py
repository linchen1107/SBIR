#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NSN資料庫主轉換腳本
按照匯入順序.md的5個階段順序執行所有轉換腳本
"""

import os
import sys
import subprocess
import time
from pathlib import Path
import logging

# 設定日誌
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class MasterConverter:
    def __init__(self):
        self.script_dir = Path(__file__).parent
        self.conversion_scripts = [
            # 按照匯入順序.md的5個階段順序
            ("00_convert_fsg.py", "FSG (聯邦供應組別)"),
            ("01_convert_mrc_key_group.py", "MRC Key Group (MRC關鍵字分組)"),
            ("02_convert_reply_table.py", "Reply Table (回應選項表)"),
            ("03_convert_fsc.py", "FSC (聯邦供應分類)"),
            ("04_convert_nato_h6_item_name.py", "NATO H6 Item Name"),
            ("05_convert_inc.py", "INC (物品名稱代碼)"),
            ("06_convert_mrc.py", "MRC (主需求代碼)"),
            ("07_convert_mode_code_edit.py", "Mode Code Edit (模式代碼編輯規則)"),
            ("08_convert_inc_fsc_xref.py", "INC-FSC交叉參照"),
            ("09_convert_nato_h6_inc_xref.py", "NATO H6-INC對應"),
            ("10_convert_colloquial_inc_xref.py", "俗稱INC對應"),
            ("11_convert_fiig.py", "FIIG (物品識別指南)"),
            ("12_convert_mrc_reply_table_xref.py", "MRC回應表對應"),
            ("13_convert_fiig_inc_xref.py", "FIIG-INC對應"),
            ("14_convert_fiig_inc_mrc_xref.py", "FIIG-INC-MRC三元關聯")
        ]
        
        self.failed_scripts = []
        self.successful_scripts = []
        
    def check_dependencies(self):
        """檢查必要依賴項目"""
        logging.info("🔍 檢查依賴項目...")
        
        # 檢查raw_data路徑
        raw_data_path = Path('../raw_data')
        if not raw_data_path.exists():
            logging.error(f"❌ raw_data路徑不存在: {raw_data_path}")
            return False
        
        # 檢查data_import路徑
        data_import_path = Path('../data_import')
        data_import_path.mkdir(exist_ok=True)
        
        # 檢查必要檔案
        required_files = [
            'fsg/Tabl316.TXT',
            'mrc_key_group/Tabl391.TXT', 
            'reply_table/Tabl128.TXT',
            'fsc/Tabl076.TXT',
            'nato_h6_item_name/NATO-H6.TXT',
            'inc/Tabl098.TXT',
            'mrc/Tabl127.TXT',
            'mode_code_edit/Tabl390.TXT'
        ]
        
        missing_files = []
        for file_path in required_files:
            full_path = raw_data_path / file_path
            if not full_path.exists():
                missing_files.append(file_path)
        
        if missing_files:
            logging.warning(f"⚠️  缺少檔案不存在: {missing_files}")
            logging.info("📝 將跳過缺少轉換腳本")
        
        logging.info("✅ 依賴檢查完成")
        return True
        
    def run_conversion_script(self, script_name, description):
        """執行單個轉換腳本"""
        script_path = self.script_dir / script_name
        
        if not script_path.exists():
            logging.warning(f"⚠️  腳本不存在: {script_name}")
            self.failed_scripts.append((script_name, "腳本檔案不存在"))
            return False
        
        logging.info(f"🚀 執行: {description}")
        start_time = time.time()
        
        try:
            # 執行腳本
            result = subprocess.run(
                [sys.executable, str(script_path)],
                capture_output=True,
                text=True,
                cwd=self.script_dir
            )
            
            end_time = time.time()
            duration = end_time - start_time
            
            if result.returncode == 0:
                logging.info(f"✅ {description} 完成 ({duration:.1f}秒)")
                self.successful_scripts.append((script_name, description, duration))
                return True
            else:
                logging.error(f"❌ {description} 失敗")
                logging.error(f"錯誤輸出: {result.stderr}")
                self.failed_scripts.append((script_name, result.stderr))
                return False
                
        except Exception as e:
            logging.error(f"❌ 執行 {script_name} 時發生錯誤: {e}")
            self.failed_scripts.append((script_name, str(e)))
            return False
    
    def run_all_conversions(self, continue_on_error=True):
        """執行所有轉換腳本"""
        logging.info("🚀 開始執行所有轉換腳本...")
        
        total_start_time = time.time()
        
        for script_name, description in self.conversion_scripts:
            print(f"\n{'='*60}")
            print(f"執行階段: {description}")
            print(f"腳本: {script_name}")
            print(f"{'='*60}")
            
            success = self.run_conversion_script(script_name, description)
            
            if not success and not continue_on_error:
                logging.error("❌ 遇到錯誤，停止執行")
                break
                
            # 短暫暫停避免資源競爭
            time.sleep(1)
        
        total_end_time = time.time()
        total_duration = total_end_time - total_start_time
        
        # 顯示最終統計
        self.show_final_report(total_duration)
        
    def show_final_report(self, total_duration):
        """顯示最終執行報告"""
        print(f"\n{'='*80}")
        print("📊 NSN資料轉換執行完成報告")
        print(f"{'='*80}")
        
        print(f"⏱️ 總執行時間: {total_duration:.1f} 秒")
        print(f"✅ 成功: {len(self.successful_scripts)} 個腳本")
        print(f"❌ 失敗: {len(self.failed_scripts)} 個腳本")
        
        if self.successful_scripts:
            print(f"\n✅ 成功執行的腳本:")
            for script, desc, duration in self.successful_scripts:
                print(f"   ✓ {desc} ({duration:.1f}s)")
        
        if self.failed_scripts:
            print(f"\n❌ 失敗的腳本:")
            for script, error in self.failed_scripts:
                print(f"   ✗ {script}: {error[:100]}...")
        
        print(f"\n📁 輸出路徑: sql/data_import/")
        print(f"📋 下一步: 執行 'execute_sql_scripts.py' 將資料匯入資料庫")
        
        if len(self.failed_scripts) == 0:
            print(f"\n🎉 所有轉換腳本執行成功，可以開始匯入資料庫！")
        else:
            print(f"\n⚠️  部分轉換失敗，建議檢查錯誤後重新執行相關腳本")

def main():
    """主程式"""
    print("🚀 NSN資料庫主轉換工具")
    print("按照匯入順序執行的5個階段資料轉換")
    print("="*60)
    
    converter = MasterConverter()
    
    # 檢查依賴
    if not converter.check_dependencies():
        sys.exit(1)
    
    # 詢問是否繼續執行失敗的腳本
    print("\n選項:")
    print("1. 遇到錯誤時繼續執行 (推薦)")
    print("2. 遇到錯誤時停止執行")
    
    choice = input("\n請選擇 (1/2) [預設:1]: ").strip()
    continue_on_error = choice != '2'
    
    print(f"\n開始批次轉換 ({'繼續模式' if continue_on_error else '停止模式'})...")
    
    # 執行所有轉換
    converter.run_all_conversions(continue_on_error)

if __name__ == "__main__":
    main() 

