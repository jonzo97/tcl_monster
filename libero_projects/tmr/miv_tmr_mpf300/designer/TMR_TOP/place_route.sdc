# Microchip Technology Inc.
# Date: 2025-Nov-24 12:43:58
# This file was generated based on the following SDC source files:
#   C:/tcl_monster/constraint/tmr/miv_tmr_timing.sdc
#

create_clock -name {CLK_IN} -period 20 -waveform {0 10 } [ get_ports { CLK_IN } ]
set_output_delay 10 -max  -clock { CLK_IN } [ get_ports { HEARTBEAT_LED } ]
set_output_delay 10 -max  -clock { CLK_IN } [ get_ports { STATUS_LED } ]
set_output_delay 10 -max  -clock { CLK_IN } [ get_ports { DISAGREE_LED } ]
set_output_delay 10 -max  -clock { CLK_IN } [ get_ports { LED_PATTERN[*] } ]
set_output_delay 10 -max  -clock { CLK_IN } [ get_ports { FAULT_LEDS[*] } ]
set_false_path -from [ get_ports { RST_N_IN } ]
set_clock_uncertainty 0.500049 [ get_clocks { CLK_IN } ]
set_clock_uncertainty -hold 0 -rise_from [ get_clocks { CLK_IN } ] -rise_to [ get_clocks { CLK_IN } ]
set_clock_uncertainty -hold 0 -fall_from [ get_clocks { CLK_IN } ] -fall_to [ get_clocks { CLK_IN } ]
