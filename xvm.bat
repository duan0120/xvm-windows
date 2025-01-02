@echo off
setlocal EnableDelayedExpansion

:: Set XVM_ROOT if not set
if "%XVM_ROOT%"=="" (
    set "XVM_ROOT=%USERPROFILE%\.xvm"
)

:: Create necessary directories
if not exist "%XVM_ROOT%" mkdir "%XVM_ROOT%"
if not exist "%XVM_ROOT%\versions" mkdir "%XVM_ROOT%\versions"

:: Set version
if not exist "%XVM_ROOT%\version" (
    echo 1.0.0> "%XVM_ROOT%\version"
)
set /p XVM_VERSION=<"%XVM_ROOT%\version"

:: Get command line arguments
set "command=%1"
set "subcommand=%2"

:: Process commands
if "%command%"=="" goto :show_usage
if "%command%"=="--version" goto :show_version
if "%command%"=="-v" goto :show_version
if "%command%"=="--help" goto :show_usage
if "%command%"=="-h" goto :show_usage
if "%command%"=="help" goto :show_help
if "%command%"=="node" goto :node_command
if "%command%"=="go" goto :go_command
if "%command%"=="python" goto :python_command
goto :invalid_command

:show_version
echo xvm version %XVM_VERSION%
exit /b 0

:show_usage
echo Usage: xvm ^<command^> [options]
echo Commands:
echo   -v, --version  Show the version of xvm
echo   -h, --help     Show help for xvm
echo   node           Manage node versions
echo   go             Manage go versions
echo   python         Manage python versions
echo   help           Show help for a command
echo.
echo See 'xvm help ^<command^>' for information on a specific command.
exit /b 0

:show_help
if "%subcommand%"=="" goto :show_usage
if exist "%XVM_ROOT%\scripts\%subcommand%.bat" (
    call "%XVM_ROOT%\scripts\%subcommand%.bat" --help
) else (
    goto :show_usage
)
exit /b 0

:node_command
set "args="
for /f "tokens=1,* delims= " %%a in ("%*") do set "args=%%b"
call "%XVM_ROOT%\scripts\node.bat" %args%
exit /b %ERRORLEVEL%

:go_command
set "args="
for /f "tokens=1,* delims= " %%a in ("%*") do set "args=%%b"
call "%XVM_ROOT%\scripts\go.bat" %args%
exit /b %ERRORLEVEL%

:python_command
set "args="
for /f "tokens=1,* delims= " %%a in ("%*") do set "args=%%b"
call "%XVM_ROOT%\scripts\python.bat" %args%
exit /b %ERRORLEVEL%

:invalid_command
echo Error: Invalid command: %command%
exit /b 1 