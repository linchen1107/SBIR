@echo off
chcp 65001 >nul
echo ============================================================
echo   SmartCodexAI - Web Application Schema Setup
echo ============================================================
echo.

cd /d "%~dp0"

echo [1/3] Checking environment...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo X Python not found. Please install Python 3.7+
    exit /b 1
)
echo OK Python environment is ready.

echo [2/3] Installing dependencies...
pip install psycopg2-binary >nul 2>&1
echo OK Dependencies are ready.

echo [3/3] Setting up Web App schema...
python setup_web_app.py
if %errorlevel% neq 0 (
    echo X Failed to set up Web App schema.
    exit /b 1
)

echo.
echo ============================================================
echo   Web Application Schema setup complete!
echo ============================================================
echo. 