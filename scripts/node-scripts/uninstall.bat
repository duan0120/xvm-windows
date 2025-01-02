@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\node"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm node uninstall ^<version^>
    exit /b 1
)

:: Normalize version
set "version=%~1"
if not "%version:~0,1%"=="v" set "version=v%version%"

:: Check if version exists
if not exist "%version_path%\%version%" (
    echo node %version% is not installed
    exit /b 1
)

:: Check if this version is current default
for /f "tokens=*" %%i in ('node --version 2^>nul') do set "current_version=%%i"
if "%current_version%"=="%version%" (
    :: Try to remove default symlink with elevated privileges
    powershell -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c rmdir \"%version_path%\default\"' -Verb RunAs -WindowStyle Hidden -Wait"
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