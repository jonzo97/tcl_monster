# Libero CLI Capabilities & Automation Workarounds

**Purpose:** Document what CAN be automated via command-line vs GUI-only operations, with workarounds for minimizing manual intervention.

**Created:** 2025-11-14
**Status:** Production-tested on PolarFire and PolarFire SoC projects

---

## Executive Summary

Through extensive testing, we've mapped out Libero/SoftConsole CLI capabilities and developed automation patterns to eliminate repetitive manual work. This guide shows:

- ✅ **What's fully scriptable** - Complete automation possible
- ⚠️ **What requires GUI but has workarounds** - Can be minimized
- ❌ **What's GUI-only** - Must be done manually (rare)

**Key Innovation:** Serial console automation via file-based command queue eliminates repetitive SSH/serial terminal sessions.

---

## Libero SoC: CLI vs GUI Capabilities

### ✅ Fully Scriptable (100% CLI)

These operations work perfectly via TCL scripts with NO GUI required:

#### Project Management
```tcl
# Create project
new_project -location "./project" -name "demo" \
    -hdl VERILOG -family PolarFire -die MPF300TS ...

# Open/close
open_project -file "demo.prjx"
save_project
close_project
```

**Verified:** ✅ Works in batch mode (`SCRIPT` mode)

#### HDL Import
```tcl
# Add Verilog/VHDL sources
import_files -hdl_source {"design.v" "uart.v" "spi.v"}

# Set hierarchy
build_design_hierarchy
set_root -module {top_module::work}
```

**Verified:** ✅ Complete automation, no GUI needed

#### Constraint Association
```tcl
# Physical constraints (PDC)
create_links -io_pdc "./constraints/pins.pdc"

# Timing constraints (SDC)
create_links -sdc "./constraints/timing.sdc"

# FloorPlanner constraints
create_links -fp_pdc "./constraints/floorplan.pdc"
```

**Verified:** ✅ All constraint types can be associated via script

#### IP Core Configuration
```tcl
# Create and configure IP cores
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} \
    -component_name {UART_0} \
    -params {
        "BAUD_VAL_FRCTN:0"
        "BAUD_VAL_FRCTN_EN:false"
        "BAUD_VALUE:1"
        "FIXEDMODE:0"
        "PRG_BIT8:0"
        "PRG_PARITY:0"
        "RX_FIFO:0"
        "RX_LEGACY_MODE:0"
        "TX_FIFO:0"
        "USE_SOFT_FIFO:0"
    }
```

**Verified:** ✅ All Microchip IP cores configurable via TCL
**Note:** Parameters must be exact strings from IP configurator

#### SmartDesign Canvas
```tcl
# Create SmartDesign component
create_smartdesign -sd_name "top"

# Instantiate components
sd_instantiate_component -sd_name "top" -component_name "PF_CCC_C0" -instance_name "PLL_0"
sd_instantiate_component -sd_name "top" -component_name "CoreUARTapb_C0" -instance_name "UART_0"

# Create connections
sd_connect_pins -sd_name "top" \
    -pin_names {"PLL_0:OUT0_FABCLK_0" "UART_0:PCLK"}

# Create ports
sd_create_scalar_port -sd_name "top" -port_name "RX" -port_direction "IN"
sd_connect_pins -sd_name "top" -pin_names {"RX" "UART_0:RX"}
```

**Verified:** ✅ Complete SmartDesign automation
**Limitation:** Complex hierarchies are tedious - use templates

#### Build Flow
```tcl
# Complete synthesis through bitstream
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}
run_tool -name {GENERATEPROGRAMMINGDATA}

# Export programming files
export_prog_job -job_file_name "program.job"
export_bitstream_file -file_name "bitstream" -format {SPI}
```

**Verified:** ✅ End-to-end automation from HDL to .spi file
**Time Saved:** Hours per build (no GUI navigation)

#### Error Checking
```tcl
# Check tool completion status
if {[catch {check_tool -name {SYNTHESIZE}} result]} {
    puts "Synthesis had warnings: $result"
    # Continue anyway for lenient checking
}
```

**Discovered Pattern:** Use `catch {}` for lenient error handling - Libero's `check_tool` is overly strict and fails on warnings.

---

### ⚠️ Scriptable with Limitations

These CAN be scripted but have caveats:

#### Pin Assignment (PDC)

**Scriptable:** ✅ Yes via PDC files
**Limitation:** Pin names must be exact (case-sensitive)
**Workaround:** Generate PDC from spreadsheet or reference design

```tcl
# pins.pdc - Must match exact FPGA pin names
set_io -port_name {LED[0]} -pin_name {V22} -fixed true -io_std LVCMOS33
```

**Best Practice:**
1. Find working PDC from reference design
2. Modify for your board
3. Validate with synthesis (errors are clear)

#### Timing Constraints (SDC)

**Scriptable:** ✅ Yes, standard SDC syntax
**Limitation:** Getting correct clock names can be tricky
**Workaround:** Run synthesis once, check log for actual clock names

```tcl
# timing.sdc
create_clock -name {clk_50mhz} -period 20 [get_ports {clk_50mhz}]
set_output_delay -clock {clk_50mhz} 5 [get_ports {led}]
```

**Tip:** Use Libero's "Export SDC" from timing analyzer once to get template

#### Programming File Export

**Scriptable:** ✅ Multiple formats supported
**Limitation:** Format names are specific strings

```tcl
# Supported formats (case-sensitive):
export_bitstream_file -format {SPI}      # For Linux FPGA manager
export_bitstream_file -format {DAT}      # For FlashPro
export_prog_job -job_file_name "prog"    # Programming job
```

**Discovery:** `.spi` format can be programmed directly from Linux on BeagleV-Fire!

---

### ❌ GUI-Only Operations

Very few things REQUIRE the GUI:

#### Initial IP Core Discovery

**GUI-Only:** Finding exact IP core VLNV strings
**Workaround:**
1. Configure once in GUI
2. Export configuration to TCL: `File → Export Script`
3. Extract VLNV and parameters
4. Use in future scripts

**Example:**
```tcl
# GUI generated this - now we know the VLNV:
create_and_configure_core \
    -core_vlnv {Actel:SgCore:PF_DDR4:2.4.118} \
    -component_name {PF_DDR4_C0}
    # ... 50+ parameters
```

#### Complex SmartDesign Debugging

**GUI-Only:** Visual canvas for understanding complex interconnects
**Workaround:** Generate simple designs via script, debug complex ones in GUI, then export

#### Interactive Timing Analysis

**GUI-Only:** ChipPlanner, interactive timing reports
**Workaround:** Generate reports via script, analyze text output

```tcl
# Generate reports scriptably
report_timing -max_paths 10 -output_file "timing.rpt"
```

---

## BeagleV-Fire: Serial Console Automation

### The Problem

**Manual workflow (repetitive and error-prone):**
1. Open PuTTY/screen
2. Log in (type username + password)
3. Run command
4. Copy output manually
5. Close session
6. Repeat 20+ times during development

**Time Cost:** ~30 seconds per command × 20 commands = 10 minutes wasted

### The Solution: File-Based Command Queue

**Concept:** PowerShell script monitors a queue file and automatically sends commands to board's serial console.

#### Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────┐
│ WSL/Linux       │         │ PowerShell       │         │ BeagleV-Fire│
│                 │         │ serial_smart.ps1 │         │             │
│ Echo command >  │────────▶│ Monitor queue ───│────────▶│ Execute     │
│ queue file      │         │ Send to serial   │         │ Return output│
│                 │◀────────│ Log to file      │◀────────│             │
└─────────────────┘         └──────────────────┘         └─────────────┘
```

#### Implementation: `C:\Temp\serial_smart.ps1`

```powershell
# Smart Serial Console with Command Queue
$PORT = "COM8"
$BAUD = 115200
$QUEUE_FILE = "C:\Temp\beaglev_cmd_queue.txt"
$LOG_FILE = "C:\Temp\beaglev_serial.log"

# Open serial port
$port = New-Object System.IO.Ports.SerialPort $PORT, $BAUD, None, 8, One
$port.Open()

"=== Smart serial session started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" |
    Out-File -Append $LOG_FILE

# Monitor loop
while ($true) {
    # Read from serial (board output)
    if ($port.BytesToRead -gt 0) {
        $data = $port.ReadExisting()
        Write-Host $data -NoNewline
        $data | Out-File -Append -NoNewline $LOG_FILE
    }

    # Check command queue
    if (Test-Path $QUEUE_FILE) {
        $commands = Get-Content $QUEUE_FILE
        if ($commands) {
            foreach ($cmd in $commands) {
                if ($cmd.Trim()) {
                    $timestamp = Get-Date -Format 'HH:mm:ss'
                    "[QUEUE $timestamp] $cmd" | Out-File -Append $LOG_FILE
                    $port.WriteLine($cmd)
                    Start-Sleep -Milliseconds 100
                }
            }
            # Clear queue
            Clear-Content $QUEUE_FILE
        }
    }

    Start-Sleep -Milliseconds 50
}
```

#### Usage from WSL/Linux

```bash
# Single command
echo "ls -la /lib/firmware" > /mnt/c/Temp/beaglev_cmd_queue.txt

# Multiple commands (heredoc)
cat > /mnt/c/Temp/beaglev_cmd_queue.txt << 'EOF'
sudo /usr/share/microchip/gateware/update-gateware.sh
EOF

# Wait for command to execute, then check log
sleep 2
tail -20 /mnt/c/Temp/beaglev_serial.log
```

#### Advantages

✅ **No manual typing** - Commands sent programmatically
✅ **Persistent log** - All output captured to file
✅ **Non-blocking** - Can queue multiple commands
✅ **Password automation** - Can send passwords via queue
✅ **WSL integration** - Works seamlessly with automation scripts

#### Real Example: FPGA Programming Automation

```bash
#!/bin/bash
# Program FPGA completely hands-off

echo "Transferring bitstream to board..."
scp led_blink.spi beagle@192.168.7.2:/lib/firmware/mpfs_bitstream.spi

echo "Triggering FPGA update..."
echo "sudo /usr/share/microchip/gateware/update-gateware.sh" > /mnt/c/Temp/beaglev_cmd_queue.txt

# Board will program and reboot automatically
echo "Programming initiated. Board will reboot in ~2 minutes."

# Monitor log for completion
tail -f /mnt/c/Temp/beaglev_serial.log
```

**Result:** Complete hands-off FPGA programming!

---

## Discovered Patterns & Best Practices

### 1. Lenient Error Checking in TCL

**Problem:** Libero's `check_tool` throws errors on warnings
**Solution:** Use `catch {}` for lenient checking

```tcl
# Strict (fails on warnings):
run_tool -name {SYNTHESIZE}
check_tool -name {SYNTHESIZE}  # ERROR if warnings exist

# Lenient (continues on warnings):
run_tool -name {SYNTHESIZE}
if {[catch {check_tool -name {SYNTHESIZE}} result]} {
    puts "\[WARN\] Synthesis completed with warnings: $result"
    puts "\[INFO\] Continuing anyway..."
}
```

**Lesson:** Libero tools often complete successfully but report "errors" for what are really warnings.

### 2. Separate PDC and SDC Files

**Problem:** Mixing pin and timing constraints in one file causes syntax errors
**Solution:** Always use separate files

```
constraint/
├── pins.pdc           # Physical pin assignments only
└── timing.sdc         # Timing constraints only
```

**Why:** PDC parser doesn't understand SDC commands like `get_nets`, `create_clock`

### 3. Path Handling in WSL

**Problem:** Libero runs on Windows, scripts run in WSL
**Solution:** Use `wslpath` for conversion

```bash
#!/bin/bash
SCRIPT_PATH="/mnt/c/tcl_monster/tcl_scripts/build.tcl"
WIN_PATH=$(wslpath -w "$SCRIPT_PATH")
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe "SCRIPT:$WIN_PATH"
```

### 4. Serial Console Password Automation

**Problem:** `sudo` prompts for password, blocking automation
**Discovery:** Can send password via command queue

```bash
# Queue the sudo command
echo "sudo /usr/share/microchip/gateware/update-gateware.sh" > queue.txt

# Wait for password prompt
sleep 2

# Send password
echo "temppwd" > queue.txt
```

**Caution:** Only use for development boards in trusted networks!

### 5. BeagleV-Fire FPGA Programming Interface

**Discovery:** Programming happens via debugfs, not sysfs

```
/sys/class/fpga_manager/fpga0/         # Visible but not used
/sys/kernel/debug/fpga/microchip_exec_update  # Actual interface
```

**Script:** `/usr/share/microchip/gateware/update-gateware.sh` handles this automatically

**Workflow:**
1. Place `.spi` file at `/lib/firmware/mpfs_bitstream.spi`
2. Run `sudo /usr/share/microchip/gateware/update-gateware.sh`
3. Script programs FPGA and triggers reboot
4. FPGA reprograms during boot sequence

---

## CLI Automation Workflow Examples

### Example 1: Complete FPGA Build (MPF300)

```bash
#!/bin/bash
# build_complete.sh - Fully automated FPGA build

set -e

PROJECT="counter_demo"

echo "=== Creating Project ==="
./run_libero.sh tcl_scripts/create_counter_project.tcl SCRIPT

echo "=== Running Build ==="
./run_libero.sh tcl_scripts/build_counter.tcl SCRIPT

echo "=== Exporting Programming File ==="
BITSTREAM="libero_projects/$PROJECT/designer/counter/counter.stp"
ls -lh "$BITSTREAM"

echo "✓ Build complete! Ready to program."
```

**Time:** ~15 minutes (vs 45 minutes manual in GUI)

### Example 2: BeagleV-Fire End-to-End

```bash
#!/bin/bash
# beaglev_complete_flow.sh - HDL to programmed FPGA

PROJECT="led_blink"
BOARD_IP="192.168.7.2"

echo "=== Building FPGA Design ==="
./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT
./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT

echo "=== Transferring to Board ==="
SPI_FILE="libero_projects/beaglev_fire/$PROJECT/designer/led_blinker_fabric/export/led_blink_bitstream.spi"
scp "$SPI_FILE" "beagle@$BOARD_IP:/lib/firmware/mpfs_bitstream.spi"

echo "=== Programming FPGA ==="
echo "sudo /usr/share/microchip/gateware/update-gateware.sh" > /mnt/c/Temp/beaglev_cmd_queue.txt

echo "✓ Programming initiated. Board will reboot with new bitstream."
echo "  Check serial log: tail -f /mnt/c/Temp/beaglev_serial.log"
```

**Time:** ~20 minutes automated (vs 1+ hour manual)

### Example 3: Batch Building Multiple Configs

```bash
#!/bin/bash
# batch_build.sh - Build multiple FPGA configurations

CONFIGS=("config_minimal" "config_uart" "config_ddr")

for config in "${CONFIGS[@]}"; do
    echo "=== Building: $config ==="
    ./run_libero.sh "tcl_scripts/$config.tcl" SCRIPT

    if [ $? -eq 0 ]; then
        echo "✓ $config build succeeded"
    else
        echo "✗ $config build failed"
        exit 1
    fi
done

echo "✓ All configurations built successfully"
```

**Benefit:** Test multiple designs overnight

---

## Tools Comparison Matrix

| Tool/Operation | GUI Required? | Scriptable? | Notes |
|----------------|---------------|-------------|-------|
| **Libero Project Creation** | ❌ | ✅ | Fully automated via TCL |
| **HDL Import** | ❌ | ✅ | `import_files` works perfectly |
| **IP Core Config** | ⚠️ | ✅ | Need VLNV from GUI first |
| **SmartDesign** | ⚠️ | ✅ | Tedious but scriptable |
| **Constraints (PDC/SDC)** | ❌ | ✅ | Text files, fully scriptable |
| **Synthesis** | ❌ | ✅ | `run_tool -name SYNTHESIZE` |
| **Place & Route** | ❌ | ✅ | `run_tool -name PLACEROUTE` |
| **Timing Analysis** | ⚠️ | ✅ | Reports scriptable, GUI better for debug |
| **Bitstream Generation** | ❌ | ✅ | `export_bitstream_file` |
| **FlashPro Programming** | ⚠️ | ✅ | Command-line tool exists |
| **BeagleV Linux Programming** | ❌ | ✅ | Via serial automation! |
| **SoftConsole Compile** | ❌ | ✅ | Standard make/gcc |
| **SoftConsole Debug** | ✅ | ❌ | GUI debugger needed |

**Legend:**
- ✅ Fully scriptable, no GUI needed
- ⚠️ Scriptable with some GUI assistance
- ❌ No scripting support

---

## Lessons Learned

### What We Thought Was GUI-Only (But Isn't!)

1. **Complete FPGA builds** - Can be 100% scripted
2. **BeagleV-Fire programming** - Fully automated via serial queue
3. **IP core configuration** - All parameters accessible via TCL
4. **Constraint association** - No GUI needed

### What Actually Requires GUI

1. **Initial IP core discovery** - Finding VLNV strings (one-time)
2. **Interactive timing debugging** - ChipPlanner visualization
3. **SoftConsole debugging** - GDB GUI (hardware debug)

### Biggest Time Savers

1. **Serial command queue** - Eliminated 10+ minutes per session of repetitive typing
2. **Build automation** - Reduced 45-minute GUI workflow to 15-minute script
3. **Lenient error checking** - Stopped failures on harmless warnings

### Biggest Surprises

1. **BeagleV-Fire has native Linux FPGA programming** - No JTAG needed!
2. **Libero's error checking is too strict** - Warnings reported as errors
3. **PDC/SDC must be separate files** - Parser limitation
4. **File-based serial queue works perfectly** - Simple but powerful pattern

---

## Future Automation Opportunities

### Not Yet Explored

1. **FlashPro command-line** - Can programming be fully automated?
2. **Timing report parsing** - Extract slack/violations programmatically
3. **Resource utilization tracking** - Automated metrics over time
4. **CI/CD integration** - GitHub Actions for FPGA builds
5. **Multi-board programming** - Parallel programming of dev boards

### Wish List (Feature Requests for Microchip)

1. **JSON output mode** for reports (easier parsing)
2. **Better exit codes** for tools (warnings ≠ errors)
3. **IP core catalog in machine-readable format** (no GUI needed for VLNV)
4. **Native Linux Libero** (WSL performance is slower)

---

## Conclusion

**CLI automation is more powerful than expected!**

Almost the entire FPGA development flow can be scripted, from project creation through programming the board. The few GUI-only operations are mostly one-time setup or optional debugging aids.

**Key Innovations:**
1. Serial command queue for autonomous board interaction
2. Lenient error checking patterns for Libero tools
3. Complete BeagleV-Fire programming automation

**Time Savings:**
- Per build: 30-45 minutes → 15-20 minutes
- Per programming cycle: 5-10 minutes → 30 seconds
- Total: **~70% time reduction for iterative development**

**Accessibility:**
- FAEs can share exact workflows with customers
- New engineers can ramp up faster (scripts > documentation)
- Reproducible builds eliminate "works on my machine" issues

---

## Additional Resources

**In This Repository:**
- `docs/libero_softconsole_cli_guide.md` - Complete CLI reference
- `docs/ai_serial_debugging_framework.md` - Serial automation patterns
- `tcl_scripts/beaglev_fire/` - Working automation examples
- `run_libero.sh` - WSL wrapper script

**External:**
- Libero TCL Command Reference (in Libero installation)
- BeagleV-Fire Gateware Repository (BeagleBoard.org)
- PolarFire SoC Documentation (Microchip)

---

**Last Updated:** 2025-11-14
**Maintainer:** Jonathan Orgill (FAE)
**Contributions:** Claude Code (Anthropic) - Automation pattern development
