# MI-V TMR System Architecture

**Document:** TMR Memory and Peripheral Architecture
**Date:** 2025-11-25
**Status:** Design Phase

---

## System Overview

Triple Modular Redundancy (TMR) system with 3x MI-V RV32IMC cores, triplicated memory, and voted peripheral outputs for fault tolerance.

### Design Goals

1. **Fault Tolerance:** Tolerate single-bit faults in any of the 3 redundant cores
2. **Performance:** 50 MHz operation with minimal voting overhead
3. **Resource Efficiency:** Use fabric resources efficiently (target < 50% LUT utilization)
4. **Peripheral Support:** UART and GPIO with voted outputs

---

## Architecture Components

### 1. Processor Cores (3x MI-V RV32IMC)

**Configuration per core:**
- **ISA:** RV32IMC (base + M extension + C extension)
- **Built-in TCM:** 32KB per core (configured in IP)
- **Clock:** 50 MHz (synchronized across all 3 cores)
- **Reset:** Synchronized reset to all cores

**Instances:**
- `MIV_RV32_CORE_A` - Primary core
- `MIV_RV32_CORE_B` - Redundant core B
- `MIV_RV32_CORE_C` - Redundant core C

### 2. Triplicated Shared Memory

**Architecture:** 3x independent memory banks with read-side voting

**Memory Configuration:**
- **Size per bank:** 64KB (using fabric LSRAMs or PF_SRAM IP)
- **Total:** 192KB (3x 64KB banks)
- **Interface:** AXI4 or AHB-Lite (depends on MI-V core configuration)

**Implementation Options:**

#### Option A: PF_SRAM IP Cores (RECOMMENDED)
```
Advantages:
- Libero IP catalog core (parameterizable via TCL)
- Built-in AXI/AHB interface
- Configurable size and width
- Easy voter integration

Configuration:
- PF_SRAM_C0 → Core A memory (64KB)
- PF_SRAM_C1 → Core B memory (64KB)
- PF_SRAM_C2 → Core C memory (64KB)
```

#### Option B: Direct LSRAM Instantiation
```
Advantages:
- More control over layout
- Potentially lower latency

Disadvantages:
- Requires custom AXI/AHB wrapper
- More complex TCL generation
```

**Decision: Use PF_SRAM IP cores for initial implementation**

**Memory Voting Strategy:**

**Write Path (no voting):**
- Each core writes to its own memory bank independently
- Writes are NOT voted (each core maintains its own state)

**Read Path (with voting):**
- When a core reads from shared memory:
  1. Read from all 3 memory banks simultaneously
  2. Apply bit-wise majority voting
  3. Return voted result to requesting core

**Note:** This approach assumes cores execute the same program and their memory contents stay synchronized under fault-free conditions.

### 3. Peripherals

#### 3.1 UART (CoreUARTapb)

**Configuration:**
- **Instances:** 3x CoreUARTapb (one per core)
- **Baud Rate:** 115200
- **Data Bits:** 8
- **Parity:** None
- **Stop Bits:** 1

**Voting:**
- **TX (Transmit):** Voted output (majority of 3)
- **RX (Receive):** Broadcast to all 3 cores (no voting)

**IP Configuration:**
```tcl
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} \
    -component_name {CoreUART_A} \
    -params { \
        "BAUD_VAL_FRCTN_EN:false" \
        "FIXEDMODE:1" \
        "PRG_BIT8:1" \
        "PRG_PARITY:0" \
        "RX_FIFO:1" \
        "TX_FIFO:1" \
    }
```

#### 3.2 GPIO (CoreGPIO)

**Configuration:**
- **Instances:** 3x CoreGPIO (one per core)
- **Width:** 8 bits per instance
- **Direction:** Configurable (default: output)

**Voting:**
- **Outputs:** Voted (majority of 3)
- **Inputs:** Broadcast to all 3 cores (no voting)

**IP Configuration:**
```tcl
create_and_configure_core \
    -core_vlnv {Actel:DirectCore:CoreGPIO:3.2.102} \
    -component_name {CoreGPIO_A} \
    -params { \
        "APB_WIDTH:8" \
        "FIXED_CONFIG_0:1" \
        "FIXED_CONFIG_1:1" \
        "FIXED_CONFIG_2:1" \
        "FIXED_CONFIG_3:1" \
        "FIXED_CONFIG_4:1" \
        "FIXED_CONFIG_5:1" \
        "FIXED_CONFIG_6:1" \
        "FIXED_CONFIG_7:1" \
        "INT_BUS:0" \
        "IO_INT:0" \
        "OE_TYPE:0" \
    }
```

### 4. Voter Modules

#### 4.1 Memory Read Voter

**HDL Module:** `memory_read_voter.v`

**Parameters:**
- `DATA_WIDTH` = 32 (for RV32)

**Ports:**
```verilog
input  [DATA_WIDTH-1:0] data_a,    // From memory bank A
input  [DATA_WIDTH-1:0] data_b,    // From memory bank B
input  [DATA_WIDTH-1:0] data_c,    // From memory bank C
output [DATA_WIDTH-1:0] data_voted // Voted output
```

**Logic:** Bit-wise majority voting

#### 4.2 UART TX Voter

**HDL Module:** `uart_tx_voter.v`

**Ports:**
```verilog
input  tx_a, tx_b, tx_c  // TX outputs from 3 UARTs
output tx_voted          // Voted TX output
```

**Logic:** Majority voting on TX signal

#### 4.3 GPIO Output Voter

**HDL Module:** `gpio_voter.v`

**Parameters:**
- `WIDTH` = 8

**Ports:**
```verilog
input  [WIDTH-1:0] gpio_a, gpio_b, gpio_c  // GPIO outputs
output [WIDTH-1:0] gpio_voted              // Voted outputs
```

**Logic:** Bit-wise majority voting

### 5. System Interconnect

**Bus Architecture:** AHB-Lite (assuming MI-V cores configured for AHB)

**Components:**
- `COREAHBLITE` interconnect fabric
- Address decoding for memory banks and peripherals

**Memory Map:**
```
0x0000_0000 - 0x0000_FFFF : Core A TCM (32KB, built-in)
0x8000_0000 - 0x8000_FFFF : Shared Memory Bank A (64KB)
0x8001_0000 - 0x8001_FFFF : Shared Memory Bank B (64KB)
0x8002_0000 - 0x8002_FFFF : Shared Memory Bank C (64KB)
0x7000_0000 - 0x7000_0FFF : UART A registers
0x7000_1000 - 0x7000_1FFF : UART B registers
0x7000_2000 - 0x7000_2FFF : UART C registers
0x7001_0000 - 0x7001_0FFF : GPIO A registers
0x7001_1000 - 0x7001_1FFF : GPIO B registers
0x7001_2000 - 0x7001_2FFF : GPIO C registers
```

---

## Resource Estimates

**Based on similar designs:**

| Component | LUTs | FFs | LSRAMs | Notes |
|-----------|------|-----|--------|-------|
| MI-V RV32 (x3) | ~9000 | ~6000 | 96 (TCM) | From IP core estimates |
| PF_SRAM 64KB (x3) | ~300 | ~200 | 96 | 64KB = 32x 20Kbit blocks |
| CoreUARTapb (x3) | ~150 | ~100 | 3 (FIFOs) | Small IP core |
| CoreGPIO (x3) | ~60 | ~40 | 0 | Minimal logic |
| Voters + Interconnect | ~500 | ~300 | 0 | Custom logic |
| **TOTAL ESTIMATE** | **~10k** | **~6.6k** | **195** | < 15% device |

**MPF300TS Resources:**
- LUTs: 68,160 (estimate uses ~15%)
- FFs: 68,160 (estimate uses ~10%)
- LSRAMs: 54 blocks (estimate uses ALL 54!)

**ISSUE:** LSRAM usage too high. Need to reduce shared memory size or use µSRAM.

**Revised Shared Memory:**
- **Size per bank:** 16KB (8x 20Kbit LSRAMs = 16KB)
- **Total:** 48KB (3x 16KB banks)
- **LSRAM usage:** 24 blocks for shared memory + built-in TCM

---

## Implementation Plan

### Phase 1: Memory Architecture (CURRENT)
1. ✅ Define memory architecture
2. Create PF_SRAM instances (3x 16KB)
3. Implement memory read voter HDL
4. Test memory voting in simulation

### Phase 2: Peripheral Integration
1. Add 3x CoreUARTapb instances
2. Add 3x CoreGPIO instances
3. Implement peripheral voters
4. Update SmartDesign with peripherals

### Phase 3: System Integration
1. Update SmartDesign with all components
2. Configure interconnect (COREAHBLITE)
3. Connect voters to outputs
4. Add top-level I/O ports

### Phase 4: Synthesis & Test
1. Run synthesis with updated design
2. Verify resource utilization
3. Check timing closure
4. Generate programming file

---

## Next Steps

1. **Update SmartDesign TCL script** to add:
   - 3x PF_SRAM cores (16KB each)
   - 3x CoreUARTapb
   - 3x CoreGPIO
   - Memory read voter
   - Peripheral output voters

2. **Create voter HDL modules:**
   - `memory_read_voter.v`
   - `uart_tx_voter.v`
   - `gpio_voter.v`

3. **Update constraints:**
   - Add peripheral I/O pins (UART TX/RX, GPIO)
   - Add timing constraints for voter logic

4. **Test build:**
   - Clean rebuild with new architecture
   - Verify resource usage stays reasonable
   - Check timing closure

---

## References

- MI-V RV32 User Guide: `hdl/miv_documentation/`
- PolarFire Fabric Guide: Via fpga_mcp RAG system
- CoreUARTapb Handbook: Libero IP catalog
- CoreGPIO Handbook: Libero IP catalog
