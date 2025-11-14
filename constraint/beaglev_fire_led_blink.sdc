# BeagleV-Fire LED Blink Timing Constraints
# Target: MPFS025T-FCVG484E

# Clock constraint - 50 MHz (20ns period)
create_clock -name {clk_50mhz} -period 20 [get_ports {clk_50mhz}]

# Output delay constraints (setup + routing delay to external load)
set_output_delay -clock {clk_50mhz} 5 [get_ports {led}]

# Asynchronous reset - no timing relationship to clock
set_false_path -to [all_registers -async_pins]
