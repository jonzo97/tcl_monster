# ==============================================================================
# TCL Monster - MI-V RV32 RISC-V Project Creation Script
# ==============================================================================
#
# Purpose: Create a PolarFire FPGA project with MI-V RV32 RISC-V processor
# Based on: Application Note AN4997 - Building a Mi-V Processor Subsystem
# Target: MPF300 Eval Kit (MPF300TS, FCG1152, -1 speed grade)
#
# Usage:
#   ./run_libero.sh tcl_scripts/create_miv_rv32_project.tcl SCRIPT
#
# Configuration: CFG1 (RV32IMC)
#   - Extensions: M (multiply/divide), C (compressed instructions)
#   - Memory: 32kB TCM (Tightly Coupled Memory) at 0x80000000-0x80007FFF
#   - Debug: JTAG debugger support
#   - Bus: AHB-Lite interface for external memory at 0x60000000-0x6000FFFF (32kB)
#   - Peripherals: APB bus at 0x70000000-0x7000FFFF
#   - Clock: 50 MHz system clock
#
# ==============================================================================

# Get the script directory for relative paths
set script_path [info script]
set script_dir [file dirname $script_path]
set project_root [file dirname $script_dir]

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
set system_clock_mhz 50

# MI-V RV32 Core Configuration
set miv_config "CFG1"
set miv_component_name "MIV_RV32_${miv_config}_C0"

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

print_msg "TCL Monster - Creating MI-V RV32 RISC-V Project"

# Check if project already exists
if {[file exists $project_location]} {
    print_error "Project directory already exists: $project_location"
    print_info "Please delete or rename the existing project first."
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
# Create and Configure MI-V RV32 Core
# ==============================================================================

print_msg "Creating and Configuring MI-V RV32 Core ($miv_config)"

# Create MI-V RV32 core with CFG1 configuration
# This will download the core from Microchip's IP catalog if not already present
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name $miv_component_name \
    -params { \
        "M_EXT:true" \
        "C_EXT:true" \
        "F_EXT:false" \
        "DEBUGGER:true" \
        "TCM_PRESENT:true" \
        "TCM_START_ADDR_0:0x0" \
        "TCM_START_ADDR_1:0x8000" \
        "TCM_END_ADDR_0:0x7fff" \
        "TCM_END_ADDR_1:0x8000" \
        "RESET_VECTOR_ADDR_0:0x0" \
        "RESET_VECTOR_ADDR_1:0x8000" \
        "INTERNAL_MTIME:true" \
        "INTERNAL_MTIME_IRQ:true" \
        "MTIME_PRESCALER:100" \
        "NUM_EXT_IRQS:1" \
        "AHB_INITIATOR_TYPE:1" \
        "AHB_START_ADDR_0:0x0" \
        "AHB_START_ADDR_1:0x6000" \
        "AHB_END_ADDR_0:0xffff" \
        "AHB_END_ADDR_1:0x6000" \
        "APB_INITIATOR_TYPE:1" \
        "APB_START_ADDR_0:0x0" \
        "APB_START_ADDR_1:0x7000" \
        "APB_END_ADDR_0:0xffff" \
        "APB_END_ADDR_1:0x7000" \
    }

print_info "MI-V RV32 core created: $miv_component_name"

# ==============================================================================
# Create Supporting Infrastructure Cores
# ==============================================================================

print_msg "Creating Supporting Infrastructure Cores"

# 1. Clock Conditioning Circuit (CCC) - Generate 50 MHz system clock
print_info "Creating PF_CCC (Clock Conditioning Circuit)..."
create_and_configure_core \
    -core_vlnv {Actel:SgCore:PF_CCC:2.2.220} \
    -component_name {PF_CCC_C0} \
    -params { \
        "INIT:CONFIG_PLL_ONLY" \
        "PLL_0_SOURCE:REFCLK" \
        "PLL_0_FEEDBACK_MODE:1" \
        "PLL_0_OUTPUT_FREQ:50.0" \
    }

# 2. Reset Controller - Manage system reset signals
print_info "Creating CORERESET_PF (Reset Controller)..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CORERESET_PF:2.3.100} \
    -component_name {CORERESET_PF_C0}

# 3. Init Monitor - Track device initialization
print_info "Creating PF_INIT_MONITOR..."
create_and_configure_core \
    -core_vlnv {Actel:SgCore:PF_INIT_MONITOR:2.0.307} \
    -component_name {PF_INIT_MONITOR_C0}

# 4. JTAG Debug Interface
print_info "Creating CoreJTAGDebug..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:COREJTAGDEBUG:4.0.100} \
    -component_name {COREJTAGDEBUG_C0} \
    -params { \
        "JTAG_INTERFACE_TYPE:COREJTAGDEBUG_IF" \
        "NUM_DEBUG_TARGETS:1" \
    }

# 5. MI-V External Subsystem (MIV_ESS) - UART and GPIO peripherals
print_info "Creating MIV_ESS (External Subsystem - UART + GPIO)..."
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_ESS:3.0.100} \
    -component_name {MIV_ESS_C0} \
    -params { \
        "ENABLE_UART_0:true" \
        "ENABLE_GPIO_0:true" \
        "GPIO_0_WIDTH:8" \
    }

# 6. CoreTimer - Timer peripherals
print_info "Creating CoreTimer instances..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_C0} \
    -params {"INTACTIVEHIGH:true" "WIDTH:32"}

create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_C1} \
    -params {"INTACTIVEHIGH:true" "WIDTH:32"}

# 7. External SRAM (32kB) via AHB-Lite
print_info "Creating PF_SRAM_AHB (32kB external memory)..."
create_and_configure_core \
    -core_vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:1.2.108} \
    -component_name {PF_SRAM_AHB_C0} \
    -params { \
        "MEMSIZE:32768" \
        "INTERFACE_TYPE:0" \
    }

print_info "All cores created successfully"

# ==============================================================================
# Build SmartDesign
# ==============================================================================

print_msg "Building SmartDesign: $smartdesign_name"

# Create SmartDesign
create_smartdesign -sd_name $smartdesign_name

# Disable auto-promotion of pad pins (we'll control this manually)
auto_promote_pad_pins -promote_all 0

# Create top-level ports
print_info "Creating top-level I/O ports..."

# Clock and reset
sd_create_scalar_port -sd_name $smartdesign_name -port_name {REF_CLK_50MHz} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {USER_RST_N} -port_direction {IN}

# JTAG interface
sd_create_scalar_port -sd_name $smartdesign_name -port_name {JTAG_TCK} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {JTAG_TDI} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {JTAG_TDO} -port_direction {OUT}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {JTAG_TMS} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {JTAG_TRSTN} -port_direction {IN}

# UART interface
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_RX} -port_direction {IN}
sd_create_scalar_port -sd_name $smartdesign_name -port_name {UART_TX} -port_direction {OUT}

# GPIO - LEDs and switches from eval board
sd_create_bus_port -sd_name $smartdesign_name -port_name {GPIO_OUT} -port_direction {OUT} -port_range {[7:0]}
sd_create_bus_port -sd_name $smartdesign_name -port_name {GPIO_IN} -port_direction {IN} -port_range {[7:0]}

# Instantiate components
print_info "Instantiating components..."

sd_instantiate_component -sd_name $smartdesign_name -component_name $miv_component_name -instance_name {MIV_RV32_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_CCC_C0} -instance_name {PF_CCC_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CORERESET_PF_C0} -instance_name {CORERESET_PF_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_INIT_MONITOR_C0} -instance_name {PF_INIT_MONITOR_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {COREJTAGDEBUG_C0} -instance_name {COREJTAGDEBUG_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {MIV_ESS_C0} -instance_name {MIV_ESS_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C0} -instance_name {CoreTimer_C0}
sd_instantiate_component -sd_name $smartdesign_name -component_name {CoreTimer_C1} -instance_name {CoreTimer_C1}
sd_instantiate_component -sd_name $smartdesign_name -component_name {PF_SRAM_AHB_C0} -instance_name {PF_SRAM_AHB_C0}

# Instantiate clock buffer macro
sd_instantiate_macro -sd_name $smartdesign_name -macro_name {CLKBUF} -instance_name {CLKBUF_0}

# Connect clocks
print_info "Connecting clock signals..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CLKBUF_0:PAD" "REF_CLK_50MHz"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CLKBUF_0:Y" "PF_CCC_C0:REF_CLK_0"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:OUT0_FABCLK_0" "CORERESET_PF_C0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:OUT0_FABCLK_0" "MIV_RV32_C0:CLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:OUT0_FABCLK_0" "MIV_ESS_C0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:OUT0_FABCLK_0" "CoreTimer_C0:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:OUT0_FABCLK_0" "CoreTimer_C1:PCLK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:OUT0_FABCLK_0" "PF_SRAM_AHB_C0:HCLK"}

# Connect resets
print_info "Connecting reset signals..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"PF_CCC_C0:PLL_LOCK_0" "CORERESET_PF_C0:PLL_LOCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"USER_RST_N" "CORERESET_PF_C0:EXT_RST_N"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:FABRIC_RESET_N" "MIV_RV32_C0:RESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:FABRIC_RESET_N" "MIV_ESS_C0:PRESETN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:FABRIC_RESET_N" "CoreTimer_C0:PRESETn"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:FABRIC_RESET_N" "CoreTimer_C1:PRESETn"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:FABRIC_RESET_N" "PF_SRAM_AHB_C0:HRESETN"}

# Connect init monitor
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:FPGA_POR_N" "PF_INIT_MONITOR_C0:FABRIC_POR_N"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CORERESET_PF_C0:INIT_DONE" "PF_INIT_MONITOR_C0:DEVICE_INIT_DONE"}

# Connect JTAG debug interface
print_info "Connecting JTAG debug interface..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TGT_TCK_0" "MIV_RV32_C0:JTAG_TCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TGT_TDI_0" "MIV_RV32_C0:JTAG_TDI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TGT_TDO_0" "MIV_RV32_C0:JTAG_TDO"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TGT_TMS_0" "MIV_RV32_C0:JTAG_TMS"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TGT_TRSTN_0" "MIV_RV32_C0:JTAG_TRSTN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TCK" "JTAG_TCK"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TDI" "JTAG_TDI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TDO" "JTAG_TDO"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TMS" "JTAG_TMS"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"COREJTAGDEBUG_C0:TRSTB" "JTAG_TRSTN"}

# Connect UART
print_info "Connecting UART interface..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0:UART_RX" "UART_RX"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0:UART_TX" "UART_TX"}

# Connect GPIO
print_info "Connecting GPIO interface..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0:GPIO_IN" "GPIO_IN"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0:GPIO_OUT" "GPIO_OUT"}

# Connect interrupts
print_info "Connecting interrupt signals..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreTimer_C0:TIMINT" "MIV_RV32_C0:MSYS_EI"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"CoreTimer_C1:TIMINT" "MIV_RV32_C0:EXT_IRQ"}

# Connect APB bus interfaces
print_info "Connecting APB bus interfaces..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_C0:APB_INITIATOR" "MIV_ESS_C0:APB_mINITIATOR"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0:APB_mTARGET_0" "CoreTimer_C0:APBslave"}
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_ESS_C0:APB_mTARGET_1" "CoreTimer_C1:APBslave"}

# Connect AHB bus interface to external SRAM
print_info "Connecting AHB bus to external SRAM..."
sd_connect_pins -sd_name $smartdesign_name -pin_names {"MIV_RV32_C0:AHBL_M_TARGET" "PF_SRAM_AHB_C0:AHBSlaveInterface"}

# Mark unused pins
print_info "Marking unused pins..."
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_RV32_C0:JTAG_TDO_DR}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_RV32_C0:EXT_RESETN}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {MIV_RV32_C0:TIME_COUNT_OUT}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0:PLL_POWERDOWN_B}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0:PCIE_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0:USRAM_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0:SRAM_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0:XCVR_INIT_DONE}
sd_mark_pins_unused -sd_name $smartdesign_name -pin_names {PF_INIT_MONITOR_C0:AUTOCALIB_DONE}

# Tie constants to CORERESET_PF status inputs
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0:BANK_x_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0:BANK_y_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0:SS_BUSY} -value {GND}
sd_connect_pins_to_constant -sd_name $smartdesign_name -pin_names {CORERESET_PF_C0:FF_US_RESTORE} -value {GND}

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
print_info "  2. Run synthesis: source tcl_scripts/build_miv_rv32_project.tcl"
print_info "  3. Generate bitstream and program device"
print_info ""
print_msg "TCL Monster - MI-V RV32 Project Creation Complete"
