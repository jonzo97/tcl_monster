# BeagleV-Fire Custom FPGA Designs Guide

**Created:** 2025-11-12 (Autonomous Session)
**Status:** Design library created, ready for integration testing
**Purpose:** Rapid prototyping designs for BeagleV-Fire FPGA fabric

---

## Overview

This guide documents custom FPGA fabric designs created for BeagleV-Fire rapid prototyping and testing. Designs range from simple LED blinkers to MSS-integrated GPIO controllers.

**Design Philosophy:**
- Start simple (LED blink) → gradually increase complexity
- Test MSS-fabric integration incrementally
- Provide reusable building blocks for future projects

---

## Design Library

### 1. LED Blinker (Fabric Standalone)

**File:** `hdl/beaglev_fire/led_blinker_fabric.v`
**Complexity:** Minimal (~50 LUTs, 26 FFs)

**Description:**
Simple 1 Hz LED blink using pure FPGA fabric logic. No MSS interaction - standalone test of fabric functionality.

**Features:**
- 50 MHz clock input from FIC
- 26-bit counter for 1 Hz toggle
- Single LED output

**Use Cases:**
- Verify FPGA fabric is programmed correctly
- Test clock distribution
- Visual "hello world" for gateware

**Integration:**
```tcl
# In SmartDesign or TCL script
import_files -hdl_source {hdl/beaglev_fire/led_blinker_fabric.v}
# Connect clk_50mhz to CCC output
# Connect rst_n to MSS reset
# Connect led to top-level pin (see constraint file)
```

**Constraints:** `constraint/beaglev_fire_led_blink.pdc`

**Next Steps:**
- Update PDC with actual BeagleV-Fire LED pin
- Add to tcl_monster build variant

---

### 2. GPIO Controller (APB Interface)

**File:** `hdl/beaglev_fire/gpio_controller.v`
**Complexity:** Low (~200 LUTs, 50 FFs)

**Description:**
8-bit bidirectional GPIO controller with APB slave interface. Memory-mapped from MSS software.

**Features:**
- APB interface (connects to MSS FIC)
- 8 bidirectional GPIO pins
- Direction control per pin
- Memory-mapped registers:
  - `0x00`: GPIO_DATA (R/W data)
  - `0x04`: GPIO_DIR (R/W direction, 0=in, 1=out)
  - `0x08`: GPIO_IN (Read input values)

**Use Cases:**
- GPIO expansion beyond MSS GPIO
- Test MSS-fabric APB communication
- Foundation for custom peripherals

**Integration:**
```tcl
# Add as APB slave in SmartDesign
# Configure FIC to expose APB bus
# Map to address range (e.g., 0x7000_0000)
```

**Software Access (C):**
```c
#define GPIO_BASE 0x70000000
#define GPIO_DATA (*(volatile uint32_t*)(GPIO_BASE + 0x00))
#define GPIO_DIR  (*(volatile uint32_t*)(GPIO_BASE + 0x04))
#define GPIO_IN   (*(volatile uint32_t*)(GPIO_BASE + 0x08))

// Set GPIO[0] as output, high
GPIO_DIR = 0x01;
GPIO_DATA = 0x01;
```

**Constraints:** TBD (8 GPIO pins to cape connector)

---

### 3. PWM Controller (LED Dimming)

**File:** `hdl/beaglev_fire/pwm_controller.v`
**Complexity:** Minimal (~30 LUTs, 10 FFs)

**Description:**
8-bit PWM generator for variable LED brightness.

**Features:**
- 8-bit duty cycle input (0-255)
- Configurable PWM frequency (default: ~195 kHz at 50 MHz clk)
- Single PWM output

**Use Cases:**
- LED dimming / brightness control
- Motor speed control (with driver)
- Analog signal generation via RC filter

**Integration:**
- Can be standalone (fixed duty cycle) or APB-connected (software control)

---

### 4. LED Pattern FSM (State Machine Demo)

**File:** `hdl/beaglev_fire/led_pattern_fsm.v`
**Complexity:** Low (~100 LUTs, 20 FFs)

**Description:**
4-LED sequential pattern generator using finite state machine.

**Features:**
- 2 patterns: chase (sequential) and blink-all
- Pattern selection via input pin or APB register
- ~0.33 sec timing between states

**Use Cases:**
- Visual debugging (pattern indicates system state)
- FSM demonstration
- Bootup indicator

**Patterns:**
- **Chase:** LEDs light sequentially (0001 → 0010 → 0100 → 1000 → repeat)
- **Blink All:** All LEDs toggle together

---

## Build Variants Configuration

**File:** `config/beaglev_fire_custom_designs.json`

Defines custom build configurations combining reference designs with custom HDL.

**Example Variants:**

### Variant: `led_blink_only`
- **Base:** minimal.yaml
- **Custom HDL:** led_blinker_fabric.v
- **Description:** Minimal MSS + LED blink fabric
- **Build Time:** ~15 minutes

### Variant: `gpio_expansion`
- **Base:** default.yaml
- **Custom HDL:** gpio_controller.v
- **MSS Integration:** APB slave at 0x7000_0000
- **Description:** Full design + 8-bit GPIO expansion
- **Build Time:** ~40 minutes

### Variant: `pwm_demo`
- **Base:** default.yaml
- **Custom HDL:** pwm_controller.v
- **Description:** Full design + PWM LED dimming
- **Build Time:** ~40 minutes

---

## Test Progression Strategy

Incremental testing approach:

**Phase 1: Standalone Fabric (No MSS)**
1. LED blink fabric → Verify FPGA works, clock distribution OK
2. PWM controller (fixed duty) → Verify timing, clock accuracy

**Phase 2: MSS Integration (APB)**
3. GPIO controller → Verify FIC, APB communication, memory-mapped access
4. Software-controlled PWM → Verify write operations to fabric

**Phase 3: Complex Peripherals**
5. UART loopback (fabric) → Verify serial, independent of MSS UART
6. SPI/I2C masters → Verify protocol implementation

**Phase 4: Hardware Acceleration**
7. Multiply-accumulate unit → Verify performance improvement
8. Custom DSP functions → Measure speedup vs. software

---

## Creating New Designs

### Template for New HDL Module

```verilog
// [Module Name] - [Brief Description]
// Target: BeagleV-Fire MPFS025T

module my_new_module (
    // APB interface (if MSS-connected)
    input  wire        pclk,
    input  wire        presetn,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] paddr,
    input  wire [31:0] pwdata,
    output reg  [31:0] prdata,
    output wire        pready,
    output wire        pslverr,

    // Custom I/O
    input  wire        custom_input,
    output reg         custom_output
);

    // Module logic here

endmodule
```

### Integration Checklist

- [ ] Create Verilog/VHDL module in `hdl/beaglev_fire/`
- [ ] Create pin constraints in `constraint/`
- [ ] Add to `config/beaglev_fire_custom_designs.json`
- [ ] Create SmartDesign instantiation TCL (if complex)
- [ ] Document register map (if APB/AXI)
- [ ] Write software driver/test code (if MSS-connected)
- [ ] Test with simulation (ModelSim) before hardware
- [ ] Build and test on hardware
- [ ] Document in this guide

---

## Future Designs (Roadmap)

### Near-term (1-2 sessions)
- **UART loopback** - Serial echo in fabric
- **Button debouncer** - Clean input signal conditioning
- **Seven-segment display driver** - BCD to 7-segment decoder

### Medium-term (3-5 sessions)
- **SPI master** - Custom SPI controller for sensors
- **I2C master** - I2C bus master for external devices
- **Timer with IRQ** - Generate interrupts to MSS
- **AXI4 peripheral** - High-performance memory-mapped device

### Long-term (10+ sessions)
- **Hardware MAC** - Multiply-accumulate for DSP
- **Custom crypto engine** - AES accelerator
- **Video pattern generator** - Test display interfaces
- **PCIe endpoint** - Custom PCIe peripheral via M.2

---

## Resources

**Design Files:**
- HDL: `hdl/beaglev_fire/`
- Constraints: `constraint/`
- Config: `config/beaglev_fire_custom_designs.json`

**Reference:**
- PolarFire FPGA Fabric User Guide: (use fpga_mcp RAG)
- APB Protocol Spec: ARM IHI 0024C
- MSS FIC Documentation: PolarFire SoC docs

**Companion Guides:**
- `docs/beaglev_fire_guide.md` - FPGA build process (Phase 1 complete)
- `docs/beaglev_fire_hardware_setup.md` - Hardware connection & embedded dev

---

**Document Version:** 1.0
**Created:** 2025-11-12 (Autonomous session while user at gym!)
**Last Updated:** 2025-11-12
