# =============================================================================
# Generate Comprehensive Reports
# Produces resource, timing, power, and pin reports
# =============================================================================

# Project configuration
set project_name "counter_demo"
set project_location "./libero_projects"

# =============================================================================
# Open Project
# =============================================================================

puts "=============================================="
puts "Generating Reports for: $project_name"
puts "=============================================="

set project_path "$project_location/$project_name/$project_name.prjx"

if {![file exists $project_path]} {
    puts "ERROR: Project file not found: $project_path"
    puts "Please build the design first!"
    exit 1
}

open_project -file $project_path

# =============================================================================
# Generate Reports
# =============================================================================

puts "\nGenerating reports..."

# Set report output directory
set report_dir "$project_location/$project_name/reports"
file mkdir $report_dir

# =============================================================================
# 1. Resource Utilization Report
# =============================================================================

puts "  (1/5) Resource utilization..."

# Resource report is automatically generated during P&R
# Copy to reports directory for easy access
set resource_src "$project_location/$project_name/designer/counter/counter_resourceusage.rpt"
if {[file exists $resource_src]} {
    file copy -force $resource_src "$report_dir/resource_utilization.rpt"
}

# =============================================================================
# 2. Timing Reports
# =============================================================================

puts "  (2/5) Timing analysis..."

# Timing reports generated during P&R
set timing_files [list \
    "$project_location/$project_name/designer/counter/counter_timing_violations_max.txt" \
    "$project_location/$project_name/designer/counter/counter_timing_violations_min.txt" \
    "$project_location/$project_name/designer/counter/counter_max_delay.txt" \
    "$project_location/$project_name/designer/counter/counter_min_delay.txt" \
]

foreach timing_file $timing_files {
    if {[file exists $timing_file]} {
        set basename [file tail $timing_file]
        file copy -force $timing_file "$report_dir/$basename"
    }
}

# =============================================================================
# 3. Pin Report
# =============================================================================

puts "  (3/5) Pin assignments..."

set pin_src "$project_location/$project_name/designer/counter/counter_pinrpt_constraint.txt"
if {[file exists $pin_src]} {
    file copy -force $pin_src "$report_dir/pin_assignments.rpt"
}

# =============================================================================
# 4. Power Report
# =============================================================================

puts "  (4/5) Power analysis..."

# Power report (if generated)
set power_src "$project_location/$project_name/designer/counter/counter_power_report.txt"
if {[file exists $power_src]} {
    file copy -force $power_src "$report_dir/power_analysis.rpt"
}

# =============================================================================
# 5. Build Summary
# =============================================================================

puts "  (5/5) Build summary..."

# Create a comprehensive summary report
set summary_file "$report_dir/build_summary.txt"
set summary_fh [open $summary_file w]

puts $summary_fh "=============================================="
puts $summary_fh "Build Summary Report"
puts $summary_fh "Project: $project_name"
puts $summary_fh "Date: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
puts $summary_fh "=============================================="
puts $summary_fh ""

# Parse resource utilization
puts $summary_fh "RESOURCE UTILIZATION:"
puts $summary_fh "--------------------"
if {[file exists "$report_dir/resource_utilization.rpt"]} {
    set res_fh [open "$report_dir/resource_utilization.rpt" r]
    set res_content [read $res_fh]
    close $res_fh

    # Extract key metrics (4LUT, DFF, etc.)
    foreach line [split $res_content "\n"] {
        if {[regexp {(4LUT|DFF|I/O Register|Logic Element)\s+\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+([\d\.]+)} $line match type used total pct]} {
            puts $summary_fh "  $type: $used / $total ($pct%)"
        }
    }
} else {
    puts $summary_fh "  Resource report not found"
}

puts $summary_fh ""
puts $summary_fh "TIMING SUMMARY:"
puts $summary_fh "--------------------"
if {[file exists "$report_dir/counter_timing_violations_max.txt"]} {
    set timing_fh [open "$report_dir/counter_timing_violations_max.txt" r]
    set timing_content [read $timing_fh]
    close $timing_fh

    if {[string match "*No violations*" $timing_content] || [string length $timing_content] < 50} {
        puts $summary_fh "  ✓ No setup timing violations"
    } else {
        puts $summary_fh "  ✗ Setup timing violations detected!"
        puts $summary_fh "  See: reports/counter_timing_violations_max.txt"
    }
} else {
    puts $summary_fh "  Timing report not found"
}

if {[file exists "$report_dir/counter_timing_violations_min.txt"]} {
    set timing_fh [open "$report_dir/counter_timing_violations_min.txt" r]
    set timing_content [read $timing_fh]
    close $timing_fh

    if {[string match "*No violations*" $timing_content] || [string length $timing_content] < 50} {
        puts $summary_fh "  ✓ No hold timing violations"
    } else {
        puts $summary_fh "  ✗ Hold timing violations detected!"
        puts $summary_fh "  See: reports/counter_timing_violations_min.txt"
    }
}

puts $summary_fh ""
puts $summary_fh "PIN ASSIGNMENTS:"
puts $summary_fh "--------------------"
if {[file exists "$report_dir/pin_assignments.rpt"]} {
    set pin_fh [open "$report_dir/pin_assignments.rpt" r]
    set pin_count 0
    while {[gets $pin_fh line] >= 0} {
        if {[regexp {^\s*\S+\s+\S+\s+\S+} $line]} {
            incr pin_count
        }
    }
    close $pin_fh
    puts $summary_fh "  Total pins assigned: $pin_count"
} else {
    puts $summary_fh "  Pin report not found"
}

puts $summary_fh ""
puts $summary_fh "PROGRAMMING FILE:"
puts $summary_fh "--------------------"
set prog_file "$project_location/$project_name/designer/counter/$project_name.ppd"
if {[file exists $prog_file]} {
    set file_size [file size $prog_file]
    puts $summary_fh "  ✓ Generated: $prog_file"
    puts $summary_fh "  Size: [expr {$file_size / 1024}] KB"
} else {
    puts $summary_fh "  ✗ Programming file not found"
}

puts $summary_fh ""
puts $summary_fh "=============================================="

close $summary_fh

# =============================================================================
# Display Summary
# =============================================================================

puts "\n=============================================="
puts "Reports Generated"
puts "=============================================="
puts "Location: $report_dir/"
puts ""
puts "Available reports:"
puts "  - build_summary.txt          (Overview)"
puts "  - resource_utilization.rpt   (LUT, FF, I/O usage)"
puts "  - counter_timing_violations_max.txt (Setup timing)"
puts "  - counter_timing_violations_min.txt (Hold timing)"
puts "  - pin_assignments.rpt        (Pin mappings)"
puts "  - power_analysis.rpt         (Power estimates)"
puts ""
puts "Quick view:"
puts "=============================================="

# Display the summary
set summary_fh [open $summary_file r]
set summary_content [read $summary_fh]
close $summary_fh
puts $summary_content

# Close project
close_project
puts "Report generation complete!"
