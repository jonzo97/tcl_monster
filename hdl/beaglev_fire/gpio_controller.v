// GPIO Controller - FPGA Fabric Design for BeagleV-Fire
// 8-bit GPIO with direction control, connected to MSS via APB
// Target: MPFS025T PolarFire SoC

module gpio_controller (
    // APB Interface
    input  wire        pclk,
    input  wire        presetn,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] paddr,
    input  wire [31:0] pwdata,
    output reg  [31:0] prdata,
    output wire        pready,
    output wire        pslverr,

    // GPIO pins
    inout  wire [7:0]  gpio_pins
);

    // Register map
    // 0x00: GPIO_DATA    - Read/write GPIO values
    // 0x04: GPIO_DIR     - Direction control (0=input, 1=output)
    // 0x08: GPIO_IN      - Read input values

    reg [7:0] gpio_out;
    reg [7:0] gpio_dir;
    wire [7:0] gpio_in;

    // Bidirectional GPIO logic
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gpio_bidir
            assign gpio_pins[i] = gpio_dir[i] ? gpio_out[i] : 1'bz;
            assign gpio_in[i] = gpio_pins[i];
        end
    endgenerate

    // APB always ready
    assign pready = 1'b1;
    assign pslverr = 1'b0;

    // APB read/write logic
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            gpio_out <= 8'h00;
            gpio_dir <= 8'h00;  // All inputs by default
            prdata <= 32'h0;
        end else begin
            if (psel && penable) begin
                if (pwrite) begin
                    // Write operation
                    case (paddr[7:0])
                        8'h00: gpio_out <= pwdata[7:0];
                        8'h04: gpio_dir <= pwdata[7:0];
                        default: ;
                    endcase
                end else begin
                    // Read operation
                    case (paddr[7:0])
                        8'h00: prdata <= {24'h0, gpio_out};
                        8'h04: prdata <= {24'h0, gpio_dir};
                        8'h08: prdata <= {24'h0, gpio_in};
                        default: prdata <= 32'h0;
                    endcase
                end
            end
        end
    end

endmodule
