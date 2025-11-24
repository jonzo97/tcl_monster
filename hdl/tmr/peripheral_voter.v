// Peripheral Voter for TMR System
// Votes on peripheral outputs (UART TX, GPIO, etc.)
// Distributes peripheral inputs to all cores

module peripheral_voter #(
    parameter DATA_WIDTH = 8  // UART data width, GPIO width, etc.
) (
    input  wire clk,
    input  wire rst_n,

    // Core A peripheral outputs
    input  wire [DATA_WIDTH-1:0] data_out_a,
    input  wire                   valid_a,

    // Core B peripheral outputs
    input  wire [DATA_WIDTH-1:0] data_out_b,
    input  wire                   valid_b,

    // Core C peripheral outputs
    input  wire [DATA_WIDTH-1:0] data_out_c,
    input  wire                   valid_c,

    // Voted peripheral output
    output reg  [DATA_WIDTH-1:0] voted_data_out,
    output reg                    voted_valid,

    // Peripheral input (broadcast to all cores)
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire                   valid_in,
    output reg  [DATA_WIDTH-1:0] data_in_a,
    output reg  [DATA_WIDTH-1:0] data_in_b,
    output reg  [DATA_WIDTH-1:0] data_in_c,
    output reg                    valid_in_a,
    output reg                    valid_in_b,
    output reg                    valid_in_c,

    // Fault detection
    output reg  data_disagreement,
    output reg  valid_disagreement,
    output reg  [2:0] data_fault_flags,
    output reg  [2:0] valid_fault_flags
);

    // Internal voted signals
    wire [DATA_WIDTH-1:0] voted_data_comb;
    wire voted_valid_comb;

    // Disagreement flags
    wire data_disagree, valid_disagree;
    wire [2:0] data_faults, valid_faults;

    // Data voter
    triple_voter #(
        .WIDTH(DATA_WIDTH)
    ) data_voter (
        .clk(clk),
        .rst_n(rst_n),
        .input_a(data_out_a),
        .input_b(data_out_b),
        .input_c(data_out_c),
        .voted_output(voted_data_comb),
        .disagreement(data_disagree),
        .fault_flags(data_faults)
    );

    // Valid signal voting (2-of-3)
    assign voted_valid_comb = (valid_a & valid_b) | (valid_b & valid_c) | (valid_a & valid_c);

    // Valid disagreement detection
    assign valid_disagree = (valid_a != valid_b) | (valid_b != valid_c) | (valid_a != valid_c);

    // Valid fault flags
    assign valid_faults[2] = (valid_a != voted_valid_comb);
    assign valid_faults[1] = (valid_b != voted_valid_comb);
    assign valid_faults[0] = (valid_c != voted_valid_comb);

    // Register voted outputs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            voted_data_out     <= {DATA_WIDTH{1'b0}};
            voted_valid        <= 1'b0;
            data_disagreement  <= 1'b0;
            valid_disagreement <= 1'b0;
            data_fault_flags   <= 3'b000;
            valid_fault_flags  <= 3'b000;
        end else begin
            voted_data_out     <= voted_data_comb;
            voted_valid        <= voted_valid_comb;
            data_disagreement  <= data_disagree;
            valid_disagreement <= valid_disagree;
            data_fault_flags   <= data_faults;
            valid_fault_flags  <= valid_faults;
        end
    end

    // Broadcast inputs to all cores (same data to everyone)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_a  <= {DATA_WIDTH{1'b0}};
            data_in_b  <= {DATA_WIDTH{1'b0}};
            data_in_c  <= {DATA_WIDTH{1'b0}};
            valid_in_a <= 1'b0;
            valid_in_b <= 1'b0;
            valid_in_c <= 1'b0;
        end else begin
            data_in_a  <= data_in;
            data_in_b  <= data_in;
            data_in_c  <= data_in;
            valid_in_a <= valid_in;
            valid_in_b <= valid_in;
            valid_in_c <= valid_in;
        end
    end

endmodule
