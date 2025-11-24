# Timing Constraints for MI-V TMR System with Voter Logic
# Target: 50 MHz operation

# ==============================================================================
# Clock Definition
# ==============================================================================

# 50 MHz input clock (20ns period)
create_clock -name {CLK_IN} -period 20 -waveform {0 10} [get_ports {CLK_IN}]

# ==============================================================================
# Clock Uncertainty
# ==============================================================================

# Add pessimism for clock jitter and skew
set_clock_uncertainty 0.5 [get_clocks {CLK_IN}]

# ==============================================================================
# False Paths
# ==============================================================================

# Reset paths are asynchronous
set_false_path -from [get_ports {RST_N_IN}]

# ==============================================================================
# Output Delays
# ==============================================================================

# LED outputs (10ns setup time relative to clock)
# Port names must match exactly what's in TMR_TOP SmartDesign
set_output_delay -clock {CLK_IN} -max 10 [get_ports {HEARTBEAT_LED}]
set_output_delay -clock {CLK_IN} -max 10 [get_ports {STATUS_LED}]
set_output_delay -clock {CLK_IN} -max 10 [get_ports {DISAGREE_LED}]
set_output_delay -clock {CLK_IN} -max 10 [get_ports {LED_PATTERN[*]}]
set_output_delay -clock {CLK_IN} -max 10 [get_ports {FAULT_LEDS[*]}]

# ==============================================================================
# Multi-Cycle Paths (if needed for voter logic)
# ==============================================================================

# Voter logic has 1-cycle latency, which is acceptable for status LEDs
# No multi-cycle constraints needed

# ==============================================================================
# Notes
# ==============================================================================

# TMR System Timing:
#   - All 3x MI-V cores synchronized to same clock
#   - Voter logic introduces 1-cycle latency (registered outputs)
#   - LED outputs are status indicators (not timing-critical)
#   - Focus on MI-V core internal timing (auto-constrained by IP)
