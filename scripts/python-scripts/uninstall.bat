@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm python uninstall ^<version^>
    exit /b 1
)

set "version=%~1"

:: Check if this is a virtual environment
set "is_virtual=0"
set "config_file="
for %%F in ("%version_path%\.%version%_*") do (
    set "is_virtual=1"
    set "config_file=%%F"
)

:: Check if version exists
if not exist "%version_path%\%version%" (
    if "!is_virtual!"=="1" (
        echo Error: Virtual environment '%version%' not found
    ) else (
        echo Error: Python %version% is not installed
    )
    exit /b 1
)

:: Check if this version is current default
if "!is_virtual!"=="0" (
    for /f "tokens=2" %%i in ('python -V 2^>^&1') do set "current_version=%%i"
    if "!current_version!"=="%version%" (
        :: Try to remove default symlink with elevated privileges
        powershell -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c rmdir \"%version_path%\default\"' -Verb RunAs -WindowStyle Hidden -Wait"
        timeout /t 1 /nobreak >nul
        if exist "%version_path%\default" (
            echo Error: Failed to remove default symlink
            exit /b 1
        )
    )
)

:: Check if virtual environment is currently active
if "!is_virtual!"=="1" (
    if "%_XVM_PYTHON_ALIAS%"=="%version%" (
        echo Error: Cannot uninstall active virtual environment
        echo Please run 'xvm python deactivate' first
        exit /b 1
    )
)

:: Remove version directory
rd /s /q "%version_path%\%version%"

:: Remove config file if it's a virtual environment
if "!is_virtual!"=="1" (
    if exist "!config_file!" (
        del "!config_file!"
        echo Virtual environment '%version%' has been uninstalled successfully
    )
) else (
    echo Python %version% has been uninstalled successfully
)

exit /b 0 