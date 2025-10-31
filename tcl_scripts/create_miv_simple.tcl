# ==============================================================================
# Create Simple MI-V RV32 Project Using Pre-Exported Components
# ==============================================================================
#
# Purpose: Create working MI-V + SRAM demo for Build Doctor analysis
# Uses pre-exported components from Mi-V reference design
#
# Usage: ./run_libero.sh tcl_scripts/create_miv_simple.tcl SCRIPT
#
# ==============================================================================

set script_dir [file dirname [info script]]
set project_root [file dirname $script_dir]

# ==============================================================================
# Project Configuration
# ==============================================================================

set project_name "miv_simple_demo"
set project_location "$project_root/libero_projects/$project_name"
set smartdesign_name "MIV_Simple_Design"

# Device configuration - MPF300 Eval Kit
set device_family "PolarFire"
set device_die "MPF300TS"
set device_package "FCG1152"
set device_speed "-1"
set device_voltage "1.0"

set hdl_language "VERILOG"

# Reference design component directory
set ref_components "$project_root/hdl/miv_polarfire_eval/Libero_Projects/import/components"
set ref_software "$project_root/hdl/miv_polarfire_eval/Libero_Projects/import/software_example/MIV_RV32/CFG1"

# Software hex file for SRAM initialization
set exProgramHex "miv-rv32-coretimer-timer_interrupt.hex"

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

# ==============================================================================
# Main Script
# ==============================================================================

print_msg "Creating Simple MI-V RV32 Project"

# Check if project already exists
if {[file exists $project_location]} {
    print_msg "ERROR: Project already exists at $project_location"
    print_info "Please delete or rename the existing project first."
    exit 1
}

# ==============================================================================
# 1. Create New Project
# ==============================================================================

print_info "Creating new Libero project..."

new_project \
    -location $project_location \
    -name $project_name \
    -project_description "Simple MI-V RV32 RISC-V with SRAM for Build Doctor Demo" \
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
    -part_range {IND} \
    -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
    -adv_options {RESTRICTPROBEPINS:1} \
    -adv_options {RESTRICTSPIPINS:0} \
    -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
    -adv_options {TEMPR:IND} \
    -adv_options {VCCI_1.2_VOLTR:IND} \
    -adv_options {VCCI_1.5_VOLTR:IND} \
    -adv_options {VCCI_1.8_VOLTR:IND} \
    -adv_options {VCCI_2.5_VOLTR:IND} \
    -adv_options {VCCI_3.3_VOLTR:IND} \
    -adv_options {VOLTR:IND}

# Configure SmartDesign DRC settings
smartdesign \
    -memory_map_drc_change_error_to_warning 1 \
    -bus_interface_data_width_drc_change_error_to_warning 1 \
    -bus_interface_id_width_drc_change_error_to_warning 1

print_info "Project created successfully"

# Copy software hex files to project directory
print_info "Copying software hex files..."
file copy -force "$ref_software/hex" "$project_location/hex"
print_info "Hex files copied"

# ==============================================================================
# 2. Create Components from Pre-Exported Definitions
# ==============================================================================

print_info "Creating components from pre-exported definitions..."

# Source component definitions from reference design
source "$ref_components/PF_CCC_C0.tcl"
print_info "  - PF_CCC_C0 created (50 MHz clock)"

source "$ref_components/PF_INIT_MONITOR_C0.tcl"
print_info "  - PF_INIT_MONITOR_C0 created"

source "$ref_components/CORERESET_PF_C0.tcl"
print_info "  - CORERESET_PF_C0 created"

source "$ref_components/CoreJTAGDebug_TRSTN_C0.tcl"
print_info "  - CoreJTAGDebug_TRSTN_C0 created"

source "$ref_components/MIV_RV32_CFG1_C0.tcl"
print_info "  - MIV_RV32_CFG1_C0 created (RV32IMC)"

source "$ref_components/PF_SRAM_AHB_C0.tcl"
print_info "  - PF_SRAM_AHB_C0 created (64kB LSRAM)"

source "$ref_components/MIV_ESS_C0.tcl"
print_info "  - MIV_ESS_C0 created (UART + GPIO + peripherals)"

source "$ref_components/CoreTimer_C0.tcl"
print_info "  - CoreTimer_C0 created"

source "$ref_components/CoreTimer_C1.tcl"
print_info "  - CoreTimer_C1 created"

print_info "All components created successfully"

# ==============================================================================
# 3. Create SmartDesign and Connect Everything
# ==============================================================================

print_info "Creating SmartDesign: $smartdesign_name"

create_smartdesign -sd_name $smartdesign_name

# Set SmartDesign as top level
set_root -module "${smartdesign_name}::work"

# Instantiate all components
print_info "Instantiating components in SmartDesign..."

sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_CCC_C0} -instance_name {PF_CCC_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_INIT_MONITOR_C0} -instance_name {PF_INIT_MONITOR_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CORERESET_PF_C0} -instance_name {CORERESET_PF_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreJTAGDebug_TRSTN_C0} -instance_name {CoreJTAGDebug_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_RV32_CFG1_C0} -instance_name {MIV_RV32_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_SRAM_AHB_C0} -instance_name {PF_SRAM_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_ESS_C0} -instance_name {MIV_ESS_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C0} -instance_name {CoreTimer_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C1} -instance_name {CoreTimer_1}

print_info "Connecting clock tree..."

# Connect system clock (50 MHz from CCC) and PLL lock
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:OUT0_FABCLK_0 CORERESET_PF_0:CLK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:PLL_LOCK_0 CORERESET_PF_0:PLL_LOCK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:OUT0_FABCLK_0 MIV_RV32_0:CLK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:OUT0_FABCLK_0 PF_SRAM_0:HCLK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:OUT0_FABCLK_0 MIV_ESS_0:PCLK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:OUT0_FABCLK_0 CoreTimer_0:PCLK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:OUT0_FABCLK_0 CoreTimer_1:PCLK}

print_info "Connecting reset tree..."

# Connect power-on reset
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_0:DEVICE_INIT_DONE CORERESET_PF_0:INIT_DONE}
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_0:FABRIC_POR_N CORERESET_PF_0:FPGA_POR_N}

# Distribute reset
sd_connect_pins -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:FABRIC_RESET_N MIV_RV32_0:RESETN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:FABRIC_RESET_N PF_SRAM_0:HRESETN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:FABRIC_RESET_N MIV_ESS_0:PRESETN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:FABRIC_RESET_N CoreTimer_0:PRESETn}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:FABRIC_RESET_N CoreTimer_1:PRESETn}

print_info "Connecting MI-V to SRAM via AHB..."

# Connect MI-V AHB master to SRAM AHB slave
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_RV32_0:AHBL_M_TARGET PF_SRAM_0:AHBSlaveInterface}

print_info "Connecting APB peripherals..."

# Connect MI-V APB initiator to MI-V ESS
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_RV32_0:APB_INITIATOR MIV_ESS_0:APB_0_mINITIATOR}

# Connect timers to MI-V ESS APB slots
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:APB_3_mTARGET CoreTimer_0:APBslave}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:APB_4_mTARGET CoreTimer_1:APBslave}

print_info "Connecting timer interrupts..."

# Connect timer interrupts to MI-V core
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_RV32_0:MSYS_EI CoreTimer_0:TIMINT}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_RV32_0:EXT_IRQ CoreTimer_1:TIMINT}

print_info "Connecting JTAG debug..."

# Connect JTAG debug interface (MI-V to CoreJTAGDebug)
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TGT_TDO_0 MIV_RV32_0:JTAG_TDO}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TGT_TDI_0 MIV_RV32_0:JTAG_TDI}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TGT_TCK_0 MIV_RV32_0:JTAG_TCK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TGT_TMS_0 MIV_RV32_0:JTAG_TMS}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TGT_TRSTN_0 MIV_RV32_0:JTAG_TRSTN}

print_info "Creating top-level ports..."

# Create top-level ports first
sd_create_scalar_port -sd_name $smartdesign_name -port_name {CLK_50MHZ} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {RESET_N} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_RX} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_TX} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_1} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_2} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_3} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {LED_4} -port_direction {OUT}

# JTAG ports
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TRSTB} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TCK} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TDI} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TMS} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {TDO} -port_direction {OUT}

print_info "Connecting to top-level ports..."

# Now connect to the ports
sd_connect_pins -sd_name $smartdesign_name -pin_names {PF_CCC_0:REF_CLK_0 CLK_50MHZ}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:EXT_RST_N RESET_N}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:UART_RX UART_RX}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:UART_TX UART_TX}

# Create GPIO pin slices and connect
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_0:GPIO_OUT} -pin_slices {[0]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_0:GPIO_OUT} -pin_slices {[1]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_0:GPIO_OUT} -pin_slices {[2]}
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_0:GPIO_OUT} -pin_slices {[3]}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:GPIO_OUT[0] LED_1}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:GPIO_OUT[1] LED_2}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:GPIO_OUT[2] LED_3}
sd_connect_pins -sd_name $smartdesign_name -pin_names {MIV_ESS_0:GPIO_OUT[3] LED_4}

# Connect JTAG to top-level ports
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TCK TCK}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TDI TDI}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TDO TDO}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TMS TMS}
sd_connect_pins -sd_name $smartdesign_name -pin_names {CoreJTAGDebug_0:TRSTB TRSTB}

print_info "Tying off unused pins..."

# Tie off CORERESET_PF unused pins
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:BANK_x_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:BANK_y_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:SS_BUSY} -value {GND}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_0:FF_US_RESTORE} -value {GND}

# Tie off unused GPIO inputs (we're only using GPIO_OUT for LEDs)
sd_create_pin_slices -sd_name $smartdesign_name -pin_name {MIV_ESS_0:GPIO_IN} -pin_slices {[3:0]}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {MIV_ESS_0:GPIO_IN[3:0]} -value {GND}

print_info "Saving and generating SmartDesign..."
save_smartdesign -sd_name $smartdesign_name
generate_component -component_name $smartdesign_name

# ==============================================================================
# 4. Save Project
# ==============================================================================

print_msg "Project Creation Complete!"

save_project

print_info "Project saved to: $project_location"
print_info ""
print_info "Next steps:"
print_info "1. Run synthesis"
print_info "2. Run place & route"
print_info "3. Analyze with Build Doctor"

close_project
