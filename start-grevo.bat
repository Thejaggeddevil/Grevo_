@echo off
echo ====================================
echo    Starting Grevo Complete System
echo ====================================
echo.

echo [INFO] Starting Backend Server...
cd /d "mock-backend"
start "Grevo Backend" cmd /k "npm start"

echo [INFO] Waiting for backend to initialize...
timeout /t 3 /nobreak

echo [INFO] Starting Flutter App...
cd /d ..
start "Grevo Flutter App" cmd /k "flutter run -d chrome"

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