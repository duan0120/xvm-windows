@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm python uninstall ^<version^>
    exit /b 1
)

set "version=%~1"

:: Check if version exists
if not exist "%version_path%\%version%" (
    echo python %version% is not installed
    exit /b 1
)

:: Check if this version is current default
for /f "tokens=2" %%i in ('python --version 2^>nul') do set "current_version=%%i"
if "%current_version%"=="%version%" (
    :: Try to remove default symlink with elevated privileges
    powershell -Command "Start-Process cmd -ArgumentList '/c rmdir \"%version_path%\default\"' -Verb RunAs -WindowStyle Hidden -Wait"
    timeout /t 1 /nobreak >nul
    if exist "%version_path%\default" (
        echo Error: Failed to remove default symlink
        exit /b 1
    )
)

:: Remove version directory
rd /s /q "%version_path%\%version%"
echo %version% has been uninstalled successfully

exit /b 0 