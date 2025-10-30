# ==============================================================================
# Clock and Reset Distribution Tree Generator
# ==============================================================================
#
# Automates clock and reset distribution in SmartDesign:
# - Clock fanout from CCC/PLL to all synchronous components
# - Reset tree generation (power-on reset, synchronous resets)
# - Clock domain management
#
# Usage:
#   source tcl_scripts/lib/smartdesign/interconnect/clock_reset_tree.tcl
#   ::clock_reset::create_tree $sd_name $config
#
# ==============================================================================

# Load helper functions
source [file join [file dirname [info script]] "../utilities/sd_helpers.tcl"]

namespace eval ::clock_reset {
    namespace import ::sd_helpers::*
}

# ==============================================================================
# Standard Clock/Reset Tree Creation
# ==============================================================================

# Create standard clock and reset distribution tree
#
# Args:
#   sd_name: SmartDesign name
#   config: Configuration dictionary with keys:
#     - clock_source: Instance providing clock (e.g., "PF_CCC_C0:OUT0_FABCLK_0")
#     - clock_consumers: List of instances needing clock (e.g., {"MIV_RV32_C0:CLK" "CoreUART_C0:PCLK"})
#     - reset_source: Instance providing reset (e.g., "CORERESET_PF_C0:FABRIC_RESET_N")
#     - reset_consumers: List of instances needing reset
#     - reset_polarity: "active_low" or "active_high" (default: active_low)
#
proc ::clock_reset::create_tree {sd_name config} {
    info "Creating clock and reset distribution tree"

    # Extract configuration
    if {![dict exists $config clock_source]} {
        error "clock_source not specified in config"
    }
    if {![dict exists $config reset_source]} {
        error "reset_source not specified in config"
    }

    set clock_src [dict get $config clock_source]
    set reset_src [dict get $config reset_source]

    set clock_consumers [dict exists $config clock_consumers] ? [dict get $config clock_consumers] : {}
    set reset_consumers [dict exists $config reset_consumers] ? [dict get $config reset_consumers] : {}

    # Distribute clock
    if {[llength $clock_consumers] > 0} {
        distribute_clock $sd_name $clock_src $clock_consumers
    }

    # Distribute reset
    if {[llength $reset_consumers] > 0} {
        distribute_reset $sd_name $reset_src $reset_consumers
    }

    info "Clock/reset tree complete"
}

# ==============================================================================
# Clock Distribution
# ==============================================================================

proc ::clock_reset::distribute_clock {sd_name clock_source consumers} {
    info "Distributing clock: $clock_source -> [llength $consumers] consumers"

    foreach consumer $consumers {
        if {[catch {
            connect_pins $sd_name [list $clock_source $consumer]
        } err]} {
            warn "Failed to connect clock to $consumer: $err"
        }
    }
}

# Distribute multiple clocks (multi-clock domain designs)
proc ::clock_reset::distribute_multi_clock {sd_name clock_map} {
    info "Distributing multiple clock domains"

    dict for {clock_name clock_info} $clock_map {
        set source [dict get $clock_info source]
        set consumers [dict get $clock_info consumers]

        info "Clock domain '$clock_name': $source -> [llength $consumers] consumers"
        distribute_clock $sd_name $source $consumers
    }
}

# ==============================================================================
# Reset Distribution
# ==============================================================================

proc ::clock_reset::distribute_reset {sd_name reset_source consumers {polarity "active_low"}} {
    info "Distributing reset: $reset_source -> [llength $consumers] consumers ($polarity)"

    foreach consumer $consumers {
        if {[catch {
            connect_pins $sd_name [list $reset_source $consumer]
        } err]} {
            warn "Failed to connect reset to $consumer: $err"
        }
    }
}

# ==============================================================================
# Standard Clock/Reset Component Creation
# ==============================================================================

# Create standard PolarFire clock conditioning circuit (PF_CCC)
#
# Args:
#   sd_name: SmartDesign name
#   config: Configuration with keys:
#     - instance_name: Name for CCC instance (default: "PF_CCC_C0")
#     - ref_clock_mhz: Reference clock frequency in MHz (default: 50)
#     - output_clocks: List of {freq_mhz name} pairs
#
# Returns: Instance name
#
proc ::clock_reset::create_ccc {sd_name {config {}}} {
    set inst_name [dict exists $config instance_name] ? [dict get $config instance_name] : "PF_CCC_C0"
    set ref_freq [dict exists $config ref_clock_mhz] ? [dict get $config ref_clock_mhz] : 50
    set outputs [dict exists $config output_clocks] ? [dict get $config output_clocks] : {{50 "SYS_CLK"}}

    info "Creating CCC instance: $inst_name"
    info "  Reference clock: $ref_freq MHz"
    info "  Output clocks: $outputs"

    # For now, use template-based approach (actual CCC config is complex)
    # User can provide pre-configured CCC component or we generate simple config

    # This would normally call create_and_configure_core with specific params
    # For simplicity, assume component already exists

    if {[component_exists $inst_name]} {
        add_component $sd_name $inst_name $inst_name
    } else {
        warn "CCC component '$inst_name' not found - must be created separately"
    }

    return $inst_name
}

# Create standard reset controller (CORERESET_PF)
#
# Args:
#   sd_name: SmartDesign name
#   config: Configuration with keys:
#     - instance_name: Name for reset instance (default: "CORERESET_PF_C0")
#     - clock_source: Clock input for reset synchronization
#     - init_source: Initialization monitor input (optional)
#
# Returns: Instance name
#
proc ::clock_reset::create_reset_controller {sd_name {config {}}} {
    set inst_name [dict exists $config instance_name] ? [dict get $config instance_name] : "CORERESET_PF_C0"

    info "Creating reset controller: $inst_name"

    # CORERESET_PF provides synchronized reset generation
    # Inputs: CLK, EXT_RST_N, INIT_DONE
    # Outputs: FABRIC_RESET_N, PLL_POWERDOWN

    if {[component_exists "CORERESET_PF_C0"]} {
        add_component $sd_name "CORERESET_PF_C0" $inst_name
    } else {
        warn "CORERESET_PF component not found - must be created separately"
    }

    return $inst_name
}

# Create PolarFire initialization monitor (PF_INIT_MONITOR)
#
# Args:
#   sd_name: SmartDesign name
#   instance_name: Name for instance (default: "PF_INIT_MONITOR_C0")
#
# Returns: Instance name
#
proc ::clock_reset::create_init_monitor {sd_name {instance_name "PF_INIT_MONITOR_C0"}} {
    info "Creating PF_INIT_MONITOR: $instance_name"

    # PF_INIT_MONITOR monitors device initialization status
    # Outputs: DEVICE_INIT_DONE, FABRIC_POR_N, PCIE_INIT_DONE

    if {[component_exists "PF_INIT_MONITOR_C0"]} {
        add_component $sd_name "PF_INIT_MONITOR_C0" $instance_name
    } else {
        warn "PF_INIT_MONITOR component not found - must be created separately"
    }

    return $instance_name
}

# ==============================================================================
# Standard Configurations
# ==============================================================================

# Create standard PolarFire power-on-reset (POR) chain
#
# Creates: PF_INIT_MONITOR -> CORERESET_PF -> distributed reset
#
# Args:
#   sd_name: SmartDesign name
#   clock_source: Clock for reset synchronization
#   reset_consumers: List of instances needing reset
#
# Returns: Dict with {init_monitor, reset_controller, reset_out}
#
proc ::clock_reset::create_standard_por {sd_name clock_source reset_consumers} {
    info "Creating standard PolarFire POR chain"

    # Create init monitor
    set init_mon [create_init_monitor $sd_name]

    # Create reset controller
    set reset_ctrl [create_reset_controller $sd_name]

    # Connect clock to reset controller
    connect_pins $sd_name [list $clock_source "${reset_ctrl}:CLK"]

    # Connect init monitor to reset controller
    connect_pins $sd_name [list \
        "${init_mon}:DEVICE_INIT_DONE" \
        "${reset_ctrl}:INIT_DONE" \
    ]

    # Distribute reset to consumers
    set reset_out "${reset_ctrl}:FABRIC_RESET_N"
    distribute_reset $sd_name $reset_out $reset_consumers

    return [dict create \
        init_monitor $init_mon \
        reset_controller $reset_ctrl \
        reset_output $reset_out \
    ]
}

# ==============================================================================
# Utility Functions
# ==============================================================================

# Automatically infer clock consumers from component list
# Looks for common clock pin names: CLK, PCLK, ACLK, clk, clock
#
proc ::clock_reset::infer_clock_consumers {component_list} {
    set consumers {}

    set clock_pins {CLK PCLK ACLK HCLK clk clock SYS_CLK}

    foreach comp $component_list {
        foreach pin $clock_pins {
            # Try each potential clock pin name
            lappend consumers "${comp}:${pin}"
        }
    }

    return $consumers
}

# Automatically infer reset consumers from component list
# Looks for common reset pin names: RESETN, RST_N, reset_n, ARESETN
#
proc ::clock_reset::infer_reset_consumers {component_list} {
    set consumers {}

    set reset_pins {RESETN RST_N reset_n ARESETN PRESETN SYS_RESET_N}

    foreach comp $component_list {
        foreach pin $reset_pins {
            lappend consumers "${comp}:${pin}"
        }
    }

    return $consumers
}

# Validate clock frequency compatibility
proc ::clock_reset::validate_clock_freq {freq_mhz min_mhz max_mhz} {
    if {$freq_mhz < $min_mhz || $freq_mhz > $max_mhz} {
        error "Clock frequency $freq_mhz MHz out of range \[$min_mhz, $max_mhz\] MHz"
    }
}

# ==============================================================================
# Export Functions
# ==============================================================================

namespace export create_tree
namespace export distribute_clock distribute_multi_clock
namespace export distribute_reset
namespace export create_ccc create_reset_controller create_init_monitor
namespace export create_standard_por
namespace export infer_clock_consumers infer_reset_consumers
