# ==============================================================================
# TCL Monster - MI-V RV32 RISC-V Project Creation Script (Version 2)
# ==============================================================================
#
# Purpose: Create a PolarFire FPGA project with MI-V RV32 RISC-V processor
# Based on: Application Note AN4997 - Building a Mi-V Processor Subsystem
# Target: MPF300 Eval Kit (MPF300TS, FCG1152, -1 speed grade)
#
# Usage:
#   ./run_libero.sh tcl_scripts/create_miv_rv32_project_v2.tcl SCRIPT
#
# Configuration: CFG1 (RV32IMC)
#   - Extensions: M (multiply/divide), C (compressed instructions)
#   - Memory: 32kB TCM (Tightly Coupled Memory) at 0x80000000-0x80007FFF
#   - Debug: JTAG debugger support
#   - Bus: AHB-Lite interface for external memory at 0x60000000-0x6000FFFF (32kB)
#   - Peripherals: APB bus at 0x70000000-0x7000FFFF
#   - Clock: 50 MHz system clock
#
# This version uses pre-configured component TCL files from the MI-V reference design
#
# ==============================================================================

# Get the script directory for relative paths
set script_path [info script]
set script_dir [file dirname $script_path]
set project_root [file dirname $script_dir]
set components_dir "$script_dir/miv_components"

# ==============================================================================
# Project Configuration
# ==============================================================================

set project_name "miv_rv32_demo"
set project_location "$project_root/libero_projects/$project_name"
set smartdesign_name "MIV_RV32_BaseDesign"

# Device configuration - MPF300 Eval Kit
set device_family "PolarFire"
set device_die "MPF300TS"
set device_package "FCG1152"
set device_speed "-1"
set device_voltage "1.0"

# Design configuration
set hdl_language "VERILOG"
set miv_config "CFG1"

# ==============================================================================
# Helper Functions
# ==============================================================================

proc print_msg {message} {
    puts "=================================================================================="
    puts $message
    puts "=================================================================================="
}

proc print_info {message} {
    puts "INFO: $message"
}

proc print_error {message} {
    puts "ERROR: $message"
}

# ==============================================================================
# Main Script
# ==============================================================================

print_msg "TCL Monster - Creating MI-V RV32 RISC-V Project (v2)"

# Check if project already exists
if {[file exists $project_location]} {
    print_error "Project directory already exists: $project_location"
    print_info "Please delete or rename the existing project first."
    exit 1
}

# Check if component files exist
if {![file exists $components_dir]} {
    print_error "Component directory not found: $components_dir"
    print_info "Please run 'mkdir -p tcl_scripts/miv_components' and copy the component TCL files."
    exit 1
}

# Create new Libero project
print_info "Creating new Libero project: $project_name"
print_info "Location: $project_location"
print_info "Device: $device_die ($device_package, speed $device_speed)"

new_project \
    -location $project_location \
    -name $project_name \
    -project_description "MI-V RV32 RISC-V Demo - TCL Monster" \
    -block_mode 0 \
    -standalone_peripheral_initialization 0 \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1 \
    -use_enhanced_constraint_flow 1 \
    -hdl $hdl_language \
    -family $device_family \
    -die $device_die \
    -package $device_package \
    -speed $device_speed \
    -die_voltage $device_voltage \
    -part_range IND \
    -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
    -adv_options {RESTRICTPROBEPINS:1} \
    -adv_options {RESTRICTSPIPINS:0} \
    -adv_options {TEMPR:IND} \
    -adv_options {VCCI_1.2_VOLTR:IND} \
    -adv_options {VCCI_1.5_VOLTR:IND} \
    -adv_options {VCCI_1.8_VOLTR:IND} \
    -adv_options {VCCI_2.5_VOLTR:IND} \
    -adv_options {VCCI_3.3_VOLTR:IND} \
    -adv_options {VOLTR:IND}

print_info "Project created successfully"

# Configure SmartDesign DRC settings
print_info "Configuring SmartDesign DRC settings..."
smartdesign \
    -memory_map_drc_change_error_to_warning 1 \
    -bus_interface_data_width_drc_change_error_to_warning 1 \
    -bus_interface_id_width_drc_change_error_to_warning 1

# ==============================================================================
# Create and Configure Cores - Using Reference Design Configurations
# ==============================================================================

print_msg "Creating Cores from Reference Design Configurations"

# Source the pre-configured component TCL files
print_info "Sourcing MI-V RV32 core configuration..."
source $components_dir/MIV_RV32_CFG1_C0.tcl

print_info "Sourcing PF_CCC (Clock) configuration..."
source $components_dir/PF_CCC_C0.tcl

print_info "Sourcing CORERESET_PF configuration..."
source $components_dir/CORERESET_PF_C0.tcl

print_info "Sourcing PF_INIT_MONITOR configuration..."
source $components_dir/PF_INIT_MONITOR_C0.tcl

print_info "Sourcing CoreJTAGDebug configuration..."
source $components_dir/CoreJTAGDebug_TRSTN_C0.tcl

print_info "Sourcing MIV_ESS (External Subsystem) configuration..."
source $components_dir/MIV_ESS_C0.tcl

print_info "Sourcing CoreTimer configurations..."
source $components_dir/CoreTimer_C0.tcl
source $components_dir/CoreTimer_C1.tcl

print_info "Sourcing PF_SRAM_AHB configuration..."
source $components_dir/PF_SRAM_AHB_C0.tcl

print_info "All cores created successfully"

# ==============================================================================
# Build SmartDesign
# ==============================================================================

print_msg "Building SmartDesign: $smartdesign_name"

# Create SmartDesign
create_smartdesign -sd_name $smartdesign_name

# Disable auto-promotion of pad pins
auto_promote_pad_pins -promote_all 0

# Create top-level ports
print_info "Creating top-level I/O ports..."

# Clock and reset
sd_create_scalar_port -sd_name $smartdesign_name -port_name {REF_CLK} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {USER_RST} -port_direction {IN}

# JTAG interface
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TCK} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TDI} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TDO} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TMS} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TRSTB} -port_direction {IN}

# UART interface
sd_create_scalar_port -sd_name $smartdesign_name -port_name {RX} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TX} -port_direction {OUT}

# GPIO - simplified (2 switches, 4 LEDs from eval board)
sd_create_scalar_port -sd_name $smartdesign_name -port_name {SW_1} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {SW_2} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_1} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_2} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_3} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_4} -port_direction {OUT}

# Instantiate components
print_info "Instantiating components..."

sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_RV32_CFG1_C0} -instance_name {MIV_RV32_CFG1_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_CCC_C0} -instance_name {PF_CCC_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CORERESET_PF_C0} -instance_name {CORERESET_PF_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_INIT_MONITOR_C0} -instance_name {PF_INIT_MONITOR_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {COREJTAGDEBUG_TRSTN_C0} -instance_name {COREJTAGDEBUG_TRSTN_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_ESS_C0} -instance_name {MIV_ESS_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C0} -instance_name {CoreTimer_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C1} -instance_name {CoreTimer_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_SRAM_AHB_C0} -instance_name {PF_SRAM_AHB_C0_0}

# Instantiate clock buffer macro
sd_instantiate_macro -sd_name $smartdesign_name -macro_name {CLKBUF} -instance_name {CLKBUF_0}

# Connect clocks
print_info "Connecting clock signals..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CLKBUF_0:PAD" "REF_CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CLKBUF_0:Y" "PF_CCC_C0_0:REF_CLK_0"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "CORERESET_PF_C0_0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "MIV_RV32_CFG1_C0_0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "MIV_ESS_C0_0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "CoreTimer_C0_0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "CoreTimer_C1_0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:OUT0_FABCLK_0" "PF_SRAM_AHB_C0_0:HCLK"}

# Connect resets
print_info "Connecting reset signals..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0_0:PLL_LOCK_0" "CORERESET_PF_C0_0:PLL_LOCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"USER_RST" "CORERESET_PF_C0_0:EXT_RST_N"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:FABRIC_RESET_N" "MIV_RV32_CFG1_C0_0:RESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:FABRIC_RESET_N" "MIV_ESS_C0_0:PRESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:FABRIC_RESET_N" "CoreTimer_C0_0:PRESETn"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:FABRIC_RESET_N" "CoreTimer_C1_0:PRESETn"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:FABRIC_RESET_N" "PF_SRAM_AHB_C0_0:HRESETN"}

# Connect init monitor
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:FPGA_POR_N" "PF_INIT_MONITOR_C0_0:FABRIC_POR_N"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0_0:INIT_DONE" "PF_INIT_MONITOR_C0_0:DEVICE_INIT_DONE"}

# Connect JTAG debug interface
print_info "Connecting JTAG debug interface..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TGT_TCK_0" "MIV_RV32_CFG1_C0_0:JTAG_TCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TGT_TDI_0" "MIV_RV32_CFG1_C0_0:JTAG_TDI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TGT_TDO_0" "MIV_RV32_CFG1_C0_0:JTAG_TDO"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TGT_TMS_0" "MIV_RV32_CFG1_C0_0:JTAG_TMS"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TGT_TRSTN_0" "MIV_RV32_CFG1_C0_0:JTAG_TRSTN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TCK" "TCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TDI" "TDI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TDO" "TDO"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TMS" "TMS"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_TRSTN_C0_0:TRSTB" "TRSTB"}

# Connect UART
print_info "Connecting UART interface..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:UART_RX" "RX"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:UART_TX" "TX"}

# Connect GPIO
print_info "Connecting GPIO interface..."
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_IN} -pin_slices {[0]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_IN} -pin_slices {[1]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_IN} -pin_slices {[3:2]}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {MIV_ESS_C0_0:GPIO_IN[3:2]} -value {GND}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:GPIO_IN[0]" "SW_1"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:GPIO_IN[1]" "SW_2"}

sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_OUT} -pin_slices {[0]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_OUT} -pin_slices {[1]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_OUT} -pin_slices {[2]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_C0_0:GPIO_OUT} -pin_slices {[3]}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:GPIO_OUT[0]" "LED_1"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:GPIO_OUT[1]" "LED_2"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:GPIO_OUT[2]" "LED_3"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:GPIO_OUT[3]" "LED_4"}

# Connect interrupts
print_info "Connecting interrupt signals..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreTimer_C0_0:TIMINT" "MIV_RV32_CFG1_C0_0:MSYS_EI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreTimer_C1_0:TIMINT" "MIV_RV32_CFG1_C0_0:EXT_IRQ"}

# Connect APB bus interfaces
print_info "Connecting APB bus interfaces..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_CFG1_C0_0:APB_INITIATOR" "MIV_ESS_C0_0:APB_0_mINITIATOR"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:APB_3_mTARGET" "CoreTimer_C0_0:APBslave"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0_0:APB_4_mTARGET" "CoreTimer_C1_0:APBslave"}

# Connect AHB bus interface to external SRAM
print_info "Connecting AHB bus to external SRAM..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_CFG1_C0_0:AHBL_M_TARGET" "PF_SRAM_AHB_C0_0:AHBSlaveInterface"}

# Mark unused pins
print_info "Marking unused pins..."
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_RV32_CFG1_C0_0:JTAG_TDO_DR}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_RV32_CFG1_C0_0:EXT_RESETN}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_RV32_CFG1_C0_0:TIME_COUNT_OUT}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_ESS_C0_0:GPIO_INT}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0_0:PLL_POWERDOWN_B}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:PCIE_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:USRAM_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:SRAM_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:XCVR_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:USRAM_INIT_FROM_SNVM_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:USRAM_INIT_FROM_UPROM_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:USRAM_INIT_FROM_SPI_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:SRAM_INIT_FROM_SNVM_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:SRAM_INIT_FROM_UPROM_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:SRAM_INIT_FROM_SPI_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0_0:AUTOCALIB_DONE}

# Tie constants to CORERESET_PF status inputs
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0_0:BANK_x_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0_0:BANK_y_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0_0:SS_BUSY} -value {GND}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0_0:FF_US_RESTORE} -value {GND}

# Re-enable auto-promotion and finalize layout
auto_promote_pad_pins -promote_all 1
sd_reset_layout -sd_name $smartdesign_name

# Save and generate SmartDesign
print_info "Saving SmartDesign..."
save_smartdesign -sd_name $smartdesign_name

print_info "Generating SmartDesign components..."
generate_component -component_name $smartdesign_name

# Set SmartDesign as root
print_info "Setting SmartDesign as root module..."
set_root -module "${smartdesign_name}::work"

# ==============================================================================
# Save Project
# ==============================================================================

print_info "Saving project..."
save_project

print_msg "MI-V RV32 Project Created Successfully!"
print_info "Project Name: $project_name"
print_info "Project Location: $project_location"
print_info "SmartDesign: $smartdesign_name"
print_info ""
print_info "Next Steps:"
print_info "  1. Add pin constraints (PDC file) for MPF300 Eval Kit"
print_info "  2. Run synthesis and place & route"
print_info "  3. Generate bitstream and program device"
print_info ""
print_msg "TCL Monster - MI-V RV32 Project Creation Complete"
