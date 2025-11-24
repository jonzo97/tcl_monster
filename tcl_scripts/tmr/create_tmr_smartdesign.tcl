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
# Step 1: Import TMR HDL Modules
# ============================================================================

puts "\[Step 1/9\] Verifying HDL modules..."

# NOTE: HDL modules were imported in create_miv_tmr_project.tcl
# We DON'T re-import here to avoid file conflicts warnings
# We also DON'T import any files that instantiate our voter modules
# (like peripheral_voter.v, memory_voter.v) because that would make
# triple_voter a "sub-module" and break sd_instantiate_hdl_module

# Build hierarchy - this confirms modules are available as top-level
build_design_hierarchy

puts "✓ TMR HDL modules verified (imported in project creation)"
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

# Instantiate the 1-bit voter HDL module in SmartDesign
# CRITICAL: Use the PROJECT's copy of the file, NOT the source directory
# The source directory contains other files that instantiate triple_voter,
# which would make it a sub-module and break instantiation!
#
# NOTE: Using triple_voter_1bit instead of parameterized triple_voter because
# sd_configure_core_instance only works with IP cores, NOT raw HDL modules.
# See docs/libero_build_flow_lessons.md for details.
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {triple_voter_1bit} -hdl_file {hdl/triple_voter_1bit.v} -instance_name {VOTER_EXT_RESETN}

puts "✓ Triple voter instantiated (1-bit for EXT_RESETN)"
puts ""

# ============================================================================
# Step 5: Create External Interfaces (Ports)
# ============================================================================

puts "\[Step 5/9\] Creating external interfaces..."

# Clock input
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {CLK_IN} -port_direction {IN}

# Reset input
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {RST_N_IN} -port_direction {IN}

# Heartbeat LED (shows clock is running - direct clock connection)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {HEARTBEAT_LED} -port_direction {OUT}

# LED Pattern (8-bit animated pattern driven by functional block)
sd_create_bus_port -sd_name {TMR_TOP} -port_name {LED_PATTERN} -port_direction {OUT} -port_range {[7:0]}

# Status LED (blinks at 1 Hz when TMR system active)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {STATUS_LED} -port_direction {OUT}

# Disagreement LED (high when cores disagree)
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {DISAGREE_LED} -port_direction {OUT}

# Fault LEDs (3 bits - one per core)
sd_create_bus_port -sd_name {TMR_TOP} -port_name {FAULT_LEDS} -port_direction {OUT} -port_range {[2:0]}

puts "✓ External interfaces created (6 ports, 13 pins total)"
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

# Voter outputs will be connected to functional outputs module (not directly to LEDs)
# This creates the data path: Cores → Voter → Functional Outputs → LEDs → Pins

puts "✓ MI-V cores connected through voter"
puts ""

# ============================================================================
# Step 8: Instantiate Functional Outputs Module
# ============================================================================

puts "\[Step 8/9\] Instantiating functional outputs module..."

# Instantiate the functional outputs HDL module
# Use PROJECT's copy (relative path from project folder)
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {tmr_functional_outputs} -hdl_file {hdl/tmr_functional_outputs.v} -instance_name {FUNCTIONAL_OUTPUTS}

puts "✓ Functional outputs module instantiated"
puts ""

# ============================================================================
# Step 9: Connect Functional Outputs
# ============================================================================

puts "\[Step 9/9\] Connecting functional outputs..."

# Connect clock and reset to functional outputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "FUNCTIONAL_OUTPUTS:clk"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "FUNCTIONAL_OUTPUTS:rst_n"}

# Connect voted EXT_RESETN to functional outputs (KEY CONNECTION!)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:voted_output" "FUNCTIONAL_OUTPUTS:voted_resetn"}

# Connect disagreement and fault flags to functional outputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:disagreement" "FUNCTIONAL_OUTPUTS:disagreement"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:fault_flags" "FUNCTIONAL_OUTPUTS:fault_flags"}

# Connect functional outputs to external LED ports
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"FUNCTIONAL_OUTPUTS:led_pattern" "LED_PATTERN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"FUNCTIONAL_OUTPUTS:status_led" "STATUS_LED"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"FUNCTIONAL_OUTPUTS:disagree_led" "DISAGREE_LED"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"FUNCTIONAL_OUTPUTS:fault_leds" "FAULT_LEDS"}

# NOTE: HEARTBEAT_LED is already connected to CLK_IN in Step 6 (line 138)
# Do NOT duplicate the connection here

puts "✓ Functional outputs connected to voted signals and LED pins"
puts ""

# ============================================================================
# Step 10: Save, Generate, and Set as Root
# ============================================================================

puts "\[Step 10/10\] Saving SmartDesign..."

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
puts "║        TMR SmartDesign with Functional Connectivity Complete       ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""
puts "TMR Architecture:"
puts "  ✓ 3x MI-V RV32IMC cores (synchronized clock/reset)"
puts "  ✓ Triple voter (2-of-3 majority voting on EXT_RESETN)"
puts "  ✓ Functional outputs module (counter + LED patterns)"
puts "  ✓ Fault detection and disagreement monitoring"
puts ""
puts "Data Flow Path (KEY - prevents optimization):"
puts "  Cores → Voter → Functional Block → Counter → LEDs → I/O Pins"
puts ""
puts "Output Signals (13 pins total):"
puts "  HEARTBEAT_LED - Clock indicator"
puts "  LED_PATTERN\[7:0\] - Animated pattern (changes every ~2.7s)"
puts "  STATUS_LED    - Blinks at 1 Hz (proves voted signal functional)"
puts "  DISAGREE_LED  - High when cores disagree"
puts "  FAULT_LEDS\[2:0\] - Individual core fault flags"
puts ""
puts "Why This Works:"
puts "  - Voted EXT_RESETN ENABLES counter (functional use, not static!)"
puts "  - Counter drives LED pattern (observable behavior)"
puts "  - Multiple outputs (13 pins) create fanout"
puts "  - Real data path prevents synthesis optimization"
puts ""
puts "Expected Synthesis Results:"
puts "  - ~35,000 LUTs (3x MI-V cores + voter + counter)"
puts "  - All 3 cores preserved in netlist"
puts "  - Voter logic synthesized"
puts "  - Functional outputs working"
puts ""
puts "Next Step:"
puts "  ./run_libero.sh tcl_scripts/tmr/build_tmr_project.tcl SCRIPT"
puts ""
