# RISC-V + DDR Design Plan

**Target Platform:** PolarFire MPF300 Eval Kit (MPF300TS-FCG1152)
**Use Case:** Bare-metal embedded control
**Status:** Planning phase
**Last Updated:** 2025-10-22

---

## Overview

This document outlines the plan for implementing a RISC-V processor with memory interface on the MPF300 eval kit using soft IP cores in the FPGA fabric.

**Key Goals:**
- Lightweight RISC-V processor for embedded control tasks
- Memory interface (DDR3/DDR4 or SRAM)
- Peripheral set (UART, GPIO, SPI, I2C)
- Bare-metal firmware support
- Demonstrable on MPF300 hardware

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PolarFire MPF300TS FPGA                  │
│                                                               │
│  ┌──────────────┐         ┌─────────────┐                    │
│  │              │  AXI/   │             │                    │
│  │  RISC-V Core │◄───────►│ Memory      │◄──┐                │
│  │  (PicoRV32)  │         │ Controller  │   │                │
│  │              │         │ (DDR3/SRAM) │   │  External      │
│  └──────┬───────┘         └─────────────┘   │  Memory        │
│         │                                    │                │
│         │ AXI/Wishbone                       │                │
│         │                                    │                │
│  ┌──────▼──────────────────────────────┐    │                │
│  │    Peripheral Interconnect           │    │                │
│  │    (AXI Crossbar / Wishbone Bus)     │    │                │
│  └──┬───┬───┬───┬───┬───────────────────┘    │                │
│     │   │   │   │   │                        │                │
│  ┌──▼─┐ │   │   │   │                        │                │
│  │UART│ │   │   │   │                        │                │
│  └────┘ │   │   │   │                        │                │
│      ┌──▼┐  │   │   │                        │                │
│      │GPIO│ │   │   │                        │                │
│      └────┘ │   │   │                        │                │
│          ┌──▼┐  │   │                        │                │
│          │SPI│  │   │                        │                │
│          └────┘ │   │                        │                │
│              ┌──▼┐  │                        │                │
│              │I2C│  │                        │                │
│              └────┘ │                        │                │
│                  ┌──▼─────┐                  │                │
│                  │ Timer  │                  │                │
│                  └────────┘                  │                │
│                                               │                │
│  I/O Pins: UART TX/RX, GPIO, SPI, I2C        ├────────────────┘
└───────────────────────────────────────────────┘
```

---

## Component Selection

### 1. RISC-V Core

**Recommended: PicoRV32**

**Pros:**
- Lightweight: ~1k-2k LUTs depending on configuration
- Well-documented, mature codebase
- MIT license (free, permissive)
- Excellent bare-metal support
- Configurable features (multiply, compressed instructions, etc.)
- Active community

**Cons:**
- No MMU (not Linux-capable, but not needed for bare-metal)
- Lower performance vs. larger cores

**Alternative: VexRiscv**
- More configurable
- Can be larger or smaller than PicoRV32
- SpinalHDL-based (may be harder to modify)
- Better performance options

**Configuration:**
- RV32I base ISA (32-bit RISC-V integer)
- RV32IM (add multiply/divide extension) - recommended
- RV32IMC (add compressed instructions) - saves code size
- ~100 MHz target frequency on PolarFire

**Repository:**
- PicoRV32: https://github.com/YosysHQ/picorv32
- VexRiscv: https://github.com/SpinalHDL/VexRiscv

---

### 2. Memory Controller

**Option A: External DDR3 Controller (Complex)**

**Microchip DDR3 IP:**
- Check if available for regular PolarFire (may be PolarFire SoC only)
- Requires external DDR3 chip on eval kit
- High bandwidth (useful for data buffering)
- Resource intensive (~5k-10k LUTs)

**Considerations:**
- Does MPF300 eval kit have DDR3 chip populated?
- Pin constraints complex (DQ, DQS, address, command groups)
- Timing critical

**Option B: External SRAM Interface (Simpler)**

**Pros:**
- Much simpler interface (address, data, control signals)
- Lower resource usage (~500-1k LUTs)
- Easier timing constraints
- Sufficient for embedded control (128KB-512KB)

**Cons:**
- Lower capacity than DDR
- Lower bandwidth

**Option C: On-Chip Memory Only (Simplest)**

**Pros:**
- No external components needed
- Very fast access
- Minimal resource usage
- Perfect for code + small data

**Cons:**
- Limited capacity (PolarFire has ~8Mb LSRAM = 1MB max)
- No persistence across power cycles

**Recommendation for Prototyping:**
- Start with **Option C** (on-chip SRAM) for initial bringup
- Add **Option B** (external SRAM) if more memory needed
- Only pursue **Option A** (DDR3) if high bandwidth required

---

### 3. Peripheral Set

**Required Peripherals:**
- **UART**: Serial console for debugging and communication
- **GPIO**: LED control, button input, general I/O
- **Timer**: Timing functions, delays, interrupts

**Optional Peripherals:**
- **SPI**: Flash memory, sensors, DACs
- **I2C**: Sensor communication, EEPROMs
- **PWM**: Motor control, LED dimming

**Implementation:**
- Use open-source IP cores from GitHub/OpenCores
- Or implement simple peripherals in Verilog (UART, GPIO are straightforward)

---

## Resource Estimates

### Baseline (PicoRV32 + On-Chip SRAM + Basic Peripherals)

| Component | LUTs | FFs | RAM Blocks | Comments |
|-----------|------|-----|------------|----------|
| PicoRV32 (RV32IM) | ~2000 | ~1500 | 0 | Core only |
| On-chip memory (32KB code + 32KB data) | ~500 | ~200 | 16 | Using LSRAM |
| UART | ~200 | ~100 | 0 | Simple implementation |
| GPIO (32 pins) | ~100 | ~50 | 0 | Trivial |
| Timer (32-bit x2) | ~100 | ~100 | 0 | Two timers |
| AXI Interconnect | ~500 | ~300 | 0 | Crossbar for peripherals |
| **Total** | **~3400** | **~2250** | **16** | **~1.1% of MPF300TS** |

### With External SRAM Controller

| Additional Component | LUTs | FFs | RAM Blocks |
|-----------|------|-----|------------|
| SRAM Controller | ~800 | ~400 | 0 |
| **New Total** | **~4200** | **~2650** | **16** |

### With DDR3 Controller (Hypothetical)

| Additional Component | LUTs | FFs | RAM Blocks |
|-----------|------|-----|------------|
| DDR3 Controller | ~8000 | ~5000 | 4 |
| **New Total** | **~11400** | **~7250** | **20** |

**Conclusion:** Even with DDR3, design would use <4% of MPF300TS resources. Plenty of headroom!

---

## Memory Map (Proposed)

```
0x00000000 - 0x00007FFF : Boot ROM (32KB, on-chip SRAM)
0x00008000 - 0x0000FFFF : Data RAM (32KB, on-chip SRAM)
0x40000000 - 0x4000000F : UART0 Registers
0x40000010 - 0x4000001F : GPIO Registers
0x40000020 - 0x4000002F : Timer0 Registers
0x40000030 - 0x4000003F : Timer1 Registers
0x40000040 - 0x4000004F : SPI0 Registers (optional)
0x40000050 - 0x4000005F : I2C0 Registers (optional)
0x80000000 - 0x8FFFFFFF : External memory (if SRAM/DDR added)
```

**Notes:**
- Boot ROM contains firmware (loaded at programming time)
- Data RAM for variables, stack, heap
- Peripherals memory-mapped for easy access
- External memory optional, large address space reserved

---

## Development Phases

### Phase 1: RISC-V Core Integration (~3-4 hours)

**Tasks:**
1. **Acquire PicoRV32 RTL** (~15 min)
   - Clone from GitHub
   - Review documentation
   - Choose configuration (RV32IMC recommended)

2. **Import into Libero** (~30 min)
   - Add PicoRV32 Verilog files to `hdl/riscv/`
   - Create Libero project
   - Compile and verify syntax

3. **Create Simple Testbench** (~1 hour)
   - Instantiate core with clock and reset
   - Add small boot ROM (simple program: blink LED)
   - Simulate in ModelSim
   - Verify instruction fetch and execution

4. **Synthesize for MPF300** (~1 hour)
   - Run synthesis
   - Check resource usage
   - Verify timing at target frequency (100 MHz)

### Phase 2: Memory Integration (~2-3 hours)

**Tasks:**
1. **On-Chip Memory** (~1 hour)
   - Instantiate PolarFire LSRAM blocks
   - Create memory controller wrapper
   - Connect to RISC-V memory interface

2. **Memory Initialization** (~30 min)
   - Create boot ROM image (hex file)
   - Load into memory at synthesis time
   - Simple program: infinite loop or LED blink

3. **Test Memory Access** (~1 hour)
   - Simulate read/write operations
   - Verify instruction fetch from ROM
   - Verify data writes to RAM

### Phase 3: Peripheral Integration (~2-3 hours)

**Tasks:**
1. **UART Controller** (~1 hour)
   - Use open-source UART core or implement simple version
   - Memory-map registers (TX data, RX data, status, baud config)
   - Test transmission and reception

2. **GPIO Controller** (~30 min)
   - Simple input/output registers
   - Connect to LED pins (reuse counter design pins)
   - Test LED control from firmware

3. **Timer Controller** (~1 hour)
   - 32-bit up-counter with compare and interrupt
   - Memory-mapped control and status registers
   - Test timing delays

4. **Interconnect** (~30 min)
   - AXI-Lite or Wishbone bus
   - Address decoder for peripherals
   - Arbitration if needed

### Phase 4: Firmware Development (~2-3 hours)

**Tasks:**
1. **Setup Toolchain** (~30 min)
   - Install RISC-V GCC toolchain (riscv32-unknown-elf-gcc)
   - Configure linker script (memory map)
   - Create Makefile

2. **Write Boot Code** (~1 hour)
   - Minimal startup code (crt0.S)
   - Initialize stack pointer
   - Jump to main()

3. **Write Application** (~1 hour)
   - Blink LED via GPIO
   - Print "Hello World" via UART
   - Timer-based delays

4. **Load and Test** (~30 min)
   - Convert ELF to hex file
   - Load into boot ROM
   - Program FPGA and test

### Phase 5: Integration and Testing (~2-3 hours)

**Tasks:**
1. **Full System Build** (~30 min)
   - Synthesize complete system
   - Place and route
   - Generate bitstream

2. **Hardware Testing** (~1 hour)
   - Program MPF300 eval kit
   - Verify UART communication (connect USB-UART adapter)
   - Verify LED blinking
   - Test button input (GPIO)

3. **Debug and Optimization** (~1 hour)
   - Fix any issues
   - Optimize timing if needed
   - Validate all peripherals

---

## Tools and Resources

### RISC-V Toolchain
- **Compiler:** riscv32-unknown-elf-gcc
- **Installation:**
  - Linux: `sudo apt-get install gcc-riscv64-unknown-elf` (cross-compile for RV32)
  - Or build from source: https://github.com/riscv/riscv-gnu-toolchain
- **Documentation:** https://riscv.org/technical/specifications/

### RTL Repositories
- **PicoRV32:** https://github.com/YosysHQ/picorv32
- **UART Core:** https://github.com/alexforencich/verilog-uart
- **AXI Interconnect:** https://github.com/alexforencich/verilog-axi

### Reference Designs
- Check Microchip website for PolarFire reference designs
- Look for SoC or soft processor examples

---

## Hardware Requirements

### MPF300 Eval Kit Connections

**UART:**
- TX: GPIO pin (e.g., A10)
- RX: GPIO pin (e.g., B10)
- Connect USB-UART adapter (FTDI FT232, CP2102, etc.)

**GPIO/LEDs:**
- Reuse existing LED pins from counter design
- 8 LEDs: D25, C26, B26, F22, H21, H22, F23, C27

**Buttons:**
- Reset: SW7 (B27) - already used
- User button: Additional GPIO if needed

**External Memory (Optional):**
- SRAM chip on breadboard or evaluation board
- Connect address/data/control pins to FPGA I/O

**Power:**
- USB power from eval kit

---

## Risk Mitigation

### Potential Challenges

**1. RISC-V RTL Integration**
- **Risk:** Verilog syntax incompatibilities with Libero
- **Mitigation:** Test compile early, fix syntax issues incrementally

**2. Memory Controller Complexity**
- **Risk:** DDR3 controller too complex for initial attempt
- **Mitigation:** Start with on-chip SRAM, add external memory later

**3. Timing Closure**
- **Risk:** Design doesn't meet 100 MHz target frequency
- **Mitigation:** Lower clock frequency (50 MHz acceptable for bare-metal)

**4. Firmware Toolchain**
- **Risk:** RISC-V GCC not available or difficult to install
- **Mitigation:** Use prebuilt binaries from SiFive or RISC-V foundation

**5. Debug Visibility**
- **Risk:** Hard to debug RISC-V execution without visibility
- **Mitigation:** Use UART for printf-style debugging, add LED status indicators

---

## Success Criteria

**Minimum Viable Product (MVP):**
- ✅ RISC-V core executes firmware from on-chip memory
- ✅ Firmware blinks LED via GPIO
- ✅ UART prints "Hello World" to terminal
- ✅ Design synthesizes and fits on MPF300TS
- ✅ Hardware validation on eval kit

**Stretch Goals:**
- [ ] External SRAM interface working
- [ ] Interrupt-driven peripherals (UART RX interrupt, timer interrupt)
- [ ] Multi-tasking bare-metal scheduler
- [ ] Performance benchmarking (CoreMark, Dhrystone)

---

## Timeline Estimate

**Total Development Time:** ~12-16 hours

| Phase | Time Estimate |
|-------|---------------|
| Phase 1: RISC-V Core Integration | 3-4 hours |
| Phase 2: Memory Integration | 2-3 hours |
| Phase 3: Peripheral Integration | 2-3 hours |
| Phase 4: Firmware Development | 2-3 hours |
| Phase 5: Integration and Testing | 2-3 hours |

**Recommended Pace:** 2-3 hour sessions, 1-2 times per week
**Timeline to Working Prototype:** 2-3 weeks

---

## Next Immediate Steps

1. **Clone PicoRV32 Repository** (~5 min)
   ```bash
   cd /mnt/c/tcl_monster/hdl
   git clone https://github.com/YosysHQ/picorv32.git riscv_picorv32
   ```

2. **Review PicoRV32 Documentation** (~30 min)
   - Read README.md
   - Understand configuration options
   - Review example designs

3. **Create RISC-V Project Structure** (~15 min)
   ```
   examples/advanced/riscv_soc/
   ├── hdl/
   │   ├── riscv_core/       (PicoRV32 files)
   │   ├── peripherals/      (UART, GPIO, Timer)
   │   └── top.v             (Top-level integration)
   ├── firmware/
   │   ├── boot/             (Startup code)
   │   ├── src/              (Application code)
   │   └── Makefile
   ├── constraint/
   │   ├── io_riscv.pdc      (Pin assignments)
   │   └── timing_riscv.sdc  (Timing constraints)
   └── README.md
   ```

4. **Update TCL Monster Scripts** (~30 min)
   - Create `tcl_scripts/create_riscv_project.tcl`
   - Add RISC-V HDL files
   - Configure for larger design

---

**Last Updated:** 2025-10-22
**Status:** Planning Complete, Ready for Implementation
**Next Session:** Start Phase 1 (RISC-V Core Integration)
