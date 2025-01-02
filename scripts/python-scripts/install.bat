@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"
set "cur_path=%CD%"

:: Check arguments
if "%~1"=="" (
    echo Usage: xvm python install ^<version^>
    exit /b 1
)

:: Parse arguments
set "version=%~1"

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
powershell -ExecutionPolicy Bypass -Command "$json = Get-Content 'package_info.json' | ConvertFrom-Json; $pkg = $json | Where-Object { $_.version -eq '%version%' -and $_.attrs.subdir -eq 'win-64' } | Select-Object -First 1; if ($pkg) { $pkg.download_url; $pkg.attrs.depends | ForEach-Object { $_ -replace ' .*','' } | ConvertTo-Json } else { 'not_found' }" > package_info.txt

set /p DOWNLOAD_URL=<package_info.txt
if "%DOWNLOAD_URL%"=="not_found" (
    cd "%cur_path%"
    rd /s /q "%temp_dir%"
    echo Python version %version% not found in Anaconda repository
    exit /b 1
)

:: Download and install dependencies
echo Installing dependencies...
for /f "tokens=* usebackq" %%a in (`powershell -ExecutionPolicy Bypass -Command "Get-Content package_info.txt | Select-Object -Skip 1 | ConvertFrom-Json"`) do (
    echo Installing %%a...
    :: Get package info
    curl -L "https://api.anaconda.org/package/anaconda/%%a/files" -o "%%a_info.json"
    :: Get latest win-64 version download URL
    powershell -ExecutionPolicy Bypass -Command "$json = Get-Content '%%a_info.json' | ConvertFrom-Json; $pkg = $json | Where-Object { $_.attrs.subdir -eq 'win-64' } | Sort-Object version -Descending | Select-Object -First 1; if ($pkg) { $pkg.download_url } else { 'not_found' }" > "%%a_url.txt"
    set /p DEP_URL=<"%%a_url.txt"
    if not "!DEP_URL!"=="not_found" (
        curl -L "https:!DEP_URL!" -o "%%a.tar.bz2"
        7z x "%%a.tar.bz2" -so | 7z x -si -ttar -aoa > nul
    ) else (
        echo Warning: Could not find package %%a
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