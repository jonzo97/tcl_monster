# MI-V TMR System - Build Script
# Synthesis + Place & Route + Timing Analysis

puts "╔════════════════════════════════════════════════════════════════════╗"
puts "║              MI-V TMR System - Build Flow                          ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""

# Open project (Windows paths for Libero)
set project_name "miv_tmr_mpf300"
set project_location "C:/tcl_monster/libero_projects/tmr/$project_name"

open_project -file "$project_location/$project_name.prjx"

puts "Project opened: $project_name"
puts ""

# ==============================================================================
# Import Constraints
# ==============================================================================

puts "\[1/5\] Importing constraints..."

# Synthesis directives (FDC) - CRITICAL for TMR preservation
# Link the FDC file using -net_fdc (works for synthesis constraint files)
create_links -net_fdc {C:/tcl_monster/constraint/tmr_synthesis_directives.fdc}
organize_tool_files -tool {SYNTHESIZE} \
    -file {C:/tcl_monster/constraint/tmr_synthesis_directives.fdc} \
    -module {TMR_TOP} \
    -input_type {constraint}

# Ensure Synplify reads the FDC
configure_tool -name {SYNTHESIZE} -params {SYNPLIFY_OPTIONS:set_option -include C:/tcl_monster/constraint/tmr_synthesis_directives.fdc}

# I/O constraints
create_links -io_pdc {C:/tcl_monster/constraint/tmr/miv_tmr_io.pdc}
organize_tool_files -tool {PLACEROUTE} \
    -file {C:/tcl_monster/constraint/tmr/miv_tmr_io.pdc} \
    -module {TMR_TOP} \
    -input_type {constraint}

# Timing constraints
create_links -sdc {C:/tcl_monster/constraint/tmr/miv_tmr_timing.sdc}
organize_tool_files -tool {SYNTHESIZE} \
    -file {C:/tcl_monster/constraint/tmr/miv_tmr_timing.sdc} \
    -module {TMR_TOP} \
    -input_type {constraint}
organize_tool_files -tool {PLACEROUTE} \
    -file {C:/tcl_monster/constraint/tmr/miv_tmr_timing.sdc} \
    -module {TMR_TOP} \
    -input_type {constraint}

puts "✓ Constraints imported (including TMR synthesis directives)"
puts ""

# ==============================================================================
# Synthesis
# ==============================================================================

puts "\[2/5\] Running synthesis..."
puts "  (This may take 30-45 minutes for 3x MI-V cores...)"
puts ""

set synthesis_start [clock seconds]

run_tool -name {SYNTHESIZE}

set synthesis_end [clock seconds]
set synthesis_time [expr {$synthesis_end - $synthesis_start}]

puts ""
puts "✓ Synthesis complete (${synthesis_time}s = [expr {$synthesis_time / 60}] min)"
puts ""

# ==============================================================================
# Place & Route
# ==============================================================================

puts "\[3/5\] Running place and route..."
puts "  (This may take 20-30 minutes...)"
puts ""

set pr_start [clock seconds]

run_tool -name {PLACEROUTE}

set pr_end [clock seconds]
set pr_time [expr {$pr_end - $pr_start}]

puts ""
puts "✓ Place and route complete (${pr_time}s = [expr {$pr_time / 60}] min)"
puts ""

# ==============================================================================
# Timing Verification
# ==============================================================================

puts "\[4/5\] Running timing verification..."

run_tool -name {VERIFYTIMING}

puts "✓ Timing verification complete"
puts ""

# ==============================================================================
# Generate Reports
# ==============================================================================

puts "\[5/5\] Generating reports..."

# Resource utilization
set utilization_file "$project_location/reports/utilization_report.txt"
file mkdir "$project_location/reports"

# Timing summary
# (Libero generates these automatically in designer/impl1/)

puts "✓ Reports generated in designer/impl1/"
puts ""

# Save project
save_project

# ==============================================================================
# Build Summary
# ==============================================================================

puts "╔════════════════════════════════════════════════════════════════════╗"
puts "║                      Build Complete!                               ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""
puts "Build Time:"
puts "  Synthesis: ${synthesis_time}s ([expr {$synthesis_time / 60}] min)"
puts "  Place & Route: ${pr_time}s ([expr {$pr_time / 60}] min)"
puts "  Total: [expr {($synthesis_time + $pr_time) / 60}] min"
puts ""
puts "Reports Location:"
puts "  $project_location/designer/impl1/"
puts ""
puts "Key Files:"
puts "  Resource Utilization: *_utilization.txt"
puts "  Timing Report: *_timing_violations_report.txt"
puts "  Pin Report: *_pinrpt.txt"
puts ""
puts "Next Steps:"
puts "  1. Review resource utilization"
puts "  2. Check timing violations (if any)"
puts "  3. Complete voter integration (SmartDesign)"
puts "  4. Re-build with full TMR voting"
puts ""
