#!/usr/bin/env tclsh
###############################################################################
# Export Memory Map from Libero SmartDesign
#
# Usage:
#   libero SCRIPT:export_memory_map.tcl SCRIPT_ARGS:<smartdesign_name> <output_json>
#
# Example:
#   libero SCRIPT:export_memory_map.tcl SCRIPT_ARGS:MIV_RV32 memory_map.json
#
# Description:
#   Exports the memory map for a SmartDesign component to JSON format.
#   This JSON can then be parsed to auto-generate hw_platform.h
###############################################################################

proc export_memory_map {smartdesign_name output_file} {
    puts "========================================="
    puts "Memory Map Export for TCL Monster"
    puts "========================================="
    puts "SmartDesign: $smartdesign_name"
    puts "Output: $output_file"
    puts ""

    # Open the SmartDesign component
    if {[catch {open_smartdesign -sd_name $smartdesign_name} err]} {
        puts "ERROR: Could not open SmartDesign '$smartdesign_name'"
        puts "  Make sure the design exists and project is open"
        return -1
    }

    puts "Opened SmartDesign: $smartdesign_name"

    # Export memory map to JSON
    # The Libero command is: File -> Export -> Memory Map Report
    # TCL command: export_memory_map (NOT export_mem_map_report!)
    if {[catch {export_memory_map -sd_name $smartdesign_name -file $output_file -format {}} err]} {
        puts "ERROR: Failed to export memory map"
        puts "  Error: $err"
        puts ""
        puts "NOTE: Memory map export requires bus fabric connections (AXI, AHB, APB)"
        puts "      If your design doesn't have initiator/target connections, this will fail"
        return -1
    }

    puts ""
    puts "SUCCESS: Memory map exported to $output_file"
    puts ""
    puts "Next steps:"
    puts "  Run: python3 scripts/generate_hw_platform.py $output_file"
    puts ""

    return 0
}

# Main execution
if {$argc != 2} {
    puts "ERROR: Invalid arguments"
    puts ""
    puts "Usage:"
    puts "  libero SCRIPT:export_memory_map.tcl SCRIPT_ARGS:<smartdesign_name> <output_json>"
    puts ""
    puts "Example:"
    puts "  libero SCRIPT:export_memory_map.tcl SCRIPT_ARGS:MIV_RV32 memory_map.json"
    exit 1
}

set smartdesign_name [lindex $argv 0]
set output_file [lindex $argv 1]

set result [export_memory_map $smartdesign_name $output_file]
exit $result
