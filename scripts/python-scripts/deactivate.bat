@echo off
setlocal EnableDelayedExpansion

:: Check if we're in a virtual environment
if not defined _XVM_PYTHON_ACTIVE (
    echo Error: No Python environment is currently active
    exit /b 1
)

:: Get the current alias name for the message
set "current_alias=%_XVM_PYTHON_ALIAS%"

:: Restore original environment
endlocal & (
    set "PATH=%_XVM_ORIGINAL_PATH%"
    set "PROMPT=%_XVM_ORIGINAL_PROMPT%"
    set "PYTHONHOME="
    set "PYTHONPATH="
    set "VIRTUAL_ENV="
    set "_XVM_PYTHON_ACTIVE="
    set "_XVM_PYTHON_ALIAS="
    set "_XVM_PYTHON_CONFIG="
    set "_XVM_ORIGINAL_PATH="
    set "_XVM_ORIGINAL_PROMPT="
    echo Deactivated Python environment '%current_alias%'
)
