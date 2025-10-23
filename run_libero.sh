#!/bin/bash
# =============================================================================
# Libero TCL Script Execution Helper
# Runs Libero TCL scripts from WSL command line
# =============================================================================

LIBERO_EXE="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe"

if [ $# -eq 0 ]; then
    echo "Usage: ./run_libero.sh <tcl_script> [SCRIPT|SCRIPT_ARGS]"
    echo ""
    echo "Examples:"
    echo "  ./run_libero.sh tcl_scripts/create_project.tcl SCRIPT"
    echo "  ./run_libero.sh tcl_scripts/build_design.tcl SCRIPT_ARGS"
    echo ""
    echo "Modes:"
    echo "  SCRIPT       - Run in batch mode (default)"
    echo "  SCRIPT_ARGS  - Run with arguments"
    exit 1
fi

TCL_SCRIPT="$1"
MODE="${2:-SCRIPT}"

if [ ! -f "$TCL_SCRIPT" ]; then
    echo "Error: TCL script not found: $TCL_SCRIPT"
    exit 1
fi

# Convert WSL path to Windows path
WIN_PATH=$(wslpath -w "$(realpath "$TCL_SCRIPT")")

echo "=============================================="
echo "Running Libero TCL Script"
echo "Script: $TCL_SCRIPT"
echo "Windows Path: $WIN_PATH"
echo "Mode: $MODE"
echo "=============================================="

"$LIBERO_EXE" "$MODE:$WIN_PATH"
