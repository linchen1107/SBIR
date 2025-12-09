@echo off
chcp 65001 >nul
echo ====================================================
echo 執行 Schema 重構腳本
echo ====================================================
echo.
echo 資料庫: sbir_equipment_db_v3
echo 主機: localhost:5432
echo 使用者: postgres
echo 腳本: integrate_nsn_core.sql
echo.
echo ====================================================
echo.

set PGPASSWORD=willlin07
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h localhost -p 5432 -U postgres -d sbir_equipment_db_v3 -f "%~dp0integrate_nsn_core.sql"
set PGPASSWORD=

echo.
echo ====================================================
echo 執行完成！
echo ====================================================
pause
