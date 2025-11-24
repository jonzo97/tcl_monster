# AGENTS.md - TCL Monster for mchp CLI

**AI Agent Guidance for MCHP CLI Tool (Continue fork, GPT-4.1)**

This file provides instructions for AI coding agents when working with the TCL Monster FPGA automation toolkit.

---

## Project Overview

**TCL Monster** - Command-line automation toolkit for Microchip Libero SoC FPGA projects.

**Primary Goal:** Enable rapid FPGA project creation, design implementation, and debugging through TCL scripting, pushing the boundaries of what's possible via command-line versus GUI workflows.

**Target Environment:**
- **Libero Version:** SoC v2024.2
- **Primary Device:** PolarFire MPF300TS (MPF300 Eval Kit)
- **BeagleV-Fire:** MPFS025T PolarFire SoC (5x RISC-V cores + FPGA fabric)
- **Development OS:** WSL2 on Windows (Libero runs on Windows side)
- **AI Tool:** mchp CLI (Continue fork, GPT-4.1 model)

---

## CRITICAL: GPT-4.1 Agentic Optimization

**Model Constraint:** This project uses GPT-4.1 (organizational policy, cannot upgrade).

### Chain-of-Thought (CoT) Reasoning - MANDATORY

**ALWAYS use step-by-step reasoning for non-trivial tasks.** CoT prompting improves GPT-4 performance by 60%+.

**Required Pattern:**
```
Task: [What you need to do]

Step 1: [Break down the problem]
Step 2: [Identify dependencies/assumptions]
Step 3: [Execute solution]
Step 4: [Verify result]

Result: [What was accomplished]
```

### Autonomous Error Recovery

**DO NOT stop at first error.** Attempt automatic recovery:

1. **API/Network Errors:** Retry with exponential backoff (3 attempts)
2. **File Not Found:** Search alternative locations before asking
3. **Syntax Errors:** Fix and retry (use TCL patterns from this repo)
4. **Build Failures:** Check logs, suggest fixes based on error type
5. **Only escalate to user when truly unrecoverable**

### Task Management

**Use internal checklists for multi-step tasks:**
- Break complex requests into 3-5 concrete steps
- Execute steps sequentially (or parallel if independent)
- Mark steps complete as you go
- Summarize all actions when done
- **Minimize user intervention** - only ask when ambiguous

---

## Critical Paths and Commands

### Libero Installation
- **Windows Path:** `C:\Microchip\Libero_SoC_v2024.2\Designer\bin\libero.exe`
- **WSL Path:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe`

### Running TCL Scripts

**Recommended (from WSL):**
```bash
./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
```

**Direct execution:**
```bash
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe SCRIPT:<windows_path_to_script>
```

**Modes:**
- `SCRIPT` - Batch mode execution (headless)
- `SCRIPT_ARGS` - With command-line arguments
- `SCRIPT_HELP` - Display help

---

## Key Documentation Resources

### 1. FPGA Documentation RAG (MCP SERVER - USE THIS FIRST!)

**MCP Server Name:** "FPGA Documentation RAG"
**Status:** ✅ Configured in mchp CLI
**Content:** 1,233 chunks from 27+ PolarFire PDFs with enhanced table extraction

**When to Use:**
- **ALWAYS** use MCP tools to query FPGA docs BEFORE reading raw PDFs
- **ALWAYS** for PolarFire-specific questions (clocking, I/O, DDR, PCIe, power)
- Saves massive context by retrieving only relevant sections

**How to Query (via MCP in mchp CLI):**
```
@FPGA Documentation RAG search_fpga_docs query="DDR4 memory controller configuration"
```

Or use natural language:
```
Search the FPGA documentation for PolarFire clocking resources
```

**Indexed Documents:**
- User IO Guide (199 chunks) - Pin config, I/O standards
- Clocking Guide (111 chunks) - CCC/PLL config
- Board Design Guide (55 chunks) - Power supply, PCB
- Datasheet (227 chunks) - Electrical specs, timing
- Transceiver Guide (221 chunks) - SERDES, PCIe
- Fabric Guide (170 chunks) - Logic resources
- Memory Controller Guide (250 chunks) - DDR3/DDR4

### 2. Local Libero Documentation
- **Sample TCL Scripts:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl`
- **FPGA Command Reference:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/doc/fpga_command_reference.pdf`
- **Help System:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/doc/libero_help/`

### 3. Project State Tracking
- **`PROJECT_STATE.json`** - Session history, architecture decisions, recent achievements
- **`docs/`** - CLI guides, capabilities matrix, context strategies
- **Read these BEFORE starting new work**

---

## Common TCL Patterns

### Project Creation
```tcl
new_project \
    -location {C:/Microchip/projects/my_project} \
    -name {my_project} \
    -project_description {} \
    -hdl {VERILOG} \
    -family {PolarFire}

configure_tool \
    -name {PLACEROUTE} \
    -params {PDPR:true} \
    -params {EFFORT_LEVEL:true}
```

### Device Configuration
```tcl
set_device \
    -family {PolarFire} \
    -die {MPF300TS} \
    -package {FCG1152} \
    -speed {-1} \
    -die_voltage {1.0}
```

### Design Import
```tcl
create_links \
    -hdl_source {./hdl/top.v}

build_design_hierarchy
```

### Build Flow
```tcl
run_tool -name {COMPILE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}
run_tool -name {GENERATEPROGRAMMINGDATA}
```

---

## Workflow Guidelines

### 1. Starting a New Task

1. **Read PROJECT_STATE.json** - Understand recent context
2. **Query FPGA MCP Server** - Use MCP tools to search documentation
3. **Review existing TCL scripts** - Don't reinvent patterns
4. **Create checklist** - Break task into steps
5. **Execute autonomously** - Minimize user asks

### 2. Handling Build Failures

**DO NOT immediately ask user. Instead:**

1. Check Libero log files (`.log` in project directory)
2. **Query FPGA MCP Server for error message or related topics**
3. Attempt common fixes:
   - Missing constraints → generate from template
   - Synthesis errors → check Verilog syntax
   - P&R failures → review timing constraints
   - Resource overflow → check device utilization
4. Only escalate if recovery attempts fail (3 tries)

### 3. File Operations

**IMPORTANT:** WSL↔Windows path conversions
- WSL path: `/mnt/c/Microchip/...`
- Windows path: `C:/Microchip/...`
- Libero TCL requires Windows paths in scripts

**Auto-convert when:**
- Passing paths to Libero commands
- Reading/writing Libero project files
- Invoking Windows tools from WSL

### 4. Code Quality Standards

**Every TCL script needs:**
- Header comment with purpose
- Input parameter documentation
- Error handling with `catch` blocks
- Return status codes (0 = success, 1 = error)

**Example:**
```tcl
# Purpose: Create PolarFire project with MI-V soft processor
# Args: PROJECT_NAME, DEVICE_PACKAGE
# Returns: 0 on success, 1 on error

if {[catch {
    new_project -location "C:/projects/$PROJECT_NAME" ...
} result]} {
    puts "ERROR: Project creation failed - $result"
    return 1
}
return 0
```

---

## Agent Capabilities Optimization (GPT-4.1)

### Multi-Step Task Pattern

**For tasks requiring 3+ steps:**

```
[Internal Checklist]
☐ Step 1: Query FPGA MCP for relevant documentation
☐ Step 2: Read existing project structure
☐ Step 3: Generate TCL script from template
☐ Step 4: Execute script and verify output
☐ Step 5: Check build logs for errors
☐ Step 6: Commit working changes

[Execution]
Executing step 1... ✓ Found DDR4 controller documentation
Executing step 2... ✓
...

[Summary]
Completed all 6 steps. Project created successfully.
Files modified: tcl_scripts/create_fpga_project.tcl
Build status: PASSED (0 errors, 2 warnings)
```

### Error Recovery Example

```
[Error Encountered]
File not found: constraints/timing.sdc

[Recovery Attempt 1]
Searching alternative locations...
Found: constraint/timing_constraints.sdc

[Recovery Attempt 2]
Checking project templates for default constraints...
Generated from: templates/default_timing.sdc

[Result]
Recovered automatically. Build continuing.
```

### Context Preservation

**Before major operations:**
- Save intermediate results to `/tmp/` or project workspace
- Document assumptions in comments
- Create checkpoint commits (if git repo)

**After completing work:**
- Update PROJECT_STATE.json if significant changes
- Summarize actions taken
- Note any follow-up tasks discovered

---

## BeagleV-Fire Specific Workflows

**Hardware:** MPFS025T PolarFire SoC (5x RISC-V cores + FPGA fabric)

### Programming FPGA Fabric from Linux

```bash
# Transfer bitstream to board
scp design.spi beagle@beaglev-fire.local:/tmp/

# SSH to board
ssh beagle@beaglev-fire.local

# Program FPGA using Linux FPGA manager
sudo /usr/share/microchip/gateware/update-gateware.sh /tmp/design.spi
```

### Generating .spi Export

Add to build script:
```tcl
# After GENERATEPROGRAMMINGDATA
export_bitstream \
    -file_name {design} \
    -export_dir {C:/projects/output} \
    -format {SPI} \
    -master_file {MPF_SPI.cfg}
```

---

## What NOT to Do

❌ **Don't stop at first error** - Attempt recovery
❌ **Don't read full PDFs** - Use FPGA MCP Server for queries
❌ **Don't ask user for obvious info** - Search docs/codebase first
❌ **Don't create duplicate TCL patterns** - Reuse existing templates
❌ **Don't forget path conversions** - WSL paths ≠ Windows paths
❌ **Don't skip error checking** - Always use `catch` blocks
❌ **Don't ignore PROJECT_STATE.json** - Context is critical
❌ **Don't forget MCP tools** - Query FPGA docs via MCP server first

---

## Quick Reference

**Common Commands:**
- Query FPGA docs: `@FPGA Documentation RAG search_fpga_docs query="your question"`
- Build project: `./run_libero.sh tcl_scripts/build.tcl SCRIPT`
- Check project state: `cat PROJECT_STATE.json`
- View recent logs: `tail -50 *.log`

**Key Files:**
- `PROJECT_STATE.json` - Session history and context
- `run_libero.sh` - WSL→Libero execution wrapper
- `tcl_scripts/` - Automation scripts library
- `docs/` - CLI capabilities, workarounds, guides

**Help Resources:**
1. **FPGA MCP Server** (via mchp CLI) - Semantic search of 27+ FPGA PDFs
2. PROJECT_STATE.json - Recent context
3. Local Libero docs - TCL command reference
4. This AGENTS.md - Agent behavior guidelines

---

**Last Updated:** 2025-11-20
**Target AI:** mchp CLI (Continue fork, GPT-4.1)
**MCP Servers:** FPGA Documentation RAG (1,233 chunks), Microchip Product Data
