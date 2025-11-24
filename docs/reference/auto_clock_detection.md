# Clock Frequency Detection - Design Decision

**Status:** Auto-detection REJECTED - Manual override implemented instead

## TL;DR

**Decision:** Use simple manual override with clear warnings instead of automatic detection.

**Reason:** Auto-detection is fundamentally unreliable due to variable clock sources, SDC over-constraints, and missing component configuration files in built projects.

## Final Implementation

### What Was Implemented

**1. Bash Wrapper (scripts/generate_hw_platform.sh)**
- Accepts optional 4th parameter for clock frequency
- Shows clear WARNING when using default 50 MHz
- Simple usage: `./script.sh project.prjx SmartDesign [output_dir] [clock_hz]`

**2. Python Generator (scripts/generate_hw_platform.py)**
- Accepts optional 3rd parameter for clock frequency
- Priority system: Command-line > JSON > Default (50 MHz)
- Displays clock source: `[command-line]`, `[auto-detected from design]`, or `[default (50 MHz)]`

**3. User Responsibility**
- User must verify default 50 MHz matches their design
- User can override with 4th parameter if different
- Clear warnings remind user to verify/override

### Usage Examples

```bash
# Use default (shows warning to verify):
./scripts/generate_hw_platform.sh project.prjx MIV_RV32 ./output

# Specify 100 MHz clock:
./scripts/generate_hw_platform.sh project.prjx MIV_RV32 ./output 100000000

# Specify 50 MHz clock (no warning):
./scripts/generate_hw_platform.sh project.prjx MIV_RV32 ./output 50000000
```

### Warning Output

When using default clock:

```
WARNING: Using default 50 MHz clock frequency
         Verify this matches your design!
         Override: ./scripts/generate_hw_platform.sh ... <output_dir> <clock_hz>
```

## Why Auto-Detection Was Rejected

### Attempted Approaches

**Approach 1: Parse SDC Timing Constraints**
- File: `scripts/extract_clock_from_sdc.py` (exploration only)
- Parses `create_clock -period <ns>` commands
- Calculates frequency from period

**Reason for Rejection:**
> "there's a danger to going off the sdc - the user could possibly overconstrain the clock in the sdc to force the timing closing tool to work harder (i.e. constraining to 60Mhz for a 50Mhz clk)"

SDC constraints can be artificially tightened for timing closure, so they don't represent actual clock frequency.

**Approach 2: Parse Component TCL Configuration**
- Attempted to read `GL0_0_OUT_FREQ` parameter from PF_CCC component TCL
- This parameter contains the ACTUAL configured frequency (not over-constrained)

**Reason for Rejection:**
Component TCL configuration files only exist during project generation. Built projects only have:
- `.cxf` - Component configuration (binary/XML)
- `.sdc` - Timing constraints (unreliable per above)
- `.v` - Generated Verilog

The `.tcl` files with `GL0_0_OUT_FREQ` don't exist in built projects.

**Approach 3: Enhanced TCL Export**
- File: `scripts/export_memory_map_with_clock.tcl` (had syntax errors)
- Attempted to inject clock info into JSON during export

**Reason for Rejection:**
Relies on SDC parsing (unreliable) or component TCL files (don't exist).

### Fundamental Issues with Auto-Detection

**1. Not All Designs Use CCC**
> "user might not be using a ccc"

Some designs use:
- External oscillators
- Direct clock inputs
- FCCC instead of PF_CCC
- No clock conditioning at all

**2. Multiple Clock Domains**
- Which clock goes to the processor?
- Different peripherals may use different clocks
- No universal way to trace clock connections

**3. SDC Over-Constraint**
- Timing constraints can be artificially tight
- Example: 60 MHz constraint for 50 MHz actual clock
- Forces tools to work harder for timing closure

**4. Missing Component Configurations**
- Component `.tcl` files don't exist in built projects
- `.cxf` files are complex XML/binary
- No simple, reliable way to extract configured frequency

## Files Created During Exploration

**Kept for Reference:**
- `scripts/extract_clock_from_sdc.py` - SDC parser (works but unreliable)
- `docs/auto_clock_detection.md` - This file (documents decision)

**Not Integrated:**
- `scripts/export_memory_map_with_clock.tcl` - TCL export (had errors)
- `scripts/test_clock_wrapper.tcl` - Test script (not needed)
- `scripts/test_query_clock.tcl` - Test script (not needed)

## Lessons Learned

### What Works
✅ Simple manual override with clear parameter
✅ Prominent warning when using default
✅ User responsibility to verify clock frequency
✅ Backwards compatible (default to 50 MHz)

### What Doesn't Work
❌ Automatic detection from SDC files
❌ Automatic detection from component configs
❌ Assuming all designs use CCC/FCCC
❌ Assuming SDC constraints match actual frequency

### Design Philosophy

**Simplicity over Automation:** When automation is unreliable, don't do it. Make it easy for users to provide the correct value instead.

**Honest Defaults:** Default to 50 MHz with clear warning, rather than pretending to auto-detect an unreliable value.

**User Trust:** Trust users to know their design's clock frequency. They designed it!

## Recommendation for Future

If auto-detection is needed in the future, the only reliable approach would be:

1. **Parse `.cxf` Component Configuration Files**
   - Extract `GL0_0_OUT_FREQ` from XML/binary format
   - More reliable than SDC, but complex parsing required

2. **SmartDesign TCL API**
   - Use native SmartDesign commands to query clock connections
   - Trace clock from processor back to source
   - Requires deep understanding of SmartDesign component graph

3. **User Configuration File**
   - Add `clock_frequency_hz` to project config JSON
   - User specifies once, reused for all builds
   - Simple, reliable, one-time setup

Currently, manual override is the simplest and most reliable approach.

## Summary

**Final Decision:** Manual clock parameter with clear warnings

**Priority:** Command-line parameter > JSON (future) > Default (50 MHz with warning)

**Rationale:** Automation is unreliable due to:
- SDC over-constraints
- Missing component configs in built projects
- Variable clock sources (CCC, FCCC, external, etc.)
- Multiple clock domains

**Result:** Simple, honest, reliable workflow that trusts the user.
