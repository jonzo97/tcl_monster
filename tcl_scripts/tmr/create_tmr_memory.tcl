# Create Triplicated Memory for TMR System
# Uses PolarFire LSRAM with AHB-Lite interface
# Each core gets its own memory bank, reads are voted

puts "Creating triplicated memory (3x 32KB LSRAM with AHB) for TMR system..."

# PF_SRAM_AHBL_AXI configuration for 32KB with AHB-Lite interface
# Based on reference design PF_SRAM_AHB_C0.tcl pattern exactly
# FABRIC_INTERFACE_TYPE:0 = AHB-Lite (not AXI4)
# Using string format like reference design (not TCL list)

puts "Creating LSRAM Bank A (32KB, AHB-Lite)..."
create_and_configure_core -core_vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:*} -download_core -component_name {PF_SRAM_AHB_A} -params \
"AXI4_AWIDTH:32 \
AXI4_DWIDTH:32 \
AXI4_IDWIDTH:8 \
AXI4_IFTYPE_RD:T \
AXI4_IFTYPE_WR:T \
AXI4_WRAP_SUPPORT:F \
BYTEENABLES:1 \
BYTE_ENABLE_WIDTH:4 \
B_REN_POLARITY:2 \
CASCADE:1 \
ECC_OPTIONS:0 \
FABRIC_INTERFACE_TYPE:0 \
IMPORT_FILE: \
INIT_RAM:F \
LPM_HINT:0 \
PIPELINE_OPTIONS:1 \
RDEPTH:8192 \
RWIDTH:40 \
USE_NATIVE_INTERFACE:F \
WDEPTH:8192 \
WWIDTH:40"

puts "Creating LSRAM Bank B (32KB, AHB-Lite)..."
create_and_configure_core -core_vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:*} -download_core -component_name {PF_SRAM_AHB_B} -params \
"AXI4_AWIDTH:32 \
AXI4_DWIDTH:32 \
AXI4_IDWIDTH:8 \
AXI4_IFTYPE_RD:T \
AXI4_IFTYPE_WR:T \
AXI4_WRAP_SUPPORT:F \
BYTEENABLES:1 \
BYTE_ENABLE_WIDTH:4 \
B_REN_POLARITY:2 \
CASCADE:1 \
ECC_OPTIONS:0 \
FABRIC_INTERFACE_TYPE:0 \
IMPORT_FILE: \
INIT_RAM:F \
LPM_HINT:0 \
PIPELINE_OPTIONS:1 \
RDEPTH:8192 \
RWIDTH:40 \
USE_NATIVE_INTERFACE:F \
WDEPTH:8192 \
WWIDTH:40"

puts "Creating LSRAM Bank C (32KB, AHB-Lite)..."
create_and_configure_core -core_vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:*} -download_core -component_name {PF_SRAM_AHB_C} -params \
"AXI4_AWIDTH:32 \
AXI4_DWIDTH:32 \
AXI4_IDWIDTH:8 \
AXI4_IFTYPE_RD:T \
AXI4_IFTYPE_WR:T \
AXI4_WRAP_SUPPORT:F \
BYTEENABLES:1 \
BYTE_ENABLE_WIDTH:4 \
B_REN_POLARITY:2 \
CASCADE:1 \
ECC_OPTIONS:0 \
FABRIC_INTERFACE_TYPE:0 \
IMPORT_FILE: \
INIT_RAM:F \
LPM_HINT:0 \
PIPELINE_OPTIONS:1 \
RDEPTH:8192 \
RWIDTH:40 \
USE_NATIVE_INTERFACE:F \
WDEPTH:8192 \
WWIDTH:40"

puts "✓ 3x LSRAM banks created (32KB each, AHB-Lite interface)"
puts ""
puts "Memory Configuration:"
puts "  Total: 96KB (3x 32KB)"
puts "  Type: PolarFire LSRAM"
puts "  Interface: AHB-Lite (FABRIC_INTERFACE_TYPE:0)"
puts "  Address Width: 32 bits"
puts "  Data Width: 32 bits"
puts "  Depth: 8192 words (32KB)"
puts ""
puts "Memory Map:"
puts "  Bank A: 0x60000000-0x60007FFF (for Core A writes)"
puts "  Bank B: 0x60000000-0x60007FFF (for Core B writes)"
puts "  Bank C: 0x60000000-0x60007FFF (for Core C writes)"
puts "  Read: Voted from all 3 banks"
puts ""
puts "Next: Create AHB voter bridge in SmartDesign"
