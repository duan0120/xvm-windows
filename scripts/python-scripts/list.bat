@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"

:: Get current version from node in PATH
set "current_version="
for /f "tokens=2" %%i in ('python --version 2^>nul') do set "current_version=%%i"

:: List installed versions
if exist "%version_path%" (
    for /d %%V in ("%version_path%\python*") do (
        set "version=%%~nxV"
        if "!version!"=="!current_version!" (
            echo !version!    ^<- current
        ) else (
            echo !version!
        )
    )
)

exit /b 0 