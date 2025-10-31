# ==============================================================================
# Generate Programming Bitstream for MI-V Simple Design
# ==============================================================================
#
# Purpose: Generate programming file (.stp) for MI-V design
# Usage: ./run_libero.sh tcl_scripts/generate_bitstream.tcl SCRIPT
#
# Prerequisites: Project must be built (synthesis + P&R complete)
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

print_msg "Generating Programming Bitstream"

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
# Configure and Run Bitstream Generation
# ==============================================================================

print_info "Configuring bitstream generation..."

# Configure programming file options
configure_tool -name {GENERATEPROGRAMMINGFILE} \
    -params {PROGRAMMING_FILE_FORMAT:STP} \
    -params {GENERATE_METADATA_FILE:TRUE}

# Run bitstream generation
print_msg "Running Bitstream Generation"
print_info "This may take 2-3 minutes..."

if {[catch {run_tool -name {GENERATEPROGRAMMINGFILE}} result]} {
    print_msg "ERROR: Bitstream generation failed"
    print_info "Error details: $result"
    save_project
    close_project
    exit 1
}

print_info "Bitstream generation completed successfully"
save_project

# ==============================================================================
# Report Results
# ==============================================================================

print_msg "Bitstream Generation Complete!"

# Find generated files
set designer_dir "$project_location/designer/impl1"
set stp_file "$designer_dir/MIV_Simple_Design.stp"
set map_file "$designer_dir/MIV_Simple_Design.map"

if {[file exists $stp_file]} {
    print_info "Programming file generated: $stp_file"
    print_info "File size: [expr {[file size $stp_file] / 1024}] KB"
} else {
    print_info "WARNING: Programming file not found at expected location"
}

if {[file exists $map_file]} {
    print_info "Mapping file generated: $map_file"
}

print_info ""
print_info "Next steps:"
print_info "1. Program FPGA using FlashPro Express"
print_info "2. Connect UART terminal (115200 baud)"
print_info "3. Load programming file: $stp_file"
print_info "4. Observe LED behavior and UART output"

close_project
