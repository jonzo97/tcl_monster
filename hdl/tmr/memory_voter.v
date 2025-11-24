// Memory Voter for TMR System
// Votes on memory addresses and data from 3 cores
// Handles both read and write operations

module memory_voter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire clk,
    input  wire rst_n,

    // Core A memory interface
    input  wire [ADDR_WIDTH-1:0] addr_a,
    input  wire [DATA_WIDTH-1:0] wdata_a,
    input  wire                   wen_a,
    input  wire                   ren_a,
    output reg  [DATA_WIDTH-1:0] rdata_a,

    // Core B memory interface
    input  wire [ADDR_WIDTH-1:0] addr_b,
    input  wire [DATA_WIDTH-1:0] wdata_b,
    input  wire                   wen_b,
    input  wire                   ren_b,
    output reg  [DATA_WIDTH-1:0] rdata_b,

    // Core C memory interface
    input  wire [ADDR_WIDTH-1:0] addr_c,
    input  wire [DATA_WIDTH-1:0] wdata_c,
    input  wire                   wen_c,
    input  wire                   ren_c,
    output reg  [DATA_WIDTH-1:0] rdata_c,

    // Voted memory interface (to triplicated memory banks)
    output reg  [ADDR_WIDTH-1:0] voted_addr,
    output reg  [DATA_WIDTH-1:0] voted_wdata,
    output reg                    voted_wen,
    output reg                    voted_ren,
    input  wire [DATA_WIDTH-1:0] rdata_bank_a,
    input  wire [DATA_WIDTH-1:0] rdata_bank_b,
    input  wire [DATA_WIDTH-1:0] rdata_bank_c,

    // Fault detection
    output reg  addr_disagreement,
    output reg  wdata_disagreement,
    output reg  rdata_disagreement,
    output reg  [2:0] addr_fault_flags,
    output reg  [2:0] wdata_fault_flags,
    output reg  [2:0] rdata_fault_flags
);

    // Internal voted signals
    wire [ADDR_WIDTH-1:0] voted_addr_comb;
    wire [DATA_WIDTH-1:0] voted_wdata_comb;
    wire [DATA_WIDTH-1:0] voted_rdata_comb;
    wire voted_wen_comb;
    wire voted_ren_comb;

    // Disagreement flags
    wire addr_disagree, wdata_disagree, rdata_disagree;
    wire [2:0] addr_faults, wdata_faults, rdata_faults;

    // Address voter
    triple_voter #(
        .WIDTH(ADDR_WIDTH)
    ) addr_voter (
        .clk(clk),
        .rst_n(rst_n),
        .input_a(addr_a),
        .input_b(addr_b),
        .input_c(addr_c),
        .voted_output(voted_addr_comb),
        .disagreement(addr_disagree),
        .fault_flags(addr_faults)
    );

    // Write data voter
    triple_voter #(
        .WIDTH(DATA_WIDTH)
    ) wdata_voter (
        .clk(clk),
        .rst_n(rst_n),
        .input_a(wdata_a),
        .input_b(wdata_b),
        .input_c(wdata_c),
        .voted_output(voted_wdata_comb),
        .disagreement(wdata_disagree),
        .fault_flags(wdata_faults)
    );

    // Read data voter (from memory banks)
    triple_voter #(
        .WIDTH(DATA_WIDTH)
    ) rdata_voter (
        .clk(clk),
        .rst_n(rst_n),
        .input_a(rdata_bank_a),
        .input_b(rdata_bank_b),
        .input_c(rdata_bank_c),
        .voted_output(voted_rdata_comb),
        .disagreement(rdata_disagree),
        .fault_flags(rdata_faults)
    );

    // Write enable voting (2-of-3)
    assign voted_wen_comb = (wen_a & wen_b) | (wen_b & wen_c) | (wen_a & wen_c);

    // Read enable voting (2-of-3)
    assign voted_ren_comb = (ren_a & ren_b) | (ren_b & ren_c) | (ren_a & ren_c);

    // Register voted outputs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            voted_addr  <= {ADDR_WIDTH{1'b0}};
            voted_wdata <= {DATA_WIDTH{1'b0}};
            voted_wen   <= 1'b0;
            voted_ren   <= 1'b0;

            addr_disagreement  <= 1'b0;
            wdata_disagreement <= 1'b0;
            rdata_disagreement <= 1'b0;

            addr_fault_flags  <= 3'b000;
            wdata_fault_flags <= 3'b000;
            rdata_fault_flags <= 3'b000;
        end else begin
            voted_addr  <= voted_addr_comb;
            voted_wdata <= voted_wdata_comb;
            voted_wen   <= voted_wen_comb;
            voted_ren   <= voted_ren_comb;

            addr_disagreement  <= addr_disagree;
            wdata_disagreement <= wdata_disagree;
            rdata_disagreement <= rdata_disagree;

            addr_fault_flags  <= addr_faults;
            wdata_fault_flags <= wdata_faults;
            rdata_fault_flags <= rdata_faults;
        end
    end

    // Distribute voted read data to all cores
    // (All cores get same corrected data)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata_a <= {DATA_WIDTH{1'b0}};
            rdata_b <= {DATA_WIDTH{1'b0}};
            rdata_c <= {DATA_WIDTH{1'b0}};
        end else begin
            rdata_a <= voted_rdata_comb;
            rdata_b <= voted_rdata_comb;
            rdata_c <= voted_rdata_comb;
        end
    end

endmodule
