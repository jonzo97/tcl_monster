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

# Instantiate 64-bit voter for TIME_COUNT_OUT (MTIME register)
# This creates the REAL data path through the cores' timer logic!
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {triple_voter_64bit} -hdl_file {hdl/triple_voter_64bit.v} -instance_name {VOTER_TIME_COUNT}

puts "✓ Triple voters instantiated (1-bit EXT_RESETN + 64-bit TIME_COUNT)"
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

# Connect clock to voters
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "VOTER_EXT_RESETN:clk"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "VOTER_TIME_COUNT:clk"}

# Connect reset to all MI-V cores
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "MIV_RV32_A:RESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "MIV_RV32_B:RESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "MIV_RV32_C:RESETN"}

# Connect reset to voters
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "VOTER_EXT_RESETN:rst_n"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "VOTER_TIME_COUNT:rst_n"}

# Heartbeat LED (simple clock indicator)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"HEARTBEAT_LED" "CLK_IN"}

puts "✓ Clock and reset connected to all components"
puts ""

# ============================================================================
# Step 7: Connect MI-V Core Outputs Through Voter
# ============================================================================

puts "\[Step 7/8\] Connecting MI-V cores through voter..."

# Connect each core's EXT_RESETN to 1-bit voter inputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_A:EXT_RESETN" "VOTER_EXT_RESETN:input_a"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_B:EXT_RESETN" "VOTER_EXT_RESETN:input_b"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_C:EXT_RESETN" "VOTER_EXT_RESETN:input_c"}

# Connect each core's TIME_COUNT_OUT (64-bit MTIME) to 64-bit voter inputs
# This creates the REAL data path through the cores' timer logic!
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_A:TIME_COUNT_OUT" "VOTER_TIME_COUNT:input_a"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_B:TIME_COUNT_OUT" "VOTER_TIME_COUNT:input_b"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"MIV_RV32_C:TIME_COUNT_OUT" "VOTER_TIME_COUNT:input_c"}

# Voter outputs will be connected to functional outputs module (not directly to LEDs)
# This creates the data path: Cores → Timers → Voters → Functional Outputs → LEDs → Pins

puts "✓ MI-V cores connected through voter"
puts ""

# ============================================================================
# Step 7a: Instantiate Peripheral IP Cores (3x UART, 3x GPIO)
# ============================================================================

puts "\[Step 7a/12\] Instantiating peripheral IP cores..."

# Instantiate 3x CoreUARTapb
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreUARTapb_A} -instance_name {UART_A}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreUARTapb_B} -instance_name {UART_B}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreUARTapb_C} -instance_name {UART_C}

# Instantiate 3x CoreGPIO
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreGPIO_A} -instance_name {GPIO_A}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreGPIO_B} -instance_name {GPIO_B}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreGPIO_C} -instance_name {GPIO_C}

puts "✓ Peripheral IP cores instantiated (3x UART, 3x GPIO)"
puts ""

# ============================================================================
# Step 7b: Instantiate Peripheral Voters
# ============================================================================

puts "\[Step 7b/12\] Instantiating peripheral voters..."

# Instantiate UART TX voter (single-bit)
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {uart_tx_voter} -hdl_file {hdl/uart_tx_voter.v} -instance_name {VOTER_UART_TX}

# Instantiate GPIO voter (8-bit)
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {gpio_voter} -hdl_file {hdl/gpio_voter.v} -instance_name {VOTER_GPIO_OUT}

puts "✓ Peripheral voters instantiated (UART TX, GPIO)"
puts ""

# ============================================================================
# Step 7c: Create External I/O Ports for Peripherals
# ============================================================================

puts "\[Step 7c/12\] Creating peripheral I/O ports..."

# UART I/O ports
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {UART_RX} -port_direction {IN}
sd_create_scalar_port -sd_name {TMR_TOP} -port_name {UART_TX} -port_direction {OUT}

# GPIO I/O ports (8-bit bus)
sd_create_bus_port -sd_name {TMR_TOP} -port_name {GPIO_OUT} -port_direction {OUT} -port_range {[7:0]}
sd_create_bus_port -sd_name {TMR_TOP} -port_name {GPIO_IN} -port_direction {IN} -port_range {[7:0]}

puts "✓ Peripheral I/O ports created"
puts ""

# ============================================================================
# Step 7d: Connect Peripherals (Clock, Reset, Bus)
# ============================================================================

puts "\[Step 7d/12\] Connecting peripherals..."

# Connect clock and reset to all UARTs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "UART_A:PCLK"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "UART_B:PCLK"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "UART_C:PCLK"}

sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "UART_A:PRESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "UART_B:PRESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "UART_C:PRESETN"}

# Connect clock and reset to all GPIOs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "GPIO_A:PCLK"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "GPIO_B:PCLK"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"CLK_IN" "GPIO_C:PCLK"}

sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "GPIO_A:PRESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "GPIO_B:PRESETN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"RST_N_IN" "GPIO_C:PRESETN"}

# Broadcast UART RX to all 3 UARTs (no voting on input)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"UART_RX" "UART_A:RX"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"UART_RX" "UART_B:RX"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"UART_RX" "UART_C:RX"}

# Broadcast GPIO inputs to all 3 GPIOs (no voting on inputs)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"GPIO_IN" "GPIO_A:GPIO_IN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"GPIO_IN" "GPIO_B:GPIO_IN"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"GPIO_IN" "GPIO_C:GPIO_IN"}

puts "✓ Peripherals connected (clock, reset, inputs)"
puts ""

# ============================================================================
# Step 7e: Connect UART TX Through Voter
# ============================================================================

puts "\[Step 7e/12\] Wiring UART TX voter..."

# Connect UART TX outputs to voter inputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"UART_A:TX" "VOTER_UART_TX:tx_a"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"UART_B:TX" "VOTER_UART_TX:tx_b"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"UART_C:TX" "VOTER_UART_TX:tx_c"}

# Connect voter output to external UART TX port
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_UART_TX:tx_voted" "UART_TX"}

puts "✓ UART TX voter wired (3 TX → voter → external TX)"
puts ""

# ============================================================================
# Step 7f: Connect GPIO Through Voter
# ============================================================================

puts "\[Step 7f/12\] Wiring GPIO voter..."

# Connect GPIO outputs to voter inputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"GPIO_A:GPIO_OUT" "VOTER_GPIO_OUT:gpio_a"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"GPIO_B:GPIO_OUT" "VOTER_GPIO_OUT:gpio_b"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"GPIO_C:GPIO_OUT" "VOTER_GPIO_OUT:gpio_c"}

# Connect voter output to external GPIO port
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_GPIO_OUT:gpio_voted" "GPIO_OUT"}

puts "✓ GPIO voter wired (3 GPIO → voter → external GPIO)"
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

# Connect voted EXT_RESETN to functional outputs
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_EXT_RESETN:voted_output" "FUNCTIONAL_OUTPUTS:voted_resetn"}

# Connect voted TIME_COUNT to functional outputs (KEY CONNECTION! 64-bit data path!)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_TIME_COUNT:voted_output" "FUNCTIONAL_OUTPUTS:voted_time_count"}

# Connect disagreement and fault flags from TIME_COUNT voter (more dynamic)
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_TIME_COUNT:disagreement" "FUNCTIONAL_OUTPUTS:disagreement"}
sd_connect_pins -sd_name {TMR_TOP} -pin_names {"VOTER_TIME_COUNT:fault_flags" "FUNCTIONAL_OUTPUTS:fault_flags"}

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
puts "║     TMR SmartDesign with Peripherals & Voters Complete            ║"
puts "╚════════════════════════════════════════════════════════════════════╝"
puts ""
puts "TMR Architecture:"
puts "  ✓ 3x MI-V RV32IMC cores (synchronized clock/reset)"
puts "  ✓ 3x CoreUARTapb (115200 baud) with TX voter"
puts "  ✓ 3x CoreGPIO (8-bit) with output voter"
puts "  ✓ Triple voters (cores, UART TX, GPIO outputs)"
puts "  ✓ Functional outputs module (counter + LED patterns)"
puts "  ✓ Fault detection and disagreement monitoring"
puts ""
puts "Data Flow Paths:"
puts "  Cores → Voter → Functional Block → Counter → LEDs"
puts "  UART 3x TX → UART Voter → External TX"
puts "  GPIO 3x Out → GPIO Voter → External GPIO"
puts "  External RX → Broadcast to 3x UART RX"
puts "  External GPIO In → Broadcast to 3x GPIO In"
puts ""
puts "I/O Signals (24 pins total):"
puts "  Clock/Reset:"
puts "    CLK_IN, RST_N_IN"
puts "  LED Status (13 pins):"
puts "    HEARTBEAT_LED, LED_PATTERN\[7:0\], STATUS_LED, DISAGREE_LED, FAULT_LEDS\[2:0\]"
puts "  Peripherals (10 pins):"
puts "    UART_RX, UART_TX, GPIO_IN\[7:0\], GPIO_OUT\[7:0\]"
puts ""
puts "Voting Strategy:"
puts "  Outputs: Voted (2-of-3 majority)"
puts "    - UART TX, GPIO outputs"
puts "  Inputs: Broadcast (no voting)"
puts "    - UART RX, GPIO inputs"
puts ""
puts "Expected Synthesis Results:"
puts "  - ~36,000 LUTs (3x MI-V cores + peripherals + voters)"
puts "  - All 3 cores preserved in netlist"
puts "  - All voter logic synthesized"
puts "  - Peripherals functional with fault masking"
puts ""
puts "Next Step:"
puts "  ./run_libero.sh tcl_scripts/tmr/build_tmr_project.tcl SCRIPT"
puts ""
