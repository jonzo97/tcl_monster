# Create 3x MI-V RV32IMC Cores for TMR System
# Identical configuration for all 3 cores

puts "Creating 3x MI-V RV32IMC cores for TMR system..."

# MI-V RV32IMC Configuration (identical for all cores)
# Based on proven configuration from previous MI-V work
set miv_params {
    "BAUD_VALUE:1"
    "ECC_ENABLE:false"
    "EXPOSE_WFI:false"
    "INTERNAL_MTIME:true"
    "INTERNAL_MTIME_IRQ:true"
    "M_EXT:true"
    "C_EXT:true"
    "RESET_VECTOR_ADDR:0x0"
    "TCM_PRESENT:true"
    "TCM_ADDR:0x80000000"
    "TCM_SIZE:65536"
}

# Create Core A
puts "Creating MI-V Core A..."
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name {MIV_RV32_CORE_A} \
    -params $miv_params

# Create Core B (identical configuration)
puts "Creating MI-V Core B..."
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name {MIV_RV32_CORE_B} \
    -params $miv_params

# Create Core C (identical configuration)
puts "Creating MI-V Core C..."
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name {MIV_RV32_CORE_C} \
    -params $miv_params

puts "✓ 3x MI-V cores created successfully"
puts ""
puts "Core specifications:"
puts "  ISA: RV32IMC (Integer + Multiply + Compressed)"
puts "  TCM: 64KB per core @ 0x80000000"
puts "  Internal MTIME: Yes"
puts "  Reset Vector: 0x0"
puts ""
puts "Next: Create triplicated memory and peripherals"
