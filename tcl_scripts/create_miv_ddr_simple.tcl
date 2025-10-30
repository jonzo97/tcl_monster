# ==============================================================================
# TCL Monster - Create MI-V RV32 + DDR4 Project (Simplified)
# ==============================================================================
#
# Purpose: Create complete PolarFire project with MI-V RISC-V + DDR4 memory
# Target: MPF300 Eval Kit (MPF300TS, FCG1152, -1 speed grade)
#
# Usage:
#   ./run_libero.sh tcl_scripts/create_miv_ddr_simple.tcl SCRIPT
#
# Note: This version uses simpler component instantiation for demo purposes
#
# ==============================================================================

set script_dir [file dirname [info script]]
set project_root [file dirname $script_dir]

# ==============================================================================
# Project Configuration
# ==============================================================================

set project_name "miv_rv32_ddr_demo"
set project_location "$project_root/libero_projects/$project_name"
set smartdesign_name "MIV_RV32_DDR_Design"

# Device configuration
set device_family "PolarFire"
set device_die "MPF300TS"
set device_package "FCG1152"
set device_speed "-1"
set device_voltage "1.0"

set hdl_language "VERILOG"

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

print_msg "Creating MI-V RV32 + DDR4 Project (Simplified)"

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
    -project_description "MI-V RV32 RISC-V with DDR4 Memory Controller" \
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

# ==============================================================================
# 2. Create/Import Components
# ==============================================================================

print_info "Creating components from pre-exported definitions..."

# Source component definitions
source "$script_dir/miv_components/PF_CCC_DUAL_BASE.tcl"
print_info "  - PF_CCC_DUAL created (50 MHz system + 200 MHz DDR4 ref)"

source "$script_dir/miv_components/PF_INIT_MONITOR_C0.tcl"
print_info "  - PF_INIT_MONITOR_C0 created"

source "$script_dir/miv_components/CORERESET_PF_C0.tcl"
print_info "  - CORERESET_PF_C0 created"

source "$script_dir/miv_components/CoreJTAGDebug_TRSTN_C0.tcl"
print_info "  - CoreJTAGDebug_TRSTN_C0 created"

# Create MI-V RV32 with AXI enabled inline
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name {MIV_RV32_AXI} \
    -params { \
        "AHB_INITIATOR_TYPE:0" \
        "AHB_START_ADDR_0:0x0" \
        "AHB_START_ADDR_1:0x0" \
        "AHB_END_ADDR_0:0x0" \
        "AHB_END_ADDR_1:0x0" \
        "AHB_TARGET_MIRROR:false" \
        "APB_INITIATOR_TYPE:1" \
        "APB_START_ADDR_0:0x0" \
        "APB_START_ADDR_1:0x7000" \
        "APB_END_ADDR_0:0xffff" \
        "APB_END_ADDR_1:0x7000" \
        "APB_TARGET_MIRROR:false" \
        "AXI_INITIATOR_TYPE:1" \
        "AXI_START_ADDR_0:0x0" \
        "AXI_START_ADDR_1:0xC000" \
        "AXI_END_ADDR_0:0xffff" \
        "AXI_END_ADDR_1:0xFFFF" \
        "AXI_TARGET_MIRROR:false" \
        "BOOTROM_PRESENT:false" \
        "C_EXT:true" \
        "DEBUGGER:true" \
        "ECC_ENABLE:false" \
        "F_EXT:false" \
        "GPR_REGS:false" \
        "INTERNAL_MTIME:true" \
        "INTERNAL_MTIME_IRQ:true" \
        "M_EXT:true" \
        "MTIME_PRESCALER:100" \
        "NUM_EXT_IRQS:1" \
        "RESET_VECTOR_ADDR_0:0x0" \
        "RESET_VECTOR_ADDR_1:0x8000" \
        "TCM_PRESENT:true" \
        "TCM_START_ADDR_0:0x0" \
        "TCM_START_ADDR_1:0x8000" \
        "TCM_END_ADDR_0:0x7fff" \
        "TCM_END_ADDR_1:0x8000" \
        "VECTORED_INTERRUPTS:false" \
    }
print_info "  - MIV_RV32_AXI created (RV32IMC with AXI for DDR4)"

source "$script_dir/miv_components/PF_DDR4_C0.tcl"
print_info "  - PF_DDR4_C0 created (2GB DDR4)"

source "$script_dir/miv_components/MIV_ESS_C0.tcl"
print_info "  - MIV_ESS_C0 created (UART + GPIO)"

source "$script_dir/miv_components/CoreTimer_C0.tcl"
print_info "  - CoreTimer_C0 created"

source "$script_dir/miv_components/CoreTimer_C1.tcl"
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

sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_CCC_DUAL} -instance_name {PF_CCC_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_INIT_MONITOR_C0} -instance_name {PF_INIT_MONITOR_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CORERESET_PF_C0} -instance_name {CORERESET_PF_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreJTAGDebug_TRSTN_C0} -instance_name {CoreJTAGDebug_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_RV32_AXI} -instance_name {MIV_RV32_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_DDR4_C0} -instance_name {PF_DDR4_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_ESS_C0} -instance_name {MIV_ESS_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C0} -instance_name {CoreTimer_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C1} -instance_name {CoreTimer_1}

print_info "Connecting clock tree..."

# Connect main system clock (50 MHz from CCC OUT0)
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_0:OUT0_FABCLK_0" "CORERESET_PF_0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_0:OUT0_FABCLK_0" "MIV_RV32_0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_0:OUT0_FABCLK_0" "MIV_ESS_0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_0:OUT0_FABCLK_0" "CoreTimer_0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_0:OUT0_FABCLK_0" "CoreTimer_1:PCLK"}

# DDR4 controller has internal PLL - no external clock connections needed
# It generates all clocks internally based on configuration parameters

print_info "Connecting reset tree..."

# Connect power-on reset
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_INIT_MONITOR_0:DEVICE_INIT_DONE" "CORERESET_PF_0:INIT_DONE"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_INIT_MONITOR_0:FABRIC_POR_N" "CORERESET_PF_0:FPGA_POR_N"}

# Distribute reset
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_0:FABRIC_RESET_N" "MIV_RV32_0:RESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_0:FABRIC_RESET_N" "PF_DDR4_0:SYS_RESET_N"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_0:FABRIC_RESET_N" "MIV_ESS_0:PRESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_0:FABRIC_RESET_N" "CoreTimer_0:PRESETn"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_0:FABRIC_RESET_N" "CoreTimer_1:PRESETn"}

print_info "Connecting MI-V to DDR4 via AXI..."

# Connect MI-V AXI master to DDR4 AXI slave
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_0:AXI_MST" "PF_DDR4_0:AXI4slave0"}

print_info "Connecting APB peripherals..."

# Create APB interconnect manually
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_0:APB_MSTR" "MIV_ESS_0:APBslave"}

# Note: For demo purposes, we'll keep timer connections simple
# In production, you'd want proper APB interconnect logic

print_info "Connecting JTAG debug..."

# Connect JTAG debug interface
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_0:TGT_TDO_0" "MIV_RV32_0:JTAG_TDO"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_0:TGT_TDI_0" "MIV_RV32_0:JTAG_TDI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_0:TGT_TCK_0" "MIV_RV32_0:JTAG_TCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_0:TGT_TMS_0" "MIV_RV32_0:JTAG_TMS"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_0:TGT_TRSTN_0" "MIV_RV32_0:JTAG_TRSTN"}

print_info "Exposing top-level ports..."

# Expose oscillator input
sd_create_scalar_port -sd_name $smartdesign_name -port_name {CLK_50MHZ} -port_direction {IN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CLK_50MHZ" "PF_CCC_0:REF_CLK_0"}

# Expose reset button
sd_create_scalar_port -sd_name $smartdesign_name -port_name {RESET_N} -port_direction {IN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"RESET_N" "CORERESET_PF_0:EXT_RST_N"}

# Expose UART
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_RX} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_TX} -port_direction {OUT}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"UART_RX" "MIV_ESS_0:UART0_RXD"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"UART_TX" "MIV_ESS_0:UART0_TXD"}

# Expose GPIOs (LEDs)
sd_create_bus_port -sd_name $smartdesign_name -port_name {GPIO_OUT} -port_direction {OUT} -port_range {[7:0]}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"GPIO_OUT" "MIV_ESS_0:GPIO_OUT"}

# DDR4 pins will be auto-exposed by the component

print_info "Saving and generating SmartDesign..."
save_smartdesign -sd_name $smartdesign_name
generate_component -component_name $smartdesign_name

# ==============================================================================
# 4. Import Constraints
# ==============================================================================

print_info "Importing I/O constraints..."

# Import pin constraints
import_files \
    -convert_EDN_to_HDL 0 \
    -io_pdc "$project_root/constraint/io_miv_ddr.pdc"

# Import timing constraints
import_files \
    -convert_EDN_to_HDL 0 \
    -sdc "$project_root/constraint/timing_miv_ddr.sdc"

# Associate constraints with tools
organize_tool_files \
    -tool {PLACEROUTE} \
    -file "$project_location/constraint/io_miv_ddr.pdc" \
    -file "$project_location/constraint/timing_miv_ddr.sdc" \
    -module "${smartdesign_name}::work" \
    -input_type {constraint}

organize_tool_files \
    -tool {SYNTHESIZE} \
    -file "$project_location/constraint/timing_miv_ddr.sdc" \
    -module "${smartdesign_name}::work" \
    -input_type {constraint}

print_info "Constraints imported and associated"

# ==============================================================================
# 5. Save Project
# ==============================================================================

print_msg "Project Creation Complete!"

save_project

print_info "Project saved to: $project_location"
print_info ""
print_info "Next steps:"
print_info "1. Run synthesis and place & route"
print_info "2. Analyze with Build Doctor"
print_info "3. Update demo documentation"

close_project
