# Libero Build Flow - Critical Lessons Learned

**Date Created:** 2025-11-23
**Context:** TMR project first synthesis attempt
**Status:** Active learning document - add lessons as discovered

---

## Critical Build Flow Steps (In Order)

### 1. Project Creation

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
    -part_range IND \           # Device-specific! MPF300TS only supports IND, not EXT
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1
```

**Lessons:**
- `part_range` values are device-specific (check datasheet)
- Remove invalid parameters like `default_lib`, `use_enhanced_constraint_flow` if not supported
- Use Windows paths (`C:/`) not WSL paths (`/mnt/c/`)

### 2. Import HDL Files

```tcl
import_files -convert_EDN_to_HDL 0 -library {work} -hdl_source {C:/path/to/file.v}
```

**Lessons:**
- Always use Windows path format
- Import custom HDL before creating SmartDesign components

### 2b. CRITICAL: HDL Module Hierarchy and sd_instantiate_hdl_module

**Error:** "You cannot instantiate a sub-module 'module_name' of HDL module."

**Root Cause:** When you use `sd_instantiate_hdl_module`, Libero checks if the module is a "top-level" module. If any OTHER imported HDL file instantiates that module, it becomes a "sub-module" and CANNOT be used with `sd_instantiate_hdl_module`.

**Example Scenario:**
```
triple_voter.v          <- Module we want to instantiate in SmartDesign
peripheral_voter.v      <- Instantiates triple_voter (uses it as sub-module!)
```

If both files are imported, `triple_voter` becomes a sub-module and SmartDesign instantiation fails!

**SOLUTION:**
1. **Only import HDL modules you will use as TOP-LEVEL in SmartDesign**
2. **Do NOT import any HDL files that instantiate modules you want to use with `sd_instantiate_hdl_module`**

**Correct Import Strategy:**
```tcl
# Import ONLY leaf modules for SmartDesign instantiation
set hdl_files [list \
    "C:/tcl_monster/hdl/tmr/triple_voter.v" \
    "C:/tcl_monster/hdl/tmr/tmr_functional_outputs.v" \
]

# DO NOT IMPORT these (they create sub-module relationships):
#   - peripheral_voter.v (instantiates triple_voter)
#   - memory_voter.v (instantiates triple_voter)
#   - tmr_top.v (HDL top-level that instantiates triple_voter)
```

**Alternative Approaches (when you need both):**
1. Use separate project variants (SmartDesign vs HDL-only)
2. Create wrapper SmartDesign components around HDL modules
3. Use `sd_instantiate_component` with pre-generated Libero components instead

**Key Insight:** This is why the MI-V reference designs ONLY use `sd_instantiate_component` (for Libero IP) and NEVER use `sd_instantiate_hdl_module` - they avoid the sub-module issue entirely by using pre-configured components.

### 2c. CRITICAL: HDL Module Parameter Configuration

**Error:** "Cannot configure instance 'INSTANCE_NAME'" with `sd_configure_core_instance`

**Root Cause:** The `sd_configure_core_instance` command ONLY works with IP cores (created via `create_and_configure_core`), NOT with raw HDL modules instantiated via `sd_instantiate_hdl_module`.

**Symptoms:**
- HDL module instantiates successfully
- Attempting to configure parameters with `sd_configure_core_instance` fails
- Error provides no indication that the command doesn't apply to HDL modules

**SOLUTION:**
For HDL modules with parameters, you have two options:

1. **Create fixed-width module variants** (recommended for small number of widths)
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

2. **Use default parameters** if they match your needs
   ```tcl
   # Just instantiate without trying to configure
   sd_instantiate_hdl_module -sd_name {TOP} -hdl_module_name {module} -hdl_file {hdl/module.v} -instance_name {INST}
   # DON'T call sd_configure_core_instance - it won't work!
   ```

**Key Insight:** Libero's SmartDesign treats IP cores and HDL modules very differently:
- **IP cores** (sd_instantiate_component): Full GUI/TCL configuration support
- **HDL modules** (sd_instantiate_hdl_module): Instantiate-only, parameters fixed at Verilog level

### 3. Create SmartDesign Component

```tcl
create_smartdesign -sd_name {DESIGN_NAME}
open_smartdesign -sd_name {DESIGN_NAME}

# Add ports
sd_create_scalar_port -sd_name {DESIGN_NAME} -port_name {CLK_IN} -port_direction {IN}

# Instantiate components
sd_instantiate_component -sd_name {DESIGN_NAME} -component_name {COMPONENT} -instance_name {INST}

# Connect pins
sd_connect_pins -sd_name {DESIGN_NAME} -pin_names {"CLK_IN" "INST:CLK"}

# Build and generate
build_design_hierarchy
save_smartdesign -sd_name {DESIGN_NAME}
generate_component -component_name {DESIGN_NAME}
set_root -module {DESIGN_NAME::work}
save_project
```

**Lessons:**
- Build hierarchy BEFORE generating component
- Generate component BEFORE setting as root
- Set root AFTER generation: `set_root -module {NAME::work}`
- Save project after generation
- **CRITICAL**: SmartDesign must have at least ONE output port connected to internal logic, or synthesis will optimize everything away!

### 4. Create Constraints (PDC for I/O)

```tcl
# PolarFire uses -io_std NOT -iostd!
set_io -port_name {CLK_IN} -pin_name {H12} -io_std {LVCMOS33} -fixed true -DIRECTION INPUT
```

**Lessons:**
- PolarFire syntax: `-io_std` (NOT `-iostd`)
- Each port needs: pin assignment, I/O standard, direction
- Only constrain ports that ACTUALLY EXIST in the design

### 5. Create Timing Constraints (SDC)

```tcl
create_clock -name {CLK_IN} -period 20 -waveform {0 10} [get_ports {CLK_IN}]
set_clock_uncertainty 0.5 [get_clocks {CLK_IN}]
set_false_path -from [get_ports {RST_N_IN}]
```

**Lessons:**
- Only constrain ports/clocks that EXIST in design
- Check SDC references match actual port names
- Async resets: use `set_false_path`

### 6. Run Build (Synthesis + P&R)

```tcl
open_project -file "$project_location/$project_name.prjx"

# Import constraints
create_links -io_pdc {C:/path/to/design.pdc}
organize_tool_files -tool {PLACEROUTE} -file {C:/path/to/design.pdc} -module {DESIGN_NAME} -input_type {constraint}

create_links -sdc {C:/path/to/timing.sdc}
organize_tool_files -tool {SYNTHESIZE} -file {C:/path/to/timing.sdc} -module {DESIGN_NAME} -input_type {constraint}
organize_tool_files -tool {PLACEROUTE} -file {C:/path/to/timing.sdc} -module {DESIGN_NAME} -input_type {constraint}

# DON'T re-generate if already done in creation script!
# Just run synthesis directly
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}
save_project
```

**Lessons:**
- Don't re-generate SmartDesign component if already done
- Import constraints to BOTH SYNTHESIZE and PLACEROUTE tools
- SDC errors will fail synthesis if "Abort on SDC errors" is enabled

---

## Common Errors and Fixes

### Error: "Parameter 'iostd' is not defined"
**Fix:** Use `-io_std` (PolarFire syntax) instead of `-iostd`

### Error: "Unable to find top level TMR_TOP in library work"
**Fix:** Ensure `generate_component` and `set_root` were called in SmartDesign creation script

### Error: "Component 'TMR_TOP' needs to be generated before running synthesis"
**Fix:** Call `generate_component -component_name {TMR_TOP}` in SmartDesign creation script

### Error: "10 errors found in SDC file"
**Fix:** Check SDC only references ports that exist in the design (remove references to deleted ports)

### Error: "A design must contain at least one net"
**Fix:** Design has no observable outputs - synthesis optimized everything away. Add at least ONE output port connected to internal logic.

---

## Design Methodology Lessons

### Incremental Build Strategy (REQUIRED)

You CANNOT synthesize a design with:
- Only inputs (CLK, RST)
- Zero outputs
- No observable behavior

**Minimum viable design for synthesis:**
- Clock input
- Reset input
- At least ONE output that depends on internal logic

**Recommended incremental approach:**
1. Start with minimal design: cores + clock/reset + ONE simple output (e.g., heartbeat LED)
2. Validate synthesis passes
3. Add peripherals one at a time
4. Add voter logic
5. Complete full TMR integration

**DON'T try to:**
- Synthesize "just the cores" with zero outputs
- Add everything at once (debug nightmare)
- Skip validation steps

---

## Path Handling

**Windows Paths (for Libero):**
- Use: `C:/tcl_monster/hdl/file.v`
- NOT: `/mnt/c/tcl_monster/hdl/file.v`

**In TCL scripts run by Libero:**
- ALL paths must be Windows format
- Use forward slashes `/` (works in both Windows and Libero TCL)

---

## IP Core Instantiation

**Version-agnostic approach (recommended):**
```tcl
create_and_configure_core \
    -core_vlnv {Microsemi:MiV:MIV_RV32} \
    -download_core \
    -component_name {CORE_NAME} \
    -params { ... }
```

**Lessons:**
- Don't specify exact versions (vary by installation)
- Use `-download_core` flag
- Let Libero pick latest compatible version

---

## TCL Syntax Gotchas

**Square brackets need escaping in puts:**
```tcl
# WRONG: puts "[1/7] Creating..."  # Interpreted as command substitution
# RIGHT: puts "\[1/7\] Creating..."
```

---

## References

- This document: `/mnt/c/tcl_monster/docs/libero_build_flow_lessons.md`
- Session notes: `/mnt/c/tcl_monster/docs/sessions/session_2025-11-23_post_compact.md`
- Working examples: `tcl_scripts/beaglev_fire/` (LED blink design - SUCCESSFUL)
