# ==============================================================================
# TCL Monster - Query IP Catalog for DDR Cores
# ==============================================================================
#
# Purpose: Discover available DDR IP cores in Libero IP catalog
# Usage:   ./run_libero.sh tcl_scripts/query_ip_catalog.tcl SCRIPT
#
# ==============================================================================

puts "================================================================================"
puts "Querying Libero IP Catalog for DDR and Memory Controller Cores"
puts "================================================================================"

# Try to get catalog information
if {[catch {
    # Method 1: Try to list all available cores
    puts "\n--- Attempting to list all IP cores ---"
    set cores [get_available_cores]
    foreach core $cores {
        if {[string match -nocase "*ddr*" $core] || [string match -nocase "*memory*" $core]} {
            puts "Found: $core"
        }
    }
} err1]} {
    puts "Method 1 failed: $err1"
}

# Method 2: Try specific DDR core names
puts "\n--- Attempting to query specific DDR core names ---"
set possible_cores {
    "Actel:SgCore:PF_DDR4:*"
    "Microsemi:SgCore:PF_DDR4:*"
    "Actel:SgCore:PF_DDR3:*"
    "Microsemi:SgCore:PF_DDR3:*"
    "Actel:SystemBuilder:PF_DDR4:*"
    "Microsemi:SystemBuilder:PF_DDR4:*"
}

foreach core_vlnv $possible_cores {
    if {[catch {
        set result [check_core_available $core_vlnv]
        puts "Core $core_vlnv: $result"
    } err]} {
        # puts "Core $core_vlnv: Not found"
    }
}

# Method 3: Try to access configurator
puts "\n--- Attempting to access DDR configurator ---"
if {[catch {
    # Check if PF_DDR4 configurator exists
    puts "Checking for DDR configurator..."
    configure_tool -name {DDR_CONFIGURATOR} -params {}
} err3]} {
    puts "DDR Configurator check: $err3"
}

puts "\n================================================================================"
puts "Query complete. Check output above for available DDR cores."
puts "================================================================================"
