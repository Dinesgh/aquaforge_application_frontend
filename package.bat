@echo off
echo Creating AquaForge Frontend Package
echo ================================
echo.

REM Create a timestamp for the zip file name
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set ZIPDATE=%datetime:~0,8%-%datetime:~8,6%

REM Create the zip file
echo Creating zip file...
powershell -command "& {Compress-Archive -Path .\* -DestinationPath ..\aquaforge_frontend_%ZIPDATE%.zip -Force}"

echo.
echo Package created successfully: aquaforge_frontend_%ZIPDATE%.zip
echo.
echo This package contains all the files needed to deploy the AquaForge frontend.
echo.
pause
