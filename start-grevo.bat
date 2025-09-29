@echo off
setlocal

REM Resolve project root based on script location
set "ROOT=%~dp0"
pushd "%ROOT%"

echo ====================================
echo    Starting Grevo Complete System
echo ====================================
echo.

echo [INFO] Starting Backend Server...
start "Grevo Backend" cmd /k "cd /d \"%ROOT%mock-backend\" && npm run dev"

echo [INFO] Waiting for backend to initialize...
timeout /t 3 /nobreak >nul

echo [INFO] Starting Flutter App...
start "Grevo Flutter App" cmd /k "cd /d \"%ROOT%\" && flutter run -d chrome"

echo.
echo ====================================
echo Grevo System Started!
echo ====================================
echo.
echo Backend: http://localhost:8000
echo Frontend: Will open in Chrome automatically
echo.
echo To stop the system:
echo 1. Close the backend window or press Ctrl+C
echo 2. Close the frontend window or press Ctrl+C
echo.
echo Press any key to continue...
pause >nul

popd
endlocal
