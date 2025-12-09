@echo off
chcp 65001 >nul
setlocal

rem --- 資料庫連線設定 ---
set "PG_HOST=localhost"
set "PG_PORT=5433"
set "PG_USER=postgres"
set "PG_PASSWORD=postgres"
set "DB_NAME=nsn_database"
set "PGPASSWORD=%PG_PASSWORD%"

echo ======================================================================
echo           SmartCodexAI - 核心料件資料更新腳本
echo ======================================================================
echo.
echo  警告: 此腳本將會清空並重新匯入 'public' schema 中的所有料件資料。
echo        此操作不會影響 'web_app' schema 中的使用者資料。
echo.
echo  執行流程:
echo  1. (清空) 執行 clear_public_schema.sql 清空所有核心料件表格。
echo  2. (轉換) 執行所有轉換腳本，將原始文字檔轉為最新的 SQL 匯入檔。
echo  3. (匯入) 將新產生的 SQL 檔案匯入資料庫。
echo.
echo ======================================================================
echo.

:confirm
set "confirm="
set /p "confirm=您確定要執行核心料件資料更新嗎? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo.
    echo 操作已由使用者取消。
    goto :end
)

echo.
echo 確認完畢，開始執行資料更新...
echo.

echo --- 步驟 1/3: 正在清空現有的核心料件資料... ---
psql -h %PG_HOST% -p %PG_PORT% -U %PG_USER% -d %DB_NAME% -f clear_public_schema.sql
if %errorlevel% neq 0 (
    echo.
    echo [錯誤] 清空 public schema 的表格時發生錯誤，更新中止。
    goto :end
)
echo --- 核心料件資料已成功清空。 ---
echo.

echo --- 步驟 2/3: 正在重新產生 SQL 匯入檔案... ---
cd txt_to_sql
call execute_all_converters.bat
if %errorlevel% neq 0 (
    echo.
    echo [錯誤] 產生 SQL 匯入檔案時發生錯誤，更新中止。
    cd ..
    goto :end
)
cd ..
echo --- SQL 匯入檔案已成功產生。 ---
echo.

echo --- 步驟 3/3: 正在匯入最新的料件資料... ---
cd txt_to_sql
python execute_sql_scripts.py
if %errorlevel% neq 0 (
    echo.
    echo [錯誤] 匯入新資料時發生錯誤，更新中止。
    cd ..
    goto :end
)
cd ..
echo --- 最新的料件資料已成功匯入。 ---
echo.

echo ======================================================================
echo    ✅ 核心料件資料更新完成！ 'public' schema 已是最新狀態。
echo ======================================================================

:end
echo.
endlocal
pause 