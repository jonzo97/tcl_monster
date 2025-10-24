# ==============================================================================
# TCL Monster - Create MI-V RV32 + DDR4 Project (Fully Automated)
# ==============================================================================
#
# Purpose: Create complete PolarFire project with MI-V RISC-V + DDR4 memory
# Based on: create_miv_rv32_project.tcl + PF_DDR4 integration
# Target: MPF300 Eval Kit (MPF300TS, FCG1152, -1 speed grade)
#
# Usage:
#   ./run_libero.sh tcl_scripts/create_miv_ddr_project.tcl SCRIPT
#
# Configuration:
#   - MI-V RV32 CFG1 (RV32IMC) with AXI interface ENABLED
#   - 32kB TCM @ 0x80000000-0x80007FFF
#   - 2GB DDR4 @ 0xC0000000-0xFFFFFFFF (AXI4 interface)
#   - Peripherals @ 0x70000000-0x7000FFFF (APB)
#   - Clock: 50 MHz system, 200 MHz DDR AXI, 800 MHz DDR PHY
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
set system_clock_mhz 50

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

print_msg "Creating MI-V RV32 + DDR4 Project"

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
# 2. Create Clock Conditioning Circuit (CCC)
# ==============================================================================

print_info "Creating PF_CCC (Clock Conditioning Circuit)..."

create_and_configure_core \
    -core_vlnv {Actel:SgCore:PF_CCC:2.2.220} \
    -component_name {PF_CCC_C1} \
    -params { \
        "INIT:0x0000000000000000000000000000000000000000000000000000000000000000_0x00000000000000000000000000000000000000000000000000000000000000000000000000000000_0x00000000000000000000000000000000000000000000000000000000000000000000000000000000_0x00000000000000000000000000000000000000000000000000000000000000000000000000000000_0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" \
        "INIT_EN:0x0" \
        "PLL_SUPPLY_1.0_OR_1.05_OR_1.1:1.0" \
        "VCOFREQUENCY:800.0" \
    } \
    -params { \
        "IMPORT_SETTINGS:import/components/IMC/PF_CCC_C1.ccc" \
    }

# PLL configuration for DDR4:
# - Input: 50 MHz from oscillator
# - OUT0: 50 MHz (system clock)
# - OUT1: 200 MHz (DDR AXI interface clock)
# - VCO: 800 MHz (for DDR PHY)

print_info "PF_CCC created (50 MHz system, 200 MHz DDR AXI)"

# ==============================================================================
# 3. Create PF_INIT_MONITOR
# ==============================================================================

print_info "Creating PF_INIT_MONITOR..."

create_and_configure_core \
    -core_vlnv {Actel:SgCore:PF_INIT_MONITOR:2.0.208} \
    -component_name {PF_INIT_MONITOR_C1} \
    -params {}

# ==============================================================================
# 4. Create Reset Controller
# ==============================================================================

print_info "Creating CORERESET_PF..."

create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CORERESET_PF:2.3.100} \
    -component_name {CORERESET_PF_C1} \
    -params {}

# ==============================================================================
# 5. Create JTAG Debug Interface
# ==============================================================================

print_info "Creating CoreJTAGDebug..."

create_and_configure_core \
    -core_vlnv {Actel:DirectCore:COREJTAGDEBUG:4.0.100} \
    -download_core \
    -component_name {CoreJTAGDebug_C1} \
    -params { \
        "FAMILY:26" \
        "IR_CODE_TGT_0:0x55" \
        "IR_CODE_TGT_1:0x56" \
        "JTAG_INTERFACE:UJTAG" \
        "NUM_DEBUG_TARGETS:1" \
        "PREV_IR_LENGTH:0" \
    }

# ==============================================================================
# 6. Create MI-V RV32 Core with AXI ENABLED
# ==============================================================================

print_info "Creating MIV_RV32_CFG1 with AXI interface enabled..."

create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name {MIV_RV32_C1} \
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

print_info "MI-V RV32 created with:"
print_info "  - TCM: 32kB @ 0x80000000-0x80007FFF"
print_info "  - AXI: 2GB @ 0xC0000000-0xFFFFFFFF (for DDR)"
print_info "  - APB: 64kB @ 0x70000000-0x7000FFFF (for peripherals)"

# ==============================================================================
# 7. Create PF_DDR4 Controller
# ==============================================================================

print_info "Creating PF_DDR4 controller..."

# Source the exported DDR4 component
source "$script_dir/miv_components/PF_DDR4_C0.tcl"

print_info "PF_DDR4 created (2GB DDR4 @ 1600 Mbps, AXI4 interface)"

# ==============================================================================
# 8. Create Peripheral Subsystem (MIV_ESS)
# ==============================================================================

print_info "Creating MIV_ESS (UART + GPIO)..."

create_and_configure_core \
    -core_vlnv {Microchip:MiV:MIV_ESS:2.0.104} \
    -download_core \
    -component_name {MIV_ESS_C1} \
    -params { \
        "EXPOSE_ICSS_APB_SLAVE:false" \
        "EXPOSE_UICSS_APB_SLAVE:false" \
        "GPOUT_WIDTH:8" \
        "GPIN_WIDTH:8" \
        "HAVE_UART0:true" \
        "HAVE_UART1:false" \
        "UART0_FIXEDBAUD:false" \
        "UART0_PRDATAWIDTH:8" \
        "UART1_FIXEDBAUD:false" \
        "UART1_PRDATAWIDTH:8" \
    }

# ==============================================================================
# 9. Create Timers
# ==============================================================================

print_info "Creating CoreTimer instances..."

create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_C0} \
    -params { \
        "FAMILY:26" \
        "INTACTIVEH:1" \
        "WIDTH:32" \
    }

create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_C1} \
    -params { \
        "FAMILY:26" \
        "INTACTIVEH:1" \
        "WIDTH:32" \
    }

# ==============================================================================
# 10. Create SmartDesign and Connect Everything
# ==============================================================================

print_info "Creating SmartDesign: $smartdesign_name"

create_smartdesign -sd_name $smartdesign_name

# Set SmartDesign as top level
set_root -module "${smartdesign_name}::work"

# Instantiate all components
print_info "Instantiating components in SmartDesign..."

sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_CCC_C1} -instance_name {PF_CCC_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_INIT_MONITOR_C1} -instance_name {PF_INIT_MONITOR_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CORERESET_PF_C1} -instance_name {CORERESET_PF_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreJTAGDebug_C1} -instance_name {CoreJTAGDebug_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_RV32_C1} -instance_name {MIV_RV32_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_DDR4_C0} -instance_name {PF_DDR4_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_ESS_C1} -instance_name {MIV_ESS_C1_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C0} -instance_name {CoreTimer_C0_0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C1} -instance_name {CoreTimer_C1_0}

print_info "Connecting clocks and resets..."

# Connect clocks
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C1_0:OUT0_FABCLK_0" "CORERESET_PF_C1_0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C1_0:OUT0_FABCLK_0" "MIV_RV32_C1_0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C1_0:OUT1_FABCLK_0" "PF_DDR4_C0_0:SYS_CLK"}

# Connect resets
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C1_0:FABRIC_RESET_N" "MIV_RV32_C1_0:RESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C1_0:FABRIC_RESET_N" "PF_DDR4_C0_0:SYS_RESET_N"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C1_0:PLL_LOCK_0" "PF_DDR4_C0_0:PLL_LOCK"}

print_info "Connecting MI-V to DDR4 via AXI..."

# Connect MI-V AXI master to DDR4 AXI slave
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_C1_0:AXI_MST" "PF_DDR4_C0_0:AXI4slave0"}

print_info "Connecting peripherals..."

# Connect MI-V APB to peripherals
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_C1_0:APB_MSTR" "MIV_ESS_C1_0:APB_MSTR_SLAVE"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_C1_0:APB_MSTR" "CoreTimer_C0_0:PADDR"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_C1_0:APB_MSTR" "CoreTimer_C1_0:PADDR"}

# Connect JTAG debug
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_C1_0:TGT_TDO_0" "MIV_RV32_C1_0:JTAG_TDO"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_C1_0:TGT_TDI_0" "MIV_RV32_C1_0:JTAG_TDI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_C1_0:TGT_TCK_0" "MIV_RV32_C1_0:JTAG_TCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_C1_0:TGT_TMS_0" "MIV_RV32_C1_0:JTAG_TMS"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreJTAGDebug_C1_0:TGT_TRSTN_0" "MIV_RV32_C1_0:JTAG_TRSTN"}

print_info "Exposing top-level ports..."

# Expose oscillator input
sd_create_scalar_port -sd_name $smartdesign_name -port_name {CLK_50MHZ} -port_direction {IN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CLK_50MHZ" "PF_CCC_C1_0:REF_CLK_0"}

# Expose reset button
sd_create_scalar_port -sd_name $smartdesign_name -port_name {RESET_N} -port_direction {IN}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"RESET_N" "CORERESET_PF_C1_0:EXT_RST_N"}

# Expose UART
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_RX} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_TX} -port_direction {OUT}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"UART_RX" "MIV_ESS_C1_0:UART0_RXD"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"UART_TX" "MIV_ESS_C1_0:UART0_TXD"}

# Expose GPIOs (LEDs)
sd_create_bus_port -sd_name $smartdesign_name -port_name {GPIO_OUT} -port_direction {OUT} -port_range {[7:0]}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"GPIO_OUT" "MIV_ESS_C1_0:GPIO_OUT"}

# Expose DDR4 pins (will be auto-assigned in constraints)
# DDR4 pin promotion handled by component itself

print_info "Saving and generating SmartDesign..."
save_smartdesign -sd_name $smartdesign_name
generate_component -component_name $smartdesign_name

# ==============================================================================
# 11. Import Constraints
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
# 12. Save Project
# ==============================================================================

print_msg "Project Creation Complete!"

save_project

print_info "Project saved to: $project_location"
print_info ""
print_info "Next steps:"
print_info "1. Run synthesis and place & route: ./run_libero.sh tcl_scripts/build_miv_ddr_project.tcl SCRIPT"
print_info "2. Write DDR test firmware"
print_info "3. Program FPGA and test"

close_project
