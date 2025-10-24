# ==============================================================================
# Test DDR4 Configuration Generator
# ==============================================================================

source tcl_scripts/lib/generators/ddr4_config_generator.tcl

puts "======================================================================"
puts "Testing DDR4 Configuration Generator"
puts "======================================================================"

# Test 1: Generate 4GB DDR4 configuration (MPF300 Eval Kit)
puts "\nTest 1: 4GB DDR4 @ 1600 Mbps"
puts "----------------------------------------------------------------------"
generate_mpf300_4gb_ddr4 "PF_DDR4_4GB_C0" "tcl_scripts/lib/templates/pf_ddr4_4gb_1600.tcl"

# Test 2: Generate 2GB DDR4 configuration
puts "\nTest 2: 2GB DDR4 @ 1600 Mbps"
puts "----------------------------------------------------------------------"
generate_mpf300_2gb_ddr4 "PF_DDR4_2GB_C0" "tcl_scripts/lib/templates/pf_ddr4_2gb_1600.tcl"

# Test 3: Generate 1GB DDR4 configuration
puts "\nTest 3: 1GB DDR4 @ 1600 Mbps"
puts "----------------------------------------------------------------------"
generate_mpf300_1gb_ddr4 "PF_DDR4_1GB_C0" "tcl_scripts/lib/templates/pf_ddr4_1gb_1600.tcl"

# Test 4: Custom configuration - high speed
puts "\nTest 4: Custom 4GB DDR4 @ 2400 Mbps"
puts "----------------------------------------------------------------------"
generate_ddr4_config \
    -size "4GB" \
    -speed "2400" \
    -width "32" \
    -axi_width "64" \
    -axi_clk "300.0" \
    -component_name "PF_DDR4_FAST_C0" \
    -output_file "tcl_scripts/lib/templates/pf_ddr4_4gb_2400.tcl"

puts "\n======================================================================"
puts "Test Complete"
puts "======================================================================"
puts "Generated configuration templates in tcl_scripts/lib/templates/"
