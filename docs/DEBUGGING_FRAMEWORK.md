# Debugging Framework Strategy

**Purpose:** Command-line debugging workflow using Identify Debugger and SmartDebug without GUI

**Last Updated:** 2025-10-22

---

## Overview

Traditional FPGA debugging requires GUI-based tools (Identify, SmartDebug). This framework enables:
- **Automated probe insertion** based on signal names or patterns
- **Command-line waveform capture** via Identify console
- **Device programming and health checks** via SmartDebug TCL
- **Analysis scripts** for common debug scenarios

---

## Available Tools

### Identify Debugger
**Location:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/bin/`

**Executables:**
- `identify_debugger.exe` - Full GUI (fallback)
- `identify_debugger_console.exe` - Console mode (CLI)
- `identify_debugger_shell.exe` - Scripting shell

**Key Capabilities:**
- Logic analyzer (capture internal signals)
- Probe insertion into netlist
- Trigger condition configuration
- Waveform capture and export

**Example Designs Available:**
- `/mnt/c/Microchip/Libero_SoC_v2023.1/Identify/examples/`
- Bus demo designs (Verilog, VHDL, mixed)

### SmartDebug
**Location:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/`

**Key Capabilities:**
- JTAG device programming
- Device status interrogation
- Power rail monitoring
- Memory readback and verification
- FPGA fabric access

---

## Phase 1: Identify Debugger CLI Research

**Goal:** Understand Identify TCL API and command-line capabilities

### Research Tasks:
1. **Identify TCL API Documentation**
   - [ ] Search for Identify command reference PDF
   - [ ] Analyze example TCL scripts in `Identify/examples/`
   - [ ] Test basic commands in console mode

2. **Probe Insertion Workflow**
   - [ ] Identify how to specify signals for probing
   - [ ] Understand probe resource requirements
   - [ ] Test automated probe insertion

3. **Trigger Configuration**
   - [ ] Boolean trigger conditions (signal == value)
   - [ ] Pattern matching triggers
   - [ ] Edge-based triggers (rising/falling)

4. **Waveform Capture**
   - [ ] Capture depth configuration
   - [ ] Pre/post-trigger windows
   - [ ] Export formats (VCD, FST, etc.)

### Research Commands:
```bash
# Use agent to research Identify debugger TCL API
/agent-research "Identify Debugger TCL command reference"

# Manually explore examples
ls /mnt/c/Microchip/Libero_SoC_v2024.2/Identify/examples/
```

---

## Phase 2: Probe Insertion Automation

**Goal:** Automatically insert probes based on signal patterns

### Use Cases:
1. **Debug all signals in a module**
   - Probe every signal in `counter::work`
   - Useful for comprehensive module debugging

2. **Debug specific signal patterns**
   - Probe all signals matching `*error*` or `*valid*`
   - Probe state machine signals (`*_state`, `*_next_state`)

3. **Debug clock domain crossings**
   - Automatically find CDC paths
   - Insert probes on both sides of CDC

### Planned Files:
- `tcl_scripts/insert_probes.tcl` - Probe insertion script
- `tools/utilities/probe_config.json` - Probe configuration template

### Example Workflow:
```tcl
# Pseudo-code for probe insertion
source tcl_scripts/insert_probes.tcl

# Insert probes on all signals in counter module
insert_probes_by_module "counter"

# Insert probes matching pattern
insert_probes_by_pattern "*_error" "*_valid"

# Save project with probes
save_project
```

---

## Phase 3: Automated Waveform Capture

**Goal:** Run Identify console mode to capture waveforms without GUI

### Workflow:
1. **Pre-Synthesis:** Insert probes via TCL
2. **Post-Synthesis:** Re-run build with probes included
3. **Programming:** Load bitstream with debug logic
4. **Capture:** Trigger and capture waveforms via console
5. **Analysis:** Parse waveform files for issues

### Planned Files:
- `tcl_scripts/run_identify.tcl` - Console-mode capture script
- `tools/utilities/identify_parser.py` - Parse captured waveforms

### Example Workflow:
```bash
# Program device with debug bitstream
./run_libero.sh tcl_scripts/program_device.tcl SCRIPT

# Run Identify console to capture
/mnt/c/Microchip/.../Identify/bin/identify_debugger_console.exe \
    -script tcl_scripts/run_identify.tcl

# Parse captured waveforms
python tools/utilities/identify_parser.py \
    --waveform output.vcd \
    --check-signals "error,valid,ready"
```

---

## Phase 4: SmartDebug Integration

**Goal:** Device programming, status checks, and diagnostics via TCL

### SmartDebug Capabilities:

#### 1. Device Programming
- Load bitstream (`.stp` or `.job` files)
- Verify programming success
- Read device ID and status

#### 2. Device Interrogation
- Query device family, die, package
- Read security settings
- Check programming status

#### 3. Power Rail Monitoring
- Read voltage levels (VDD, VDDIO)
- Current consumption
- Temperature monitoring

#### 4. Memory Access
- Read/write fabric RAM contents
- Verify initialization data
- Dump memory for analysis

### Planned Files:
- `tcl_scripts/program_device.tcl` - JTAG programming
- `tcl_scripts/smartdebug_query.tcl` - Device status checks
- `tcl_scripts/verify_programming.tcl` - Post-program verification

### Example SmartDebug TCL:
```tcl
# Pseudo-code for SmartDebug automation

# Open programmer
open_programmer

# Select device (auto-detect or specify)
select_device -auto

# Program FPGA
program_device -file "counter_demo.stp"

# Verify programming
if {[verify_device]} {
    puts "Programming successful!"
} else {
    puts "ERROR: Programming failed!"
    exit 1
}

# Read device info
set device_id [read_device_id]
puts "Device ID: $device_id"

# Close programmer
close_programmer
```

---

## Phase 5: Debug Workflows

**Goal:** End-to-end automated debugging for common scenarios

### Workflow 1: Signal Trace
**Scenario:** Capture signals in running design

1. Insert probes on signals of interest
2. Rebuild with debug logic
3. Program device
4. Capture waveforms
5. Parse and analyze

**Script:** `tools/utilities/signal_trace.sh`

### Workflow 2: State Machine Debug
**Scenario:** Debug FSM stuck states or illegal transitions

1. Automatically identify FSM signals (`*_state`)
2. Insert probes on FSM signals
3. Configure triggers for stuck states
4. Capture and report transitions

**Script:** `tools/utilities/debug_fsm.sh`

### Workflow 3: Performance Profiling
**Scenario:** Measure latency or throughput

1. Insert probes on start/end signals
2. Capture timing information
3. Calculate latency statistics

**Script:** `tools/utilities/profile_design.sh`

---

## Integration with Build Flow

### Enhanced Build Script with Debug Options

```tcl
# build_design_with_debug.tcl

# Check if debug mode requested
if {$::debug_mode == 1} {
    puts "Debug mode enabled - inserting probes"
    source tcl_scripts/insert_probes.tcl

    # Insert probes based on configuration
    insert_probes_from_config "probe_config.json"
}

# Run normal build flow
run_tool -name SYNTHESIZE
run_tool -name PLACEROUTE
run_tool -name GENERATEPROGRAMMINGFILE

# If debug mode, also generate Identify database
if {$::debug_mode == 1} {
    export_identify_database "counter_demo.idb"
}
```

**Usage:**
```bash
# Normal build (no debug)
./run_libero.sh tcl_scripts/build_design.tcl SCRIPT

# Build with debug probes
DEBUG_MODE=1 ./run_libero.sh tcl_scripts/build_design_with_debug.tcl SCRIPT
```

---

## Debug Configuration Templates

### Probe Configuration JSON
```json
{
  "probe_sets": [
    {
      "name": "counter_debug",
      "signals": [
        "counter::work/counter",
        "counter::work/led_reg",
        "counter::work/clk_50mhz",
        "counter::work/reset_n"
      ],
      "capture_depth": 1024,
      "trigger": {
        "type": "boolean",
        "condition": "counter == 24'hFFFFFF"
      }
    },
    {
      "name": "error_signals",
      "pattern": "*error*",
      "capture_depth": 512,
      "trigger": {
        "type": "edge",
        "signal": "*error*",
        "edge": "rising"
      }
    }
  ]
}
```

---

## Known Limitations & Workarounds

*This section will be populated as we discover Identify/SmartDebug limitations*

### Potential Challenges:
1. **Identify Console Mode:** May have limited functionality vs. GUI
   - **Workaround:** Research which commands work in console mode

2. **Probe Insertion:** May require GUI for initial setup
   - **Workaround:** Export probe configuration from GUI, replay via TCL

3. **JTAG Compatibility:** WSL may have issues with USB JTAG adapters
   - **Workaround:** Run SmartDebug from Windows side, control via TCL

---

## Success Metrics

- **Probe Insertion Time:** <1 minute for typical design
- **Waveform Capture:** One-command execution
- **Programming Success Rate:** >95% automated
- **Debug Iteration Time:** <5 minutes per cycle (insert probes → capture → analyze)

---

## Recommended Research Agents

Use Claude Code agents to accelerate research:

```bash
# Research Identify TCL API
/agent-research "Microchip Identify Debugger TCL command reference and console mode"

# Research SmartDebug TCL
/agent-research "Microchip SmartDebug TCL programming and device interrogation"

# Explore examples
/agent-scout "/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/examples/"
```

---

**Maintained by:** TCL Monster Project | **Last Updated:** 2025-10-22
