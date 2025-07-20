@echo off
echo AquaForge Frontend - Configuration Helper
echo =======================================
echo.

:MENU
echo Choose an option:
echo 1. Configure API Endpoint
echo 2. Install Dependencies
echo 3. Run Flutter Web App
echo 4. Build for Production
echo 5. Exit
echo.

set /p option="Enter option (1-5): "

if "%option%"=="1" goto CONFIG_API
if "%option%"=="2" goto INSTALL_DEPS
if "%option%"=="3" goto RUN_APP
if "%option%"=="4" goto BUILD_PROD
if "%option%"=="5" goto EXIT
goto MENU

:CONFIG_API
echo.
echo Configure API Endpoint
echo --------------------
set /p api_url="Enter production API URL (e.g., https://api.aquaforge.example.com): "
python configure_api.py %api_url%
echo.
pause
goto MENU

:INSTALL_DEPS
echo.
echo Installing Dependencies...
echo --------------------
flutter pub get
echo.
pause
goto MENU

:RUN_APP
echo.
echo Running Flutter Web App...
echo --------------------
flutter run -d chrome
goto MENU

:BUILD_PROD
echo.
echo Building for Production...
echo --------------------
flutter build web --release
echo Build completed. Files are in the 'build/web' directory.
echo.
pause
goto MENU

:EXIT
echo.
echo Thank you for using AquaForge Frontend Configuration Helper
exit /b 0
