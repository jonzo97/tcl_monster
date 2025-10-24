# ==============================================================================
# DDR4 Configuration Generator
# ==============================================================================
#
# Purpose: Generate PF_DDR4 IP core configurations from high-level parameters
# Usage:   source tcl_scripts/lib/generators/ddr4_config_generator.tcl
#          generate_ddr4_config -size "4GB" -speed "1600" -width "32"
#
# ==============================================================================

# ==============================================================================
# Helper Functions
# ==============================================================================

proc calculate_address_bits {size width} {
    # Calculate row/col/bank bits based on total size and width
    # Standard DDR4: 2 bank address bits, 2 bank group bits

    set bank_bits 2
    set bank_group_bits 2
    set width_bytes [expr {$width / 8}]

    # Total address bits needed
    # size_bytes = 2^(row + col + bank + bg + width_bytes_bits)
    # Solve for row + col

    set size_gb [string map {GB ""} $size]
    set size_bytes [expr {$size_gb * 1024 * 1024 * 1024}]
    set total_addr_bits [expr {int(log($size_bytes) / log(2))}]
    set width_bits [expr {int(log($width_bytes) / log(2))}]
    set remaining_bits [expr {$total_addr_bits - $bank_bits - $bank_group_bits - $width_bits}]

    # Standard split: 10 column bits, rest for rows
    set col_bits 10
    set row_bits [expr {$remaining_bits - $col_bits}]

    # Validate row bits (DDR4 supports 13-16 row bits)
    if {$row_bits < 13 || $row_bits > 16} {
        puts "WARNING: Calculated row_bits=$row_bits is out of DDR4 range (13-16)"
        set row_bits [expr {max(13, min(16, $row_bits))}]
        puts "         Adjusted to row_bits=$row_bits"
    }

    return [list $row_bits $col_bits $bank_bits $bank_group_bits]
}

proc calculate_latency {speed_mbps} {
    # Calculate CAS latency and write latency based on speed
    # Returns: [CL, CWL]

    set speed_mhz [expr {$speed_mbps / 2.0}]

    if {$speed_mhz <= 800} {
        # DDR4-1600
        return [list 12 9]
    } elseif {$speed_mhz <= 1066} {
        # DDR4-2133
        return [list 15 11]
    } elseif {$speed_mhz <= 1200} {
        # DDR4-2400
        return [list 16 12]
    } elseif {$speed_mhz <= 1333} {
        # DDR4-2666
        return [list 18 14]
    } else {
        # DDR4-3200 and higher
        return [list 22 16]
    }
}

proc calculate_timing_params {speed_mbps} {
    # Calculate timing parameters in nanoseconds based on speed
    # These are typical values for DDR4

    set speed_mhz [expr {$speed_mbps / 2.0}]
    set clock_period_ns [expr {1000.0 / $speed_mhz}]

    # Standard DDR4 timing constraints (in nanoseconds)
    # These are relatively constant across speed grades
    dict set timings TIMING_RAS 32.0
    dict set timings TIMING_RC 45.5
    dict set timings TIMING_RCD 13.5
    dict set timings TIMING_RP 13.5
    dict set timings TIMING_REFI 7.8
    dict set timings TIMING_RFC 350.0
    dict set timings TIMING_WR 15.0
    dict set timings TIMING_WTR_L 6.0
    dict set timings TIMING_WTR_S 2.0
    dict set timings TIMING_RTP 7.5
    dict set timings TIMING_RRD_L 5.0
    dict set timings TIMING_RRD_S 4.0
    dict set timings TIMING_CCD_L 4.0
    dict set timings TIMING_CCD_S 4.0
    dict set timings TIMING_FAW 25.0

    # Data strobe timings (picoseconds)
    dict set timings TIMING_DH 150
    dict set timings TIMING_DS 75
    dict set timings TIMING_DQSQ 200
    dict set timings TIMING_DQSCK 400
    dict set timings TIMING_DQSS 0.25
    dict set timings TIMING_DSH 0.2
    dict set timings TIMING_DSS 0.2

    # Setup timings
    dict set timings TIMING_IH 275
    dict set timings TIMING_IS 200
    dict set timings TIMING_INIT 200

    # Mode register delay
    dict set timings TIMING_MRD 4

    # Other timings
    dict set timings TIMING_QH 0.38
    dict set timings TIMING_QSH 0.38

    return $timings
}

# ==============================================================================
# Main Configuration Generator
# ==============================================================================

proc generate_ddr4_config {args} {
    # Parse arguments
    array set opts {
        -size "4GB"
        -speed "1600"
        -width "32"
        -axi_width "64"
        -component_name "PF_DDR4_C0"
        -axi_clk "200.0"
        -output_file ""
    }

    foreach {key value} $args {
        if {[info exists opts($key)]} {
            set opts($key) $value
        } else {
            puts "ERROR: Unknown option $key"
            return
        }
    }

    # Calculate derived parameters
    lassign [calculate_address_bits $opts(-size) $opts(-width)] row_bits col_bits bank_bits bg_bits
    lassign [calculate_latency $opts(-speed)] cas_lat cas_wlat
    set timings [calculate_timing_params $opts(-speed)]

    # Calculate clocks
    set ddr_clock [expr {$opts(-speed) / 2.0}]
    set pll_multiplier [expr {int($ddr_clock / $opts(-axi_clk))}]

    # Generate configuration
    set config "# Exporting Component Description of $opts(-component_name) to TCL\n"
    append config "# Auto-generated by DDR4 Configuration Generator\n"
    append config "# Configuration: $opts(-size) DDR4 @ $opts(-speed) Mbps, x$opts(-width)\n"
    append config "# Family: PolarFire\n"
    append config "# Create and Configure the core component $opts(-component_name)\n"
    append config "create_and_configure_core -core_vlnv {Actel:SystemBuilder:PF_DDR4:2.5.113} -component_name {$opts(-component_name)} -params {\\\n"

    # Memory topology
    append config "\"ADDRESS_MIRROR:false\" \\\n"
    append config "\"ADDRESS_ORDERING:CHIP_ROW_BG_BANK_COL\" \\\n"
    append config "\"AUTO_SELF_REFRESH:3\" \\\n"
    append config "\"AXI_ID_WIDTH:4\" \\\n"
    append config "\"AXI_WIDTH:$opts(-axi_width)\" \\\n"
    append config "\"BANKSTATMODULES:4\" \\\n"
    append config "\"BANK_ADDR_WIDTH:$bank_bits\" \\\n"
    append config "\"BANK_GROUP_ADDR_WIDTH:$bg_bits\" \\\n"
    append config "\"BURST_LENGTH:0\" \\\n"

    # Latency
    append config "\"CAS_ADDITIVE_LATENCY:0\" \\\n"
    append config "\"CAS_LATENCY:$cas_lat\" \\\n"
    append config "\"CAS_WRITE_LATENCY:$cas_wlat\" \\\n"
    append config "\"CA_PARITY_LATENCY_MODE:0\" \\\n"

    # Clocks
    append config "\"CCC_PLL_CLOCK_MULTIPLIER:$pll_multiplier\" \\\n"
    append config "\"CK_CA_ADDITIVE_OFFSET:4\" \\\n"
    append config "\"CLOCK_DDR:$ddr_clock\" \\\n"
    append config "\"CLOCK_PLL_REFERENCE:$opts(-axi_clk)\" \\\n"
    append config "\"CLOCK_RATE:$pll_multiplier\" \\\n"
    append config "\"CLOCK_USER:$opts(-axi_clk)\" \\\n"

    # Memory geometry
    append config "\"COL_ADDR_WIDTH:$col_bits\" \\\n"
    append config "\"DLL_ENABLE:1\" \\\n"
    append config "\"DM_MODE:DM\" \\\n"
    append config "\"DQ_DQS_GROUP_SIZE:8\" \\\n"

    # Feature enables
    append config "\"ENABLE_ECC:false\" \\\n"
    append config "\"ENABLE_INIT_INTERFACE:false\" \\\n"
    append config "\"ENABLE_LOOKAHEAD_PRECHARGE_ACTIVATE:false\" \\\n"
    append config "\"ENABLE_PAR_ALERT:false\" \\\n"
    append config "\"ENABLE_REINIT:false\" \\\n"
    append config "\"ENABLE_SELF_REFRESH:false\" \\\n"
    append config "\"ENABLE_TAG_IF:false\" \\\n"
    append config "\"ENABLE_USER_ZQCALIB:false\" \\\n"
    append config "\"EXPOSE_TRAINING_DEBUG_IF:false\" \\\n"

    # Interface
    append config "\"FABRIC_INTERFACE:AXI4\" \\\n"
    append config "\"GRANULARITY_MODE:0\" \\\n"
    append config "\"INTERNAL_VREF_MONITER:0\" \\\n"
    append config "\"MEMCTRLR_INST_NO:0\" \\\n"
    append config "\"MEMORY_FORMAT:COMPONENT\" \\\n"
    append config "\"MINIMUM_READ_IDLE:1\" \\\n"

    # ODT Configuration (standard single-rank setup)
    append config "\"ODT_ENABLE_RD_RNK0_ODT0:false\" \\\n"
    append config "\"ODT_ENABLE_RD_RNK0_ODT1:false\" \\\n"
    append config "\"ODT_ENABLE_RD_RNK1_ODT0:false\" \\\n"
    append config "\"ODT_ENABLE_RD_RNK1_ODT1:false\" \\\n"
    append config "\"ODT_ENABLE_WR_RNK0_ODT0:true\" \\\n"
    append config "\"ODT_ENABLE_WR_RNK0_ODT1:false\" \\\n"
    append config "\"ODT_ENABLE_WR_RNK1_ODT0:false\" \\\n"
    append config "\"ODT_ENABLE_WR_RNK1_ODT1:true\" \\\n"
    append config "\"ODT_RD_OFF_SHIFT:0\" \\\n"
    append config "\"ODT_RD_ON_SHIFT:0\" \\\n"
    append config "\"ODT_WR_OFF_SHIFT:0\" \\\n"
    append config "\"ODT_WR_ON_SHIFT:0\" \\\n"

    # Drive strength and termination
    append config "\"OUTPUT_DRIVE_STRENGTH:RZQ7\" \\\n"
    append config "\"PHYONLY:false\" \\\n"
    append config "\"PIPELINE:false\" \\\n"
    append config "\"POWERDOWN_INPUT_BUFFER:1\" \\\n"
    append config "\"QOFF:0\" \\\n"
    append config "\"QUEUE_DEPTH:3\" \\\n"
    append config "\"RDIMM_LAT:0\" \\\n"
    append config "\"READ_BURST_TYPE:SEQUENTIAL\" \\\n"
    append config "\"READ_DBI:0\" \\\n"
    append config "\"READ_PREAMBLE:0\" \\\n"
    append config "\"ROW_ADDR_WIDTH:$row_bits\" \\\n"
    append config "\"RTT_NOM:RZQ4\" \\\n"
    append config "\"RTT_PARK:0\" \\\n"
    append config "\"RTT_WR:OFF\" \\\n"

    # Ranks and type
    append config "\"SDRAM_NB_RANKS:1\" \\\n"
    append config "\"SDRAM_NUM_CLK_OUTS:1\" \\\n"
    append config "\"SDRAM_TYPE:DDR4\" \\\n"
    append config "\"SELF_REFRESH_ABORT_MODE:0\" \\\n"
    append config "\"SHIELD_ENABLED:true\" \\\n"
    append config "\"SIMULATION_MODE:FAST\" \\\n"
    append config "\"TEMPERATURE_REFRESH_MODE:0\" \\\n"
    append config "\"TEMPERATURE_REFRESH_RANGE:NORMAL\" \\\n"

    # Timing parameters
    foreach {key value} $timings {
        append config "\"$key:$value\" \\\n"
    }

    # Turnaround timings
    append config "\"TURNAROUND_RTR_DIFFRANK:2\" \\\n"
    append config "\"TURNAROUND_RTW_DIFFRANK:2\" \\\n"
    append config "\"TURNAROUND_WTR_DIFFRANK:1\" \\\n"
    append config "\"TURNAROUND_WTW_DIFFRANK:2\" \\\n"

    # Power and calibration
    append config "\"USER_POWER_DOWN:false\" \\\n"
    append config "\"VREF_CALIB_ENABLE:0\" \\\n"
    append config "\"VREF_CALIB_RANGE:0\" \\\n"
    append config "\"VREF_CALIB_VALUE:70.40\" \\\n"
    append config "\"WIDTH:$opts(-width)\" \\\n"
    append config "\"WRITE_LEVELING:ENABLE\" \\\n"
    append config "\"WRITE_PREAMBLE:0\" \\\n"
    append config "\"ZQ_CALIB_PERIOD:200\" \\\n"
    append config "\"ZQ_CALIB_TYPE:0\" \\\n"
    append config "\"ZQ_CALIB_TYPE_TEMP:false\" \\\n"
    append config "\"ZQ_CAL_INIT_TIME:1024\" \\\n"
    append config "\"ZQ_CAL_L_TIME:512\" \\\n"
    append config "\"ZQ_CAL_S_TIME:128\" }\n"

    append config "# Exporting Component Description of $opts(-component_name) to TCL done\n"

    # Output
    if {$opts(-output_file) != ""} {
        set fp [open $opts(-output_file) w]
        puts $fp $config
        close $fp
        puts "Generated DDR4 configuration: $opts(-output_file)"
        puts "  Memory: $opts(-size) DDR4 x$opts(-width) @ $opts(-speed) Mbps"
        puts "  Geometry: $row_bits row bits, $col_bits col bits, $bank_bits banks, $bg_bits bank groups"
        puts "  Latency: CL=$cas_lat, CWL=$cas_wlat"
        puts "  Clocks: DDR=$ddr_clock MHz, AXI=$opts(-axi_clk) MHz"
    } else {
        puts $config
    }

    return $config
}

# ==============================================================================
# Convenience Functions for Common Configurations
# ==============================================================================

proc generate_mpf300_4gb_ddr4 {{component_name "PF_DDR4_C0"} {output_file ""}} {
    generate_ddr4_config \
        -size "4GB" \
        -speed "1600" \
        -width "32" \
        -axi_width "64" \
        -component_name $component_name \
        -axi_clk "200.0" \
        -output_file $output_file
}

proc generate_mpf300_2gb_ddr4 {{component_name "PF_DDR4_C0"} {output_file ""}} {
    generate_ddr4_config \
        -size "2GB" \
        -speed "1600" \
        -width "32" \
        -axi_width "64" \
        -component_name $component_name \
        -axi_clk "200.0" \
        -output_file $output_file
}

proc generate_mpf300_1gb_ddr4 {{component_name "PF_DDR4_C0"} {output_file ""}} {
    generate_ddr4_config \
        -size "1GB" \
        -speed "1600" \
        -width "16" \
        -axi_width "32" \
        -component_name $component_name \
        -axi_clk "200.0" \
        -output_file $output_file
}

puts "DDR4 Configuration Generator loaded"
puts "Usage:"
puts "  generate_ddr4_config -size \"4GB\" -speed \"1600\" -width \"32\" -output_file \"my_ddr4.tcl\""
puts ""
puts "Convenience functions:"
puts "  generate_mpf300_4gb_ddr4 \"PF_DDR4_C0\" \"output.tcl\""
puts "  generate_mpf300_2gb_ddr4 \"PF_DDR4_C0\" \"output.tcl\""
puts "  generate_mpf300_1gb_ddr4 \"PF_DDR4_C0\" \"output.tcl\""
