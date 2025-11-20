#!/bin/bash
###############################################################################
# TCL Monster: Complete hw_platform.h Generation Workflow
#
# Usage: ./scripts/generate_hw_platform.sh <project_file> <smartdesign_name>
#
# Example:
#   ./scripts/generate_hw_platform.sh \
#       ./projects/my_project/my_project.prjx \
#       MIV_RV32
#
# Description:
#   Complete automation workflow:
#   1. Opens Libero project
#   2. Exports memory map to JSON
#   3. Parses JSON and generates hw_platform.h
###############################################################################

###############################################################################
# CONFIGURATION - MODIFY THESE PATHS FOR YOUR INSTALLATION
###############################################################################

# Libero installation path
# Default: Auto-detect common installation locations
# Override with: export LIBERO_PATH="/path/to/libero.exe"
if [ -z "$LIBERO_PATH" ]; then
    # Try common installation paths (WSL) - check both Libero.exe and libero.exe (case varies)
    if [ -f "/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/Libero.exe" ]; then
        LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/Libero.exe"
    elif [ -f "/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe" ]; then
        LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe"
    elif [ -f "/mnt/c/Microchip/Libero_SoC_v2024.1/Designer/bin/Libero.exe" ]; then
        LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.1/Designer/bin/Libero.exe"
    elif [ -f "/mnt/c/Microchip/Libero_SoC_v2024.1/Designer/bin/libero.exe" ]; then
        LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.1/Designer/bin/libero.exe"
    # Try Linux paths
    elif [ -f "$HOME/Microchip/Libero_SoC_v2024.2/Designer/bin/libero" ]; then
        LIBERO_PATH="$HOME/Microchip/Libero_SoC_v2024.2/Designer/bin/libero"
    else
        echo "ERROR: Could not find Libero installation"
        echo ""
        echo "Please set LIBERO_PATH environment variable:"
        echo "  export LIBERO_PATH=\"/path/to/Designer/bin/Libero.exe\""
        echo ""
        echo "Or edit this script and set LIBERO_PATH manually at line ~30"
        exit 1
    fi
fi

# Python interpreter (usually python3, sometimes python)
PYTHON="${PYTHON:-python3}"

###############################################################################
# END CONFIGURATION
###############################################################################

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ $# -lt 2 ]; then
    echo -e "${RED}ERROR: Missing required arguments${NC}"
    echo ""
    echo "Usage:"
    echo "  $0 <project_file> <smartdesign_name> [output_dir] [sys_clk_freq_hz]"
    echo ""
    echo "Arguments:"
    echo "  project_file      - Libero project file (.prjx)"
    echo "  smartdesign_name  - SmartDesign component name"
    echo "  output_dir        - Output directory (default: current directory)"
    echo "  sys_clk_freq_hz   - System clock frequency in Hz (default: 50000000)"
    echo ""
    echo "Examples:"
    echo "  $0 ./my_project.prjx MIV_RV32"
    echo "  $0 ./my_project.prjx MIV_RV32 ./output"
    echo "  $0 ./my_project.prjx MIV_RV32 ./output 100000000"
    echo ""
    exit 1
fi

PROJECT_FILE="$1"
SMARTDESIGN_NAME="$2"
OUTPUT_DIR="${3:-.}"  # Default to current directory
SYS_CLK_FREQ_MANUAL="${4:-}"  # Optional manual override

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo -e "${RED}ERROR: Project file not found: $PROJECT_FILE${NC}"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Determine clock frequency
if [ -z "$SYS_CLK_FREQ_MANUAL" ]; then
    # No clock specified - use 50 MHz default with warning
    SYS_CLK_FREQ=50000000
    echo -e "${YELLOW}WARNING: Using default 50 MHz clock frequency${NC}"
    echo -e "${YELLOW}         Verify this matches your design!${NC}"
    echo -e "${YELLOW}         Override: $0 ... <output_dir> <clock_hz>${NC}"
    echo ""
else
    # User specified clock frequency
    SYS_CLK_FREQ="$SYS_CLK_FREQ_MANUAL"
fi

echo "========================================"
echo "TCL Monster: hw_platform.h Generator"
echo "========================================"
echo "Project: $PROJECT_FILE"
echo "SmartDesign: $SMARTDESIGN_NAME"
echo "Output Directory: $OUTPUT_DIR"
echo "System Clock: $SYS_CLK_FREQ Hz ($((SYS_CLK_FREQ / 1000000)) MHz)"
echo ""

# Create temporary directory for intermediate files
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

MEMORY_MAP_JSON="$TEMP_DIR/memory_map.json"
HW_PLATFORM_H="$OUTPUT_DIR/hw_platform.h"

# Convert paths to Windows format for Libero
# Get absolute paths first
ABS_PROJECT_FILE="$(readlink -f "$PROJECT_FILE")"

# Find export script relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/export_memory_map.tcl" ]; then
    # Running from toolkit package (same directory)
    ABS_EXPORT_SCRIPT="$(readlink -f "$SCRIPT_DIR/export_memory_map.tcl")"
elif [ -f "$SCRIPT_DIR/../scripts/export_memory_map.tcl" ]; then
    # Running from tcl_monster root
    ABS_EXPORT_SCRIPT="$(readlink -f "$SCRIPT_DIR/../scripts/export_memory_map.tcl")"
elif [ -f "scripts/export_memory_map.tcl" ]; then
    # Fallback: relative to current directory
    ABS_EXPORT_SCRIPT="$(readlink -f scripts/export_memory_map.tcl)"
else
    echo -e "${RED}ERROR: Could not find export_memory_map.tcl${NC}"
    echo "Searched in:"
    echo "  $SCRIPT_DIR/export_memory_map.tcl"
    echo "  $SCRIPT_DIR/../scripts/export_memory_map.tcl"
    echo "  scripts/export_memory_map.tcl"
    exit 1
fi

# Convert to Windows paths
WIN_PROJECT_FILE=$(wslpath -w "$ABS_PROJECT_FILE")
WIN_EXPORT_SCRIPT=$(wslpath -w "$ABS_EXPORT_SCRIPT")
WIN_MEMORY_MAP_JSON=$(wslpath -w "$MEMORY_MAP_JSON")
WIN_TCL_WRAPPER=$(wslpath -w "$TEMP_DIR/export_wrapper.tcl")

# Step 1: Export memory map from Libero
echo -e "${YELLOW}[1/3] Exporting memory map from Libero...${NC}"

# Create TCL script to open project and export
# Note: Inline the export logic instead of sourcing the export script
cat > "$TEMP_DIR/export_wrapper.tcl" << 'EOFTCL'
# Open project
puts "========================================="
puts "TCL Monster: Memory Map Export"
puts "========================================="
puts "Opening project..."
open_project -file {PROJECT_FILE_PLACEHOLDER}

puts "Project opened successfully"
puts ""

# Open SmartDesign
puts "Opening SmartDesign: SMARTDESIGN_PLACEHOLDER"
if {[catch {open_smartdesign -sd_name SMARTDESIGN_PLACEHOLDER} err]} {
    puts "ERROR: Could not open SmartDesign 'SMARTDESIGN_PLACEHOLDER'"
    puts "  Make sure the design exists and project is open"
    close_project
    exit 1
}

puts "SmartDesign opened successfully"
puts ""

# Export memory map to JSON
puts "Exporting memory map to JSON..."
if {[catch {export_memory_map -sd_name {SMARTDESIGN_PLACEHOLDER} -file {MEMORY_MAP_PLACEHOLDER} -format {}} err]} {
    puts "ERROR: Failed to export memory map"
    puts "  Error: $err"
    puts ""
    puts "NOTE: Memory map export requires bus fabric connections (AXI, AHB, APB)"
    puts "      If your design doesn't have initiator/target connections, this will fail"
    close_project
    exit 1
}

puts ""
puts "SUCCESS: Memory map exported"
puts "Output file: MEMORY_MAP_PLACEHOLDER"
puts ""

# Close project
puts "Closing project..."
close_project

puts "========================================="
puts "Export complete!"
puts "========================================="
exit 0
EOFTCL

# Replace placeholders with actual Windows paths (preserving backslashes)
sed -i "s|PROJECT_FILE_PLACEHOLDER|${WIN_PROJECT_FILE//\\/\\\\}|g" "$TEMP_DIR/export_wrapper.tcl"
sed -i "s|MEMORY_MAP_PLACEHOLDER|${WIN_MEMORY_MAP_JSON//\\/\\\\}|g" "$TEMP_DIR/export_wrapper.tcl"
sed -i "s|SMARTDESIGN_PLACEHOLDER|${SMARTDESIGN_NAME}|g" "$TEMP_DIR/export_wrapper.tcl"

# Run Libero in batch mode
echo "  Using Libero: $LIBERO_PATH"
"$LIBERO_PATH" \
    "SCRIPT:${WIN_TCL_WRAPPER}" \
    > "$TEMP_DIR/libero.log" 2>&1

if [ ! -f "$MEMORY_MAP_JSON" ]; then
    echo -e "${RED}ERROR: Memory map export failed${NC}"
    echo "Check log: $TEMP_DIR/libero.log"
    cat "$TEMP_DIR/libero.log"
    exit 1
fi

echo -e "${GREEN}  ✓ Memory map exported${NC}"

# Step 2: Generate hw_platform.h
echo -e "${YELLOW}[2/3] Generating hw_platform.h...${NC}"

# Find Python script relative to this script's location
if [ -f "$SCRIPT_DIR/generate_hw_platform.py" ]; then
    PYTHON_SCRIPT="$SCRIPT_DIR/generate_hw_platform.py"
elif [ -f "./scripts/generate_hw_platform.py" ]; then
    PYTHON_SCRIPT="./scripts/generate_hw_platform.py"
else
    echo -e "${RED}ERROR: Could not find generate_hw_platform.py${NC}"
    exit 1
fi

"$PYTHON" "$PYTHON_SCRIPT" "$MEMORY_MAP_JSON" "$HW_PLATFORM_H" "$SYS_CLK_FREQ"

if [ ! -f "$HW_PLATFORM_H" ]; then
    echo -e "${RED}ERROR: Header generation failed${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Header file generated${NC}"

# Step 3: Summary
echo ""
echo -e "${YELLOW}[3/3] Summary${NC}"
echo "  Generated: $HW_PLATFORM_H"
echo ""
echo -e "${GREEN}SUCCESS!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review $HW_PLATFORM_H"
echo "  2. Copy to firmware project:"
echo "     cp $HW_PLATFORM_H <project>/boards/<board>/"
echo ""
echo "Note: SYS_CLK_FREQ is configured to $SYS_CLK_FREQ Hz"
echo "      To change, re-run with: $0 ... $((SYS_CLK_FREQ + 1000000))"
echo ""
