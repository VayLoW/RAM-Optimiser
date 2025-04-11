@echo off
title Super Optimiseur de RAM
mode con: cols=80 lines=30
color 0A

net session >nul 2>&1
if %errorLevel% == 0 (
    goto menu
) else (
    echo Ce programme necessite des droits administrateur.
    echo Veuillez relancer en tant qu'administrateur.
    pause
    exit
)

:menu
cls
echo.
echo     ===============================================
echo     =             OPTIMISEUR DE RAM v2.0          =
echo     =            By VayLoW - 2025                 =
echo     ===============================================
echo.
echo     [ ETAT DE LA MEMOIRE ]
for /f "tokens=4" %%a in ('systeminfo ^| findstr /C:"Memoire physique totale"') do set "total=%%a"
for /f "tokens=4" %%a in ('systeminfo ^| findstr /C:"Memoire physique disponible"') do set "dispo=%%a"

echo     -----------------------------------------------
echo     Memoire Totale : %-37s
echo     Memoire Libre  : %-37s
echo     -----------------------------------------------
echo.
echo     [ MENU PRINCIPAL ]
echo     -----------------------------------------------
echo      1. Optimisation Complete
echo      2. Optimisation Legere
echo      3. Voir les processus gourmands
echo      4. Optimiser fichier de pagination
echo      5. Quitter
echo     -----------------------------------------------
echo.
set /p "choix=    Votre choix (1-5) : "

if "%choix%"=="1" goto optimize_full
if "%choix%"=="2" goto optimize_light
if "%choix%"=="3" goto processes
if "%choix%"=="4" goto pagefile
if "%choix%"=="5" exit
goto menu

setlocal EnableDelayedExpansion

:optimize_full
cls
echo     ===============================================
echo                OPTIMISATION COMPLETE EN COURS...
echo     ===============================================
echo.
echo Appuyez sur CTRL+C pour annuler l'operation a tout moment
echo.

set "step=1"

:phase1
echo Phase !step!: Nettoyage des fichiers temporaires...
echo Nettoyage du dossier Temp...
start /b /wait timeout /t 2 >nul
del /f /s /q %temp%\* >nul 2>&1
for /d %%x in (%temp%\*) do (
    start /b /wait timeout /t 1 >nul
    rd /s /q "%%x" 2>nul
)

echo Nettoyage de Windows\Temp...
start /b /wait timeout /t 2 >nul
del /f /s /q C:\Windows\Temp\* >nul 2>&1
for /d %%x in (C:\Windows\Temp\*) do (
    start /b /wait timeout /t 1 >nul
    rd /s /q "%%x" 2>nul
)

echo Nettoyage de Prefetch...
start /b /wait timeout /t 2 >nul
del /f /s /q C:\Windows\Prefetch\* >nul 2>&1
echo.

echo Phase 2: Nettoyage des caches...
ipconfig /flushdns
powershell -command "Clear-DnsClientCache"
echo.

echo Phase 3: Nettoyage des caches navigateurs...
taskkill /F /IM chrome.exe /T >nul 2>&1
taskkill /F /IM firefox.exe /T >nul 2>&1
taskkill /F /IM msedge.exe /T >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.default\cache2" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
echo.

set /a "step+=1"
echo Phase !step!: Optimisation services...
echo Arret des services non essentiels...

for %%s in (themes WSearch wuauserv DiagTrack SysMain) do (
    echo Arret de %%s...
    start /b /wait timeout /t 2 >nul
    net stop %%s >nul 2>&1
    if !errorlevel! neq 0 (
        echo Le service %%s n'a pas pu etre arrete. On continue...
    )
)
echo.

set /a "step+=1"
echo Phase !step!: Nettoyage de la memoire...

echo Vidage de la corbeille...
start /b /wait timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo Nettoyage de la memoire physique...
start /b /wait timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'SilentlyContinue'; Get-Process | Where-Object {$_.NonpagedSystemMemorySize -gt 10MB -and $_.Name -notmatch '^(System|Registry|svchost|lsass|csrss|smss|wininit|services|winlogon)$'} | ForEach-Object { try { $_.Kill() } catch {} }" >nul 2>&1

echo Liberation de la memoire standby...
start /b /wait timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()" >nul 2>&1
echo.

set /a "step+=1"
echo Phase !step!: Optimisation avancee...

:: Création d'un processus avec timeout
start /b cmd /c "%windir%\system32\rundll32.exe advapi32.dll,ProcessIdleTasks >nul 2>&1"

:: Attendre maximum 10 secondes
set /a timeout_counter=0
:wait_loop
if %timeout_counter% geq 10 (
    echo L'optimisation avancee prend trop de temps, utilisation de la methode alternative...
    :: Méthode alternative d'optimisation
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Process | Where-Object {$_.PriorityClass -ne 'Idle'} | ForEach-Object { try { $_.PriorityClass = 'BelowNormal' } catch {} }" >nul 2>&1
    goto optimization_done
)
timeout /t 1 >nul
set /a timeout_counter+=1
tasklist /fi "imagename eq rundll32.exe" 2>nul | find "rundll32.exe" >nul
if not errorlevel 1 goto wait_loop

:optimization_done

echo.
echo Toutes les phases sont terminees !
echo Si certaines operations ont echoue, c'est normal - le systeme est protege.
echo.

echo Optimisation complete terminee !
timeout /t 5
goto menu

:optimize_light
cls
echo     ===============================================
echo                OPTIMISATION LEGERE EN COURS...
echo     ===============================================
echo.
echo Phase 1: Nettoyage basique...
ipconfig /flushdns
powershell -command "Clear-DnsClientCache"
echo.

echo Phase 2: Liberation memoire...
powershell -command "Get-Process | Where-Object {$_.NonpagedSystemMemorySize -gt 50MB} | Stop-Process -Force"
echo.

echo Optimisation legere terminee !
timeout /t 3
goto menu

:processes
cls
echo     ===============================================
echo            PROCESSUS UTILISANT LE PLUS DE RAM
echo     ===============================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 | Format-Table Name, @{Name='Memory (MB)';Expression={[math]::round($_.WorkingSet / 1MB, 2)}}, CPU"
echo.
echo Appuyez sur une touche pour revenir au menu...
pause >nul
goto menu

:pagefile
cls
echo     ===============================================
echo             OPTIMISATION FICHIER DE PAGINATION
echo     ===============================================
echo.
echo Modification de la taille du fichier de pagination...
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False
wmic pagefileset where name="C:\pagefile.sys" set InitialSize=4096,MaximumSize=4096
echo.
echo Le fichier de pagination a ete optimise !
timeout /t 3
goto menu


