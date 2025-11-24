# Create Triplicated Memory for TMR System
# Uses PolarFire LSRAM blocks (64KB per core)

puts "Creating triplicated memory (3x 64KB LSRAM) for TMR system..."

# PF_SRAM configuration for 64KB
# PolarFire LSRAM can be configured via IP core
set sram_params {
    "AXI4_AWIDTH:16"
    "AXI4_DWIDTH:64"
    "AXI4_IDWIDTH:8"
    "AXI4_IFTYPE_RD:T"
    "AXI4_IFTYPE_WR:T"
    "BUSY_FLAG:0"
    "BYTE_ENABLE_WIDTH:8"
    "BYTE_SIZE:9"
    "CASCADE:1"
    "ECC:0"
    "IMPORT_FILE:"
    "INIT_RAM:F"
    "LPM_HINT:0"
    "PIPE_OPTIONS:1"
    "RDEPTH:65536"
    "RWIDTH:8"
    "USE_NATIVE:1"
    "WDEPTH:65536"
    "WWIDTH:8"
}

puts "Creating LSRAM Bank A (64KB)..."
create_and_configure_core \
    -core_vlnv {Actel:SystemBuilder:PF_SRAM} \
    -download_core \
    -component_name {PF_SRAM_BANK_A} \
    -params $sram_params

puts "Creating LSRAM Bank B (64KB)..."
create_and_configure_core \
    -core_vlnv {Actel:SystemBuilder:PF_SRAM} \
    -download_core \
    -component_name {PF_SRAM_BANK_B} \
    -params $sram_params

puts "Creating LSRAM Bank C (64KB)..."
create_and_configure_core \
    -core_vlnv {Actel:SystemBuilder:PF_SRAM} \
    -download_core \
    -component_name {PF_SRAM_BANK_C} \
    -params $sram_params

puts "✓ 3x LSRAM banks created (64KB each)"
puts ""
puts "Memory Configuration:"
puts "  Total: 192KB (3x 64KB)"
puts "  Type: PolarFire LSRAM"
puts "  Interface: AHB-Lite / AXI4"
puts "  Address Width: 16 bits (64K addresses)"
puts "  Data Width: 64 bits"
puts ""
puts "Next: Integrate with voter logic in SmartDesign"
