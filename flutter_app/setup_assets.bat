@echo off
REM Setup script for EGF Reader Flutter app (Windows)
REM This script copies the web application files to the Flutter assets folder

echo Setting up EGF Reader Flutter assets...

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
set PARENT_DIR=%SCRIPT_DIR%..

REM Create assets\web directory
if not exist "%SCRIPT_DIR%assets\web" mkdir "%SCRIPT_DIR%assets\web"

REM Copy web files
echo Copying web files from parent directory...

copy "%PARENT_DIR%\index.html" "%SCRIPT_DIR%assets\web\"
copy "%PARENT_DIR%\app.js" "%SCRIPT_DIR%assets\web\"
copy "%PARENT_DIR%\style.css" "%SCRIPT_DIR%assets\web\"
copy "%PARENT_DIR%\i18n.js" "%SCRIPT_DIR%assets\web\"
copy "%PARENT_DIR%\jszip.min.js" "%SCRIPT_DIR%assets\web\"

echo.
echo Files copied successfully!
echo.
echo Asset files:
dir "%SCRIPT_DIR%assets\web\"

echo.
echo Setup complete! You can now run:
echo   flutter pub get
echo   flutter run

pause
