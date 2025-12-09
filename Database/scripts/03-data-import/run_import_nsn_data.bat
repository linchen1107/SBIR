@echo off
chcp 65001 >nul
echo ====================================================
echo NSN 資料匯入工具
echo ====================================================
echo.
echo 資料庫: sbir_equipment_db_v3
echo Schema: public
echo 主機: localhost:5432
echo.
echo ====================================================
echo.

python "%~dp0import_nsn_data.py" %*

echo.
echo ====================================================
pause
