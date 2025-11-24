// Triple Modular Redundancy (TMR) Voter - 64-bit Version
// For voting on MI-V TIME_COUNT_OUT (MTIME register)
//
// This voter takes 3x 64-bit inputs and produces:
//   - voted_output: 2-of-3 majority vote result (bitwise)
//   - disagreement: 1 if any inputs differ
//   - fault_flags: which input(s) disagree with majority
//
// Purpose: Create functional data path through MI-V timer logic
//          to prevent synthesis optimization of cores

module triple_voter_64bit (
    input  wire        clk,
    input  wire        rst_n,

    // 64-bit inputs from 3 redundant cores
    input  wire [63:0] input_a,
    input  wire [63:0] input_b,
    input  wire [63:0] input_c,

    // Voted output
    output reg  [63:0] voted_output,

    // TMR status
    output reg         disagreement,
    output reg  [2:0]  fault_flags    // [2]=C differs, [1]=B differs, [0]=A differs
);

    // Combinational voting logic (bitwise 2-of-3 majority)
    wire [63:0] voted_comb;
    assign voted_comb = (input_a & input_b) |
                        (input_b & input_c) |
                        (input_a & input_c);

    // Disagreement detection
    wire disagree_ab, disagree_bc, disagree_ac;
    assign disagree_ab = (input_a != input_b);
    assign disagree_bc = (input_b != input_c);
    assign disagree_ac = (input_a != input_c);

    wire any_disagreement;
    assign any_disagreement = disagree_ab | disagree_bc | disagree_ac;

    // Fault flag logic: which input differs from majority?
    wire [2:0] fault_flags_comb;
    assign fault_flags_comb[0] = (input_a != voted_comb);  // A differs
    assign fault_flags_comb[1] = (input_b != voted_comb);  // B differs
    assign fault_flags_comb[2] = (input_c != voted_comb);  // C differs

    // Registered outputs for clean timing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            voted_output <= 64'h0;
            disagreement <= 1'b0;
            fault_flags  <= 3'b000;
        end else begin
            voted_output <= voted_comb;
            disagreement <= any_disagreement;
            fault_flags  <= fault_flags_comb;
        end
    end

endmodule
