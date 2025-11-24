// MI-V TMR System - Top-Level HDL Wrapper
// Direct HDL instantiation (bypasses SmartDesign limitations)
//
// This top-level module instantiates:
// - 3x MI-V RV32IMC cores (configured identically)
// - 1x Triple voter for EXT_RESETN outputs
// - LED status indicators for TMR demonstration

`timescale 1ns / 100ps

module tmr_top (
    // Clock and Reset Inputs
    input  wire CLK_IN,
    input  wire RST_N_IN,

    // LED Outputs (TMR Status Indicators)
    output wire HEARTBEAT_LED,    // Clock indicator (blinks at clock rate)
    output wire TMR_STATUS_LED,   // Voted output from 3x cores
    output wire FAULT_LED_A,      // Core A fault indicator
    output wire FAULT_LED_B,      // Core B fault indicator
    output wire FAULT_LED_C,      // Core C fault indicator
    output wire DISAGREE_LED      // Disagreement indicator
);

    //========================================================================
    // Internal Signals
    //========================================================================

    // EXT_RESETN outputs from each core (to be voted on)
    wire ext_resetn_a;
    wire ext_resetn_b;
    wire ext_resetn_c;

    // Voter outputs
    wire voted_resetn;
    wire [2:0] fault_flags;
    wire disagreement;

    //========================================================================
    // Heartbeat LED (direct clock connection for visual feedback)
    //========================================================================

    assign HEARTBEAT_LED = CLK_IN;

    //========================================================================
    // MI-V Core A Instantiation
    //========================================================================

    MIV_RV32_CORE_A core_a (
        // Clock and Reset
        .CLK(CLK_IN),
        .RESETN(RST_N_IN),

        // AHB Lite Initiator (unused - tied off)
        .AHB_HADDR(),
        .AHB_HBURST(),
        .AHB_HMASTLOCK(),
        .AHB_HPROT(),
        .AHB_HSIZE(),
        .AHB_HTRANS(),
        .AHB_HWDATA(),
        .AHB_HWRITE(),
        .AHB_HRDATA(32'h0),
        .AHB_HREADY(1'b1),
        .AHB_HRESP(1'b0),

        // APB Initiator (unused - tied off)
        .APB_PADDR(),
        .APB_PENABLE(),
        .APB_PSEL(),
        .APB_PWDATA(),
        .APB_PWRITE(),
        .APB_PRDATA(32'h0),
        .APB_PREADY(1'b1),
        .APB_PSLVERR(1'b0),

        // External Interrupt (unused)
        .EXT_IRQ(1'b0),

        // JTAG Debug (unused - tied off)
        .JTAG_TCK(1'b0),
        .JTAG_TDI(1'b0),
        .JTAG_TMS(1'b0),
        .JTAG_TRSTN(1'b1),
        .JTAG_TDO(),
        .JTAG_TDO_DR(),

        // External Reset Output (VOTED SIGNAL)
        .EXT_RESETN(ext_resetn_a),

        // Time Counter (unused)
        .TIME_COUNT_OUT()
    );

    //========================================================================
    // MI-V Core B Instantiation
    //========================================================================

    MIV_RV32_CORE_B core_b (
        // Clock and Reset
        .CLK(CLK_IN),
        .RESETN(RST_N_IN),

        // AHB Lite Initiator (unused - tied off)
        .AHB_HADDR(),
        .AHB_HBURST(),
        .AHB_HMASTLOCK(),
        .AHB_HPROT(),
        .AHB_HSIZE(),
        .AHB_HTRANS(),
        .AHB_HWDATA(),
        .AHB_HWRITE(),
        .AHB_HRDATA(32'h0),
        .AHB_HREADY(1'b1),
        .AHB_HRESP(1'b0),

        // APB Initiator (unused - tied off)
        .APB_PADDR(),
        .APB_PENABLE(),
        .APB_PSEL(),
        .APB_PWDATA(),
        .APB_PWRITE(),
        .APB_PRDATA(32'h0),
        .APB_PREADY(1'b1),
        .APB_PSLVERR(1'b0),

        // External Interrupt (unused)
        .EXT_IRQ(1'b0),

        // JTAG Debug (unused - tied off)
        .JTAG_TCK(1'b0),
        .JTAG_TDI(1'b0),
        .JTAG_TMS(1'b0),
        .JTAG_TRSTN(1'b1),
        .JTAG_TDO(),
        .JTAG_TDO_DR(),

        // External Reset Output (VOTED SIGNAL)
        .EXT_RESETN(ext_resetn_b),

        // Time Counter (unused)
        .TIME_COUNT_OUT()
    );

    //========================================================================
    // MI-V Core C Instantiation
    //========================================================================

    MIV_RV32_CORE_C core_c (
        // Clock and Reset
        .CLK(CLK_IN),
        .RESETN(RST_N_IN),

        // AHB Lite Initiator (unused - tied off)
        .AHB_HADDR(),
        .AHB_HBURST(),
        .AHB_HMASTLOCK(),
        .AHB_HPROT(),
        .AHB_HSIZE(),
        .AHB_HTRANS(),
        .AHB_HWDATA(),
        .AHB_HWRITE(),
        .AHB_HRDATA(32'h0),
        .AHB_HREADY(1'b1),
        .AHB_HRESP(1'b0),

        // APB Initiator (unused - tied off)
        .APB_PADDR(),
        .APB_PENABLE(),
        .APB_PSEL(),
        .APB_PWDATA(),
        .APB_PWRITE(),
        .APB_PRDATA(32'h0),
        .APB_PREADY(1'b1),
        .APB_PSLVERR(1'b0),

        // External Interrupt (unused)
        .EXT_IRQ(1'b0),

        // JTAG Debug (unused - tied off)
        .JTAG_TCK(1'b0),
        .JTAG_TDI(1'b0),
        .JTAG_TMS(1'b0),
        .JTAG_TRSTN(1'b1),
        .JTAG_TDO(),
        .JTAG_TDO_DR(),

        // External Reset Output (VOTED SIGNAL)
        .EXT_RESETN(ext_resetn_c),

        // Time Counter (unused)
        .TIME_COUNT_OUT()
    );

    //========================================================================
    // Triple Voter Instantiation
    //========================================================================

    triple_voter #(
        .WIDTH(1)  // 1-bit voting for EXT_RESETN
    ) voter_inst (
        .clk(CLK_IN),
        .rst_n(RST_N_IN),

        // Three inputs from MI-V cores
        .input_a(ext_resetn_a),
        .input_b(ext_resetn_b),
        .input_c(ext_resetn_c),

        // Voted output and fault detection
        .voted_output(voted_resetn),
        .disagreement(disagreement),
        .fault_flags(fault_flags)
    );

    //========================================================================
    // LED Output Assignments
    //========================================================================

    // TMR Status LED (shows voted output from 3x cores)
    assign TMR_STATUS_LED = voted_resetn;

    // Individual core fault indicators
    assign FAULT_LED_A = fault_flags[2];  // Core A disagrees with voted result
    assign FAULT_LED_B = fault_flags[1];  // Core B disagrees with voted result
    assign FAULT_LED_C = fault_flags[0];  // Core C disagrees with voted result

    // Disagreement indicator (high if any cores disagree)
    assign DISAGREE_LED = disagreement;

endmodule
