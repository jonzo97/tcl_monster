@echo off
REM ############################################################################
REM TCL Monster: hw_platform.h Generator (Windows Batch Wrapper)
REM
REM Usage: generate_hw_platform.bat <project_file> <smartdesign_name> [output_dir]
REM
REM Example:
REM   generate_hw_platform.bat ^
REM       "C:\Projects\my_project\my_project.prjx" ^
REM       "MIV_RV32" ^
REM       ".\output"
REM ############################################################################

setlocal

REM Check if PowerShell is available
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell not found
    echo This script requires PowerShell
    exit /b 1
)

REM Get script directory
set SCRIPT_DIR=%~dp0

REM Call PowerShell script with all arguments
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%generate_hw_platform.ps1" %*

endlocal
