@echo off
echo ====================================
echo    Grevo App - Quick Setup Script
echo ====================================
echo.

:: Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    echo.
    echo Quick install via winget:
    echo winget install --id=Flutter.Flutter
    echo.
    pause
    exit /b 1
)

echo [✓] Flutter is installed
flutter --version

:: Check Flutter doctor
echo.
echo [INFO] Running Flutter doctor...
flutter doctor

:: Install dependencies
echo.
echo [INFO] Installing dependencies...
flutter pub get

:: Copy environment file if it doesn't exist
if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] Creating .env file from template...
        copy ".env.example" ".env"
        echo [!] Please edit .env file with your configuration
    )
)

echo.
echo ====================================
echo Setup Complete!
echo ====================================
echo.
echo Next steps:
echo 1. Ensure your backend server is running on http://localhost:8000
echo 2. Edit .env file with your configuration
echo 3. Run: flutter run
echo.
echo For web: flutter run -d chrome
echo For Android: flutter run (with device connected)
echo.
pause