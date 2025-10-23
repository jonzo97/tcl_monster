# Written by Synplify Pro version map202309actp1, Build 008R. Synopsys Run ID: sid1761195142 
# Top Level Design Parameters 

# Clocks 
create_clock -period 20.000 -waveform {0.000 10.000} -name {clk_50mhz} [get_ports {clk_50mhz}] 

# Virtual Clocks 

# Generated Clocks 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 
set_false_path -from [get_ports {reset_n}] -to [get_cells {counter[23] counter[22] counter[21] counter[20] counter[19] counter[18] counter[17] counter[16] counter[15] counter[14] counter[13] counter[12] counter[11] counter[10] counter[9] counter[8] counter[7] counter[6] counter[5] counter[4] counter[3] counter[2] counter[1] counter[0] led_reg[7] led_reg[6] led_reg[5] led_reg[4] led_reg[3] led_reg[2] led_reg[1] led_reg[0]}] 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 
set_input_delay {5} -max -clock [get_clocks {clk_50mhz}] [get_ports {reset_n}]
set_input_delay {0} -min -clock [get_clocks {clk_50mhz}] [get_ports {reset_n}]

# Output Delay Constraints 
set_output_delay {0} -min -clock [get_clocks {clk_50mhz}] [get_ports {leds[*]}]
set_output_delay {10} -max -clock [get_clocks {clk_50mhz}] [get_ports {leds[*]}]

# Wire Loads 

# Other Constraints 
set_clock_uncertainty -setup {0.200} [get_clocks {clk_50mhz}]
set_clock_uncertainty -hold {0.100} [get_clocks {clk_50mhz}]

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 


# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

