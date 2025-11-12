# BeagleV-Fire Development Guide

**Last Updated:** 2025-11-12
**Status:** Phase 1 - Setup & Understanding (In Progress)
**Project Goal:** Modify/extend BeagleV-Fire reference design with custom MSS, FPGA fabric, and cape connectors

---

## Quick Reference

**Target Device:** MPFS025T-FCVG484E (PolarFire SoC)
**Board:** BeagleV-Fire by BeagleBoard.org
**CPU:** 5x RISC-V cores (4x U54 @ 625MHz + 1x E51 monitor)
**FPGA Fabric:** 23K logic elements, 68 math blocks, 1.8 MB embedded RAM
**External Memory:** 2GB LPDDR4, 16GB eMMC, 128Mbit SPI Flash

**Key Documentation:**
- Official gateware: https://github.com/beagleboard/beaglev-fire-gateware
- PolarFire SoC docs: https://www.microchip.com/design-centers/fpga-soc/fpga/polarfire-soc
- BeagleV-Fire board: https://www.beagleboard.org/boards/beaglev-fire

---

## Repository Structure

```
tcl_monster/
├── beaglev-fire-gateware/          [3.5 MB] Official BeagleBoard.org reference design
│   ├── README.md                    Main documentation
│   ├── build-options/               YAML configurations (8 variants)
│   ├── recipes/libero-project/      TCL build flow scripts
│   ├── sources/FPGA-design/         FPGA design components + HDL
│   └── boards/                      Board-specific configs
│
├── beaglev_fire_demo/               [16 KB] Empty Libero project skeleton
│   ├── beaglev_fire_demo.prjx       Project file (minimal/empty)
│   ├── designer/impl1/              Design implementation (empty)
│   ├── hdl/                         HDL sources (empty - ready for custom design)
│   └── constraint/                  Constraints (empty)
│
├── config/
│   └── beaglev_fire_config.json     Project configuration metadata
│
└── tcl_scripts/beaglev_fire/        [12 KB] TCL automation scripts
    ├── create_minimal_project.tcl   Creates blank PolarFire SoC project
    └── README.md                     Usage documentation
```

---

## Three Resources Explained

### 1. beaglev-fire-gateware/ (Complete Reference Design)

**What it is:** Official production-ready gateware from BeagleBoard.org with full board support.

**Key Features:**
- Python-based bitstream builder combining HSS bootloader + MSS config + FPGA fabric
- 8 different build configurations via YAML files
- Complete TCL/HDL implementation for all board peripherals
- Production-tested and maintained

**Build Configurations:**

| Config | Description | Version | Use Case |
|--------|-------------|---------|----------|
| `default.yaml` | Full design with DEFAULT cape + M.2 Wi-Fi | v2.0.5 | General purpose, Wi-Fi enabled |
| `minimal.yaml` | Linux only, no FPGA fabric | v1.0.5 | Software-only, minimal resources |
| `picorv-apu.yaml` | DEFAULT cape + M.2 + PicoRV32 CPU | v6.0.1 | Custom RISC-V soft core in fabric |
| `sin-shls-apu.yaml` | SmartHLS sin() accelerator | | Hardware acceleration demo |
| `cape-4-uarts.yaml` | 4 serial UART ports on cape | | Multi-UART applications |
| `cape-comms.yaml` | Communications cape, no M.2 | | Comms-focused design |
| `click-boards.yaml` | Click cape support | | MikroElektronika Click boards |
| `robotics.yaml` | Robotics cape (encoders, servos) | | Robotics applications |
| `board-tests.yaml` | Device validation test suite | | Board bring-up and testing |

**Key Files:**
```
beaglev-fire-gateware/
├── build-options/
│   ├── default.yaml              Full design configuration
│   ├── picorv-apu.yaml          PicoRV32 RISC-V core variant
│   └── [6 more variants]
│
├── recipes/libero-project/       TCL build automation
│   ├── generate-project.tcl     Project creation
│   ├── configure.tcl            Project configuration
│   ├── import-clients.tcl       Import MSS/fabric components
│   ├── run-flow.tcl             Execute synthesis/P&R
│   ├── constraints.tcl          I/O and timing constraints
│   ├── export-data.tcl          Bitstream generation
│   └── functions.tcl            Reusable TCL utilities
│
└── sources/FPGA-design/
    ├── BUILD_BVF_GATEWARE.tcl   Main Libero build script
    ├── mss.bundle               Git bundle of MSS configuration
    └── script_support/components/
        ├── APU/                 Additional Processing Units
        │   ├── NONE/
        │   ├── PICO_RV/         PicoRV32 soft RISC-V core
        │   └── SMARTHLS/        SmartHLS C→HDL accelerators
        ├── BVF_RISCV_SUBSYSTEM/ User LED GPIO config
        ├── CAPE/                Cape connector interfaces (9 variants)
        ├── M2/                  M.2 E-Key socket logic (4 variants)
        ├── MIPI_CSI/            Camera interface (5 variants)
        └── SYZYGY/              SYZYGY high-speed connector
```

**How to Use:**
```bash
cd beaglev-fire-gateware
python3 build-bitstream.py ./build-options/default.yaml

# Output: Full bitstream ready for programming
```

**When to Use:**
- Learning the complete board design
- Production deployment (use as-is or lightly modified)
- Understanding reference implementations of peripherals
- Quick prototyping with existing configurations

---

### 2. beaglev_fire_demo/ (Empty Starting Point)

**What it is:** Fresh Libero project skeleton correctly configured for BeagleV-Fire hardware.

**Status:** Empty - no HDL sources, constraints, or design logic yet.

**Purpose:** Starting point for building custom FPGA designs from scratch.

**Created by:** `tcl_scripts/beaglev_fire/create_minimal_project.tcl`

**Project Configuration:**
- **Device:** MPFS025T-FCVG484E
- **Package:** FCVG484 (484-pin BGA)
- **Speed Grade:** STD
- **Die Voltage:** 1.05V
- **I/O Standard:** LVCMOS 1.8V (default)

**Empty Directories:**
- `hdl/` - Ready for custom Verilog/VHDL sources
- `constraint/` - Ready for I/O and timing constraints
- `component/` - Ready for SmartDesign components
- `designer/impl1/` - Empty design implementation workspace

**When to Use:**
- Building entirely custom FPGA designs
- Learning Libero project structure
- Experimenting with simple designs before adding complexity
- tcl_monster automation development/testing

---

### 3. tcl_scripts/beaglev_fire/ (Minimal Automation)

**What it is:** Single TCL script for creating blank BeagleV-Fire projects.

**Contents:**
- `create_minimal_project.tcl` (~100 lines) - Creates empty Libero project
- `README.md` - Usage documentation

**What it does:**
```tcl
# Creates fresh Libero project with correct device config
new_project \
    -location "./beaglev_fire_demo" \
    -name "beaglev_fire_demo" \
    -hdl VERILOG \
    -family PolarFire \
    -die MPFS025T \
    -package FCVG484 \
    -speed STD \
    -die_voltage 1.05 \
    ...
```

**Usage:**
```bash
cd /mnt/c/tcl_monster
./run_libero.sh tcl_scripts/beaglev_fire/create_minimal_project.tcl SCRIPT
```

**When to Use:**
- Starting new custom BeagleV-Fire projects
- Testing tcl_monster automation
- Template for more advanced project creation scripts

**Limitations:**
- Only creates empty project - doesn't add HDL, MSS, or constraints
- No build flow automation yet
- Planned expansion: integrate MSS config, add build scripts, constraint generation

---

## Device Specifications

### MPFS025T-FCVG484E (PolarFire SoC)

**Microprocessor Subsystem (MSS):**
- **CPU Cores:** 5x RISC-V
  - 4x U54 application cores @ 625 MHz (RV64GC - 64-bit with IMAFD extensions + Compressed)
  - 1x E51 monitor core @ 625 MHz (RV64IMAC - 64-bit with IMAC + Compressed)
- **L1 Cache:** 16KB I-cache + 16KB D-cache per U54 core
- **L2 Cache:** 2MB shared
- **Memory Controllers:**
  - DDR4 controller (2GB LPDDR4 on BeagleV-Fire)
  - eNVM (embedded Non-Volatile Memory)
- **Peripherals (MSS):**
  - 2x Gigabit Ethernet (GEM)
  - 1x USB 2.0 OTG
  - 5x UART (1 reserved for debug console)
  - 2x SPI
  - 2x I2C
  - 2x CAN
  - GPIO
  - Timers, Watchdogs, RTC

**FPGA Fabric:**
- **Logic Elements:** 23,352
- **Math Blocks:** 68 (18x18 MACC - multiply-accumulate)
- **Embedded RAM:** 1.8 MB total
  - LSRAM (Large SRAM): 1,536 Kbit
  - µSRAM (Micro SRAM): 426 Kbit
- **SerDes Transceivers:** 4 lanes @ 12.7 Gbps (PCIe Gen2 capable)
- **Clock Resources:**
  - PLL (Phase-Locked Loop)
  - DLL (Delay-Locked Loop)
  - Global clock networks
- **I/O Banks:** Multiple, supporting various I/O standards (LVCMOS, LVDS, HSIO)

**I/O Pins (FPGA Fabric):**
- **Total User I/O:** 108 pins available to FPGA fabric
- **Routing:** Connected to cape headers (P8/P9), M.2 socket, SYZYGY connector, MIPI CSI
- **Default Standard:** LVCMOS 1.8V

**Package:** FCVG484 (484-pin Fine-pitch Ceramic Ball Grid Array)

---

## Board Peripherals & Interfaces

### BeagleV-Fire Board Features

**Connectors:**
- **Cape Headers (P8/P9):** 2x 46-pin headers (BeagleBone-compatible expansion)
- **M.2 E-Key Socket:** Wi-Fi card, PCIe peripherals (PCIe Gen2 x1)
- **SYZYGY Connector:** High-speed peripheral expansion
- **MIPI CSI Connector:** Camera sensor interface (supports IMX219, etc.)
- **Ethernet:** 2x Gigabit RJ45 (MSS GEM controllers)
- **USB:** 1x USB Type-C (USB 2.0 OTG)
- **Debug:** UART console, JTAG/SWD header
- **Power:** USB-C PD or barrel jack

**Storage:**
- **eMMC:** 16GB on-board
- **microSD:** SD card slot (boot/storage)
- **SPI Flash:** 128Mbit for bootloader/config

**Onboard Peripherals:**
- **User LEDs:** Controllable from FPGA fabric (defined in BVF_RISCV_SUBSYSTEM component)
- **Boot mode switches:** Configure boot source
- **Reset button**

---

## Modular Component Architecture

The reference design uses a modular architecture where different components can be mixed/matched:

### APU (Additional Processing Unit)

| Variant | Description | Use Case |
|---------|-------------|----------|
| `NONE` | No additional CPU | Default - MSS RISC-V cores only |
| `PICO_RV` | PicoRV32 soft RISC-V core (RV32IMC) | Custom soft CPU in fabric |
| `SMARTHLS` | SmartHLS C/C++ → HDL accelerators | Hardware acceleration from C code |

**Files:** `sources/FPGA-design/script_support/components/APU/`

### CAPE (Cape Connector Configuration)

| Variant | Description | Pins Used |
|---------|-------------|-----------|
| `DEFAULT` | Default cape config (basic GPIO) | P8/P9 mixed |
| `4_UARTS` | 4 serial UART ports | P8/P9 UARTs |
| `CLICK_BOARDS` | MikroElektronika Click cape | P8/P9 SPI/I2C/GPIO |
| `COMMS_CAPE` | Communications cape | P8/P9 comms |
| `GPIOS` | Maximum GPIO breakout | P8/P9 GPIO |
| `ROBOTICS` | Encoders, servos, sensors | P8/P9 robotics |
| `VERILOG_TEMPLATE` | Example custom Verilog cape | Template |
| `VERILOG_TUTORIAL` | Tutorial for custom cape logic | Learning |
| `NONE` | No cape support | Minimal |

**Files:** `sources/FPGA-design/script_support/components/CAPE/`

### M2 (M.2 E-Key Socket)

| Variant | Description | SerDes Lanes |
|---------|-------------|--------------|
| `DEFAULT` | Wi-Fi card support (PCIe + USB) | PCIe x1 |
| `BOARD_TESTS` | Test M.2 connectivity | Test mode |
| `PCIE_ONLY` | Pure PCIe (no USB) | PCIe x1 |
| `NONE` | M.2 socket disabled | 0 |

**Files:** `sources/FPGA-design/script_support/components/M2/`

### MIPI_CSI (Camera Interface)

| Variant | Description | Supported Sensors |
|---------|-------------|-------------------|
| `DEFAULT` | Basic camera support | IMX219, etc. |
| `IMX219_PHY_TEST` | IMX219 PHY validation | IMX219 |
| `IO_BOARD_VALIDATION` | I/O board testing | Test suite |
| `IO_STUB` | Stub for testing without camera | None |
| `NONE` | Camera disabled | None |

**Files:** `sources/FPGA-design/script_support/components/MIPI_CSI/`

### SYZYGY (High-Speed Connector)

**Files:** `sources/FPGA-design/script_support/components/SYZYGY/`

---

## Development Workflow Strategies

### Strategy 1: Use Reference Design As-Is
**Best for:** Quick deployment, learning board capabilities

**Steps:**
1. Choose configuration: `beaglev-fire-gateware/build-options/[config].yaml`
2. Build: `python3 build-bitstream.py ./build-options/default.yaml`
3. Program board with generated bitstream
4. Boot Linux and test

**Pros:** Fast, guaranteed to work, fully featured
**Cons:** Limited customization, harder to understand internals

---

### Strategy 2: Build Custom Design from Scratch
**Best for:** Learning Libero, simple custom logic, tcl_monster development

**Steps:**
1. Create project: `./run_libero.sh tcl_scripts/beaglev_fire/create_minimal_project.tcl SCRIPT`
2. Add custom HDL to `beaglev_fire_demo/hdl/`
3. Create SmartDesign components
4. Add constraints
5. Build with Libero

**Pros:** Full control, understand every detail, clean simple designs
**Cons:** Time-consuming, need to configure MSS manually, more complexity for full board support

---

### Strategy 3: Modify/Extend Reference Design ⭐ **CURRENT APPROACH**
**Best for:** Custom peripherals while leveraging reference MSS config

**Steps:**
1. Extract reference TCL scripts from `beaglev-fire-gateware/recipes/`
2. Import MSS configuration (from `mss.bundle`)
3. Select base components (APU, CAPE, M2, MIPI_CSI variants)
4. Add custom HDL/SmartDesign components
5. Integrate into tcl_monster build automation
6. Build with custom workflow

**Pros:** Best of both worlds - working MSS + custom fabric
**Cons:** Need to understand reference structure, more complex automation

**Development Plan:**
- **Phase 1:** Setup & understand reference structure (~30-45 min)
- **Phase 2:** Extract/adapt TCL scripts into tcl_monster (~1-2 hours)
- **Phase 3:** Add custom modifications (MSS, fabric, cape) (~2-3 hours)
- **Phase 4:** Build automation & documentation (~1-2 hours)

---

## Key TCL Scripts (Reference Design)

### recipes/libero-project/generate-project.tcl
**Purpose:** Creates Libero project with device configuration

**Key Functions:**
- `new_project` - Project initialization
- Device configuration (MPFS025T, package, voltage, speed)
- Project options (enhanced constraint flow, instantiate in SmartDesign, etc.)

### recipes/libero-project/configure.tcl
**Purpose:** Configures project-specific settings

### recipes/libero-project/import-clients.tcl
**Purpose:** Imports MSS configuration and FPGA fabric components

**Key Operations:**
- Extracts MSS from `mss.bundle` (git bundle)
- Imports modular components based on YAML config (APU, CAPE, M2, MIPI_CSI)
- Connects components in SmartDesign

### recipes/libero-project/run-flow.tcl
**Purpose:** Executes synthesis and place & route

**Commands:**
- `run_tool -name SYNTHESIZE` - Synplify Pro synthesis
- `run_tool -name PLACEROUTE` - Place and route
- `run_tool -name VERIFYTIMING` - Timing verification

### recipes/libero-project/constraints.tcl
**Purpose:** Applies I/O and timing constraints

**Constraint Types:**
- Pin assignments (PDC files)
- Timing constraints (SDC files)
- I/O standards and voltage banks

### recipes/libero-project/export-data.tcl
**Purpose:** Generates bitstream and exports programming files

**Outputs:**
- `.stp` - Libero programming file
- `.hex` - Raw bitstream
- Reports and logs

### recipes/libero-project/functions.tcl
**Purpose:** Reusable TCL utility functions

**Functions:**
- Path manipulation
- File operations
- Component instantiation helpers

---

## MSS Configuration (Microprocessor Subsystem)

The MSS configuration defines:
- **CPU core settings** (frequency, cache, AMP/SMP mode)
- **Peripheral routing** (which MSS peripherals are enabled and routed to I/O)
- **Memory map** (address ranges for peripherals, memory, fabric interfaces)
- **Clock configuration** (MSS clock tree)
- **Boot configuration** (boot mode, eNVM settings)

**Storage:** `sources/FPGA-design/mss.bundle` (git bundle format)

**Extracting MSS:**
```bash
cd sources/FPGA-design
git bundle unbundle mss.bundle
# Creates MSS configuration files for import into Libero
```

**MSS Configuration Tool:** Microchip provides a GUI tool for MSS configuration (part of Libero)

---

## Next Steps (Phase 1 Continued)

**Current Status:** PROJECT_STATE.json updated, documentation created

**Remaining Phase 1 Tasks:**
1. **Read key reference TCL scripts** (~10 min)
   - `recipes/libero-project/generate-project.tcl`
   - `recipes/libero-project/import-clients.tcl`
   - `recipes/libero-project/run-flow.tcl`
   - `sources/FPGA-design/BUILD_BVF_GATEWARE.tcl`

2. **Test reference design Python builder** (~15 min)
   - Run: `cd beaglev-fire-gateware && python3 build-bitstream.py ./build-options/default.yaml`
   - Observe build process, generated files, logs
   - Understand how Python script orchestrates TCL execution

3. **Create initial project directory structure** (~5 min)
   - `libero_projects/beaglev_fire/` - Working project directory
   - `hdl/beaglev_fire/` - Custom HDL sources
   - `config/beaglev_fire_variants.json` - Configuration variants

4. **Document findings** (~10 min)
   - Update this guide with insights from TCL script reading
   - Add notes about Python builder workflow
   - Plan Phase 2 integration approach

---

## Future Integration (Phase 2+)

**Planned tcl_monster Integration:**
- `tcl_scripts/beaglev_fire/import_reference_design.tcl` - Imports MSS + base components
- `tcl_scripts/beaglev_fire/customize_design.tcl` - Adds custom modifications
- `tcl_scripts/beaglev_fire/build_beaglev.tcl` - Complete build flow
- `config/beaglev_fire_variants.json` - Parameterized configurations (JSON)

**Build Doctor Integration:**
- Analyze BeagleV-Fire build logs
- Timing closure recommendations for PolarFire SoC
- Resource utilization analysis

**Documentation:**
- BeagleV-Fire-specific design guide
- Cape connector interface library
- MSS integration examples

---

## Resources

**Official Documentation:**
- BeagleV-Fire gateware: https://github.com/beagleboard/beaglev-fire-gateware
- BeagleV-Fire board: https://www.beagleboard.org/boards/beaglev-fire
- PolarFire SoC: https://www.microchip.com/design-centers/fpga-soc/fpga/polarfire-soc
- PolarFire SoC Documentation: https://mi-v-ecosystem.github.io/redirects/asymmetric-multiprocessing-on-polarfire-soc-master

**FPGA MCP Documentation Search:**
- Use `~/fpga_mcp` RAG system for PolarFire SoC-specific questions
- Indexed docs: User IO Guide, Clocking Guide, Datasheet, Transceiver Guide, Memory Controller Guide

**Microchip Support:**
- Libero SoC v2024.2 installation: `/mnt/c/Microchip/Libero_SoC_v2024.2/`
- Sample scripts: `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl`
- Help system: `/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/doc/libero_help/`

---

---

## TCL Script Analysis (Phase 1 Findings)

### BUILD_BVF_GATEWARE.tcl - Main Build Script (349 lines)

**Purpose:** Parameterized project creation and full build flow for BeagleV-Fire gateware.

**Key Features:**
- **Libero Version Detection:** Validates Libero v2022.3, v2023.2, v2024.1, v2024.2, v2025.1
- **Path Length Validation:** Ensures Windows project paths < 90 characters
- **Command-Line Arguments:** TCL variable assignment via `PARAM:VALUE` syntax
- **Modular Component Selection:** CAPE_OPTION, M2_OPTION, APU_OPTION, SYZYGY_OPTION, MIPI_CSI_OPTION
- **Device Configuration:** Die, package, voltage parameterized
- **MSS Configuration:** LPDDR4, width configurable
- **Full Build Flow:** Synthesis → P&R → Timing verification → Bitstream generation

**Parameter Handling:**
```tcl
# Example command-line usage:
# libero.exe SCRIPT:BUILD_BVF_GATEWARE.tcl CAPE_OPTION:ROBOTICS M2_OPTION:NONE APU_OPTION:PICO_RV

# Script parses arguments:
if { $::argc > 0 } {
    foreach arg $::argv {
        if {[string match "*:*" $arg]} {
            set temp [split $arg ":"]
            set [lindex $temp 0] "[lindex $temp 1]"
        }
    }
}
```

**Project Creation:**
```tcl
new_project \
    -location $project_dir \
    -name $project_name \
    -hdl {VERILOG} \
    -family {PolarFireSoC} \
    -die $die \              # Default: MPFS025T
    -package $package \      # Default: FCVG484
    -speed $speed \          # Default: STD
    -die_voltage $die_voltage \  # Default: 1.0
    -part_range $part_range \    # Default: EXT
    -adv_options {IO_DEFT_STD:LVCMOS 1.8V}
```

**Constraint Import (Modular):**
```tcl
import_files \
    -io_pdc "${constraint_path}/$board/base_design.pdc" \
    -fp_pdc "${constraint_path}/$board/NW_PLL.pdc" \
    -sdc "${constraint_path}/$board/fic_clocks.sdc" \
    -io_pdc "./script_support/components/CAPE/$cape_option/constraints/$board/cape.pdc" \
    -io_pdc "./script_support/components/M2/$m2_option/constraints/$board/M2.pdc" \
    -io_pdc "./script_support/components/SYZYGY/$syzygy_option/constraints/$board/SYZYGY.pdc" \
    -io_pdc "./script_support/components/MIPI_CSI/$mipi_csi_option/constraints/$board/MIPI_CSI_INTERFACE.pdc"
```

**MSS Import:**
```tcl
# Sources MSS configuration recursively from MSS/ directory
safe_source [file join $INITIAL_DIRECTORY "sources" "MSS" "scripts" "B_V_F_recursive.tcl"]
```

**Build Flow Execution:**
```tcl
if !{[info exists ONLY_CREATE_DESIGN]} {
    run_tool -name {SYNTHESIZE}
    run_tool -name {PLACEROUTE}
    run_tool -name {VERIFYTIMING}

    if {[info exists HSS_IMAGE_PATH]} {
        # Configure eNVM with HSS bootloader
        create_eNVM_config "$envm_config_name" "$HSS_IMAGE_PATH"
        configure_envm -cfg_file $envm_config_name

        # Configure SPI flash
        configure_spiflash -cfg_file {./script_support/spiflash.cfg}
        run_tool -name {GENERATEPROGRAMMINGFILE}

        # Export programming files
        safe_source ./script_support/export_fns/export_flashproexpress.tcl
        safe_source ./script_support/export_fns/export_directc.tcl
    }
}
```

**Key Insight:** The BUILD_BVF_GATEWARE.tcl script is a complete, self-contained build automation that can be adapted for tcl_monster by:
1. Extracting the modular component import logic
2. Reusing the constraint organization pattern
3. Adopting the parameter-driven configuration approach

---

### generate-project.tcl / import-clients.tcl / run-flow.tcl

**Purpose:** Three-stage build flow for recipes/ directory.

**Stage 1: generate-project.tcl (69 lines)**
- Sources configure.tcl for parameters
- Creates new Libero project
- Imports MSS component from `.cxz` file: `import_mss_component -file "./output/MSS/test_mss.cxz"`
- Sources HDL recursively: `source ./sources/HDL/base/base_recursive.tcl`
- Imports constraints

**Stage 2: import-clients.tcl (37 lines)**
- Opens existing project
- Configures eNVM with HSS bootloader: `create_eNVM_config ... configure_envm`
- Configures SPI flash with bare metal image: `create_spi_config ... configure_spiflash`
- Generates design initialization data

**Stage 3: run-flow.tcl (146 lines)**
- Opens existing project
- **Configures Synplify Pro synthesis options** (detailed parameters for CDC, clock gating, retiming, ROM optimization)
- Runs synthesis: `run_tool -name {SYNTHESIZE}`
- **Configures Place & Route with multi-pass timing closure strategy:**
  - Pass 1: MAX delay analysis, standard effort
  - Pass 2: Incremental P&R with MIN delay repair, 25 multi-passes
- Verifies timing: `run_tool -name {VERIFYTIMING}`
- Verifies power: `run_tool -name {VERIFYPOWER}`
- Generates programming data: `run_tool -name {GENERATEPROGRAMMINGDATA}`

**Key Insight:** This three-stage approach separates concerns:
- Project creation (generate-project.tcl)
- Client data configuration (import-clients.tcl)
- Build execution with optimization (run-flow.tcl)

This is ideal for tcl_monster integration - create separate scripts for each stage.

---

## Python Builder Workflow (beaglev-fire-gateware)

### build-bitstream.py Overview

**Purpose:** High-level orchestration script that builds HSS bootloader + FPGA gateware + combines into single bitstream.

**Requirements:**
- **Python Libraries:** GitPython, PyYAML
  ```bash
  pip3 install gitpython pyyaml
  ```
- **Environment Variables:**
  - `LIBERO_INSTALL_DIR` - Path to Libero installation
  - `SC_INSTALL_DIR` - Path to SoftConsole (for HSS compilation)
  - `FPGENPROG` - Path to programming tools
  - `LM_LICENSE_FILE` - Microchip license file

**Usage:**
```bash
cd beaglev-fire-gateware
python3 build-bitstream.py ./build-options/default.yaml
```

**YAML Configuration Structure:**
```yaml
HSS:
    type: git
    link: https://github.com/polarfire-soc/hart-software-services.git
    branch: next
    commit: af4f81a657c92601b0de2f52b89a3f97bbf4a2b3
    depth: 1
    patches:
        - 0001-Disable-annoying-debug-message.patch
    make_clean: 0

MSS:
    type: git
    local: sources/FPGA-design/mss.bundle
    branch: default

gateware:
    type: sources
    # Points to sources/FPGA-design/ with BUILD_BVF_GATEWARE.tcl
```

**Build Workflow:**
1. **Parse YAML configuration** - Read build-options/*.yaml
2. **Clone/checkout repositories:**
   - HSS (Hart Software Services bootloader)
   - MSS (Microprocessor Subsystem configuration)
   - Gateware sources (FPGA design)
3. **Apply patches** (if specified in YAML)
4. **Build HSS bootloader:**
   - Uses SoftConsole (Eclipse + GCC for RISC-V)
   - Compiles bootloader to `.hex` file
5. **Build FPGA design:**
   - Invokes Libero with BUILD_BVF_GATEWARE.tcl
   - Passes component options (CAPE, M2, APU, etc.) as TCL variables
   - Runs synthesis, P&R, timing verification
6. **Combine HSS + bitstream:**
   - Programs eNVM with HSS bootloader
   - Creates FlashProExpress programming file
   - Creates DirectC programming file (for Linux programming)
   - Exports SPI flash image

**Output:**
```
bitstream/
├── FlashProExpress/        # For FlashPro programmer
├── DirectC/                # For Linux-based programming
├── LinuxProgramming/       # Linux programming scripts
└── SmartHLS_Executables/   # If SmartHLS accelerators included
```

**Key Insight:** The Python builder is comprehensive but heavyweight. For tcl_monster integration:
- **Don't need:** HSS cloning/compilation (use pre-built HSS images)
- **Do need:** Gateware build workflow (adapt BUILD_BVF_GATEWARE.tcl)
- **Opportunity:** Create lightweight TCL-only build flow without Python dependencies

---

## Phase 1 Completion Summary

### Accomplished (This Session)

✅ **Explored BeagleV-Fire resources:**
- beaglev-fire-gateware/ - Complete reference design (8 configurations)
- beaglev_fire_demo/ - Empty Libero project skeleton
- tcl_scripts/beaglev_fire/ - Minimal automation scripts

✅ **Analyzed reference design TCL scripts:**
- BUILD_BVF_GATEWARE.tcl - Parameterized project creation + build flow
- generate-project.tcl / import-clients.tcl / run-flow.tcl - Three-stage approach
- Understood modular component architecture (CAPE, M2, APU, SYZYGY, MIPI_CSI)
- Identified constraint organization patterns

✅ **Analyzed Python builder workflow:**
- Understood HSS bootloader + gateware integration
- Identified environment requirements (LIBERO_INSTALL_DIR, SC_INSTALL_DIR, etc.)
- Recognized opportunity for lightweight TCL-only build flow

✅ **Created tcl_monster integration structure:**
- `libero_projects/beaglev_fire/` - Working project directory
- `hdl/beaglev_fire/` - Custom HDL sources
- `config/beaglev_fire_variants.json` - 8 design configuration variants
- README files documenting purposes and organization

✅ **Documentation created to save tokens:**
- `docs/beaglev_fire_guide.md` - Comprehensive 700+ line reference guide
- PROJECT_STATE.json updated with current phase and findings
- No need to re-explore in future sessions!

### Token Usage Optimization

**This session:** ~70k tokens used (exploring + documentation)
**Future sessions:** Read `docs/beaglev_fire_guide.md` (~10k tokens) instead of re-exploring
**Savings:** ~60k tokens per session (6x reduction)

---

## Phase 2 Planning: tcl_monster Integration

### Goals
- Adapt reference TCL scripts for tcl_monster framework
- Create parameterized project creation scripts
- Implement variant selection from config/beaglev_fire_variants.json
- Build automation with Build Doctor integration

### Immediate Next Steps (Phase 2 Session)

**1. Extract Reference Components (~30 min)**
- Copy modular component TCL files to tcl_scripts/beaglev_fire/components/
- CAPE variants (DEFAULT, GPIOS, ROBOTICS, 4_UARTS, etc.)
- M2 variants (DEFAULT, PCIE_ONLY, NONE)
- APU variants (NONE, PICO_RV, SMARTHLS)
- Constraint files for each variant

**2. Create Project Creation Script (~20 min)**
- `tcl_scripts/beaglev_fire/create_bvf_project.tcl`
- Read variant from config/beaglev_fire_variants.json
- Call new_project with device config
- Import MSS configuration (extract from mss.bundle)
- Import modular components based on variant
- Import constraints

**3. Create Build Flow Script (~15 min)**
- `tcl_scripts/beaglev_fire/build_bvf_project.tcl`
- Configure synthesis options
- Run synthesis, P&R, timing verification
- Generate programming files
- Export reports for Build Doctor

**4. Test with Minimal Variant (~20 min)**
- Create project with "minimal" variant (no FPGA fabric)
- Verify project creation succeeds
- Attempt build (may require HSS image)

**5. Document and Plan Phase 3 (~10 min)**
- Update beaglev_fire_guide.md with Phase 2 results
- Identify blockers (HSS images, environment variables)
- Plan Phase 3 custom modifications

### Estimated Time: Phase 2 = ~1.5-2 hours

---

**Document Version:** 1.1
**Created:** 2025-11-12
**Last Updated:** 2025-11-12 (Phase 1 Complete)
