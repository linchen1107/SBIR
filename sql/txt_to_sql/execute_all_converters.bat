@echo off
chcp 65001 >nul
:: NSN料號申編系統 - TXT轉SQL批次執行腳本
:: 版本: 1.1 (修正路徑問題)
:: 按照匯入順序.md的15個階段依序執行所有轉換腳本

echo ============================================================
echo   NSN料號申編系統 - TXT轉SQL批次轉換工具
echo   版本: 1.1
echo   功能: 依序執行15個轉換腳本 (00-14)
echo ============================================================
echo.

:: 取得批次檔案所在目錄
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

:: 檢查Python是否安裝
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python 未安裝，請先安裝 Python 3.7+
    pause
    exit /b 1
)

echo [OK] Python 已安裝
echo.

:: 檢查是否在正確目錄
if not exist "00_convert_fsg.py" (
    echo [ERROR] 找不到轉換腳本，請確認在正確目錄執行
    echo 當前目錄: %CD%
    echo 需要的檔案: 00_convert_fsg.py
    pause
    exit /b 1
)

:: 記錄開始時間
echo [INFO] 開始執行TXT轉SQL轉換流程...
echo [INFO] 開始時間: %date% %time%
echo [INFO] 工作目錄: %CD%
echo.

:: 設定計數器
set success_count=0
set total_count=15

:: ================================================
:: 階段 1-8: 基礎表格 (無外鍵依賴)
:: ================================================

echo [STAGE] 第一階段: 基礎表格轉換 (無外鍵依賴)
echo ================================================

:: 00_convert_fsg.py
echo [1/15] 執行 FSG聯邦供應組別轉換...
python "00_convert_fsg.py"
if %errorlevel% equ 0 (
    echo   [OK] FSG轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] FSG轉換失敗
    goto :error_exit
)

:: 01_convert_mrc_key_group.py
echo [2/15] 執行 MRC關鍵字分組轉換...
python "01_convert_mrc_key_group.py"
if %errorlevel% equ 0 (
    echo   [OK] MRC關鍵字分組轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] MRC關鍵字分組轉換失敗
    goto :error_exit
)

:: 02_convert_reply_table.py
echo [3/15] 執行 回應選項表轉換...
python "02_convert_reply_table.py"
if %errorlevel% equ 0 (
    echo   [OK] 回應選項表轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] 回應選項表轉換失敗
    goto :error_exit
)

:: 03_convert_fsc.py
echo [4/15] 執行 FSC聯邦供應分類轉換...
python "03_convert_fsc.py"
if %errorlevel% equ 0 (
    echo   [OK] FSC聯邦供應分類轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] FSC聯邦供應分類轉換失敗
    goto :error_exit
)

:: 04_convert_nato_h6_item_name.py
echo [5/15] 執行 NATO H6物品名稱轉換...
python "04_convert_nato_h6_item_name.py"
if %errorlevel% equ 0 (
    echo   [OK] NATO H6物品名稱轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] NATO H6物品名稱轉換失敗
    goto :error_exit
)

:: 05_convert_inc.py
echo [6/15] 執行 INC物品名稱代碼轉換...
python "05_convert_inc.py"
if %errorlevel% equ 0 (
    echo   [OK] INC物品名稱代碼轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] INC物品名稱代碼轉換失敗
    goto :error_exit
)

:: 06_convert_mrc.py
echo [7/15] 執行 MRC主需求代碼轉換...
python "06_convert_mrc.py"
if %errorlevel% equ 0 (
    echo   [OK] MRC主需求代碼轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] MRC主需求代碼轉換失敗
    goto :error_exit
)

:: 07_convert_mode_code_edit.py
echo [8/15] 執行 模式代碼編輯規則轉換...
python "07_convert_mode_code_edit.py"
if %errorlevel% equ 0 (
    echo   [OK] 模式代碼編輯規則轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] 模式代碼編輯規則轉換失敗
    goto :error_exit
)

echo.
echo [SUCCESS] 第一階段完成! 基礎表格轉換 (8/8) 成功
echo.

:: ================================================
:: 階段 9-15: 關聯表格 (有外鍵依賴)
:: ================================================

echo [STAGE] 第二階段: 關聯表格轉換 (有外鍵依賴)
echo ================================================

:: 08_convert_inc_fsc_xref.py
echo [9/15] 執行 INC-FSC交叉參照轉換...
python "08_convert_inc_fsc_xref.py"
if %errorlevel% equ 0 (
    echo   [OK] INC-FSC交叉參照轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] INC-FSC交叉參照轉換失敗
    goto :error_exit
)

:: 09_convert_nato_h6_inc_xref.py
echo [10/15] 執行 NATO H6-INC對應轉換...
python "09_convert_nato_h6_inc_xref.py"
if %errorlevel% equ 0 (
    echo   [OK] NATO H6-INC對應轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] NATO H6-INC對應轉換失敗
    goto :error_exit
)

:: 10_convert_colloquial_inc_xref.py
echo [11/15] 執行 俗稱INC對應轉換...
python "10_convert_colloquial_inc_xref.py"
if %errorlevel% equ 0 (
    echo   [OK] 俗稱INC對應轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] 俗稱INC對應轉換失敗
    goto :error_exit
)

:: 11_convert_fiig.py
echo [12/15] 執行 FIIG物品識別指南轉換...
python "11_convert_fiig.py"
if %errorlevel% equ 0 (
    echo   [OK] FIIG物品識別指南轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] FIIG物品識別指南轉換失敗
    goto :error_exit
)

:: 12_convert_mrc_reply_table_xref.py
echo [13/15] 執行 MRC回應表對應轉換...
python "12_convert_mrc_reply_table_xref.py"
if %errorlevel% equ 0 (
    echo   [OK] MRC回應表對應轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] MRC回應表對應轉換失敗
    goto :error_exit
)

:: 13_convert_fiig_inc_xref.py
echo [14/15] 執行 FIIG-INC對應轉換...
python "13_convert_fiig_inc_xref.py"
if %errorlevel% equ 0 (
    echo   [OK] FIIG-INC對應轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] FIIG-INC對應轉換失敗
    goto :error_exit
)

:: 14_convert_fiig_inc_mrc_xref.py
echo [15/15] 執行 FIIG-INC-MRC三元關聯轉換...
python "14_convert_fiig_inc_mrc_xref.py"
if %errorlevel% equ 0 (
    echo   [OK] FIIG-INC-MRC三元關聯轉換完成
    set /a success_count+=1
) else (
    echo   [ERROR] FIIG-INC-MRC三元關聯轉換失敗
    goto :error_exit
)

echo.
echo [SUCCESS] 第二階段完成! 關聯表格轉換 (7/7) 成功
echo.

:: ================================================
:: 完成報告
:: ================================================

echo ============================================================
echo [SUCCESS] 所有轉換腳本執行完成！
echo ============================================================
echo [INFO] 完成時間: %date% %time%
echo [INFO] 執行結果: %success_count%/%total_count% 個腳本成功執行
echo.
echo [INFO] 輸出檔案位置: ../data_import/
echo    - 00_import_fsg.sql
echo    - 01_import_mrc_key_group.sql
echo    - 02_import_reply_table.sql
echo    - 03_import_fsc.sql
echo    - 04_import_nato_h6_item_name.sql
echo    - 05_import_inc.sql
echo    - 06_import_mrc.sql
echo    - 07_import_mode_code_edit.sql
echo    - 08_import_inc_fsc_xref.sql
echo    - 09_import_nato_h6_inc_xref.sql
echo    - 10_import_colloquial_inc_xref.sql
echo    - 11_import_fiig.sql
echo    - 12_import_mrc_reply_table_xref.sql
echo    - 13_import_fiig_inc_xref.sql
echo    - 14_import_fiig_inc_mrc_xref.sql
echo.
echo [INFO] 下一步:
echo    1. 檢查 ../data_import/ 目錄中的SQL檔案
echo    2. 按照順序匯入到PostgreSQL資料庫
echo    3. 執行資料完整性檢查
echo.
echo ============================================================
goto :end

:error_exit
echo.
echo ============================================================
echo [ERROR] 轉換過程中發生錯誤！
echo ============================================================
echo [INFO] 執行結果: %success_count%/%total_count% 個腳本成功執行
echo [WARNING] 請檢查錯誤訊息並修正問題後重新執行
echo.
echo [DEBUG] 常見問題排查:
echo    1. 檢查 ../raw_data/ 目錄是否存在對應的TXT檔案
echo    2. 檢查原始檔案格式是否正確
echo    3. 檢查磁碟空間是否足夠
echo    4. 檢查Python相關套件是否正確安裝
echo    5. 確認在 sql/txt_to_sql/ 目錄下執行批次檔
echo.
echo [INFO] 當前工作目錄: %CD%
echo ============================================================
pause
exit /b 1

:end
echo [INFO] 按任意鍵退出...
pause >nul 