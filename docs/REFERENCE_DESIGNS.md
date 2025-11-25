# PolarFire Reference Design Corpus Guide

**Last Updated:** 2025-11-25

**Corpus Size:** 1,549 TCL files across 64 reference designs (analyzed by codex)

**Purpose:** Guide to using the 64-design corpus for pattern mining and best practices

---

## Overview

This document explains how to leverage the comprehensive analysis of 64 PolarFire reference designs to improve your TCL scripting practices.

**Corpus Statistics:**
- **Total TCL files:** 1,549
- **Design count:** 64
- **Component-first bias:** 9.6:1 ratio (IP cores vs raw HDL instantiation)
- **Numbered topology:** 58+ designs use 1_create, 2_constrain, 4_implement, 5_program pattern
- **VERIFYTIMING usage:** 49+ designs insert timing gate before bitstream generation
- **Constraint linking:** 44+ designs use create_links + organize_tool_files pattern

---

## Corpus Access

### Indices and Summaries

**Primary references:**
- `docs/ref_designs/tcl_index.json` - Per-design TCL count, Libero version, entry candidates
- `docs/ref_designs/tcl_deep_dive.md` - Pattern analysis and best practices
- `docs/ref_designs/tcl_reusable_patterns.md` - Drop-in code snippets
- `docs/ref_designs/tcl_consensus.md` - Statistical analysis
- `docs/ref_designs/claude_passoff.md` - Quick reference cheat sheet

**IP Configuration:**
- `docs/ref_designs/ip_config_index.json` - All create_and_configure_core calls (VLNV, params)
- `docs/ref_designs/ip_config_focus.json` - High-value cores (DDR/XCVR/PCS/JESD/MIPI/HDMI/PLL/CCC)
- `docs/ref_designs/ip_versions.md` - IP version pinning from common.tcl files

**HDL Analysis:**
- `docs/ref_designs/custom_hdl_index.json` - Custom HDL modules per design (non-IP/BFM)
- `docs/ref_designs/custom_hdl_notes.md` - Reusable HDL patterns

**Raw Archives:**
- `ref_designs/` - Raw reference design drops (ignored by git except markdown)
- `ref_designs_hdl/` - Extracted HDL (1,022 files, consider ignoring if repo bloat matters)

---

## Standard TCL Script Topology

### Numbered Script Pattern (58+ designs)

**Standard structure:**
```
project/
├── src/
│   ├── components/          # IP/SmartDesign TCL configs
│   │   ├── PF_CCC_C0.tcl
│   │   ├── CORERESET_PF_C0.tcl
│   │   └── top.tcl          # SD aggregator
│   └── hdl/                 # Custom RTL
├── constraint/
│   ├── io.pdc
│   └── timing.sdc
├── common.tcl               # IP version pins, project variables
├── 1_create_design.tcl      # Project + HDL import
├── 2_constrain_design.tcl   # PDC/SDC linking
├── [3_*.tcl]                # Reserved for variants (optional)
├── 4_implement_design.tcl   # SYNTH → PLACE → VERIFYTIMING → GENFILE
└── 5_program_design.tcl     # export_prog_job + save
```

**Numbered step rationale:**
- **1** - Creation: Import HDL, source components, set root
- **2** - Constraints: create_links + organize_tool_files
- **3** - Reserved: Multi-variant configurations (Low_Power/Normal, 64b66b/8b10b)
- **4** - Implementation: Full build flow with timing gate
- **5** - Programming: Bitstream export and packaging

**Key insight:** Step 3 is intentionally skipped in single-variant flows, allowing easy addition of variants later without renumbering.

---

## Component-First Design Philosophy

**Finding:** 9.6:1 ratio of IP core instantiation vs raw HDL instantiation

**What this means:**
- Reference designs heavily prefer `create_and_configure_core` + `sd_instantiate_component`
- `sd_instantiate_hdl_module` used sparingly (< 10% of instantiations)
- Small custom blocks only: pattern generators, PRBS checkers, simple glue logic

**Why this matters:**
- IP cores get full configuration support (GUI-like in TCL)
- Avoids sub-module hierarchy issues entirely
- Better version management and parameterization
- Easier maintenance and updates

**When to deviate:**
- Very simple leaf modules with no parameters
- Custom logic that doesn't fit IP catalog
- Performance-critical handcrafted blocks

---

## Critical Patterns from Corpus

### 1. VERIFYTIMING Gate (49+ designs)

**Pattern:**
```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}  # <- CRITICAL: catches timing issues early
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}
```

**Why it matters:**
- Catches timing closure failures BEFORE spending time on bitstream generation
- Standard practice in production flows
- Prevents surprise failures late in build

**Where to add:** Between PLACEROUTE and GENERATEPROGRAMMINGDATA

### 2. Constraint Linking (44+ designs)

**Pattern:**
```tcl
# Step 1: Register files with project
create_links -io_pdc {C:/path/io.pdc}
create_links -sdc {C:/path/timing.sdc}

# Step 2: Associate with BOTH tools (SDC to both!)
organize_tool_files -tool {SYNTHESIZE} -file {C:/path/timing.sdc} -module {top} -input_type {constraint}
organize_tool_files -tool {PLACEROUTE} -file {C:/path/timing.sdc} -module {top} -input_type {constraint}
organize_tool_files -tool {PLACEROUTE} -file {C:/path/io.pdc} -module {top} -input_type {constraint}
```

**Why it matters:**
- `import_files` alone is NOT sufficient - constraints won't be used!
- SDC must be associated with BOTH SYNTHESIZE and PLACEROUTE
- PDC typically only for PLACEROUTE

**Error if missing:** "No timing constraint associated" or "No User PDC file specified"

### 3. IP Version Pinning (common.tcl pattern)

**Pattern:**
```tcl
# common.tcl - Shared across all numbered scripts
set project_name "my_design"
set project_location "C:/projects"
set projectDir "$project_location/$project_name"

# IP Version Definitions (Libero 2024.2)
set PF_DDR4_ver {3.9.200}
set PF_CCC_ver {3.5.100}
set CORERESET_PF_ver {5.1.100}
set MIV_RV32_ver {3.1.200}

# Usage in component scripts
create_and_configure_core \
    -core_vlnv "Actel:SgCore:PF_CCC:${PF_CCC_ver}" \
    -component_name {PF_CCC_C0}
```

**Why it matters:**
- Centralizes version management
- Easy to update when changing Libero versions
- Documents which IP versions were tested together
- Improves reproducibility across installations

**Where to find:** See `docs/ref_designs/ip_versions.md` for ready-to-use version blocks

---

## Top-10 High-Value Reference Designs

These designs demonstrate advanced patterns worth studying:

### 1. **mpf_dg0757_df** - Multi-lane HSIO
- **Focus:** SERDES, PRBS, bit-slip control
- **Patterns:** Bank control, pattern generators/checkers
- **TCL highlights:** Multi-variant flow (64b66b vs 8b10b)

### 2. **mpf_an5454_v2024p2_df** - Video pipeline
- **Focus:** DDR arbiters, video packetization, PISO/SIPO
- **Patterns:** Large SmartDesign phased sourcing
- **TCL highlights:** Logical component grouping with intermediate hierarchy rebuilds

### 3. **mpf_an5270_v2025p1_df** - 4K video/MIPI/HDMI
- **Focus:** High-bandwidth video, IP-heavy design
- **Patterns:** Mostly IP-wrapped, minimal custom HDL
- **TCL highlights:** Clean numbered topology, excellent constraint organization

### 4. **mpf_dg0843_df** - PCIe + DDR integration
- **Focus:** High-speed interfaces, complex clocking
- **Patterns:** CCC configuration, multi-clock domains
- **TCL highlights:** Comprehensive SDC with cross-domain constraints

### 5. **mpf_an4662_df** - SERDES bring-up
- **Focus:** Bit-slip, PRBS testing, FabUART
- **Patterns:** Test pattern generation and checking
- **TCL highlights:** Debugging-focused design with observation ports

### 6. **mpf_dg0799_eval_df** - HSIO eval
- **Focus:** Multiple SERDES configurations
- **Patterns:** Variant flow (different lane configs)
- **TCL highlights:** Shared component reuse across variants

### 7. **mpf_an4597_df** - PCIe + DDR helpers
- **Focus:** Memory controller integration
- **Patterns:** AXI interconnect, memory arbitration
- **TCL highlights:** Modular component organization

### 8. **mpf_an4661_v2024p1_eval_df** - Math/MACC
- **Focus:** LSRAM/MACC cascades, pattern checkers
- **Patterns:** Fabric resource optimization
- **TCL highlights:** Resource-aware IP configuration

### 9. **BeagleV-Fire reference designs**
- **Focus:** PolarFire SoC, embedded Linux + FPGA fabric
- **Patterns:** HSS/U-Boot integration, Microprocessor Subsystem (MSS)
- **TCL highlights:** Complete system-on-chip examples

### 10. **MI-V reference designs**
- **Focus:** RISC-V softcore integration
- **Patterns:** TCM, JTAG debug, peripheral integration
- **TCL highlights:** Component-only design (zero sd_instantiate_hdl_module!)

---

## Multi-Variant Flow Patterns

**Problem:** How to maintain multiple design configurations (different modes/speeds/protocols) without duplicating everything?

**Solution from corpus:**

```
project/
├── HW/
│   ├── 64b66b/
│   │   ├── 1_create_design.tcl    # Variant-specific
│   │   ├── 2_constrain_design.tcl # Variant-specific
│   │   ├── 4_implement_design.tcl # Can be shared or variant-specific
│   │   └── 5_program_design.tcl   # Variant-specific (different export names)
│   └── 8b10b/
│       ├── 1_create_design.tcl
│       └── ... (similar structure)
├── src/
│   └── components/                 # SHARED across variants
│       ├── common.tcl              # Shared variables
│       ├── PF_CCC_C0.tcl          # Shared IP configs
│       └── PF_XCVR_C0.tcl
```

**Key insights:**
- Reuse component configurations where possible
- Separate constraint sets per variant (different clocking/pinout)
- Shared common.tcl for IP versions
- Variant folders keep builds isolated

**Benefits:**
- Easy A/B testing and comparison
- Reduced duplication
- Clear organization
- Simple to add new variants

---

## HDL Reuse Opportunities

**Custom HDL worth lifting from corpus:**

### SERDES/HSIO Blocks
- **Designs:** mpf_dg0757_df, mpf_dg0843_df, mpf_dg0799_eval_df
- **Modules:** PRBS generators/checkers, bit-slip controllers, lane alignment
- **Use cases:** High-speed serial interface bring-up and testing

### Video Processing
- **Designs:** mpf_an5454_v2024p2_df, mpf_an5270_v2025p1_df
- **Modules:** Packetization, PISO/SIPO, DDR read/write controllers, Bayer/histogram/gamma
- **Use cases:** Video pipelines, image processing

### Communication Interfaces
- **Designs:** mpf_an4662_df
- **Modules:** FabUART, pattern_gen/chk variants
- **Use cases:** Debugging, test infrastructure

### Memory Arbitration
- **Designs:** mpf_an5454_v2024p2_df, mpf_an4597_df
- **Modules:** DDR arbiters, AXI interconnect glue
- **Use cases:** Multi-master DDR access

**Location:** See `docs/ref_designs/custom_hdl_index.json` for module → file mappings

---

## SmartDesign Best Practices from Corpus

### 1. Generate → set_root → save Ordering

**Standard pattern (appears in 60+ designs):**
```tcl
build_design_hierarchy              # Rebuild hierarchy
save_smartdesign -sd_name {TOP}     # Save SD definition
generate_component -component_name {TOP}  # Generate component
set_root -module {TOP::work}        # Set as top-level
save_project                        # Save project
```

**Why this order matters:**
- Hierarchy must be built before generation
- Generation must complete before setting root
- Save after setting root ensures persistence

### 2. Phased Component Sourcing (Large Designs)

**Pattern from video/HSIO designs:**
```tcl
# Phase 1: Clock/Reset infrastructure
source ./src/components/PF_CCC_C0.tcl
source ./src/components/CORERESET_PF_C0.tcl
build_design_hierarchy
save_project

# Phase 2: MSS/Processor (if applicable)
source ./src/components/MIV_RV32_C0.tcl
build_design_hierarchy
save_project

# Phase 3: Peripherals/PHY
source ./src/components/PF_DDR4_C0.tcl
source ./src/components/PF_XCVR_C0.tcl
build_design_hierarchy
save_project

# Phase 4: Top-level aggregation
source ./src/components/top.tcl
build_design_hierarchy
set_root -module {top::work}
save_project
```

**Benefits:**
- Avoids dependency issues in complex designs
- Easier debugging (isolate failures to specific phase)
- Better progress visibility during long builds

### 3. Component-First, HDL-Leaf Strategy

**Key insight from 9.6:1 ratio:**

Prefer this:
```tcl
# IP cores via create_and_configure_core
source ./src/components/PF_CCC_C0.tcl      # Clock IP
source ./src/components/CORERESET_PF_C0.tcl # Reset IP
sd_instantiate_component -component_name {PF_CCC_C0}
sd_instantiate_component -component_name {CORERESET_PF_C0}
```

Over this:
```tcl
# Raw HDL instantiation (use sparingly!)
sd_instantiate_hdl_module -hdl_module_name {clock_gen} -hdl_file {hdl/clock_gen.v}
sd_instantiate_hdl_module -hdl_module_name {reset_ctrl} -hdl_file {hdl/reset_ctrl.v}
```

**Why:**
- IP cores have full configuration support
- No sub-module hierarchy issues
- Better version management
- Easier maintenance

**When to use HDL modules:** Only for simple leaf blocks with no parameters (< 100 lines, no submodules)

---

## IP Configuration Best Practices

### High-Value IP Cores (from ip_config_focus.json)

**DDR Controllers:**
- `PF_DDR3`, `PF_DDR4` - Memory interface IP
- **Key params:** Data width, clock frequency, CAS latency, training
- **Location:** `docs/ref_designs/ip_config_focus.json` for example configurations

**Clocking:**
- `PF_CCC` (Clock Conditioning Circuit) - PLL/DLL configuration
- **Key params:** Input frequency, output frequencies, phase shifts
- **Pattern:** Always pair with CORERESET_PF

**Transceivers:**
- `PF_XCVR`, `PF_PCIE`, `PF_SERDES` - High-speed serial
- **Key params:** Protocol, lane count, data rate
- **Usage:** Complex configs benefit from GUI generation, then lift TCL

**Video/Display:**
- `PF_HDMI`, `PF_MIPI` - Display interface IP
- **Pattern:** Often combined with DDR for framebuffer access

**Communication:**
- `CoreUARTapb`, `CoreGPIO`, `CoreSPI`, `CoreI2C` - Standard peripherals
- **Pattern:** Simple configs, good candidates for version-agnostic approach

### Version Management Strategy

**Option 1: Explicit versions (production):**
```tcl
# Pin exact versions for reproducibility
set PF_CCC_ver {3.5.100}
create_and_configure_core -core_vlnv "Actel:SgCore:PF_CCC:${PF_CCC_ver}"
```

**Option 2: Version-agnostic (development):**
```tcl
# Let Libero pick latest compatible
create_and_configure_core \
    -core_vlnv "Actel:SgCore:PF_CCC" \
    -download_core
```

**Recommendation:** Use explicit versions in common.tcl for production, version-agnostic during prototyping.

---

## Constraint Organization

### Constraint File Structure (from 44+ designs)

**Standard organization:**
```
constraint/
├── io/
│   ├── io_top.pdc           # Main I/O pin assignments
│   ├── io_ddr.pdc           # DDR-specific pins (if separate)
│   └── io_hsio.pdc          # High-speed I/O pins (if separate)
└── timing/
    ├── timing_clocks.sdc    # Clock definitions
    ├── timing_constraints.sdc  # Input/output delays
    └── timing_exceptions.sdc   # False paths, multi-cycle
```

**Benefits:**
- Modular organization (easier to maintain)
- Clear separation of concerns
- Reusable across variants (with overrides)

### Linking Pattern (REQUIRED)

**From 2_constrain_design.tcl:**
```tcl
# Create links (register with project)
create_links -io_pdc {C:/project/constraint/io/io_top.pdc}
create_links -sdc {C:/project/constraint/timing/timing_clocks.sdc}
create_links -sdc {C:/project/constraint/timing/timing_constraints.sdc}

# Associate with tools (CRITICAL STEP!)
foreach sdc_file [list \
    "C:/project/constraint/timing/timing_clocks.sdc" \
    "C:/project/constraint/timing/timing_constraints.sdc" \
] {
    organize_tool_files -tool {SYNTHESIZE} -file $sdc_file -module {top} -input_type {constraint}
    organize_tool_files -tool {PLACEROUTE} -file $sdc_file -module {top} -input_type {constraint}
}

organize_tool_files -tool {PLACEROUTE} \
    -file {C:/project/constraint/io/io_top.pdc} \
    -module {top} -input_type {constraint}
```

---

## Export and Programming Patterns

### Standard Export Block

**From 5_program_design.tcl:**
```tcl
run_tool -name {GENERATEPROGRAMMINGDATA}
run_tool -name {GENERATEPROGRAMMINGFILE}

# Export for FlashPro/DirectC
export_prog_job \
    -job_file_name $project_name \
    -export_dir "$projectDir/designer/top/export" \
    -bitstream_file_type {TRUSTED_FACILITY}

save_project
```

**Bitstream types from corpus:**
- `TRUSTED_FACILITY` - Most common (production)
- `SPI` - SPI flash programming (e.g., BeagleV-Fire)
- `STAPL` - JTAG programming (less common)

**Export organization:**
```
designer/
└── top/
    └── export/
        ├── project_name.pro      # FlashPro job
        ├── project_name.spi      # SPI flash image (if applicable)
        └── project_name_*.*      # Supporting files
```

---

## How to Use This Guide

**Starting new project:**
1. Check `docs/ref_designs/tcl_index.json` for similar designs
2. Review patterns in `docs/ref_designs/tcl_deep_dive.md`
3. Copy numbered script skeleton from this guide
4. Lift IP versions from `docs/ref_designs/ip_versions.md`
5. Use constraint linking pattern from Section 2 of this guide

**Looking for specific IP config:**
1. Search `docs/ref_designs/ip_config_focus.json` for core name
2. Check parameters used in reference designs
3. Adapt to your requirements

**Need custom HDL:**
1. Check `docs/ref_designs/custom_hdl_index.json` for relevant modules
2. Review `docs/ref_designs/custom_hdl_notes.md` for usage patterns
3. Extract from `ref_designs_hdl/` if needed

**Debugging build issues:**
1. Compare your flow to numbered topology in Section 2
2. Verify constraint linking matches Section 2 pattern
3. Check VERIFYTIMING gate is present (Section 3.1)
4. Review `docs/TCL_MASTERY.md` Part 5 for error fixes

---

## Corpus Maintenance

**Keep archives lightweight:**
- Raw drops in `ref_designs/` ignored by git (except markdown summaries)
- Extracted HDL in `ref_designs_hdl/` can be ignored if repo size matters
- Rely on indices and summaries instead of raw files

**When adding new reference designs:**
1. Extract TCL/HDL using codex patterns
2. Update `tcl_index.json` with entry candidates
3. Document key patterns in `tcl_deep_dive.md`
4. Add notable IP configs to `ip_config_focus.json`
5. Update `ip_versions.md` if new version patterns found

---

## Quick Lookups

**"I need an example of X":**
- **Project creation:** Section 2 (Numbered Script Topology)
- **SmartDesign flow:** Section 6 (SmartDesign Best Practices)
- **Constraint linking:** Section 3.2 (Constraint Linking)
- **Build flow:** Section 3.1 (VERIFYTIMING Gate)
- **IP configuration:** Section 7 (IP Configuration Best Practices)
- **Multi-variant:** Section 5 (Multi-Variant Flow Patterns)

**"Show me working code":**
- `docs/TCL_MASTERY.md` Part 6: Code Snippets
- `docs/ref_designs/tcl_reusable_patterns.md`

**"What are the critical patterns I must not skip?":**
1. VERIFYTIMING gate (Section 3.1)
2. Constraint linking with organize_tool_files (Section 3.2)
3. Import only leaf HDL modules (see `docs/TCL_MASTERY.md` Part 1.3)

---

## References

**Related Documentation:**
- `docs/TCL_MASTERY.md` - Comprehensive TCL guide (consolidated knowledge)
- `docs/TCL_QUICK_REFERENCE.md` - One-page cheat sheet
- `docs/ref_designs/tcl_deep_dive.md` - Pattern analysis
- `docs/ref_designs/tcl_reusable_patterns.md` - Drop-in snippets
- `docs/ref_designs/claude_passoff.md` - Codex's handoff notes

**Corpus Indices:**
- `docs/ref_designs/tcl_index.json` - Entry points per design
- `docs/ref_designs/ip_config_focus.json` - High-value IP configs
- `docs/ref_designs/custom_hdl_index.json` - HDL module → file mapping

**Working Examples:**
- `tcl_scripts/beaglev_fire/` - LED blink (successful synthesis)
- `tcl_scripts/tmr/` - MI-V TMR project

---

**Last Updated:** 2025-11-25
**Corpus analyzed by:** codex
**Maintained by:** tcl_monster project
