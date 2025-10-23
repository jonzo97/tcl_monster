// =============================================================================
// Simple Counter Design for PolarFire MPF300 Eval Kit
// Demonstrates basic FPGA functionality with LED outputs
// =============================================================================

module counter (
    // Clock and Reset
    input  wire       clk_50mhz,     // 50 MHz clock input from oscillator
    input  wire       reset_n,        // Active-low reset from push button

    // LED Outputs
    output wire [7:0] leds            // 8 LEDs on eval board
);

    // =============================================================================
    // Parameters
    // =============================================================================

    // Clock divider to slow down counter for visible LED changes
    // 50 MHz / 2^24 = ~3 Hz toggle rate
    parameter COUNT_WIDTH = 24;

    // =============================================================================
    // Internal Signals
    // =============================================================================

    reg [COUNT_WIDTH-1:0] counter;
    reg [7:0] led_reg;

    // =============================================================================
    // Counter Logic
    // =============================================================================

    always @(posedge clk_50mhz or negedge reset_n) begin
        if (!reset_n) begin
            counter <= {COUNT_WIDTH{1'b0}};
            led_reg <= 8'b00000001;  // Start with LED0 on
        end else begin
            counter <= counter + 1'b1;

            // Update LEDs at a slower rate (top bits of counter)
            if (counter == {COUNT_WIDTH{1'b1}}) begin
                // Rotate LED pattern
                led_reg <= {led_reg[6:0], led_reg[7]};
            end
        end
    end

    // =============================================================================
    // Output Assignments
    // =============================================================================

    assign leds = led_reg;

endmodule
