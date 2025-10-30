# ==============================================================================
# SmartDesign Helper Functions
# ==============================================================================
#
# Provides utilities for SmartDesign automation:
# - Component introspection
# - Pin connection validation
# - Address map generation
# - Naming convention enforcement
#
# ==============================================================================

# Include guard - prevent multiple loads
if {[info exists ::sd_helpers::loaded]} {
    return
}

namespace eval ::sd_helpers {
    variable verbose 1
    variable loaded 1
}

# ==============================================================================
# Logging and Error Handling
# ==============================================================================

proc ::sd_helpers::log {level message} {
    variable verbose
    if {$verbose || $level == "ERROR"} {
        set timestamp [clock format [clock seconds] -format {%H:%M:%S}]
        puts "\[$timestamp\] \[$level\] $message"
    }
}

proc ::sd_helpers::info {message} {
    log "INFO" $message
}

proc ::sd_helpers::warn {message} {
    log "WARN" $message
}

proc ::sd_helpers::error {message} {
    log "ERROR" $message
    error $message
}

# ==============================================================================
# Component Management
# ==============================================================================

# Add component to SmartDesign with error checking
proc ::sd_helpers::add_component {sd_name component_name instance_name} {
    info "Adding component $component_name as $instance_name to $sd_name"

    if {[catch {
        sd_instantiate_component \
            -sd_name $sd_name \
            -component_name $component_name \
            -instance_name $instance_name
    } err]} {
        error "Failed to add component $component_name: $err"
    }

    return $instance_name
}

# ==============================================================================
# Pin Connection Utilities
# ==============================================================================

# Connect two pins with error checking
proc ::sd_helpers::connect_pins {sd_name pin_list} {
    info "Connecting pins: [join $pin_list { <-> }]"

    if {[llength $pin_list] < 2} {
        error "connect_pins requires at least 2 pins, got [llength $pin_list]"
    }

    if {[catch {
        sd_connect_pins -sd_name $sd_name -pin_names $pin_list
    } err]} {
        warn "Failed to connect pins [join $pin_list {, }]: $err"
        return 0
    }

    return 1
}

# Connect pin to a constant value (0 or 1)
proc ::sd_helpers::tie_pin {sd_name instance_pin value} {
    if {$value != 0 && $value != 1} {
        error "tie_pin value must be 0 or 1, got $value"
    }

    set const_name "CONST_${value}"

    # Create constant component if it doesn't exist
    # (Libero has built-in constants we can use)

    connect_pins $sd_name [list $instance_pin $const_name]
}

# ==============================================================================
# Clock and Reset Distribution
# ==============================================================================

# Connect clock signal to multiple instances
proc ::sd_helpers::fanout_clock {sd_name source_pin dest_pins} {
    info "Fanning out clock: $source_pin -> [llength $dest_pins] destinations"

    foreach dest $dest_pins {
        connect_pins $sd_name [list $source_pin $dest]
    }
}

# Connect reset signal to multiple instances
proc ::sd_helpers::fanout_reset {sd_name source_pin dest_pins} {
    info "Fanning out reset: $source_pin -> [llength $dest_pins] destinations"

    foreach dest $dest_pins {
        connect_pins $sd_name [list $source_pin $dest]
    }
}

# ==============================================================================
# Bus Interface Utilities
# ==============================================================================

# Connect APB master to APB slave
proc ::sd_helpers::connect_apb {sd_name master_prefix slave_prefix} {
    info "Connecting APB: $master_prefix -> $slave_prefix"

    # Standard APB signals
    set apb_signals {
        PADDR
        PSEL
        PENABLE
        PWRITE
        PWDATA
        PRDATA
        PREADY
        PSLVERR
    }

    foreach signal $apb_signals {
        set master_pin "${master_prefix}:${signal}"
        set slave_pin "${slave_prefix}:${signal}"

        # Try to connect, but don't fail if signal doesn't exist
        # (some APB peripherals don't implement all signals)
        catch {
            connect_pins $sd_name [list $master_pin $slave_pin]
        }
    }
}

# Connect AXI master to AXI slave
proc ::sd_helpers::connect_axi4 {sd_name master_if slave_if} {
    info "Connecting AXI4: $master_if -> $slave_if"

    # AXI4 uses bus interfaces, simpler than individual signals
    if {[catch {
        sd_connect_pins -sd_name $sd_name -pin_names [list $master_if $slave_if]
    } err]} {
        error "Failed to connect AXI interfaces: $err"
    }
}

# ==============================================================================
# Address Map Generation
# ==============================================================================

# Generate address decoder configuration for APB peripherals
# Returns dict of peripheral -> {base_addr, size}
proc ::sd_helpers::generate_apb_address_map {peripherals base_addr} {
    info "Generating APB address map starting at 0x[format %08X $base_addr]"

    set address_map [dict create]
    set current_addr $base_addr

    # Standard peripheral sizes (can be overridden)
    set default_sizes {
        CoreUART     0x1000
        CoreTimer    0x1000
        CoreGPIO     0x1000
        CoreSPI      0x1000
        CoreI2C      0x1000
        CorePWM      0x1000
    }

    foreach periph $peripherals {
        # Extract peripheral type from instance name
        regexp {^([A-Za-z0-9_]+)_C?[0-9]+$} $periph -> periph_type

        # Lookup size or use default
        if {[dict exists $default_sizes $periph_type]} {
            set size [dict get $default_sizes $periph_type]
        } else {
            set size 0x1000
            warn "Unknown peripheral type $periph_type, using default size 0x1000"
        }

        dict set address_map $periph [dict create \
            base $current_addr \
            size $size \
            end [expr {$current_addr + $size - 1}] \
        ]

        info "  $periph: 0x[format %08X $current_addr] - 0x[format %08X [expr {$current_addr + $size - 1}]]"

        set current_addr [expr {$current_addr + $size}]
    }

    return $address_map
}

# ==============================================================================
# Validation Utilities
# ==============================================================================

# Check if component exists in catalog
proc ::sd_helpers::component_exists {component_name} {
    # Try to query component info
    if {[catch {
        get_component_vlnv $component_name
    }]} {
        return 0
    }
    return 1
}

# Validate instance name (no special characters, not too long)
proc ::sd_helpers::validate_instance_name {name} {
    if {[string length $name] > 64} {
        error "Instance name too long (>64 chars): $name"
    }

    if {![regexp {^[A-Za-z][A-Za-z0-9_]*$} $name]} {
        error "Invalid instance name (must start with letter, alphanumeric+underscore only): $name"
    }

    return 1
}

# ==============================================================================
# Export Functions
# ==============================================================================

namespace export log info warn error
namespace export add_component connect_pins tie_pin
namespace export fanout_clock fanout_reset
namespace export connect_apb connect_axi4
namespace export generate_apb_address_map
namespace export component_exists validate_instance_name
