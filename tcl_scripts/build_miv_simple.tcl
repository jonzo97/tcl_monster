# ==============================================================================
# Build MI-V Simple Design - Run Synthesis and Place & Route
# ==============================================================================
#
# Purpose: Build the MI-V + SRAM design through synthesis and P&R
# Usage: ./run_libero.sh tcl_scripts/build_miv_simple.tcl SCRIPT
#
# ==============================================================================

set script_dir [file dirname [info script]]
set project_root [file dirname $script_dir]
set project_name "miv_simple_demo"
set project_location "$project_root/libero_projects/$project_name"

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

# ==============================================================================
# Main Script
# ==============================================================================

print_msg "Building MI-V Simple Design"

# Check if project exists
if {![file exists "$project_location/${project_name}.prjx"]} {
    print_msg "ERROR: Project not found at $project_location"
    print_info "Please run create_miv_simple.tcl first."
    exit 1
}

# Open existing project
print_info "Opening project: $project_location"
open_project "$project_location/${project_name}.prjx"

# ==============================================================================
# Run Synthesis
# ==============================================================================

print_msg "Running Synthesis"
print_info "This may take 10-15 minutes..."

if {[catch {run_tool -name {SYNTHESIZE}} result]} {
    print_msg "ERROR: Synthesis failed"
    print_info "Error details: $result"
    save_project
    close_project
    exit 1
}

print_info "Synthesis completed successfully"
save_project

# ==============================================================================
# Run Place and Route
# ==============================================================================

print_msg "Running Place and Route"
print_info "This may take 15-20 minutes..."

if {[catch {run_tool -name {PLACEROUTE}} result]} {
    print_msg "ERROR: Place and Route failed"
    print_info "Error details: $result"
    save_project
    close_project
    exit 1
}

print_info "Place and Route completed successfully"
save_project

# ==============================================================================
# Generate Reports
# ==============================================================================

print_msg "Build Complete!"

print_info "Project location: $project_location"
print_info ""
print_info "Next steps:"
print_info "1. Check synthesis reports in: synthesis/"
print_info "2. Check P&R reports in: designer/impl1/"
print_info "3. Run Build Doctor to analyze timing and resource usage"
print_info "4. Generate programming file if needed"

close_project
