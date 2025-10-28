# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TCL Monster** - Command-line automation toolkit for Microchip Libero SoC FPGA projects.

**Primary Goal:** Enable rapid FPGA project creation, design implementation, and debugging through TCL scripting, pushing the boundaries of what's possible via command-line interface versus GUI-only workflows.

**Target Environment:**
- **Libero Version:** SoC v2024.2
- **Primary Device:** PolarFire MPF300TS (MPF300 Eval Kit - FCG1152 package)
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

## Libero TCL Command Patterns

Based on analysis of `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl`:

### Project Creation
```tcl
new_project \
    -location "./path/to/project" \
    -name "project_name" \
    -hdl VERILOG \
    -family PolarFire \
    -die MPF300TS \
    -package FCG1152 \
    -speed -1 \
    -die_voltage 1.0 \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1 \
    -use_enhanced_constraint_flow 1
```

### Adding HDL Sources
```tcl
import_files \
    -convert_EDN_to_HDL 0 \
    -library {work} \
    -hdl_source {./path/to/source.v}
```

### Design Hierarchy
```tcl
build_design_hierarchy
set_root -module {module_name::work}
```

### Build Stages
```tcl
run_tool -name SYNTHESIZE       # Synthesis with Synplify Pro
run_tool -name PLACEROUTE       # Place and Route
run_tool -name VERIFYTIMING     # Timing verification
run_tool -name SIM_PRESYNTH     # Pre-synthesis simulation
run_tool -name SIM_POSTSYNTH    # Post-synthesis simulation
```

### Project Management
```tcl
save_project
close_project
```

## Architecture and Design Philosophy

### Modular Structure
- **tcl_scripts/** - Libero TCL automation scripts (project creation, build, constraints)
- **hdl/** - HDL source files (Verilog/VHDL modules)
- **config/** - Project configuration files (JSON templates for project parameters)
- **docs/** - Documentation, examples, and notes

### Configuration-Driven Approach
Projects are defined in JSON configuration files (`config/project_template.json`) that specify:
- Device family, die, package, speed grade
- HDL sources and hierarchy
- Constraint files
- Build flow options

TCL scripts read these configurations to enable parameterized project generation.

### Scalability Strategy
1. **Template-based:** Reusable TCL functions for common tasks
2. **Device-agnostic:** Parameterize device selection through config files
3. **Modular scripts:** Separate TCL files for creation, build, constraints, debugging
4. **Future Python wrapper:** Higher-level orchestration and intelligent feedback loops (aspirational)

## Development Workflow

### Current Capabilities (v0.1)
1. Create Libero project from command line
2. Configure for MPF300 Eval Kit
3. *(In progress)* Add HDL sources
4. *(In progress)* Run synthesis/P&R
5. *(Future)* Constraint generation
6. *(Future)* Debugging and feedback loops

### Testing Approach
User will manually execute TCL scripts in Libero (initially via GUI TCL console if needed, transitioning to pure CLI). Feedback loop:
1. Claude Code generates TCL script
2. User runs script via `./run_libero.sh`
3. User reports errors/results
4. Claude Code debugs and iterates

### Next Immediate Tasks (Tonight's Session)
1. Create simple counter HDL module (`hdl/counter.v`)
2. Extend `create_project.tcl` to import HDL sources
3. Create `build_design.tcl` for synthesis/place & route
4. Test complete flow: create project → add design → build → bitstream
5. Document any CLI limitations discovered

## Known Constraints and Unknowns

### Unknowns (to be explored)
- **CLI limitations:** What can/cannot be done via `libero.exe` command line vs. GUI?
- **Feedback mechanisms:** Can we capture build logs programmatically for debugging?
- **Constraint automation:** Can we generate PDC/SDC files from pin assignments?
- **Python integration:** Is there a Libero Python API, or must we wrap TCL?

### Constraints
- Libero runs on Windows; automation runs in WSL (path translation required)
- User is experienced FAE - can validate results, but needs time savings from automation
- Real hardware available (MPF300 Eval Kit) for validation

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

## Comprehensive Documentation Structure

**NEW (2025-10-22):** Extensive planning documents created for long-term development

### Primary Documentation

**For Session Startup:**
- **THIS FILE** (`.claude/CLAUDE.md`) - Read first every session for paths, commands, and project overview
- `QUICKSTART.md` - Quick reference for immediate tasks
- `README.md` - Project overview and introduction

**For Planning and Roadmap:**
- **`docs/ROADMAP.md`** - **MASTER PLAN** - Multi-phase development strategy with time estimates
  - Current Status: Phase 0 complete (counter design synthesized!)
  - Next: Phase 1 (timing constraints, reporting, templates)
  - Phases 2-6 detailed with time estimates

**For Specific Topics:**
- **`docs/DESIGN_LIBRARY.md`** - Catalog of all designs (basic → advanced)
  - Counter design: ✅ Complete (33 LUTs, 32 FFs)
  - Planned: UART, SPI, I2C, DDR, PCIe, RISC-V
- **`docs/DEBUGGING_FRAMEWORK.md`** - Identify & SmartDebug automation strategy
  - Probe insertion, waveform capture, device programming
- **`docs/SIMULATION_FRAMEWORK.md`** - ModelSim/QuestaSim integration
  - Testbench generation, regression testing, waveform analysis
- **`docs/APP_NOTE_AUTOMATION.md`** - Application note recreation strategy
  - Parse Libero projects, adapt to different boards
- **`docs/CONTEXT_STRATEGY.md`** - Context window management
  - Memory MCP usage, session protocols, compaction strategy
- **`docs/COLLEAGUE_GUIDE.md`** - Getting started guide for other FAEs
  - Installation, quick start, troubleshooting

### When to Read What

| Situation | Read This |
|-----------|-----------|
| Starting ANY session | `.claude/CLAUDE.md` (this file) + query Memory MCP |
| Planning next phase | `docs/ROADMAP.md` |
| Choosing/creating design | `docs/DESIGN_LIBRARY.md` |
| Debugging issues | `docs/DEBUGGING_FRAMEWORK.md` |
| Setting up simulation | `docs/SIMULATION_FRAMEWORK.md` |
| Recreating app notes | `docs/APP_NOTE_AUTOMATION.md` |
| Context near limit | `docs/CONTEXT_STRATEGY.md` |
| Sharing with colleague | `docs/COLLEAGUE_GUIDE.md` |

### Session Start Protocol (MANDATORY)

**Every session MUST start with:**
1. Check context usage with `/check-context` or `/compact-check`
2. Read `.mcp.json` for last session state
3. Read relevant sections of THIS file (`.claude/CLAUDE.md`)
4. Check `docs/ROADMAP.md` for current phase
5. Confirm with user: "Resuming [phase X], last completed [task Y]?"

## Autonomous Context Compaction (CRITICAL)

**Philosophy:** Treat context like precious RAM. Compact proactively before quality degrades.

### When to Check Context (Proactive Monitoring)

**ALWAYS check context before:**
- Starting large research tasks (WebSearch, reading multiple files)
- Beginning new feature/phase
- After completing 5-7 conversational turns

**Use `/compact-check` to:**
- Get current context percentage
- Receive intelligent recommendations
- Plan compaction timing

### Compaction Thresholds

**< 75% (Safe Zone)** ✅
- Continue working normally
- Check again after completing current task

**75-85% (Planning Zone)** ⚠️
- Start planning compaction
- Run `/save-state` to preserve context
- Complete current task, then evaluate
- **Recommendation:** Compact after current task

**85-90% (Warning Zone)** 🟠
- Compact within 1-2 tasks
- MUST save state before continuing major work
- No new large research tasks
- **Recommendation:** Complete current task, compact immediately

**90-95% (Urgent Zone)** 🔴
- COMPACT NOW before starting new work
- Run `/save-state` immediately
- Don't start new features or research
- **Recommendation:** Save and compact now

**> 95% (Critical Zone)** 🚨
- EMERGENCY COMPACT
- Auto-compact will trigger imminently
- Loss of control over what gets summarized
- **Action:** Immediate save-state and compact

### Pre-Compact Checklist

**Before every `/compact`, run `/save-state` to create:**
1. **`.mcp.json`** - Updated project state, decisions, next steps
2. **`docs/sessions/session_[date].md`** - Session summary
3. **`docs/lessons_learned/[topic].md`** - Any new patterns/learnings
4. **Git commit** - If substantial work completed

### Compaction Best Practices

**Compact proactively when:**
- Finishing a feature/phase (even if < 75%)
- Pivoting to new work direction
- Session ending soon
- Every 5-7 deep conversational turns

**DON'T wait for:**
- 95% auto-compact threshold
- User to manually trigger
- Context quality to degrade

**Philosophy from experts:**
> "Curate the smallest high-signal set of tokens" - Anthropic
> "Compact every 5-7 turns to prevent context rot" - BinaryVerseAI

### Post-Compact Recovery

**After compacting:**
1. Read `.mcp.json` to restore state
2. Read last session summary from `docs/sessions/`
3. Check TodoWrite list for active tasks
4. Confirm understanding with user before continuing

## Success Metrics

**Short-term (this week):**
- ✅ Successfully create projects via CLI - **DONE!**
- ✅ Generate bitstream for simple counter design - **DONE!**
- ⏳ Complete Phase 1 (timing constraints, reporting)

**Medium-term (3-4 weeks):**
- Parameterized project templates for multiple devices
- Complex design examples (UART, SPI, DDR)
- Simulation and debugging frameworks
- Application note recreation

**Long-term (future):**
- Agent-based intelligent automation
- Self-improving toolkit with learned patterns
- Comprehensive design library
- Integration with version control and CI/CD workflows

**See `docs/ROADMAP.md` for detailed timeline and estimates**
