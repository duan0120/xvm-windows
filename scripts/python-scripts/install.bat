@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"
set "cur_path=%CD%"
set "arch=64"

:: Parse arguments
:parse_args
if "%~1"=="" goto :args_done
if "%~1"=="--arch" (
    set "arch_arg=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--arch=386" (
    set "arch_arg=386"
    shift
    goto :parse_args
)
if "%~1"=="--arch=amd64" (
    set "arch_arg=amd64"
    shift
    goto :parse_args
)
if "%~1"=="--arch=arm64" (
    set "arch_arg=arm64"
    shift
    goto :parse_args
)
set "version=%~1"
shift
goto :parse_args
:args_done

:: Map architecture names to Anaconda format
if "%arch_arg%"=="386" (
    set "arch=32"
) else if "%arch_arg%"=="amd64" (
    set "arch=64"
) else if "%arch_arg%"=="arm64" (
    set "arch=aarch64"
) else if not "%arch_arg%"=="" (
    echo Error: Unsupported architecture: %arch_arg%
    echo Supported architectures: 386, amd64, arm64
    exit /b 1
)

:: Check if version is provided
if "%version%"=="" (
    echo Usage: xvm python install [--arch^=^<386^|amd64^|arm64^>] ^<version^>
    exit /b 1
)

:: Check if already installed
if exist "%version_path%\%version%" (
    echo python %version% is already installed.
    exit /b 0
)

:: Create temp directory
set "temp_dir=%TEMP%\python_install_%RANDOM%"
mkdir "%temp_dir%"
cd "%temp_dir%"

:: Get package info from Anaconda
echo Querying Python %version% package info...
curl -L "https://api.anaconda.org/package/anaconda/python/files" -o package_info.json
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Failed to get package info from Anaconda
    exit /b 1
)

:: Parse package info to find the correct version and its dependencies
powershell -ExecutionPolicy Bypass -Command "$json = Get-Content 'package_info.json' | ConvertFrom-Json; $pkg = $json | Where-Object { $_.version -eq '%version%' -and $_.attrs.subdir -eq 'win-%arch%' } | Select-Object -First 1; if ($pkg) { $pkg.download_url; $pkg.attrs.depends | ForEach-Object { $_ -replace ' .*','' } | ConvertTo-Json } else { 'not_found' }" > package_info.txt

set /p DOWNLOAD_URL=<package_info.txt
if "%DOWNLOAD_URL%"=="not_found" (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Python version %version% not found for architecture %arch%
    exit /b 1
)

:: Download and install dependencies
echo Installing dependencies...
for /f "tokens=* usebackq" %%a in (`powershell -ExecutionPolicy Bypass -Command "Get-Content package_info.txt | Select-Object -Skip 1 | ConvertFrom-Json"`) do (
    echo Installing %%a...
    :: Get package info
    curl -L "https://api.anaconda.org/package/anaconda/%%a/files" -o "%%a_info.json"
    :: Get latest win-arch version download URL
    powershell -ExecutionPolicy Bypass -Command "$json = Get-Content '%%a_info.json' | ConvertFrom-Json; $pkg = $json | Where-Object { $_.attrs.subdir -eq 'win-%arch%' } | Sort-Object version -Descending | Select-Object -First 1; if ($pkg) { $pkg.download_url } else { 'not_found' }" > "%%a_url.txt"
    set /p DEP_URL=<"%%a_url.txt"
    if not "!DEP_URL!"=="not_found" (
        curl -L "https:!DEP_URL!" -o "%%a.tar.bz2"
        7z x "%%a.tar.bz2" -so | 7z x -si -ttar -aoa > nul
    ) else (
        echo Warning: Could not find package %%a for architecture %arch%
    )
)

:: Download Python
echo Downloading Python %version%...
curl -L "https:%DOWNLOAD_URL%" -o "python.tar.bz2"
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Failed to download Python from Anaconda
    exit /b 1
)

:: Extract package
echo Extracting Python package...
7z x python.tar.bz2 -so | 7z x -si -ttar -aoa > nul
if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Failed to extract Python package
    exit /b 1
)

:: Create version directory
mkdir "%version_path%\%version%"

:: Copy files maintaining directory structure
echo Copying files to final location...
xcopy /E /H /Y "Library\*" "%version_path%\%version%\Library\"
xcopy /E /H /Y "include\*" "%version_path%\%version%\include\"
xcopy /E /H /Y "DLLs\*" "%version_path%\%version%\DLLs\"
xcopy /E /H /Y "Lib\*" "%version_path%\%version%\Lib\"
xcopy /E /H /Y "libs\*" "%version_path%\%version%\libs\"
xcopy /E /H /Y "Scripts\*" "%version_path%\%version%\Scripts\"
xcopy /E /H /Y "Tools\*" "%version_path%\%version%\Tools\"
xcopy /Y "python.exe" "%version_path%\%version%\"
xcopy /Y "pythonw.exe" "%version_path%\%version%\"

:: Copy all DLL files from root directory and Library/bin
for %%F in (*.dll) do (
    xcopy /Y "%%F" "%version_path%\%version%\"
)
if exist "Library\bin\*.dll" (
    xcopy /Y "Library\bin\*.dll" "%version_path%\%version%\"
)

if %ERRORLEVEL% neq 0 (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    rd /s /q "%version_path%\%version%"
    echo Failed to copy Python to final location
    exit /b 1
)

:: Clean up
cd "%cur_path%"
rd /s /q "%temp_dir%"

echo Python %version% has been installed successfully
echo Please run 'xvm python use %version%' to set it
exit /b 0 