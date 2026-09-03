@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ============================================
echo   Sumaticket - Comprobar proyecto
echo ============================================
echo.

set "FAILED=0"
call :check "Sumaticket.xcodeproj\project.pbxproj"
call :check "Sumaticket.xcodeproj\xcshareddata\xcschemes\Sumaticket.xcscheme"
call :check "Sumaticket\SumaticketApp.swift"
call :check "Sumaticket\Info.plist"
call :check "Sumaticket\Assets.xcassets\AppIcon.appiconset\Contents.json"
call :check ".github\workflows\build-ipa.yml"
call :check "SUBIR_A_GITHUB.bat"
call :check "README.md"
call :check "INSTALACION_WINDOWS.md"

findstr /S /I /M "GameShelf ahorro-iphone PLACEHOLDER_APP" "Sumaticket\*.swift" "Sumaticket.xcodeproj\project.pbxproj" >nul 2>nul
if not errorlevel 1 (
    echo [ERROR] Se encontraron nombres residuales de otro proyecto.
    set "FAILED=1"
)

if "%FAILED%"=="1" (
    echo.
    echo [ERROR] La comprobacion estructural ha fallado.
    pause
    exit /b 1
)

echo.
echo [OK] Estructura basica correcta.
echo La compilacion real de iOS se valida en GitHub Actions con Xcode 26.
pause
exit /b 0

:check
if not exist %~1 (
    echo [ERROR] Falta: %~1
    set "FAILED=1"
) else (
    echo [OK] %~1
)
exit /b 0
