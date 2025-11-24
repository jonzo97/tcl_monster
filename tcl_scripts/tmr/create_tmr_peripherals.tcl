# Create Triplicated Peripherals for TMR System
# Uses Microchip IP cores: CoreUARTapb, CoreGPIO, CoreTimer

puts "Creating triplicated peripherals for TMR system..."

# ============================================================================
# UART - 3x CoreUARTapb (115200 baud)
# ============================================================================

set uart_params {
    "BAUD_VAL_FRCTN:0"
    "BAUD_VAL_FRCTN_EN:false"
    "BAUD_VALUE:26"
    "FIXEDMODE:0"
    "PRG_BIT8:0"
    "PRG_PARITY:0"
    "RX_FIFO:0"
    "RX_LEGACY_MODE:0"
    "TX_FIFO:0"
    "USE_SOFT_FIFO:0"
}

puts "Creating UART A..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} \
    -component_name {CoreUARTapb_A} \
    -params $uart_params

puts "Creating UART B..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} \
    -component_name {CoreUARTapb_B} \
    -params $uart_params

puts "Creating UART C..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} \
    -component_name {CoreUARTapb_C} \
    -params $uart_params

puts "✓ 3x UART cores created (115200 baud)"

# ============================================================================
# GPIO - 3x CoreGPIO (32 pins, output mode for fault LEDs)
# ============================================================================

set gpio_params {
    "APB_WIDTH:32"
    "FAMILY:19"
    "FIXED_CONFIG_0:false"
    "FIXED_CONFIG_1:false"
    "FIXED_CONFIG_2:false"
    "FIXED_CONFIG_3:false"
    "INT_BUS:0"
    "IO_INT_TYPE_BIT_0_31:0x00000000"
    "IO_NUM:8"
    "IO_TYPE_BIT_0_31:0x000000FF"
    "IO_VAL_BIT_0_31:0x00000000"
    "OE_TYPE:1"
}

puts "Creating GPIO A..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreGPIO:3.2.102} \
    -component_name {CoreGPIO_A} \
    -params $gpio_params

puts "Creating GPIO B..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreGPIO:3.2.102} \
    -component_name {CoreGPIO_B} \
    -params $gpio_params

puts "Creating GPIO C..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreGPIO:3.2.102} \
    -component_name {CoreGPIO_C} \
    -params $gpio_params

puts "✓ 3x GPIO cores created (8 pins, output mode)"

# ============================================================================
# Timer - 3x CoreTimer (for delays and interrupts)
# ============================================================================

set timer_params {
    "FAMILY:19"
    "INTACTIVEH:1"
    "WIDTH:32"
}

puts "Creating Timer A..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_A} \
    -params $timer_params

puts "Creating Timer B..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_B} \
    -params $timer_params

puts "Creating Timer C..."
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreTimer:2.0.103} \
    -component_name {CoreTimer_C} \
    -params $timer_params

puts "✓ 3x Timer cores created (32-bit)"

puts ""
puts "Peripheral Summary:"
puts "  UART:  3x CoreUARTapb @ 115200 baud"
puts "  GPIO:  3x CoreGPIO (8 pins output)"
puts "  Timer: 3x CoreTimer (32-bit)"
puts ""
puts "Next: Create triplicated memory (LSRAM)"
