#!/bin/bash
# Instant FPGA - One-Command FPGA Project Generator
# Creates complete FPGA projects from templates in seconds
#
# Usage: ./create_instant_fpga.sh <board> <design>
#
# Examples:
#   ./create_instant_fpga.sh mpf300_eval led_blink
#   ./create_instant_fpga.sh beaglev_fire uart_echo
#   ./create_instant_fpga.sh mpf300_eval gpio_test
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              🚀 INSTANT FPGA - One-Command Generator 🚀            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check arguments
if [ "$#" -ne 2 ]; then
    echo -e "${RED}Usage: $0 <board> <design>${NC}"
    echo ""
    echo "Available boards:"
    echo "  mpf300_eval   - PolarFire MPF300 Evaluation Kit"
    echo "  beaglev_fire  - BeagleV-Fire (MPFS025T PolarFire SoC)"
    echo ""
    echo "Available designs:"
    echo "  led_blink     - Simple LED counter/blinker"
    echo "  uart_echo     - UART echo loopback"
    echo "  gpio_test     - GPIO input/output test"
    echo ""
    echo "Examples:"
    echo "  $0 mpf300_eval led_blink"
    echo "  $0 beaglev_fire uart_echo"
    echo ""
    exit 1
fi

BOARD=$1
DESIGN=$2

# Validate board
case $BOARD in
    mpf300_eval|beaglev_fire)
        ;;
    *)
        echo -e "${RED}Error: Unknown board '$BOARD'${NC}"
        echo "Supported boards: mpf300_eval, beaglev_fire"
        exit 1
        ;;
esac

# Validate design
case $DESIGN in
    led_blink|uart_echo|gpio_test)
        ;;
    *)
        echo -e "${RED}Error: Unknown design '$DESIGN'${NC}"
        echo "Supported designs: led_blink, uart_echo, gpio_test"
        exit 1
        ;;
esac

# Paths
TEMPLATE_DIR="templates/instant_designs/${DESIGN}"
PROJECT_NAME="${BOARD}_${DESIGN}_$(date +%Y%m%d_%H%M%S)"
PROJECT_DIR="libero_projects/instant/${PROJECT_NAME}"

echo -e "${GREEN}Configuration:${NC}"
echo "  Board:   $BOARD"
echo "  Design:  $DESIGN"
echo "  Project: $PROJECT_NAME"
echo ""

# Check if template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}Error: Template not found: $TEMPLATE_DIR${NC}"
    echo ""
    echo "Creating template directory structure..."
    mkdir -p "$TEMPLATE_DIR"
    echo ""
    echo -e "${YELLOW}Template needs to be created. See templates/instant_designs/README.md${NC}"
    exit 1
fi

# Create project directory
echo -e "${BLUE}[1/6]${NC} Creating project directory..."
mkdir -p "$PROJECT_DIR"
echo "      ✓ Created: $PROJECT_DIR"
echo ""

# Copy template files
echo -e "${BLUE}[2/6]${NC} Copying design template..."
cp -r "$TEMPLATE_DIR"/* "$PROJECT_DIR/"
echo "      ✓ HDL, constraints, and config files copied"
echo ""

# Generate board-specific TCL script
echo -e "${BLUE}[3/6]${NC} Generating Libero TCL script..."

# Read board configuration
case $BOARD in
    mpf300_eval)
        DEVICE_FAMILY="PolarFire"
        DEVICE_DIE="MPF300TS"
        DEVICE_PACKAGE="FCG1152"
        DEVICE_SPEED="-1"
        DEVICE_VOLTAGE="1.0"
        ;;
    beaglev_fire)
        DEVICE_FAMILY="PolarFireSoC"
        DEVICE_DIE="MPFS025T"
        DEVICE_PACKAGE="FCVG484"
        DEVICE_SPEED="STD"
        DEVICE_VOLTAGE="1.05"
        ;;
esac

# Generate TCL script
cat > "$PROJECT_DIR/create_and_build.tcl" << EOF
# Auto-generated Libero TCL script for Instant FPGA
# Project: $PROJECT_NAME
# Board:   $BOARD
# Design:  $DESIGN
# Generated: $(date)

puts "Creating project: $PROJECT_NAME"

# Create new project
new_project \\
    -location {$PROJECT_DIR} \\
    -name {$PROJECT_NAME} \\
    -hdl VERILOG \\
    -family $DEVICE_FAMILY \\
    -die $DEVICE_DIE \\
    -package $DEVICE_PACKAGE \\
    -speed $DEVICE_SPEED \\
    -die_voltage $DEVICE_VOLTAGE \\
    -part_range {EXT} \\
    -default_lib {work} \\
    -instantiate_in_smartdesign 1 \\
    -ondemand_build_dh 1 \\
    -use_enhanced_constraint_flow 1 \\
    -hdl_param_on 0

# Import HDL sources
puts "Importing HDL sources..."
set hdl_files [glob -directory {$PROJECT_DIR/hdl} *.v *.vhd 2>/dev/null]
if {[llength \$hdl_files] > 0} {
    import_files -convert_EDN_to_HDL 0 -library {work} -hdl_source \$hdl_files
}

# Build design hierarchy
build_design_hierarchy

# Find top module name from design
set top_module [file rootname [file tail [lindex \$hdl_files 0]]]
puts "Setting top module: \$top_module"

# Set root
configure_tool -name {SYNTHESIZE} -params {SYNPLIFY_OPTIONS:set_option -top_module \$top_module}
set_root -module {\${top_module}::work}

# Import constraints
puts "Importing constraints..."
if {[file exists {$PROJECT_DIR/constraint/io.pdc}]} {
    create_links -io_pdc {$PROJECT_DIR/constraint/io.pdc}
    organize_tool_files -tool {PLACEROUTE} -file {$PROJECT_DIR/constraint/io.pdc} \\
        -module {\${top_module}::work} -input_type {constraint}
}

if {[file exists {$PROJECT_DIR/constraint/timing.sdc}]} {
    create_links -sdc {$PROJECT_DIR/constraint/timing.sdc}
    organize_tool_files -tool {SYNTHESIZE} -file {$PROJECT_DIR/constraint/timing.sdc} \\
        -module {\${top_module}::work} -input_type {constraint}
    organize_tool_files -tool {PLACEROUTE} -file {$PROJECT_DIR/constraint/timing.sdc} \\
        -module {\${top_module}::work} -input_type {constraint}
}

# Save project
save_project

puts "✓ Project created successfully!"
puts ""

# Build flow
puts "════════════════════════════════════════════════════════════════"
puts "Starting build flow..."
puts "════════════════════════════════════════════════════════════════"

# Synthesis
puts ""
puts "[1/3] Running synthesis..."
run_tool -name {SYNTHESIZE}
puts "✓ Synthesis complete"

# Place & Route
puts ""
puts "[2/3] Running place and route..."
run_tool -name {PLACEROUTE}
puts "✓ Place and route complete"

# Generate programming file
puts ""
puts "[3/3] Generating bitstream..."
run_tool -name {GENERATEPROGRAMMINGFILE}
puts "✓ Bitstream generated"

# Save final project
save_project

puts ""
puts "════════════════════════════════════════════════════════════════"
puts "Build complete!"
puts "════════════════════════════════════════════════════════════════"

# Generate simple report
puts ""
puts "Resource Utilization:"
puts "  Design:  $DESIGN"
puts "  Device:  $DEVICE_DIE ($DEVICE_PACKAGE)"
puts ""
puts "Programming files:"
puts "  Location: designer/impl1/"
puts ""

# Close project
close_project
EOF

echo "      ✓ TCL script generated: create_and_build.tcl"
echo ""

# Run Libero
echo -e "${BLUE}[4/6]${NC} Running Libero synthesis and place & route..."
echo "      (This will take 2-10 minutes depending on design complexity)"
echo ""

if ./run_libero.sh "$PROJECT_DIR/create_and_build.tcl" SCRIPT; then
    echo ""
    echo -e "      ${GREEN}✓ Libero build successful!${NC}"
    echo ""
else
    echo ""
    echo -e "      ${RED}✗ Libero build failed${NC}"
    echo "      Check log: $PROJECT_DIR/*.log"
    exit 1
fi

# Generate reports
echo -e "${BLUE}[5/6]${NC} Extracting build reports..."

REPORTS_DIR="$PROJECT_DIR/reports"
mkdir -p "$REPORTS_DIR"

# Resource utilization
if [ -f "$PROJECT_DIR/designer/impl1"/*_utilization.txt ]; then
    cp "$PROJECT_DIR/designer/impl1"/*_utilization.txt "$REPORTS_DIR/resources.txt"
    echo "      ✓ Resource utilization report"
fi

# Timing summary
if [ -f "$PROJECT_DIR/designer/impl1"/*_timing_violations_report.txt ]; then
    cp "$PROJECT_DIR/designer/impl1"/*_timing_violations_report.txt "$REPORTS_DIR/timing.txt"
    echo "      ✓ Timing violations report"
fi

# Pin report
if [ -f "$PROJECT_DIR/designer/impl1"/*_pinrpt.txt ]; then
    cp "$PROJECT_DIR/designer/impl1"/*_pinrpt.txt "$REPORTS_DIR/pins.txt"
    echo "      ✓ Pin assignments report"
fi

echo ""

# Summary
echo -e "${BLUE}[6/6]${NC} Generating summary..."
cat > "$PROJECT_DIR/BUILD_SUMMARY.txt" << EOF
╔════════════════════════════════════════════════════════════════════╗
║                    INSTANT FPGA - Build Summary                     ║
╚════════════════════════════════════════════════════════════════════╝

Project:   $PROJECT_NAME
Board:     $BOARD
Design:    $DESIGN
Generated: $(date)

Device Configuration:
  Family:   $DEVICE_FAMILY
  Die:      $DEVICE_DIE
  Package:  $DEVICE_PACKAGE
  Speed:    $DEVICE_SPEED

Build Status: ✓ SUCCESS

Output Files:
  Project:     $PROJECT_DIR/$PROJECT_NAME.prjx
  Bitstream:   $PROJECT_DIR/designer/impl1/*.stp
  Reports:     $PROJECT_DIR/reports/

Next Steps:
  1. Review reports in: $PROJECT_DIR/reports/
  2. Program device with: designer/impl1/*.stp
  3. Test on hardware!

═══════════════════════════════════════════════════════════════════════
Generated with Instant FPGA - One-Command FPGA Development
═══════════════════════════════════════════════════════════════════════
EOF

cat "$PROJECT_DIR/BUILD_SUMMARY.txt"
echo ""

# Success!
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  🎉 INSTANT FPGA - SUCCESS! 🎉                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Your FPGA project is ready!${NC}"
echo ""
echo "Project location:"
echo "  $PROJECT_DIR"
echo ""
echo "What was automated:"
echo "  ✓ Project creation"
echo "  ✓ HDL source import"
echo "  ✓ Constraint association"
echo "  ✓ Synthesis"
echo "  ✓ Place & Route"
echo "  ✓ Bitstream generation"
echo "  ✓ Report extraction"
echo ""
echo "Program your device:"
echo "  FlashPro: Load $PROJECT_DIR/designer/impl1/*.stp"
echo ""
echo -e "${BLUE}Total time: ~2-10 minutes (fully automated!)${NC}"
echo ""
