// LED Pattern FSM - 4-LED sequential patterns
// Demonstrates finite state machine in fabric
// Target: BeagleV-Fire MPFS025T

module led_pattern_fsm (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       pattern_select,  // 0=chase, 1=blink_all
    output reg  [3:0] leds
);

    // State machine
    reg [2:0] state;
    reg [23:0] delay_counter;  // ~0.33 sec at 50 MHz
    wire delay_done = (delay_counter == 24'd16_666_666);

    localparam IDLE = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            leds <= 4'b0000;
            delay_counter <= 24'd0;
        end else begin
            delay_counter <= delay_done ? 24'd0 : delay_counter + 1'b1;

            if (delay_done) begin
                if (pattern_select == 1'b0) begin
                    // Chase pattern
                    case (state)
                        IDLE: begin state <= S1; leds <= 4'b0001; end
                        S1:   begin state <= S2; leds <= 4'b0010; end
                        S2:   begin state <= S3; leds <= 4'b0100; end
                        S3:   begin state <= S4; leds <= 4'b1000; end
                        S4:   begin state <= S1; leds <= 4'b0001; end
                        default: begin state <= IDLE; leds <= 4'b0000; end
                    endcase
                end else begin
                    // Blink all pattern
                    leds <= ~leds;
                end
            end
        end
    end

endmodule
