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

## What's Next

### Immediate Use Cases
1. **Daily build analysis** - Run Build Doctor after every synthesis
2. **MI-V project creation** - Use SmartDesign automation for new RISC-V projects
3. **Reusable templates** - Create your own SmartDesign templates

### Future Enhancements
- Board adaptation (auto-port designs to different eval boards)
- AXI interconnect generator
- HTML dashboard for build trends
- Integration with FPGA docs RAG system
- More SmartDesign templates (MI-V + DDR, MI-V + PCIe, etc.)

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
