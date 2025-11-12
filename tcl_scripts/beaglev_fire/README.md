# BeagleV-Fire TCL Scripts

TCL scripts for creating and managing Libero projects for the BeagleV-Fire board.

## Board Specifications

**BeagleV-Fire** - Open-source single-board computer with PolarFire SoC FPGA

### Hardware Details
- **FPGA Device:** MPFS025T-FCVG484E (PolarFire SoC)
- **CPU Cores:** 5x RISC-V (4x U54 application cores @ 625 MHz + 1x E51 monitor core)
- **FPGA Fabric:** 23,000 logic elements, 68 math blocks (18x18 MACC)
- **Memory:** 1.8 Mb embedded RAM, 2GB LPDDR4 external
- **Storage:** 16GB eMMC, 128Mbit SPI Flash
- **SerDes:** 4 lanes @ 12.7 Gbps (supports 2x PCIe Gen2)
- **I/O:** 108 FPGA I/O pins (HSIO + GPIO)

### Peripherals
- **Networking:** 2x Gigabit Ethernet MACs
- **USB:** USB 2.0 OTG
- **Serial:** 5x multi-mode UARTs
- **Protocols:** 2x SPI, 2x I2C, 2x CAN 2.0
- **PCIe:** 2x Gen2 endpoints/root ports
- **Expansion:** SYZYGY connector, M.2 E-Key socket, 2x BeagleBone cape headers

## Scripts

### create_minimal_project.tcl
Creates a minimal PolarFire SoC project configured for the BeagleV-Fire board.

**Usage:**
```bash
./run_libero.sh tcl_scripts/beaglev_fire/create_minimal_project.tcl SCRIPT
```

**What it does:**
- Creates a new Libero project with BeagleV-Fire device configuration
- Configures PolarFire SoC MPFS025T with correct package and speed grade
- Sets up voltage and temperature range options
- Prepares project for MSS configuration and FPGA fabric design

**Next steps after running:**
1. Open project in Libero GUI (optional)
2. Configure MSS (Microprocessor Subsystem) using Tools → MSS Configurator
3. Add custom FPGA fabric logic (SmartDesign or HDL)
4. Import pin constraints for board interfaces
5. Run synthesis and place & route

## Reference Design

The official BeagleV-Fire gateware repository contains a complete reference design:

**Repository:** https://git.beagleboard.org/beaglev-fire/gateware

The reference design includes:
- Complete MSS configuration for BeagleV-Fire
- HSS (Hart Software Services) bootloader integration
- FPGA fabric designs for cape support (default, comms, robotics, etc.)
- Pin constraints for all board interfaces
- Build automation with Python + YAML configuration

**Cloned locally:** `../../../beaglev-fire-gateware/`

### Using the Full Reference Design

To use the complete reference design with all peripherals:

```bash
cd ../../../beaglev-fire-gateware

# Install prerequisites
pip3 install gitpython pyyaml

# Set environment variables (adjust paths for your installation)
export LIBERO_INSTALL_DIR=/mnt/c/Microchip/Libero_SoC_v2024.2
export SC_INSTALL_DIR=/mnt/c/Microchip/SoftConsole-v2022.2-7.0.0.599
export FPGENPROG=/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin
export LM_LICENSE_FILE=<your_license_file>

# Build default configuration
python3 build-bitstream.py ./build-options/default.yaml
```

## Configuration File

Project parameters are defined in:
- **JSON Config:** `../../config/beaglev_fire_config.json`

This can be used for programmatic project generation or documentation.

## Resources

- **BeagleV-Fire Homepage:** https://www.beagleboard.org/boards/beaglev-fire
- **Documentation:** https://docs.beagle.cc/boards/beaglev/fire/
- **Gateware Repo:** https://git.beagleboard.org/beaglev-fire/gateware
- **GitHub Mirror:** https://github.com/beagleboard/beaglev-fire
- **Microchip PolarFire SoC:** https://www.microchip.com/en-us/product/mpfs025t

## Design Approach

### Option 1: Minimal Project (Current Script)
- Start with empty PolarFire SoC project
- Manually configure MSS
- Add custom FPGA fabric logic
- Good for: Learning, custom designs from scratch

### Option 2: Reference Design Modification
- Clone official gateware repository
- Modify existing design
- Leverage pre-configured MSS and constraints
- Good for: Board bring-up, cape integration, production designs

### Option 3: Hybrid Approach
- Use minimal project script to create base
- Import MSS configuration from reference design
- Import constraints from reference design
- Add custom FPGA fabric modules
- Good for: Custom peripherals while maintaining board compatibility

## Known Device Differences

**BeagleV-Fire vs MPF300 Eval Kit:**

| Feature | BeagleV-Fire | MPF300 Eval Kit |
|---------|--------------|-----------------|
| Device | MPFS025T (SoC) | MPF300TS (FPGA) |
| CPU | 5x RISC-V cores | None (pure FPGA) |
| Logic Elements | 23K | 300K |
| Math Blocks | 68 | 924 |
| SerDes Lanes | 4 | 16 |
| Package | FCVG484 | FCG1152 |
| Memory | 2GB LPDDR4 | DDR3/DDR4 slots |
| Use Case | Embedded Linux + FPGA | High-performance FPGA |

The BeagleV-Fire is optimized for embedded Linux applications with FPGA acceleration, while the MPF300 is for pure FPGA designs.

## MSS Configuration

The MSS (Microprocessor Subsystem) in PolarFire SoC includes:
- RISC-V CPU cores and cache
- Memory controllers (DDR, eNVM)
- Peripheral controllers (Ethernet, USB, UART, etc.)
- Fabric Interface Controllers (FIC) for AXI communication with FPGA fabric

**To configure MSS:**
1. Tools → MSS Configurator (in Libero GUI)
2. Configure peripherals, clocks, and FIC interfaces
3. Export configuration as .cxz file
4. Import into project with `import_mss_component`

The reference design includes pre-configured MSS files optimized for the BeagleV-Fire board.
