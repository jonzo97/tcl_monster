# Simulation Framework Strategy

**Purpose:** Automated simulation workflow using ModelSim/QuestaSim via command line

**Last Updated:** 2025-10-22

---

## Overview

Libero integrates with ModelSim/QuestaSim for HDL simulation. This framework enables:
- **Automated testbench generation** from design templates
- **Command-line simulation** execution (pre/post-synthesis)
- **Regression testing** framework for continuous validation
- **Waveform capture** and automated pass/fail checking

---

## Available Simulators

### ModelSim
**Location:** `/mnt/c/Microchip/Libero_SoC_v2024.2/ModelSim/`

### QuestaSim
**Location:** `/mnt/c/Microchip/Libero_SoC_v2024.2/QuestaSim/`

**Key Differences:**
- **ModelSim:** Standard simulator, widely used
- **QuestaSim:** Advanced features (UVM, coverage, advanced debug)

**For TCL Monster:** Start with ModelSim, add QuestaSim support later if needed

---

## Libero Simulation Integration

### Libero TCL Commands

From sample script analysis (`/Designer/scripts/sample/run.tcl`):

```tcl
# Pre-synthesis simulation
run_tool -name SIM_PRESYNTH

# Post-synthesis simulation
run_tool -name SIM_POSTSYNTH
```

### Simulator Configuration

```tcl
# Configure which simulator to use
configure_tool -name {SIM_PRESYNTH} -params {SIMULATOR:ModelSim}

# Set simulation options
configure_tool -name {SIM_PRESYNTH} -params {
    SIMULATOR:ModelSim
    SIMULATION_TIME:1000ns
    RESOLUTION:1ps
}
```

---

## Phase 1: Basic Simulation Integration

**Goal:** Run simulations from command line via Libero TCL

**Time Estimate:** 1 hour

### Tasks:
1. [ ] Create simulation TCL script
2. [ ] Add testbench to counter design
3. [ ] Run pre-synthesis simulation
4. [ ] Capture waveforms (VCD export)
5. [ ] Verify simulation results

### Planned Files:
- `tcl_scripts/run_simulation.tcl` - Simulation execution script
- `hdl/testbench/tb_counter.v` - Counter testbench
- `tcl_scripts/configure_simulation.tcl` - Simulator settings

### Example Workflow:
```tcl
# run_simulation.tcl

# Open project
open_project -file "./libero_projects/counter_demo/counter_demo.prjx"

# Configure simulator
configure_tool -name {SIM_PRESYNTH} -params {
    SIMULATOR:ModelSim
    SIMULATION_TIME:10000ns
    RESOLUTION:1ps
}

# Add testbench files
import_files -simulation {hdl/testbench/tb_counter.v}

# Run simulation
run_tool -name SIM_PRESYNTH

# Check results
if {[simulation_passed]} {
    puts "SIMULATION PASSED"
} else {
    puts "SIMULATION FAILED"
    exit 1
}

# Close project
close_project
```

**Usage:**
```bash
./run_libero.sh tcl_scripts/run_simulation.tcl SCRIPT
```

---

## Phase 2: Testbench Library

**Goal:** Reusable testbench components and utilities

**Time Estimate:** 1.5 hours

### Testbench Utilities

#### Clock and Reset Generation
```verilog
// hdl/testbench/tb_utils.v

module clock_gen #(
    parameter PERIOD = 20  // 50 MHz = 20ns period
)(
    output reg clk
);
    initial clk = 0;
    always #(PERIOD/2) clk = ~clk;
endmodule

module reset_gen #(
    parameter RESET_CYCLES = 10
)(
    input clk,
    output reg reset_n
);
    integer count = 0;

    initial reset_n = 0;

    always @(posedge clk) begin
        if (count < RESET_CYCLES) begin
            reset_n <= 0;
            count <= count + 1;
        end else begin
            reset_n <= 1;
        end
    end
endmodule
```

#### Self-Checking Testbench Pattern
```verilog
// hdl/testbench/tb_counter.v

`timescale 1ns/1ps

module tb_counter;
    // Clock and reset
    wire clk;
    wire reset_n;

    // DUT signals
    wire [7:0] leds;

    // Instantiate utilities
    clock_gen #(.PERIOD(20)) clk_gen (.clk(clk));
    reset_gen #(.RESET_CYCLES(10)) rst_gen (.clk(clk), .reset_n(reset_n));

    // Instantiate DUT
    counter dut (
        .clk_50mhz(clk),
        .reset_n(reset_n),
        .leds(leds)
    );

    // Test monitoring
    integer error_count = 0;

    initial begin
        // Wait for reset
        wait(reset_n == 1);

        // Check LED initial state
        #100;
        if (leds !== 8'b00000001) begin
            $display("ERROR: LED initial state incorrect. Expected 0x01, got 0x%h", leds);
            error_count = error_count + 1;
        end

        // Run for some time
        #1000000;

        // Check for LED changes (counter should have updated)
        if (leds === 8'b00000001) begin
            $display("WARNING: LEDs did not change - counter may not be working");
        end

        // Report results
        if (error_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED with %0d errors", error_count);
            $finish(1);  // Exit with error code
        end

        $finish(0);  // Exit with success
    end

    // Waveform dumping
    initial begin
        $dumpfile("counter_sim.vcd");
        $dumpvars(0, tb_counter);
    end
endmodule
```

### Bus Functional Models (BFMs)

#### UART BFM
```verilog
// hdl/testbench/bfm/uart_bfm.v

module uart_tx_bfm #(
    parameter BAUD_RATE = 115200,
    parameter CLK_FREQ = 50000000
)(
    output reg tx
);
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            tx = 0;
            #BIT_PERIOD;

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                tx = data[i];
                #BIT_PERIOD;
            end

            // Stop bit
            tx = 1;
            #BIT_PERIOD;
        end
    endtask

    initial tx = 1;  // Idle high
endmodule
```

#### SPI BFM
*(Placeholder - to be implemented)*

#### I2C BFM
*(Placeholder - to be implemented)*

---

## Phase 3: Regression Testing Framework

**Goal:** Automated test suite that runs on every design change

**Time Estimate:** 1 hour

### Regression Test Structure

```
hdl/testbench/
├── tb_utils.v           # Reusable utilities
├── bfm/                 # Bus functional models
├── tests/
│   ├── test_counter.v
│   ├── test_uart.v
│   └── test_spi.v
└── run_regression.tcl   # Run all tests
```

### Regression Test Script

```tcl
# hdl/testbench/run_regression.tcl

set test_list {
    "test_counter"
    "test_uart"
    "test_spi"
}

set passed 0
set failed 0

foreach test $test_list {
    puts "Running test: $test"

    # Configure simulation
    configure_tool -name {SIM_PRESYNTH} -params {
        SIMULATOR:ModelSim
        TESTBENCH:$test
        SIMULATION_TIME:100us
    }

    # Run simulation
    if {[catch {run_tool -name SIM_PRESYNTH}]} {
        puts "FAILED: $test"
        incr failed
    } else {
        puts "PASSED: $test"
        incr passed
    }
}

puts "=========================================="
puts "Regression Test Summary"
puts "PASSED: $passed"
puts "FAILED: $failed"
puts "=========================================="

if {$failed > 0} {
    exit 1
}
```

**Usage:**
```bash
./run_libero.sh hdl/testbench/run_regression.tcl SCRIPT
```

---

## Phase 4: Automated Testbench Generation

**Goal:** Generate testbench skeletons from HDL modules

**Time Estimate:** 1 hour

### Testbench Generator Script

```tcl
# tcl_scripts/generate_testbench.tcl

proc generate_testbench {module_name module_file} {
    # Parse module to extract ports
    set ports [parse_module_ports $module_file]

    # Generate testbench file
    set tb_file "hdl/testbench/tb_${module_name}.v"

    # Create testbench template
    set tb_content "
`timescale 1ns/1ps

module tb_${module_name};
    // Clock and reset
    wire clk;
    wire reset_n;

    clock_gen #(.PERIOD(20)) clk_gen (.clk(clk));
    reset_gen #(.RESET_CYCLES(10)) rst_gen (.clk(clk), .reset_n(reset_n));

    // DUT signals
    [generate_signal_declarations $ports]

    // Instantiate DUT
    ${module_name} dut (
        [generate_port_connections $ports]
    );

    // Test sequence
    initial begin
        wait(reset_n == 1);

        // TODO: Add test stimulus

        #10000;
        \$display(\"TEST PASSED\");
        \$finish(0);
    end

    // Waveform dumping
    initial begin
        \$dumpfile(\"${module_name}_sim.vcd\");
        \$dumpvars(0, tb_${module_name});
    end
endmodule
    "

    # Write testbench file
    write_file $tb_file $tb_content

    puts "Generated testbench: $tb_file"
}
```

**Usage:**
```tcl
source tcl_scripts/generate_testbench.tcl
generate_testbench "counter" "hdl/counter.v"
```

---

## Phase 5: Waveform Analysis Automation

**Goal:** Parse VCD files and extract metrics/errors

**Time Estimate:** 30 minutes

### Waveform Parser Utility

```python
# tools/utilities/parse_waveform.py

import sys
from vcd import VCDParser

def analyze_waveform(vcd_file, checks):
    """
    Analyze VCD waveform file and run checks

    Args:
        vcd_file: Path to VCD file
        checks: Dict of signal checks to perform
    """
    parser = VCDParser()

    with open(vcd_file, 'r') as f:
        parser.parse(f)

    errors = []

    # Example check: Signal should never be X
    for signal, check_type in checks.items():
        if check_type == 'no_x':
            if 'x' in parser.get_signal_values(signal):
                errors.append(f"Signal {signal} contains X values")

    return errors

if __name__ == '__main__':
    vcd_file = sys.argv[1]

    checks = {
        'tb_counter.dut.leds': 'no_x',
        'tb_counter.dut.counter': 'no_x'
    }

    errors = analyze_waveform(vcd_file, checks)

    if errors:
        print("ERRORS FOUND:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)
    else:
        print("Waveform analysis PASSED")
        sys.exit(0)
```

**Usage:**
```bash
python tools/utilities/parse_waveform.py counter_sim.vcd
```

---

## Integration with Build Flow

### Simulation in CI/CD

```bash
# .github/workflows/fpga_ci.yml (example)

name: FPGA CI
on: [push, pull_request]

jobs:
  simulation:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2

      - name: Run Regression Tests
        run: ./run_libero.sh hdl/testbench/run_regression.tcl SCRIPT

      - name: Upload Waveforms
        uses: actions/upload-artifact@v2
        with:
          name: waveforms
          path: "**/*.vcd"
```

---

## ModelSim/QuestaSim Direct Usage

**For cases where Libero integration is insufficient:**

### Compile and Simulate Directly

```bash
# Compile HDL
vlog hdl/counter.v hdl/testbench/tb_counter.v

# Run simulation
vsim -c -do "run -all; quit" tb_counter

# With waveform
vsim -c -do "run -all; quit" tb_counter -wlf counter.wlf
```

### TCL Wrapper for Direct ModelSim

```tcl
# tcl_scripts/modelsim_direct.tcl

# Compile design
vlog hdl/counter.v hdl/testbench/tb_utils.v hdl/testbench/tb_counter.v

# Start simulation
vsim -c tb_counter

# Run simulation
run -all

# Check for errors
if {[runStatus] != "finished"} {
    puts "ERROR: Simulation did not complete"
    quit -f -code 1
}

# Exit
quit -f -code 0
```

---

## Success Metrics

- **Testbench Generation Time:** <2 minutes per module
- **Simulation Run Time:** <5 minutes for typical design
- **Regression Test Suite:** Runs in <15 minutes
- **Pass/Fail Automation:** 100% (no manual waveform inspection required)

---

## Known Limitations & Workarounds

*To be populated as we discover limitations*

### Potential Challenges:
1. **Libero Simulation Integration:** May require GUI for initial setup
   - **Workaround:** Use direct ModelSim/QuestaSim invocation

2. **WSL Compatibility:** ModelSim may have display issues in WSL
   - **Workaround:** Use `-c` console mode exclusively

---

## Recommended Next Steps

1. **Implement basic simulation** for counter design
2. **Create testbench library** starting with clock/reset utilities
3. **Build regression framework** as designs are added
4. **Automate waveform analysis** for common error patterns

---

**Maintained by:** TCL Monster Project | **Last Updated:** 2025-10-22
