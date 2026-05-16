@echo off
REM Gospel Backend + Flutter Integration Setup Script
REM This script sets up both backend and frontend for local development

echo.
echo =============================================
echo Gospel Platform - Local Development Setup
echo =============================================
echo.

REM Check if running from Gospel folder
if not exist "pubspec.yaml" (
    echo Error: Run this script from the Gospel folder root
    pause
    exit /b 1
)

echo Step 1: Installing Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Failed to get Flutter dependencies
    pause
    exit /b 1
)
echo ✓ Flutter dependencies installed

echo.
echo Step 2: Checking GospelBackend location...
if not exist "..\GospelBackend\package.json" (
    echo Error: GospelBackend not found at ..\GospelBackend
    echo Please ensure GospelBackend folder exists on Desktop
    pause
    exit /b 1
)
echo ✓ GospelBackend found

echo.
echo =============================================
echo Setup Complete!
echo =============================================
echo.
echo Next steps:
echo.
echo 1. Start the backend (in another terminal):
echo    cd ..\GospelBackend
echo    npm run dev
echo.
echo 2. Run the Flutter app:
echo    flutter run -d chrome        (for web)
echo    flutter run -d windows       (for Windows desktop)
echo    flutter run                  (for device/emulator)
echo.
echo 3. Backend will be available at:
echo    http://localhost:3000
echo.
echo Documentation:
echo    See BACKEND_INTEGRATION.md for detailed setup
echo.
pause
