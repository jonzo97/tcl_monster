# =============================================================================
# Libero SoC Build Script - Synthesis and Place & Route
# Target: PolarFire MPF300 Eval Kit
# Libero Version: 2024.2
# =============================================================================

# Project configuration
set project_name "counter_demo"
set project_location "./libero_projects"

# =============================================================================
# Open Existing Project
# =============================================================================

puts "=============================================="
puts "Opening Libero Project: $project_name"
puts "=============================================="

set project_path "$project_location/$project_name/$project_name.prjx"

if {![file exists $project_path]} {
    puts "ERROR: Project file not found: $project_path"
    puts "Please run create_project.tcl first!"
    exit 1
}

open_project -file $project_path

puts "Project opened successfully!"

# =============================================================================
# Run Synthesis
# =============================================================================

puts "=============================================="
puts "Starting Synthesis (Synplify Pro)..."
puts "=============================================="

run_tool -name {SYNTHESIZE}

# Check synthesis results
if {[catch {check_log -tool SYNTHESIZE}]} {
    puts "WARNING: Synthesis completed with warnings/errors"
} else {
    puts "Synthesis completed successfully!"
}

# =============================================================================
# Run Place and Route
# =============================================================================

puts "=============================================="
puts "Starting Place and Route..."
puts "=============================================="

run_tool -name {PLACEROUTE}

# Check place and route results
if {[catch {check_log -tool PLACEROUTE}]} {
    puts "WARNING: Place and Route completed with warnings/errors"
} else {
    puts "Place and Route completed successfully!"
}

# =============================================================================
# Generate Programming File
# =============================================================================

puts "=============================================="
puts "Generating Programming File..."
puts "=============================================="

run_tool -name {GENERATEPROGRAMMINGFILE}

if {[catch {check_log -tool GENERATEPROGRAMMINGFILE}]} {
    puts "WARNING: Programming file generation completed with warnings/errors"
} else {
    puts "Programming file generated successfully!"
}

# =============================================================================
# Display Build Summary
# =============================================================================

puts "=============================================="
puts "Build Summary"
puts "=============================================="
puts "Project: $project_name"
puts "Location: $project_location/$project_name"
puts ""
puts "Build stages completed:"
puts "  (1) Synthesis"
puts "  (2) Place and Route"
puts "  (3) Programming File Generation"
puts ""
puts "Programming file location:"
puts "  $project_location/$project_name/designer/counter/$project_name.ppd"
puts "=============================================="

# Save and close project
save_project
puts "Project saved!"

close_project
puts "Build complete!"
