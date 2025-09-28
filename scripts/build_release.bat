@echo off
echo Building Grevo App for Production Release...

:: Clean previous builds
echo Cleaning previous builds...
call flutter clean
call flutter pub get

:: Generate app icons (if needed)
echo Checking for app icons...
if exist "assets\icon\app_icon.png" (
    echo Generating app icons...
    call flutter pub run flutter_launcher_icons:main
)

:: Build Android APK
echo Building Android APK...
call flutter build apk --release --split-per-abi

:: Build Android App Bundle (recommended for Play Store)
echo Building Android App Bundle...
call flutter build appbundle --release

:: Build for Windows (if on Windows)
echo Building Windows executable...
call flutter build windows --release

:: Build for Web
echo Building Web version...
call flutter build web --release --base-href "/grevo/"

:: Create build summary
echo.
echo ========================================
echo Build Summary
echo ========================================
echo Android APK: build\app\outputs\flutter-apk\
echo Android AAB: build\app\outputs\bundle\release\
echo Windows: build\windows\runner\Release\
echo Web: build\web\
echo.
echo Build completed successfully!
echo.

:: Open build directory
start "" "build"

pause