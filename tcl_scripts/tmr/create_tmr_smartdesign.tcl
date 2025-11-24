# MI-V TMR System - SmartDesign Integration with Voter Logic
# Creates SmartDesign canvas, connects 3x MI-V cores through triple voter
#
# This implements IP-level TMR with voter logic:
# - 3x MI-V cores with individual memory
# - Triple voter for EXT_RESETN outputs
# - Voted output drives LED (demonstrates TMR functionality)

puts "╔════════════════════════════════════════════════════════════════════╗"
puts "║         MI-V TMR System - SmartDesign with Voting                  ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""

# Open project (Windows paths for Libero)
set project_name "miv_tmr_mpf300"
set project_location "C:/tcl_monster/libero_projects/tmr/$project_name"

open_project -file "$project_location/$project_name.prjx"

puts "Project opened: $project_name"
puts ""

# ============================================================================
# Step 1: Import Triple Voter HDL
# ============================================================================

puts "\[Step 1/8\] Importing triple voter HDL..."

# Import the voter Verilog module
import_files -convert_EDN_to_HDL 0 -library {work} -hdl_source {C:/tcl_monster/hdl/tmr/triple_voter.v}

puts "✓ Triple voter HDL imported"
puts ""

# ============================================================================
# Step 2: Create SmartDesign Component
# ============================================================================

puts "\[Step 2/8\] Creating SmartDesign component 'TMR_TOP'..."

create_smartdesign -sd_name {TMR_TOP}
open_smartdesign -sd_name {TMR_TOP}

puts "✓ SmartDesign canvas created"
puts ""

# ============================================================================
# Step 3: Instantiate MI-V Cores
# ============================================================================

puts "\[Step 3/8\] Instantiating 3x MI-V cores..."

sd_instantiate_component -sd_name {TMR_TOP} -component_name {MIV_RV32_CORE_A} -instance_name {MIV_RV32_A}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {MIV_RV32_CORE_B} -instance_name {MIV_RV32_B}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {MIV_RV32_CORE_C} -instance_name {MIV_RV32_C}

puts "✓ MI-V cores instantiated"
puts ""

# ============================================================================
# Step 4: Instantiate Triple Voter
# ============================================================================

puts "\[Step 4/8\] Instantiating triple voter..."

# Instantiate the voter HDL module in SmartDesign
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {triple_voter} -hdl_file {C:/tcl_monster/hdl/tmr/triple_voter.v} -instance_name {VOTER_EXT_RESETN}

# Configure voter parameters (1-bit width for EXT_RESETN)
sd_configure_core_instance -sd_name {TMR_TOP} -instance_name {VOTER_EXT_RESETN} -params {"WIDTH:1"}

puts "✓ Triple voter instantiated (1-bit for EXT_RESETN)"
puts ""

# ============================================================================
# Step 5: Create External Interfaces (Ports)
# ============================================================================

puts "\[Step 5/8\] Creating external interfaces..."

# Clock input
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {CLK_IN} -port_direction {IN}

# Reset input
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {RST_N_IN} -port_direction {IN}

# Heartbeat LED (shows clock is running)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {HEARTBEAT_LED} -port_direction {OUT}

# TMR Status LED (shows voted output from 3x cores)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {TMR_STATUS_LED} -port_direction {OUT}

# Fault indicators (3 LEDs showing which cores have faults)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {FAULT_LED_A} -port_direction {OUT}
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {FAULT_LED_B} -port_direction {OUT}
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {FAULT_LED_C} -port_direction {OUT}

# Disagreement indicator (high if any cores disagree)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {DISAGREE_LED} -port_direction {OUT}

puts "✓ External interfaces created (8 ports total)"
puts ""

# ============================================================================
# Step 6: Connect Clock and Reset to All Components
# ============================================================================

puts "\[Step 6/8\] Connecting clock and reset..."

# Connect clock to all MI-V cores
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "MIV_RV32_A:CLK"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "MIV_RV32_B:CLK"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "MIV_RV32_C:CLK"}

# Connect clock to voter
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "VOTER_EXT_RESETN:clk"}

# Connect reset to all MI-V cores
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "MIV_RV32_A:RESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "MIV_RV32_B:RESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "MIV_RV32_C:RESETN"}

# Connect reset to voter
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "VOTER_EXT_RESETN:rst_n"}

# Heartbeat LED (simple clock indicator)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"HEARTBEAT_LED" "CLK_IN"}

puts "✓ Clock and reset connected to all components"
puts ""

# ============================================================================
# Step 7: Connect MI-V Core Outputs Through Voter
# ============================================================================

puts "\[Step 7/8\] Connecting MI-V cores through voter..."

# Connect each core's EXT_RESETN to voter inputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_A:EXT_RESETN" "VOTER_EXT_RESETN:input_a"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_B:EXT_RESETN" "VOTER_EXT_RESETN:input_b"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_C:EXT_RESETN" "VOTER_EXT_RESETN:input_c"}

# Connect voted output to LED
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:voted_output" "TMR_STATUS_LED"}

# Connect fault flags to LEDs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:fault_flags[2]" "FAULT_LED_A"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:fault_flags[1]" "FAULT_LED_B"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:fault_flags[0]" "FAULT_LED_C"}

# Connect disagreement flag to LED
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:disagreement" "DISAGREE_LED"}

puts "✓ MI-V cores connected through voter"
puts ""

# ============================================================================
# Step 8: Save, Generate, and Set as Root
# ============================================================================

puts "\[Step 8/8\] Saving SmartDesign..."

# Save SmartDesign
save_smartdesign -sd_name {TMR_TOP}

# Build design hierarchy
build_design_hierarchy

# Generate component (REQUIRED before synthesis!)
generate_component -component_name {TMR_TOP}

# Set as root module
set_root -module {TMR_TOP::work}

# Save project
save_project

puts "✓ SmartDesign saved, generated, and set as root"
puts ""

# ============================================================================
# Summary
# ============================================================================

puts "╔════════════════════════════════════════════════════════════════════╗"
puts "║              TMR SmartDesign Integration Complete                  ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""
puts "TMR Architecture:"
puts "  ✓ 3x MI-V RV32IMC cores (synchronized clock/reset)"
puts "  ✓ Triple voter (2-of-3 majority voting on EXT_RESETN)"
puts "  ✓ Fault detection and disagreement monitoring"
puts ""
puts "Output Signals:"
puts "  HEARTBEAT_LED   - Clock indicator (blinks at clock rate)"
puts "  TMR_STATUS_LED  - Voted output from 3x cores"
puts "  FAULT_LED_A/B/C - Individual core fault indicators"
puts "  DISAGREE_LED    - High if any cores disagree"
puts ""
puts "This is IP-level TMR:"
puts "  - 3x processor instances (not register-level triplication)"
puts "  - Voter logic in fabric"
puts "  - Observable outputs force synthesis to keep all cores"
puts ""
puts "Next Step:"
puts "  ./run_libero.sh tcl_scripts/tmr/build_tmr_project.tcl SCRIPT"
puts ""
