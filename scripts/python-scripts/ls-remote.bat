@echo off
setlocal enabledelayedexpansion

:: Set Python download URL
set "PYTHON_URL=https://www.python.org/ftp/python/"

:: Use curl to fetch the directory listing
curl -s %PYTHON_URL% | findstr /i "href" | findstr /i /R "[0-9]\.[0-9]\.[0-9]" > temp.txt

:: Process and display versions
for /f "tokens=2 delims=<>" %%a in (temp.txt) do (
    set "version=%%a"
    set "version=!version:/=!"
    echo !version!
)

:: Clean up
del temp.txt

endlocal
