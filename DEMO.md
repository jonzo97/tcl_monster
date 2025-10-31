# TCL Monster Demo - FPGA Automation Toolkit

**Quick demo** of command-line FPGA automation tools for Microchip Libero SoC.

## What This Does

**Eliminates manual GUI clicking** with two powerful automation tools:
1. **SmartDesign Automation** - Create MI-V systems in 30 seconds (vs. 5-10 minutes manual)
2. **Build Doctor** - Intelligent build analysis with actionable recommendations

---

## Demo 1: Build Doctor (~2 minutes)

### The Problem
Libero build logs are cryptic and hard to parse manually:
- Buried warnings and errors
- No actionable recommendations
- Hard to track resource usage trends

### The Solution
**Build Doctor** analyzes logs and gives intelligent recommendations.

```bash
# Analyze any Libero project
python tools/diagnostics/build_doctor.py libero_projects/counter_demo --verbose
```

**Output:**
```
🔬 BUILD DOCTOR ANALYSIS

Build Status: ✅ PASSED

Quick Stats:
  Errors:   0
  Warnings: 0
  LUTs:     33 / 299,544 (0.01%)
  FFs:      32 / 299,544 (0.01%)

⚠️  WARNINGS (1):
  ⚠️ [Performance] Timing-driven Place & Route is disabled
     Impact: Design may not meet timing requirements
     Fix: Add timing constraints (SDC file) to enable timing-driven P&R
     Reference: See constraint/timing_constraints_template.sdc

💡 SUGGESTIONS (3):
  💡 [Resource] Very low resource usage - plenty of headroom!
  💡 [Optimization] Consider register pipelining for higher Fmax
  💡 [Power] Enable power-driven P&R for battery applications
```

**Before vs. After:**
- **Before:** Read raw logs, guess at issues, no guidance
- **After:** Instant analysis with actionable fixes

---

## Demo 2: SmartDesign Automation (~2 minutes)

### The Problem
Creating MI-V RISC-V systems in Libero GUI:
- **5-10 minutes** of clicking and dragging
- **Easy to make mistakes** (missed connections, wrong addresses)
- **Hard to reuse** across projects

### The Solution
**SmartDesign Automation** creates complete systems in one command.

```tcl
# Load automation library
source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl

# Create complete MI-V system with UART + GPIO
::miv_minimal::create_and_set_root "MyMIV_System" {
    core_variant "RV32IMC"
    system_clock_mhz 50
    gpio_width 8
    add_uart true
}
```

**What it does automatically:**
- ✅ Creates SmartDesign
- ✅ Adds MI-V RV32 core + JTAG debug
- ✅ Connects clock tree (CCC → all components)
- ✅ Connects reset tree (init monitor → reset controller → all components)
- ✅ Connects APB peripherals with auto-generated address map
- ✅ Creates top-level ports
- ✅ Validates all connections

**Before vs. After:**
- **Before:** 5-10 minutes, error-prone manual clicking
- **After:** 30 seconds, validated automatically

---

## Quick Start

### 1. Install Dependencies
```bash
# Python 3.7+ required
python --version

# No external dependencies for basic features!
```

### 2. Run Build Doctor
```bash
# Analyze your Libero project
python tools/diagnostics/build_doctor.py <path/to/your/project>

# Verbose mode for all suggestions
python tools/diagnostics/build_doctor.py <path/to/your/project> --verbose
```

### 3. Try SmartDesign Automation
```bash
# Test the library (no Libero needed)
tclsh tcl_scripts/test_smartdesign_lib.tcl

# Should see: "All Tests Passed!"
```

---

## Features Demonstrated

### Build Doctor
- ✅ Parse synthesis logs (Synplify Pro)
- ✅ Parse P&R logs (Place & Route)
- ✅ Extract resource usage (LUTs, FFs, I/O, RAM, Math)
- ✅ Detect configuration issues (timing-driven, constraints)
- ✅ Provide actionable recommendations
- ✅ Categorize by severity (ERROR, WARNING, INFO)

### SmartDesign Automation
- ✅ APB interconnect generator (auto-addressing)
- ✅ Clock/reset tree automation
- ✅ Component management with validation
- ✅ MI-V minimal template (complete system)
- ✅ Tested and working

---

---

## Demo 3: Complete MI-V Project (~3 minutes)

### The Complete Workflow
**From nothing to working RISC-V processor** - all via command line.

```bash
# 1. Create MI-V RV32 project with SRAM + peripherals
./run_libero.sh tcl_scripts/create_miv_simple.tcl SCRIPT

# 2. Run synthesis and place & route
./run_libero.sh tcl_scripts/build_miv_simple.tcl SCRIPT

# 3. Analyze with Build Doctor
python tools/diagnostics/build_doctor.py libero_projects/miv_simple_demo
```

**System Created:**
- MI-V RV32IMC processor (Integer + Multiply + Compressed)
- 64kB on-chip SRAM
- UART peripheral
- 4x GPIO outputs (LEDs)
- 2x CoreTimer peripherals
- JTAG debug interface
- Complete clock/reset infrastructure

**Build Results:**
```
Build Status: ✅ PASSED

Resource Usage:
  LUTs:           11,607 / 299,544 (3.87%)
  Flip-Flops:      5,644 / 299,544 (1.88%)
  Logic Elements: 11,771 total
  I/O Pins:            8 (all placed)

Build Time: ~25-30 minutes (automated)
Errors: 0
```

### Complexity Scaling Demo

**Counter (baseline):** 33 LUTs, 32 FFs
**MI-V Processor:** 11,607 LUTs, 5,644 FFs

**That's a 351x increase in complexity!**

Build Doctor analyzes both equally fast (<2 seconds), demonstrating scalability from trivial designs to production processors.

See `docs/build_comparison.md` for detailed metrics.

---

## What's Next

### Immediate Use Cases
1. **Daily build analysis** - Run Build Doctor after every synthesis
2. **MI-V project creation** - Complete RISC-V systems via automated scripts
3. **Reusable templates** - Create your own project templates
4. **Build regression testing** - Automate synthesis in CI/CD pipelines

### Future Enhancements
- Pin constraints generation (PDC automation)
- Bitstream generation automation
- Timing analysis integration
- Board adaptation (auto-port designs to different eval boards)
- HTML dashboard for build trends
- Integration with FPGA docs RAG system
- More complex templates (MI-V + DDR, MI-V + PCIe, etc.)

---

## Documentation

- **SmartDesign Library:** `tcl_scripts/lib/smartdesign/README.md`
- **Build Diagnostics:** `tools/diagnostics/README.md` (coming soon)
- **Project Roadmap:** `docs/ROADMAP.md`

---

## Questions?

**Try it yourself:**
1. Clone repo: `git clone <repo_url>`
2. Run demos above
3. Read `tcl_scripts/lib/smartdesign/README.md` for detailed API

**Issues or suggestions:**
- GitHub Issues: <repo_url>/issues
- Or ask Jonathan directly

---

**Created:** 2025-10-29
**Status:** ✅ Demo Ready
**Tested On:** Libero SoC v2024.2, PolarFire MPF300
