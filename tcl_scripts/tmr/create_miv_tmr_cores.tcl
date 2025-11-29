# Create 3x MI-V RV32IMC Cores for TMR System
# Identical configuration for all 3 cores
# AHB interface enabled for external memory access through voters

puts "Creating 3x MI-V RV32IMC cores for TMR system..."

# MI-V RV32IMC Configuration (identical for all cores)
# Based on MIV_RV32_CFG1 reference design pattern with AHB enabled
set miv_params {
    "C_EXT:true"
    "M_EXT:true"
    "F_EXT:false"
    "DEBUGGER:true"
    "ECC_ENABLE:false"
    "INTERNAL_MTIME:true"
    "INTERNAL_MTIME_IRQ:true"
    "MTIME_PRESCALER:100"
    "NUM_EXT_IRQS:1"
    "GEN_MUL_TYPE:2"
    "VECTORED_INTERRUPTS:false"
    "RESET_VECTOR_ADDR_0:0x0"
    "RESET_VECTOR_ADDR_1:0x8000"
    "TCM_PRESENT:true"
    "TCM_START_ADDR_0:0x0"
    "TCM_START_ADDR_1:0x8000"
    "TCM_END_ADDR_0:0xFFFF"
    "TCM_END_ADDR_1:0x8000"
    "AHB_INITIATOR_TYPE:1"
    "AHB_START_ADDR_0:0x0"
    "AHB_START_ADDR_1:0x6000"
    "AHB_END_ADDR_0:0xFFFF"
    "AHB_END_ADDR_1:0x6000"
    "AHB_TARGET_MIRROR:false"
    "APB_INITIATOR_TYPE:1"
    "APB_START_ADDR_0:0x0"
    "APB_START_ADDR_1:0x7000"
    "APB_END_ADDR_0:0xFFFF"
    "APB_END_ADDR_1:0x7000"
    "APB_TARGET_MIRROR:false"
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
puts "  AHB Master: Enabled @ 0x60000000-0x6000FFFF"
puts "  APB Master: Enabled @ 0x70000000-0x7000FFFF"
puts "  Internal MTIME: Yes"
puts "  Reset Vector: 0x80000000"
puts "  Debugger: Enabled"
puts ""
puts "Memory Map:"
puts "  0x60000000-0x6000FFFF: AHB slaves (external SRAM via voter)"
puts "  0x70000000-0x7000FFFF: APB slaves (UART, GPIO, Timer)"
puts "  0x80000000-0x8000FFFF: TCM (internal, per-core)"
puts ""
puts "Next: Create triplicated memory and peripherals"
