// memory_read_voter.v - 32-bit bit-wise majority voter for memory read data
//
// Implements fault-tolerant memory reads using bit-wise majority voting.
// Takes 3x 32-bit read data from redundant memory banks and outputs
// the bit-wise majority vote (2-of-3 for each bit).
//
// Voting Logic:
//   - Each bit voted independently
//   - If 2 or more inputs have bit[i] = '1', output bit[i] = '1'
//   - If 2 or more inputs have bit[i] = '0', output bit[i] = '0'
//   - Single-bit faults in memory are masked by majority
//
// Usage:
//   - Place between memory banks and processor cores
//   - Cores read from voter output, not directly from memory
//   - Write path bypasses voter (cores write independently)
//
// Target: PolarFire FPGA
// TMR System: MI-V triple modular redundancy design

module memory_read_voter #(
    parameter DATA_WIDTH = 32  // Memory data width (RV32 = 32 bits)
) (
    input  [DATA_WIDTH-1:0] data_a,     // Read data from memory bank A
    input  [DATA_WIDTH-1:0] data_b,     // Read data from memory bank B
    input  [DATA_WIDTH-1:0] data_c,     // Read data from memory bank C
    output [DATA_WIDTH-1:0] data_voted  // Voted read data (majority of 3)
);

// Bit-wise majority voting
// For each bit: voted[i] = (a[i] & b[i]) | (b[i] & c[i]) | (a[i] & c[i])
genvar i;
generate
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin : vote_bit
        assign data_voted[i] = (data_a[i] & data_b[i]) |
                               (data_b[i] & data_c[i]) |
                               (data_a[i] & data_c[i]);
    end
endgenerate

endmodule
