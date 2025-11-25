# TCL Quick Reference - One-Page Cheat Sheet

**Last Updated:** 2025-11-25

**For comprehensive guide, see:** `docs/TCL_MASTERY.md`

---

## Project Lifecycle (Standard Flow)

```
new_project → import_files → build_design_hierarchy →
[SmartDesign] → create_links → organize_tool_files →
run_tool SYNTHESIZE → PLACEROUTE → VERIFYTIMING →
GENERATEPROGRAMMINGDATA → GENERATEPROGRAMMINGFILE → export_prog_job
```

---

## Numbered Script Topology (64-design standard)

```
1_create_design.tcl    - Project + HDL import
2_constrain_design.tcl - Link PDC/SDC with organize_tool_files
[3 reserved for variants]
4_implement_design.tcl - SYNTH → PLACE → VERIFYTIMING → GENFILE
5_program_design.tcl   - export_prog_job + save
```

---

## Critical Gotchas (Most Common Errors)

| WRONG ❌ | CORRECT ✅ |
|----------|-----------|
| Import submodules → | Import only leaf modules |
| Skip organize_tool_files → | Link constraints to BOTH SYNTH & PLACE |
| Skip VERIFYTIMING → | Always insert timing gate |
| Use sd_configure_core_instance on HDL → | Use fixed-width module variants |
| Use -iostd (PolarFire) → | Use -io_std |
| Use /mnt/c/ paths → | Use C:/ Windows paths |

---

## Essential Code Snippets

### Constraint Linking (REQUIRED PATTERN)

```tcl
# Step 1: Create links
create_links -io_pdc {C:/proj/constraints/io.pdc}
create_links -sdc {C:/proj/constraints/timing.sdc}

# Step 2: Associate with tools (BOTH for SDC!)
organize_tool_files -tool {SYNTHESIZE} \
    -file {C:/proj/constraints/timing.sdc} \
    -module {top} -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/proj/constraints/timing.sdc} \
    -module {top} -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/proj/constraints/io.pdc} \
    -module {top} -input_type {constraint}
```

### Build Flow with Timing Gate

```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}  # <- TIMING GATE (CRITICAL!)
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}

export_prog_job \
    -job_file_name $project_name \
    -export_dir $projectDir/designer/top/export \
    -bitstream_file_type {TRUSTED_FACILITY}

save_project
```

### SmartDesign Pattern

```tcl
# Create and configure
create_smartdesign -sd_name {TOP}
open_smartdesign -sd_name {TOP}

# Add ports
sd_create_scalar_port -sd_name {TOP} -port_name {CLK} -port_direction {IN}

# Instantiate components
sd_instantiate_component -sd_name {TOP} \
    -component_name {PF_CCC_C0} -instance_name {CCC_0}

# Connect
sd_connect_pins -sd_name {TOP} -pin_names {"CLK" "CCC_0:REF_CLK_0"}

# Generate (ALWAYS in this order!)
build_design_hierarchy
save_smartdesign -sd_name {TOP}
generate_component -component_name {TOP}
set_root -module {TOP::work}
save_project
```

---

## Where to Go for Help

| Question | Reference |
|----------|-----------|
| "How do I...?" | `docs/TCL_MASTERY.md` |
| "Error: X" | `docs/TCL_MASTERY.md` Part 5: Error Reference |
| "Show code" | `docs/TCL_MASTERY.md` Part 6: Code Snippets |
| "Reference designs?" | `docs/REFERENCE_DESIGNS.md` |
| "64-design corpus?" | `docs/ref_designs/tcl_deep_dive.md` |

---

## Three CRITICAL Patterns (Never Skip!)

### 1. VERIFYTIMING Gate
**Why:** Catches timing closure issues BEFORE wasting time on bitstream generation
**Where:** Between PLACEROUTE and GENERATEPROGRAMMINGDATA
**Source:** 49+ reference designs use this pattern

### 2. organize_tool_files for Constraints
**Why:** Without it, constraints are imported but NOT used by tools
**Where:** After create_links, before run_tool
**Source:** 44+ reference designs require this

### 3. Import Only Leaf HDL Modules
**Why:** Importing submodules breaks sd_instantiate_hdl_module
**Where:** Only import HDL you'll directly instantiate in SmartDesign
**Source:** MI-V reference designs avoid this issue entirely

---

## Quick Diagnostics

**Problem:** Synthesis uses wrong clock period (auto-inferred 100 MHz)
**Fix:** SDC not associated with SYNTHESIZE → Use organize_tool_files

**Problem:** "I/O Locked: 0 (0%)" despite PDC
**Fix:** PDC not associated with PLACEROUTE → Use organize_tool_files

**Problem:** "Cannot instantiate sub-module 'X'"
**Fix:** Don't import HDL files that instantiate module X

**Problem:** "Cannot configure instance 'X'"
**Fix:** sd_configure_core_instance only works on IP cores, not HDL modules

**Problem:** "A design must contain at least one net"
**Fix:** Add at least ONE output port connected to internal logic

---

**For detailed explanations, see:** `docs/TCL_MASTERY.md`
