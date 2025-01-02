@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"

:: Get current version from python command
set "current_version="
for /f "tokens=2" %%i in ('python -V 2^>^&1') do set "current_version=%%i"

:: List installed versions
if exist "%version_path%" (
    echo Installed versions:
    echo -----------------
    
    :: List regular versions (excluding default and alias environments)
    for /d %%V in ("%version_path%\*") do (
        set "dirname=%%~nxV"
        if "!dirname!"=="default" (
            rem Skip default symlink
        ) else if exist "%version_path%\.!dirname!_*" (
            rem Skip alias directories, will handle them later
        ) else (
            if "!dirname!"=="!current_version!" (
                echo !dirname!    ^<- current
            ) else (
                echo !dirname!
            )
        )
    )
    
    :: List virtual environments
    set "has_virtual=0"
    for %%F in ("%version_path%\.*_*") do (
        if "!has_virtual!"=="0" (
            echo.
            echo Virtual environments:
            echo -------------------
            set "has_virtual=1"
        )
        
        set "config_file=%%~nxF"
        set "alias_name=!config_file:~1!"
        for /f "tokens=1,* delims=_" %%a in ("!alias_name!") do (
            set "env_name=%%a"
            set "env_version=%%b"
            if "!env_name!"=="!_XVM_PYTHON_ALIAS!" (
                echo !env_name! (!env_version!^)    ^<- active
            ) else (
                echo !env_name! (!env_version!^)
            )
        )
    )
)

exit /b 0 