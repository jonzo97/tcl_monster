# ==============================================================================
# MI-V RV32 + DDR4 Timing Constraints
# ==============================================================================
#
# Clock Domains:
#   - CLK_50MHZ:     50 MHz input oscillator
#   - System Clock:  50 MHz (from PF_CCC OUT0)
#   - DDR AXI Clock: 200 MHz (from PF_CCC OUT1)
#   - DDR PHY Clock: 800 MHz (internal to PF_DDR4)
#
# ==============================================================================

# ==============================================================================
# Input Clock Constraint
# ==============================================================================

# 50 MHz oscillator input
create_clock -name {CLK_50MHZ} \
    -period 20.000 \
    -waveform {0.000 10.000} \
    [get_ports {CLK_50MHZ}]

# ==============================================================================
# Generated Clocks from PF_CCC
# ==============================================================================

# System clock: 50 MHz (OUT0_FABCLK_0)
# This clock is used by MI-V RISC-V core, peripherals, and fabric logic
create_generated_clock -name {SYSTEM_CLK_50MHZ} \
    -multiply_by 1 \
    -divide_by 1 \
    -source [get_pins {PF_CCC_C1_0/PF_CCC_C1_0/pll_inst_0/REF_CLK_0}] \
    -phase 0 \
    [get_pins {PF_CCC_C1_0/PF_CCC_C1_0/pll_inst_0/OUT0}]

# DDR AXI interface clock: 200 MHz (OUT1_FABCLK_0)
# This clock is used by the AXI interface to DDR4 controller
create_generated_clock -name {DDR_AXI_CLK_200MHZ} \
    -multiply_by 4 \
    -divide_by 1 \
    -source [get_pins {PF_CCC_C1_0/PF_CCC_C1_0/pll_inst_0/REF_CLK_0}] \
    -phase 0 \
    [get_pins {PF_CCC_C1_0/PF_CCC_C1_0/pll_inst_0/OUT1}]

# ==============================================================================
# Clock Groups (Asynchronous Clock Domains)
# ==============================================================================

# System clock and DDR AXI clock are synchronous (both from same PLL)
# but paths between them should be constrained carefully
set_clock_groups -name {ASYNC_CLK_GROUPS} \
    -asynchronous \
    -group [get_clocks {CLK_50MHZ}] \
    -group [get_clocks {SYSTEM_CLK_50MHZ DDR_AXI_CLK_200MHZ}]

# DDR4 controller internal clocks are handled by PF_DDR4 IP
# and should not be manually constrained

# ==============================================================================
# Input Delay Constraints
# ==============================================================================

# Reset button
set_input_delay -clock {SYSTEM_CLK_50MHZ} \
    -max 5.000 \
    [get_ports {RESET_N}]

set_input_delay -clock {SYSTEM_CLK_50MHZ} \
    -min 2.000 \
    [get_ports {RESET_N}]

# UART RX
set_input_delay -clock {SYSTEM_CLK_50MHZ} \
    -max 5.000 \
    [get_ports {UART_RX}]

set_input_delay -clock {SYSTEM_CLK_50MHZ} \
    -min 2.000 \
    [get_ports {UART_RX}]

# ==============================================================================
# Output Delay Constraints
# ==============================================================================

# UART TX
set_output_delay -clock {SYSTEM_CLK_50MHZ} \
    -max 5.000 \
    [get_ports {UART_TX}]

set_output_delay -clock {SYSTEM_CLK_50MHZ} \
    -min -2.000 \
    [get_ports {UART_TX}]

# GPIO outputs (LEDs) - relaxed timing
set_output_delay -clock {SYSTEM_CLK_50MHZ} \
    -max 10.000 \
    [get_ports {GPIO_OUT[*]}]

set_output_delay -clock {SYSTEM_CLK_50MHZ} \
    -min -5.000 \
    [get_ports {GPIO_OUT[*]}]

# ==============================================================================
# False Paths
# ==============================================================================

# Reset is asynchronous
set_false_path -from [get_ports {RESET_N}]

# ==============================================================================
# Multicycle Paths
# ==============================================================================

# Add multicycle path constraints here if needed for specific paths
# Example:
# set_multicycle_path -setup -from [get_clocks {SYSTEM_CLK_50MHZ}] \
#                              -to [get_clocks {DDR_AXI_CLK_200MHZ}] 2

# ==============================================================================
# DDR4 Timing
# ==============================================================================

# DDR4 timing is handled internally by PF_DDR4 IP core
# The IP includes built-in timing constraints for:
# - DDR4 setup/hold times
# - ODT timing
# - DQS-DQ relationships
# - Address/command timing
#
# These constraints are automatically applied when PF_DDR4 is instantiated
# and do not require manual specification

# ==============================================================================
# Design Rule Constraints
# ==============================================================================

# Set maximum fanout for high-fanout nets
set_max_fanout 100 [current_design]

# Set maximum transition time
set_max_transition 2.000 [current_design]

# ==============================================================================
# End of Timing Constraints
# ==============================================================================
