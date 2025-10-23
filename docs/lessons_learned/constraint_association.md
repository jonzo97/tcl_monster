# Lesson Learned: Constraint Association in Libero TCL

**Date:** 2025-10-22
**Issue:** Constraints (SDC, PDC) not automatically associated with build tools
**Solution:** Use `organize_tool_files` command
**Status:** Solved (with limitations)

---

## Problem Statement

When importing constraint files via `import_files`, they are added to the project but NOT automatically associated with build tools (synthesis, place & route). This causes:

1. **Synthesis** uses auto-inferred timing constraints instead of user SDC
2. **Place & Route** runs without user PDC, pins not locked
3. **Build logs** show warnings like:
   - "No timing constraint has been associated to the 'Place and Route' tool"
   - "No User PDC file(s) was specified"

---

## Root Cause

Libero requires explicit association of constraint files with specific build stages using the `organize_tool_files` command. Simply importing files is insufficient.

---

## Solution

### Step 1: Import Constraint Files (Existing Method)

```tcl
# Import files into project (doesn't associate with tools)
import_files -io_pdc "$constraint_dir/io_constraints.pdc"
import_files -sdc "$constraint_dir/timing_constraints.sdc"
```

This adds files to the project structure but doesn't tell build tools to use them.

### Step 2: Associate Files with Build Tools (KEY STEP)

```tcl
# Associate timing constraints (SDC) with synthesis
organize_tool_files -tool {SYNTHESIZE} \
    -file "$project_location/$project_name/constraint/timing_constraints.sdc" \
    -module {counter::work} \
    -input_type {constraint}

# Associate timing constraints (SDC) with place & route
organize_tool_files -tool {PLACEROUTE} \
    -file "$project_location/$project_name/constraint/timing_constraints.sdc" \
    -module {counter::work} \
    -input_type {constraint}

# Associate I/O constraints (PDC) with place & route
organize_tool_files -tool {PLACEROUTE} \
    -file "$project_location/$project_name/constraint/io/io_constraints.pdc" \
    -module {counter::work} \
    -input_type {constraint}
```

**Key Points:**
- File path must be relative to project directory (where files exist after import)
- SDC can be associated with BOTH {SYNTHESIZE} and {PLACEROUTE}
- PDC typically only associated with {PLACEROUTE}
- Module name must match top-level module (e.g., `{counter::work}`)

---

## Results

### Before Fix:
```
Synthesis:
  - Auto-inferred clock: 10ns period (100 MHz) - WRONG

Place & Route:
  - "No User PDC file(s) was specified"
  - I/O Locked: 0 (0%)
  - Timing-driven: OFF
```

### After Fix:
```
Synthesis:
  - User SDC clock: 20ns period (50 MHz) - CORRECT
  - create_clock -period 20.000 [get_ports {clk_50mhz}]

Place & Route:
  - "Reading User PDC file... 0 error(s)"
  - I/O Locked: 10 (100%)
  - All pins placed at correct locations
```

**Verification:**
```bash
# Check synthesis used correct clock period
cat libero_projects/counter_demo/synthesis/counter_vm.sdc | grep "create_clock"
# Output: create_clock -period 20.000 ...  (correct!)

# Check pins locked
# Build log shows: "I/O Locked | 10 | 100.00%" (correct!)
```

---

## Remaining Limitation: Timing-Driven Place & Route

**Issue:** Even with SDC associated to PLACEROUTE, timing-driven mode shows "OFF"

**Attempted Fix:**
```tcl
configure_tool -name {PLACEROUTE} -params {TDPR:true}
```

**Result:** Setting doesn't persist through project save/load cycle

**Root Cause:** Likely Libero CLI limitation - may require:
- Different TCL command
- GUI-only configuration
- Project settings file modification

**Impact:** Low for simple designs
- Design builds correctly with proper constraints
- Pins locked, timing constraints defined
- Just missing timing optimization during P&R
- For 0.01% resource usage, timing easily met anyway

**Future Work:**
- Research alternative TCL commands for timing-driven mode
- Check Libero command reference for P&R configuration
- Consider accepting as GUI-only feature if no solution found

---

## TCL Command Reference

### organize_tool_files

**Purpose:** Associate files with specific build tools

**Syntax:**
```tcl
organize_tool_files -tool {TOOL_NAME} \
                    -file {FILE_PATH} \
                    -module {MODULE_NAME} \
                    -input_type {FILE_TYPE}
```

**Parameters:**
- `-tool`: {SYNTHESIZE}, {PLACEROUTE}, {VERIFYTIMING}, etc.
- `-file`: Path to file (relative to project directory)
- `-module`: Top-level module name with library (e.g., `{counter::work}`)
- `-input_type`: {constraint}, {hdl_source}, etc.

**Example:**
```tcl
organize_tool_files -tool {SYNTHESIZE} \
    -file "./libero_projects/my_proj/constraint/timing.sdc" \
    -module {top::work} \
    -input_type {constraint}
```

---

## Best Practices

1. **Always associate constraints explicitly**
   - Don't assume `import_files` is sufficient
   - Use `organize_tool_files` after importing

2. **Verify constraint association**
   - Check synthesis log for correct clock periods
   - Check P&R log for "Reading User PDC file"
   - Verify I/O locking percentage is 100%

3. **File paths matter**
   - Use paths relative to project directory
   - Files must exist at specified location (after import)
   - Double-check paths if association fails

4. **Module naming**
   - Use `{module_name::work}` format
   - Must match top-level module
   - Case-sensitive

5. **Test incrementally**
   - Associate one constraint at a time
   - Rebuild and verify each step
   - Easier to debug if something breaks

---

## Workarounds for Timing-Driven P&R

Until timing-driven mode is enabled via TCL:

**Option 1: Accept non-timing-driven mode**
- For simple designs with low utilization, timing easily met
- Build completes successfully
- Bitstream works correctly

**Option 2: Manual GUI configuration (one-time)**
- Open project in GUI
- Configure → Tool Profiles → Place and Route
- Enable "Timing Driven" checkbox
- Save project
- Future CLI builds may inherit setting (needs testing)

**Option 3: Project file modification (advanced)**
- Directly edit `.prjx` XML file
- Find PLACEROUTE configuration section
- Add timing-driven parameter
- Risky - may break project

---

## Related Issues

### Issue: Pins not locked despite `-fixed true` in PDC

**Symptom:** PDC has `set_io -pin_name {E25} -fixed true` but build shows "Locked: 0"

**Cause:** PDC not associated with PLACEROUTE tool

**Solution:** Use `organize_tool_files` as shown above

### Issue: Synthesis ignores SDC clock period

**Symptom:** Synthesis uses auto-inferred 100 MHz clock despite SDC specifying 50 MHz

**Cause:** SDC not associated with SYNTHESIZE tool

**Solution:** Use `organize_tool_files` for SYNTHESIZE

---

## Testing Checklist

After implementing constraint association:

- [ ] Synthesis log shows user-defined clock period (not auto-inferred)
- [ ] P&R log shows "Reading User PDC file"
- [ ] P&R log shows "I/O Locked: X | 100.00%"
- [ ] Pin report shows all pins at correct locations per PDC
- [ ] Timing report uses correct clock constraints
- [ ] Build completes successfully
- [ ] Programming file generated

---

## References

- Libero sample script: `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl`
- TCL Monster project: `tcl_scripts/create_project.tcl` (working example)
- Microchip Libero help: Check for `organize_tool_files` documentation

---

**Last Updated:** 2025-10-22
**Affects:** All Libero TCL projects using constraints
**Severity:** High (breaks timing/pin constraints if not addressed)
**Status:** Solved (with timing-driven P&R limitation noted)
