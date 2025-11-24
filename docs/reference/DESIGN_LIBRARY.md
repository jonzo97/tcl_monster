# Design Library Catalog

**Purpose:** Comprehensive catalog of validated FPGA designs with resource usage, complexity, and reuse guidance

**Last Updated:** 2025-10-22

---

## Library Organization

```
examples/
├── basic/           # Simple designs for learning and testing
├── communication/   # Serial protocols (UART, SPI, I2C)
├── advanced/        # Complex designs with IP cores
└── app_notes/       # Recreated Microchip application notes
```

---

## Basic Designs

### Counter with Rotating LEDs ✅ COMPLETE
**Status:** Validated, synthesized on MPF300TS

**Description:** Simple binary counter with clock divider, drives 8 LEDs in rotating pattern

**Files:**
- HDL: `hdl/counter.v`
- Constraints: `constraint/io_constraints.pdc`
- Project: Created by `tcl_scripts/create_project.tcl`

**Features:**
- 50 MHz clock input
- Active-low reset
- 24-bit counter with overflow-driven LED rotation
- Parameterizable counter width

**Resource Usage (MPF300TS):**
- 4LUT: 33 (0.01%)
- DFF: 32 (0.01%)
- I/O: 10

**Timing:**
- Clock: 50 MHz
- Max Frequency: TBD (add timing constraints)
- Critical Path: TBD

**Reuse Guidance:**
- Excellent starting template for any LED-based design
- Demonstrates clock domain, reset, and I/O structure
- Good for board bring-up and validation

**Next Steps:**
- Add timing constraints (SDC)
- Lock I/O pins
- Test on hardware

---

### Blinky (LED Heartbeat)
**Status:** Planned

**Description:** Ultra-simple design that blinks single LED at 1 Hz

**Planned Features:**
- Single LED output
- Minimal resource usage
- Board bring-up validation

**Target Resource Usage:** <10 LUTs

---

## Communication Designs

### UART Transceiver
**Status:** Planned

**Description:** Full-duplex UART with configurable baud rate

**Planned Features:**
- Configurable baud rate (9600, 115200, etc.)
- 8N1 format (8 data bits, no parity, 1 stop bit)
- TX/RX FIFOs for buffering
- Error detection (framing errors)

**Anticipated Resource Usage:** ~100-200 LUTs

**Applications:**
- Serial terminal communication
- Debug console
- Sensor data logging

---

### SPI Master/Slave
**Status:** Planned

**Description:** SPI controller for flash memory, sensors, DACs

**Planned Features:**
- Mode 0/1/2/3 support
- Configurable clock speed
- Multi-slave support with CS
- CPOL/CPHA configuration

**Anticipated Resource Usage:** ~150-250 LUTs

**Applications:**
- Flash memory access
- ADC/DAC interfaces
- SD card communication

---

### I2C Master
**Status:** Planned

**Description:** I2C master for sensor communication

**Planned Features:**
- Standard mode (100 kHz)
- Fast mode (400 kHz)
- Multi-master arbitration
- Clock stretching support

**Anticipated Resource Usage:** ~100-150 LUTs

**Applications:**
- Temperature sensors
- EEPROMs
- Real-time clocks (RTCs)

---

### PWM Controller
**Status:** Planned

**Description:** Multi-channel PWM with deadband insertion

**Planned Features:**
- Configurable frequency and duty cycle
- Deadband insertion (for motor control)
- Multiple independent channels
- Synchronized or phase-shifted outputs

**Anticipated Resource Usage:** ~50-100 LUTs per channel

**Applications:**
- Motor control (BLDC, stepper)
- LED dimming
- Power supply control

---

## Advanced Designs

### Multi-Clock Domain Design
**Status:** Planned

**Description:** Demonstrates clock domain crossing (CDC) best practices

**Planned Features:**
- Multiple independent clock domains
- Asynchronous FIFOs for safe CDC
- Gray code counters
- Metastability mitigation

**Anticipated Resource Usage:** ~300-500 LUTs

**Learning Topics:**
- CDC challenges and solutions
- Asynchronous FIFO design
- Timing constraint strategies

---

### DDR Memory Controller Integration
**Status:** Planned

**Description:** Integrate Microchip DDR3/DDR4 memory controller IP

**Planned Features:**
- DDR3 or DDR4 support
- AXI interface
- Read/write test patterns
- Performance benchmarking

**Anticipated Resource Usage:** Varies by DDR type

**Applications:**
- High-bandwidth data buffering
- Image processing
- Video frame buffers

---

### PCIe Endpoint Example
**Status:** Planned

**Description:** PCIe Gen3 x4 endpoint with DMA

**Planned Features:**
- PCIe Gen3 x4
- DMA engine for high-throughput transfers
- BAR space configuration
- MSI/MSI-X interrupts

**Anticipated Resource Usage:** Significant (IP core intensive)

**Applications:**
- Host communication
- High-speed data acquisition
- FPGA acceleration cards

---

### RISC-V SoC Integration
**Status:** Planned

**Description:** Soft RISC-V processor (e.g., VexRiscv) with peripherals

**Planned Features:**
- RISC-V RV32I core
- Memory-mapped peripherals (UART, GPIO, SPI)
- Bootloader and software examples
- GCC toolchain integration

**Anticipated Resource Usage:** ~5000-10000 LUTs (depends on config)

**Applications:**
- Embedded control systems
- Soft-core prototyping
- Custom ISA extensions

---

### SmartDesign IP Core Integration (PolarFire SoC)
**Status:** Planned

**Description:** Microchip Subsystem (MSS) integration with fabric logic

**Planned Features:**
- MSS configuration (clocks, I/O, peripherals)
- Fabric-to-MSS interconnect (APB, AXI)
- Interrupt handling
- Linux boot (optional)

**Anticipated Resource Usage:** Depends on MSS config

**Applications:**
- Embedded Linux systems
- Hard processor + FPGA fabric co-design

---

## Application Note Recreations

*This section will be populated as we recreate Microchip application notes*

### Planned Application Notes:
- UART Designs
- SPI Flash Programming
- DDR Memory Interface
- Motor Control (BLDC, Stepper)
- High-Speed SerDes Examples

---

## Design Complexity Matrix

| Design | Complexity | Resource Usage | Development Time | Hardware Test |
|--------|------------|----------------|------------------|---------------|
| Counter (Rotating LEDs) | ★☆☆☆☆ | 33 LUTs | ✅ Complete | Pending |
| Blinky | ★☆☆☆☆ | <10 LUTs | 10 min | N/A |
| UART Transceiver | ★★☆☆☆ | ~150 LUTs | 1 hour | Required |
| SPI Master | ★★☆☆☆ | ~200 LUTs | 1 hour | Required |
| I2C Master | ★★☆☆☆ | ~150 LUTs | 1 hour | Required |
| PWM Controller | ★★☆☆☆ | ~100 LUTs | 45 min | Required |
| Multi-Clock CDC | ★★★☆☆ | ~400 LUTs | 2 hours | Recommended |
| DDR Controller | ★★★★☆ | Varies | 3 hours | Required |
| PCIe Endpoint | ★★★★★ | Large | 4 hours | Required |
| RISC-V SoC | ★★★★☆ | ~8000 LUTs | 4 hours | Required |

---

## Design Selection Guide

### For Board Bring-Up:
- Start with **Blinky** or **Counter** to validate clock, reset, I/O

### For Communication:
- **UART**: Terminal/debug console
- **SPI**: Flash, ADC/DAC, high-speed peripherals
- **I2C**: Sensors, EEPROMs, low-speed peripherals

### For Learning:
- **Counter**: Basic structure and timing
- **Multi-Clock CDC**: Clock domain crossing best practices
- **RISC-V SoC**: Soft processor integration

### For Production:
- Start with validated app note recreations
- Customize for specific board/requirements

---

## Contribution Guidelines

### Adding a New Design:
1. Create directory under appropriate category (`examples/basic/`, etc.)
2. Include:
   - HDL source files
   - Testbench
   - Constraints (PDC, SDC)
   - README with description, features, resource usage
3. Synthesize and document results
4. Update this catalog

### Design Quality Checklist:
- [ ] Synthesizes without errors/warnings
- [ ] Testbench validates functionality
- [ ] Timing constraints included
- [ ] Resource usage documented
- [ ] README with reuse guidance
- [ ] (Optional) Hardware validated

---

**Maintained by:** TCL Monster Project | **Last Updated:** 2025-10-22
