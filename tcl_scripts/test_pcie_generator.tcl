#!/usr/bin/env tclsh
# ==============================================================================
# Test Script for PCIe Configuration Generator
# ==============================================================================
#
# Purpose: Validate PCIe generator produces correct configurations
# Usage:   tclsh tcl_scripts/test_pcie_generator.tcl
#
# ==============================================================================

# Source the generator
source tcl_scripts/lib/generators/pcie_config_generator.tcl

puts "\n=========================================="
puts "Testing PCIe Configuration Generator"
puts "=========================================="

# Create templates directory if it doesn't exist
file mkdir tcl_scripts/lib/templates

# ==============================================================================
# Test 1: x1 Gen1 Endpoint (most common add-in card)
# ==============================================================================
puts "\n--- Test 1: PCIe Endpoint x1 Gen1 ---"
set output_file "tcl_scripts/lib/templates/pcie_ep_x1_gen1.tcl"
generate_pcie_ep_x1_gen1 "PF_PCIE_EP_X1" $output_file

# Verify file was created
if {[file exists $output_file]} {
    puts "✓ Template file created: $output_file"

    # Check file size
    set size [file size $output_file]
    if {$size > 1000} {
        puts "✓ File size looks reasonable: $size bytes"
    } else {
        puts "✗ WARNING: File size seems too small: $size bytes"
    }
} else {
    puts "✗ ERROR: Template file not created!"
}

# ==============================================================================
# Test 2: x4 Gen2 Endpoint (high performance)
# ==============================================================================
puts "\n--- Test 2: PCIe Endpoint x4 Gen2 ---"
set output_file "tcl_scripts/lib/templates/pcie_ep_x4_gen2.tcl"
generate_pcie_ep_x4_gen2 "PF_PCIE_EP_X4" $output_file

if {[file exists $output_file]} {
    puts "✓ Template file created: $output_file"
    set size [file size $output_file]
    if {$size > 1000} {
        puts "✓ File size looks reasonable: $size bytes"
    } else {
        puts "✗ WARNING: File size seems too small: $size bytes"
    }
} else {
    puts "✗ ERROR: Template file not created!"
}

# ==============================================================================
# Test 3: x4 Gen2 Root Port (host controller)
# ==============================================================================
puts "\n--- Test 3: PCIe Root Port x4 Gen2 ---"
set output_file "tcl_scripts/lib/templates/pcie_rp_x4_gen2.tcl"
generate_pcie_rp_x4_gen2 "PF_PCIE_RP_X4" $output_file

if {[file exists $output_file]} {
    puts "✓ Template file created: $output_file"
    set size [file size $output_file]
    if {$size > 1000} {
        puts "✓ File size looks reasonable: $size bytes"
    } else {
        puts "✗ WARNING: File size seems too small: $size bytes"
    }
} else {
    puts "✗ ERROR: Template file not created!"
}

# ==============================================================================
# Test 4: Custom Endpoint Configuration
# ==============================================================================
puts "\n--- Test 4: Custom PCIe Endpoint (x2 lanes, Gen1, custom IDs) ---"
set output_file "tcl_scripts/lib/templates/pcie_ep_custom.tcl"
generate_pcie_endpoint \
    -num_lanes 2 \
    -speed "Gen1" \
    -bar0_size "256 KB" \
    -device_id "0xABCD" \
    -vendor_id "0x1234" \
    -component_name "PF_PCIE_CUSTOM" \
    -output_file $output_file

if {[file exists $output_file]} {
    puts "✓ Template file created: $output_file"

    # Verify custom parameters in file
    set fp [open $output_file r]
    set content [read $fp]
    close $fp

    if {[string match "*0xABCD*" $content]} {
        puts "✓ Custom device ID found in configuration"
    }
    if {[string match "*0x1234*" $content]} {
        puts "✓ Custom vendor ID found in configuration"
    }
    if {[string match "*256 KB*" $content]} {
        puts "✓ Custom BAR0 size found in configuration"
    }
    if {[string match "*x2 lanes*" $content]} {
        puts "✓ x2 lane configuration found"
    }
} else {
    puts "✗ ERROR: Template file not created!"
}

# ==============================================================================
# Test 5: Validation - Invalid Lane Count
# ==============================================================================
puts "\n--- Test 5: Validation - Invalid Lane Count (should show error) ---"
puts "Testing with num_lanes = 8 (invalid, should reject):"
generate_pcie_endpoint -num_lanes 8 -output_file "should_not_exist.tcl"
if {![file exists "should_not_exist.tcl"]} {
    puts "✓ Generator correctly rejected invalid lane count"
}

# ==============================================================================
# Summary
# ==============================================================================
puts "\n=========================================="
puts "Test Summary"
puts "=========================================="

set template_files [glob -nocomplain tcl_scripts/lib/templates/pcie_*.tcl]
puts "Generated [llength $template_files] PCIe template files:"
foreach file $template_files {
    puts "  - $file ([file size $file] bytes)"
}

puts "\n✓ PCIe generator tests complete!"
puts "\nGenerated templates can be used with:"
puts "  source tcl_scripts/lib/templates/pcie_ep_x1_gen1.tcl"
puts ""
puts "Or source the generator and call functions directly:"
puts "  source tcl_scripts/lib/generators/pcie_config_generator.tcl"
puts "  generate_pcie_ep_x1_gen1 \"MY_PCIE\" \"my_config.tcl\""
puts ""
