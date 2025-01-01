@echo off
setlocal EnableDelayedExpansion

:: 如果没有参数，直接退出
if "%1"=="" exit /b 0

:: 调用对应的函数
call :%*
exit /b %ERRORLEVEL%

:check_curl
where curl >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Please install curl first.
    exit /b 1
)
exit /b 0

:check_jq
where jq >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Please install jq first.
    exit /b 1
)
exit /b 0

:check_git
where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Please install git first.
    exit /b 1
)
exit /b 0 