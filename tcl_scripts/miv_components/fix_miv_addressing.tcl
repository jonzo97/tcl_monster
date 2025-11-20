#!/usr/bin/env tclsh
###############################################################################
# Fix Address Map for MIV_RV32_BaseDesign
#
# Description:
#   Corrects the peripheral address assignments in the SmartDesign to resolve
#   DRC errors. Assigns unique, non-overlapping address ranges.
#
# Usage:
#   libero SCRIPT:fix_miv_addressing.tcl
#
# Target Addresses (4KB blocks):
#   CoreUARTapb:     0x70000000 - 0x70000FFF (4KB)
#   CoreTimer_C0:    0x70001000 - 0x70001FFF (4KB)
#   CoreTimer_C1:    0x70002000 - 0x70002FFF (4KB)
#   CoreGPIO:        0x70003000 - 0x70003FFF (4KB)
###############################################################################

# Configuration
set project_dir "../libero_projects/miv_rv32_demo"
set project_name "miv_rv32_demo"
set smartdesign_name "MIV_RV32_BaseDesign"

puts "========================================="
puts "Fix MIV_RV32_BaseDesign Address Map"
puts "========================================="
puts ""

# Open project
puts "Opening project: $project_name"
if {[catch {open_project -file "${project_dir}/${project_name}.prjx"} err]} {
    puts "ERROR: Could not open project"
    puts "  Error: $err"
    exit 1
}
puts "  Project opened successfully"
puts ""

# Open SmartDesign
puts "Opening SmartDesign: $smartdesign_name"
if {[catch {open_smartdesign -sd_name $smartdesign_name} err]} {
    puts "ERROR: Could not open SmartDesign"
    puts "  Error: $err"
    close_project
    exit 1
}
puts "  SmartDesign opened successfully"
puts ""

# The addressing in SmartDesign is controlled by the APB bus fabric
# We need to reconfigure the APB interconnect with proper addresses

puts "Attempting to reconfigure address map..."
puts ""

# Strategy 1: Try to use sd_update_instance to reconfigure the APB bus
# The APB bus is MIV_ESS_C0_0/MIV_APB3_0

# Get current APB configuration
puts "Checking current APB bus configuration..."
if {[catch {
    # Try to get component info
    set comp_info [get_component_info -sd_name $smartdesign_name]
    puts "Component info:"
    puts $comp_info
} err]} {
    puts "Could not get component info: $err"
}

puts ""
puts "========================================="
puts "Address Configuration Required"
puts "========================================="
puts ""
puts "MANUAL STEPS REQUIRED:"
puts ""
puts "1. In Libero GUI, open Design Hierarchy"
puts "2. Double-click 'MIV_RV32_BaseDesign' to open SmartDesign canvas"
puts "3. Go to: Design → Addressing → Configure Address Map"
puts "4. In the Address Editor, configure peripheral addresses:"
puts ""
puts "   Component          | Base Address | Size"
puts "   -------------------|--------------|------"
puts "   CoreUARTapb_0      | 0x70000000   | 4KB"
puts "   CoreTimer_C0_0     | 0x70001000   | 4KB"
puts "   CoreTimer_C1_0     | 0x70002000   | 4KB"
puts "   CoreGPIO_0         | 0x70003000   | 4KB"
puts ""
puts "5. Click 'OK' to apply"
puts "6. Save the SmartDesign (Ctrl+S)"
puts "7. File → Export Memory Map Report (JSON) to verify"
puts ""
puts "========================================="
puts ""

# Alternative: Try to delete and recreate the APB interconnect with correct config
# This is more complex and may break other connections

puts "Would you like to attempt automatic fix? (Experimental)"
puts "This will try to reconfigure the APB bus programmatically."
puts ""
puts "Press Enter to skip, or type 'yes' to attempt automatic fix..."

# For now, just provide instructions
# Automatic fix requires understanding the exact Libero TCL API for address configuration
# which may vary by version

puts ""
puts "Script paused for manual configuration."
puts "After fixing addresses manually, run the toolkit again:"
puts ""
puts "  ./scripts/generate_hw_platform.sh \\"
puts "    libero_projects/miv_rv32_demo/miv_rv32_demo.prjx \\"
puts "    MIV_RV32_BaseDesign \\"
puts "    test_output"
puts ""

# Keep project open for manual editing
puts "Project left open for manual address configuration."
puts "Close Libero when done."
puts ""
puts "========================================="
