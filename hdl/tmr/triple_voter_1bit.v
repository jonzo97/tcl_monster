// 1-bit Triple Voter for TMR Systems
// Implements 2-of-3 majority voting with disagreement detection
// Fixed 1-bit width - for scalar signals like EXT_RESETN
//
// NOTE: This is a non-parameterized version because Libero's
// sd_configure_core_instance only works with IP cores, not HDL modules.
// For different widths, use the parameterized triple_voter.v and
// create a wrapper component, or create additional fixed-width versions.

module triple_voter_1bit (
    // Clock and reset (for registered output)
    input  wire clk,
    input  wire rst_n,

    // Three inputs to vote on
    input  wire input_a,
    input  wire input_b,
    input  wire input_c,

    // Voted output (majority result)
    output reg  voted_output,

    // Disagreement detection
    output reg  disagreement,      // High if any inputs disagree
    output reg  [2:0] fault_flags  // [2]=A bad, [1]=B bad, [0]=C bad
);

    // Internal signals for combinational voting
    wire voted_comb;
    wire disagreement_comb;
    wire [2:0] fault_flags_comb;

    // Majority voting logic (2-of-3)
    // Result is 1 if at least 2 inputs are 1
    assign voted_comb = (input_a & input_b) |
                        (input_b & input_c) |
                        (input_a & input_c);

    // Disagreement detection
    // High if any two inputs differ
    assign disagreement_comb = (input_a != input_b) |
                               (input_b != input_c) |
                               (input_a != input_c);

    // Fault identification
    // A fault flag is high if that input disagrees with voted result
    assign fault_flags_comb[2] = (input_a != voted_comb);  // Core A fault
    assign fault_flags_comb[1] = (input_b != voted_comb);  // Core B fault
    assign fault_flags_comb[0] = (input_c != voted_comb);  // Core C fault

    // Register outputs (1 cycle latency, improves timing)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            voted_output <= 1'b0;
            disagreement <= 1'b0;
            fault_flags  <= 3'b000;
        end else begin
            voted_output <= voted_comb;
            disagreement <= disagreement_comb;
            fault_flags  <= fault_flags_comb;
        end
    end

endmodule
