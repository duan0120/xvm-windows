@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\node"
set "cur_path=%CD%"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm node install ^<version^>
    exit /b 1
)

:: Normalize version
set "version=%~1"
if not "%version:~0,1%"=="v" set "version=v%version%"

:: Check if already installed
if exist "%version_path%\%version%" (
    echo node %version% is already installed.
    exit /b 0
)

:: Get system info
set "os=win"
set "arch=x64"

:: Create temp directory
set "temp_dir=%TEMP%\node_install_%RANDOM%"
mkdir "%temp_dir%"
cd "%temp_dir%"

:: Download and install
set "download_url=https://nodejs.org/dist/%version%/node-%version%-win-%arch%.zip"
echo Downloading from %download_url%

curl -L "%download_url%" -o "node.zip"
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Failed to download node
    exit /b 1
)

mkdir "%version_path%\%version%"
powershell -Command "Expand-Archive -Path node.zip -DestinationPath '%version_path%\%version%' -Force"
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    rd /s /q "%version_path%\%version%"
    echo Failed to extract node
    exit /b 1
)

:: Move files from nested directory to version directory
xcopy "%version_path%\%version%\node-%version%-win-%arch%\*" "%version_path%\%version%\" /E /H /Y
rd /s /q "%version_path%\%version%\node-%version%-win-%arch%"

cd "%cur_path%"
rd /s /q "%temp_dir%"

echo node %version% has been installed successfully
echo Please run 'xvm node use %version%' to set it
exit /b 0 