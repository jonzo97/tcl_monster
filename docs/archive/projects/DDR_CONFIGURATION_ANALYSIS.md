# DDR4 Configuration Analysis

## Overview
Analysis of PF_DDR4 IP core configuration patterns and automation opportunities based on Libero examples and ddr_functions.tcl library.

## Key Resources Discovered

### 1. DDR Functions Library
**Location:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/data/aPA5M/cores/MSS/TCL/ddr_functions.tcl`

**Purpose:** Comprehensive utility library for calculating DDR timing parameters and address mappings.

**Key Functions:**
- `convert_ns_to_memory_clocks` - Convert nanosecond timing to clock cycles
- `convert_us_to_memory_clocks` - Convert microsecond timing to clock cycles
- `returnAXIEndAddressMapValue` - Calculate AXI address space based on memory geometry
- `returnRowAddressMapValue` - Calculate row address mapping
- `returnColAddressMapValue` - Calculate column address mapping
- `calculate_write_recovery` - Calculate write recovery timing
- `returnODTvalue` - Calculate ODT configuration values
- `calculate_vrefdq_trn_value` - Calculate VREF DQ training values
- DDR3, DDR4, LPDDR3, LPDDR4 specific variants of all functions

### 2. PF_DDR4 Configuration Structure

**VLNV:** `Actel:SystemBuilder:PF_DDR4:2.5.113`

**Total Parameters:** 118

**Parameter Categories:**

#### Memory Topology (15 parameters)
```tcl
WIDTH:32                      # Data bus width (16 or 32)
ROW_ADDR_WIDTH:16            # Row address bits (13-16)
COL_ADDR_WIDTH:10            # Column address bits (9-11)
BANK_ADDR_WIDTH:2            # Bank address bits (2 for DDR4)
BANK_GROUP_ADDR_WIDTH:2      # Bank group bits (0-2 for DDR4)
SDRAM_NB_RANKS:1             # Number of ranks (1 or 2)
SDRAM_NUM_CLK_OUTS:1         # Number of clock outputs
MEMORY_FORMAT:COMPONENT      # COMPONENT vs DIMM
ADDRESS_ORDERING:CHIP_ROW_BG_BANK_COL  # Address mapping scheme
ADDRESS_MIRROR:false         # Enable address mirroring
```

**Memory Size Calculation:**
```
Total Size = 2^(ROW + COL + BANK + BG + log2(WIDTH/8) + log2(RANKS))
Example: 2^(16 + 10 + 2 + 2 + 2 + 0) = 2^32 = 4GB
```

#### Clock Configuration (6 parameters)
```tcl
CLOCK_DDR:800.0              # DDR PHY clock in MHz (actual DDR4 rate = 2x = 1600 Mbps)
CLOCK_USER:200.0             # AXI/fabric interface clock in MHz
CLOCK_PLL_REFERENCE:200.000  # PLL reference clock input
CCC_PLL_CLOCK_MULTIPLIER:4   # PLL multiplier (200 MHz * 4 = 800 MHz)
CLOCK_RATE:4                 # Clock rate ratio
DLL_ENABLE:1                 # Enable DLL for timing
```

**Clock Relationships:**
```
DDR PHY Clock = PLL_REFERENCE * CCC_PLL_CLOCK_MULTIPLIER
DDR4 Data Rate = DDR PHY Clock * 2 (DDR = double data rate)
AXI Clock = CLOCK_USER (typically DDR PHY Clock / 4)
```

#### AXI Interface (3 parameters)
```tcl
FABRIC_INTERFACE:AXI4        # AXI4 vs AXI3
AXI_WIDTH:64                 # AXI data bus width (32, 64, 128, 256)
AXI_ID_WIDTH:4               # AXI transaction ID width
```

#### Timing Parameters (31 parameters)
All timing values in nanoseconds or clock cycles:

**Activation Timings:**
```tcl
TIMING_RAS:32                # Row active time (tRAS)
TIMING_RC:45.5               # Row cycle time (tRC)
TIMING_RCD:13.5              # RAS to CAS delay (tRCD)
TIMING_RP:13.5               # Row precharge time (tRP)
```

**Refresh Timings:**
```tcl
TIMING_REFI:7.8              # Refresh interval (tREFI) in μs
TIMING_RFC:350               # Refresh cycle time (tRFC)
```

**Write/Read Timings:**
```tcl
TIMING_WR:15                 # Write recovery time (tWR)
TIMING_WTR_L:6               # Write to read (long) (tWTR_L)
TIMING_WTR_S:2               # Write to read (short) (tWTR_S)
TIMING_RTP:7.5               # Read to precharge (tRTP)
```

**Bank/Group Timings:**
```tcl
TIMING_RRD_L:5               # Row to row delay (long) (tRRD_L)
TIMING_RRD_S:4               # Row to row delay (short) (tRRD_S)
TIMING_CCD_L:4               # CAS to CAS delay (long) (tCCD_L)
TIMING_CCD_S:4               # CAS to CAS delay (short) (tCCD_S)
TIMING_FAW:25                # Four activate window (tFAW)
```

**Data Strobe Timings (picoseconds):**
```tcl
TIMING_DH:150                # Data hold time
TIMING_DS:75                 # Data setup time
TIMING_DQSQ:200              # DQS to DQ skew
TIMING_DQSCK:400             # DQS to CK skew
```

#### ODT Configuration (13 parameters)
```tcl
ODT_ENABLE_WR_RNK0_ODT0:true   # Write ODT for rank 0
ODT_ENABLE_WR_RNK0_ODT1:false
ODT_ENABLE_RD_RNK0_ODT0:false  # Read ODT for rank 0
ODT_ENABLE_RD_RNK0_ODT1:false
RTT_NOM:RZQ4                   # Nominal termination (60Ω)
RTT_WR:OFF                     # Write termination
RTT_PARK:0                     # Park termination
```

**ODT Values:**
- `RZQ4` = 60Ω
- `RZQ6` = 40Ω
- `RZQ7` = 34Ω
- `OFF` = Disabled

#### Drive Strength & Termination (2 parameters)
```tcl
OUTPUT_DRIVE_STRENGTH:RZQ7   # 34Ω output drive
```

#### Latency Configuration (4 parameters)
```tcl
CAS_LATENCY:12               # CAS latency (CL) in clocks
CAS_WRITE_LATENCY:9          # CAS write latency (CWL) in clocks
CAS_ADDITIVE_LATENCY:0       # Additive latency (AL)
BURST_LENGTH:0               # 0 = BL8, 1 = BC4/BL8
```

**Latency Selection:**
Determined by DDR clock frequency and speed grade:
- DDR4-1600: CL=12, CWL=9
- DDR4-2133: CL=15, CWL=11
- DDR4-2400: CL=16, CWL=12
- DDR4-2666: CL=18, CWL=14

#### Training & Calibration (8 parameters)
```tcl
WRITE_LEVELING:ENABLE        # Enable write leveling
VREF_CALIB_ENABLE:0          # VREF calibration
VREF_CALIB_RANGE:0           # VREF range select
VREF_CALIB_VALUE:70.40       # VREF target value
ZQ_CALIB_TYPE:0              # ZQ calibration type
ZQ_CALIB_PERIOD:200          # ZQ calibration period
ZQ_CAL_INIT_TIME:1024        # Initial ZQ cal time
ZQ_CAL_L_TIME:512            # Long ZQ cal time
ZQ_CAL_S_TIME:128            # Short ZQ cal time
```

#### Feature Enables (16 parameters)
```tcl
ENABLE_ECC:false             # Error correction code
ENABLE_INIT_INTERFACE:false  # Expose init interface
ENABLE_SELF_REFRESH:false    # Self-refresh support
ENABLE_USER_ZQCALIB:false    # User ZQ calibration
EXPOSE_TRAINING_DEBUG_IF:false  # Training debug interface
DM_MODE:DM                   # Data mask vs DBI mode
```

## Configuration Patterns by Use Case

### Pattern 1: Standard 4GB DDR4 @ 1600 Mbps (MPF300 Eval Kit)
```tcl
# Memory: 4GB DDR4 x32 (1600 Mbps)
WIDTH:32
ROW_ADDR_WIDTH:16
COL_ADDR_WIDTH:10
BANK_ADDR_WIDTH:2
BANK_GROUP_ADDR_WIDTH:2
SDRAM_NB_RANKS:1

# Clocks: 200 MHz AXI, 800 MHz PHY (1600 Mbps data rate)
CLOCK_USER:200.0
CLOCK_DDR:800.0
CLOCK_PLL_REFERENCE:200.0
CCC_PLL_CLOCK_MULTIPLIER:4

# AXI: 64-bit interface
FABRIC_INTERFACE:AXI4
AXI_WIDTH:64
AXI_ID_WIDTH:4
```

### Pattern 2: Smaller 1GB DDR4 @ 1600 Mbps
```tcl
# Memory: 1GB DDR4 x16
WIDTH:16                     # Change: x16 instead of x32
ROW_ADDR_WIDTH:16           # Same
COL_ADDR_WIDTH:10           # Same
BANK_ADDR_WIDTH:2
BANK_GROUP_ADDR_WIDTH:2
SDRAM_NB_RANKS:1

# Clocks: Same as Pattern 1
# AXI: Can reduce to 32-bit if needed
AXI_WIDTH:32                # Change: Match memory width
```

### Pattern 3: High-Speed 2GB DDR4 @ 2400 Mbps
```tcl
# Memory: 2GB DDR4 x32
WIDTH:32
ROW_ADDR_WIDTH:15           # Change: Reduced rows for 2GB
COL_ADDR_WIDTH:10
BANK_ADDR_WIDTH:2
BANK_GROUP_ADDR_WIDTH:2

# Clocks: Faster
CLOCK_USER:300.0            # Change: 300 MHz AXI
CLOCK_DDR:1200.0            # Change: 1200 MHz PHY (2400 Mbps)
CLOCK_PLL_REFERENCE:200.0
CCC_PLL_CLOCK_MULTIPLIER:6  # Change: 200 * 6 = 1200

# Latency: Adjusted for higher speed
CAS_LATENCY:16              # Change: Higher CL for DDR4-2400
CAS_WRITE_LATENCY:12        # Change: Higher CWL
```

## Automation Strategy

### Level 1: Template-Based Generation
**Input:** High-level parameters (memory size, speed, width)
**Process:** Select appropriate template, fill in values
**Output:** Complete PF_DDR4_C0.tcl configuration

### Level 2: Calculation-Based Generation
**Input:** Memory part number or detailed specs
**Process:**
1. Parse memory specifications (timing datasheet)
2. Use `ddr_functions.tcl` to calculate timing parameters
3. Use address mapping functions to configure geometry
4. Generate complete configuration

### Level 3: Application Note Parsing
**Input:** Microchip app note or reference design
**Process:**
1. Extract working PF_DDR4 configurations from app notes
2. Catalog by memory type, speed, board
3. Allow user to select closest match
4. Adapt to target device/board

## DDR4 Timing Calculation Examples

Using functions from `ddr_functions.tcl`:

### Example 1: Calculate tRFC in clock cycles
```tcl
# DDR4-1600 (800 MHz PHY), tRFC = 350ns
set CLOCK_DDR 800.0
set tRFC 350
set tRFC_clocks [convert_ns_to_memory_clocksForDDR4 "DDR4" $CLOCK_DDR $tRFC 6 511]
# Result: tRFC_clocks = 280 (350ns / 1.25ns per clock)
```

### Example 2: Calculate AXI address space
```tcl
# 4GB DDR4: 32-bit width, 16 row, 10 col, 2 bank, 2 BG, 1 rank
set axi_end_low [returnAXIEndAddressMapValueForDDR4 "DDR4" 32 16 2 10 1 0 2]
set axi_end_high [returnAXIEndAddressMapValueForDDR4 "DDR4" 32 16 2 10 1 1 2]
# Result: 0xFFFFFFFF, 0x0 (4GB address space)
```

### Example 3: Calculate write recovery
```tcl
# DDR4-1600, tWR = 15ns
set CLOCK_DDR 800.0
set tWR 15
set wr_value [calculate_write_recoveryForDDR4 "DDR4" $CLOCK_DDR $tWR]
# Result: wr_value = 12 clocks (15ns / 1.25ns, rounded per spec)
```

## Next Steps for Automation

### Phase 1: Template Library (~20 min)
Create common DDR4 configuration templates:
- `tcl_scripts/lib/templates/ddr4_1gb_1600.tcl`
- `tcl_scripts/lib/templates/ddr4_2gb_1600.tcl`
- `tcl_scripts/lib/templates/ddr4_4gb_1600.tcl`
- `tcl_scripts/lib/templates/ddr4_4gb_2400.tcl`

### Phase 2: Configuration Generator (~30 min)
```tcl
# Usage:
source tcl_scripts/lib/ddr_config_generator.tcl
generate_ddr4_config \
    -size "4GB" \
    -speed "1600" \
    -width "32" \
    -axi_width "64" \
    -component_name "PF_DDR4_C0" \
    -output_file "components/PF_DDR4_C0.tcl"
```

### Phase 3: Memory Part Number Parser (~40 min)
```tcl
# Usage:
generate_ddr4_from_part \
    -part_number "MT40A1G8SA-075:E" \  # Micron part number
    -component_name "PF_DDR4_C0"
# Automatically looks up timing from internal database
```

### Phase 4: App Note Ingestion (~1-2 hours)
- Download Microchip DDR app notes
- Extract working configurations
- Build searchable database
- Allow selection by board/application

## References

### Microchip Documentation
- **Memory Controller User Guide:** `~/fpga_mcp/PolarFire_FPGA_PolarFire_SoC_FPGA_Memory_Controller_User_Guide_VB.pdf` (11MB)
- **AN4597:** PolarFire FPGA PCIe Endpoint DDR3L and DDR4 Memory Controller Data Plane

### Libero Resources
- **DDR Functions:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/data/aPA5M/cores/MSS/TCL/ddr_functions.tcl`
- **Sample Configs:** `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/data/aPA4M/sysbld/cores/*/`

### JEDEC Standards
- **JESD79-4:** DDR4 SDRAM Standard
- **Timing parameters must comply with JEDEC specifications for selected speed bin**
