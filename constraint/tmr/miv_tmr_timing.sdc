# Timing Constraints for MI-V TMR System
# Target: 50 MHz operation
#
# NOTE: Minimal constraints for initial synthesis
# Output port constraints will be added when outputs are created in SmartDesign

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
# Output Delays (TO BE ADDED)
# ==============================================================================

# LED output constraints will be added once SmartDesign ports are created:
#   - HEARTBEAT_LED, STATUS_LED, DISAGREE_LED
#   - LED_PATTERN[*], FAULT_LEDS[*]
#
# Example (uncomment when ports exist):
# set_output_delay -clock {CLK_IN} -max 10 [get_ports {HEARTBEAT_LED}]

# ==============================================================================
# Notes
# ==============================================================================

# TMR System Timing:
#   - All 3x MI-V cores synchronized to same clock
#   - Voter logic introduces 1-cycle latency (registered outputs)
#   - LED outputs are status indicators (not timing-critical)
#   - Focus on MI-V core internal timing (auto-constrained by IP)
