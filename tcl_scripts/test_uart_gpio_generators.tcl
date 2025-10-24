# ==============================================================================
# Test UART and GPIO Configuration Generators
# ==============================================================================

puts "======================================================================"
puts "Testing UART and GPIO Configuration Generators"
puts "======================================================================"

# ==============================================================================
# Test UART Generator
# ==============================================================================

source tcl_scripts/lib/generators/uart_config_generator.tcl

puts "\n======================================================================"
puts "UART Generator Tests"
puts "======================================================================"

# Test 1: Standard 115200 baud
puts "\nTest 1: UART 115200 baud @ 50 MHz"
puts "----------------------------------------------------------------------"
generate_uart_115200 "CoreUARTapb_115200" "tcl_scripts/lib/templates/uart_115200.tcl"

# Test 2: Slow 9600 baud
puts "\nTest 2: UART 9600 baud @ 50 MHz"
puts "----------------------------------------------------------------------"
generate_uart_9600 "CoreUARTapb_9600" "tcl_scripts/lib/templates/uart_9600.tcl"

# Test 3: High speed 460800 baud
puts "\nTest 3: UART 460800 baud @ 50 MHz"
puts "----------------------------------------------------------------------"
generate_uart_460800 "CoreUARTapb_460800" "tcl_scripts/lib/templates/uart_460800.tcl"

# Test 4: Custom baud rate
puts "\nTest 4: UART 57600 baud @ 50 MHz (custom)"
puts "----------------------------------------------------------------------"
generate_uart_custom 50000000 57600 "CoreUARTapb_57600" "tcl_scripts/lib/templates/uart_57600.tcl"

# Test 5: Different system clock
puts "\nTest 5: UART 115200 baud @ 100 MHz system clock"
puts "----------------------------------------------------------------------"
generate_uart_custom 100000000 115200 "CoreUARTapb_100MHz" "tcl_scripts/lib/templates/uart_115200_100mhz.tcl"

# ==============================================================================
# Test GPIO Generator
# ==============================================================================

source tcl_scripts/lib/generators/gpio_config_generator.tcl

puts "\n======================================================================"
puts "GPIO Generator Tests"
puts "======================================================================"

# Test 1: 8 LED outputs
puts "\nTest 1: 8 GPIO outputs (LEDs)"
puts "----------------------------------------------------------------------"
generate_gpio_leds 8 "CoreGPIO_LEDS" "tcl_scripts/lib/templates/gpio_leds_8.tcl"

# Test 2: 4 button inputs
puts "\nTest 2: 4 GPIO inputs (buttons)"
puts "----------------------------------------------------------------------"
generate_gpio_buttons 4 "CoreGPIO_BUTTONS" "tcl_scripts/lib/templates/gpio_buttons_4.tcl"

# Test 3: Bidirectional GPIO
puts "\nTest 3: 8 bidirectional GPIO"
puts "----------------------------------------------------------------------"
generate_gpio_bidir 8 "CoreGPIO_BIDIR" "tcl_scripts/lib/templates/gpio_bidir_8.tcl"

# Test 4: Output with pattern
puts "\nTest 4: 4 GPIO outputs with pattern (1010)"
puts "----------------------------------------------------------------------"
generate_gpio_output_pattern 4 {1 0 1 0} "CoreGPIO_PATTERN" "tcl_scripts/lib/templates/gpio_pattern_4.tcl"

# Test 5: Maximum 32 pins
puts "\nTest 5: 32 GPIO outputs (maximum)"
puts "----------------------------------------------------------------------"
set init_vals {}
for {set i 0} {$i < 32} {incr i} {
    lappend init_vals [expr {$i % 2}]
}
generate_gpio_config \
    -num_pins 32 \
    -direction "output" \
    -initial_values $init_vals \
    -component_name "CoreGPIO_MAX" \
    -output_file "tcl_scripts/lib/templates/gpio_max_32.tcl"

puts "\n======================================================================"
puts "Test Complete"
puts "======================================================================"
puts "Generated configuration templates in tcl_scripts/lib/templates/"
puts ""
puts "UART templates:"
puts "  - uart_115200.tcl (standard)"
puts "  - uart_9600.tcl (slow)"
puts "  - uart_460800.tcl (fast)"
puts "  - uart_57600.tcl (custom)"
puts "  - uart_115200_100mhz.tcl (different sys clock)"
puts ""
puts "GPIO templates:"
puts "  - gpio_leds_8.tcl (8 output pins)"
puts "  - gpio_buttons_4.tcl (4 input pins)"
puts "  - gpio_bidir_8.tcl (8 bidirectional)"
puts "  - gpio_pattern_4.tcl (4 outputs with pattern)"
puts "  - gpio_max_32.tcl (32 outputs, maximum)"
