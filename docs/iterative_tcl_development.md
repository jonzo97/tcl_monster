# Iterative TCL Development for Libero SoC

**Author:** Jonathan Orgill & Claude (Anthropic)
**Date:** 2025-11-14
**Audience:** Engineers familiar with TCL scripting who want to build FPGA designs incrementally

---

## The Problem: Libero's Batch-Only Limitation

### Vivado Has This

```tcl
Vivado% create_bd_design "my_design"
# Instant feedback: Design created ✓

Vivado% add_bd_cell -type ip axi_bram_ctrl_0
# Instant feedback: Cell added ✓

Vivado% connect_bd_net [get_bd_pins clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
# Instant feedback: Connected ✓

Vivado% validate_bd_design
# Instant feedback: Validation results shown
```

**Cycle time:** Seconds per command
**Learning:** Immediate feedback on what works/doesn't work
**Workflow:** Interactive experimentation → Discover patterns → Automate

### Libero Has This

```bash
$ ./run_libero.sh my_script.tcl SCRIPT
[Wait 5-15 minutes for Libero to launch, run script, exit]
[Open log file to see if it worked]
[Edit script to fix errors]
[Wait another 5-15 minutes]
[Repeat...]
```

**Cycle time:** 5-15 minutes per iteration
**Learning:** Delayed - can't see results until full run completes
**Workflow:** Guess → Wait → Debug logs → Repeat

**This is why iterative development in Libero is painful.**

---

## Why Iterative Beats One-Shot

### The "Perfect Script" Myth

❌ **Wrong approach:**
```
1. Write 500-line monolithic script
2. Run it
3. 37 errors appear
4. Spend hours debugging which line caused what
5. Can't isolate the problem
6. Give up and go back to GUI
```

✅ **Right approach:**
```
1. Write minimal 20-line script (just create project)
2. Run it → SUCCESS ✓
3. Add next 15 lines (import HDL)
4. Run it → SUCCESS ✓
5. Add next 25 lines (add IP core)
6. Run it → FAIL (but you know exactly what failed)
7. Fix that one section
8. Continue...
```

**Result:** Build up complex designs from known-good increments

### Real Example: Our LED Blink Development

**Iteration 1: Create project**
```tcl
new_project -name "led_blink" -family PolarFire -die MPFS025T
```
Run time: 2 minutes → ✅ SUCCESS

**Iteration 2: Import HDL**
```tcl
import_files -hdl_source "led_blinker.v"
build_design_hierarchy
set_root -module {led_blinker::work}
```
Run time: 3 minutes → ✅ SUCCESS

**Iteration 3: Add constraints (FIRST ATTEMPT)**
```tcl
create_links -io_pdc "constraints.pdc"  # PDC file contains both pin AND timing
```
Run time: 5 minutes → ❌ FAIL
**Error:** PDC parser doesn't understand `create_clock` command

**Iteration 4: Fix constraints (SECOND ATTEMPT)**
```tcl
create_links -io_pdc "pins.pdc"      # Pin constraints only
create_links -sdc "timing.sdc"        # Timing constraints separate
```
Run time: 5 minutes → ✅ SUCCESS
**Learned:** PDC and SDC must be separate files (documented for next time)

**Total time:** 15 minutes, 4 iterations
**Knowledge gained:** PDC/SDC separation pattern (reusable forever)

**Compare to one-shot:** Would have failed on iteration 1, spent hours debugging monolithic script

---

## Workarounds for Lack of REPL

### 1. Modular Script Architecture

**Don't write this:**
```tcl
# monolithic_script.tcl - 500 lines that does everything
new_project ...
import_files ...
create_smartdesign ...
add_ip_cores ...
connect_everything ...
run_synthesis ...
run_place_route ...
export_bitstream ...
```

**Write this:**
```bash
# Separate scripts for each stage
tcl_scripts/
├── create_project.tcl       # Just project creation
├── import_hdl.tcl            # Just HDL import
├── build_smartdesign.tcl     # Just SmartDesign (the one you'll iterate on most)
├── run_synthesis.tcl         # Just synthesis
└── export_bitstream.tcl      # Just export
```

**Why this works:**
- SmartDesign changes frequently → Only re-run `build_smartdesign.tcl`
- Synthesis stable → Don't re-run every iteration
- 15-minute full build → 2-minute SmartDesign iteration

### 2. Lenient Error Checking

Libero's `check_tool` is too strict - it stops on warnings:

```tcl
# ❌ Strict (stops on first warning)
run_tool -name {SYNTHESIZE}
check_tool -name {SYNTHESIZE}  # Throws error if ANY warnings

# ✅ Lenient (shows all issues in one run)
if {[catch {run_tool -name {SYNTHESIZE}} result]} {
    puts "\[WARN\] Synthesis had warnings: $result"
    puts "\[INFO\] Continuing to see all issues..."
}

if {[catch {run_tool -name {PLACEROUTE}} result]} {
    puts "\[WARN\] Place & Route had warnings: $result"
}
```

**Benefit:** See ALL issues in one 15-minute run instead of fixing one issue per run (70% time savings)

### 3. Build Reports as Feedback

After each run, extract feedback from reports:

```bash
# After synthesis
grep "Resource Usage" libero_projects/my_design/synthesis/synplify.log

# After place & route
grep "Timing Summary" libero_projects/my_design/designer/impl1/my_design_timing.rpt

# Did .spi export succeed?
ls -lh libero_projects/my_design/designer/impl1/export/*.spi
```

This gives you the "feedback loop" that Vivado's REPL provides automatically.

---

## Conversational Design Pattern (AI-Assisted)

This is where AI shines - it acts as your **virtual REPL** for Libero.

### The Workflow Your Co-Worker Wants

**Instead of:**
```
Write entire SmartDesign script → Run → Debug → Repeat
```

**Use this:**
```
You: "Give me a basic MI-V system"
AI: [Generates minimal MI-V + clock + reset]
You: "Run it"
AI: [Runs script, reports success]

You: "Add a UART at 0x70001000"
AI: [Adds CoreUARTapb, connects to APB bus, updates address map]
You: "Run it"
AI: [Runs script, reports success]

You: "Add 2 more UARTs at 0x70002000 and 0x70003000"
AI: [Adds 2 more UARTs, connects them, updates address map]
You: "Run it"
AI: [Runs script, reports success]

You: "Give me 8 GPIO pins for LEDs"
AI: [Adds CoreGPIO with 8 outputs, connects to APB]
You: "Run it"
AI: [Runs script, reports success]

You: "Add a Timer at 0x70004000"
AI: [Adds CoreTimer, connects it]
You: "Run it"
AI: [Runs script, reports success]

You: "Now build it and show me resource usage"
AI: [Runs synthesis, extracts report]
AI: "Design uses 3,450 LUTs, 1,892 FFs. Timing: All constraints met ✓"
```

**Each iteration:** 2-5 minutes
**Total time for complex system:** 30 minutes
**Traditional approach:** 4+ hours (write monolithic script, debug, fix, repeat)

### How This Works Under the Hood

#### Example 1: "Give me a UART"

**You say:**
> "Add a UART at 0x70001000 with 115200 baud"

**AI generates:**
```tcl
# Use our IP generator library
source tcl_scripts/lib/generators/uart_config_generator.tcl

# Generate UART with specified baud rate
generate_uart_115200 "CoreUARTapb_C0" "temp_uart.tcl"
source temp_uart.tcl

# Add to SmartDesign
sd_instantiate_component -sd_name "MyDesign" \
    -component_name "CoreUARTapb_C0" \
    -instance_name "UART0"

# Connect to APB bus (using our interconnect library)
source tcl_scripts/lib/smartdesign/interconnect/apb_interconnect.tcl
::apb_interconnect::connect_peripheral "MyDesign" "MIV_RV32_C0:APB_MSTR" \
    "UART0" 0x70001000 0x1000

# Connect clock and reset
sd_connect_pins -sd_name "MyDesign" \
    -pin_names {"CLK:CLK_OUT" "UART0:PCLK"}
sd_connect_pins -sd_name "MyDesign" \
    -pin_names {"RESET:POWER_ON_RESET_N" "UART0:PRESETN"}

# Expose UART pins to top level
sd_create_scalar_port -sd_name "MyDesign" -port_name "UART_RX" -port_direction "IN"
sd_create_scalar_port -sd_name "MyDesign" -port_name "UART_TX" -port_direction "OUT"
sd_connect_pins -sd_name "MyDesign" -pin_names {"UART_RX" "UART0:RX"}
sd_connect_pins -sd_name "MyDesign" -pin_names {"UART_TX" "UART0:TX"}

puts "\[INFO\] UART added at 0x70001000 (115200 baud)"
```

**AI runs it:**
```bash
./run_libero.sh add_uart.tcl SCRIPT
```

**AI parses output:**
```
[INFO] UART added at 0x70001000 (115200 baud)
[INFO] Design validation: PASSED
```

**AI reports back:**
> "✓ UART added successfully. Ready for next component."

#### Example 2: "Give me a RAM"

**You say:**
> "Add a 64KB LSRAM block at 0x80000000"

**AI generates:**
```tcl
# Create LSRAM component
create_and_configure_core \
    -core_vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:1.2.108} \
    -component_name {PF_SRAM_C0} \
    -params {
        "AXI4_AWIDTH:32" \
        "AXI4_DWIDTH:64" \
        "AXI4_IDWIDTH:8" \
        "AXI4_IFTYPE_RD:T" \
        "AXI4_IFTYPE_WR:T" \
        "ECC:0" \
        "FABRIC_INTERFACE_TYPE:1" \
        "IMPORT_FILE:" \
        "INIT_RAM:F" \
        "LPM_HINT:0" \
        "PIPELINE_OPTIONS:1" \
        "RDEPTH:16384" \
        "RWIDTH:32" \
        "USE_NATIVE_INTERFACE:F" \
        "WDEPTH:16384" \
        "WWIDTH:32"
    }

# Add to SmartDesign
sd_instantiate_component -sd_name "MyDesign" \
    -component_name "PF_SRAM_C0" \
    -instance_name "LSRAM_64KB"

# Connect to AXI bus
# (Assuming you have an AXI interconnect - if not, AI would create one)
sd_connect_pins -sd_name "MyDesign" \
    -pin_names {"AXI_INTERCONNECT:M0_AXI" "LSRAM_64KB:AXI4_S"}

# Clock and reset
sd_connect_pins -sd_name "MyDesign" \
    -pin_names {"CLK:CLK_OUT" "LSRAM_64KB:ACLK"}
sd_connect_pins -sd_name "MyDesign" \
    -pin_names {"RESET:POWER_ON_RESET_N" "LSRAM_64KB:ARESETN"}

puts "\[INFO\] 64KB LSRAM added at 0x80000000"
```

**Result:** RAM is added, connected, ready to use

### Example 3: "Connect this element"

**You say:**
> "Connect the GPIO output pins to external I/O ports named LED[7:0]"

**AI generates:**
```tcl
# Create 8-bit bus port
sd_create_bus_port -sd_name "MyDesign" \
    -port_name "LED" \
    -port_direction "OUT" \
    -port_range "[7:0]"

# Connect GPIO outputs to LED port
sd_connect_pins -sd_name "MyDesign" \
    -pin_names {"LED" "GPIO_C0:GPIO_OUT[7:0]"}

puts "\[INFO\] GPIO outputs connected to LED[7:0] ports"
```

**Why this is powerful:** You describe the connection in natural language, AI translates to exact TCL syntax.

---

## Practical Workflow Example

Let's build a complete MI-V system incrementally:

### Session Transcript

```
You: "Create a new PolarFire project called 'my_miv_system' for MPF300 eval board"

AI: [Generates project creation script]
    [Runs it]
    "✓ Project created at libero_projects/my_miv_system"

You: "Start with a minimal MI-V RV32IMC system at 50 MHz"

AI: [Uses our SmartDesign template]
    ```tcl
    source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl
    ::miv_minimal::create_and_set_root "my_miv_system" {
        core_variant "RV32IMC"
        system_clock_mhz 50
    }
    ```
    [Runs it]
    "✓ MI-V RV32IMC core created with 50 MHz clock"

You: "Add a UART at 0x70001000 for debugging"

AI: [Uses UART generator + interconnect library]
    [Connects to APB bus at specified address]
    [Runs it]
    "✓ UART added at 0x70001000 (115200 baud default)"

You: "Make that 921600 baud instead"

AI: [Regenerates UART with different baud rate parameter]
    [Runs it]
    "✓ UART updated to 921600 baud"

You: "Add 8 GPIO pins for LEDs at 0x70002000"

AI: [Adds CoreGPIO configured for 8 outputs]
    [Connects to APB bus]
    [Creates external LED[7:0] port]
    [Runs it]
    "✓ GPIO added with 8 LED outputs at 0x70002000"

You: "Add 2 timers at 0x70003000 and 0x70004000"

AI: [Adds 2 CoreTimer instances]
    [Connects both to APB bus with correct address decoding]
    [Runs it]
    "✓ 2 timers added at specified addresses"

You: "Give me 64KB of LSRAM at 0x80000000"

AI: [Creates PF_SRAM configured for 64KB]
    [Adds AXI interconnect to connect CPU to RAM]
    [Maps to 0x80000000 address space]
    [Runs it]
    "✓ 64KB LSRAM added at 0x80000000"

You: "Show me the memory map"

AI: [Parses SmartDesign and extracts address assignments]
    "Memory Map:
     ================
     LSRAM            0x80000000 - 0x8000FFFF  (64 KB)

     APB Peripherals:
     UART0            0x70001000 - 0x70001FFF  (4 KB)
     GPIO0            0x70002000 - 0x70002FFF  (4 KB)
     TIMER0           0x70003000 - 0x70003FFF  (4 KB)
     TIMER1           0x70004000 - 0x70004FFF  (4 KB)"

You: "Build it and tell me the resource usage"

AI: [Runs synthesis]
    [Waits 15 minutes]
    [Extracts resource report]
    "Build complete ✓
     Resources:
       LUTs: 3,847 / 299,544 (1.28%)
       FFs:  2,103 / 299,544 (0.70%)
     Timing: All constraints met (worst slack: +2.3 ns)"

You: "Perfect! Export the bitstream"

AI: [Runs export]
    "✓ Bitstream exported: my_miv_system.stp (4.2 MB)"
```

**Total time:** ~45 minutes (including synthesis)
**Traditional approach:** 4-8 hours writing monolithic script, debugging, fixing

---

## AI as Virtual REPL

### What AI Does That Makes This Work

1. **Generates correct TCL syntax**
   - You: "Add UART at 115200 baud"
   - AI: Translates to exact `create_and_configure_core` parameters

2. **Runs the script and parses results**
   - Detects success/failure
   - Extracts useful information from logs
   - Reports back in human-readable form

3. **Remembers context across iterations**
   - Knows what you've already added
   - Updates address map automatically
   - Detects conflicts (e.g., address overlap)

4. **Suggests fixes when things fail**
   - You: [Script fails with PDC syntax error]
   - AI: "This error occurs because PDC files can't contain `create_clock`. Let me split constraints into separate PDC (pins) and SDC (timing) files."

5. **Learns from previous iterations**
   - Discovers that PDC/SDC must be separate → Uses pattern forever
   - Discovers that lenient error checking saves time → Uses pattern forever
   - Documents patterns in PROJECT_STATE.json for future sessions

### Example: AI Catches Address Conflict

```
You: "Add another UART at 0x70002000"

AI: [Checks existing address map]
    "⚠️ Address conflict detected!
    GPIO0 is already mapped at 0x70002000 - 0x70002FFF

    Suggested addresses for new UART:
    - 0x70005000 (next available)
    - 0x70006000

    Which would you prefer?"

You: "Use 0x70005000"

AI: [Adds UART at corrected address]
    "✓ UART added at 0x70005000"
```

**This is REPL-like behavior** even though Libero doesn't support it natively.

---

## Patterns for Non-AI Iterative Development

Your co-worker can use these patterns even WITHOUT AI:

### Pattern 1: Script Templates

Create a library of reusable snippets:

```bash
tcl_scripts/snippets/
├── add_uart.tcl          # Template: Add UART with parameters
├── add_gpio.tcl          # Template: Add GPIO block
├── add_timer.tcl         # Template: Add timer
├── connect_apb.tcl       # Template: APB bus connection
└── address_map.tcl       # Template: Print address map
```

**Usage:**
```tcl
# Start with blank SmartDesign
create_smartdesign -sd_name "MyDesign"
open_smartdesign -sd_name "MyDesign"

# Use snippets to build incrementally
source tcl_scripts/snippets/add_uart.tcl
# Edit parameters in add_uart.tcl, save, run again

source tcl_scripts/snippets/add_gpio.tcl
# Edit parameters in add_gpio.tcl, save, run again

# ... and so on
```

### Pattern 2: Incremental Script with Flags

```tcl
# build_system.tcl - Incremental build with enable flags

set enable_uart  1  ;# Toggle these to add/remove components
set enable_gpio  1
set enable_timer 0  ;# Not ready yet - leave disabled

if {$enable_uart} {
    source tcl_scripts/lib/generators/uart_config_generator.tcl
    generate_uart_115200 "CoreUARTapb_C0" "temp_uart.tcl"
    source temp_uart.tcl
    # ... connection code ...
}

if {$enable_gpio} {
    source tcl_scripts/lib/generators/gpio_config_generator.tcl
    generate_gpio_outputs "CoreGPIO_C0" 8 "temp_gpio.tcl"
    source temp_gpio.tcl
    # ... connection code ...
}

if {$enable_timer} {
    # Not implemented yet - will add in next iteration
}
```

**Workflow:**
1. Start with all flags = 0
2. Set `enable_uart = 1` → Run → Debug until working
3. Set `enable_gpio = 1` → Run → Debug until working
4. Set `enable_timer = 1` → Run → Debug until working

### Pattern 3: Version-Controlled Iterations

```bash
# Iteration 1: Minimal system
git add create_project.tcl
git commit -m "Iteration 1: Basic MI-V + clock"
git tag v0.1-minimal

# Iteration 2: Add UART
[Edit script to add UART]
git add create_project.tcl
git commit -m "Iteration 2: Added UART at 115200 baud"
git tag v0.2-uart

# Iteration 3: Add GPIO (FAILS - address conflict)
[Edit script to add GPIO]
./run_libero.sh create_project.tcl SCRIPT
# FAILED!

# Revert to known-good state
git revert HEAD
# or
git checkout v0.2-uart

# Fix and try again
[Edit script with corrected address]
git add create_project.tcl
git commit -m "Iteration 3: Added GPIO (fixed address conflict)"
git tag v0.3-gpio
```

**Benefit:** Every working iteration is a checkpoint you can return to.

---

## Tools We've Built to Support This

### 1. IP Configuration Generators

Location: `tcl_scripts/lib/generators/`

```bash
ddr4_config_generator.tcl   # Generate DDR4 with auto-calculated geometry
uart_config_generator.tcl   # Generate UART with baud rate calculation
gpio_config_generator.tcl   # Generate GPIO with width/direction
ccc_config_generator.tcl    # Generate clock conditioning circuit
pcie_config_generator.tcl   # Generate PCIe endpoint/root port
```

**Usage:**
```tcl
source tcl_scripts/lib/generators/uart_config_generator.tcl
generate_uart_115200 "CoreUARTapb_C0" "my_uart.tcl"
source my_uart.tcl
# UART is now instantiated and ready to add to SmartDesign
```

### 2. SmartDesign Interconnect Library

Location: `tcl_scripts/lib/smartdesign/interconnect/`

```bash
apb_interconnect.tcl        # Auto-generate APB bus connections
clock_reset_tree.tcl        # Distribute clock/reset to all components
```

**Usage:**
```tcl
source tcl_scripts/lib/smartdesign/interconnect/apb_interconnect.tcl

# Define peripherals with addresses
set peripherals {
    {CoreUARTapb_C0 0x70001000 0x1000}
    {CoreGPIO_C0    0x70002000 0x1000}
    {CoreTimer_C0   0x70003000 0x1000}
}

# Auto-connect all to MI-V APB master
::apb_interconnect::connect_peripherals "MyDesign" "MIV_RV32_C0:APB_MSTR" $peripherals

# Print address map for documentation
::apb_interconnect::print_address_map $peripherals
```

### 3. SmartDesign Templates

Location: `tcl_scripts/lib/smartdesign/templates/`

```bash
miv_rv32_minimal.tcl        # Minimal MI-V system (core + clock + reset)
```

**Usage:**
```tcl
source tcl_scripts/lib/smartdesign/templates/miv_rv32_minimal.tcl

::miv_minimal::create_and_set_root "MySystem" {
    core_variant "RV32IMC"
    system_clock_mhz 50
    gpio_width 8
    add_uart true
}

# System is created and ready - now add your custom components
```

**See:** `tcl_scripts/lib/smartdesign/README.md` for complete documentation

---

## Comparison: Traditional vs Iterative

### Traditional "One-Shot" Approach

```
Day 1: Write 500-line script trying to create entire system
Day 2: Run script → 47 errors
Day 3: Debug errors → Fix 10, introduce 3 new ones
Day 4: Run again → 25 errors remaining
Day 5: Debug more → Realize fundamental design flaw
Day 6: Rewrite large sections
Day 7: Run again → Different errors
...
Week 2: Finally get it working
Week 3: Realize you need to add one more UART
Week 4: Entire script breaks, start over
```

**Total time:** 3-4 weeks
**Result:** Brittle, hard-to-modify script

### Iterative Approach

```
Hour 1: Create minimal project → SUCCESS ✓
Hour 2: Add MI-V core → SUCCESS ✓
Hour 3: Add UART → FAIL (PDC syntax error)
        Fix (separate PDC/SDC) → SUCCESS ✓
Hour 4: Add GPIO → SUCCESS ✓
Hour 5: Add Timer → SUCCESS ✓
Hour 6: Add LSRAM → SUCCESS ✓
Hour 7: Build and verify → SUCCESS ✓

[2 weeks later]
Minute 1: "I need one more UART"
Minute 5: Add UART → SUCCESS ✓
Minute 10: Build → SUCCESS ✓
```

**Total time:** 7 hours initial + 10 minutes per modification
**Result:** Modular, easy-to-modify, well-understood system

---

## Tips for Your Co-Worker

### 1. Start Small, Always

Don't try to build the entire system in one iteration:

❌ **Bad:**
```tcl
# first_attempt.tcl - Everything at once!
[500 lines of SmartDesign code]
```

✅ **Good:**
```tcl
# iteration_1.tcl - Just the basics
create_smartdesign -sd_name "MyDesign"
# Add clock source
# Add reset controller
# Save and exit
```

Then test it. Then add one component. Then test. Then add another...

### 2. Use Version Control Religiously

Every working iteration = one commit:

```bash
git commit -m "Iteration 5: UART + GPIO working"
```

If next iteration breaks something, you can always return to this known-good state.

### 3. Extract Reusable Patterns

When you successfully add a component, save the pattern:

```tcl
# Pattern: Add APB peripheral
# 1. Create/configure component
# 2. Instantiate in SmartDesign
# 3. Connect to APB bus with address
# 4. Connect clock and reset
# 5. Expose external pins if needed

# Save this pattern for next peripheral!
```

### 4. Document Failures Too

When something fails, document WHY:

```tcl
# Learned: PDC files cannot contain create_clock commands
# Solution: Use separate SDC file for timing constraints
```

Add this to your project's `key_learnings` list.

### 5. Use Our Libraries

Don't reinvent the wheel:

- **IP generators** for common cores (UART, GPIO, etc.)
- **Interconnect library** for APB/AXI connections
- **Templates** for common system types (MI-V minimal, etc.)

These encode the patterns we've already discovered.

---

## AI-Assisted Workflow (Detailed)

If your co-worker wants to try AI assistance, here's the recommended workflow:

### Step 1: Start Conversation with Context

```
You: "I'm working on a PolarFire FPGA design. I want to build a MI-V RISC-V
     system incrementally, adding components one at a time and testing
     between iterations. Use our SmartDesign library at
     tcl_scripts/lib/smartdesign/ for automation."
```

**AI understands:**
- Incremental approach desired
- Use existing libraries (not reinventing)
- Test-driven development

### Step 2: Request Minimal Starting Point

```
You: "Create a minimal MI-V RV32IMC system with just a 50 MHz clock and reset"

AI: [Generates script using template]
    "Ready to run. This will create a basic system with:
     - MI-V RV32IMC core
     - 50 MHz clock from PF_CCC
     - Power-on reset controller

     Run with: ./run_libero.sh iteration_1.tcl SCRIPT"
```

### Step 3: Build Incrementally

```
You: "That worked. Now add a UART for console I/O"

AI: [Adds UART using generator library]
    [Connects to APB bus]
    "UART added at 0x70001000. Run iteration_2.tcl"

You: [Runs it] "Success! Now add GPIO for 8 LEDs"

AI: [Adds GPIO]
    "GPIO added at 0x70002000 with 8 output pins. Run iteration_3.tcl"

You: [Runs it] "Failed with address conflict error"

AI: [Parses error log]
    "The APB interconnect is out of address space. Need to adjust
     base address. Let me regenerate with 0x70003000 instead."

You: [Runs corrected version] "Success!"
```

### Step 4: Extract and Save Patterns

```
You: "This pattern of adding APB peripherals works well. Save it as a reusable function"

AI: [Creates helper function]
    ```tcl
    # add_apb_peripheral.tcl
    proc add_apb_peripheral {sd_name peripheral_type instance_name base_addr} {
        # Implementation here...
    }
    ```
    "Saved to tcl_scripts/lib/smartdesign/utilities/add_apb_peripheral.tcl

     Usage:
     add_apb_peripheral "MyDesign" "UART" "UART1" 0x70004000"
```

### Step 5: Build Complete System

After 10-15 iterations, you have a complete system that was built incrementally, tested at each step, and fully understood.

---

## Common Pitfalls and Solutions

### Pitfall 1: Trying to Do Too Much Per Iteration

❌ **Symptom:** Script fails, don't know which part broke
✅ **Solution:** Limit each iteration to ONE new component/connection

### Pitfall 2: Not Testing Between Iterations

❌ **Symptom:** Run 5 iterations without testing, everything breaks
✅ **Solution:** Test after EVERY iteration (even if it's just project opening)

### Pitfall 3: Losing Track of What Changed

❌ **Symptom:** "It worked last time, what did I change?"
✅ **Solution:** Git commit after every successful iteration with clear message

### Pitfall 4: Inconsistent Naming

❌ **Symptom:** Can't find components, connections fail
✅ **Solution:** Use consistent naming convention:
- Instances: `UART0`, `GPIO0`, `TIMER0`
- Buses: `APB_BUS`, `AXI_INTERCONNECT`
- Clocks: `CLK_50MHZ`, `CLK_100MHZ`

### Pitfall 5: Hardcoded Paths

❌ **Bad:**
```tcl
import_files -hdl_source "C:/Users/JohnDoe/my_project/design.v"
```

✅ **Good:**
```tcl
set project_root [file dirname [info script]]
import_files -hdl_source "$project_root/hdl/design.v"
```

---

## Resources

### Documentation
- **SmartDesign Library:** `tcl_scripts/lib/smartdesign/README.md`
- **IP Generators:** `tcl_scripts/lib/generators/README.md`
- **Lessons Learned:** `docs/lessons_learned/`
- **CLI Capabilities:** `docs/cli_capabilities_and_workarounds.md`

### Example Projects
- **LED Blink:** `tcl_scripts/beaglev_fire/led_blink_standalone.tcl`
- **Counter Demo:** `tcl_scripts/create_counter_project.tcl`
- **MI-V System:** `tcl_scripts/create_miv_simple.tcl`

### Getting Help
- Check `PROJECT_STATE.json` for architecture decisions and learnings
- Search `docs/lessons_learned/` for similar issues
- Ask AI: "I'm getting error [X], what does this mean in Libero context?"

---

## Summary

**Key Takeaways:**

1. **Libero doesn't have a REPL** like Vivado, but iterative development is still possible
2. **Break scripts into stages** - create, build, export as separate scripts
3. **Use lenient error checking** to see all issues in one run
4. **Build incrementally** - one component at a time, test between additions
5. **Version control every iteration** - Git commits = checkpoints
6. **Extract and reuse patterns** - Build up a library of working solutions
7. **AI acts as virtual REPL** - generates, runs, parses, reports, suggests fixes
8. **Conversational design is possible** - "give me a UART", "add GPIO", "connect this"

**The Bottom Line:**

Iterative development in Libero is not only possible - it's the **recommended** approach. The lack of a REPL makes it more important, not less, to build incrementally and test frequently.

AI assistance accelerates this by acting as the interactive feedback loop that Libero's batch model lacks, but the patterns work even without AI.

**Start small. Test often. Build up. Document learnings. Reuse patterns.**

---

**Last Updated:** 2025-11-14
**Maintained by:** TCL Monster Project
