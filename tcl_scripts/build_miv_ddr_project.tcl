# ==============================================================================
# TCL Monster - Build MI-V RV32 + DDR4 Project
# ==============================================================================
#
# Purpose: Run synthesis, place & route, and generate programming file
# Usage:   ./run_libero.sh tcl_scripts/build_miv_ddr_project.tcl SCRIPT
#
# ==============================================================================

set script_dir [file dirname [info script]]
set project_root [file dirname $script_dir]
set project_location "$project_root/libero_projects/miv_rv32_ddr_demo"
set project_file "$project_location/miv_rv32_ddr_demo.prjx"

proc print_msg {message} {
    puts "=================================================================================="
    puts $message
    puts "=================================================================================="
}

proc print_info {message} {
    puts "INFO: $message"
}

print_msg "Building MI-V RV32 + DDR4 Project"

# ==============================================================================
# Open Project
# ==============================================================================

print_info "Opening project: $project_file"
open_project $project_file

# ==============================================================================
# Run Synthesis
# ==============================================================================

print_msg "Running Synthesis..."

if {[catch {run_tool -name {SYNTHESIZE}} result]} {
    print_msg "ERROR: Synthesis failed!"
    puts $result
    close_project
    exit 1
}

print_info "Synthesis completed successfully"

# ==============================================================================
# Run Place and Route
# ==============================================================================

print_msg "Running Place and Route..."

if {[catch {run_tool -name {PLACEROUTE}} result]} {
    print_msg "ERROR: Place and Route failed!"
    puts $result
    close_project
    exit 1
}

print_info "Place and Route completed successfully"

# ==============================================================================
# Run Timing Verification
# ==============================================================================

print_msg "Running Timing Verification..."

if {[catch {run_tool -name {VERIFYTIMING}} result]} {
    print_msg "WARNING: Timing verification failed or has violations"
    puts $result
    # Don't exit - we want to see the programming file even with timing issues
}

print_info "Timing verification completed"

# ==============================================================================
# Generate Programming File
# ==============================================================================

print_msg "Generating Programming File..."

if {[catch {run_tool -name {GENERATEPROGRAMMINGFILE}} result]} {
    print_msg "ERROR: Programming file generation failed!"
    puts $result
    close_project
    exit 1
}

print_info "Programming file generated successfully"

# ==============================================================================
# Generate Reports
# ==============================================================================

print_msg "Generating Reports..."

# Resource utilization report
export_resource_usage_report \
    -report_name "resource_utilization.txt" \
    -options "DETAILED"

# Timing report
export_timing_report \
    -report_name "timing_summary.txt"

print_info "Reports generated"

# ==============================================================================
# Summary
# ==============================================================================

print_msg "Build Complete!"

print_info "Output files:"
print_info "  - Programming file: designer/MIV_RV32_DDR_Design/MIV_RV32_DDR_Design.map"
print_info "  - Resource report:  designer/MIV_RV32_DDR_Design/resource_utilization.txt"
print_info "  - Timing report:    designer/MIV_RV32_DDR_Design/timing_summary.txt"

print_info ""
print_info "Next steps:"
print_info "1. Review timing report for any violations"
print_info "2. Program FPGA: FlashPro or SmartDebug"
print_info "3. Test with DDR firmware"

save_project
close_project
