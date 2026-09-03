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

echo Repositorio configurado:
git remote get-url origin
goto :sync

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

:sync
echo.
echo Sincronizando con origin/main...

git fetch origin
if errorlevel 1 goto :error

git show-ref --verify --quiet refs/remotes/origin/main
if errorlevel 1 goto :push

git merge-base HEAD origin/main >nul 2>nul
if errorlevel 1 goto :unrelated

git pull --rebase origin main
if errorlevel 1 goto :rebase_error
goto :push

:unrelated
echo.
echo El repositorio remoto tiene un historial inicial distinto.
echo Se integrara sin sobrescribir el contenido remoto.
git pull origin main --allow-unrelated-histories --no-edit
if errorlevel 1 goto :merge_error
goto :push

:push
echo.
echo Subiendo main...
git push -u origin main
if errorlevel 1 goto :error

echo.
echo [OK] Proyecto sincronizado y subido correctamente.
echo GitHub Actions generara la IPA tras el push.
pause
exit /b 0

:rebase_error
echo.
echo [ERROR] Git encontro un conflicto al integrar origin/main.
echo.
echo Archivos en conflicto:
git status --short
echo.
echo Resuelve los conflictos y despues ejecuta:
echo   git add .
echo   git rebase --continue
echo.
echo Para cancelar la integracion:
echo   git rebase --abort
pause
exit /b 1

:merge_error
echo.
echo [ERROR] Git encontro un conflicto al unir el historial remoto.
echo.
git status --short
echo.
echo Resuelve los conflictos, ejecuta "git add ." y crea el commit.
echo Para cancelar: git merge --abort
pause
exit /b 1

:error
echo.
echo [ERROR] La operacion fallo. Revisa el mensaje anterior.
pause
exit /b 1
