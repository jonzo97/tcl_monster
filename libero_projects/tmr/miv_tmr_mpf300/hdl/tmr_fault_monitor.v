// TMR Fault Monitor
// Collects disagreement flags from all voters
// Maintains fault counters per core
// Generates system health status

module tmr_fault_monitor (
    input  wire clk,
    input  wire rst_n,

    // Disagreement inputs from voters
    input  wire mem_addr_disagreement,
    input  wire mem_wdata_disagreement,
    input  wire mem_rdata_disagreement,
    input  wire uart_disagreement,
    input  wire gpio_disagreement,

    // Fault flags from voters [2]=A, [1]=B, [0]=C
    input  wire [2:0] mem_addr_faults,
    input  wire [2:0] mem_wdata_faults,
    input  wire [2:0] mem_rdata_faults,
    input  wire [2:0] uart_faults,
    input  wire [2:0] gpio_faults,

    // Fault counters (per core)
    output reg  [15:0] fault_count_a,
    output reg  [15:0] fault_count_b,
    output reg  [15:0] fault_count_c,

    // Persistent fault flags
    output reg  core_a_faulty,  // Core A consistently faulty
    output reg  core_b_faulty,  // Core B consistently faulty
    output reg  core_c_faulty,  // Core C consistently faulty

    // System status
    output reg  any_disagreement,  // Any voter reports disagreement
    output reg  system_healthy,    // All cores agree
    output reg  tmr_active         // TMR system is active
);

    // Fault threshold (number of faults before marking core as persistently faulty)
    localparam FAULT_THRESHOLD = 100;

    // Collect all disagreements
    wire any_disagree;
    assign any_disagree = mem_addr_disagreement |
                          mem_wdata_disagreement |
                          mem_rdata_disagreement |
                          uart_disagreement |
                          gpio_disagreement;

    // Count faults per core this cycle
    wire [3:0] faults_a_this_cycle;
    wire [3:0] faults_b_this_cycle;
    wire [3:0] faults_c_this_cycle;

    assign faults_a_this_cycle = {1'b0, mem_addr_faults[2]} +
                                 {1'b0, mem_wdata_faults[2]} +
                                 {1'b0, mem_rdata_faults[2]} +
                                 {1'b0, uart_faults[2]} +
                                 {1'b0, gpio_faults[2]};

    assign faults_b_this_cycle = {1'b0, mem_addr_faults[1]} +
                                 {1'b0, mem_wdata_faults[1]} +
                                 {1'b0, mem_rdata_faults[1]} +
                                 {1'b0, uart_faults[1]} +
                                 {1'b0, gpio_faults[1]};

    assign faults_c_this_cycle = {1'b0, mem_addr_faults[0]} +
                                 {1'b0, mem_wdata_faults[0]} +
                                 {1'b0, mem_rdata_faults[0]} +
                                 {1'b0, uart_faults[0]} +
                                 {1'b0, gpio_faults[0]};

    // Fault counters
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fault_count_a <= 16'd0;
            fault_count_b <= 16'd0;
            fault_count_c <= 16'd0;
        end else begin
            // Increment fault counters (saturate at max)
            if (faults_a_this_cycle > 0 && fault_count_a != 16'hFFFF) begin
                fault_count_a <= fault_count_a + {12'd0, faults_a_this_cycle};
            end

            if (faults_b_this_cycle > 0 && fault_count_b != 16'hFFFF) begin
                fault_count_b <= fault_count_b + {12'd0, faults_b_this_cycle};
            end

            if (faults_c_this_cycle > 0 && fault_count_c != 16'hFFFF) begin
                fault_count_c <= fault_count_c + {12'd0, faults_c_this_cycle};
            end
        end
    end

    // Persistent fault flags (set when count exceeds threshold)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            core_a_faulty <= 1'b0;
            core_b_faulty <= 1'b0;
            core_c_faulty <= 1'b0;
        end else begin
            if (fault_count_a > FAULT_THRESHOLD) begin
                core_a_faulty <= 1'b1;
            end

            if (fault_count_b > FAULT_THRESHOLD) begin
                core_b_faulty <= 1'b1;
            end

            if (fault_count_c > FAULT_THRESHOLD) begin
                core_c_faulty <= 1'b1;
            end
        end
    end

    // System status
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            any_disagreement <= 1'b0;
            system_healthy   <= 1'b0;
            tmr_active       <= 1'b0;
        end else begin
            any_disagreement <= any_disagree;
            system_healthy   <= !any_disagree && !core_a_faulty && !core_b_faulty && !core_c_faulty;
            tmr_active       <= 1'b1;  // Always active after reset
        end
    end

endmodule
