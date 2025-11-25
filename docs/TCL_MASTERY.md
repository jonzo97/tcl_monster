# TCL Mastery - Libero SoC Complete Reference Guide

**Purpose:** Comprehensive guide to Libero TCL automation, consolidating lessons from tcl_monster and analysis of 64 PolarFire reference designs (1,549 TCL files)

**Last Updated:** 2025-11-25

**Quick Navigation:**
- [Part 1: Project Lifecycle](#part-1-project-lifecycle) - Create → Build → Export
- [Part 2: SmartDesign & IP](#part-2-smartdesign--ip) - Component patterns and instantiation
- [Part 3: Constraints](#part-3-constraints) - PDC/SDC linking with organize_tool_files
- [Part 4: Build Flow](#part-4-build-flow) - Tool sequencing with VERIFYTIMING gate
- [Part 5: Error Reference](#part-5-error-reference) - Common issues and solutions
- [Part 6: Code Snippets](#part-6-code-snippets) - Copy-paste patterns

---

## Part 1: Project Lifecycle

### 1.1 Project Creation

**Standard project creation pattern:**

```tcl
new_project \
    -location $project_location \
    -name $project_name \
    -hdl VERILOG \
    -family PolarFire \
    -die MPF300TS \
    -package FCG1152 \
    -speed -1 \
    -die_voltage 1.0 \
    -part_range IND \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1
```

**Critical Lessons:**
- `part_range` values are device-specific (check datasheet)
  - MPF300TS supports: `IND` (Industrial) only
  - Other devices may support: `EXT` (Extended), `COM` (Commercial)
- Remove invalid parameters if not supported by your Libero version
- **ALWAYS use Windows paths** (`C:/`) not WSL paths (`/mnt/c/`)
- Use forward slashes `/` (works in both Windows and Libero TCL)

### 1.2 Importing HDL Sources

**Standard HDL import:**

```tcl
import_files \
    -convert_EDN_to_HDL 0 \
    -library {work} \
    -hdl_source {C:/path/to/file.v}
```

**CRITICAL: Import Order Matters**

Import custom HDL **BEFORE** creating SmartDesign components.

**Numbered script topology** (from 64-design corpus analysis):

```
1_create_design.tcl    - Project + HDL import
2_constrain_design.tcl - Link PDC/SDC with organize_tool_files
[3 reserved for variants]
4_implement_design.tcl - SYNTH → PLACE → VERIFYTIMING → GENFILE
5_program_design.tcl   - export_prog_job + save
```

### 1.3 HDL Module Hierarchy Rules

**CRITICAL: Understanding sd_instantiate_hdl_module limitations**

**Error:** "You cannot instantiate a sub-module 'module_name' of HDL module."

**Root Cause:** When you use `sd_instantiate_hdl_module`, Libero checks if the module is a "top-level" module. If any OTHER imported HDL file instantiates that module, it becomes a "sub-module" and CANNOT be used with `sd_instantiate_hdl_module`.

**Example Scenario:**
```
triple_voter.v          <- Module we want to instantiate in SmartDesign
peripheral_voter.v      <- Instantiates triple_voter (uses it as sub-module!)
```

If both files are imported, `triple_voter` becomes a sub-module and SmartDesign instantiation fails!

**SOLUTION: Only import leaf modules**

```tcl
# Import ONLY leaf modules for SmartDesign instantiation
set hdl_files [list \
    "C:/project/hdl/triple_voter.v" \
    "C:/project/hdl/functional_outputs.v" \
]

# DO NOT IMPORT files that create sub-module relationships:
#   - peripheral_voter.v (instantiates triple_voter)
#   - memory_voter.v (instantiates triple_voter)
#   - top.v (HDL top-level)
```

**Alternative Approaches:**
1. Use separate project variants (SmartDesign vs HDL-only)
2. Create wrapper SmartDesign components around HDL modules
3. Use `sd_instantiate_component` with pre-generated components instead

**Key Insight:** This is why MI-V reference designs ONLY use `sd_instantiate_component` (for Libero IP) and avoid `sd_instantiate_hdl_module` entirely - they prevent the sub-module issue.

### 1.4 HDL Module Parameter Configuration

**CRITICAL: sd_configure_core_instance ONLY works with IP cores**

**Error:** "Cannot configure instance 'INSTANCE_NAME'" with `sd_configure_core_instance`

**Root Cause:** The `sd_configure_core_instance` command ONLY works with IP cores (created via `create_and_configure_core`), NOT with raw HDL modules instantiated via `sd_instantiate_hdl_module`.

**Solutions:**

**Option 1: Create fixed-width module variants** (recommended)
```verilog
// triple_voter_1bit.v - Fixed 1-bit width voter
module triple_voter_1bit (
    input wire input_a,
    input wire input_b,
    input wire input_c,
    output reg voted_output,
    ...
);
```

**Option 2: Use default parameters**
```tcl
# Just instantiate without trying to configure
sd_instantiate_hdl_module -sd_name {TOP} \
    -hdl_module_name {module} \
    -hdl_file {hdl/module.v} \
    -instance_name {INST}
# DON'T call sd_configure_core_instance - it won't work!
```

**Key Insight:** Libero's SmartDesign treats IP cores and HDL modules very differently:
- **IP cores** (sd_instantiate_component): Full GUI/TCL configuration support
- **HDL modules** (sd_instantiate_hdl_module): Instantiate-only, parameters fixed at Verilog level

### 1.5 Design Hierarchy Management

**Standard hierarchy build pattern:**

```tcl
# Build hierarchy after importing HDL
build_design_hierarchy

# Set top-level module
set_root -module {module_name::work}

# Save project
save_project
```

**When to rebuild hierarchy:**
- After importing new HDL files
- Before `generate_component` in SmartDesign
- Before `set_root` after SmartDesign generation
- When adding blocks mid-script

### 1.6 IP Core Instantiation

**Version-agnostic approach (recommended):**

```tcl
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32} \
    -download_core \
    -component_name {CORE_NAME} \
    -params { ... }
```

**IP version pinning (from common.tcl pattern):**

```tcl
# IP Version Definitions (Libero 2024.2)
set PF_DDR4_ver {3.9.200}
set PF_CCC_ver {3.5.100}
set CORERESET_PF_ver {5.1.100}
set MIV_RV32_ver {3.1.200}

# Use in instantiation
create_and_configure_core \
    -core_vlnv "Microsemi:MiV:MIV_RV32:${MIV_RV32_ver}" \
    -component_name {MIV_RV32_C0}
```

**Lessons:**
- Don't hardcode versions across scripts (vary by installation)
- Use `-download_core` flag for automatic download
- Centralize version definitions in `common.tcl`

### 1.7 Build Stages

**Standard build flow:**

```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}
```

**Additional tools:**
```tcl
run_tool -name {SIM_PRESYNTH}     # Pre-synthesis simulation
run_tool -name {SIM_POSTSYNTH}    # Post-synthesis simulation
```

**CRITICAL: VERIFYTIMING gate** (from 64-design corpus - 49+ designs use this)

Always insert `VERIFYTIMING` between PLACEROUTE and bitstream generation. This catches timing closure issues early before spending time on bitstream generation.

### 1.8 Project Management

```tcl
save_project              # Save current state
close_project             # Close project
open_project -file {path} # Reopen existing project
```

**Save frequently:**
- After generating SmartDesign components
- After successful tool runs (SYNTHESIZE, PLACEROUTE)
- Before and after constraint changes

---

## Part 2: SmartDesign & IP

### 2.1 SmartDesign Creation Pattern

**Standard SmartDesign workflow:**

```tcl
# 1. Create SmartDesign
create_smartdesign -sd_name {DESIGN_NAME}

# 2. Open for editing
open_smartdesign -sd_name {DESIGN_NAME}

# 3. Add external ports
sd_create_scalar_port -sd_name {DESIGN_NAME} \
    -port_name {CLK_IN} \
    -port_direction {IN}

sd_create_scalar_port -sd_name {DESIGN_NAME} \
    -port_name {LED_OUT} \
    -port_direction {OUT}

# 4. Instantiate components
sd_instantiate_component -sd_name {DESIGN_NAME} \
    -component_name {PF_CCC_C0} \
    -instance_name {PF_CCC_0}

# 5. Connect pins
sd_connect_pins -sd_name {DESIGN_NAME} \
    -pin_names {"CLK_IN" "PF_CCC_0:REF_CLK_0"}

# 6. Build, save, generate
build_design_hierarchy
save_smartdesign -sd_name {DESIGN_NAME}
generate_component -component_name {DESIGN_NAME}

# 7. Set as root and save project
set_root -module {DESIGN_NAME::work}
save_project
```

### 2.2 SmartDesign Best Practices (from 64-design corpus)

**Generate → set_root → save ordering is consistent:**

```tcl
# ALWAYS follow this order:
build_design_hierarchy              # Step 1: Rebuild hierarchy
generate_component -component_name {TOP}  # Step 2: Generate component
set_root -module {TOP::work}        # Step 3: Set as root
save_project                        # Step 4: Save
```

**Re-build hierarchy timing:**
- Before `generate_component` when adding components
- Before `set_root` after SmartDesign generation
- When instantiating multiple components (rebuild between logical phases)

### 2.3 Component-First Design Philosophy

**Finding from 64-design corpus: 9.6:1 component-first bias**

Reference designs prefer:
- `create_and_configure_core` + `sd_instantiate_component` (96%)
- `sd_instantiate_hdl_module` used sparingly (4%) for small custom blocks

**When to use each:**

**Use sd_instantiate_component when:**
- Working with Libero IP cores (CCC, DDR, PCIe, CoreReset, etc.)
- Need GUI-like configuration support
- Want version control and parameterization
- Building complex designs

**Use sd_instantiate_hdl_module when:**
- Small custom glue logic (pattern generators, PRBS checkers)
- Simple leaf modules with no parameterization needed
- No sub-module relationships exist (see Part 1.3)

### 2.4 Large Design Organization

**Pattern from video/HSIO reference designs:**

Split component sourcing into logical phases with intermediate hierarchy rebuilds:

```tcl
# Phase 1: Clock/Reset
source ./src/components/PF_CCC_C0.tcl
source ./src/components/CORERESET_PF_C0.tcl
build_design_hierarchy

# Phase 2: MSS/Processor
source ./src/components/MIV_RV32_C0.tcl
build_design_hierarchy

# Phase 3: PHY/XCVR
source ./src/components/PF_XCVR_C0.tcl
build_design_hierarchy

# Phase 4: Video/ISP (if applicable)
source ./src/components/video_pipeline.tcl
build_design_hierarchy

# Final: Top-level aggregation
source ./src/components/top.tcl
build_design_hierarchy
set_root -module {top::work}
save_project
```

This avoids dependency issues in complex designs.

### 2.5 Flow Scaffolding Template

**Standard directory structure:**
```
project/
├── src/
│   ├── components/          # IP/SD TCLs
│   │   ├── PF_CCC_C0.tcl
│   │   ├── CORERESET_PF_C0.tcl
│   │   └── top.tcl          # SD aggregator
│   └── hdl/                 # Custom RTL
│       └── custom_module.v
├── constraint/
│   ├── io.pdc
│   └── timing.sdc
├── 1_create_design.tcl
├── 2_constrain_design.tcl
├── 4_implement_design.tcl
└── 5_program_design.tcl
```

**Top-level template (1_create_design.tcl):**

```tcl
# Import HDL leafs first
import_files -hdl_source {./src/hdl/foo.v}
build_design_hierarchy

# Source IP/component configs
source ./src/components/PF_CCC_C0.tcl
source ./src/components/CORERESET_PF_C0.tcl

# Generate SDs and set root
source ./src/components/top.tcl
build_design_hierarchy
set_root -module {top::work}
save_project
```

---

## Part 3: Constraints

### 3.1 CRITICAL: Constraint Linking with organize_tool_files

**Problem:** Simply importing constraint files via `import_files` is NOT sufficient. They must be explicitly associated with build tools.

**Symptoms of missing association:**
- Synthesis uses auto-inferred timing instead of user SDC
- Place & Route runs without user PDC, pins not locked
- Build logs show: "No timing constraint associated" or "No User PDC file specified"

### 3.2 Standard Constraint Linking Pattern

**REQUIRED pattern** (from 44+ reference designs):

```tcl
# Step 1: Create links (registers files with project)
create_links -io_pdc {C:/path/io.pdc}
create_links -sdc {C:/path/timing.sdc}

# Step 2: Associate with BOTH tools (CRITICAL!)
organize_tool_files -tool {SYNTHESIZE} \
    -file {C:/path/timing.sdc} \
    -module {top} \
    -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/path/timing.sdc} \
    -module {top} \
    -input_type {constraint}

# PDC typically only for PLACEROUTE
organize_tool_files -tool {PLACEROUTE} \
    -file {C:/path/io.pdc} \
    -module {top} \
    -input_type {constraint}
```

**Key Points:**
- File path must be Windows format and absolute or relative to project directory
- SDC **MUST** be associated with BOTH {SYNTHESIZE} and {PLACEROUTE}
- PDC typically only associated with {PLACEROUTE}
- Module name must match top-level module (e.g., `{top}` or `{counter::work}`)
- Module name is case-sensitive

### 3.3 organize_tool_files Command Reference

**Syntax:**
```tcl
organize_tool_files -tool {TOOL_NAME} \
                    -file {FILE_PATH} \
                    -module {MODULE_NAME} \
                    -input_type {FILE_TYPE}
```

**Parameters:**
- `-tool`: {SYNTHESIZE}, {PLACEROUTE}, {VERIFYTIMING}, etc.
- `-file`: Path to file (Windows format, relative to project or absolute)
- `-module`: Top-level module name (e.g., `{top}` or `{top::work}`)
- `-input_type`: {constraint}, {hdl_source}, etc.

### 3.4 I/O Constraints (PDC)

**PolarFire PDC syntax:**

```tcl
# CRITICAL: PolarFire uses -io_std NOT -iostd!
set_io -port_name {CLK_IN} \
       -pin_name {H12} \
       -io_std {LVCMOS33} \
       -fixed true \
       -DIRECTION INPUT

set_io -port_name {LED_OUT} \
       -pin_name {E25} \
       -io_std {LVCMOS33} \
       -fixed true \
       -DIRECTION OUTPUT
```

**Common I/O standards:**
- LVCMOS33, LVCMOS25, LVCMOS18, LVCMOS12
- LVDS, LVDS25
- HSTL, SSTL (for DDR)

**Lessons:**
- PolarFire syntax: `-io_std` (NOT `-iostd`)
- Each port needs: pin assignment, I/O standard, direction
- Only constrain ports that ACTUALLY EXIST in the design
- Use `-fixed true` to lock pin placement

### 3.5 Timing Constraints (SDC)

**Standard SDC patterns:**

```tcl
# Clock definition
create_clock -name {CLK_IN} -period 20 -waveform {0 10} [get_ports {CLK_IN}]

# Clock uncertainty
set_clock_uncertainty 0.5 [get_clocks {CLK_IN}]

# Asynchronous reset (false path)
set_false_path -from [get_ports {RST_N_IN}]

# Input delays
set_input_delay -clock {CLK_IN} -max 5.0 [get_ports {DATA_IN}]

# Output delays
set_output_delay -clock {CLK_IN} -max 5.0 [get_ports {DATA_OUT}]

# Multi-cycle paths
set_multicycle_path -from [get_cells {A}] -to [get_cells {B}] 2
```

**Lessons:**
- Only constrain ports/clocks that EXIST in design
- Check SDC references match actual port names
- Async resets: use `set_false_path`
- Keep SDC separate from PDC (Libero requirement)

### 3.6 Verification

**After implementing constraint association, verify:**

```bash
# Check synthesis used correct clock period
cat libero_projects/project/synthesis/design_vm.sdc | grep "create_clock"

# Check build logs
cat libero_projects/project/designer/top/place_route.log | grep "Reading User PDC"
cat libero_projects/project/designer/top/place_route.log | grep "I/O Locked"
```

**Expected results:**
- Synthesis log shows user-defined clock period (not auto-inferred 100 MHz)
- P&R log shows "Reading User PDC file... 0 error(s)"
- P&R log shows "I/O Locked: X | 100.00%"

---

## Part 4: Build Flow

### 4.1 Standard Tool Sequencing

**Flow ordering** (stable across 64-design corpus):

```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}              # CRITICAL: Timing gate
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}
```

### 4.2 VERIFYTIMING Timing Gate (CRITICAL)

**Finding from 64-design corpus:** 49+ designs call `run_tool -name {VERIFYTIMING}` before bitstream/export.

**Why this matters:**
- Catches timing closure issues BEFORE spending time on bitstream generation
- Provides detailed timing reports for debugging
- Prevents surprise failures late in build flow
- Standard practice in production flows

**ALWAYS insert VERIFYTIMING:**

```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}  # <- TIMING GATE (catches closure issues early)
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}
```

### 4.3 Export and Programming File Generation

**Standard export pattern:**

```tcl
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}

export_prog_job \
    -job_file_name $project_name \
    -export_dir $projectDir/designer/top/export \
    -bitstream_file_type {TRUSTED_FACILITY}

save_project
```

**Bitstream file types:**
- `TRUSTED_FACILITY` - Most common for production
- `SPI` - For SPI flash programming (BeagleV-Fire uses this)
- `STAPL` - For JTAG programming

**Export locations:**
- Programming files: `$projectDir/designer/top/export/`
- Job files: Used by FlashPro/DirectC for device programming

### 4.4 Multi-Variant Flow

**Pattern for multiple design configurations:**

Duplicate numbered scripts per mode while reusing shared component TCLs:

```
project/
├── HW/
│   ├── 64b66b/
│   │   ├── 1_create_design.tcl
│   │   ├── 4_implement_design.tcl
│   │   └── 5_program_design.tcl
│   └── 8b10b/
│       ├── 1_create_design.tcl
│       ├── 4_implement_design.tcl
│       └── 5_program_design.tcl
├── src/
│   └── components/          # Shared across variants
│       ├── PF_CCC_C0.tcl
│       └── common.tcl       # IP version pins
```

**Benefits:**
- Reuse component configurations
- Maintain separate constraint sets per variant
- Easy A/B testing and comparison

### 4.5 Incremental Build Strategy

**CRITICAL: Minimum viable design for synthesis**

You CANNOT synthesize a design with:
- Only inputs (CLK, RST)
- Zero outputs
- No observable behavior

**Error:** "A design must contain at least one net"

**Minimum viable design:**
- Clock input
- Reset input
- At least ONE output that depends on internal logic

**Recommended incremental approach:**
1. Start with minimal design: cores + clock/reset + ONE simple output (e.g., heartbeat LED)
2. Validate synthesis passes
3. Add peripherals one at a time
4. Add complex logic
5. Complete full integration

**DON'T try to:**
- Synthesize "just the cores" with zero outputs
- Add everything at once (debug nightmare)
- Skip validation steps

### 4.6 Build Flow Complete Example

**4_implement_design.tcl template:**

```tcl
# Open existing project
open_project -file "$project_location/$project_name.prjx"

# Import and associate constraints (if not done in 2_constrain_design.tcl)
create_links -io_pdc {C:/path/io.pdc}
create_links -sdc {C:/path/timing.sdc}

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

# Run build flow
run_tool -name {SYNTHESIZE}
save_project

run_tool -name {PLACEROUTE}
save_project

run_tool -name {VERIFYTIMING}
save_project

# Check for timing errors before continuing
# (add error checking logic here if needed)

run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}

export_prog_job \
    -job_file_name $project_name \
    -export_dir $projectDir/designer/top/export \
    -bitstream_file_type {TRUSTED_FACILITY}

save_project
close_project
```

---

## Part 5: Error Reference

### 5.1 Project Creation Errors

**Error:** "Parameter 'part_range' value 'EXT' is invalid"
**Fix:** Check device datasheet for supported part ranges. MPF300TS only supports `IND` (Industrial).

**Error:** "Parameter 'default_lib' is not defined"
**Fix:** Remove unsupported parameters from `new_project` command (version-specific).

**Error:** "Parameter 'use_enhanced_constraint_flow' is not defined"
**Fix:** Remove parameter if using older Libero version.

### 5.2 HDL Import Errors

**Error:** "You cannot instantiate a sub-module 'module_name' of HDL module"
**Fix:** Only import leaf HDL modules that will be used directly in SmartDesign. Don't import HDL files that instantiate modules you want to use with `sd_instantiate_hdl_module`. (See Part 1.3)

**Error:** "Cannot configure instance 'INSTANCE_NAME'"
**Fix:** `sd_configure_core_instance` only works with IP cores, not HDL modules. Use fixed-width module variants or default parameters. (See Part 1.4)

### 5.3 SmartDesign Errors

**Error:** "Unable to find top level TMR_TOP in library work"
**Fix:** Ensure `generate_component` and `set_root` were called in SmartDesign creation script.

**Error:** "Component 'TMR_TOP' needs to be generated before running synthesis"
**Fix:** Call `generate_component -component_name {TMR_TOP}` before `run_tool -name {SYNTHESIZE}`.

**Error:** "A design must contain at least one net"
**Fix:** Design has no observable outputs - synthesis optimized everything away. Add at least ONE output port connected to internal logic. (See Part 4.5)

### 5.4 Constraint Errors

**Error:** "Parameter 'iostd' is not defined"
**Fix:** Use `-io_std` (PolarFire syntax) instead of `-iostd`.

**Error:** "10 errors found in SDC file"
**Fix:** Check SDC only references ports that exist in the design (remove references to deleted ports).

**Error:** "No timing constraint has been associated to the 'Place and Route' tool"
**Fix:** Use `organize_tool_files` to associate SDC with PLACEROUTE tool. (See Part 3.2)

**Error:** "No User PDC file(s) was specified"
**Fix:** Use `organize_tool_files` to associate PDC with PLACEROUTE tool. (See Part 3.2)

**Error:** "I/O Locked: 0 (0%)" despite PDC with `-fixed true`
**Fix:** PDC not associated with PLACEROUTE tool via `organize_tool_files`.

### 5.5 Synthesis Errors

**Error:** Synthesis uses auto-inferred 100 MHz clock instead of user SDC
**Fix:** SDC not associated with SYNTHESIZE tool. Use `organize_tool_files` to associate SDC with both SYNTHESIZE and PLACEROUTE. (See Part 3.2)

**Error:** "Syntax error in SDC file"
**Fix:** Check SDC syntax, ensure square brackets are properly escaped in clock definitions.

### 5.6 TCL Syntax Errors

**Error:** "Invalid command name '[1/7]'" in puts statement
**Fix:** Square brackets need escaping in puts:
```tcl
# WRONG: puts "[1/7] Creating..."  # Interpreted as command substitution
# RIGHT: puts "\[1/7\] Creating..."
```

### 5.7 Path Handling Errors

**Error:** "Cannot find file at /mnt/c/..."
**Fix:** Use Windows paths (`C:/`) not WSL paths (`/mnt/c/`) when running Libero. Use forward slashes `/` for compatibility.

### 5.8 Build Flow Errors

**Error:** Timing closure failure after PLACEROUTE
**Fix:** This is why VERIFYTIMING gate exists! Run `run_tool -name {VERIFYTIMING}` before bitstream generation to catch timing issues early.

**Error:** "Export failed - programming data not generated"
**Fix:** Must run `GENERATEPROGRAMMINGDATA` before `GENERATEPROGRAMMINGFILE` and `export_prog_job`.

---

## Part 6: Code Snippets

### 6.1 Complete Project Creation

```tcl
# Define project parameters
set project_name "my_design"
set project_location "C:/projects"
set top_module "top"

# Create project
new_project \
    -location $project_location \
    -name $project_name \
    -hdl VERILOG \
    -family PolarFire \
    -die MPF300TS \
    -package FCG1152 \
    -speed -1 \
    -die_voltage 1.0 \
    -part_range IND \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1

# Import HDL sources (leaf modules only)
import_files -convert_EDN_to_HDL 0 -library {work} \
    -hdl_source {C:/projects/my_design/hdl/module1.v}
import_files -convert_EDN_to_HDL 0 -library {work} \
    -hdl_source {C:/projects/my_design/hdl/module2.v}

build_design_hierarchy
save_project
```

### 6.2 SmartDesign Component Creation

```tcl
# Source IP component configurations
source ./src/components/PF_CCC_C0.tcl
source ./src/components/CORERESET_PF_C0.tcl

# Create top-level SmartDesign
create_smartdesign -sd_name {TOP}
open_smartdesign -sd_name {TOP}

# Add external ports
sd_create_scalar_port -sd_name {TOP} -port_name {CLK_IN} -port_direction {IN}
sd_create_scalar_port -sd_name {TOP} -port_name {RST_N} -port_direction {IN}
sd_create_scalar_port -sd_name {TOP} -port_name {LED_OUT} -port_direction {OUT}

# Instantiate components
sd_instantiate_component -sd_name {TOP} -component_name {PF_CCC_C0} -instance_name {PF_CCC_0}
sd_instantiate_component -sd_name {TOP} -component_name {CORERESET_PF_C0} -instance_name {RESET_0}

# Connect pins
sd_connect_pins -sd_name {TOP} -pin_names {"CLK_IN" "PF_CCC_0:REF_CLK_0"}
sd_connect_pins -sd_name {TOP} -pin_names {"RST_N" "RESET_0:EXT_RST_N"}
sd_connect_pins -sd_name {TOP} -pin_names {"PF_CCC_0:OUT0_FABCLK_0" "RESET_0:CLK"}

# Build, generate, set root
build_design_hierarchy
save_smartdesign -sd_name {TOP}
generate_component -component_name {TOP}
set_root -module {TOP::work}
save_project
```

### 6.3 Constraint Linking (COMPLETE PATTERN)

```tcl
# Create constraint links
create_links -io_pdc {C:/projects/my_design/constraint/io.pdc}
create_links -sdc {C:/projects/my_design/constraint/timing.sdc}

# Associate SDC with BOTH SYNTHESIZE and PLACEROUTE
organize_tool_files -tool {SYNTHESIZE} \
    -file {C:/projects/my_design/constraint/timing.sdc} \
    -module {top} \
    -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/projects/my_design/constraint/timing.sdc} \
    -module {top} \
    -input_type {constraint}

# Associate PDC with PLACEROUTE
organize_tool_files -tool {PLACEROUTE} \
    -file {C:/projects/my_design/constraint/io.pdc} \
    -module {top} \
    -input_type {constraint}
```

### 6.4 Complete Build and Export

```tcl
# Open existing project
open_project -file "C:/projects/my_design/my_design.prjx"

# Run synthesis
run_tool -name {SYNTHESIZE}
save_project

# Run place and route
run_tool -name {PLACEROUTE}
save_project

# CRITICAL: Timing gate
run_tool -name {VERIFYTIMING}
save_project

# Generate programming files
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}

# Export for programming
export_prog_job \
    -job_file_name "my_design" \
    -export_dir "C:/projects/my_design/designer/top/export" \
    -bitstream_file_type {TRUSTED_FACILITY}

save_project
close_project

puts "Build complete! Programming files at: designer/top/export/"
```

### 6.5 IP Core Creation with Version Pinning

```tcl
# Common IP versions (from common.tcl pattern)
set PF_CCC_ver {3.5.100}
set CORERESET_PF_ver {5.1.100}
set MIV_RV32_ver {3.1.200}

# Create CCC (Clock Conditioning Circuit)
create_and_configure_core \
    -core_vlnv "Actel:SgCore:PF_CCC:${PF_CCC_ver}" \
    -download_core \
    -component_name {PF_CCC_C0} \
    -params { \
        "INIT:0x01" \
        "MODE_EN:true" \
        "OUT0_FABCLK_EN:true" \
        "OUT0_FABCLK_FREQ:50" \
    }

# Create CoreReset
create_and_configure_core \
    -core_vlnv "Actel:DirectCore:CORERESET_PF:${CORERESET_PF_ver}" \
    -download_core \
    -component_name {CORERESET_PF_C0}

# Create MI-V RV32
create_and_configure_core \
    -core_vlnv "Microsemi:MiV:MIV_RV32:${MIV_RV32_ver}" \
    -download_core \
    -component_name {MIV_RV32_C0} \
    -params { \
        "M_EXT:true" \
        "C_EXT:true" \
        "DEBUGGER:true" \
        "TCM_PRESENT:true" \
    }
```

### 6.6 Numbered Script Skeleton

**1_create_design.tcl:**
```tcl
# Project creation + HDL import
source common.tcl
new_project -location $project_location -name $project_name ...
import_files -hdl_source {./src/hdl/foo.v}
build_design_hierarchy
source ./src/components/PF_CCC_C0.tcl
source ./src/components/CORERESET_PF_C0.tcl
source ./src/components/top.tcl
build_design_hierarchy
set_root -module {top::work}
save_project
```

**2_constrain_design.tcl:**
```tcl
# Constraint linking
source common.tcl
open_project -file "$project_location/$project_name.prjx"
create_links -io_pdc {C:/path/io.pdc}
create_links -sdc {C:/path/timing.sdc}
organize_tool_files -tool {SYNTHESIZE} -file {C:/path/timing.sdc} -module {top} -input_type {constraint}
organize_tool_files -tool {PLACEROUTE} -file {C:/path/timing.sdc} -module {top} -input_type {constraint}
organize_tool_files -tool {PLACEROUTE} -file {C:/path/io.pdc} -module {top} -input_type {constraint}
save_project
```

**4_implement_design.tcl:**
```tcl
# SYNTH → PLACE → VERIFYTIMING → GENFILE
source common.tcl
open_project -file "$project_location/$project_name.prjx"
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}
save_project
```

**5_program_design.tcl:**
```tcl
# export_prog_job + save
source common.tcl
open_project -file "$project_location/$project_name.prjx"
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}
export_prog_job -job_file_name $project_name \
    -export_dir $projectDir/designer/top/export \
    -bitstream_file_type {TRUSTED_FACILITY}
save_project
close_project
```

**common.tcl:**
```tcl
# Shared project variables and IP versions
set project_name "my_design"
set project_location "C:/projects"
set projectDir "$project_location/$project_name"

# IP Version Definitions (Libero 2024.2)
set PF_CCC_ver {3.5.100}
set CORERESET_PF_ver {5.1.100}
set MIV_RV32_ver {3.1.200}
```

---

## Quick Reference

### Essential Commands Checklist

**Project:**
- `new_project` - Create project
- `open_project` - Open existing
- `save_project` - Save state
- `close_project` - Close

**HDL:**
- `import_files -hdl_source` - Import HDL
- `build_design_hierarchy` - Build hierarchy
- `set_root -module` - Set top module

**SmartDesign:**
- `create_smartdesign` - Create SD
- `open_smartdesign` - Open SD
- `sd_create_scalar_port` - Add port
- `sd_instantiate_component` - Add IP
- `sd_instantiate_hdl_module` - Add HDL
- `sd_connect_pins` - Connect
- `save_smartdesign` - Save SD
- `generate_component` - Generate

**IP:**
- `create_and_configure_core` - Create IP

**Constraints:**
- `create_links` - Link constraint files
- `organize_tool_files` - Associate with tools (CRITICAL!)

**Build:**
- `run_tool -name {SYNTHESIZE}` - Synthesis
- `run_tool -name {PLACEROUTE}` - P&R
- `run_tool -name {VERIFYTIMING}` - Timing check
- `run_tool -name {GENERATEPROGRAMMINGDATA}` - Gen data
- `run_tool -name {GENERATEPROGRAMMINGFILE}` - Gen file
- `export_prog_job` - Export for programming

### Common Gotchas

❌ **WRONG:**
- Import all HDL files (creates sub-module issues)
- Use `sd_configure_core_instance` on HDL modules
- Skip `organize_tool_files` (constraints not used!)
- Skip `VERIFYTIMING` (timing surprises late)
- Use WSL paths (`/mnt/c/`) in Libero scripts
- Use `-iostd` on PolarFire (should be `-io_std`)

✅ **CORRECT:**
- Import only leaf HDL modules for SmartDesign
- Use fixed-width HDL variants instead of parameters
- Always use `organize_tool_files` for constraints
- Always insert `VERIFYTIMING` gate before bitstream
- Use Windows paths (`C:/`) with forward slashes
- Use `-io_std` on PolarFire

---

## References

**Source Documents:**
- `docs/reference/libero_build_flow_lessons.md` - Build flow and common errors
- `docs/lessons_learned/constraint_association.md` - Constraint linking deep dive
- `docs/ref_designs/tcl_deep_dive.md` - 64-design corpus analysis
- `docs/ref_designs/tcl_reusable_patterns.md` - Drop-in code snippets
- `docs/ref_designs/claude_passoff.md` - Quick reference from codex analysis
- `.claude/CLAUDE.md` - Project overview and command patterns

**External Resources:**
- Libero sample script: `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl`
- FPGA command reference: `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/doc/fpga_command_reference.pdf`
- Libero help: `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/doc/libero_help/`

**Working Examples:**
- `tcl_scripts/beaglev_fire/` - LED blink design (successful synthesis)
- `tcl_scripts/tmr/` - TMR project (work in progress)

---

**Last Updated:** 2025-11-25
**Maintained by:** tcl_monster project
**Status:** Active - add lessons as discovered
