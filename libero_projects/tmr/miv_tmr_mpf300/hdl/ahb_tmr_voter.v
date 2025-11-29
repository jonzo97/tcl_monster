// ahb_tmr_voter.v - AHB-Lite TMR Voter Bridge
//
// Implements Triple Modular Redundancy voting for AHB-Lite memory interface:
// - 3x AHB masters (from MI-V cores) connect to this voter
// - Votes on address, write data, and control signals
// - Fans out voted transactions to 3x AHB slaves (memory banks)
// - Votes on read data from memory banks
// - Returns voted read data to all cores
//
// TMR Strategy:
// - Write path: Vote address + data → broadcast to all 3 banks
// - Read path: Read from all 3 banks → vote data → return to all cores
// - Synchronous operation: All cores must be lock-stepped
//
// Target: PolarFire FPGA TMR MI-V System

module ahb_tmr_voter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire                     HCLK,
    input  wire                     HRESETn,

    // =========================================================================
    // AHB Master Interfaces (from 3x MI-V cores)
    // =========================================================================

    // Core A AHB Master
    input  wire [ADDR_WIDTH-1:0]    HADDR_A,
    input  wire [DATA_WIDTH-1:0]    HWDATA_A,
    input  wire                     HWRITE_A,
    input  wire [1:0]               HTRANS_A,
    input  wire [2:0]               HSIZE_A,
    input  wire [2:0]               HBURST_A,
    input  wire                     HSEL_A,
    output wire [DATA_WIDTH-1:0]    HRDATA_A,
    output wire                     HREADY_A,
    output wire                     HRESP_A,

    // Core B AHB Master
    input  wire [ADDR_WIDTH-1:0]    HADDR_B,
    input  wire [DATA_WIDTH-1:0]    HWDATA_B,
    input  wire                     HWRITE_B,
    input  wire [1:0]               HTRANS_B,
    input  wire [2:0]               HSIZE_B,
    input  wire [2:0]               HBURST_B,
    input  wire                     HSEL_B,
    output wire [DATA_WIDTH-1:0]    HRDATA_B,
    output wire                     HREADY_B,
    output wire                     HRESP_B,

    // Core C AHB Master
    input  wire [ADDR_WIDTH-1:0]    HADDR_C,
    input  wire [DATA_WIDTH-1:0]    HWDATA_C,
    input  wire                     HWRITE_C,
    input  wire [1:0]               HTRANS_C,
    input  wire [2:0]               HSIZE_C,
    input  wire [2:0]               HBURST_C,
    input  wire                     HSEL_C,
    output wire [DATA_WIDTH-1:0]    HRDATA_C,
    output wire                     HREADY_C,
    output wire                     HRESP_C,

    // =========================================================================
    // AHB Slave Interfaces (to 3x memory banks)
    // =========================================================================

    // Memory Bank A AHB Slave
    output wire [ADDR_WIDTH-1:0]    HADDR_MEM_A,
    output wire [DATA_WIDTH-1:0]    HWDATA_MEM_A,
    output wire                     HWRITE_MEM_A,
    output wire [1:0]               HTRANS_MEM_A,
    output wire [2:0]               HSIZE_MEM_A,
    output wire [2:0]               HBURST_MEM_A,
    output wire                     HSEL_MEM_A,
    input  wire [DATA_WIDTH-1:0]    HRDATA_MEM_A,
    input  wire                     HREADY_MEM_A,
    input  wire                     HRESP_MEM_A,

    // Memory Bank B AHB Slave
    output wire [ADDR_WIDTH-1:0]    HADDR_MEM_B,
    output wire [DATA_WIDTH-1:0]    HWDATA_MEM_B,
    output wire                     HWRITE_MEM_B,
    output wire [1:0]               HTRANS_MEM_B,
    output wire [2:0]               HSIZE_MEM_B,
    output wire [2:0]               HBURST_MEM_B,
    output wire                     HSEL_MEM_B,
    input  wire [DATA_WIDTH-1:0]    HRDATA_MEM_B,
    input  wire                     HREADY_MEM_B,
    input  wire                     HRESP_MEM_B,

    // Memory Bank C AHB Slave
    output wire [ADDR_WIDTH-1:0]    HADDR_MEM_C,
    output wire [DATA_WIDTH-1:0]    HWDATA_MEM_C,
    output wire                     HWRITE_MEM_C,
    output wire [1:0]               HTRANS_MEM_C,
    output wire [2:0]               HSIZE_MEM_C,
    output wire [2:0]               HBURST_MEM_C,
    output wire                     HSEL_MEM_C,
    input  wire [DATA_WIDTH-1:0]    HRDATA_MEM_C,
    input  wire                     HREADY_MEM_C,
    input  wire                     HRESP_MEM_C,

    // =========================================================================
    // Fault Detection Outputs
    // =========================================================================
    output wire                     addr_disagreement,
    output wire                     wdata_disagreement,
    output wire                     rdata_disagreement,
    output wire [2:0]               fault_flags  // One bit per core
);

    // =========================================================================
    // Address Voting (2-of-3 majority, bit-wise)
    // =========================================================================
    wire [ADDR_WIDTH-1:0] voted_addr;
    genvar i;
    generate
        for (i = 0; i < ADDR_WIDTH; i = i + 1) begin : vote_addr
            assign voted_addr[i] = (HADDR_A[i] & HADDR_B[i]) |
                                   (HADDR_B[i] & HADDR_C[i]) |
                                   (HADDR_A[i] & HADDR_C[i]);
        end
    endgenerate

    // =========================================================================
    // Write Data Voting (2-of-3 majority, bit-wise)
    // =========================================================================
    wire [DATA_WIDTH-1:0] voted_wdata;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : vote_wdata
            assign voted_wdata[i] = (HWDATA_A[i] & HWDATA_B[i]) |
                                    (HWDATA_B[i] & HWDATA_C[i]) |
                                    (HWDATA_A[i] & HWDATA_C[i]);
        end
    endgenerate

    // =========================================================================
    // Control Signal Voting (2-of-3 majority)
    // =========================================================================
    wire voted_hwrite = (HWRITE_A & HWRITE_B) | (HWRITE_B & HWRITE_C) | (HWRITE_A & HWRITE_C);
    wire voted_hsel   = (HSEL_A & HSEL_B) | (HSEL_B & HSEL_C) | (HSEL_A & HSEL_C);

    // HTRANS voting (2 bits)
    wire [1:0] voted_htrans;
    generate
        for (i = 0; i < 2; i = i + 1) begin : vote_htrans
            assign voted_htrans[i] = (HTRANS_A[i] & HTRANS_B[i]) |
                                     (HTRANS_B[i] & HTRANS_C[i]) |
                                     (HTRANS_A[i] & HTRANS_C[i]);
        end
    endgenerate

    // HSIZE voting (3 bits)
    wire [2:0] voted_hsize;
    generate
        for (i = 0; i < 3; i = i + 1) begin : vote_hsize
            assign voted_hsize[i] = (HSIZE_A[i] & HSIZE_B[i]) |
                                    (HSIZE_B[i] & HSIZE_C[i]) |
                                    (HSIZE_A[i] & HSIZE_C[i]);
        end
    endgenerate

    // HBURST voting (3 bits)
    wire [2:0] voted_hburst;
    generate
        for (i = 0; i < 3; i = i + 1) begin : vote_hburst
            assign voted_hburst[i] = (HBURST_A[i] & HBURST_B[i]) |
                                     (HBURST_B[i] & HBURST_C[i]) |
                                     (HBURST_A[i] & HBURST_C[i]);
        end
    endgenerate

    // =========================================================================
    // Read Data Voting (from memory banks)
    // =========================================================================
    wire [DATA_WIDTH-1:0] voted_rdata;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : vote_rdata
            assign voted_rdata[i] = (HRDATA_MEM_A[i] & HRDATA_MEM_B[i]) |
                                    (HRDATA_MEM_B[i] & HRDATA_MEM_C[i]) |
                                    (HRDATA_MEM_A[i] & HRDATA_MEM_C[i]);
        end
    endgenerate

    // HREADY voting (all memories must be ready)
    wire voted_hready = HREADY_MEM_A & HREADY_MEM_B & HREADY_MEM_C;

    // HRESP voting (any error propagates)
    wire voted_hresp = HRESP_MEM_A | HRESP_MEM_B | HRESP_MEM_C;

    // =========================================================================
    // Fan-out: Voted signals to all memory banks
    // =========================================================================

    // All banks receive the same voted address and control
    assign HADDR_MEM_A  = voted_addr;
    assign HADDR_MEM_B  = voted_addr;
    assign HADDR_MEM_C  = voted_addr;

    assign HWDATA_MEM_A = voted_wdata;
    assign HWDATA_MEM_B = voted_wdata;
    assign HWDATA_MEM_C = voted_wdata;

    assign HWRITE_MEM_A = voted_hwrite;
    assign HWRITE_MEM_B = voted_hwrite;
    assign HWRITE_MEM_C = voted_hwrite;

    assign HTRANS_MEM_A = voted_htrans;
    assign HTRANS_MEM_B = voted_htrans;
    assign HTRANS_MEM_C = voted_htrans;

    assign HSIZE_MEM_A  = voted_hsize;
    assign HSIZE_MEM_B  = voted_hsize;
    assign HSIZE_MEM_C  = voted_hsize;

    assign HBURST_MEM_A = voted_hburst;
    assign HBURST_MEM_B = voted_hburst;
    assign HBURST_MEM_C = voted_hburst;

    assign HSEL_MEM_A   = voted_hsel;
    assign HSEL_MEM_B   = voted_hsel;
    assign HSEL_MEM_C   = voted_hsel;

    // =========================================================================
    // Fan-out: Voted read data to all cores
    // =========================================================================

    // All cores receive the same voted read data
    assign HRDATA_A = voted_rdata;
    assign HRDATA_B = voted_rdata;
    assign HRDATA_C = voted_rdata;

    assign HREADY_A = voted_hready;
    assign HREADY_B = voted_hready;
    assign HREADY_C = voted_hready;

    assign HRESP_A  = voted_hresp;
    assign HRESP_B  = voted_hresp;
    assign HRESP_C  = voted_hresp;

    // =========================================================================
    // Disagreement Detection
    // =========================================================================

    // Address disagreement: any core differs from voted result
    assign addr_disagreement = (HADDR_A != voted_addr) |
                               (HADDR_B != voted_addr) |
                               (HADDR_C != voted_addr);

    // Write data disagreement
    assign wdata_disagreement = (HWDATA_A != voted_wdata) |
                                (HWDATA_B != voted_wdata) |
                                (HWDATA_C != voted_wdata);

    // Read data disagreement (memory banks differ)
    assign rdata_disagreement = (HRDATA_MEM_A != voted_rdata) |
                                (HRDATA_MEM_B != voted_rdata) |
                                (HRDATA_MEM_C != voted_rdata);

    // Per-core fault flags (which core disagrees)
    assign fault_flags[0] = (HADDR_A != voted_addr) | (HWDATA_A != voted_wdata);
    assign fault_flags[1] = (HADDR_B != voted_addr) | (HWDATA_B != voted_wdata);
    assign fault_flags[2] = (HADDR_C != voted_addr) | (HWDATA_C != voted_wdata);

endmodule
