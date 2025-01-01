@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\go"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm go use ^<version^>
    exit /b 1
)

:: Normalize version
set "version=%~1"
if not "%version:~0,2%"=="go" set "version=go%version%"

:: Check if version exists
if not exist "%version_path%\%version%" (
    echo Error: Version %version% is not installed
    echo Run 'xvm go install %version%' to install it
    exit /b 1
)

:: Create or update default symlink with elevated privileges
if exist "%version_path%\default" (
    rmdir "%version_path%\default" 2>nul
    if !ERRORLEVEL! neq 0 (
        powershell -Command "Start-Process cmd -ArgumentList '/c rmdir \"%version_path%\default\"' -Verb RunAs -WindowStyle Hidden -Wait"
        timeout /t 1 /nobreak >nul
        if exist "%version_path%\default" (
            echo Error: Failed to remove existing symlink
            exit /b 1
        )
    )
)

powershell -Command "Start-Process cmd -ArgumentList '/c mklink /D \"%version_path%\default\" \"%version_path%\%version%\"' -Verb RunAs -WindowStyle Hidden -Wait"
timeout /t 1 /nobreak >nul
if not exist "%version_path%\default" (
    echo Error: Failed to create symlink
    exit /b 1
)

echo Successfully set golang %version% as default

exit /b 0 