// LED Blinker - FPGA Fabric Design for BeagleV-Fire
// Simple LED blink at 1 Hz using fabric logic
// Target: MPFS025T PolarFire SoC

module led_blinker_fabric (
    input  wire clk_50mhz,    // 50 MHz clock from FIC
    input  wire rst_n,        // Active-low reset
    output reg  led           // LED output
);

    // Counter for 1 Hz blink (50 MHz / 50,000,000 = 1 Hz)
    reg [25:0] counter;

    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 26'd0;
            led <= 1'b0;
        end else begin
            if (counter == 26'd49_999_999) begin
                counter <= 26'd0;
                led <= ~led;  // Toggle LED every 0.5 seconds
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule
