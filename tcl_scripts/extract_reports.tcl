# ==============================================================================
# Extract Build Reports for MI-V Design
# ==============================================================================
#
# Purpose: Extract and format key build metrics from Libero reports
# Usage: ./run_libero.sh tcl_scripts/extract_reports.tcl SCRIPT
#
# Outputs: Human-readable summary of resource usage, timing, power
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

proc print_section {title} {
    puts ""
    puts "----------------------------------------"
    puts $title
    puts "----------------------------------------"
}

# ==============================================================================
# Main Script
# ==============================================================================

print_msg "Extracting Build Reports"

# Check if project exists
if {![file exists "$project_location/${project_name}.prjx"]} {
    print_msg "ERROR: Project not found at $project_location"
    print_info "Please run create_miv_simple.tcl and build_miv_simple.tcl first."
    exit 1
}

# Open existing project
print_info "Opening project: $project_location"
open_project "$project_location/${project_name}.prjx"

# Create reports directory
set reports_dir "$project_location/reports"
file mkdir $reports_dir

# ==============================================================================
# Extract Resource Utilization
# ==============================================================================

print_section "Resource Utilization"

# Run resource report
if {[catch {
    report -type "resourceusage" \
        -format "text" \
        -file "$reports_dir/resource_utilization.rpt"
} result]} {
    print_info "Note: Could not generate resource report (build may not be complete)"
} else {
    print_info "Resource report saved to: $reports_dir/resource_utilization.rpt"

    # Try to read and display key metrics
    if {[file exists "$reports_dir/resource_utilization.rpt"]} {
        set fd [open "$reports_dir/resource_utilization.rpt" r]
        set content [read $fd]
        close $fd

        # Extract LUT/FF counts
        if {[regexp {4LUT\s+(\d+)\s+(\d+)\s+([0-9.]+)} $content match luts total pct]} {
            puts "  LUTs: $luts / $total ($pct%)"
        }
        if {[regexp {DFF\s+(\d+)\s+(\d+)\s+([0-9.]+)} $content match ffs total pct]} {
            puts "  Flip-Flops: $ffs / $total ($pct%)"
        }
    }
}

# ==============================================================================
# Extract Timing Information
# ==============================================================================

print_section "Timing Analysis"

# Run timing report
if {[catch {
    report -type "timing" \
        -format "text" \
        -file "$reports_dir/timing_summary.rpt"
} result]} {
    print_info "Note: Could not generate timing report (constraints may not be defined)"
} else {
    print_info "Timing report saved to: $reports_dir/timing_summary.rpt"
}

# Extract timing violations
if {[catch {
    report -type "violations" \
        -format "text" \
        -file "$reports_dir/timing_violations.rpt"
} result]} {
    print_info "Note: Timing violations report not available"
}

# ==============================================================================
# Extract Pin Assignments
# ==============================================================================

print_section "Pin Assignments"

if {[catch {
    report -type "pin" \
        -format "text" \
        -file "$reports_dir/pin_assignments.rpt"
} result]} {
    print_info "Note: Could not generate pin report"
} else {
    print_info "Pin assignments saved to: $reports_dir/pin_assignments.rpt"
}

# ==============================================================================
# Extract Power Estimates
# ==============================================================================

print_section "Power Analysis"

if {[catch {
    report -type "power" \
        -format "text" \
        -file "$reports_dir/power_analysis.rpt"
} result]} {
    print_info "Note: Could not generate power report"
} else {
    print_info "Power analysis saved to: $reports_dir/power_analysis.rpt"
}

# ==============================================================================
# Create Summary Report
# ==============================================================================

print_section "Build Summary"

set summary_file "$reports_dir/build_summary.txt"
set fd [open $summary_file w]

puts $fd "================================================================================"
puts $fd "Build Summary Report - MI-V Simple Design"
puts $fd "================================================================================"
puts $fd ""
puts $fd "Project: $project_name"
puts $fd "Date: [clock format [clock seconds]]"
puts $fd ""
puts $fd "Device: MPF300TS-FCG1152"
puts $fd "Family: PolarFire"
puts $fd ""
puts $fd "================================================================================"
puts $fd ""
puts $fd "Available Reports:"
puts $fd ""

foreach report_file [glob -nocomplain -directory $reports_dir *.rpt] {
    puts $fd "  - [file tail $report_file]"
}

puts $fd ""
puts $fd "================================================================================"
puts $fd ""
puts $fd "For detailed analysis, use Build Doctor:"
puts $fd "  python tools/diagnostics/build_doctor.py $project_location"
puts $fd ""
puts $fd "================================================================================"

close $fd

print_info "Summary report saved to: $summary_file"

# ==============================================================================
# Display Summary
# ==============================================================================

print_msg "Report Extraction Complete!"

print_info ""
print_info "Reports directory: $reports_dir"
print_info ""
print_info "Generated reports:"
print_info "  - build_summary.txt"
print_info "  - resource_utilization.rpt"
print_info "  - timing_summary.rpt (if timing constraints defined)"
print_info "  - pin_assignments.rpt (if constraints defined)"
print_info "  - power_analysis.rpt"
print_info ""
print_info "For intelligent analysis:"
print_info "  python tools/diagnostics/build_doctor.py $project_location"

save_project
close_project
