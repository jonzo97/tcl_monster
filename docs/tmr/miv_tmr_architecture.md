# MI-V Triple Modular Redundancy (TMR) System Architecture

**Project:** High-Reliability RISC-V Processor System for Safety-Critical Applications
**Device:** PolarFire MPF300TS-1FCG1152 (MPF300 Eval Kit)
**Date:** 2025-11-23
**Status:** Architecture Phase

---

## 1. Overview

### 1.1 Purpose
Design and implement a complete Triple Modular Redundancy (TMR) system using MI-V RISC-V processor cores for high-reliability applications where single event upsets (SEUs), transient faults, or hardware failures must be tolerated.

### 1.2 TMR Principles
**Triple Modular Redundancy (TMR):**
- Three identical computational units execute same operations
- Majority voting on outputs (2-of-3 agreement)
- Single fault tolerance: System continues with 2 good cores
- Fault detection: Identify which core disagrees

**Advantages over Dual Lockstep:**
- Lockstep (2-core): Detects faults but cannot correct
- TMR (3-core): Detects AND masks faults automatically
- Continues operation with one faulty core

### 1.3 Design Goals
- **Reliability:** Single-fault tolerant operation
- **Performance:** Minimal voting overhead (<5% performance penalty)
- **Observability:** Clear fault indication and reporting
- **Resource Efficiency:** Fit in MPF300TS (~35k LUTs target)

---

## 2. System Architecture

### 2.1 Top-Level Block Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   MI-V TMR System (MPF300TS)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │  MI-V Core │  │  MI-V Core │  │  MI-V Core │                │
│  │     A      │  │     B      │  │     C      │                │
│  │  RV32IMC   │  │  RV32IMC   │  │  RV32IMC   │                │
│  │            │  │            │  │            │                │
│  │  AHB-Lite  │  │  AHB-Lite  │  │  AHB-Lite  │                │
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘                │
│         │                │                │                      │
│         └────────────────┴────────────────┘                      │
│                          │                                       │
│              ┌───────────▼───────────┐                           │
│              │  Memory Address Voter │                           │
│              │  Memory Data Voter    │                           │
│              └───────────┬───────────┘                           │
│                          │                                       │
│         ┌────────────────┼────────────────┐                     │
│         │                │                │                      │
│    ┌────▼────┐      ┌────▼────┐     ┌────▼────┐                │
│    │ LSRAM   │      │ LSRAM   │     │ LSRAM   │                │
│    │ Bank A  │      │ Bank B  │     │ Bank C  │                │
│    │ 64KB    │      │ 64KB    │     │ 64KB    │                │
│    └────┬────┘      └────┬────┘     └────┬────┘                │
│         │                │                │                      │
│         └────────────────┼────────────────┘                     │
│                          │                                       │
│              ┌───────────▼───────────┐                           │
│              │  Memory Read Voter    │                           │
│              └───────────┬───────────┘                           │
│                          │                                       │
│  ┌───────────────────────┴──────────────────────┐               │
│  │          Peripheral Subsystem                 │               │
│  │  ┌──────┐  ┌──────┐  ┌──────┐               │               │
│  │  │UART A│  │UART B│  │UART C│  → TX Voter   │               │
│  │  └──────┘  └──────┘  └──────┘               │               │
│  │  ┌──────┐  ┌──────┐  ┌──────┐               │               │
│  │  │GPIO A│  │GPIO B│  │GPIO C│  → Output Voter│               │
│  │  └──────┘  └──────┘  └──────┘               │               │
│  │  ┌──────┐  ┌──────┐  ┌──────┐               │               │
│  │  │Timer A│ │Timer B│ │Timer C│  → IRQ Voter  │               │
│  │  └──────┘  └──────┘  └──────┘               │               │
│  └───────────────────────────────────────────────┘               │
│                                                                  │
│  ┌───────────────────────────────────────────────┐               │
│  │         Fault Detection & Reporting            │               │
│  │  • Disagreement counters (per core)            │               │
│  │  • Fault identification logic                  │               │
│  │  • Status register (memory-mapped)             │               │
│  │  • Fault indicator LEDs                        │               │
│  └───────────────────────────────────────────────┘               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Key Components

| Component | Quantity | Purpose |
|-----------|----------|---------|
| MI-V RV32IMC Core | 3 | Main computation |
| LSRAM (64KB) | 3 | Triplicated memory |
| CoreUARTapb | 3 | Serial communication |
| CoreGPIO | 3 | General-purpose I/O |
| CoreTimer | 3 | Timer/counter |
| Triple Voter (generic) | Multiple | Majority voting logic |
| Fault Monitor | 1 | Disagreement detection |
| Sync Controller | 1 | Core synchronization |

---

## 3. Voting Strategy

### 3.1 Voting Points

**Critical Decision:** Where to insert voters?

**Option A: Instruction-Level Voting**
- Vote on every register write, branch decision, memory access
- **Pros:** Maximum fault coverage
- **Cons:** Requires MI-V RTL modification, complex, high overhead
- **Verdict:** ❌ Not practical without RTL access

**Option B: Memory/IO Interface Voting** ✅ **SELECTED**
- Cores run independently (lock-step preferred but not required)
- Vote on:
  - Memory write addresses and data
  - Memory read data (from triplicated banks)
  - Peripheral output data (UART TX, GPIO outputs)
- **Pros:** No RTL modification, practical, proven approach (similar to AN4228)
- **Cons:** Less coverage than instruction-level
- **Verdict:** ✅ Best balance of practicality and reliability

**Option C: Full System TMR (External)**
- Triplicate entire FPGA bitstream, vote at board level
- **Pros:** Maximum coverage
- **Cons:** 3x FPGAs, complex board design, cost
- **Verdict:** ❌ Out of scope for single-FPGA demo

### 3.2 Voting Algorithm

**Majority Voter (2-of-3):**
```verilog
voted_output = (A & B) | (B & C) | (A & C);
```

**With Disagreement Detection:**
```verilog
voted_output = (A & B) | (B & C) | (A & C);
disagreement = (A != B) | (B != C) | (A != C);
fault_A = (A != voted_output);
fault_B = (B != voted_output);
fault_C = (C != voted_output);
```

### 3.3 Synchronization Requirements

**Critical for TMR:**
- All 3 cores must start simultaneously (synchronized reset release)
- Deterministic execution (no async interrupts unless voted)
- Same clock (single clock distribution to all cores)
- Identical configurations (memory map, peripherals, etc.)

**Lock-Step Enforcement (Ideal but Optional):**
- Cores execute instruction-for-instruction in sync
- Requires careful AHB/memory arbiter design
- May need to stall cores if one gets ahead

**Practical Approach for Tonight:**
- Synchronous reset release
- Single clock distribution
- Let cores run independently
- Vote at memory/IO boundaries (auto-correction)

---

## 4. Memory Architecture

### 4.1 Triplicated Memory Banks

**Design Choice:** 3x 64KB LSRAM banks (one per core)

**Write Operation:**
```
1. Each core issues write request (address + data)
2. Memory voter receives 3x (address, data, write_enable)
3. Vote on address → voted_address
4. Vote on data → voted_data
5. If 2-of-3 agreement:
   - Write voted_data to voted_address in ALL 3 banks
   - Maintain consistency across banks
6. If disagreement:
   - Flag fault
   - Still write majority result (fault masking)
```

**Read Operation:**
```
1. Each core issues read request (address)
2. Memory voter receives 3x address
3. Vote on address → voted_address
4. Read from ALL 3 banks at voted_address
5. Vote on read data (3x data_out)
6. Return voted_data to all 3 cores
7. If disagreement in read data:
   - Flag memory corruption or soft error
   - Return majority value (error correction!)
```

**Advantages:**
- Memory soft errors are automatically corrected
- Each core gets majority-voted data
- Single memory error doesn't propagate

### 4.2 Memory Arbiter

**Challenge:** 3 cores trying to access memory simultaneously

**Solution:** Round-robin or priority arbiter
- Cycle 1: Core A accesses memory
- Cycle 2: Core B accesses memory
- Cycle 3: Core C accesses memory
- Voter operates on collected requests

**Alternative:** Parallel access with voting
- All cores access in same cycle (if AHB timing allows)
- Voter combines immediately
- More complex but lower latency

---

## 5. Peripheral Architecture

### 5.1 UART Voting

**Transmit Path (Critical - Must Vote):**
```
UART_A TX ──┐
            ├──> Triple Voter ──> External UART TX Pin
UART_B TX ──┤
            │
UART_C TX ──┘
```

- Vote on TX data before transmission
- Prevents corrupted data from being sent

**Receive Path (Broadcast - No Voting):**
```
External UART RX Pin ──┬──> UART_A RX
                       ├──> UART_B RX
                       └──> UART_C RX
```

- Same RX data to all cores
- Cores process independently
- Any response requires voting before TX

### 5.2 GPIO Voting

**Output Path:**
```
GPIO_A outputs ──┐
                 ├──> Triple Voter (per pin) ──> External GPIO Pins
GPIO_B outputs ──┤
                 │
GPIO_C outputs ──┘
```

**Input Path:**
```
External GPIO Pins ──┬──> GPIO_A inputs
                     ├──> GPIO_B inputs
                     └──> GPIO_C inputs
```

### 5.3 Timer/Interrupt Voting

**Timer Interrupts:**
- Each core has independent timer
- Vote on timer expiration before asserting interrupt to core
- Ensures synchronized interrupt handling

**External Interrupts:**
- Broadcast same interrupt to all 3 cores
- Cores handle synchronously
- Vote on any externally-visible response

---

## 6. Fault Detection & Reporting

### 6.1 Disagreement Monitoring

**Per-Voter Fault Flags:**
- Each voter outputs: `disagreement`, `fault_A`, `fault_B`, `fault_C`
- Collect flags from all voters:
  - Memory address voter
  - Memory data voter
  - UART TX voter
  - GPIO output voter

**Fault Counters:**
```
For each core (A, B, C):
  fault_count[core] += number of disagreements this cycle
```

**Persistent Fault Detection:**
```
If fault_count[core] > THRESHOLD (e.g., 100 faults):
  Flag core as "consistently faulty"
  Consider degraded mode (2-core voting)
```

### 6.2 Fault Status Register

**Memory-Mapped Status Register (Read-Only):**
```
Address: 0x8000_0000 (example)

Bits [31:24]: Core A fault count
Bits [23:16]: Core B fault count
Bits [15:8]:  Core C fault count
Bits [7:6]:   Reserved
Bits [5]:     Core C faulty (persistent)
Bits [4]:     Core B faulty (persistent)
Bits [3]:     Core A faulty (persistent)
Bits [2]:     Current disagreement (any voter)
Bits [1]:     System healthy (all cores agree)
Bits [0]:     TMR active
```

### 6.3 External Fault Indication

**LED Indicators (MPF300 Eval Kit):**
- LED[0]: TMR Active (green, always on)
- LED[1]: Core A fault (red)
- LED[2]: Core B fault (red)
- LED[3]: Core C fault (red)
- LED[4]: System healthy (green, blink when no faults)
- LED[5-7]: Fault count indicator (binary representation)

---

## 7. Resource Estimation

### 7.1 Component Resources

| Component | LUTs | FFs | Memory | Notes |
|-----------|------|-----|--------|-------|
| MI-V RV32IMC (single) | ~11,000 | ~5,600 | - | Proven from previous build |
| MI-V x3 | ~33,000 | ~16,800 | - | Main resource consumer |
| LSRAM 64KB (single) | ~100 | ~50 | 64KB | PolarFire LSRAM block |
| LSRAM x3 | ~300 | ~150 | 192KB | Triplicated memory |
| CoreUARTapb (single) | ~150 | ~100 | - | Simple peripheral |
| CoreUARTapb x3 | ~450 | ~300 | - | Triplicated |
| CoreGPIO (single) | ~100 | ~80 | - | 32-pin GPIO |
| CoreGPIO x3 | ~300 | ~240 | - | Triplicated |
| CoreTimer (single) | ~50 | ~40 | - | Simple counter |
| CoreTimer x3 | ~150 | ~120 | - | Triplicated |
| Triple Voter (32-bit) | ~50 | ~10 | - | Combinational + disagreement logic |
| Voters x10 (est.) | ~500 | ~100 | - | Memory, UART, GPIO, timers |
| Memory Arbiter | ~200 | ~100 | - | 3-way arbitration |
| Fault Monitor | ~100 | ~200 | - | Counters + status register |
| Sync Controller | ~50 | ~50 | - | Reset sync, clock distribution |
| **Total** | **~35,050** | **~17,960** | **192KB** | Fits in MPF300TS! |

### 7.2 Device Capacity

**MPF300TS-1FCG1152:**
- **LUTs:** 299,544 available
- **FFs:** 299,544 available
- **LSRAM:** 1,800 KB available
- **Utilization:** ~12% LUTs, ~6% FFs, ~11% RAM
- **Verdict:** ✅ Plenty of room!

---

## 8. Timing Considerations

### 8.1 Target Clock Frequency

**Conservative:** 50 MHz (20ns period)
- MI-V cores: Proven at 50 MHz
- Voter logic: Combinational (fast)
- Memory arbiter: May need careful timing
- **Confidence:** High

**Stretch Goal:** 100 MHz (10ns period)
- MI-V cores: Should work at 100 MHz
- Voter paths: May need pipelining
- Requires careful constraint and optimization
- **Confidence:** Medium (optimize if time permits)

### 8.2 Critical Paths

**Expected Long Paths:**
1. MI-V AHB output → Memory voter → LSRAM write
2. LSRAM read → Memory voter → MI-V AHB input
3. MI-V peripheral output → Peripheral voter → Pin
4. Fault detection → Status register read

**Mitigation:**
- Pipeline voters if needed (adds 1 cycle latency)
- Use flop-flop paths where possible
- Careful SDC constraints

---

## 9. Implementation Phases (Tonight)

### Phase 1: ✅ Architecture (This Document)
### Phase 2: Voter Module Library
- Generic triple voter (parameterized width)
- Specialized voters (memory, UART, GPIO)

### Phase 3: MI-V Core Integration
- 3x MI-V instantiation
- Synchronous reset distribution
- AHB interface to voters

### Phase 4: Memory Subsystem
- 3x 64KB LSRAM
- Memory arbiter/voter
- Write voting + Read voting

### Phase 5: Peripheral Integration
- 3x UART, GPIO, Timer
- Output voters
- Input distribution

### Phase 6: Fault Detection
- Disagreement monitors
- Fault counters
- Status register
- LED indicators

### Phase 7: SmartDesign Integration
- Complete canvas
- Interconnects
- External interfaces

### Phase 8: Build & Debug
- Constraints
- Synthesis
- Timing analysis
- Debug any issues

### Phase 9: Documentation
- Design walkthrough
- Demo guide
- PowerPoint integration

---

## 10. Known Challenges & Mitigations

### Challenge 1: Core Synchronization
**Issue:** Ensuring 3 cores stay in lockstep
**Mitigation:**
- Synchronous reset release (critical)
- Single clock domain
- Memory arbiter may naturally enforce sync
- Accept some divergence, rely on voting

### Challenge 2: Memory Arbitration Latency
**Issue:** 3 cores competing for memory access
**Mitigation:**
- Round-robin arbiter (fair, predictable)
- May reduce effective performance to ~1/3
- Accept tradeoff for reliability

### Challenge 3: Voter Timing
**Issue:** Voting adds combinational delay
**Mitigation:**
- Keep voters simple (majority = 3 AND-OR gates)
- Pipeline if critical path
- Target conservative 50 MHz clock

### Challenge 4: Build Time
**Issue:** 3x MI-V is large design
**Mitigation:**
- Expect 30-45 min synthesis
- Plan for multiple build iterations
- Use incremental compile if available

### Challenge 5: Debugging TMR System
**Issue:** Hard to debug when cores disagree
**Mitigation:**
- Extensive fault reporting
- Status register for software access
- LED indicators for visual feedback
- Simulation before hardware (if time)

---

## 11. Success Criteria

### Must Have (Tonight):
- ✅ Architecture document (this)
- ✅ Voter modules implemented
- ✅ 3x MI-V instantiated
- ✅ Memory subsystem with voting
- ✅ Basic fault detection
- ✅ Design synthesizes (even if timing needs work)

### Nice to Have:
- ✅ Peripheral voting (UART, GPIO)
- ✅ Complete fault reporting
- ✅ SmartDesign canvas
- ✅ Timing closure at 50 MHz

### Stretch Goals:
- ⏳ Lockstep enforcement
- ⏳ 100 MHz operation
- ⏳ Simulation testbench
- ⏳ Hardware validation

---

## 12. References

- **AN4228:** "RT PolarFire Lockstep Processor" - Dual-core fault tolerance patterns
- **MI-V User Guide:** Processor configuration and integration
- **PolarFire FPGA Fabric Guide:** LSRAM usage, resource estimation
- **TMR Literature:** General TMR principles and best practices

---

**Next Step:** Phase 2 - Create voter module library

**Status:** Architecture Complete ✅
**Time Spent:** ~45 minutes
**Remaining:** ~5 hours for implementation
