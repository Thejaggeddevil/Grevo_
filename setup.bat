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

:: Install Flutter dependencies
echo.
echo [INFO] Installing Flutter dependencies...
flutter pub get

:: Check if Node.js is installed
echo.
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed!
    echo Please install Node.js from: https://nodejs.org
    echo.
    echo Quick install via winget:
    echo winget install --id=OpenJS.NodeJS
    echo.
    pause
    exit /b 1
)

echo [✓] Node.js is installed
node --version
npm --version

:: Install backend dependencies
echo.
echo [INFO] Installing backend dependencies...
if exist "mock-backend" (
    cd mock-backend
    npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install backend dependencies!
        pause
        exit /b 1
    )
    cd ..
    echo [✓] Backend dependencies installed
) else (
    echo [WARNING] mock-backend folder not found, skipping backend setup
)

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
echo 1. Start the complete system: start-grevo.bat
echo 2. OR manually start backend: cd mock-backend && npm start
echo 3. OR manually start frontend: flutter run -d chrome
echo.
echo The integrated backend will run on: http://localhost:8000
echo Edit .env file if you need custom configuration
echo.
pause