# MI-V RV32 RISC-V Project

**Created:** 2025-10-23
**Status:** Project creation complete, ready for synthesis
**Based on:** Application Note AN4997 - Building a Mi-V Processor Subsystem

## Overview

Successfully created a complete MI-V RV32 RISC-V processor subsystem for the PolarFire MPF300 Eval Kit using TCL automation.

## Project Details

**Project Name:** `miv_rv32_demo`
**Location:** `libero_projects/miv_rv32_demo/`
**Device:** MPF300TS (FCG1152 package, -1 speed grade)
**SmartDesign:** `MIV_RV32_BaseDesign`

## Configuration: CFG1 (RV32IMC)

- **RISC-V Extensions:**
  - **M:** Hardware multiply/divide
  - **C:** Compressed instructions (16-bit)

- **Memory Architecture:**
  - **32kB TCM (Tightly Coupled Memory):**
    Address range: `0x80000000 - 0x80007FFF`
    Directly connected to CPU core (zero wait-state)

  - **32kB External SRAM via AHB-Lite:**
    Address range: `0x60000000 - 0x6000FFFF`
    For additional program/data storage

- **Peripherals (APB Bus: 0x70000000 - 0x7000FFFF):**
  - **UART:** Serial communication (115200 baud default)
  - **GPIO:** 4 GPIOs (2 inputs for switches, 4 outputs for LEDs)
  - **CoreTimer (2x):** 32-bit programmable timers with interrupts

- **Debug Interface:**
  - **JTAG:** Full JTAG debug support via CoreJTAGDebug
  - Compatible with SoftConsole IDE debugger

- **Clock:**
  - **System Clock:** 50 MHz (from PF_CCC)
  - **Reference Clock:** External 50 MHz oscillator on eval board

## Components Created

### Core Processor
- **MIV_RV32_CFG1_C0** - MI-V RV32 RISC-V processor core v3.1.200
  - RV32IMC ISA
  - 32kB internal TCM
  - JTAG debug interface
  - APB and AHB-Lite bus interfaces
  - Machine timer with interrupt

### Infrastructure
- **PF_CCC_C0** - Clock Conditioning Circuit
  - Generates 50 MHz system clock from reference
  - PLL-based clock generation

- **CORERESET_PF_C0** - Reset controller
  - Manages power-on reset
  - PLL lock detection
  - External reset synchronization

- **PF_INIT_MONITOR_C0** - Initialization monitor
  - Tracks FPGA fabric initialization
  - Provides initialization done signal

### Peripherals
- **MIV_ESS_C0** - MI-V External Subsystem v2.0.200
  - Integrates UART (CoreUARTapb) and GPIO (CoreGPIO)
  - APB3 interconnect for peripherals
  - Interrupt routing

- **CoreTimer_C0, CoreTimer_C1** - Timer peripherals
  - 32-bit countdown timers
  - Interrupt generation
  - Configurable prescalers

- **PF_SRAM_AHB_C0** - 32kB external SRAM
  - AHB-Lite interface
  - Zero wait-state operation

- **CoreJTAGDebug_TRSTN_C0** - JTAG debug interface
  - JTAG-to-core debug bridge
  - Supports SoftConsole debugger

## I/O Signals

### Clock & Reset
- `REF_CLK` - 50 MHz reference clock input
- `USER_RST` - Active-low external reset button

### JTAG Debug
- `TCK` - JTAG clock
- `TDI` - JTAG data in
- `TDO` - JTAG data out
- `TMS` - JTAG mode select
- `TRSTB` - JTAG reset (active-low)

### UART
- `RX` - UART receive
- `TX` - UART transmit

### GPIO
- `SW_1`, `SW_2` - Input switches
- `LED_1`, `LED_2`, `LED_3`, `LED_4` - Output LEDs

## Memory Map

| Address Range          | Size  | Component           | Description                    |
|------------------------|-------|---------------------|--------------------------------|
| 0x80000000-0x80007FFF  | 32kB  | TCM                 | Tightly Coupled Memory (CPU)   |
| 0x60000000-0x6000FFFF  | 32kB  | PF_SRAM_AHB         | External SRAM                  |
| 0x70000000-0x7000FFFF  | 64kB  | APB Peripherals     | UART, GPIO, Timers             |

### APB Peripheral Memory Map (Base: 0x70000000)
| Offset    | Peripheral     | Description              |
|-----------|----------------|--------------------------|
| 0x0000    | CoreUARTapb    | UART control registers   |
| 0x1000    | CoreGPIO       | GPIO control registers   |
| 0x3000    | CoreTimer_C0   | Timer 0 registers        |
| 0x4000    | CoreTimer_C1   | Timer 1 registers        |

## TCL Script Architecture

### Component Configuration Approach
Rather than manually specifying hundreds of parameters, the script uses **pre-configured component TCL files** from the MI-V reference design:

**Location:** `tcl_scripts/miv_components/`
- `MIV_RV32_CFG1_C0.tcl` - RISC-V core configuration
- `PF_CCC_C0.tcl` - Clock configuration (247 parameters!)
- `CORERESET_PF_C0.tcl` - Reset controller
- `PF_INIT_MONITOR_C0.tcl` - Init monitor
- `CoreJTAGDebug_TRSTN_C0.tcl` - JTAG debug
- `MIV_ESS_C0.tcl` - External subsystem (UART + GPIO)
- `CoreTimer_C0.tcl`, `CoreTimer_C1.tcl` - Timers
- `PF_SRAM_AHB_C0.tcl` - External SRAM (modified to disable hex init)

These files are **sourced** rather than recreated from scratch, ensuring correct configuration without having to understand every parameter.

### Project Creation Script
**File:** `tcl_scripts/create_miv_rv32_project_v2.tcl`

**Workflow:**
1. Create Libero project with device settings
2. Configure SmartDesign DRC settings
3. Source pre-configured component TCL files (creates all IP cores)
4. Build SmartDesign:
   - Create top-level I/O ports
   - Instantiate components
   - Connect clocks (all to 50 MHz from PF_CCC)
   - Connect resets (synchronized via CORERESET_PF)
   - Connect buses (APB, AHB-Lite)
   - Connect interrupts
   - Connect peripherals to top-level I/O
5. Set SmartDesign as root module
6. Save project

**Execution:**
```bash
./run_libero.sh tcl_scripts/create_miv_rv32_project_v2.tcl SCRIPT
```

**Duration:** ~30 seconds to create complete project

## Next Steps

### Immediate (Tonight)
1. Create build script for synthesis and place & route
2. Add pin constraints (PDC file) for MPF300 Eval Kit
3. Run synthesis to verify design

### Short-term
1. Create example C program for MI-V processor
2. Test UART communication
3. Test GPIO (LEDs and switches)
4. Program FPGA and verify on hardware

### Future Enhancements
1. Add more peripherals (SPI, I2C)
2. Implement interrupt service routines
3. Add DDR memory controller
4. Create software HAL examples

## Key Learnings

### MI-V Core Discovery
- **MI-V cores are Libero IP Catalog cores**, not raw RTL
- Downloaded automatically via `create_and_configure_core -download_core`
- VLNV: `Microsemi:MiV:MIV_RV32:3.1.200`
- Cannot simply copy Verilog files - must use Libero's IP instantiation

### Address Parameter Format
MI-V core addresses are split into upper/lower 16-bit components:
- `TCM_START_ADDR_1:0x8000` - Upper 16 bits (bits 31:16)
- `TCM_START_ADDR_0:0x0` - Lower 16 bits (bits 15:0)
- Combined address: 0x80000000

### Component Configuration Complexity
- PF_CCC clock generator: **247 parameters**
- Manually configuring would be error-prone
- Better approach: Use reference design configurations as templates
- Modified only what's necessary (e.g., removed hex file init from SRAM)

### MIV_ESS Subsystem
- **External Subsystem (ESS)** bundles commonly-used peripherals
- Includes UART, GPIO, APB interconnect, reset controller, timers
- Simplifies peripheral integration vs. individual core instantiation
- Has internal APB bridge to route to external peripherals

## Files Created

### TCL Scripts
- `tcl_scripts/create_miv_rv32_project_v2.tcl` - Main project creation script (working version)
- `tcl_scripts/create_miv_rv32_project.tcl` - Initial attempt (had parameter issues)
- `tcl_scripts/miv_components/*.tcl` - Pre-configured component files (9 files)

### Project
- `libero_projects/miv_rv32_demo/` - Complete Libero project (ready for synthesis)
- `libero_projects/miv_rv32_demo/miv_rv32_demo.prjx` - Project file

### Documentation
- `docs/MIV_RV32_PROJECT.md` - This file
- `.claude/CLAUDE.md` - Updated with MI-V core information

## References

- **Application Note AN4997:** PolarFire FPGA Building a Mi-V Processor Subsystem
- **MI-V Reference Design:** `hdl/miv_polarfire_eval/Libero_Projects/PF_Eval_Kit_MIV_RV32_BaseDesign.tcl`
- **MI-V Documentation:** `hdl/miv_documentation/` (GitHub submodule)
- **MI-V Platform HAL:** `hdl/miv_platform/` (GitHub submodule)
- **FPGA Command Reference:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/doc/fpga_command_reference.pdf`

## Success Metrics

✅ Project creation via pure TCL automation
✅ All components instantiated successfully
✅ SmartDesign generated without errors
✅ Zero manual GUI steps required
⏳ Synthesis (next step)
⏳ Place & Route (next step)
⏳ Bitstream generation (next step)
⏳ Hardware validation (future)

---

**Project Status:** ✅ **COMPLETE - Ready for synthesis**
