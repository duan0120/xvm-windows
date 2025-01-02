@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"
set "config_path=%version_path%"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm python alias ^<version^> ^<alias_name^>
    exit /b 1
)
if "%~2"=="" (
    echo Usage: xvm python alias ^<version^> ^<alias_name^>
    exit /b 1
)

set "version=%~1"
set "alias_name=%~2"
set "config_file=%config_path%\.%alias_name%_%version%"

:: Check if config file already exists
if exist "%config_file%" (
    echo Error: Alias '%alias_name%' already exists
    echo To remove it, delete: %config_file%
    exit /b 1
)

:: Check if source version is a virtual environment
if exist "%version_path%\.%version%_*" (
    echo Error: Cannot create alias from a virtual environment
    echo Please use a regular Python version instead
    exit /b 1
)

:: Check if source version exists
if not exist "%version_path%\%version%" (
    echo Error: Python version %version% is not installed
    echo Please run 'xvm python install %version%' first
    exit /b 1
)

:: Create config directory if it doesn't exist
if not exist "%config_path%" (
    mkdir "%config_path%"
)

:: Create alias by copying the source version
echo Creating alias '%alias_name%' for Python %version%...
xcopy /E /H /I /Y "%version_path%\%version%" "%version_path%\%alias_name%" > nul

:: Create config file to track the alias
echo version=%version%> "%config_file%"
echo alias=%alias_name%>> "%config_file%"
echo created=%date% %time%>> "%config_file%"

echo Successfully created alias '%alias_name%' for Python %version%
echo To use this environment, run: xvm python activate %alias_name%

exit /b 0
