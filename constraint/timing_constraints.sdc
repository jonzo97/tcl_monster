# =============================================================================
# Timing Constraints (SDC) for Counter Design
# Target: PolarFire MPF300 Eval Kit
# Device: MPF300TS-FCG1152
# =============================================================================
# SDC Version 2.0
# =============================================================================

# =============================================================================
# Clock Definitions
# =============================================================================

# 50 MHz input clock from oscillator
# Period = 20 ns (50 MHz = 1/20ns)
create_clock -name {clk_50mhz} \
             -period 20 \
             -waveform {0 10} \
             [get_ports {clk_50mhz}]

# =============================================================================
# Clock Uncertainty
# =============================================================================

# Add clock uncertainty for jitter and other variations
# Typical value: 0.1-0.2 ns for oscillator + FPGA routing
set_clock_uncertainty -setup 0.2 [get_clocks {clk_50mhz}]
set_clock_uncertainty -hold 0.1 [get_clocks {clk_50mhz}]

# =============================================================================
# Input/Output Delays
# =============================================================================

# Reset input delay
# Assume reset comes from push button with ~5ns delay relative to clock
set_input_delay -clock {clk_50mhz} -max 5.0 [get_ports {reset_n}]
set_input_delay -clock {clk_50mhz} -min 0.0 [get_ports {reset_n}]

# LED output delays
# LEDs are asynchronous outputs, but constrain for timing closure
# Assume 10ns setup time relative to clock edge
set_output_delay -clock {clk_50mhz} -max 10.0 [get_ports {leds[*]}]
set_output_delay -clock {clk_50mhz} -min 0.0 [get_ports {leds[*]}]

# =============================================================================
# False Paths
# =============================================================================

# Reset is asynchronous - no timing analysis needed
set_false_path -from [get_ports {reset_n}] -to [all_registers]

# LEDs are slow outputs - timing not critical
# (Optional: Remove this if you want to ensure timing)
# set_false_path -from [all_registers] -to [get_ports {leds[*]}]

# =============================================================================
# Multi-Cycle Paths
# =============================================================================

# No multi-cycle paths in this simple design

# =============================================================================
# Design Goals
# =============================================================================

# Target: Meet timing at 50 MHz (20ns period)
# Slack goal: > 2ns positive slack
# Max delay: < 18ns for any path

# =============================================================================
# Notes
# =============================================================================
# - This is a simple single-clock design
# - All logic is synchronous to clk_50mhz
# - Reset is properly treated as asynchronous
# - LED outputs have relaxed timing (could tighten if needed)
#
# To verify timing after build:
#   Check: libero_projects/counter_demo/designer/counter/counter_timing_violations_max.txt
#   Goal: No setup or hold violations
