# Quick Start Guide - TCL Monster

## Current Status ✅ MI-V RISC-V Demo Ready!

**NEW (2025-10-30):** Complete MI-V RV32 RISC-V processor with SRAM and peripherals - fully automated build!
**Phase 0:** Counter demo (33 LUTs) - ✅ Complete
**Phase 1:** MI-V demo (11,607 LUTs) - ✅ Complete

### Project Structure
```
tcl_monster/
├── tcl_scripts/
│   ├── create_project.tcl     # ✅ Creates project, imports HDL & constraints
│   ├── build_design.tcl       # ✅ Full build flow (synth → bitstream)
│   └── generate_reports.tcl   # ✅ NEW: Comprehensive reporting
├── hdl/
│   └── counter.v              # ✅ Counter design with rotating LEDs
├── constraint/
│   ├── io_constraints.pdc     # ✅ Pin mappings (locked)
│   └── timing_constraints.sdc # ✅ NEW: Timing constraints (50 MHz)
├── docs/                       # ✅ NEW: Comprehensive documentation!
│   ├── ROADMAP.md             # Master development plan
│   ├── DESIGN_LIBRARY.md      # Design catalog
│   ├── DEBUGGING_FRAMEWORK.md # Debug strategy
│   ├── SIMULATION_FRAMEWORK.md # Sim strategy
│   ├── APP_NOTE_AUTOMATION.md # App note recreation
│   ├── CONTEXT_STRATEGY.md    # Context management
│   └── COLLEAGUE_GUIDE.md     # Getting started guide
├── config/
│   └── project_template.json  # Project configuration template
├── run_libero.sh              # Helper script to run TCL from WSL
└── .claude/
    └── CLAUDE.md              # Project documentation for Claude Code
```

### 2. Quick Start: MI-V RISC-V Demo (Recommended)

**Create and build complete RISC-V processor system:**
```bash
# 1. Create MI-V project (takes ~2 minutes)
./run_libero.sh tcl_scripts/create_miv_simple.tcl SCRIPT

# 2. Build (synthesis + P&R, takes ~25-30 minutes)
./run_libero.sh tcl_scripts/build_miv_simple.tcl SCRIPT

# 3. Analyze with Build Doctor
python tools/diagnostics/build_doctor.py libero_projects/miv_simple_demo
```

**What you get:**
- MI-V RV32IMC RISC-V processor
- 64kB on-chip SRAM
- UART + GPIO + Timers
- JTAG debug
- 11,607 LUTs, 5,644 FFs
- Zero errors!

### 3. Quick Start: Counter Demo (Simple Baseline)

**Test the basic project creation:**
```bash
# Already built! Just analyze:
python tools/diagnostics/build_doctor.py libero_projects/counter_demo
```

This creates a simple counter at `./libero_projects/counter_demo/` configured for:
- Device: PolarFire MPF300TS-FCG1152
- HDL: Verilog
- 33 LUTs, 32 FFs
- Enhanced constraint flow enabled

## What's Next (Tonight's Session)

### Step 1: Create Counter HDL Module
Create `hdl/counter.v` with a simple counter design:
- Clock input
- Reset input
- Counter output (e.g., 8-bit or 16-bit)
- LED outputs for visual feedback

### Step 2: Extend Project Creation Script
Modify `tcl_scripts/create_project.tcl` to:
- Import HDL sources from `hdl/` directory
- Set design hierarchy
- Set top-level module

### Step 3: Create Build Script
New file `tcl_scripts/build_design.tcl` to:
- Run synthesis
- Run place & route
- Generate programming file

### Step 4: Test End-to-End
Run complete flow and verify bitstream generation.

## Debugging Notes

If Libero CLI doesn't work as expected:
1. Check that script is using Windows-style paths when needed
2. Verify Libero license is valid
3. Try running script manually in Libero GUI TCL console first
4. Check Libero logs in project directory

## Key Libero Commands Reference

```tcl
# Create project
new_project -location "path" -name "name" -family PolarFire ...

# Add files
import_files -hdl_source {file.v}

# Build hierarchy
build_design_hierarchy
set_root -module {top::work}

# Run tools
run_tool -name SYNTHESIZE
run_tool -name PLACEROUTE

# Save/Close
save_project
close_project
```

## Tips for Working with Claude Code

1. **Ask questions early** - If you hit roadblocks, provide error messages
2. **Test incrementally** - Run scripts after each change
3. **Document discoveries** - Note any CLI limitations or tricks that work
4. **Leverage MCP server** - Query `~/fpga_mcp` for device-specific info

## What's New (2025-10-22)

### Completed This Session:
- ✅ **Phase 0 Complete!** Counter design synthesized successfully
- ✅ **Comprehensive Documentation** - 6 planning docs for future phases
- ✅ **Timing Constraints** - SDC file for 50 MHz clock with proper setup/hold
- ✅ **I/O Pins Locked** - All pins fixed in PDC file
- ✅ **Reporting Script** - Automated build reports (resource, timing, pins)

### New Commands:

**Generate comprehensive reports:**
```bash
./run_libero.sh tcl_scripts/generate_reports.tcl SCRIPT
```

Outputs:
- `reports/build_summary.txt` - Quick overview
- `reports/resource_utilization.rpt` - LUT/FF usage
- `reports/*_timing_violations_*.txt` - Setup/hold violations
- `reports/pin_assignments.rpt` - Pin mappings
- `reports/power_analysis.rpt` - Power estimates

### Next Steps:

**Short-term (next session):**
1. Test rebuild with timing constraints
2. Program hardware and verify LEDs rotate
3. Start Phase 1 work (device templates, enhanced reporting)

**Long-term (see `docs/ROADMAP.md`):**
- Phase 1: Foundation & reporting (2-3 hours)
- Phase 2: Complex designs (UART, SPI, DDR) (4-5 hours)
- Phase 3: Simulation framework (3-4 hours)
- Phase 4: Debugging automation (3-4 hours)
- Phase 5: Application note recreation (5-6 hours)
- Phase 6: Intelligent agents (4-5 hours)

**Total Development Roadmap:** ~22-27 hours over 3-4 weeks

## Original Time Estimates (COMPLETED!)

- ✅ Create counter HDL: ~5 min - **DONE**
- ✅ Update project script to add HDL: ~5 min - **DONE**
- ✅ Create build script: ~10 min - **DONE**
- ✅ Test and debug: ~15-20 min - **DONE**
- ✅ **Total: ~35-40 minutes** - **COMPLETED SUCCESSFULLY!**

(Actual Libero synthesis/build time: ~2 minutes for counter design)
