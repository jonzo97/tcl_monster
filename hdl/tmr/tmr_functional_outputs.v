// TMR Functional Outputs Module
// Adds observable functionality to prevent synthesis optimization
//
// This module takes the voted EXT_RESETN signal and drives multiple
// functional blocks that connect to I/O pins, forcing synthesis to
// keep all TMR logic.

module tmr_functional_outputs (
    input wire clk,
    input wire rst_n,

    // Voted input from TMR voter
    input wire voted_resetn,

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
    // Free-Running Counter (proves voted signal is used)
    // ==================================================================

    reg [27:0] counter;  // 28-bit counter (wraps at ~268M cycles)
    reg [3:0] pattern_select;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 28'h0;
            pattern_select <= 4'h0;
        end else if (voted_resetn) begin  // Counter enabled by voted signal
            counter <= counter + 1'b1;
            if (counter[27:24] != pattern_select) begin
                pattern_select <= counter[27:24];
            end
        end else begin
            counter <= 28'h0;  // Counter frozen if voted_resetn low
        end
    end

    // ==================================================================
    // LED Pattern Generator (8 different patterns based on counter)
    // ==================================================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_pattern <= 8'h00;
        end else begin
            case (pattern_select)
                4'h0: led_pattern <= 8'b00000001;
                4'h1: led_pattern <= 8'b00000011;
                4'h2: led_pattern <= 8'b00000111;
                4'h3: led_pattern <= 8'b00001111;
                4'h4: led_pattern <= 8'b00011111;
                4'h5: led_pattern <= 8'b00111111;
                4'h6: led_pattern <= 8'b01111111;
                4'h7: led_pattern <= 8'b11111111;
                4'h8: led_pattern <= 8'b01111111;
                4'h9: led_pattern <= 8'b00111111;
                4'hA: led_pattern <= 8'b00011111;
                4'hB: led_pattern <= 8'b00001111;
                4'hC: led_pattern <= 8'b00000111;
                4'hD: led_pattern <= 8'b00000011;
                4'hE: led_pattern <= 8'b00000001;
                4'hF: led_pattern <= 8'b00000000;
            endcase
        end
    end

    // ==================================================================
    // Status LED (blinks at 1 Hz when voted_resetn is high)
    // ==================================================================

    reg [25:0] blink_counter;  // For 50 MHz clock, 26 bits gives ~1.3s period

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            blink_counter <= 26'h0;
            status_led <= 1'b0;
        end else if (voted_resetn) begin
            blink_counter <= blink_counter + 1'b1;
            status_led <= blink_counter[25];  // Toggle at ~0.75 Hz
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
    // 1. voted_resetn drives counter (used functionally, not just tied off)
    // 2. counter drives LED pattern (observable outputs to pins)
    // 3. Multiple outputs (13 LEDs total) prevent optimization
    // 4. Disagreement/fault signals are registered and output
    //
    // Synthesis CANNOT optimize away TMR logic because:
    // - voted_resetn controls counter enable
    // - Counter value affects LED pattern
    // - LED outputs connect to I/O pins
    // - Real data path: cores → voter → counter → LEDs → pins

endmodule
