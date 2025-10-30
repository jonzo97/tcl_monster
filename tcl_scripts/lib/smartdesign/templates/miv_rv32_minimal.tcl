# ==============================================================================
# MI-V RV32 Minimal Template
# ==============================================================================
#
# Creates minimal MI-V RISC-V system with:
# - MI-V RV32 core (RV32I or RV32IMC)
# - Clock conditioning (CCC)
# - Reset controller
# - JTAG debug interface
# - GPIO for LEDs/buttons
#
# This template demonstrates using the SmartDesign automation libraries.
#
# Usage:
#   source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl
#   ::miv_minimal::create $sd_name $config
#
# ==============================================================================

# Load interconnect generators
source [file join [file dirname [info script]] "../interconnect/clock_reset_tree.tcl"]
source [file join [file dirname [info script]] "../interconnect/apb_interconnect.tcl"]
source [file join [file dirname [info script]] "../utilities/sd_helpers.tcl"]

namespace eval ::miv_minimal {
    namespace import ::sd_helpers::*
    namespace import ::clock_reset::*
    namespace import ::apb_interconnect::*
}

# ==============================================================================
# Create Minimal MI-V RV32 System
# ==============================================================================

# Create complete minimal MI-V system in SmartDesign
#
# Args:
#   sd_name: Name for SmartDesign (e.g., "MIV_Minimal")
#   config: Configuration dictionary (optional):
#     - core_variant: "RV32I" or "RV32IMC" (default: RV32IMC)
#     - system_clock_mhz: System clock frequency (default: 50)
#     - gpio_width: Number of GPIO pins (default: 8)
#     - add_uart: Include UART peripheral (default: true)
#
proc ::miv_minimal::create {sd_name {config {}}} {
    info "Creating minimal MI-V RV32 system: $sd_name"

    # Parse configuration
    set core_variant [dict exists $config core_variant] ? [dict get $config core_variant] : "RV32IMC"
    set sys_clk_mhz [dict exists $config system_clock_mhz] ? [dict get $config system_clock_mhz] : 50
    set gpio_width [dict exists $config gpio_width] ? [dict get $config gpio_width] : 8
    set add_uart [dict exists $config add_uart] ? [dict get $config add_uart] : true

    info "Configuration:"
    info "  Core: $core_variant"
    info "  System clock: $sys_clk_mhz MHz"
    info "  GPIO width: $gpio_width"
    info "  UART: $add_uart"

    # Create SmartDesign
    create_smartdesign -sd_name $sd_name

    # ===========================================================================
    # 1. Add Clock and Reset Components
    # ===========================================================================

    info "Adding clock and reset components..."

    # Assume these components already exist in the project
    # (created via IP generators or templates)
    set components [list \
        "PF_CCC_C0" \
        "PF_INIT_MONITOR_C0" \
        "CORERESET_PF_C0" \
    ]

    foreach comp $components {
        if {[component_exists $comp]} {
            add_component $sd_name $comp "${comp}_0"
        } else {
            warn "Component $comp not found - you may need to create it first"
        }
    }

    # ===========================================================================
    # 2. Add MI-V RV32 Core
    # ===========================================================================

    info "Adding MI-V RV32 core..."

    set miv_comp "MIV_RV32_CFG1_C0"
    if {[component_exists $miv_comp]} {
        add_component $sd_name $miv_comp "MIV_RV32_C0"
    } else {
        warn "MI-V core component not found - create using IP catalog"
    }

    # ===========================================================================
    # 3. Add JTAG Debug
    # ===========================================================================

    info "Adding JTAG debug interface..."

    set jtag_comp "CoreJTAGDebug_C0"
    if {[component_exists $jtag_comp]} {
        add_component $sd_name $jtag_comp "${jtag_comp}_0"

        # Connect JTAG to MI-V core
        catch {
            connect_pins $sd_name [list \
                "MIV_RV32_C0:JTAG_TDI" \
                "CoreJTAGDebug_C0_0:TDI" \
            ]
            connect_pins $sd_name [list \
                "MIV_RV32_C0:JTAG_TDO" \
                "CoreJTAGDebug_C0_0:TDO" \
            ]
            connect_pins $sd_name [list \
                "MIV_RV32_C0:JTAG_TCK" \
                "CoreJTAGDebug_C0_0:TCK" \
            ]
            connect_pins $sd_name [list \
                "MIV_RV32_C0:JTAG_TMS" \
                "CoreJTAGDebug_C0_0:TMS" \
            ]
        }
    }

    # ===========================================================================
    # 4. Add Peripherals (GPIO, UART)
    # ===========================================================================

    info "Adding peripherals..."

    set peripherals {}

    # GPIO
    set gpio_comp "CoreGPIO_${gpio_width}bit_C0"
    if {[component_exists $gpio_comp]} {
        add_component $sd_name $gpio_comp "CoreGPIO_C0"
        lappend peripherals [list "CoreGPIO_C0" 0x70000000 0x1000]
    } else {
        warn "GPIO component not found"
    }

    # UART (optional)
    if {$add_uart} {
        set uart_comp "CoreUARTapb_C0"
        if {[component_exists $uart_comp]} {
            add_component $sd_name $uart_comp "CoreUARTapb_C0"
            lappend peripherals [list "CoreUARTapb_C0" 0x70001000 0x1000]
        } else {
            warn "UART component not found"
        }
    }

    # ===========================================================================
    # 5. Clock and Reset Distribution
    # ===========================================================================

    info "Distributing clock and reset..."

    # Clock tree
    set clock_src "PF_CCC_C0_0:OUT0_FABCLK_0"
    set clock_consumers [list \
        "CORERESET_PF_C0_0:CLK" \
        "MIV_RV32_C0:CLK" \
        "CoreGPIO_C0:PCLK" \
    ]

    if {$add_uart} {
        lappend clock_consumers "CoreUARTapb_C0:PCLK"
    }

    distribute_clock $sd_name $clock_src $clock_consumers

    # Reset tree
    # Connect init monitor -> reset controller
    catch {
        connect_pins $sd_name [list \
            "PF_INIT_MONITOR_C0_0:DEVICE_INIT_DONE" \
            "CORERESET_PF_C0_0:INIT_DONE" \
        ]
    }

    set reset_src "CORERESET_PF_C0_0:FABRIC_RESET_N"
    set reset_consumers [list \
        "MIV_RV32_C0:RESETN" \
        "CoreGPIO_C0:PRESETN" \
    ]

    if {$add_uart} {
        lappend reset_consumers "CoreUARTapb_C0:PRESETN"
    }

    distribute_reset $sd_name $reset_src $reset_consumers

    # ===========================================================================
    # 6. APB Interconnect
    # ===========================================================================

    info "Connecting APB peripherals..."

    if {[llength $peripherals] > 0} {
        print_address_map $peripherals
        connect_peripherals $sd_name "MIV_RV32_C0:APB_MSTR" $peripherals
    }

    # ===========================================================================
    # 7. Create Top-Level Ports
    # ===========================================================================

    info "Creating top-level ports..."

    # External clock input
    catch {
        sd_create_scalar_port -sd_name $sd_name -port_name {REF_CLK_50MHZ} -port_direction {IN}
        connect_pins $sd_name [list "REF_CLK_50MHZ" "PF_CCC_C0_0:REF_CLK_0"]
    }

    # GPIO output
    catch {
        sd_create_bus_port -sd_name $sd_name -port_name {GPIO_OUT} -port_direction {OUT} -port_range "\[${gpio_width}-1:0\]"
        connect_pins $sd_name [list "GPIO_OUT" "CoreGPIO_C0:GPIO_OUT"]
    }

    # UART signals (if enabled)
    if {$add_uart} {
        catch {
            sd_create_scalar_port -sd_name $sd_name -port_name {UART_RX} -port_direction {IN}
            sd_create_scalar_port -sd_name $sd_name -port_name {UART_TX} -port_direction {OUT}
            connect_pins $sd_name [list "UART_RX" "CoreUARTapb_C0:RX"]
            connect_pins $sd_name [list "UART_TX" "CoreUARTapb_C0:TX"]
        }
    }

    # ===========================================================================
    # 8. Finalize
    # ===========================================================================

    # Save SmartDesign
    save_smartdesign -sd_name $sd_name

    # Generate SmartDesign
    generate_component -component_name $sd_name

    info "Minimal MI-V system '$sd_name' created successfully!"
    info ""
    info "Next steps:"
    info "  1. Review SmartDesign in Libero GUI (optional)"
    info "  2. Set as root: set_root -module ${sd_name}::work"
    info "  3. Run synthesis and P&R"

    return $sd_name
}

# ==============================================================================
# Convenience Functions
# ==============================================================================

# Create system and set as root in one call
proc ::miv_minimal::create_and_set_root {sd_name {config {}}} {
    create $sd_name $config
    set_root -module "${sd_name}::work"
}

# ==============================================================================
# Export Functions
# ==============================================================================

namespace export create create_and_set_root
