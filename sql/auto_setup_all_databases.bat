@echo off
chcp 65001 >nul
setlocal

echo ======================================================================
echo           SmartCodexAI - FULL DATABASE RESET AND SETUP
echo ======================================================================
echo.
echo  WARNING: This script will completely ERASE the existing 'nsn_database'
echo           and rebuild everything from scratch, including:
echo           1. Core NSN data (public schema)
echo           2. Web application data (web_app schema)
echo           3. All imported data from text files.
echo.
echo           THIS ACTION CANNOT BE UNDONE.
echo.
echo ======================================================================
echo.

:confirm_1
set "confirm="
set /p "confirm=Are you absolutely sure you want to proceed? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo.
    echo Setup cancelled by user.
    goto :end
)

echo.
:confirm_2
set "confirm="
set /p "confirm=Final confirmation. This will delete all data. Type 'PROCEED' to continue: "
if /i not "%confirm%"=="PROCEED" (
    echo.
    echo Setup cancelled by user. Final confirmation failed.
    goto :end
)

echo.
echo Confirmed. Starting the full database setup...
echo.

echo --- Step 1: Setting up Core NSN Database and Web App Schema ---
call setup_nsn_database.bat
if %errorlevel% neq 0 (
    echo.
    echo [FATAL] Database setup failed. Aborting.
    goto :end
)
echo --- Database setup finished. ---
echo.

echo ======================================================================
echo    All databases and schemas have been successfully reset and set up!
echo ======================================================================

:end
echo.
endlocal
pause 