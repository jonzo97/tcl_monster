// gpio_voter_32bit.v - 32-bit majority voter for GPIO outputs
//
// Fixed 32-bit version for SmartDesign instantiation (HDL modules
// cannot have parameters configured in SmartDesign).
//
// Matches CoreGPIO configured with APB_WIDTH:32
// Only lower IO_NUM bits are used, but full 32-bit bus is voted.

module gpio_voter_32bit (
    input  [31:0] gpio_a,     // GPIO outputs from instance A
    input  [31:0] gpio_b,     // GPIO outputs from instance B
    input  [31:0] gpio_c,     // GPIO outputs from instance C
    output [31:0] gpio_voted  // Voted GPIO outputs (majority of 3)
);

// Bit-wise majority voting (2-of-3)
genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : vote_bit
        assign gpio_voted[i] = (gpio_a[i] & gpio_b[i]) |
                               (gpio_b[i] & gpio_c[i]) |
                               (gpio_a[i] & gpio_c[i]);
    end
endgenerate

endmodule
