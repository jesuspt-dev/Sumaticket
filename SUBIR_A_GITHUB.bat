@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ============================================
echo   Sumaticket - Subir a GitHub
echo ============================================
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git no esta instalado o no esta en PATH.
    pause
    exit /b 1
)

if not exist ".git" (
    git init
    if errorlevel 1 goto :error
)

git add .
if errorlevel 1 goto :error

git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Update Sumaticket"
    if errorlevel 1 goto :error
) else (
    echo No hay cambios nuevos que confirmar.
)

git branch -M main
if errorlevel 1 goto :error

git remote get-url origin >nul 2>nul
if errorlevel 1 goto :askrepo

echo.
echo Repositorio configurado:
git remote get-url origin
goto :push

:askrepo
set "REPO_URL="
set /p "REPO_URL=Introduce la URL HTTPS del repositorio GitHub: "
if not defined REPO_URL (
    echo [ERROR] No se ha indicado ninguna URL.
    pause
    exit /b 1
)
git remote add origin "%REPO_URL%"
if errorlevel 1 goto :error

:push
echo.
echo Subiendo main...
git push -u origin main
if errorlevel 1 goto :error

echo.
echo [OK] Proyecto subido. GitHub Actions generara la IPA.
pause
exit /b 0

:error
echo.
echo [ERROR] La operacion fallo. Revisa el mensaje anterior.
pause
exit /b 1
