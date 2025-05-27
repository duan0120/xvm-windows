@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\go"
set "cur_path=%CD%"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm go install ^<version^> [--arch=^<arch^> or --arch ^<arch^>]
    exit /b 1
)

:: Parse arguments
set "version=%~1"
set "arch=amd64"

:: Process --arch parameter if present
if "%~2"=="--arch" (
    if "%~3"=="" (
        echo Error: --arch requires an architecture value
        exit /b 1
    )
    set "arch=%~3"
) else if "%~2:~0,7%"=="--arch=" (
    set "arg=%~2"
    set "arch=!arg:~7!"
)

:: Validate architecture
if not "!arch!"=="amd64" if not "!arch!"=="386" if not "!arch!"=="arm64" (
    echo Unsupported architecture: !arch!. Supported architectures: amd64, 386, arm64
    exit /b 1
)

:: Normalize version
if not "%version:~0,2%"=="go" set "version=go%version%"

:: Check if already installed
if exist "%version_path%\%version%" (
    echo golang %version% is already installed.
    exit /b 0
)

set "os=windows"

:: Create temp directory
set "temp_dir=%TEMP%\go_install_%RANDOM%"
mkdir "%temp_dir%"
cd "%temp_dir%"

:: Set download URL (with proxy support)
set "pkg_url=https://go.dev"
if exist "%XVM_ROOT%\scripts\go-scripts\proxy" (
    set /p pkg_url=<"%XVM_ROOT%\scripts\go-scripts\proxy"
)

:: Download and install
set "download_url=%pkg_url%/dl/%version%.%os%-%arch%.zip"
echo Downloading from !download_url!

curl -L "!download_url!" -o "golang.zip"
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Failed to download golang
    exit /b 1
)

mkdir "%version_path%\%version%"
powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Path golang.zip -DestinationPath '%version_path%\%version%' -Force"
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    rd /s /q "%version_path%\%version%"
    echo Failed to extract golang
    exit /b 1
)

:: Delete the zip file after extraction
del /f /q "golang.zip"
if %ERRORLEVEL% neq 0 (
    echo Warning: Failed to delete golang.zip file
)

:: Move files and directories from nested directory to version directory
xcopy "%version_path%\%version%\go\*" "%version_path%\%version%\" /E /H /Y
rd /s /q "%version_path%\%version%\go"

cd "%cur_path%"
rd /s /q "%temp_dir%"

echo golang %version% has been installed successfully
echo Please run 'xvm go use %version%' to set it
exit /b 0