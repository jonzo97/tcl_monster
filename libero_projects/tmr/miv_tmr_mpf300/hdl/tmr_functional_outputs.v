// TMR Functional Outputs Module
// Adds observable functionality to prevent synthesis optimization
//
// This module takes the voted TIME_COUNT (64-bit MTIME) and drives multiple
// functional blocks that connect to I/O pins, forcing synthesis to
// keep all TMR logic including the MTIME timer in each core.

module tmr_functional_outputs (
    input wire clk,
    input wire rst_n,

    // Voted input from TMR voter (1-bit EXT_RESETN)
    input wire voted_resetn,

    // Voted 64-bit TIME_COUNT from TMR voter (MTIME value)
    input wire [63:0] voted_time_count,

    // Disagreement indicators from voter
    input wire disagreement,
    input wire [2:0] fault_flags,

    // LED outputs (drive to I/O pins)
    output reg [7:0] led_pattern,
    output reg status_led,
    output reg disagree_led,
    output reg [2:0] fault_leds
);

    // ==================================================================
    // LED Pattern from VOTED TIME_COUNT (KEY functional path!)
    // ==================================================================
    // Uses upper bits of voted time count directly to drive LEDs
    // This creates a real data path: Cores → Timer → Voter → LEDs
    // Synthesis CANNOT optimize this away because the value changes!

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_pattern <= 8'h00;
        end else if (voted_resetn) begin
            // Use bits [31:24] of voted time - changes every ~2.7s at 50MHz
            led_pattern <= voted_time_count[31:24];
        end else begin
            led_pattern <= 8'h00;
        end
    end

    // ==================================================================
    // Status LED (blinks based on voted time count)
    // ==================================================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            status_led <= 1'b0;
        end else if (voted_resetn) begin
            // Use bit 25 of voted time - toggles at ~0.75 Hz at 50MHz
            status_led <= voted_time_count[25];
        end else begin
            status_led <= 1'b0;
        end
    end

    // ==================================================================
    // Fault Indicators (driven directly from voter)
    // ==================================================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            disagree_led <= 1'b0;
            fault_leds <= 3'b000;
        end else begin
            disagree_led <= disagreement;
            fault_leds <= fault_flags;
        end
    end

    // ==================================================================
    // Design Intent: Functional Connectivity
    // ==================================================================

    // This module ensures that:
    // 1. voted_time_count bits directly drive LED outputs (not just registered)
    // 2. LED pattern changes based on actual MTIME value from cores
    // 3. Multiple outputs (13 LEDs total) prevent optimization
    // 4. Disagreement/fault signals are registered and output
    //
    // Synthesis CANNOT optimize away TMR logic because:
    // - voted_time_count value affects LED pattern directly
    // - TIME_COUNT_OUT is a free-running counter in each core
    // - Voting creates data path: cores → voters → LEDs → pins
    // - The MTIME module in each core must be preserved

endmodule
