# common.tcl - Shared project variables and IP version definitions
#
# Source this file from numbered scripts (1_create, 2_constrain, 4_implement, 5_program)
# to maintain consistent project parameters and IP versions across all build stages.
#
# Usage:
#   source ./tcl_scripts/lib/common.tcl
#   # Then use $project_name, $project_location, IP version variables, etc.

# =============================================================================
# Project Configuration
# =============================================================================

# CUSTOMIZE THESE FOR YOUR PROJECT:
set project_name "my_design"
set project_location "C:/projects"
set top_module "top"

# Device Configuration
set device_family "PolarFire"
set device_die "MPF300TS"
set device_package "FCG1152"
set device_speed "-1"
set device_voltage "1.0"
set device_part_range "IND"  # Device-specific! MPF300TS only supports IND

# Derived paths (don't modify)
set projectDir "$project_location/$project_name"

# =============================================================================
# IP Version Definitions (Libero 2024.2)
# =============================================================================
#
# These versions are tested together and known to work.
# Update when changing Libero versions or updating IP cores.
#
# Source: Analysis of 64 PolarFire reference designs

# Clock and Reset
set PF_CCC_ver {3.5.100}             # Clock Conditioning Circuit (PLL/DLL)
set CORERESET_PF_ver {5.1.100}       # Reset controller

# Processor Cores
set MIV_RV32_ver {3.1.200}           # MI-V RISC-V RV32IMC softcore

# Memory Controllers
set PF_DDR3_ver {3.9.200}            # DDR3 memory controller
set PF_DDR4_ver {3.9.200}            # DDR4 memory controller

# High-Speed Interfaces
set PF_XCVR_ver {3.1.100}            # XCVR (transceiver) controller
set PF_PCIE_ver {3.0.100}            # PCIe interface
set PF_SERDES_ver {3.0.100}          # SERDES interface

# Communication Peripherals
set CoreUARTapb_ver {5.7.100}        # UART (APB interface)
set CoreGPIO_ver {3.2.102}           # GPIO controller
set CoreSPI_ver {5.2.104}            # SPI controller
set CoreI2C_ver {7.2.101}            # I2C controller

# Video/Display
set PF_HDMI_ver {2.0.100}            # HDMI interface
set PF_MIPI_ver {2.0.100}            # MIPI interface

# Fabric Resources
set COREABC_ver {3.5.100}            # ABC (Advanced Bus Controller)
set COREAHBLITE_ver {5.5.101}        # AHB-Lite interconnect
set COREAPB3_ver {4.2.100}           # APB3 interconnect

# Add more IP versions as needed for your project

# =============================================================================
# Common Helper Functions
# =============================================================================

# Print banner with timestamp
proc print_banner {message} {
    puts "=============================================================================="
    puts "$message"
    puts "Time: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
    puts "=============================================================================="
}

# Print step header
proc print_step {step_num step_name} {
    puts ""
    puts "\[Step $step_num\] $step_name..."
    puts "------------------------------------------------------------------------------"
}

# Check if file exists (useful for constraint checking)
proc file_exists_or_error {filepath description} {
    if {![file exists $filepath]} {
        puts "ERROR: $description not found at: $filepath"
        return 0
    }
    puts "Found $description: $filepath"
    return 1
}

# =============================================================================
# Usage Examples
# =============================================================================
#
# In 1_create_design.tcl:
#   source ./tcl_scripts/lib/common.tcl
#   print_banner "Creating $project_name"
#   new_project -location $project_location -name $project_name ...
#
# In 2_constrain_design.tcl:
#   source ./tcl_scripts/lib/common.tcl
#   print_banner "Applying constraints to $project_name"
#   file_exists_or_error "$projectDir/constraint/io.pdc" "I/O constraints"
#
# In IP component scripts:
#   source ./tcl_scripts/lib/common.tcl
#   create_and_configure_core \
#       -core_vlnv "Actel:SgCore:PF_CCC:${PF_CCC_ver}" \
#       -component_name {PF_CCC_C0}
#
# =============================================================================

puts "Loaded common.tcl: project=$project_name, device=$device_die, location=$project_location"
