@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\go"

if not exist "%version_path%" mkdir "%version_path%"

set "COMMAND=%~1"
shift

:: 构建剩余参数
set "args="
:parse_args
if "%~1" neq "" (
    if not defined args (
        set "args=%~1"
    ) else (
        set "args=%args% %~1"
    )
    shift
    goto :parse_args
)

if "%COMMAND%"=="" goto :show_usage
if "%COMMAND%"=="--help" goto :show_usage
if "%COMMAND%"=="-h" goto :show_usage
if "%COMMAND%"=="list" goto :list
if "%COMMAND%"=="ls" goto :list
if "%COMMAND%"=="ls-remote" (
    call "%XVM_ROOT%\scripts\function\tools.bat" check_git
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
    goto :ls_remote
)
if "%COMMAND%"=="install" (
    call "%XVM_ROOT%\scripts\function\tools.bat" check_curl
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
    goto :install
)
if "%COMMAND%"=="uninstall" goto :uninstall
if "%COMMAND%"=="use" goto :use
echo "Unrecognized command line argument: '%COMMAND%'"
exit /b 1

:show_usage
echo Usage: xvm go ^<command^> [options]
echo Commands:
echo   -h, --help     Show help for xvm go
echo   list           List all installed versions of go
echo   ls-remote      List all remote versions of go
echo   install        Install a specific version of go
echo   uninstall      Uninstall a specific version of go
echo   use            Set a specific version as active
exit /b 1

:list
call "%XVM_ROOT%\scripts\go-scripts\list.bat" %args%
exit /b %ERRORLEVEL%

:ls_remote
call "%XVM_ROOT%\scripts\go-scripts\ls-remote.bat" %args%
exit /b %ERRORLEVEL%

:install
call "%XVM_ROOT%\scripts\go-scripts\install.bat" %args%
exit /b %ERRORLEVEL%

:uninstall
call "%XVM_ROOT%\scripts\go-scripts\uninstall.bat" %args%
exit /b %ERRORLEVEL% 

:use
call "%XVM_ROOT%\scripts\go-scripts\use.bat" %args%
exit /b %ERRORLEVEL%