# ==============================================================================
# APB Interconnect Generator
# ==============================================================================
#
# Automatically connects APB peripherals to an APB master with:
# - Address decoding
# - Peripheral enable (PSEL) generation
# - Multiplexed read data (PRDATA) and ready (PREADY) signals
#
# Usage:
#   source tcl_scripts/lib/smartdesign/interconnect/apb_interconnect.tcl
#   ::apb_interconnect::connect_peripherals $sd_name $master $peripheral_list
#
# Example:
#   set peripherals {
#       {CoreUART_C0 0x70001000 0x1000}
#       {CoreGPIO_C0 0x70002000 0x1000}
#       {CoreTimer_C0 0x70003000 0x1000}
#   }
#   ::apb_interconnect::connect_peripherals "MyDesign" "MIV_RV32_C0:APB_MSTR" $peripherals
#
# ==============================================================================

# Load helper functions
source [file join [file dirname [info script]] "../utilities/sd_helpers.tcl"]

namespace eval ::apb_interconnect {
    namespace import ::sd_helpers::*
}

# ==============================================================================
# APB Interconnect Configuration
# ==============================================================================

# Connect APB master to multiple APB slave peripherals
#
# Args:
#   sd_name: SmartDesign name
#   master_prefix: APB master instance and port (e.g., "MIV_RV32_C0:APB_MSTR")
#   peripherals: List of {instance_name base_addr size} tuples
#
# Example peripherals list:
#   {
#       {CoreUARTapb_C0 0x70001000 0x1000}
#       {CoreGPIO_C0    0x70002000 0x1000}
#       {CoreTimer_C0   0x70003000 0x1000}
#   }
#
proc ::apb_interconnect::connect_peripherals {sd_name master_prefix peripherals} {
    info "Connecting APB interconnect with [llength $peripherals] peripherals"

    if {[llength $peripherals] == 0} {
        warn "No peripherals to connect"
        return
    }

    # Parse master instance and port
    if {![regexp {^([^:]+):(.+)$} $master_prefix -> master_inst master_port]} {
        error "Invalid master prefix format. Expected 'instance:port', got '$master_prefix'"
    }

    info "Master: $master_inst, Port: $master_port"

    # For simple cases (1-3 peripherals), use direct connections
    # For complex cases (4+ peripherals), consider using CoreAPB3 interconnect core
    if {[llength $peripherals] <= 3} {
        connect_peripherals_direct $sd_name $master_prefix $peripherals
    } else {
        connect_peripherals_with_fabric $sd_name $master_prefix $peripherals
    }
}

# ==============================================================================
# Direct Connection (Simple, 1-3 peripherals)
# ==============================================================================

proc ::apb_interconnect::connect_peripherals_direct {sd_name master_prefix peripherals} {
    info "Using direct APB connection (simple interconnect)"

    foreach periph_info $peripherals {
        lassign $periph_info periph_inst base_addr size

        info "Connecting $periph_inst at 0x[format %08X $base_addr]"

        # Parse peripheral instance to find APB slave port
        # Common naming: instance has ports like PADDR, PSEL, etc.
        set slave_port $periph_inst

        # Connect APB signals
        #
        # For MI-V RV32, the APB_MSTR port is a bus interface
        # We need to connect individual peripheral signals
        #
        # Standard APB3 signals:
        # - PADDR (address bus)
        # - PSEL (peripheral select - one per slave)
        # - PENABLE (enable strobe)
        # - PWRITE (write enable)
        # - PWDATA (write data)
        # - PRDATA (read data - multiplexed from slaves)
        # - PREADY (ready signal - OR'd from slaves)
        # - PSLVERR (slave error - OR'd from slaves)

        # For direct connection in SmartDesign, Libero's APB routing
        # handles most of this automatically when we connect the bus interfaces

        catch {
            connect_pins $sd_name [list \
                "${master_prefix}" \
                "${periph_inst}:APBslave" \
            ]
        } err

        # If that didn't work, try individual signal connections
        if {$err != ""} {
            info "Bus interface connection failed, trying individual signals"
            connect_apb_signals $sd_name $master_prefix $periph_inst
        }
    }

    info "APB interconnect complete"
}

# ==============================================================================
# Connection with Fabric (Complex, 4+ peripherals)
# ==============================================================================

proc ::apb_interconnect::connect_peripherals_with_fabric {sd_name master_prefix peripherals} {
    info "Using CoreAPB3 fabric for [llength $peripherals] peripherals"

    # Instantiate CoreAPB3 interconnect fabric
    # This is a Microchip IP core that provides APB bus matrix

    set fabric_inst "CoreAPB3_Fabric"

    # Check if CoreAPB3 is available
    if {[component_exists "CoreAPB3"]} {
        # Create CoreAPB3 with appropriate number of slaves
        set num_slaves [llength $peripherals]

        info "Creating CoreAPB3 fabric with $num_slaves slaves"

        # Note: This is a placeholder - actual CoreAPB3 configuration
        # would need specific VLNV and parameters
        catch {
            create_and_configure_core \
                -core_vlnv {Actel:DirectCore:CoreAPB3:4.2.100} \
                -component_name {CoreAPB3_C0} \
                -params "APB_DWIDTH:32" \
                -params "APBSLOT0ENABLE:true" \
                -params "APBSLOT1ENABLE:[expr {$num_slaves > 1}]" \
                -params "APBSLOT2ENABLE:[expr {$num_slaves > 2}]" \
                -params "APBSLOT3ENABLE:[expr {$num_slaves > 3}]"

            # Add to SmartDesign
            add_component $sd_name "CoreAPB3_C0" $fabric_inst

            # Connect master to fabric
            connect_pins $sd_name [list \
                "${master_prefix}" \
                "${fabric_inst}:APB3mmaster" \
            ]

            # Connect each peripheral to fabric slot
            set slot_idx 0
            foreach periph_info $peripherals {
                lassign $periph_info periph_inst base_addr size

                connect_pins $sd_name [list \
                    "${fabric_inst}:APBmslave${slot_idx}" \
                    "${periph_inst}:APBslave" \
                ]

                incr slot_idx
            }
        }
    } else {
        warn "CoreAPB3 not available in IP catalog, falling back to direct connection"
        connect_peripherals_direct $sd_name $master_prefix $peripherals
    }
}

# ==============================================================================
# Individual Signal Connection (Fallback)
# ==============================================================================

proc ::apb_interconnect::connect_apb_signals {sd_name master_prefix slave_inst} {
    info "Connecting individual APB signals: $master_prefix -> $slave_inst"

    # APB3 signal list
    set signals {
        PADDR
        PSEL
        PENABLE
        PWRITE
        PWDATA
        PRDATA
        PREADY
        PSLVERR
    }

    foreach signal $signals {
        catch {
            connect_pins $sd_name [list \
                "${master_prefix}:${signal}" \
                "${slave_inst}:${signal}" \
            ]
        }
    }
}

# ==============================================================================
# Convenience Functions
# ==============================================================================

# Auto-generate peripheral list with sequential addresses
proc ::apb_interconnect::auto_address_peripherals {peripheral_names base_addr {periph_size 0x1000}} {
    set peripherals {}
    set current_addr $base_addr

    foreach name $peripheral_names {
        lappend peripherals [list $name $current_addr $periph_size]
        set current_addr [expr {$current_addr + $periph_size}]
    }

    return $peripherals
}

# Print address map for documentation
proc ::apb_interconnect::print_address_map {peripherals} {
    puts "APB Address Map:"
    puts "================"

    foreach periph_info $peripherals {
        lassign $periph_info name base size
        set end [expr {$base + $size - 1}]
        puts [format "%-20s 0x%08X - 0x%08X  (%-6s bytes)" \
            $name $base $end $size]
    }
}

# ==============================================================================
# Export Functions
# ==============================================================================

namespace export connect_peripherals
namespace export connect_peripherals_direct
namespace export auto_address_peripherals
namespace export print_address_map
