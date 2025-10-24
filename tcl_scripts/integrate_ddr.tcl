# ==============================================================================
# TCL Monster - Integrate DDR4 Controller into MI-V Project
# ==============================================================================
#
# Purpose: Add PF_DDR4 to existing MI-V RV32 project and connect via AXI
# Usage:   ./run_libero.sh tcl_scripts/integrate_ddr.tcl SCRIPT
#
# Prerequisites: PF_DDR4_C0.tcl must exist in miv_components/
#
# ==============================================================================

set script_dir [file dirname [info script]]
set project_root [file dirname $script_dir]
set project_location "$project_root/libero_projects/miv_rv32_demo"
set project_file "$project_location/miv_rv32_demo.prjx"

proc print_msg {message} {
    puts "=================================================================================="
    puts $message
    puts "=================================================================================="
}

proc print_info {message} {
    puts "INFO: $message"
}

print_msg "Integrating DDR4 Controller into MI-V Project"

# ==============================================================================
# Step 1: Open existing project
# ==============================================================================

print_info "Opening project: $project_file"
open_project $project_file

# ==============================================================================
# Step 2: Instantiate PF_DDR4 component
# ==============================================================================

print_info "Instantiating PF_DDR4 component..."

# Source the exported component TCL
source "$script_dir/miv_components/PF_DDR4_C0.tcl"

print_info "PF_DDR4_C0 component created successfully"

# ==============================================================================
# Step 3: Add DDR4 to SmartDesign
# ==============================================================================

print_info "Opening SmartDesign: MIV_RV32_BaseDesign"

# Open the SmartDesign
open_smartdesign -sd_name {MIV_RV32_BaseDesign}

# Instantiate PF_DDR4 in SmartDesign
sd_instantiate_component -sd_name {MIV_RV32_BaseDesign} -component_name {PF_DDR4_C0} -instance_name {PF_DDR4_C0_0}

print_info "PF_DDR4 added to SmartDesign"

# ==============================================================================
# Step 4: Connect DDR4 to System
# ==============================================================================

print_info "Connecting DDR4 to system..."

# Connect system clock to DDR4 SYS_CLK (200 MHz from PF_CCC)
sd_connect_pins -sd_name {MIV_RV32_BaseDesign} -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "PF_DDR4_C0_0:SYS_CLK"}

# Connect system reset to DDR4
sd_connect_pins -sd_name {MIV_RV32_BaseDesign} -pin_names {"CORERESET_PF_C0_0:FABRIC_RESET_N" "PF_DDR4_C0_0:SYS_RESET_N"}

# Connect PLL reference clock to DDR4
sd_connect_pins -sd_name {MIV_RV32_BaseDesign} -pin_names {"PF_CCC_C0_0:PLL_LOCK_0" "PF_DDR4_C0_0:PLL_LOCK"}

# Create AXI interconnect for DDR4
# Note: MI-V has AHB interface, so we need AHB-to-AXI bridge or reconfigure MI-V for AXI

print_info "Connecting AXI interface..."

# TODO: Add AXI interconnect logic here
# For now, we're just instantiating the DDR controller
# Full AXI connection requires either:
# 1. CoreAXI4Interconnect + CoreAXI2AHB bridge, OR
# 2. Reconfiguring MI-V to use AXI instead of AHB

print_info "Note: AXI interconnect logic needs to be added based on MI-V bus configuration"

# ==============================================================================
# Step 5: Expose DDR4 pins to top level
# ==============================================================================

print_info "Exposing DDR4 pins to top level..."

# Promote DDR4 external pins to top level
sd_mark_pins_unused -sd_name {MIV_RV32_BaseDesign} -pin_names {PF_DDR4_C0_0:SHIELD0}
sd_mark_pins_unused -sd_name {MIV_RV32_BaseDesign} -pin_names {PF_DDR4_C0_0:SHIELD1}
sd_mark_pins_unused -sd_name {MIV_RV32_BaseDesign} -pin_names {PF_DDR4_C0_0:SHIELD2}
sd_mark_pins_unused -sd_name {MIV_RV32_BaseDesign} -pin_names {PF_DDR4_C0_0:SHIELD3}

# Promote DDR4 memory interface pins
sd_create_pin_group -sd_name {MIV_RV32_BaseDesign} -group_name {DDR4_PINS} -instance_name {PF_DDR4_C0_0} -pin_names {\
    "A" \
    "BA" \
    "BG" \
    "CAS_N" \
    "CKE" \
    "CK_N" \
    "CK" \
    "CS_N" \
    "DM_N" \
    "DQ" \
    "DQS_N" \
    "DQS" \
    "ODT" \
    "RAS_N" \
    "RESET_N" \
    "WE_N" \
}

sd_create_pin_group_with_dummy -sd_name {MIV_RV32_BaseDesign} -group_name {DDR4_PINS}
sd_promote_pin_group_to_top_level -sd_name {MIV_RV32_BaseDesign} -group_name {DDR4_PINS}

print_info "DDR4 pins exposed to top level"

# ==============================================================================
# Step 6: Save and generate SmartDesign
# ==============================================================================

print_info "Saving SmartDesign..."
save_smartdesign -sd_name {MIV_RV32_BaseDesign}

print_info "Generating SmartDesign..."
generate_component -component_name {MIV_RV32_BaseDesign}

# ==============================================================================
# Step 7: Save project
# ==============================================================================

print_info "Saving project..."
save_project

print_msg "DDR4 Integration Complete!"

print_info "Next steps:"
print_info "1. Add DDR4 pin constraints (constraint/ddr4_pins.pdc)"
print_info "2. Add AXI interconnect for MI-V ↔ DDR4 connection"
print_info "3. Run synthesis and place & route"
print_info "4. Test with DDR firmware"

close_project
