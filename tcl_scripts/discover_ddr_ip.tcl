# ==============================================================================
# TCL Monster - Discover DDR IP Core Information
# ==============================================================================
#
# Purpose: Open existing project and discover DDR IP cores
# Usage:   ./run_libero.sh tcl_scripts/discover_ddr_ip.tcl SCRIPT
#
# ==============================================================================

set script_dir [file dirname [info script]]
set project_root [file dirname $script_dir]
set project_location "$project_root/libero_projects/miv_rv32_demo"
set project_file "$project_location/miv_rv32_demo.prjx"

puts "================================================================================"
puts "Opening existing project to discover DDR IP cores"
puts "================================================================================"

# Open existing project
puts "Opening project: $project_file"
open_project $project_file

puts "\n--- Project opened successfully ---\n"

# Method 1: List all cores in the catalog using download_core
puts "--- Method 1: Trying to list cores with 'download_core' ---"
if {[catch {
    set core_list [download_core -help]
    puts "$core_list"
} err1]} {
    puts "download_core query failed: $err1"
}

# Method 2: Try to use configure_tool to see DDR options
puts "\n--- Method 2: Query configurator tools ---"
if {[catch {
    set tools [configure_tool -help]
    puts "$tools"
} err2]} {
    puts "configure_tool query: $err2"
}

# Method 3: Try to instantiate a DDR core with common VLNV patterns
puts "\n--- Method 3: Attempting DDR core instantiation (dry run) ---"
set possible_vlnvs {
    "Actel:SgCore:PF_DDR4:1.0.0"
    "Microsemi:SgCore:PF_DDR4:1.0.0"
    "Actel:SystemBuilder:PF_DDR4:1.0.0"
    "Microchip:SgCore:PF_DDR4:1.0.0"
}

foreach vlnv $possible_vlnvs {
    puts "Trying VLNV: $vlnv"
    if {[catch {
        create_and_configure_core \
            -core_vlnv $vlnv \
            -component_name "DDR4_TEST" \
            -params {}
    } err]} {
        puts "  Result: $err"
    } else {
        puts "  SUCCESS! Found valid VLNV: $vlnv"
        # Clean up test component
        delete_component -component_name {DDR4_TEST}
        break
    }
}

# Method 4: Check IP catalog location
puts "\n--- Method 4: Checking IP catalog repository ---"
if {[catch {
    set repo_path [get_repository_location]
    puts "Repository location: $repo_path"
} err4]} {
    puts "Repository query: $err4"
}

puts "\n================================================================================"
puts "Discovery complete."
puts "================================================================================"

# Close project
close_project
