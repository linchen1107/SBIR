@echo off
chcp 65001 >nul
echo ============================================================
echo   NSN料號申編系統 - 完全自動建置
echo   自動執行: 建立資料庫 + 表格結構 + 匯入資料
echo ============================================================
echo.

cd /d "%~dp0"

echo [1/6] 檢查環境...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python未安裝，請先安裝Python 3.7+
    exit /b 1
)
echo ✅ Python環境正常

echo [2/6] 安裝依賴套件...
pip install psycopg2-binary >nul 2>&1
echo ✅ 依賴套件準備完成

echo [3/6] 檢查檔案...
if not exist "database_schema.sql" (
    echo ❌ database_schema.sql檔案不存在
    exit /b 1
)
if not exist "data_import\db_config.ini" (
    echo ❌ data_import\db_config.ini檔案不存在
    exit /b 1
)
echo ✅ 所需檔案檢查完成

echo [4/6] 建立資料庫結構...
python setup_database.py
if %errorlevel% neq 0 (
    echo ❌ 資料庫建立失敗
    exit /b 1
)

echo [5/6] 執行TXT轉SQL...
cd txt_to_sql
echo 開始轉換TXT檔案為SQL...
call execute_all_converters.bat > converter_output.log 2>&1
set converter_result=%errorlevel%

echo 檢查轉換結果...
findstr /C:"SUCCESS] 所有轉換腳本執行完成" converter_output.log >nul
if %errorlevel% equ 0 (
    echo ✅ TXT轉SQL轉換成功
    set converter_result=0
) else (
    echo ⚠️ TXT轉SQL可能有問題，檢查日誌...
    findstr /C:"個腳本成功執行" converter_output.log
)

cd ..

:: 檢查SQL檔案是否生成
set sql_count=0
for %%f in (data_import\*.sql) do set /a sql_count+=1
if %sql_count% LSS 15 (
    echo ❌ SQL檔案生成不完整，只有%sql_count%個檔案
    echo.
    echo 🔧 可能的解決方案:
    echo 1. 檢查 raw_data 目錄是否包含所有DLA原始檔案
    echo 2. 檢查 txt_to_sql/converter_output.log 查看詳細錯誤
    echo 3. 手動修正 txt_to_sql 目錄中對應的Python轉換腳本
    echo.
    echo 📋 轉換腳本對應表:
    echo    00_convert_fsg.py          → FSG聯邦供應組別
    echo    01_convert_mrc_key_group.py → MRC關鍵群組
    echo    02_convert_reply_table.py  → 回應選項表
    echo    03_convert_fsc.py          → FSC聯邦供應分類
    echo    04_convert_nato_h6_item_name.py → NATO H6物品名稱
    echo    05_convert_inc.py          → INC物品名稱代碼
    echo    06_convert_mrc.py          → MRC主需求代碼
    echo    07_convert_mode_code_edit.py → 模式代碼編輯
    echo    08_convert_inc_fsc_xref.py → INC-FSC交叉參照
    echo    09_convert_nato_h6_inc_xref.py → NATO H6-INC對應
    echo    10_convert_colloquial_inc_xref.py → 俗稱INC對應
    echo    11_convert_fiig.py         → FIIG物品識別指南
    echo    12_convert_mrc_reply_table_xref.py → MRC回應表對應
    echo    13_convert_fiig_inc_xref.py → FIIG-INC對應
    echo    14_convert_fiig_inc_mrc_xref.py → FIIG-INC-MRC三元關聯
    exit /b 1
)
echo ✅ SQL檔案生成完成 (%sql_count%個檔案)

echo [6/6] 匯入資料...
cd data_import
python import_database.py
set import_result=%errorlevel%
cd ..

if %import_result% neq 0 (
    echo ❌ 資料匯入失敗
    echo.
    echo 🔧 故障排除步驟:
    echo 1. 檢查 data_import/import_log_*.log 查看詳細錯誤
    echo 2. 如果是欄位不存在錯誤，檢查 database_schema.sql
    echo 3. 如果是資料格式錯誤，需要修正對應的轉換腳本:
    echo.
    echo 📋 常見錯誤與修正腳本對應:
    echo    ○ mrc_key_group欄位錯誤     → 修正 txt_to_sql/01_convert_mrc_key_group.py
    echo    ○ 外鍵約束錯誤             → 檢查資料依賴關係
    echo    ○ 資料格式錯誤             → 修正對應的convert_*.py腳本
    echo    ○ 編碼問題                → 在Python腳本中加入encoding='utf-8'
    echo.
    echo 💡 修正Python腳本後，重新執行:
    echo    cd txt_to_sql
    echo    python 對應的convert_*.py
    echo    cd ../data_import
    echo    python import_database.py
    exit /b 1
)

echo.
echo ============================================================
echo 🎉 NSN料號申編系統建置完成！
echo ============================================================
echo 📋 資料庫資訊:
echo    主機: localhost:5433
echo    資料庫: nsn_database
echo    表格: 15張核心表格
echo.
echo 🎯 支援功能:
echo    - H2→H6→INC→FIIG→MRC申編流程
echo    - 完整的料號申編資料查詢
echo    - 220MB+ 實際資料內容
echo.
echo 📝 連線資訊:
echo    postgresql://postgres@localhost:5433/nsn_database
echo.
echo ✅ 系統已準備就緒，可開始開發申編介面！
echo ============================================================ 

echo.
echo ============================================================
echo   接著設定 Web Application Schema...
echo ============================================================
call setup_web_app.bat 