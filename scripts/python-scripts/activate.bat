@echo off
setlocal EnableDelayedExpansion

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm python activate ^<alias_name^>
    exit /b 1
)

set "version_path=%XVM_ROOT%\versions\python"
set "alias_name=%~1"

:: Find config file for the alias
set "found="
for %%F in ("%version_path%\.%alias_name%_*") do (
    set "config_file=%%F"
    set "found=1"
)

if not defined found (
    echo Error: Alias '%alias_name%' not found
    echo Please create it first using: xvm python alias ^<version^> %alias_name%
    exit /b 1
)

:: Check if alias directory exists
if not exist "%version_path%\%alias_name%" (
    echo Error: Alias environment directory not found
    echo Please recreate the alias using: xvm python alias ^<version^> %alias_name%
    exit /b 1
)

:: Check if already in a virtual environment
if defined _XVM_PYTHON_ACTIVE (
    echo Error: Another Python environment is already active.
    echo Please run 'xvm python deactivate' first.
    exit /b 1
)

:: Set environment variables
endlocal & (
    set "_XVM_ORIGINAL_PATH=%PATH%"
    set "_XVM_ORIGINAL_PROMPT=%PROMPT%"
    set "_XVM_PYTHON_ACTIVE=1"
    set "_XVM_PYTHON_ALIAS=%alias_name%"
    set "_XVM_PYTHON_CONFIG=%config_file%"
    set "PYTHONHOME=%version_path%\%alias_name%"
    set "PATH=%version_path%\%alias_name%;%version_path%\%alias_name%\Scripts;%PATH%"
    set "PYTHONPATH=%version_path%\%alias_name%\Lib\site-packages"
    set "VIRTUAL_ENV=%version_path%\%alias_name%"
    set "PROMPT=(%alias_name%) %PROMPT%"
    echo Activated Python environment '%alias_name%'
    echo Type 'xvm python deactivate' to deactivate
)
