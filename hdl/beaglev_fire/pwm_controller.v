// PWM Controller - Variable duty cycle LED dimming
// 8-bit PWM with configurable period
// Target: BeagleV-Fire MPFS025T

module pwm_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  duty_cycle,  // 0-255 duty cycle
    output reg         pwm_out
);

    reg [7:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 8'h00;
            pwm_out <= 1'b0;
        end else begin
            counter <= counter + 1'b1;
            pwm_out <= (counter < duty_cycle);
        end
    end

endmodule
