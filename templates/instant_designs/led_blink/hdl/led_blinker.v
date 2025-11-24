// Simple LED Blinker for Instant FPGA
// Rotates LEDs in a binary counter pattern
// Clock: 50 MHz
// LED update rate: ~1 Hz

module led_blinker (
    input  wire       clk,        // 50 MHz clock
    input  wire       rst_n,      // Active-low reset
    output reg  [7:0] leds        // 8 LEDs
);

// Parameters
parameter CLK_FREQ = 50_000_000;    // 50 MHz
parameter LED_FREQ = 1;             // 1 Hz LED update

// Counter for LED update
localparam COUNT_MAX = CLK_FREQ / LED_FREQ - 1;
reg [31:0] counter;

// LED pattern counter
reg [7:0] led_pattern;

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 32'd0;
        led_pattern <= 8'b00000001;
    end else begin
        if (counter == COUNT_MAX) begin
            counter <= 32'd0;
            // Rotate LED pattern
            led_pattern <= {led_pattern[6:0], led_pattern[7]};
        end else begin
            counter <= counter + 1'b1;
        end
    end
end

// Output assignment
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        leds <= 8'b00000001;
    end else begin
        if (counter == COUNT_MAX) begin
            leds <= led_pattern;
        end
    end
end

endmodule
