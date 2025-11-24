# TCL Monster - Development Roadmap

**Project Vision:** Command-line FPGA automation toolkit that makes FAE workflows 10x faster

**Current Status:** Phase 0 Complete - Basic project creation and synthesis working!

**Last Updated:** 2025-10-22

---

## Phase 0: Foundation ✅ COMPLETE

**Status:** Successfully synthesized first design (counter) from command line!

**Achievements:**
- ✅ Project creation automation
- ✅ HDL source import
- ✅ I/O constraint import (PDC)
- ✅ Synthesis, Place & Route, Programming file generation
- ✅ Simple counter design (33 LUTs, 32 FFs on MPF300TS)

**Files Created:**
- `tcl_scripts/create_project.tcl` - Project creation with HDL/constraint import
- `tcl_scripts/build_design.tcl` - Full build flow (synthesis → bitstream)
- `hdl/counter.v` - Rotating LED counter design
- `constraint/io_constraints.pdc` - Pin mappings for MPF300 eval kit
- `run_libero.sh` - WSL helper script

---

## Phase 1: Foundation & Reporting

**Goal:** Robust foundation with timing analysis and comprehensive reporting

**Time Estimate:** 2-3 hours total

### 1.1 Timing Constraints Framework (~45 min)
**Status:** Not started

**Tasks:**
- [ ] Create SDC constraint templates:
  - Single clock domain (like counter)
  - Multi-clock domain with CDC
  - I/O timing constraints (setup/hold)
- [ ] Implement timing constraint generator from design analysis
- [ ] Create timing report parser (extract slack, frequency, violations)

**Files to Create:**
- `constraint/timing_constraints.sdc` - SDC for counter design (50 MHz)
- `tcl_scripts/generate_constraints.tcl` - Auto-generate constraints
- `tools/utilities/parse_timing_report.py` - Parse timing reports

**Success Criteria:**
- Counter design meets timing at 50 MHz
- Automated slack reporting
- No timing violations in synthesis

### 1.2 Enhanced Reporting (~30 min)
**Status:** Not started

**Tasks:**
- [ ] Create resource utilization report script
- [ ] Integrate power analysis reporting
- [ ] Build time tracking and metrics
- [ ] Timing summary reports

**Files to Create:**
- `tcl_scripts/generate_reports.tcl` - Generate all reports
- `tools/utilities/report_dashboard.py` - Parse and display metrics

**Success Criteria:**
- One-command report generation
- Clear visibility into resource usage, timing, power

### 1.3 Project Templates (~45 min)
**Status:** Not started

**Tasks:**
- [ ] Create device-specific templates:
  - PolarFire MPF300TS (✅ done)
  - PolarFire SoC (MPFS250T)
  - Igloo2 (M2GL150)
  - SmartFusion2 (M2S150)
- [ ] Create board-specific templates:
  - MPF300 Eval Kit (✅ done)
  - PolarFire SoC Icicle Kit
  - Igloo2 Eval Kit

**Files to Create:**
- `templates/devices/polarfire_mpf300.json`
- `templates/devices/polarfire_soc_mpfs250.json`
- `templates/boards/mpf300_eval_kit.json`
- `templates/boards/icicle_kit.json`

**Success Criteria:**
- One-command project creation for any supported device/board
- Pin mappings auto-populated from board templates

---

## Phase 2: Complex Design Examples

**Goal:** Library of validated, reusable designs

**Time Estimate:** 16-21 hours total (includes RISC-V SoC)

### 2.1 Intermediate Designs (~2 hours)
**Status:** Not started

**Designs to Implement:**
- [ ] UART transceiver (configurable baud rate)
- [ ] SPI master/slave
- [ ] I2C master
- [ ] PWM controller with deadband
- [ ] Multi-clock domain design (demonstrate CDC best practices)

**Files to Create:**
- `examples/communication/uart/` - UART design + testbench
- `examples/communication/spi/` - SPI design + testbench
- `examples/communication/i2c/` - I2C design + testbench
- `examples/basic/pwm/` - PWM design

**Success Criteria:**
- All designs synthesize without warnings
- Testbenches validate functionality
- Resource usage documented

### 2.2 RISC-V SoC Design (~12-16 hours) **NEW - HIGH PRIORITY**
**Status:** Planning complete (2025-10-22)
**Platform:** MPF300 Eval Kit + PicoRV32 soft core
**Use Case:** Bare-metal embedded control

**Detailed Plan:** See `docs/RISCV_DDR_DESIGN.md`

**Sub-Phases:**

#### 2.2.1 RISC-V Core Integration (3-4 hours)
- [ ] Acquire PicoRV32 RTL from GitHub
- [ ] Import into Libero project
- [ ] Create simple testbench (instruction fetch test)
- [ ] Synthesize for MPF300, verify resource usage (~2k LUTs target)
- [ ] Verify timing at 100 MHz

#### 2.2.2 Memory Integration (2-3 hours)
- [ ] Instantiate on-chip SRAM (32KB code + 32KB data)
- [ ] Create boot ROM with firmware hex file
- [ ] Test memory access in simulation
- [ ] Verify instruction fetch from ROM

#### 2.2.3 Peripheral Integration (2-3 hours)
- [ ] UART controller (memory-mapped registers)
- [ ] GPIO controller (LED control)
- [ ] Timer controller (delays, interrupts)
- [ ] AXI-Lite or Wishbone interconnect

#### 2.2.4 Firmware Development (2-3 hours)
- [ ] Setup RISC-V GCC toolchain (riscv32-unknown-elf-gcc)
- [ ] Write boot code (crt0.S, startup)
- [ ] Write application (blink LED, UART "Hello World")
- [ ] Create Makefile and linker script

#### 2.2.5 Integration and Testing (2-3 hours)
- [ ] Full system synthesis and P&R
- [ ] Program MPF300 eval kit
- [ ] Verify UART communication (USB-UART adapter)
- [ ] Verify LED blinking
- [ ] Debug and optimization

**Files Created:**
- `examples/advanced/riscv_soc/hdl/` - RISC-V core, peripherals, top-level
- `examples/advanced/riscv_soc/firmware/` - Boot code, application, Makefile
- `examples/advanced/riscv_soc/constraint/` - Pins, timing
- `tcl_scripts/create_riscv_project.tcl` - Project creation for RISC-V

**Resource Estimate:**
- PicoRV32 (RV32IM): ~2000 LUTs, ~1500 FFs
- On-chip memory (64KB): ~500 LUTs, 16 RAM blocks
- Peripherals (UART, GPIO, Timer): ~400 LUTs
- Interconnect: ~500 LUTs
- **Total: ~3400 LUTs (~1.1% of MPF300TS)**

**Success Criteria:**
- ✅ RISC-V executes firmware from on-chip memory
- ✅ LED blinks via GPIO
- ✅ UART prints "Hello World"
- ✅ Validated on MPF300 hardware

**Stretch Goals:**
- [ ] External SRAM interface (if more memory needed)
- [ ] Interrupt-driven peripherals
- [ ] Performance benchmarking (CoreMark)

---

### 2.3 Other Advanced Designs (~2-3 hours)
**Status:** Not started

**Designs to Implement:**
- [ ] DDR memory controller integration (standalone, or part of RISC-V)
- [ ] PCIe endpoint example (Gen3 x4)
- [ ] SmartDesign IP core integration (MSS for PolarFire SoC)
- [ ] High-speed SerDes example

**Files to Create:**
- `examples/advanced/ddr_controller/`
- `examples/advanced/pcie_endpoint/`

**Success Criteria:**
- Demonstrates IP core integration workflow
- Automated IP configuration via TCL
- Validated on hardware (where possible)

---

## Phase 3: Simulation Framework

**Goal:** Automated testbench generation and regression testing

**Time Estimate:** 3-4 hours total

### 3.1 ModelSim/QuestaSim Integration (~1.5 hours)
**Status:** Not started

**Tasks:**
- [ ] TCL scripts for simulation compilation
- [ ] Waveform capture automation
- [ ] Testbench template generation
- [ ] Regression test framework

**Files to Create:**
- `tcl_scripts/run_simulation.tcl` - Compile and run simulation
- `tcl_scripts/generate_testbench.tcl` - Auto-generate testbench skeleton
- `tools/utilities/sim_runner.py` - Regression test orchestration

**Libero Commands to Explore:**
- `run_tool -name SIM_PRESYNTH`
- `run_tool -name SIM_POSTSYNTH`
- `configure_tool -name {SIM_PRESYNTH} -params {SIMULATOR:ModelSim}`

**Success Criteria:**
- One-command simulation run
- Automated pass/fail checking
- Waveform capture for debugging

### 3.2 Testbench Library (~1.5 hours)
**Status:** Not started

**Tasks:**
- [ ] Self-checking testbench templates
- [ ] Clock/reset generation utilities
- [ ] Bus functional models (UART, SPI, I2C)
- [ ] Assertion-based verification (SVA)

**Files to Create:**
- `hdl/testbench/tb_utils.v` - Reusable testbench utilities
- `hdl/testbench/bfm/` - Bus functional models

**Success Criteria:**
- Reusable testbench components
- Reduced testbench development time

---

## Phase 4: Debugging Framework

**Goal:** In-system debugging without manual GUI interaction

**Time Estimate:** 3-4 hours total

### 4.1 Identify Debugger Automation (~2 hours)
**Status:** Not started

**Tasks:**
- [ ] Research Identify TCL API (use `/agent-research`)
- [ ] Probe insertion automation
- [ ] Trigger condition generation from signal names
- [ ] Waveform capture and analysis

**Files to Create:**
- `tcl_scripts/insert_probes.tcl` - Auto-insert Identify probes
- `tcl_scripts/run_identify.tcl` - Capture waveforms via CLI
- `tools/utilities/identify_parser.py` - Parse captured waveforms

**Identify Tools Available:**
- `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/bin/identify_debugger_console.exe`
- `/mnt/c/Microchip/Libero_SoC_v2024.2/Identify/bin/identify_debugger_shell.exe`

**Success Criteria:**
- Command-line probe insertion
- Automated signal capture
- Waveform analysis without GUI

### 4.2 SmartDebug Integration (~1-2 hours)
**Status:** Not started

**Tasks:**
- [ ] JTAG programming automation
- [ ] Device interrogation (device ID, status registers)
- [ ] Power rail monitoring
- [ ] Memory content verification

**Files to Create:**
- `tcl_scripts/program_device.tcl` - JTAG programming
- `tcl_scripts/smartdebug_query.tcl` - Device interrogation

**Success Criteria:**
- One-command device programming
- Automated health checks post-programming

---

## Phase 5: Application Note Automation

**Goal:** Parse and recreate Microchip app notes for any board

**Time Estimate:** 5-6 hours total

### 5.1 App Note Discovery (~1 hour)
**Status:** Not started

**Tasks:**
- [ ] Catalog available Microchip application notes
- [ ] Download and cache design files locally
- [ ] Extract metadata (device, board, features, I/O requirements)

**Files to Create:**
- `tools/utilities/app_note_catalog.py` - Catalog management
- `examples/app_notes/catalog.json` - Metadata database

**App Notes to Target:**
- UART designs
- SPI flash programming
- DDR memory interface
- PCIe examples
- Motor control designs

**Success Criteria:**
- Local cache of 10+ application notes
- Metadata extracted and searchable

### 5.2 Design Recreation Engine (~3-4 hours)
**Status:** Not started

**Tasks:**
- [ ] Parse existing Libero projects (`.prjx` files)
- [ ] Extract HDL, constraints, IP configurations
- [ ] Generate templates for different target devices
- [ ] Automated board file adaptation (pin remapping)

**Files to Create:**
- `tools/utilities/parse_libero_project.py` - Project parser
- `tools/utilities/adapt_to_board.py` - Pin remapping automation
- `tcl_scripts/recreate_app_note.tcl` - App note recreation

**Success Criteria:**
- Parse existing Libero project files
- Auto-adapt to different target boards
- One-command recreation of app note designs

### 5.3 Reference Design Library (~1 hour)
**Status:** Not started

**Tasks:**
- [ ] Curate collection of recreated app notes
- [ ] Device-specific variants
- [ ] Deployment automation

**Files to Create:**
- `examples/app_notes/README.md` - Reference design catalog

**Success Criteria:**
- Library of 5+ validated reference designs
- One-command deployment to supported boards

---

## Phase 6: Intelligent Automation & Agents

**Goal:** Self-improving toolkit with minimal user intervention

**Time Estimate:** 4-5 hours total

### 6.1 Agent Architecture (~2 hours)
**Status:** Not started

**Agents to Implement:**
- [ ] **Scout Agent**: Analyzes designs, identifies potential issues before synthesis
- [ ] **Build Agent**: Runs synthesis/P&R, auto-retries with fixes on failure
- [ ] **Debug Agent**: Parses logs, suggests constraint/code fixes
- [ ] **Research Agent**: Searches docs for solutions to specific errors

**Files to Create:**
- `tools/agents/scout_agent.py` - Design analysis
- `tools/agents/build_agent.py` - Build with auto-retry
- `tools/agents/debug_agent.py` - Log parsing and suggestions
- `tools/agents/research_agent.py` - Documentation search

**Success Criteria:**
- Agents run autonomously
- Intelligent error recovery
- Reduced need for manual intervention

### 6.2 Context Management Strategy (~1 hour)
**Status:** Not started

**Strategies:**
- [ ] **Checkpointing**: Save full project state at milestones
- [ ] **Incremental Memory**: Store only deltas between sessions
- [ ] **Smart Compaction**: Summarize completed work, preserve active context
- [ ] **External Knowledge Base**: Memory MCP for patterns, known issues

**Files to Create:**
- `docs/CONTEXT_STRATEGY.md` - Context management guide
- `.mcp.json` - Memory MCP knowledge graph

**Success Criteria:**
- Seamless session continuity
- Cross-device synchronization (home/work)
- Context loss minimized during compaction

### 6.3 Self-Improvement (~1-2 hours)
**Status:** Not started

**Tasks:**
- [ ] Learn from successful builds (constraint patterns)
- [ ] Build failure database with solutions
- [ ] Auto-optimization (iterative P&R strategies)

**Files to Create:**
- `tools/agents/learning_engine.py` - Pattern learning
- `data/build_history.json` - Build metrics and outcomes

**Success Criteria:**
- Improving success rate over time
- Auto-application of learned patterns

---

## Documentation for Colleagues

**Goal:** Enable other FAEs to use this toolkit

**Time Estimate:** 1-2 hours

### Files to Create:
- [ ] `docs/COLLEAGUE_GUIDE.md` - Getting started guide for new users
- [ ] `docs/TROUBLESHOOTING.md` - Common issues and solutions
- [ ] `docs/BEST_PRACTICES.md` - Recommended workflows

---

## Context Window Management Strategy

### Proactive Compaction
- Compact every 50k tokens (not just at limits)
- Save checkpoint to Memory MCP before compaction

### Session Checkpointing
- Save full state to Memory MCP every hour
- Document decisions and rationale in real-time

### Incremental Documentation
- Update ROADMAP.md after each phase completion
- Mark tasks as complete immediately

### Agent Handoffs
- Use Task tool with detailed context for sub-tasks
- Agents should return comprehensive summaries

---

## Success Metrics

### Technical Metrics
- **Build Success Rate**: % of designs building without manual intervention
  - Target: >90% for template-based designs
- **Time to Bitstream**: End-to-end flow time
  - Baseline: Counter design ~2 minutes synthesis
- **Reusability**: # of projects using shared templates/libraries
- **Error Recovery**: % of build failures auto-resolved by agents
  - Target: >50% by Phase 6

### User Metrics
- **Setup Time**: How long for colleague to get first design running
  - Target: <15 minutes
- **Productivity Gain**: Time saved vs. manual GUI workflow
  - Target: 5-10x for routine tasks
- **Adoption Rate**: # of colleagues actively using toolkit

---

## Recommended Next Steps

### After This Session:
1. **Complete Foundation Improvements** (timing constraints, locked pins, reporting)
2. **Research Sprint**: Deep-dive on Identify debugger TCL API
3. **Brainstorming Session**: Prioritize phases based on immediate FAE needs

### Between Sessions:
- Test counter design on hardware (MPF300 eval kit)
- Document any Libero CLI limitations discovered
- Share initial toolkit with one colleague for feedback

---

## Timeline Estimates

**Total Development Time:** ~34-39 hours across 6 phases (updated 2025-10-22)
- Phase 0: Complete ✅
- Phase 1: 2-3 hours
- Phase 2: 16-21 hours (includes RISC-V SoC 12-16 hours)
- Phase 3: 3-4 hours
- Phase 4: 3-4 hours
- Phase 5: 5-6 hours
- Phase 6: 4-5 hours

**Recommended Pace:** 2-3 hour sessions, 2-3 times per week

**Timeline to Production Ready:** 4-5 weeks

**Milestones:**
- **Week 1**: Phases 0-1 complete (Foundation + Reporting) ✅ Phase 0 done
- **Week 2-3**: Phase 2 in progress (RISC-V SoC design) **← Next focus**
- **Week 4**: Phases 3-4 complete (Simulation + Debugging)
- **Week 5**: Phases 5-6 complete (App notes + Agents)

**Current Status (2025-10-22):**
- Phase 0: ✅ Complete (counter design synthesized, constraints working)
- Phase 1: Partially started (timing constraints added, reporting script created)
- Phase 2: RISC-V planning complete, ready to start implementation
- Memory MCP: ✅ Initialized for cross-session continuity

---

## Notes and Lessons Learned

### Constraint Association (2025-10-22)
**Issue:** Constraints not automatically associated with build tools
**Solution:** Use `organize_tool_files` command
**Details:** See `docs/lessons_learned/constraint_association.md`

**Key Takeaway:** Always explicitly associate SDC/PDC files with {SYNTHESIZE} and {PLACEROUTE} tools using `organize_tool_files`, don't assume `import_files` is sufficient.

### Timing-Driven Place & Route (2025-10-22)
**Issue:** Timing-driven P&R mode doesn't enable via TCL
**Status:** Known CLI limitation
**Impact:** Low (design builds correctly, just without timing optimization)
**Workaround:** Use GUI for one-time config, or accept for simple designs

### SmartDesign HDL Module Instantiation (2025-11-24)
**Issue:** `sd_instantiate_hdl_module` cannot instantiate arbitrary Verilog modules in SmartDesign
**Error:** "You cannot instantiate a sub-module of HDL module. You need to instantiate top module."
**Status:** Known TCL API limitation
**Impact:** Medium (requires workaround for designs that need HDL + IP integration)
**Workaround:** Use direct HDL top-level instantiation instead of SmartDesign canvas
**Example:** TMR design (hdl/tmr/tmr_top.v) - instantiates 3x MI-V cores + voter in Verilog
**Future Work:** Investigate SmartDesign component wrapper approach or pre-configure HDL modules as reusable components

---

### Reference Documentation

For comprehensive CLI limitations and workarounds, see:
- **`docs/core/cli_capabilities_and_workarounds.md`** - Complete matrix of scriptable vs GUI-only operations
- **`docs/lessons_learned/`** - Detailed discoveries and solutions from real development

**Additional Future Work Items (from archived explorations):**
- DDR4 configuration patterns (from DDR_CONFIGURATION_ANALYSIS)
- MI-V + DDR4 system integration (from RISCV_DDR_DESIGN)
- Application note automation framework (see docs/specialized/APP_NOTE_AUTOMATION.md)

---

**Last Updated:** 2025-11-24 | **Status:** Phase 0 Complete, TMR Demo Complete, BeagleV-Fire Automation Complete
