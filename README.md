# TCL Monster - Libero FPGA Project Automation

Command-line driven TCL automation for Microchip Libero SoC projects, targeting PolarFire and PolarFire SoC FPGAs. Complete workflow automation from project creation through bitstream generation and FPGA programming.

## Supported Platforms
- **Libero Version:** SoC v2024.2
- **PolarFire MPF300 Eval Kit** - Development board automation
- **BeagleV-Fire (MPFS025T)** - Complete Linux-based FPGA programming workflow ✓
- **Future Support:** Igloo2, SmartFusion2 families

## Development Environment
- **Primary:** WSL2 on Windows (tested on Ubuntu 22.04/23.04)
- **Libero:** Can run natively in WSL or via Windows installation
- **SoftConsole:** WSL-compatible for RISC-V development

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

## Complete Design Flow Examples

### BeagleV-Fire LED Blink (Standalone Fabric)
Complete automation from HDL to programmed FPGA:

```bash
# 1. Create project with HDL and constraints
./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT

# 2. Build design (synthesis, P&R, bitstream, .spi export)
./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT

# 3. Transfer to BeagleV-Fire
scp libero_projects/beaglev_fire/led_blink/designer/led_blinker_fabric/export/led_blink_bitstream.spi \
    beagle@beaglev-fire.local:/lib/firmware/mpfs_bitstream.spi

# 4. Program FPGA via Linux
ssh beagle@beaglev-fire.local "sudo /usr/share/microchip/gateware/update-gateware.sh"
```

**Results:** 48 LUTs, 27 FFs, 1 Hz LED blink on cape connector P8[3]

**See:** `docs/beaglev_fire_hardware_setup.md` for complete workflow documentation

### MPF300 Eval Kit Counter Demo
```bash
./run_libero.sh tcl_scripts/create_counter_project.tcl SCRIPT
./run_libero.sh tcl_scripts/build_counter.tcl SCRIPT
```

## Status

**Working:**
- ✅ Complete project creation automation
- ✅ Automated build flow (synthesis → P&R → bitstream)
- ✅ BeagleV-Fire Linux FPGA programming
- ✅ 5 IP configuration generators (DDR4, CCC, UART, GPIO, PCIe)
- ✅ 20+ pre-generated templates
- ✅ Constraint file generation (PDC/SDC)
- ✅ Automated test scripts
- ✅ Comprehensive documentation

**In Development:**
- ⏳ Additional IP generators (SPI, I2C, SERDES)
- ⏳ SmartDesign automation (interconnect generation)
- ⏳ MI-V RISC-V integration examples

## Documentation

Comprehensive guides available in `docs/`:

### BeagleV-Fire (PolarFire SoC)
- **`beaglev_fire_guide.md`** - Reference design analysis, device specs, TCL patterns
- **`beaglev_fire_hardware_setup.md`** - Hardware setup, programming workflow, embedded development
- **`complete_toolchain_setup.md`** - RISC-V toolchain installation and HSS workflow

### General FPGA Development
- **`DESIGN_LIBRARY.md`** - Catalog of example designs (basic → advanced)
- **`DEBUGGING_FRAMEWORK.md`** - SmartDebug and Identify automation
- **`SIMULATION_FRAMEWORK.md`** - ModelSim/QuestaSim integration
- **`ROADMAP.md`** - Project roadmap with phases and time estimates
- **`COLLEAGUE_GUIDE.md`** - Quick start guide for new users

### AI-Assisted Development
- **`ai_serial_debugging_framework.md`** - Autonomous board interaction patterns
- **`CONTEXT_STRATEGY.md`** - Managing Claude Code sessions

## Getting Started (WSL)

### Prerequisites
```bash
# Install WSL2 (Windows PowerShell as Administrator)
wsl --install -d Ubuntu-23.04

# Inside WSL - Install required tools
sudo apt update
sudo apt install -y git tcl build-essential

# Optional: Native RISC-V toolchain for BeagleV-Fire
./install_native_toolchain.sh
```

### Clone Repository
```bash
git clone https://github.com/yourusername/tcl_monster.git
cd tcl_monster
```

### Setup Libero Path
Edit `run_libero.sh` to point to your Libero installation:
```bash
# If running Libero on Windows (via WSL mount)
LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe"

# If running Libero natively in WSL
LIBERO_PATH="/opt/microchip/libero/bin/libero"
```

### Run Your First Design
```bash
# Create and build simple counter
./run_libero.sh tcl_scripts/create_counter_project.tcl SCRIPT
./run_libero.sh tcl_scripts/build_counter.tcl SCRIPT

# Or try BeagleV-Fire LED blink
./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT
./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT
```

## Documentation

Comprehensive guides available in `docs/`:

### BeagleV-Fire (PolarFire SoC)
- **`beaglev_fire_guide.md`** - Reference design analysis, device specs, TCL patterns
- **`beaglev_fire_hardware_setup.md`** - Hardware setup, programming workflow, embedded development
- **`complete_toolchain_setup.md`** - RISC-V toolchain installation and HSS workflow

### General FPGA Development
- **`DESIGN_LIBRARY.md`** - Catalog of example designs (basic → advanced)
- **`DEBUGGING_FRAMEWORK.md`** - SmartDebug and Identify automation
- **`SIMULATION_FRAMEWORK.md`** - ModelSim/QuestaSim integration
- **`ROADMAP.md`** - Project roadmap with phases and time estimates
- **`COLLEAGUE_GUIDE.md`** - Quick start guide for new users

### AI-Assisted Development
- **`ai_serial_debugging_framework.md`** - Autonomous board interaction patterns
- **`CONTEXT_STRATEGY.md`** - Managing Claude Code sessions

## Getting Started (WSL)

### Prerequisites
```bash
# Install WSL2 (Windows PowerShell as Administrator)
wsl --install -d Ubuntu-23.04

# Inside WSL - Install required tools
sudo apt update
sudo apt install -y git tcl build-essential

# Optional: Native RISC-V toolchain for BeagleV-Fire
./install_native_toolchain.sh
```

### Clone Repository
```bash
git clone https://github.com/yourusername/tcl_monster.git
cd tcl_monster
```

### Setup Libero Path
Edit `run_libero.sh` to point to your Libero installation:
```bash
# If running Libero on Windows (via WSL mount)
LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe"

# If running Libero natively in WSL
LIBERO_PATH="/opt/microchip/libero/bin/libero"
```

### Run Your First Design
```bash
# Create and build simple counter
./run_libero.sh tcl_scripts/create_counter_project.tcl SCRIPT
./run_libero.sh tcl_scripts/build_counter.tcl SCRIPT

# Or try BeagleV-Fire LED blink
./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT
./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT
```

## Contributing

This project is developed with assistance from Claude Code (Anthropic). Contributions welcome!

### Project Philosophy
- **Command-line first** - Eliminate GUI bottlenecks
- **Parameterized** - Reusable, configurable scripts
- **Documented** - Every pattern explained
- **Tested** - Validate on real hardware

## License

See LICENSE file for details.
