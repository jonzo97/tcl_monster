# Add Peripherals and Memory to Existing TMR Project
# Opens existing project and adds missing components incrementally

puts "════════════════════════════════════════════════════════════════"
puts "  Adding Peripherals & Memory to TMR Project"
puts "════════════════════════════════════════════════════════════════"
puts ""

set project_name "miv_tmr_mpf300"
set project_dir "C:/tcl_monster/libero_projects/tmr"
set project_location "$project_dir/$project_name"

# ============================================================================
# Step 1: Open Existing Project
# ============================================================================

puts "\[1/4\] Opening existing project..."
open_project "$project_location/$project_name.prjx"
puts "✓ Project opened"
puts ""

# ============================================================================
# Step 2: Create Peripheral IP Cores (3x UART, 3x GPIO)
# ============================================================================

puts "\[2/4\] Creating peripheral IP cores..."

# CoreUARTapb configuration (115200 baud, 8N1)
set uart_params {
    "BAUD_VAL_FRCTN_EN:false"
    "BAUD_VALUE:1"
    "FIXEDMODE:0"
    "PRG_BIT8:0"
    "PRG_PARITY:0"
    "RX_FIFO:0"
    "RX_LEGACY_MODE:0"
    "TX_FIFO:0"
    "USE_SOFT_FIFO:0"
}

# Create 3x CoreUARTapb instances
foreach suffix {A B C} {
    puts "  Creating CoreUARTapb_$suffix..."
    create_and_configure_core \
        -core_vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} \
        -component_name "CoreUARTapb_$suffix" \
        -params $uart_params
}

# CoreGPIO configuration (8-bit width)
set gpio_params {
    "APB_WIDTH:8"
    "FAMILY:26"
    "FIXED_CONFIG_0:true"
    "FIXED_CONFIG_1:true"
    "FIXED_CONFIG_2:true"
    "FIXED_CONFIG_3:true"
    "FIXED_CONFIG_4:true"
    "FIXED_CONFIG_5:true"
    "FIXED_CONFIG_6:true"
    "FIXED_CONFIG_7:true"
    "INT_BUS:0"
    "IO_INT:0"
    "IO_NUM:8"
    "IO_TYPE_0:0"
    "IO_TYPE_1:0"
    "IO_TYPE_2:0"
    "IO_TYPE_3:0"
    "IO_TYPE_4:0"
    "IO_TYPE_5:0"
    "IO_TYPE_6:0"
    "IO_TYPE_7:0"
    "IO_VAL_0:0"
    "IO_VAL_1:0"
    "IO_VAL_2:0"
    "IO_VAL_3:0"
    "IO_VAL_4:0"
    "IO_VAL_5:0"
    "IO_VAL_6:0"
    "IO_VAL_7:0"
    "OE_TYPE:0"
}

# Create 3x CoreGPIO instances
foreach suffix {A B C} {
    puts "  Creating CoreGPIO_$suffix..."
    create_and_configure_core \
        -core_vlnv {Actel:DirectCore:CoreGPIO:3.2.102} \
        -component_name "CoreGPIO_$suffix" \
        -params $gpio_params
}

puts "✓ Peripherals created"
puts ""

# ============================================================================
# Step 3: Create Memory IP Cores (3x 64KB PF_SRAM)
# ============================================================================

puts "\[3/4\] Creating memory IP cores..."

# PF_SRAM configuration (64KB, AXI4 interface)
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

# Create 3x PF_SRAM instances
foreach suffix {A B C} {
    puts "  Creating PF_SRAM_BANK_$suffix..."
    create_and_configure_core \
        -core_vlnv {Actel:SystemBuilder:PF_SRAM} \
        -download_core \
        -component_name "PF_SRAM_BANK_$suffix" \
        -params $sram_params
}

puts "✓ Memory banks created"
puts ""

# ============================================================================
# Step 4: Add Components to SmartDesign
# ============================================================================

puts "\[4/4\] Adding components to TMR_TOP SmartDesign..."

# Open existing SmartDesign
open_smartdesign -sd_name {TMR_TOP}

# Add 3x UART peripherals
puts "  Adding UART peripherals..."
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreUARTapb_A} -instance_name {UART_A}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreUARTapb_B} -instance_name {UART_B}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreUARTapb_C} -instance_name {UART_C}

# Add 3x GPIO peripherals
puts "  Adding GPIO peripherals..."
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreGPIO_A} -instance_name {GPIO_A}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreGPIO_B} -instance_name {GPIO_B}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {CoreGPIO_C} -instance_name {GPIO_C}

# Add 3x memory banks
puts "  Adding memory banks..."
sd_instantiate_component -sd_name {TMR_TOP} -component_name {PF_SRAM_BANK_A} -instance_name {MEM_BANK_A}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {PF_SRAM_BANK_B} -instance_name {MEM_BANK_B}
sd_instantiate_component -sd_name {TMR_TOP} -component_name {PF_SRAM_BANK_C} -instance_name {MEM_BANK_C}

# Add voter modules (HDL)
puts "  Adding voter modules..."
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {uart_tx_voter} -hdl_file {hdl/uart_tx_voter.v} -instance_name {VOTER_UART_TX}
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {gpio_voter} -hdl_file {hdl/gpio_voter.v} -instance_name {VOTER_GPIO}
sd_instantiate_hdl_module -sd_name {TMR_TOP} -hdl_module_name {memory_read_voter} -hdl_file {hdl/memory_read_voter.v} -instance_name {VOTER_MEM_READ}

# Save SmartDesign
save_smartdesign -sd_name {TMR_TOP}
puts "✓ Components added to SmartDesign"
puts ""

# ============================================================================
# Step 5: Save Project
# ============================================================================

save_project

puts "════════════════════════════════════════════════════════════════"
puts "  Components Added Successfully!"
puts "════════════════════════════════════════════════════════════════"
puts ""
puts "Added to TMR_TOP SmartDesign:"
puts "  • 3x CoreUARTapb (UART_A, UART_B, UART_C)"
puts "  • 3x CoreGPIO (GPIO_A, GPIO_B, GPIO_C)"
puts "  • 3x PF_SRAM_BANK (MEM_BANK_A, MEM_BANK_B, MEM_BANK_C)"
puts "  • 3x Voter modules (uart_tx, gpio, memory_read)"
puts ""
puts "Next: Wire up connections in SmartDesign (or via TCL)"
puts ""
