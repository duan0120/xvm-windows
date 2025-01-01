@echo off
setlocal enabledelayedexpansion

set "LTS_ONLY=false"
if "%1"=="--lts" set "LTS_ONLY=true"

set "PS_CMD=$data = Invoke-WebRequest -Uri 'https://nodejs.org/dist/index.json' -UseBasicParsing; "
set "PS_CMD=!PS_CMD!$json = $data.Content | ConvertFrom-Json; "

if "!LTS_ONLY!"=="true" (
    set "PS_CMD=!PS_CMD!$json | Where-Object { $_.lts -ne $false } | "
) else (
    set "PS_CMD=!PS_CMD!$json | "
)

set "PS_CMD=!PS_CMD!Sort-Object { [version]($_.version -replace 'v', '') } | "
set "PS_CMD=!PS_CMD!ForEach-Object { "
set "PS_CMD=!PS_CMD!    if ($_.lts -eq $false) { "
set "PS_CMD=!PS_CMD!        $_.version "
set "PS_CMD=!PS_CMD!    } else { "
set "PS_CMD=!PS_CMD!        $_.version + [char]9 + '(lts: ' + $_.lts + ')' "
set "PS_CMD=!PS_CMD!    } "
set "PS_CMD=!PS_CMD!}"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%PS_CMD%"
