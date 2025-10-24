# TCL Monster - Libero FPGA Project Automation

Command-line driven TCL automation for Microchip Libero SoC projects, primarily targeting PolarFire and PolarFire SoC FPGAs.

## Current Target
- **Libero Version:** SoC v2024.2
- **Primary Device:** PolarFire MPF300 Eval Kit
- **Future Support:** Igloo2, SmartFusion2 families

## Project Structure
```
tcl_monster/
├── tcl_scripts/       # Libero TCL automation scripts
├── hdl/              # HDL source files (Verilog/VHDL)
├── config/           # Project configuration files
├── docs/             # Documentation and examples
└── .claude/          # Claude Code project instructions
```

## Features

### IP Configuration Generators ✓ Working
Automated generators for common Microchip/Actel IP cores that eliminate manual GUI configuration:

- **DDR4 Memory Controller** (`ddr4_config_generator.tcl`)
  - Automatic geometry calculation (row/col/bank bits)
  - Latency selection based on speed grade
  - Supports 1GB to 4GB+ configurations
  - DDR4-1600 through DDR4-3200 speeds

- **Clock Conditioning Circuit** (`ccc_config_generator.tcl`)
  - Single and dual output configurations
  - Automatic PLL calculation
  - Template-based for common MI-V + DDR scenarios

- **UART** (`uart_config_generator.tcl`)
  - Automatic baud rate divisor calculation with error checking
  - Configurable data bits, parity, FIFOs
  - Standard rates: 9600, 57600, 115200, 460800 baud

- **GPIO** (`gpio_config_generator.tcl`)
  - 1-32 pins configurable as input/output/bidirectional
  - Custom initial value patterns
  - LED and button templates

- **PCIe** (`pcie_config_generator.tcl`)
  - Endpoint and Root Port configurations
  - x1, x2, x4 lane support
  - Gen1/Gen2 speeds
  - Template-based for common use cases

**See:** `tcl_scripts/lib/generators/README.md` for complete documentation and usage examples.

### Pre-Generated IP Templates ✓ Available
Ready-to-use configurations in `tcl_scripts/lib/templates/`:
- 4 DDR4 variants (1GB, 2GB, 4GB @ different speeds)
- 2 PF_CCC variants (single/dual output for MI-V projects)
- 5 UART variants (standard baud rates)
- 5 GPIO variants (LEDs, buttons, bidirectional, patterns)
- 4 PCIe variants (endpoint/root port configurations)

## Quick Start

### Generate IP Core Configuration
```bash
# Example: Generate 4GB DDR4 configuration
cd /mnt/c/tcl_monster
tclsh
source tcl_scripts/lib/generators/ddr4_config_generator.tcl
generate_mpf300_4gb_ddr4 "PF_DDR4_C0" "my_ddr4.tcl"
exit

# Example: Generate 115200 baud UART
tclsh
source tcl_scripts/lib/generators/uart_config_generator.tcl
generate_uart_115200 "CoreUARTapb_C0" "my_uart.tcl"
exit
```

### Use Pre-Generated Templates
```tcl
# In your Libero TCL project script:
source tcl_scripts/lib/templates/pf_ddr4_4gb_1600.tcl
source tcl_scripts/lib/templates/uart_115200.tcl
source tcl_scripts/lib/templates/gpio_leds_8.tcl

# IP cores are now instantiated and ready to add to SmartDesign
```

### Test Generators
```bash
# Test all generators
tclsh tcl_scripts/test_uart_gpio_generators.tcl
tclsh tcl_scripts/test_pcie_generator.tcl
./run_libero.sh tcl_scripts/test_ddr4_generator.tcl SCRIPT
./run_libero.sh tcl_scripts/test_ccc_generator.tcl SCRIPT
```

## Status

**Working:**
- ✅ 5 IP configuration generators (DDR4, CCC, UART, GPIO, PCIe)
- ✅ 20+ pre-generated templates
- ✅ Automated test scripts
- ✅ Complete documentation

**In Development:**
- ⏳ Additional IP generators (SPI, I2C, SERDES)
- ⏳ SmartDesign automation (interconnect generation)
- ⏳ Pin constraint automation
