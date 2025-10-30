# SmartDesign Automation Library

Automated SmartDesign creation and interconnect generation for Microchip Libero SoC.

## Overview

This library eliminates manual GUI clicking by providing TCL functions to:
- **Auto-generate interconnects** (APB, AXI, clock/reset trees)
- **Create design templates** (MI-V systems, common patterns)
- **Validate connections** and catch errors early

## Directory Structure

```
smartdesign/
├── utilities/
│   └── sd_helpers.tcl          # Helper functions (logging, validation, connection)
├── interconnect/
│   ├── apb_interconnect.tcl    # APB bus interconnect generator
│   ├── axi_interconnect.tcl    # AXI4 interconnect generator (TODO)
│   └── clock_reset_tree.tcl    # Clock and reset distribution
├── templates/
│   ├── miv_rv32_minimal.tcl    # Minimal MI-V RISC-V system
│   ├── miv_rv32_full.tcl       # Full-featured MI-V system (TODO)
│   └── ...
└── README.md                    # This file
```

## Quick Start

### 1. Create Minimal MI-V System

```tcl
# In your Libero project script:
source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl

# Create minimal MI-V system
::miv_minimal::create_and_set_root "MyMIV_System" {
    core_variant "RV32IMC"
    system_clock_mhz 50
    gpio_width 8
    add_uart true
}

# System is now created and set as root - ready to build!
run_tool -name SYNTHESIZE
```

### 2. Manual APB Interconnect

```tcl
source tcl_scripts/lib/smartdesign/interconnect/apb_interconnect.tcl

# Define peripherals with base addresses
set peripherals {
    {CoreUARTapb_C0 0x70001000 0x1000}
    {CoreGPIO_C0    0x70002000 0x1000}
    {CoreTimer_C0   0x70003000 0x1000}
}

# Connect to MI-V APB master
::apb_interconnect::connect_peripherals "MyDesign" "MIV_RV32_C0:APB_MSTR" $peripherals

# Print address map for documentation
::apb_interconnect::print_address_map $peripherals
```

**Output:**
```
APB Address Map:
================
CoreUARTapb_C0       0x70001000 - 0x70001FFF  (4096   bytes)
CoreGPIO_C0          0x70002000 - 0x70002FFF  (4096   bytes)
CoreTimer_C0         0x70003000 - 0x70003FFF  (4096   bytes)
```

### 3. Clock and Reset Distribution

```tcl
source tcl_scripts/lib/smartdesign/interconnect/clock_reset_tree.tcl

# Create standard PolarFire power-on-reset chain
set reset_consumers {
    "MIV_RV32_C0:RESETN"
    "CoreUART_C0:PRESETN"
    "CoreGPIO_C0:PRESETN"
}

::clock_reset::create_standard_por "MyDesign" "PF_CCC_C0:OUT0_FABCLK_0" $reset_consumers
```

## API Reference

### APB Interconnect (`apb_interconnect.tcl`)

#### `connect_peripherals`
Connect APB master to multiple peripherals with automatic address decoding.

```tcl
::apb_interconnect::connect_peripherals $sd_name $master_prefix $peripherals
```

**Args:**
- `sd_name`: SmartDesign name
- `master_prefix`: APB master instance:port (e.g., `"MIV_RV32_C0:APB_MSTR"`)
- `peripherals`: List of `{instance base_addr size}` tuples

#### `auto_address_peripherals`
Auto-generate sequential address map.

```tcl
set periph_names {CoreUART_C0 CoreGPIO_C0 CoreTimer_C0}
set peripherals [::apb_interconnect::auto_address_peripherals $periph_names 0x70000000 0x1000]
```

#### `print_address_map`
Print formatted address map for documentation.

---

### Clock/Reset Tree (`clock_reset_tree.tcl`)

#### `create_tree`
Create complete clock and reset distribution.

```tcl
set config {
    clock_source "PF_CCC_C0:OUT0_FABCLK_0"
    clock_consumers {"MIV_RV32_C0:CLK" "CoreUART_C0:PCLK"}
    reset_source "CORERESET_PF_C0:FABRIC_RESET_N"
    reset_consumers {"MIV_RV32_C0:RESETN" "CoreUART_C0:PRESETN"}
}

::clock_reset::create_tree "MyDesign" $config
```

#### `distribute_clock`
Fan out clock to multiple consumers.

```tcl
::clock_reset::distribute_clock $sd_name $clock_source $consumer_list
```

#### `distribute_reset`
Fan out reset to multiple consumers.

```tcl
::clock_reset::distribute_reset $sd_name $reset_source $consumer_list "active_low"
```

#### `create_standard_por`
Create complete PolarFire POR (Power-On-Reset) chain.

```tcl
set por_chain [::clock_reset::create_standard_por $sd_name $clock_src $reset_consumers]
# Returns: {init_monitor INST reset_controller INST reset_output PIN}
```

---

### Helper Utilities (`sd_helpers.tcl`)

#### `add_component`
Add component to SmartDesign with error checking.

```tcl
::sd_helpers::add_component $sd_name "CoreUART_C0" "CoreUART_C0_inst"
```

#### `connect_pins`
Connect pins with validation.

```tcl
::sd_helpers::connect_pins $sd_name {"InstA:PIN_OUT" "InstB:PIN_IN"}
```

#### `generate_apb_address_map`
Generate address map dictionary for peripherals.

```tcl
set addr_map [::sd_helpers::generate_apb_address_map $peripheral_list 0x70000000]
# Returns: dict of {periph -> {base addr, size, end addr}}
```

## Design Patterns

### Pattern 1: Simple Peripheral System
**Use case:** MI-V core + UART + GPIO + Timer

```tcl
source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl

::miv_minimal::create_and_set_root "SimpleSoC" {
    gpio_width 8
    add_uart true
}
```

**Result:** Complete system in ~30 seconds vs. 5-10 minutes manually.

---

### Pattern 2: Custom Peripheral Integration

```tcl
# 1. Source libraries
source tcl_scripts/lib/smartdesign/interconnect/apb_interconnect.tcl
source tcl_scripts/lib/smartdesign/interconnect/clock_reset_tree.tcl

# 2. Create SmartDesign
create_smartdesign -sd_name "CustomSoC"

# 3. Add your components
::sd_helpers::add_component "CustomSoC" "MIV_RV32_C0" "MIV_RV32"
::sd_helpers::add_component "CustomSoC" "CoreUART_C0" "UART0"
::sd_helpers::add_component "CustomSoC" "CorePWM_C0" "PWM0"

# 4. Auto-connect APB peripherals
set peripherals [::apb_interconnect::auto_address_peripherals \
    {"UART0" "PWM0"} \
    0x70000000 \
    0x1000
]
::apb_interconnect::connect_peripherals "CustomSoC" "MIV_RV32:APB_MSTR" $peripherals

# 5. Distribute clock/reset
::clock_reset::distribute_clock "CustomSoC" "PF_CCC_C0:OUT0_FABCLK_0" \
    {"MIV_RV32:CLK" "UART0:PCLK" "PWM0:PCLK"}

::clock_reset::distribute_reset "CustomSoC" "RESET_CTRL:FABRIC_RESET_N" \
    {"MIV_RV32:RESETN" "UART0:PRESETN" "PWM0:PRESETN"}
```

---

## Advanced Usage

### Multi-Clock Domain Systems

```tcl
set clock_domains {
    sys_clk {
        source "PF_CCC_C0:OUT0_FABCLK_0"
        consumers {"MIV_RV32_C0:CLK" "CoreUART_C0:PCLK"}
    }
    ddr_clk {
        source "PF_CCC_C0:OUT1_FABCLK_0"
        consumers {"PF_DDR4_C0:SYS_CLK"}
    }
}

::clock_reset::distribute_multi_clock "MyDesign" $clock_domains
```

### Complex APB Fabric (4+ Peripherals)

When you have many peripherals, the library automatically uses CoreAPB3 fabric:

```tcl
set peripherals {
    {UART0 0x70001000 0x1000}
    {GPIO0 0x70002000 0x1000}
    {TIMER0 0x70003000 0x1000}
    {SPI0 0x70004000 0x1000}
    {I2C0 0x70005000 0x1000}
}

# Library automatically instantiates CoreAPB3 for >3 peripherals
::apb_interconnect::connect_peripherals "MyDesign" "MIV_RV32:APB_MSTR" $peripherals
```

---

## Debugging

### Enable Verbose Logging

```tcl
set ::sd_helpers::verbose 1
```

### Catch Connection Errors

The library uses `catch` internally, but you can check return values:

```tcl
if {![::sd_helpers::connect_pins $sd_name {"PIN_A" "PIN_B"}]} {
    puts "WARNING: Connection failed, but continuing..."
}
```

---

## Limitations & Known Issues

### Current Limitations
1. **AXI interconnect generator not yet implemented** - Use manual connections for AXI
2. **Component must pre-exist** - Libraries assume IP cores already created via generators
3. **Bus interface introspection limited** - Cannot programmatically query pin lists

### Workarounds
- **Pre-create IP cores** using IP generator library (`tcl_scripts/lib/generators/`)
- **Use templates** as starting points, customize as needed
- **Fallback to manual connections** for complex cases

---

## Examples

See `tcl_scripts/test_smartdesign_*.tcl` for complete working examples:
- `test_smartdesign_minimal.tcl` - Minimal MI-V system
- `test_smartdesign_peripherals.tcl` - System with UART/GPIO/Timer
- `test_smartdesign_multi_clock.tcl` - Multi-clock domain design

---

## Future Enhancements

### Planned Features
- ✅ APB interconnect automation
- ✅ Clock/reset tree automation
- ⏳ AXI4 interconnect automation
- ⏳ AXI crossbar for multiple masters
- ⏳ Interrupt aggregation (MIV_ESS)
- ⏳ SmartDesign layout optimization (component positioning)
- ⏳ Export to standalone HDL wrapper

---

## Contributing

When adding new templates or interconnect generators:
1. Use `::sd_helpers::log` for consistent logging
2. Use `catch` for error handling - don't fail entire design
3. Document parameters with examples
4. Add entry to this README

---

**Created:** 2025-10-28
**Status:** Experimental - feedback welcome!
