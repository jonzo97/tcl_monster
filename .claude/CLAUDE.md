# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TCL Monster** - Command-line automation toolkit for Microchip Libero SoC FPGA projects.

**Primary Goal:** Enable rapid FPGA project creation, design implementation, and debugging through TCL scripting, pushing the boundaries of what's possible via command-line interface versus GUI-only workflows.

**Target Environment:**
- **Libero Version:** SoC v2024.2
- **Primary Device:** PolarFire MPF300TS (MPF300 Eval Kit - FCG1152 package)
- **BeagleV-Fire:** MPFS025T PolarFire SoC (5x RISC-V cores + FPGA fabric) - for embedded + FPGA development
- **Future Devices:** PolarFire SoC, Igloo2, SmartFusion2 families
- **Development OS:** WSL2 on Windows (Libero runs on Windows side)
- **User Role:** Field Applications Engineer (FAE) - experienced with Libero GUI, exploring CLI automation

## Critical Paths and Commands

### Libero Installation
- **Windows Path:** `C:\Microchip\Libero_SoC_v2024.2\Designer\bin\libero.exe`
- **WSL Path:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe`

### Related Tools (same version)
- **Synplify Pro:** `/mnt/c/Microchip/Libero_SoC_v2024.2/SynplifyPro/`
- **ModelSim/QuestaSim:** `/mnt/c/Microchip/Libero_SoC_v2024.2/ModelSim/` or `QuestaSim/`
- **Identify:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/`

### Running Libero TCL Scripts

**From WSL (recommended):**
```bash
./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
```

**Direct execution:**
```bash
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe SCRIPT:<windows_path_to_script>
```

**Modes:**
- `SCRIPT` - Batch mode execution
- `SCRIPT_ARGS` - With command-line arguments
- `SCRIPT_HELP` - Display help information

## Key Documentation Locations

### TCL Documentation (CRITICAL - READ FIRST!)
- **TCL Mastery Guide:** `docs/TCL_MASTERY.md` (comprehensive guide from 64-design corpus)
- **TCL Quick Reference:** `docs/TCL_QUICK_REFERENCE.md` (1-page cheat sheet)
- **Build Flow Lessons:** `docs/reference/libero_build_flow_lessons.md` (synthesis/P&R workflow)

### Local Libero Documentation
- **Sample TCL Scripts:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl`
- **FPGA Command Reference:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/doc/fpga_command_reference.pdf`
- **Help System:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/doc/libero_help/`

### FPGA Documentation RAG System (CRITICAL - USE THIS FIRST!)

**Location:** `~/fpga_mcp` - Semantic search over all PolarFire FPGA documentation
**Status:** ✅ Operational - 1,233 chunks indexed with semantic chunking

**When to Use:**
- **ALWAYS** search here BEFORE reading raw PDFs
- **ALWAYS** use for PolarFire-specific questions (clocking, I/O, DDR, PCIe, power, etc.)
- **DO NOT** waste context reading full PDFs when RAG can answer

**How to Use:**
```python
# In Python scripts or interactive sessions
cd ~/fpga_mcp
python scripts/test_indexing.py  # Run search tests
```

**MCP Server:**
- **Type:** Model Context Protocol server with ChromaDB vector store
- **Model:** BAAI/bge-small-en-v1.5 (384-dim embeddings)
- **Search Quality:** 0.75-0.87 similarity scores on test queries

**Indexed Documents (1,233 chunks, optimized with semantic chunking):**
1. **User IO Guide** (199 chunks) - Pin config, I/O standards, LVDS, HSIO
2. **Clocking Guide** (111 chunks) - CCC/PLL config, clock routing
3. **Board Design Guide** (55 chunks) - Power supply, PCB layout
4. **Datasheet** (227 chunks) - Electrical specs, timing, resources
5. **Transceiver Guide** (221 chunks) - SERDES, PCIe, protocols
6. **Fabric Guide** (170 chunks) - Logic resources, routing
7. **Memory Controller Guide** (250 chunks) - DDR3/DDR4 config

**Not Yet Indexed:**
- TCL Command Reference (use `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/doc/fpga_command_reference.pdf`)
- Libero internal help (93 PDFs in Designer/doc/libero_help/)
- Application notes

**Example Queries That Work Well:**
- "DDR4 memory controller configuration"
- "PolarFire clocking resources CCC"
- "PCIe transceiver lanes"
- "FPGA power supply requirements"
- "GPIO pin configuration"

## TCL Reference & Best Practices

**For TCL scripting, see consolidated documentation:**
- **Quick syntax:** `docs/TCL_QUICK_REFERENCE.md` (1-page cheat sheet)
- **Comprehensive guide:** `docs/TCL_MASTERY.md` (complete reference with all lessons from 64-design corpus)
- **Reference designs:** `docs/REFERENCE_DESIGNS.md` (guide to mining 64-design corpus)

**Critical patterns documented below in "Standard TCL Script Structure"**

## Standard TCL Script Structure

**Source:** Analysis of 64 PolarFire reference designs (1,549 TCL files) by codex

**For comprehensive guide, see:** `docs/TCL_MASTERY.md` | **Quick reference:** `docs/TCL_QUICK_REFERENCE.md`

### THREE CRITICAL PATTERNS (NEVER SKIP!)

#### 1. Numbered Script Topology (58+ reference designs use this)

**Standard structure:**
```
project/
├── src/components/      # IP/SmartDesign TCL configs
├── constraint/          # PDC/SDC files
├── common.tcl          # IP versions, project variables
├── 1_create_design.tcl      # Project + HDL import
├── 2_constrain_design.tcl   # PDC/SDC linking with organize_tool_files
├── [3_*.tcl]                # Reserved for variants (optional)
├── 4_implement_design.tcl   # SYNTH → PLACE → VERIFYTIMING → GENFILE
└── 5_program_design.tcl     # export_prog_job + save
```

**Why:** Standardizes build flow, enables multi-variant designs, simplifies maintenance

**Step 3 intentionally skipped** in single-variant flows to allow easy variant addition later without renumbering.

#### 2. Constraint Linking Pattern (44+ reference designs REQUIRE this)

**CRITICAL:** `import_files` alone is NOT sufficient - constraints must be explicitly associated with tools.

```tcl
# Step 1: Create links (register files with project)
create_links -io_pdc {C:/path/io.pdc}
create_links -sdc {C:/path/timing.sdc}

# Step 2: Associate with tools (BOTH for SDC!)
organize_tool_files -tool {SYNTHESIZE} \
    -file {C:/path/timing.sdc} \
    -module {top} \
    -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/path/timing.sdc} \
    -module {top} \
    -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/path/io.pdc} \
    -module {top} \
    -input_type {constraint}
```

**Why:** Without `organize_tool_files`, synthesis uses auto-inferred timing and P&R ignores pin constraints.

**Errors if missing:**
- "No timing constraint associated to 'Place and Route' tool"
- "No User PDC file specified"
- "I/O Locked: 0 (0%)" despite PDC with `-fixed true`

#### 3. VERIFYTIMING Gate (49+ reference designs use this)

**ALWAYS insert timing gate between PLACEROUTE and bitstream generation:**

```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}  # <- TIMING GATE (catches closure issues early)
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}

export_prog_job \
    -job_file_name $project_name \
    -export_dir $projectDir/designer/top/export \
    -bitstream_file_type {TRUSTED_FACILITY}
```

**Why:** Catches timing closure failures BEFORE spending time on bitstream generation. Standard practice in production flows.

**Benefits:**
- Early detection of timing violations
- Detailed timing reports for debugging
- Prevents surprise failures late in build flow

### Additional Key Lessons from 64-Design Corpus

**Component-First Philosophy (9.6:1 ratio):**
- Prefer `create_and_configure_core` + `sd_instantiate_component` (96% of instantiations)
- Use `sd_instantiate_hdl_module` sparingly (< 10%) - only for simple leaf blocks
- Avoids HDL sub-module hierarchy issues entirely

**IP Version Pinning:**
- Centralize IP versions in `common.tcl` for reproducibility
- See `docs/ref_designs/ip_versions.md` for ready-to-use version blocks

**HDL Import Rule:**
- ONLY import leaf modules you will directly instantiate in SmartDesign
- DON'T import HDL files that instantiate modules you want to use with `sd_instantiate_hdl_module`
- This prevents "Cannot instantiate sub-module" errors

**See also:**
- `docs/TCL_MASTERY.md` - Comprehensive TCL guide (consolidated all lessons)
- `docs/REFERENCE_DESIGNS.md` - How to use 64-design corpus for pattern mining
- `docs/ref_designs/tcl_deep_dive.md` - Statistical analysis and patterns

## Project Architecture

**Directory Structure:**
- `tcl_scripts/` - Libero TCL automation (numbered scripts: 1_create, 2_constrain, 4_implement, 5_program)
- `tcl_scripts/lib/` - Shared libraries (common.tcl for IP versions)
- `hdl/` - HDL source files (Verilog/VHDL)
- `constraint/` - Constraint files (PDC/SDC)
- `docs/` - Documentation (guides, references, lessons learned)

**Design Philosophy:**
- **Component-first:** Prefer IP cores over raw HDL (9.6:1 ratio from reference designs)
- **Numbered scripts:** Standard topology (1_create, 2_constrain, 4_implement, 5_program)
- **Version pinning:** Centralize IP versions in `tcl_scripts/lib/common.tcl`


## Integration with User's Global Preferences

### Time Estimation Philosophy
- Simple TCL script modifications: ~5 minutes
- New TCL script with HDL: ~10-15 minutes
- Full build flow script: ~20-30 minutes
- End-to-end testing: ~20 minutes (limited by Libero synthesis time)

### Memory and Context
- Use Memory MCP to preserve architecture decisions and script patterns
- Document discovered Libero CLI capabilities and limitations
- Save working TCL patterns for reuse across projects

### Task Management
- Use TodoWrite for all session planning and progress tracking
- Time-based labels ([Now], [Next ~Xmin], [Tonight], [Future session])
- Mark tasks complete immediately after finishing
- Keep active list focused (5-10 items)

## Microchip IP Cores - MI-V RISC-V (CRITICAL)

**ALWAYS use Microchip/Microsemi IP cores** instead of third-party alternatives.

### MI-V RISC-V Core Information

**Core Type:** Libero IP Catalog Core (not raw RTL)
**VLNV:** `Microsemi:MiV:MIV_RV32:3.1.200`
**Location:** Downloaded automatically by Libero when using `create_and_configure_core -download_core`

**Reference Designs:**
- `hdl/miv_polarfire_eval/` - Complete MI-V designs for MPF300 Eval Kit
- Key script: `Libero_Projects/PF_Eval_Kit_MIV_RV32_BaseDesign.tcl`
- Component configs: `Libero_Projects/import/components/MIV_RV32_CFG*.tcl`

**MI-V RV32 Configurations:**
- **CFG1** (RV32IMC): M+C extensions, 32kB TCM, JTAG debug
- **CFG2** (RV32IMC): Similar to CFG1 with different memory map
- **CFG3** (RV32IMCF): Adds floating-point extension

**Instantiation Pattern:**
```tcl
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32:3.1.200} \
    -download_core \
    -component_name {MIV_RV32_CFG1_C0} \
    -params { \
        "M_EXT:true" \
        "C_EXT:true" \
        "F_EXT:false" \
        "DEBUGGER:true" \
        "TCM_PRESENT:true" \
        "INTERNAL_MTIME:true" \
        ... \
    }
```

**GitHub Resources:**
- Organization: https://github.com/Mi-V-Soft-RISC-V
- Platform HAL: `hdl/miv_platform/` (drivers, HAL)
- Documentation: `hdl/miv_documentation/` (user guides)

**DO NOT** use third-party RISC-V cores (PicoRV32, VexRiscv, etc.) unless specifically required.

## Documentation Quick Reference

**Session Startup (READ EVERY TIME):**
- THIS FILE (`.claude/CLAUDE.md`) - Paths, commands, critical patterns
- `docs/TCL_MASTERY.md` - Complete TCL reference guide
- `docs/TCL_QUICK_REFERENCE.md` - 1-page TCL cheat sheet

**Technical References:**
- `docs/REFERENCE_DESIGNS.md` - 64-design corpus guide
- `docs/reference/libero_build_flow_lessons.md` - Build flow lessons learned
- `docs/core/cli_capabilities_and_workarounds.md` - CLI limitations & workarounds
- `docs/reference/beaglev_fire_guide.md` - BeagleV-Fire FPGA development

**Quick Lookups:**

| Need to... | Read this |
|------------|-----------|
| Write TCL scripts | `docs/TCL_MASTERY.md` or `docs/TCL_QUICK_REFERENCE.md` |
| Use reference designs | `docs/REFERENCE_DESIGNS.md` |
| Work with BeagleV-Fire | `docs/reference/beaglev_fire_guide.md` |
| Understand CLI limits | `docs/core/cli_capabilities_and_workarounds.md` |

### Session Start Protocol

**Every session:**
1. Read THIS FILE (`.claude/CLAUDE.md`) for project overview
2. Check `docs/TCL_MASTERY.md` for TCL patterns
3. Review recent work via `git log` or TodoWrite list

## Context Management

**Philosophy:** Treat context like precious RAM. Compact proactively before quality degrades.

**Protocol:** See user's global preferences (`~/.claude/CLAUDE.md`) for complete context management strategy.

**Quick reference:**
- Check context: `/check-context`
- Save state: `/prep-compact`
- Full automation: `/compact` (auto-prep, compact, restore)

## Project Status & Next Steps

**Completed:**
- ✅ CLI project creation and build automation
- ✅ Counter design synthesized (33 LUTs, 32 FFs)
- ✅ TCL knowledge consolidated (TCL_MASTERY.md, QUICK_REFERENCE.md, REFERENCE_DESIGNS.md)
- ✅ BeagleV-Fire documentation complete
- ✅ LED blink standalone design for BeagleV-Fire

**Active Work:**
- ⏳ TMR (Triple Modular Redundancy) project with MI-V RISC-V

**Future:**
- Complex designs (DDR, PCIe, high-speed interfaces)
- Simulation frameworks (ModelSim/QuestaSim integration)
- Debugging frameworks (Identify/SmartDebug automation)

**See `docs/ROADMAP.md` for detailed development roadmap**

**Reference Design Resources:**
- **64-Design Corpus Guide:** `docs/REFERENCE_DESIGNS.md` (top-10 designs, patterns, mining guide)
- **IP Version Pinning:** `tcl_scripts/lib/common.tcl` (centralized version definitions)

