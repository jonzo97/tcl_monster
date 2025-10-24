# IP Configuration Generators

Intelligent TCL-based generators for Microchip PolarFire FPGA IP cores.

## Overview

This directory contains automated IP core configuration generators that eliminate manual GUI configuration for common use cases. The generators take high-level parameters and produce complete, ready-to-use TCL configurations.

## Available Generators

### 1. DDR4 Configuration Generator (`ddr4_config_generator.tcl`)

**Purpose:** Generate PF_DDR4 IP core configurations from memory specifications.

**Features:**
- Automatic geometry calculation (row/column/bank bits)
- Automatic latency selection based on speed
- Automatic timing parameter calculation
- Supports 1GB to 4GB+ configurations
- Supports DDR4-1600 through DDR4-3200

**Usage:**
```tcl
source tcl_scripts/lib/generators/ddr4_config_generator.tcl

# Method 1: High-level parameters
generate_ddr4_config \
    -size "4GB" \
    -speed "1600" \
    -width "32" \
    -axi_width "64" \
    -axi_clk "200.0" \
    -component_name "PF_DDR4_C0" \
    -output_file "my_ddr4.tcl"

# Method 2: Convenience functions
generate_mpf300_4gb_ddr4 "PF_DDR4_C0" "pf_ddr4_4gb.tcl"   # 4GB @ 1600 Mbps
generate_mpf300_2gb_ddr4 "PF_DDR4_C0" "pf_ddr4_2gb.tcl"   # 2GB @ 1600 Mbps
generate_mpf300_1gb_ddr4 "PF_DDR4_C0" "pf_ddr4_1gb.tcl"   # 1GB @ 1600 Mbps
```

**Parameters:**
| Parameter | Description | Example |
|-----------|-------------|---------|
| `-size` | Memory size | `"4GB"`, `"2GB"`, `"1GB"` |
| `-speed` | DDR4 data rate in Mbps | `"1600"`, `"2133"`, `"2400"` |
| `-width` | Memory bus width | `"16"`, `"32"` |
| `-axi_width` | AXI interface width | `"32"`, `"64"`, `"128"` |
| `-axi_clk` | AXI clock frequency (MHz) | `"200.0"`, `"300.0"` |
| `-component_name` | Instance name | `"PF_DDR4_C0"` |
| `-output_file` | Output TCL file | `"my_config.tcl"` |

**Output:**
Complete `create_and_configure_core` TCL with all 118 PF_DDR4 parameters configured.

**Example Output Summary:**
```
Generated DDR4 configuration: pf_ddr4_4gb_1600.tcl
  Memory: 4GB DDR4 x32 @ 1600 Mbps
  Geometry: 16 row bits, 10 col bits, 2 banks, 2 bank groups
  Latency: CL=12, CWL=9
  Clocks: DDR=800.0 MHz, AXI=200.0 MHz
```

---

### 2. PF_CCC Configuration Generator (`ccc_config_generator.tcl`)

**Purpose:** Generate PF_CCC (Clock Conditioning Circuit) configurations for system clocking.

**Features:**
- Single or dual output configurations
- Automatic PLL multiplier/divider calculation
- Simplified interface (GUI handles complex PLL math)
- Template-based for reliability

**Usage:**
```tcl
source tcl_scripts/lib/generators/ccc_config_generator.tcl

# Method 1: Single output
generate_ccc_single_output \
    -input_freq "50" \
    -output_freq "50" \
    -component_name "PF_CCC_C0" \
    -output_file "my_ccc.tcl"

# Method 2: Dual output (for MI-V + DDR)
generate_ccc_dual_output \
    -input_freq "50" \
    -output0_freq "50" \
    -output1_freq "200" \
    -component_name "PF_CCC_C1" \
    -output_file "my_ccc.tcl"

# Method 3: Convenience functions
generate_miv_ccc "PF_CCC_C0" "pf_ccc_miv.tcl"           # 50 MHz single output
generate_miv_ddr_ccc "PF_CCC_C1" "pf_ccc_miv_ddr.tcl"   # 50 MHz + 200 MHz dual
```

**Parameters:**
| Parameter | Description | Example |
|-----------|-------------|---------|
| `-input_freq` | Input clock (MHz) | `"50"`, `"100"` |
| `-output_freq` | Output clock (MHz) for single output | `"50"`, `"100"` |
| `-output0_freq` | Output 0 clock (MHz) for dual output | `"50"` |
| `-output1_freq` | Output 1 clock (MHz) for dual output | `"200"` |
| `-component_name` | Instance name | `"PF_CCC_C0"` |
| `-output_file` | Output TCL file | `"my_config.tcl"` |

**Output:**
Simplified `create_and_configure_core` TCL for PF_CCC.

**Example Output Summary:**
```
INFO: PLL Configuration
  VCO Frequency: 200 MHz (input 50 MHz × 4)
  Output 0: 200 MHz ÷ 4 = 50 MHz
  Output 1: 200 MHz ÷ 1 = 200 MHz
Generated CCC configuration: pf_ccc_miv_ddr.tcl
  Input: 50 MHz
  Output 0 (GL0_0): 50 MHz
  Output 1 (GL0_1): 200 MHz
```

**Note:** CCC configurations are simplified. For production use, verify in Libero GUI and tune PLL parameters for optimal jitter performance.

---

### 3. UART Configuration Generator (`uart_config_generator.tcl`)

**Purpose:** Generate CoreUARTapb (APB UART) IP core configurations with automatic baud rate calculation.

**Features:**
- Automatic baud rate divisor calculation with error checking
- Configurable data bits (7 or 8)
- Configurable parity (none, odd, even)
- RX/TX FIFO enable options
- Baud rate accuracy validation (warns if error > 2%)

**Usage:**
```tcl
source tcl_scripts/lib/generators/uart_config_generator.tcl

# Method 1: Full parameter control
generate_uart_config \
    -sys_clk_hz "50000000" \
    -baud_rate "115200" \
    -data_bits "8" \
    -parity "none" \
    -rx_fifo "1" \
    -tx_fifo "1" \
    -component_name "CoreUARTapb_C0" \
    -output_file "my_uart.tcl"

# Method 2: Convenience functions
generate_uart_115200 "CoreUARTapb_C0" "uart_115200.tcl"     # Standard 115200 baud
generate_uart_9600 "CoreUARTapb_C0" "uart_9600.tcl"         # 9600 baud
generate_uart_460800 "CoreUARTapb_C0" "uart_460800.tcl"     # High-speed 460800
generate_uart_custom "CoreUARTapb_C0" "uart_custom.tcl" 100000000 57600  # Custom clock/baud
```

**Parameters:**
| Parameter | Description | Example |
|-----------|-------------|---------|
| `-sys_clk_hz` | System clock frequency (Hz) | `"50000000"` (50 MHz) |
| `-baud_rate` | Target baud rate | `"115200"`, `"9600"`, `"57600"` |
| `-data_bits` | Data bits per frame | `"7"`, `"8"` |
| `-parity` | Parity mode | `"none"`, `"odd"`, `"even"` |
| `-rx_fifo` | RX FIFO enable | `"0"` (disabled), `"1"` (enabled) |
| `-tx_fifo` | TX FIFO enable | `"0"` (disabled), `"1"` (enabled) |
| `-component_name` | Instance name | `"CoreUARTapb_C0"` |
| `-output_file` | Output TCL file | `"my_config.tcl"` |

**Baud Rate Calculation:**
- Formula: `BAUD_VALUE = (SYS_CLK / (BAUD_RATE × 16)) - 1`
- Actual baud rate calculated and compared to target
- Warning issued if error > 2% (may cause communication issues)

**Output:**
Complete `create_and_configure_core` TCL for CoreUARTapb with 10 parameters.

**Example Output Summary:**
```
Generated UART configuration: uart_115200.tcl
  System Clock: 50000000 Hz
  Baud Rate: 115200 (actual: 115740, error: 0.47%)
  Data Bits: 8, Parity: none
  RX FIFO: enabled, TX FIFO: enabled
  BAUD_VALUE: 26
```

---

### 4. GPIO Configuration Generator (`gpio_config_generator.tcl`)

**Purpose:** Generate CoreGPIO (General Purpose I/O) IP core configurations for input/output/bidirectional pins.

**Features:**
- Supports 1-32 GPIO pins
- Configurable direction per configuration (all input, all output, all bidirectional)
- Customizable initial values for outputs
- Pattern generation for LED sequences
- Fixed configuration mode (compile-time direction)

**Usage:**
```tcl
source tcl_scripts/lib/generators/gpio_config_generator.tcl

# Method 1: Custom configuration
generate_gpio_config \
    -num_pins "8" \
    -direction "output" \
    -initial_values {0 1 0 1 0 1 0 1} \
    -component_name "CoreGPIO_LEDS" \
    -output_file "my_gpio.tcl"

# Method 2: Convenience functions
generate_gpio_leds "CoreGPIO_LEDS" "gpio_leds.tcl" 8        # 8 LED outputs
generate_gpio_buttons "CoreGPIO_BTN" "gpio_btn.tcl" 4       # 4 button inputs
generate_gpio_bidir "CoreGPIO_BID" "gpio_bidir.tcl" 8       # 8 bidirectional
generate_gpio_output_pattern "CoreGPIO_PAT" "gpio_pat.tcl" 4 {1 0 1 0}  # Custom pattern
```

**Parameters:**
| Parameter | Description | Example |
|-----------|-------------|---------|
| `-num_pins` | Number of GPIO pins (1-32) | `"8"`, `"16"`, `"32"` |
| `-direction` | Pin direction | `"input"`, `"output"`, `"bidir"` |
| `-initial_values` | Initial output values (list) | `{0 1 0 1}`, `{1 1 1 1}` |
| `-component_name` | Instance name | `"CoreGPIO_LEDS"` |
| `-output_file` | Output TCL file | `"my_config.tcl"` |

**Direction Mapping:**
- `input` → `IO_TYPE = 0` (input only)
- `output` → `IO_TYPE = 1` (output only)
- `bidir` → `IO_TYPE = 2` (bidirectional with software control)

**Output:**
Complete `create_and_configure_core` TCL for CoreGPIO with ~100 parameters (32 pins × 3 params each).

**Example Output Summary:**
```
Generated GPIO configuration: gpio_leds_8.tcl
  Pins: 8
  Direction: output
  Initial Values: [0, 1, 0, 1, 0, 1, 0, 1]
```

---

### 5. PCIe Configuration Generator (`pcie_config_generator.tcl`)

**Purpose:** Generate PF_PCIE (PCIe controller) configurations for endpoints and root ports.

**Features:**
- Template-based approach for 200+ parameter complexity
- Endpoint and Root Port configurations
- x1, x2, x4 lane support
- Gen1 (2.5 Gbps) and Gen2 (5.0 Gbps) speeds
- BAR0 configuration with customizable size
- Device ID and Vendor ID customization

**Usage:**
```tcl
source tcl_scripts/lib/generators/pcie_config_generator.tcl

# Method 1: Endpoint configuration
generate_pcie_endpoint \
    -num_lanes "1" \
    -speed "Gen1" \
    -bar0_size "4 KB" \
    -device_id "0x1556" \
    -vendor_id "0x11AA" \
    -component_name "PF_PCIE_EP" \
    -output_file "my_pcie_ep.tcl"

# Method 2: Root Port configuration
generate_pcie_root_port \
    -num_lanes "4" \
    -speed "Gen2" \
    -bar0_size "2 GB" \
    -component_name "PF_PCIE_RP" \
    -output_file "my_pcie_rp.tcl"

# Method 3: Convenience functions
generate_pcie_ep_x1_gen1 "PF_PCIE_EP" "pcie_ep_x1.tcl"      # Simple x1 endpoint
generate_pcie_ep_x4_gen2 "PF_PCIE_EP" "pcie_ep_x4.tcl"      # x4 Gen2 endpoint
generate_pcie_rp_x4_gen2 "PF_PCIE_RP" "pcie_rp_x4.tcl"      # x4 Gen2 root port
```

**Parameters:**
| Parameter | Description | Example |
|-----------|-------------|---------|
| `-num_lanes` | Number of PCIe lanes | `"1"`, `"2"`, `"4"` |
| `-speed` | PCIe generation | `"Gen1"` (2.5 Gbps), `"Gen2"` (5.0 Gbps) |
| `-bar0_size` | Base Address Register 0 size | `"4 KB"`, `"1 MB"`, `"2 GB"` |
| `-device_id` | PCIe device ID | `"0x1556"` |
| `-vendor_id` | PCIe vendor ID | `"0x11AA"` (Microchip) |
| `-ref_clk_freq` | Reference clock (MHz) | `"100"` |
| `-component_name` | Instance name | `"PF_PCIE_EP"` |
| `-output_file` | Output TCL file | `"my_config.tcl"` |

**Controller Architecture:**
- **PCIE_0**: Used for Endpoint configurations
- **PCIE_1**: Used for Root Port configurations
- BARs 1-5 disabled by default (only BAR0 active)
- MSI interrupts enabled (MSI1 for EP, MSI8 for RP)

**Output:**
Complete `create_and_configure_core` TCL for PF_PCIE with template-based configuration (~3000 bytes).

**Example Output Summary:**
```
Generated PCIe Endpoint configuration: pcie_ep_x1_gen1.tcl
  Lanes: x1
  Speed: Gen1 (2.5 Gbps)
  BAR0: 4 KB
  Device ID: 0x1556, Vendor ID: 0x11AA
```

**Note:** This generator provides simplified configurations for 80% of common use cases. For advanced features (multiple BARs, MSI-X, AER, hotplug, ASPM), use Libero GUI for full control.

---

## Pre-Generated Templates

Located in `tcl_scripts/lib/templates/`, ready to use:

### DDR4 Templates:
- `pf_ddr4_1gb_1600.tcl` - 1GB DDR4 @ 1600 Mbps, x16
- `pf_ddr4_2gb_1600.tcl` - 2GB DDR4 @ 1600 Mbps, x32
- `pf_ddr4_4gb_1600.tcl` - 4GB DDR4 @ 1600 Mbps, x32
- `pf_ddr4_4gb_2400.tcl` - 4GB DDR4 @ 2400 Mbps, x32 (high speed)

### PF_CCC Templates:
- `pf_ccc_miv_50mhz.tcl` - 50 MHz single output (standard MI-V)
- `pf_ccc_miv_ddr.tcl` - 50 MHz + 200 MHz dual output (MI-V + DDR)

### UART Templates:
- `uart_115200.tcl` - 115200 baud @ 50 MHz (standard debug console)
- `uart_9600.tcl` - 9600 baud @ 50 MHz (legacy devices)
- `uart_460800.tcl` - 460800 baud @ 50 MHz (high-speed, 13% error warning)
- `uart_57600.tcl` - 57600 baud @ 50 MHz
- `uart_115200_100mhz.tcl` - 115200 baud @ 100 MHz system clock

### GPIO Templates:
- `gpio_leds_8.tcl` - 8 LED outputs (alternating initial pattern)
- `gpio_buttons_4.tcl` - 4 button/switch inputs
- `gpio_bidir_8.tcl` - 8 bidirectional GPIO
- `gpio_pattern_4.tcl` - 4 outputs with custom 1010 pattern
- `gpio_max_32.tcl` - 32 outputs (maximum GPIO, 0x55555555 pattern)

### PCIe Templates:
- `pcie_ep_x1_gen1.tcl` - x1 Gen1 endpoint, 4 KB BAR0 (most common add-in card)
- `pcie_ep_x4_gen2.tcl` - x4 Gen2 endpoint, 1 MB BAR0 (high performance)
- `pcie_rp_x4_gen2.tcl` - x4 Gen2 root port, 2 GB BAR0 (host controller)
- `pcie_ep_custom.tcl` - x2 Gen1 endpoint with custom IDs (example)

---

## Complete Workflow Example: MI-V + DDR Project

### Step 1: Generate Clock Configuration
```tcl
source tcl_scripts/lib/generators/ccc_config_generator.tcl
generate_miv_ddr_ccc "PF_CCC_C1" "components/PF_CCC_C1.tcl"
```

### Step 2: Generate DDR4 Configuration
```tcl
source tcl_scripts/lib/generators/ddr4_config_generator.tcl
generate_mpf300_4gb_ddr4 "PF_DDR4_C0" "components/PF_DDR4_C0.tcl"
```

### Step 3: Use in Project Creation Script
```tcl
# In your project creation script:
source components/PF_CCC_C1.tcl        # Instantiates PF_CCC_C1
source components/PF_DDR4_C0.tcl       # Instantiates PF_DDR4_C0

# Then connect in SmartDesign...
open_smartdesign -sd_name {MyDesign}

# Add instances to SmartDesign
sd_inst_component -sd_name {MyDesign} -instance_name {PF_CCC_C1_0}
sd_inst_component -sd_name {MyDesign} -instance_name {PF_DDR4_C0_0}

# Connect clocks
sd_connect_pins -sd_name {MyDesign} \
    -pin_names {"PF_CCC_C1_0:OUT0_FABCLK_0" "MI_V_RV32:CLK"} \
    -pin_names {"PF_CCC_C1_0:OUT1_FABCLK_0" "PF_DDR4_C0_0:SYS_CLK"}
```

---

## Technical Background

### DDR4 Generator Architecture

The DDR4 generator uses intelligent calculation functions inspired by Microchip's `ddr_functions.tcl` library:

1. **Geometry Calculation**: Determines row/column/bank bits from total memory size
2. **Latency Selection**: Chooses CAS latency and write latency based on speed bin
3. **Timing Calculation**: Applies standard JEDEC DDR4 timing parameters
4. **Clock Configuration**: Calculates DDR PHY clock, AXI clock, and PLL multipliers

**Key Functions:**
- `calculate_address_bits {size width}` - Computes memory geometry
- `calculate_latency {speed_mbps}` - Selects latency based on speed grade
- `calculate_timing_params {speed_mbps}` - Applies JEDEC timing constraints

### PF_CCC Generator Architecture

The CCC generator uses template-based approach for reliability:

1. **Simplified Interface**: User specifies only frequencies, generator handles rest
2. **PLL Calculation**: Basic multiplier/divider math for common integer ratios
3. **Template Filling**: Pre-defined structures ensure valid configurations

**Design Philosophy:**
- Complex PLL math (VCO tuning, jitter optimization) left to Libero GUI
- Generators produce working configurations for common cases
- Users can refine in GUI for production

---

## Resources Used

### Microchip Libraries:
- `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/data/aPA5M/cores/MSS/TCL/ddr_functions.tcl`
  - 1850+ lines of DDR timing calculation functions
  - Address mapping utilities
  - JEDEC compliance functions

### Documentation:
- `docs/DDR_CONFIGURATION_ANALYSIS.md` - Complete DDR4 parameter breakdown
- PolarFire Memory Controller User Guide (11MB PDF in ~/fpga_mcp/)
- PolarFire Clocking Resources User Guide (1.3MB PDF in ~/fpga_mcp/)
- CoreUARTapb Handbook (searched via web)
- Application Note AN4597 - PCIe + DDR4 integration

### Reference Designs:
- Existing MI-V RV32 projects in `hdl/miv_polarfire_eval/`
- SmartHLS DDR examples in Libero installation
- SmartHLS MI-V SoC reference designs:
  - `/mnt/c/Microchip/Libero_SoC_v2024.2/SmartHLS-2024.2/SmartHLS/reference_designs/MiV_SoC/ref_design/base_project_setup_scripts/components/CoreUARTapb_C0.tcl`
  - `/mnt/c/Microchip/Libero_SoC_v2024.2/SmartHLS-2024.2/SmartHLS/reference_designs/MiV_SoC/ref_design/base_project_setup_scripts/components/CoreGPIO_OUT.tcl`
  - `/mnt/c/Microchip/Libero_SoC_v2024.2/SmartHLS-2024.2/SmartHLS/reference_designs/Icicle_SoC/ref_design/script_support/components/PF_PCIE_C0.tcl`

---

## Limitations and Future Enhancements

### Current Limitations:
- **DDR4 only**: No DDR3, LPDDR3, LPDDR4 support yet
- **Standard timing only**: No support for custom timing tuning
- **No ECC**: Error correction code generation not yet implemented
- **Simplified CCC**: Complex PLL features (SSM, dynamic reconfig) not exposed
- **PCIe Gen2 max**: No Gen3/Gen4 support (hardware limitation of PolarFire)
- **Fixed GPIO direction**: All pins in configuration share same direction (no per-pin mixed)
- **UART basic features**: No 9-bit mode, auto-baud, or flow control
- **PCIe advanced features**: Multiple BARs, MSI-X, AER, hotplug require GUI

### Planned Enhancements (Future):
1. **DDR3/LPDDR support** - Extend generator to other memory types
2. **Memory part number parser** - Input Micron/Samsung part numbers directly
3. **App note ingestion** - Parse Microchip app notes for working configs
4. **Advanced CCC features** - SSM, phase shifting, dynamic reconfiguration
5. **Validation** - Check parameters against datasheet limits
6. **GUI integration** - Launch Libero GUI with generated config for tuning
7. **Additional IP cores** - SPI, I2C, CAN, Ethernet, SERDES generators
8. **Mixed GPIO** - Support per-pin direction configuration
9. **UART flow control** - RTS/CTS hardware flow control option
10. **PCIe advanced configs** - Multi-BAR, MSI-X, AER templates

---

## Testing

Test scripts are provided to verify generator functionality:

```bash
# Test DDR4 generator
./run_libero.sh tcl_scripts/test_ddr4_generator.tcl SCRIPT

# Test CCC generator
./run_libero.sh tcl_scripts/test_ccc_generator.tcl SCRIPT

# Test UART and GPIO generators
tclsh tcl_scripts/test_uart_gpio_generators.tcl

# Test PCIe generator
tclsh tcl_scripts/test_pcie_generator.tcl
```

All tests generate configurations in `tcl_scripts/lib/templates/` and display summaries with validation results.

---

## Contributing

To add a new IP core generator:

1. Analyze the IP core's TCL export format
2. Identify key parameters and their relationships
3. Create `<ipcore>_config_generator.tcl` in this directory
4. Implement parameter calculation logic
5. Provide convenience functions for common cases
6. Add tests to verify output
7. Document in this README

---

## License

Part of TCL Monster project. See main project README for license information.

---

**Last Updated:** 2025-10-23
**Author:** TCL Monster Development Team
**Contact:** See project README for support information
