@echo off
setlocal EnableDelayedExpansion

:: 创建临时文件
set "temp_file=%TEMP%\go_versions.txt"
if exist "%temp_file%" del "%temp_file%"

:: 获取所有标签
for /f "tokens=2 delims=	" %%i in ('git ls-remote --tags https://github.com/golang/go') do (
    set "tag=%%i"
    :: 从 refs/tags/ 中提取版本号
    set "version=!tag:refs/tags/=!"
    :: 只显示 go1.x.x 格式的版本号
    echo !version!| findstr /r "^go1\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
    if !ERRORLEVEL! equ 0 (
        :: 提取版本号并转换为可排序的格式 (例如: go1.2.3 -> 000002.000003)
        for /f "tokens=1,2,3 delims=." %%a in ("!version!") do (
            set "major=%%b"
            set "minor=%%c"
            :: 补齐到6位数
            set "padded_major=00000!major!"
            set "padded_minor=00000!minor!"
            set "padded_major=!padded_major:~-6!"
            set "padded_minor=!padded_minor:~-6!"
            echo !padded_major!.!padded_minor! !version!>>"%temp_file%"
        )
    )
)

:: 排序并只输出原始版本号
if exist "%temp_file%" (
    for /f "tokens=2" %%i in ('sort "%temp_file%"') do echo %%i
    del "%temp_file%"
)

exit /b 0 