# Timing Constraints for LED Blinker

# Clock definition (50 MHz = 20ns period)
create_clock -name {clk} -period 20 -waveform {0 10} [get_ports {clk}]

# Input delays (assume 5ns from external source)
set_input_delay -clock {clk} -max 5 [get_ports {rst_n}]
set_input_delay -clock {clk} -min 2 [get_ports {rst_n}]

# Output delays (assume 5ns to external loads)
set_output_delay -clock {clk} -max 5 [get_ports {leds[*]}]
set_output_delay -clock {clk} -min 2 [get_ports {leds[*]}]

# Clock uncertainty (for pessimism)
set_clock_uncertainty 0.5 [get_clocks {clk}]
