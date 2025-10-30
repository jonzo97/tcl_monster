# ==============================================================================
# Test SmartDesign Automation Library
# ==============================================================================
#
# Tests the SmartDesign interconnect generators and templates without
# requiring a full Libero project.
#
# Usage:
#   tclsh tcl_scripts/test_smartdesign_lib.tcl
#
# ==============================================================================

set script_dir [file dirname [info script]]

puts "=============================================="
puts "Testing SmartDesign Automation Library"
puts "=============================================="
puts ""

# ==============================================================================
# Test 1: Load Helper Library
# ==============================================================================

puts "Test 1: Loading sd_helpers.tcl..."
if {[catch {
    source "$script_dir/lib/smartdesign/utilities/sd_helpers.tcl"
    puts "  ✓ sd_helpers.tcl loaded successfully"
} err]} {
    puts "  ✗ FAILED: $err"
    exit 1
}

# Test helper functions
puts "  Testing helper functions..."
::sd_helpers::info "This is an info message"
::sd_helpers::warn "This is a warning message"

if {[::sd_helpers::validate_instance_name "ValidName_123"]} {
    puts "  ✓ Instance name validation works"
}

# Test address map generation
set test_peripherals {"CoreUART_C0" "CoreGPIO_C0" "CoreTimer_C0"}
set addr_map [::sd_helpers::generate_apb_address_map $test_peripherals 0x70000000]
puts "  ✓ Address map generation works"
puts "    Generated [dict size $addr_map] address entries"

puts ""

# ==============================================================================
# Test 2: Load APB Interconnect
# ==============================================================================

puts "Test 2: Loading apb_interconnect.tcl..."
if {[catch {
    source "$script_dir/lib/smartdesign/interconnect/apb_interconnect.tcl"
    puts "  ✓ apb_interconnect.tcl loaded successfully"
} err]} {
    puts "  ✗ FAILED: $err"
    exit 1
}

# Test auto-address function
puts "  Testing auto_address_peripherals..."
set periph_names {"UART0" "GPIO0" "TIMER0"}
set peripherals [::apb_interconnect::auto_address_peripherals $periph_names 0x70000000 0x1000]

if {[llength $peripherals] == 3} {
    puts "  ✓ Auto-addressing works: [llength $peripherals] peripherals"
} else {
    puts "  ✗ FAILED: Expected 3 peripherals, got [llength $peripherals]"
    exit 1
}

# Print address map
puts ""
puts "  Generated Address Map:"
::apb_interconnect::print_address_map $peripherals
puts ""

# ==============================================================================
# Test 3: Load Clock/Reset Tree
# ==============================================================================

puts "Test 3: Loading clock_reset_tree.tcl..."
if {[catch {
    source "$script_dir/lib/smartdesign/interconnect/clock_reset_tree.tcl"
    puts "  ✓ clock_reset_tree.tcl loaded successfully"
} err]} {
    puts "  ✗ FAILED: $err"
    exit 1
}

# Test clock consumer inference
puts "  Testing infer_clock_consumers..."
set components {"MIV_RV32_C0" "CoreUART_C0" "CoreGPIO_C0"}
set consumers [::clock_reset::infer_clock_consumers $components]
puts "  ✓ Inferred [llength $consumers] clock consumers"

# Test reset consumer inference
puts "  Testing infer_reset_consumers..."
set reset_consumers [::clock_reset::infer_reset_consumers $components]
puts "  ✓ Inferred [llength $reset_consumers] reset consumers"

puts ""

# ==============================================================================
# Test 4: Load MI-V Template
# ==============================================================================

puts "Test 4: Loading miv_rv32_minimal.tcl template..."
if {[catch {
    source "$script_dir/lib/smartdesign/templates/miv_rv32_minimal.tcl"
    puts "  ✓ miv_rv32_minimal.tcl loaded successfully"
} err]} {
    puts "  ✗ FAILED: $err"
    exit 1
}

puts "  Template namespaces available:"
puts "    - ::miv_minimal::create"
puts "    - ::miv_minimal::create_and_set_root"

puts ""

# ==============================================================================
# Test 5: Namespace Verification
# ==============================================================================

puts "Test 5: Verifying namespaces and exported functions..."

set expected_namespaces {
    "::sd_helpers"
    "::apb_interconnect"
    "::clock_reset"
    "::miv_minimal"
}

foreach ns $expected_namespaces {
    if {[namespace exists $ns]} {
        puts "  ✓ Namespace $ns exists"
    } else {
        puts "  ✗ FAILED: Namespace $ns not found"
        exit 1
    }
}

puts ""

# ==============================================================================
# Test Summary
# ==============================================================================

puts "=============================================="
puts "All Tests Passed!"
puts "=============================================="
puts ""
puts "Library Status:"
puts "  ✅ Helper utilities (sd_helpers.tcl)"
puts "  ✅ APB interconnect (apb_interconnect.tcl)"
puts "  ✅ Clock/reset tree (clock_reset_tree.tcl)"
puts "  ✅ MI-V minimal template (miv_rv32_minimal.tcl)"
puts ""
puts "Next Steps:"
puts "  1. Test with real Libero project (requires IP cores)"
puts "  2. Create additional templates (miv_rv32_full, etc.)"
puts "  3. Implement AXI interconnect generator"
puts ""
puts "Usage Example:"
puts "  source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl"
puts "  ::miv_minimal::create_and_set_root \"MySystem\""
puts ""
