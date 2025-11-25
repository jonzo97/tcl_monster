// gpio_voter.v - 8-bit bit-wise majority voter for GPIO outputs
//
// Implements fault-tolerant GPIO outputs using bit-wise majority voting.
// Takes 3x 8-bit GPIO outputs from redundant GPIO instances and outputs
// the bit-wise majority vote (2-of-3 for each bit).
//
// Voting Logic:
//   - Each bit voted independently
//   - If 2 or more inputs have bit[i] = '1', output bit[i] = '1'
//   - If 2 or more inputs have bit[i] = '0', output bit[i] = '0'
//   - Single-bit faults are masked by majority
//
// Target: PolarFire FPGA
// TMR System: MI-V triple modular redundancy design

module gpio_voter #(
    parameter WIDTH = 8  // GPIO width (default 8 bits)
) (
    input  [WIDTH-1:0] gpio_a,     // GPIO outputs from instance A
    input  [WIDTH-1:0] gpio_b,     // GPIO outputs from instance B
    input  [WIDTH-1:0] gpio_c,     // GPIO outputs from instance C
    output [WIDTH-1:0] gpio_voted  // Voted GPIO outputs (majority of 3)
);

// Bit-wise majority voting
// For each bit: voted[i] = (a[i] & b[i]) | (b[i] & c[i]) | (a[i] & c[i])
genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : vote_bit
        assign gpio_voted[i] = (gpio_a[i] & gpio_b[i]) |
                               (gpio_b[i] & gpio_c[i]) |
                               (gpio_a[i] & gpio_c[i]);
    end
endgenerate

endmodule
