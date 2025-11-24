# MI-V TMR System - HDL Top-Level Integration
# Uses direct HDL instantiation instead of SmartDesign
#
# This script:
# - Opens existing project with 3x MI-V cores
# - Imports voter and top-level HDL modules
# - Sets up hierarchy with tmr_top as root
# - Prepares for synthesis

puts "╔════════════════════════════════════════════════════════════════════╗"
puts "║         MI-V TMR System - HDL Top-Level Integration               ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""

# Open project (Windows paths for Libero)
set project_name "miv_tmr_mpf300"
set project_location "C:/tcl_monster/libero_projects/tmr/$project_name"

open_project -file "$project_location/$project_name.prjx"

puts "Project opened: $project_name"
puts ""

# ============================================================================
# Step 1: Import HDL Modules
# ============================================================================

puts "\[Step 1/5\] Importing HDL modules..."

# Import triple voter module
import_files -convert_EDN_to_HDL 0 -library {work} -hdl_source {C:/tcl_monster/hdl/tmr/triple_voter.v}

# Import top-level wrapper
import_files -convert_EDN_to_HDL 0 -library {work} -hdl_source {C:/tcl_monster/hdl/tmr/tmr_top.v}

puts "✓ HDL modules imported (voter + top-level)"
puts ""

# ============================================================================
# Step 2: Build Design Hierarchy
# ============================================================================

puts "\[Step 2/5\] Building design hierarchy..."

build_design_hierarchy

puts "✓ Design hierarchy built"
puts ""

# ============================================================================
# Step 3: Set Top-Level Module
# ============================================================================

puts "\[Step 3/5\] Setting tmr_top as root module..."

set_root -module {tmr_top::work}

puts "✓ tmr_top set as root module"
puts ""

# ============================================================================
# Step 4: Save Project
# ============================================================================

puts "\[Step 4/5\] Saving project..."

save_project

puts "✓ Project saved"
puts ""

# ============================================================================
# Summary
# ============================================================================

puts "╔════════════════════════════════════════════════════════════════════╗"
puts "║              TMR HDL Top-Level Integration Complete               ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""
puts "TMR Architecture:"
puts "  ✓ 3x MI-V RV32IMC cores (instantiated in tmr_top.v)"
puts "  ✓ Triple voter (2-of-3 majority voting)"
puts "  ✓ 6 LED outputs (heartbeat, status, 3x faults, disagreement)"
puts ""
puts "HDL Files:"
puts "  tmr_top.v       - Top-level wrapper with all instantiations"
puts "  triple_voter.v  - Voter logic module"
puts ""
puts "Root Module: tmr_top::work"
puts ""
puts "Next Step:"
puts "  ./run_libero.sh tcl_scripts/tmr/build_tmr_project.tcl SCRIPT"
puts ""
