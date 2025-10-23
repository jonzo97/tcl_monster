# ==============================================================================
# TCL Monster - MI-V RV32 RISC-V Project Build Script
# ==============================================================================
#
# Purpose: Build MI-V RV32 project through synthesis, place & route, and bitstream
# Target: MPF300 Eval Kit (MPF300TS, FCG1152)
#
# Usage:
#   ./run_libero.sh tcl_scripts/build_miv_rv32_project.tcl SCRIPT
#
# Build Flow:
#   1. Open project
#   2. Associate pin constraints (PDC file)
#   3. Run synthesis (Synplify Pro)
#   4. Run place and route
#   5. Verify timing
#   6. Generate programming data
#   7. Generate programming file (bitstream)
#   8. Export programming job file
#
# ==============================================================================

# Get the script directory for relative paths
set script_path [info script]
set script_dir [file dirname $script_path]
set project_root [file dirname $script_dir]

# ==============================================================================
# Project Configuration
# ==============================================================================

set project_name "miv_rv32_demo"
set project_location "$project_root/libero_projects/$project_name"
set smartdesign_name "MIV_RV32_BaseDesign"
set constraint_file "$project_location/constraint/io_constraints.pdc"

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

proc print_error {message} {
    puts "ERROR: $message"
}

proc print_timestamp {} {
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    puts "Timestamp: $timestamp"
}

# ==============================================================================
# Main Build Script
# ==============================================================================

print_msg "TCL Monster - Building MI-V RV32 RISC-V Project"
print_timestamp

# Check if project exists
if {![file exists "$project_location/$project_name.prjx"]} {
    print_error "Project file not found: $project_location/$project_name.prjx"
    print_info "Please run create_miv_rv32_project_v2.tcl first."
    exit 1
}

# Open project
print_info "Opening project: $project_name"
open_project "$project_location/$project_name.prjx"

# ==============================================================================
# Associate Constraints
# ==============================================================================

print_msg "Associating Pin Constraints"

# Check if constraint file exists
if {[file exists $constraint_file]} {
    print_info "Constraint file found: $constraint_file"

    # Create constraint file in project if not already present
    create_links \
        -io_pdc $constraint_file

    print_info "Pin constraints associated successfully"
} else {
    print_error "Constraint file not found: $constraint_file"
    print_info "Continuing without pin constraints (will use auto-placement)"
}

# ==============================================================================
# Configure Design for Build
# ==============================================================================

print_msg "Configuring Build Settings"

# Configure design settings
configure_tool -name {SYNTHESIZE} \
    -params {SYNPLIFY_OPTIONS:set_option -auto_constrain_io 1}

# Configure Place & Route
configure_tool -name {PLACEROUTE} \
    -params {TDPR:true} \
    -params {PDPR:false}

print_info "Build settings configured"

# ==============================================================================
# Run Synthesis
# ==============================================================================

print_msg "Starting Synthesis (Synplify Pro)"
print_timestamp

run_tool -name {SYNTHESIZE}

if {[catch {run_tool -name {SYNTHESIZE}} result]} {
    print_error "Synthesis failed: $result"
    save_project
    exit 1
}

print_info "Synthesis completed successfully"
print_timestamp
save_project

# ==============================================================================
# Run Place and Route
# ==============================================================================

print_msg "Starting Place and Route"
print_timestamp

if {[catch {run_tool -name {PLACEROUTE}} result]} {
    print_error "Place and Route failed: $result"
    save_project
    exit 1
}

print_info "Place and Route completed successfully"
print_timestamp
save_project

# ==============================================================================
# Verify Timing
# ==============================================================================

print_msg "Verifying Timing"

if {[catch {run_tool -name {VERIFYTIMING}} result]} {
    print_error "Timing verification failed: $result"
    print_info "Warning: Timing violations detected. Check timing report."
    # Don't exit - continue to bitstream generation
} else {
    print_info "Timing verification passed"
}

save_project

# ==============================================================================
# Generate Programming Data
# ==============================================================================

print_msg "Generating Programming Data"
print_timestamp

if {[catch {run_tool -name {GENERATEPROGRAMMINGDATA}} result]} {
    print_error "Programming data generation failed: $result"
    save_project
    exit 1
}

print_info "Programming data generated successfully"
save_project

# ==============================================================================
# Generate Programming File (Bitstream)
# ==============================================================================

print_msg "Generating Programming File (Bitstream)"
print_timestamp

if {[catch {run_tool -name {GENERATEPROGRAMMINGFILE}} result]} {
    print_error "Programming file generation failed: $result"
    save_project
    exit 1
}

print_info "Programming file (bitstream) generated successfully"
save_project

# ==============================================================================
# Export Programming Job File
# ==============================================================================

print_msg "Exporting Programming Job File"

set export_dir "$project_location/designer/$smartdesign_name/export"
file mkdir $export_dir

if {[catch {
    export_prog_job \
        -job_file_name $project_name \
        -export_dir $export_dir \
        -bitstream_file_type {TRUSTED_FACILITY} \
        -bitstream_file_components {}
} result]} {
    print_error "Programming job export failed: $result"
    # Don't exit - bitstream is still usable
} else {
    print_info "Programming job file exported to: $export_dir"
}

save_project

# ==============================================================================
# Build Complete
# ==============================================================================

print_msg "Build Complete - Success!"
print_timestamp

print_info "Project: $project_name"
print_info "SmartDesign: $smartdesign_name"
print_info "Programming file location: $project_location/designer/$smartdesign_name"
print_info ""
print_info "Next Steps:"
print_info "  1. Review timing reports in designer/$smartdesign_name/"
print_info "  2. Program FPGA using FlashPro Express"
print_info "  3. Connect UART (115200 baud) to test processor"
print_info "  4. Test GPIO (LEDs and switches) functionality"
print_info ""

print_msg "TCL Monster - Build Complete"
