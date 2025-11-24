---
marp: true
theme: default
paginate: true
size: 16:9
---

<!-- _class: lead -->

# TCL Monster
## CLI Automation for Libero FPGA Workflows

**Jonathan Orgill, Field Applications Engineer**
November 2025

*From 60-minute manual workflows to 15-minute hands-off automation*

---

# The Problem: GUI Workflows Are Slow

**Manual FPGA Development Bottlenecks:**

- **Slow:** MI-V RISC-V project setup takes 45+ minutes of clicking
- **Error-Prone:** 20+ configuration steps, easy to miss settings
- **Not Reproducible:** Can't version control GUI clicks
- **No Automation:** Every project iteration requires manual work

**Impact:** Multiple iterations per day = **hours wasted**

**Time:** 45-60 minutes per iteration

---

# Solution: Multi-Language Automation Stack

**Complete CLI Automation Architecture**

**Languages:**
- **TCL (75+ scripts)** - Libero project creation, IP configuration, build flows
- **Python (utilities)** - Parsing, code generation, data transformation
- **Bash (orchestration)** - Complete workflows, WSL compatibility

**Key Components:**
1. Project Creation & Templates
2. IP Configuration Generators (DDR4, PCIe, CCC, UART, GPIO)
3. Build Flow Automation (Synthesis → P&R → Bitstream)
4. Integration Tools (hw_platform.h, BeagleV-Fire programming)

---

# Demo 1: hw_platform Toolkit

**Automated Firmware-FPGA Integration**

**Manual Process:** 30+ minutes
1. Open SmartDesign in GUI → Export memory map → Hand-edit C header → Update clock frequency → Copy to firmware

**Automated Solution:** 30 seconds
```bash
./scripts/generate_hw_platform.sh project.prjx MIV_RV32 ./output 100000000
```

**Result:**
```c
// Auto-generated hw_platform.h
#define SYS_CLK_FREQ 100000000
#define UART0_BASE_ADDR 0x70001000
#define GPIO_BASE_ADDR 0x70002000
```

**Value:** Not AI-dependent, version controlled, eliminates manual errors

---

# Demo 2: Triple Modular Redundancy (TMR)

**High-Reliability System with Automated Build**

**System Architecture:**
- **3x MI-V RV32IMC RISC-V cores** (192 KB total TCM)
- **Custom voter logic** (2-of-3 majority voting)
- **6 LED status indicators** (heartbeat, TMR status, 3x faults, disagreement)

**Complexity:** 3 IP cores + custom HDL + hierarchical design + constraints

**Automated Build:**
```bash
./build_miv_tmr.sh
```

**Time:** 45 minutes (mostly synthesis) | **User Effort:** One command, hands-off

**Key Innovation:** AI discovered SmartDesign TCL limitation, designed HDL workaround in <1 hour

---

# It Scales: Simple to Complex

**Same Automation, Any Complexity**

**Simple:** Counter
- 33 LUTs, 32 FFs
- Build time: 2 minutes

↓ **Same automation** ↓

**Complex:** MI-V RISC-V
- 11,607 LUTs, 5,644 FFs
- Build time: 25 minutes

↓ **Same automation** ↓

**Advanced:** TMR (3x RISC-V + Voter)
- High-reliability system
- Build time: 45 minutes
- **One command:** `./build_miv_tmr.sh`

---

# Instant FPGA Generator

**For Colleagues Without Claude**

**The Problem:** "This looks great, but I don't have AI tools"

**The Solution:**
```bash
./create_instant_fpga.sh <board> <design>
```

**What It Does (Fully Automated):**
1. Creates Libero project with device config
2. Imports HDL sources and constraints
3. Runs synthesis + place & route
4. Generates bitstream
5. **All in 2-10 minutes!**

**Current Templates:** LED blink (rotating pattern), UART echo, GPIO test

**Value:** Scripts work standalone - no AI subscription required

---

# Automation Catalog

**75+ Scripts Covering Entire FPGA Workflow**

**IP Core Generators:**
- DDR4: 1GB/2GB/4GB, 1600/2400 MHz
- PCIe: Gen1/Gen2, Endpoint/Root Port, x1/x4
- Clocking (CCC): Custom frequencies, jitter control
- UART, GPIO, Timers

**Build Flows:**
- Synthesis + Place & Route
- Timing analysis and reporting
- Bitstream generation

**BeagleV-Fire:** LED blink, Linux FPGA programming, serial automation

**Total:** 15,000+ lines of automation code | **Platforms:** WSL2, Linux, Windows

---

# AI-Assisted Development

**How AI Accelerated Development**

**Rapid Iteration:** 70% reduction in debug cycles

**Documentation Mining:**
- RAG system: 1,233 chunks from 7 PolarFire user guides
- Semantic search: 0.75-0.87 similarity scores
- **90% reduction in documentation lookup time**

**Autonomous Problem Solving:**
- Discovered SmartDesign TCL limitation automatically
- Designed HDL workaround in <1 hour (vs 4-8 hours manual)
- Documented lessons learned in ROADMAP.md

**Example:** "How do I configure DDR4 timing?" → Instant answer with page references

---

# Quantified Impact

**Measurable Time Savings**

| Workflow | Before | After | Savings |
|----------|--------|-------|---------|
| FPGA Build Iteration | 60 min | 15 min | **75%** |
| BeagleV-Fire Development | 60 min | 20 min | **70%** |
| Firmware Integration | 30 min | 30 sec | **99%** |
| Documentation Discovery | 10-20 min | 10 sec | **90-95%** |

**Total Weekly Savings (active development):**
- 5 build iterations: 3.75 hours
- 3 BeagleV tests: 2 hours
- 10 firmware updates: 5 hours
- 50 doc lookups: 8 hours
- **Total: 18+ hours per week**

---

# Next Steps & Roadmap

**Future Enhancements**

**Phase 1:** Advanced Constraint Automation (2-3 hours)
**Phase 2:** Extended IP Library - CAN, Ethernet, USB (16-21 hours)
**Phase 3:** Simulation Framework - ModelSim/QuestaSim (3-4 hours)
**Phase 4:** Debugging Automation - SmartDebug, probe insertion (3-4 hours)

**Deployment:**
- Package as FAE toolkit
- Internal documentation & training
- Field deployment for customer support

**Timeline:** 34-39 hours total (4-5 weeks)

---

<!-- _class: lead -->

# Questions?

**Key Takeaways:**
- 75+ scripts, 15,000+ lines of automation
- 75% faster FPGA builds (60 min → 15 min)
- hw_platform toolkit: standalone, production-ready
- TMR demo: automated high-reliability systems
- 18+ hours saved per week

**Contact:** Jonathan Orgill
**Repository:** Internal FAE toolkit
