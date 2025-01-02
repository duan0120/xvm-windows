@echo off
setlocal EnableDelayedExpansion

set "version_path=%XVM_ROOT%\versions\python"

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
if "%COMMAND%"=="ls-remote" goto :ls_remote
if "%COMMAND%"=="install" (
    call "%XVM_ROOT%\scripts\function\tools.bat" check_curl
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
    call "%XVM_ROOT%\scripts\function\tools.bat" check_7z
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
    goto :install
)
if "%COMMAND%"=="uninstall" goto :uninstall
if "%COMMAND%"=="use" goto :use
if "%COMMAND%"=="activate" goto :activate
if "%COMMAND%"=="deactivate" goto :deactivate
echo "Unrecognized command line argument: '%COMMAND%'"
exit /b 1

:show_usage
echo Usage: xvm python ^<command^> [options]
echo Commands:
echo   -h, --help     Show help for xvm python
echo   list           List all installed versions of python
echo   ls-remote      List all remote versions of python
echo   install        Install a specific version of python
echo   uninstall      Uninstall a specific version of python
echo   use            Set a specific version as active
echo   activate       Activate a specific version
echo   deactivate     Deactivate the current version
exit /b 1

:list
call "%XVM_ROOT%\scripts\python-scripts\list.bat" %args%
exit /b %ERRORLEVEL%

:ls_remote
call "%XVM_ROOT%\scripts\python-scripts\ls-remote.bat" %args%
exit /b %ERRORLEVEL%

:install
call "%XVM_ROOT%\scripts\python-scripts\install.bat" %args%
exit /b %ERRORLEVEL%

:uninstall
call "%XVM_ROOT%\scripts\python-scripts\uninstall.bat" %args%
exit /b %ERRORLEVEL% 

:use
call "%XVM_ROOT%\scripts\python-scripts\use.bat" %args%
exit /b %ERRORLEVEL%

:activate
call "%XVM_ROOT%\scripts\python-scripts\activate.bat" %args%
exit /b %ERRORLEVEL%

:deactivate
call "%XVM_ROOT%\scripts\python-scripts\deactivate.bat"
exit /b %ERRORLEVEL%

