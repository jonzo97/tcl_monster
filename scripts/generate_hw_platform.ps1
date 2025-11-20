###############################################################################
# TCL Monster: Hardware Platform Header Generator (Windows PowerShell)
#
# Usage: .\generate_hw_platform.ps1 <project_file> <smartdesign_name> [output_dir]
#
# Example:
#   .\generate_hw_platform.ps1 `
#       "C:\Projects\my_project\my_project.prjx" `
#       "MIV_RV32" `
#       ".\output"
#
# Description:
#   Windows native version of hw_platform.h automation workflow:
#   1. Opens Libero project
#   2. Exports memory map to JSON
#   3. Parses JSON and generates hw_platform.h
###############################################################################

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectFile,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$SmartDesignName,

    [Parameter(Mandatory=$false, Position=2)]
    [string]$OutputDir = "."
)

###############################################################################
# CONFIGURATION - Auto-detect or set manually
###############################################################################

# Libero installation path - auto-detect or override
$LiberoPath = $env:LIBERO_PATH
if (-not $LiberoPath) {
    $CommonPaths = @(
        "C:\Microchip\Libero_SoC_v2024.2\Designer\bin\libero.exe",
        "C:\Microchip\Libero_SoC_v2024.1\Designer\bin\libero.exe",
        "C:\Microchip\Libero_SoC_v2024.2\Designer\bin\Libero.exe",
        "C:\Microchip\Libero_SoC_v2024.1\Designer\bin\Libero.exe"
    )

    foreach ($path in $CommonPaths) {
        if (Test-Path $path) {
            $LiberoPath = $path
            break
        }
    }

    if (-not $LiberoPath) {
        Write-Host "ERROR: Could not find Libero installation" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please set LIBERO_PATH environment variable:"
        Write-Host '  $env:LIBERO_PATH = "C:\Microchip\Libero_SoC_v2024.2\Designer\bin\libero.exe"'
        Write-Host ""
        Write-Host "Or edit this script and set `$LiberoPath manually"
        exit 1
    }
}

# Python interpreter
$Python = if (Get-Command python -ErrorAction SilentlyContinue) { "python" }
          elseif (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" }
          else { $null }

if (-not $Python) {
    Write-Host "ERROR: Python not found in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.6+ and add to PATH"
    exit 1
}

###############################################################################
# Validate inputs
###############################################################################

if (-not (Test-Path $ProjectFile)) {
    Write-Host "ERROR: Project file not found: $ProjectFile" -ForegroundColor Red
    exit 1
}

# Create output directory if needed
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "========================================"
Write-Host "TCL Monster: hw_platform.h Generator"
Write-Host "========================================"
Write-Host "Project: $ProjectFile"
Write-Host "SmartDesign: $SmartDesignName"
Write-Host "Output Directory: $OutputDir"
Write-Host ""

###############################################################################
# Setup paths
###############################################################################

# Get absolute paths
$ProjectFileAbs = (Resolve-Path $ProjectFile).Path
$OutputDirAbs = (Resolve-Path $OutputDir).Path

# Create temp directory
$TempDir = Join-Path $env:TEMP "hw_platform_$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir | Out-Null

$MemoryMapJson = Join-Path $TempDir "memory_map.json"
$HwPlatformH = Join-Path $OutputDirAbs "hw_platform.h"

# Find scripts relative to this script's location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = $null
$ExportScript = $null

# Try to find Python script
$PythonScriptPaths = @(
    (Join-Path $ScriptDir "generate_hw_platform.py"),
    (Join-Path $ScriptDir "..\scripts\generate_hw_platform.py"),
    "scripts\generate_hw_platform.py"
)

foreach ($path in $PythonScriptPaths) {
    if (Test-Path $path) {
        $PythonScript = (Resolve-Path $path).Path
        break
    }
}

if (-not $PythonScript) {
    Write-Host "ERROR: Could not find generate_hw_platform.py" -ForegroundColor Red
    Write-Host "Searched in:"
    foreach ($path in $PythonScriptPaths) {
        Write-Host "  $path"
    }
    exit 1
}

###############################################################################
# Step 1: Export memory map from Libero
###############################################################################

Write-Host "[1/3] Exporting memory map from Libero..." -ForegroundColor Yellow

# Create inline TCL script for export
$TclWrapper = Join-Path $TempDir "export_wrapper.tcl"
$TclContent = @"
# Open project
puts "========================================="
puts "TCL Monster: Memory Map Export"
puts "========================================="
puts "Opening project..."
open_project -file {$ProjectFileAbs}

puts "Project opened successfully"
puts ""

# Open SmartDesign
puts "Opening SmartDesign: $SmartDesignName"
if {[catch {open_smartdesign -sd_name $SmartDesignName} err]} {
    puts "ERROR: Could not open SmartDesign '$SmartDesignName'"
    puts "  Make sure the design exists and project is open"
    close_project
    exit 1
}

puts "SmartDesign opened successfully"
puts ""

# Export memory map to JSON
puts "Exporting memory map to JSON..."
if {[catch {export_memory_map -sd_name {$SmartDesignName} -file {$MemoryMapJson} -format {}} err]} {
    puts "ERROR: Failed to export memory map"
    puts "  Error: `$err"
    puts ""
    puts "NOTE: Memory map export requires bus fabric connections (AXI, AHB, APB)"
    puts "      If your design doesn't have initiator/target connections, this will fail"
    close_project
    exit 1
}

puts ""
puts "SUCCESS: Memory map exported"
puts "Output file: $MemoryMapJson"
puts ""

# Close project
puts "Closing project..."
close_project

puts "========================================="
puts "Export complete!"
puts "========================================="
exit 0
"@

$TclContent | Out-File -FilePath $TclWrapper -Encoding ASCII

# Run Libero in batch mode
Write-Host "  Using Libero: $LiberoPath"
$LiberoLog = Join-Path $TempDir "libero.log"
& $LiberoPath "SCRIPT:$TclWrapper" > $LiberoLog 2>&1

# Wait for Libero to complete and file system to sync
Start-Sleep -Seconds 2

if (-not (Test-Path $MemoryMapJson)) {
    Write-Host "ERROR: Memory map export failed" -ForegroundColor Red
    Write-Host "Check log: $LiberoLog"
    Get-Content $LiberoLog
    exit 1
}

Write-Host "  Success: Memory map exported" -ForegroundColor Green

###############################################################################
# Step 2: Generate hw_platform.h
###############################################################################

Write-Host "[2/3] Generating hw_platform.h..." -ForegroundColor Yellow

& $Python $PythonScript $MemoryMapJson $HwPlatformH

if (-not (Test-Path $HwPlatformH)) {
    Write-Host "ERROR: Header generation failed" -ForegroundColor Red
    exit 1
}

Write-Host "  Success: Header file generated" -ForegroundColor Green

###############################################################################
# Step 3: Summary
###############################################################################

Write-Host ""
Write-Host "[3/3] Summary" -ForegroundColor Yellow
Write-Host "  Generated: $HwPlatformH"
Write-Host ""
Write-Host "SUCCESS!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review $HwPlatformH"
Write-Host "  2. Update SYS_CLK_FREQ if needed"
Write-Host "  3. Copy to firmware project:"
Write-Host "     Copy-Item $HwPlatformH <project>\boards\<board>\"
Write-Host ""

# Cleanup temp directory
Remove-Item -Recurse -Force $TempDir
