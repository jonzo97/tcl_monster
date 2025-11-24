// TMR Synchronization Controller
// Ensures all 3 cores start simultaneously
// Provides synchronized reset release

module tmr_sync_controller (
    input  wire clk,
    input  wire rst_n_in,  // External reset (async)

    // Synchronized resets to all 3 cores
    output reg  rst_n_core_a,
    output reg  rst_n_core_b,
    output reg  rst_n_core_c,

    // Status
    output reg  sync_active,    // High when cores are synchronized
    output reg  [7:0] sync_counter  // Counts cycles since sync
);

    // Reset synchronizer chain (2-stage for metastability)
    reg rst_n_sync1, rst_n_sync2;

    // Synchronized reset (all cores get same signal)
    reg rst_n_synchronized;

    // Reset synchronizer
    always @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in) begin
            rst_n_sync1 <= 1'b0;
            rst_n_sync2 <= 1'b0;
            rst_n_synchronized <= 1'b0;
        end else begin
            rst_n_sync1 <= 1'b1;
            rst_n_sync2 <= rst_n_sync1;
            rst_n_synchronized <= rst_n_sync2;
        end
    end

    // Distribute synchronized reset to all cores
    // This ensures all cores come out of reset at same clock edge
    always @(posedge clk) begin
        rst_n_core_a <= rst_n_synchronized;
        rst_n_core_b <= rst_n_synchronized;
        rst_n_core_c <= rst_n_synchronized;
    end

    // Sync active flag
    always @(posedge clk or negedge rst_n_synchronized) begin
        if (!rst_n_synchronized) begin
            sync_active <= 1'b0;
        end else begin
            sync_active <= 1'b1;
        end
    end

    // Sync counter (for debug/monitoring)
    always @(posedge clk or negedge rst_n_synchronized) begin
        if (!rst_n_synchronized) begin
            sync_counter <= 8'd0;
        end else begin
            if (sync_counter != 8'hFF) begin
                sync_counter <= sync_counter + 1'b1;
            end
        end
    end

endmodule
