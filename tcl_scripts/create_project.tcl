# =============================================================================
# Libero SoC Project Creation Script
# Target: PolarFire MPF300 Eval Kit
# Libero Version: 2024.2
# =============================================================================

# Load configuration from JSON (future enhancement - for now hardcoded)
set project_name "counter_demo"
set project_location "./libero_projects"

# Device configuration - MPF300TS on Eval Kit
set device_family "PolarFire"
set device_die "MPF300TS"
set device_package "FCG1152"
set speed_grade "-1"
set die_voltage "1.0"
set hdl_language "VERILOG"

# =============================================================================
# Project Creation
# =============================================================================

puts "=============================================="
puts "Creating Libero Project: $project_name"
puts "Target Device: $device_die$device_package"
puts "=============================================="

# Clean up any existing project
if {[file exists $project_location/$project_name]} {
    puts "Removing existing project directory..."
    file delete -force $project_location/$project_name
}

# Create new project
new_project \
    -location "$project_location/$project_name" \
    -name $project_name \
    -project_description "Auto-generated PolarFire project" \
    -hdl $hdl_language \
    -family $device_family \
    -die $device_die \
    -package $device_package \
    -speed $speed_grade \
    -die_voltage $die_voltage \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1 \
    -use_enhanced_constraint_flow 1

puts "Project created successfully!"

# =============================================================================
# Import HDL Sources
# =============================================================================

puts "Importing HDL sources..."

# Convert relative paths to absolute for import
set script_dir [file dirname [file normalize [info script]]]
set project_root [file dirname $script_dir]
set hdl_dir "$project_root/hdl"
set constraint_dir "$project_root/constraint"

# Import counter design
import_files \
    -convert_EDN_to_HDL 0 \
    -library {work} \
    -hdl_source "$hdl_dir/counter.v"

puts "HDL sources imported successfully!"

# =============================================================================
# Import Constraint Files
# =============================================================================

puts "Importing constraint files..."

# Import I/O constraints
import_files \
    -io_pdc "$constraint_dir/io_constraints.pdc"

# Import timing constraints
import_files \
    -sdc "$constraint_dir/timing_constraints.sdc"

puts "Constraint files imported successfully!"

# =============================================================================
# Configure Design Hierarchy
# =============================================================================

puts "Building design hierarchy..."

# Build design hierarchy
build_design_hierarchy

# Set top-level module
set_root -module {counter::work}

puts "Design hierarchy configured - top module: counter"

# =============================================================================
# Associate Constraints with Tools
# =============================================================================

puts "Associating constraints with build tools..."

# Files are imported into project structure, reference them relative to project
# Associate timing constraints (SDC) with synthesis
organize_tool_files -tool {SYNTHESIZE} \
    -file "$project_location/$project_name/constraint/timing_constraints.sdc" \
    -module {counter::work} \
    -input_type {constraint}

# Associate timing constraints (SDC) with place & route (for timing-driven P&R)
organize_tool_files -tool {PLACEROUTE} \
    -file "$project_location/$project_name/constraint/timing_constraints.sdc" \
    -module {counter::work} \
    -input_type {constraint}

# Associate I/O constraints (PDC) with place & route
organize_tool_files -tool {PLACEROUTE} \
    -file "$project_location/$project_name/constraint/io/io_constraints.pdc" \
    -module {counter::work} \
    -input_type {constraint}

puts "Constraints associated with tools successfully!"

# =============================================================================
# Configure Tools for Timing-Driven Flow
# =============================================================================

puts "Configuring tools for timing-driven optimization..."

# Enable timing-driven place & route
configure_tool -name {PLACEROUTE} -params {TDPR:true}

puts "Timing-driven mode enabled!"

# Save and close project
save_project
puts "Project saved at: $project_location/$project_name"

close_project
puts "Project creation complete!"
