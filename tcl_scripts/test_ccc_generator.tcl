# ==============================================================================
# Test PF_CCC Configuration Generator
# ==============================================================================

source tcl_scripts/lib/generators/ccc_config_generator.tcl

puts "======================================================================"
puts "Testing PF_CCC Configuration Generator"
puts "======================================================================"

# Test 1: Single output (MI-V standard)
puts "\nTest 1: Single Output - 50 MHz in → 50 MHz out"
puts "----------------------------------------------------------------------"
generate_miv_ccc "PF_CCC_MIV_C0" "tcl_scripts/lib/templates/pf_ccc_miv_50mhz.tcl"

# Test 2: Dual output (MI-V + DDR)
puts "\nTest 2: Dual Output - 50 MHz in → 50 MHz + 200 MHz out"
puts "----------------------------------------------------------------------"
generate_miv_ddr_ccc "PF_CCC_MIV_DDR_C1" "tcl_scripts/lib/templates/pf_ccc_miv_ddr.tcl"

# Test 3: Custom dual output
puts "\nTest 3: Custom Dual Output - 50 MHz in → 100 MHz + 150 MHz out"
puts "----------------------------------------------------------------------"
generate_ccc_dual_output \
    -input_freq "50" \
    -output0_freq "100" \
    -output1_freq "150" \
    -component_name "PF_CCC_CUSTOM_C0" \
    -output_file "tcl_scripts/lib/templates/pf_ccc_custom.tcl"

puts "\n======================================================================"
puts "Test Complete"
puts "======================================================================"
puts "Generated CCC configuration templates in tcl_scripts/lib/templates/"
puts ""
puts "NOTE: These are simplified configurations."
puts "      For production use, verify and tune in Libero GUI."
