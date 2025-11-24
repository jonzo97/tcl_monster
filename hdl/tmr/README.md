# TMR Voter Module Library

Verilog modules for implementing Triple Modular Redundancy (TMR) in FPGA designs.

## Modules

### 1. `triple_voter.v` - Generic Triple Voter
**Purpose:** Parameterized 2-of-3 majority voter for any data width

**Parameters:**
- `WIDTH` - Data width (1 to 512 bits)

**Inputs:**
- `input_a`, `input_b`, `input_c` - Three inputs to vote on
- `clk`, `rst_n` - Clock and reset

**Outputs:**
- `voted_output` - Majority result
- `disagreement` - High if any inputs disagree
- `fault_flags[2:0]` - Per-input fault indication

**Latency:** 1 clock cycle (registered output for timing)

---

### 2. `memory_voter.v` - Memory Voter
**Purpose:** Vote on memory addresses and data for TMR memory subsystem

**Handles:**
- Memory address voting (from 3 cores)
- Memory write data voting
- Memory read data voting (from 3 banks)

**Interfaces:**
- 3x core memory interfaces (address, wdata, wen, ren, rdata)
- 1x voted memory interface (to triplicated banks)

**Features:**
- Separate fault detection for address, wdata, rdata
- Distributes voted read data to all cores
- Latency: 2 clock cycles

---

### 3. `peripheral_voter.v` - Peripheral Voter
**Purpose:** Vote on peripheral outputs (UART TX, GPIO, etc.)

**Handles:**
- Output data voting (3 cores → 1 pin)
- Input data broadcast (1 pin → 3 cores)

**Use Cases:**
- UART TX voting
- GPIO output voting
- Timer outputs

**Features:**
- Separate data and valid signal voting
- Input broadcast (same data to all cores)
- Latency: 1 clock cycle

---

### 4. `tmr_sync_controller.v` - Synchronization Controller
**Purpose:** Ensure all 3 cores start simultaneously

**Features:**
- Synchronized reset distribution
- 2-stage reset synchronizer (metastability protection)
- Sync status monitoring

**Outputs:**
- `rst_n_core_a`, `rst_n_core_b`, `rst_n_core_c` - Synchronized resets
- `sync_active` - Synchronization status
- `sync_counter` - Debug counter

---

### 5. `tmr_fault_monitor.v` - Fault Monitor
**Purpose:** Collect and report disagreements from all voters

**Inputs:**
- Disagreement flags from all voters
- Fault flags from all voters

**Outputs:**
- `fault_count_a/b/c` - Per-core fault counters (16-bit)
- `core_a/b/c_faulty` - Persistent fault flags
- `system_healthy` - All cores agree
- `any_disagreement` - Any voter reports disagreement

**Features:**
- Per-core fault counting
- Persistent fault detection (threshold-based)
- System health status

**Threshold:** 100 faults → core marked as persistently faulty

---

## Usage Example

```verilog
// Instantiate memory voter
memory_voter #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
) mem_voter (
    .clk(clk),
    .rst_n(rst_n),

    // Connect 3 cores
    .addr_a(core_a_addr),
    .wdata_a(core_a_wdata),
    // ... (similar for B, C)

    // Connect to memory banks
    .voted_addr(mem_addr),
    .voted_wdata(mem_wdata),
    // ...

    // Fault detection
    .addr_disagreement(mem_addr_fault),
    .wdata_disagreement(mem_wdata_fault)
);

// Instantiate fault monitor
tmr_fault_monitor fault_mon (
    .clk(clk),
    .rst_n(rst_n),

    // Connect voter disagreements
    .mem_addr_disagreement(mem_addr_fault),
    .mem_wdata_disagreement(mem_wdata_fault),
    // ...

    // System status
    .system_healthy(health_led),
    .core_a_faulty(fault_led_a)
);
```

---

## Testing

Testbenches (to be created):
- `tb_triple_voter.v` - Unit test for generic voter
- `tb_memory_voter.v` - Memory voting scenarios
- `tb_tmr_system.v` - Full system integration

---

## Resource Utilization

Per module (estimated for MPF300TS):

| Module | LUTs | FFs | Notes |
|--------|------|-----|-------|
| triple_voter (32-bit) | ~50 | ~10 | Simple majority logic |
| memory_voter | ~200 | ~100 | 3x voter instances |
| peripheral_voter (8-bit) | ~30 | ~20 | Small data width |
| tmr_sync_controller | ~10 | ~15 | Simple sync logic |
| tmr_fault_monitor | ~100 | ~200 | Counters + comparison |

---

**Status:** ✅ Complete and ready for integration
**Next:** Integrate with MI-V cores in SmartDesign
