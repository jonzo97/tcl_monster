# Application Note Automation Strategy

**Purpose:** Parse and recreate Microchip application notes for automated deployment on any board

**Last Updated:** 2025-10-22

---

## Overview

Microchip publishes hundreds of application notes with reference designs. Goals:
- **Catalog** available application notes and their target devices/boards
- **Parse** existing Libero projects to extract HDL, constraints, and IP configurations
- **Recreate** designs automatically for different target boards
- **Deploy** with one command to any supported device/board combination

---

## Application Note Categories

### Communication Interfaces
- UART designs (RS-232, RS-485)
- SPI flash programming
- I2C sensor interfaces
- CAN bus controllers
- Ethernet (RGMII, SGMII)

### Memory Interfaces
- DDR3/DDR4 memory controllers
- External SRAM interfaces
- Flash memory controllers

### Motor Control
- BLDC motor control
- Stepper motor drivers
- FOC (Field-Oriented Control)
- Encoder interfaces

### High-Speed I/O
- PCIe endpoints and root complexes
- SerDes examples (JESD204B, Aurora)
- Video interfaces (HDMI, DisplayPort)

### Embedded Systems
- RISC-V SoC designs
- MicroBlaze/ARM integration
- Real-time control systems

---

## Phase 1: Application Note Discovery

**Goal:** Build searchable catalog of Microchip application notes

**Time Estimate:** 1 hour

### Data Sources:

#### 1. Microchip Website
**URL:** https://www.microchip.com/en-us/search?searchQuery=PolarFire&category=Application+Notes

**Metadata to Extract:**
- Application note number (e.g., AC469)
- Title and description
- Target device family (PolarFire, PolarFire SoC, Igloo2, etc.)
- Target board (if specified)
- HDL language (Verilog, VHDL, mixed)
- Features implemented
- Download links (PDF, design files)

#### 2. Local Libero Installation
Check for bundled reference designs:
```bash
find /mnt/c/Microchip -name "*reference*" -o -name "*demo*" | grep -i polarfire
```

#### 3. GitHub and Community
- Microchip GitHub repositories
- Community-contributed designs

### Catalog Structure

```json
{
  "app_notes": [
    {
      "id": "AC469",
      "title": "PolarFire FPGA DDR4 Memory Controller",
      "description": "Demonstrates DDR4 interface using IP core",
      "devices": ["MPF300TS", "MPF500TS"],
      "boards": ["MPF300 Eval Kit", "Splash Kit"],
      "hdl": "Verilog",
      "features": ["DDR4", "AXI4", "Memory test patterns"],
      "downloads": {
        "pdf": "https://...",
        "design_files": "https://..."
      },
      "local_cache": "./examples/app_notes/AC469/"
    }
  ]
}
```

### Planned Files:
- `tools/utilities/scrape_app_notes.py` - Web scraper for Microchip site
- `examples/app_notes/catalog.json` - Application note database
- `tools/utilities/catalog_manager.py` - Search and filter catalog

---

## Phase 2: Project Parser

**Goal:** Parse existing Libero projects to extract all components

**Time Estimate:** 2 hours

### Libero Project Structure

Libero `.prjx` files are XML-based. Key sections to parse:

#### 1. Design Files
- HDL sources (Verilog, VHDL)
- Testbenches
- Include files

#### 2. Constraint Files
- PDC (pin constraints)
- SDC (timing constraints)
- FDC (floorplan constraints)

#### 3. IP Core Configurations
- IP catalog cores used
- Configuration parameters
- TCL scripts for IP generation

#### 4. Device Configuration
- Device family, die, package, speed grade
- I/O standards and voltage settings

#### 5. Build Settings
- Synthesis options
- Place & route strategies
- Timing goals

### Project Parser Utility

```python
# tools/utilities/parse_libero_project.py

import xml.etree.ElementTree as ET
import json

class LiberoProjectParser:
    def __init__(self, prjx_file):
        self.tree = ET.parse(prjx_file)
        self.root = self.tree.getroot()

    def get_design_files(self):
        """Extract all HDL source files"""
        files = []
        for file in self.root.findall(".//File[@type='HDL']"):
            files.append({
                'path': file.get('path'),
                'language': file.get('language'),
                'library': file.get('library')
            })
        return files

    def get_constraint_files(self):
        """Extract constraint files"""
        constraints = {
            'pdc': [],
            'sdc': [],
            'fdc': []
        }
        for file in self.root.findall(".//File[@type='PDC']"):
            constraints['pdc'].append(file.get('path'))
        # Similar for SDC, FDC
        return constraints

    def get_device_config(self):
        """Extract device configuration"""
        device = self.root.find(".//Device")
        return {
            'family': device.get('family'),
            'die': device.get('die'),
            'package': device.get('package'),
            'speed': device.get('speed'),
            'voltage': device.get('voltage')
        }

    def get_ip_cores(self):
        """Extract IP core configurations"""
        cores = []
        for ip in self.root.findall(".//IPCore"):
            cores.append({
                'name': ip.get('name'),
                'type': ip.get('type'),
                'config': ip.find('Configuration').text
            })
        return cores

    def export_template(self, output_file):
        """Export project as template JSON"""
        template = {
            'design_files': self.get_design_files(),
            'constraints': self.get_constraint_files(),
            'device': self.get_device_config(),
            'ip_cores': self.get_ip_cores()
        }

        with open(output_file, 'w') as f:
            json.dump(template, f, indent=2)

        print(f"Exported template to {output_file}")
```

**Usage:**
```bash
python tools/utilities/parse_libero_project.py \
    --input examples/app_notes/AC469/design.prjx \
    --output examples/app_notes/AC469/template.json
```

---

## Phase 3: Board Adaptation Engine

**Goal:** Automatically adapt designs to different target boards

**Time Estimate:** 2 hours

### Pin Mapping Strategy

#### 1. Board Templates
Create JSON templates for each supported board with pin mappings:

```json
{
  "board": "MPF300 Eval Kit",
  "device": "MPF300TS-FCG1152",
  "pins": {
    "clock_50mhz": "E25",
    "reset_n": "B27",
    "led": ["D25", "C26", "B26", "F22", "H21", "H22", "F23", "C27"],
    "uart": {
      "tx": "A10",
      "rx": "B10"
    },
    "ddr4": {
      "ck_p": "F12",
      "ck_n": "G12",
      "dq": ["A1", "B1", "C1", "..."]
    }
  },
  "io_standards": {
    "default": "LVCMOS18",
    "ddr4": "SSTL12_DCI"
  }
}
```

#### 2. Pin Mapper Utility

```python
# tools/utilities/pin_mapper.py

class PinMapper:
    def __init__(self, source_board, target_board):
        self.source = load_board_template(source_board)
        self.target = load_board_template(target_board)

    def map_constraints(self, source_pdc):
        """
        Remap pin constraints from source board to target board
        """
        mapped_pdc = []

        for constraint in parse_pdc(source_pdc):
            signal = constraint['signal']
            source_pin = constraint['pin']

            # Find logical function of source pin
            function = self.source.get_function(source_pin)

            # Map to target board pin for same function
            target_pin = self.target.get_pin(function)

            mapped_pdc.append({
                'signal': signal,
                'pin': target_pin,
                'io_std': self.target.io_standards.get(function, 'LVCMOS18')
            })

        return mapped_pdc
```

**Usage:**
```bash
python tools/utilities/pin_mapper.py \
    --source "MPF300 Eval Kit" \
    --target "Icicle Kit" \
    --input design.pdc \
    --output design_icicle.pdc
```

---

## Phase 4: Design Recreation Automation

**Goal:** One-command recreation of application notes for any board

**Time Estimate:** 1 hour

### Recreation Script

```tcl
# tcl_scripts/recreate_app_note.tcl

proc recreate_app_note {app_note_id target_board project_name} {
    # Load application note template
    set template [load_json "examples/app_notes/$app_note_id/template.json"]

    # Load target board configuration
    set board_config [load_json "templates/boards/$target_board.json"]

    # Create new project
    new_project \
        -name $project_name \
        -location "./libero_projects/$project_name" \
        -family [dict get $board_config device family] \
        -die [dict get $board_config device die] \
        -package [dict get $board_config device package]

    # Import HDL sources
    foreach file [dict get $template design_files] {
        import_files -hdl_source "examples/app_notes/$app_note_id/[dict get $file path]"
    }

    # Adapt and import constraints
    set adapted_pdc [adapt_constraints \
        $template \
        $board_config \
        "examples/app_notes/$app_note_id/constraints.pdc"]

    import_files -io_pdc $adapted_pdc

    # Configure IP cores (if any)
    foreach ip [dict get $template ip_cores] {
        configure_ip_core [dict get $ip name] [dict get $ip config]
    }

    # Build design hierarchy
    build_design_hierarchy
    set_root -module [dict get $template top_module]

    # Save project
    save_project

    puts "Successfully recreated $app_note_id for $target_board"
}
```

**Usage:**
```bash
./run_libero.sh tcl_scripts/recreate_app_note.tcl SCRIPT_ARGS \
    --app_note AC469 \
    --board "Icicle Kit" \
    --project ddr4_icicle
```

---

## Phase 5: Validation and Testing

**Goal:** Ensure recreated designs function correctly

**Time Estimate:** 1 hour (per application note)

### Validation Checklist:
- [ ] Design synthesizes without errors
- [ ] Timing constraints met
- [ ] All pins mapped correctly
- [ ] IP cores configured properly
- [ ] Testbenches pass (if available)
- [ ] (Optional) Hardware validation

### Automated Validation Script

```bash
# tools/utilities/validate_app_note.sh

#!/bin/bash

APP_NOTE=$1
BOARD=$2

echo "Validating $APP_NOTE on $BOARD..."

# Recreate design
./run_libero.sh tcl_scripts/recreate_app_note.tcl SCRIPT_ARGS \
    --app_note $APP_NOTE \
    --board $BOARD \
    --project ${APP_NOTE}_${BOARD}

# Build design
./run_libero.sh tcl_scripts/build_design.tcl SCRIPT

# Check for errors
if grep -q "ERROR" libero_projects/${APP_NOTE}_${BOARD}/synthesis/synlog.log; then
    echo "VALIDATION FAILED: Synthesis errors"
    exit 1
fi

# Check timing
if ! grep -q "Timing constraints met" libero_projects/${APP_NOTE}_${BOARD}/designer/*/timing.rpt; then
    echo "VALIDATION WARNING: Timing violations"
fi

echo "VALIDATION PASSED"
```

---

## Reference Design Library

### Target Application Notes (Priority List):

| ID | Title | Priority | Complexity | HW Test |
|----|-------|----------|------------|---------|
| AC469 | DDR4 Memory Controller | High | ★★★★☆ | Required |
| AC??? | UART Example | High | ★★☆☆☆ | Recommended |
| AC??? | SPI Flash Programming | Medium | ★★☆☆☆ | Recommended |
| AC??? | PCIe Endpoint | Medium | ★★★★★ | Required |
| AC??? | BLDC Motor Control | Low | ★★★★☆ | Required |

*Note: Actual AC numbers to be determined during catalog phase*

---

## Integration with TCL Monster

### Workflow:
1. User selects application note from catalog
2. User specifies target board
3. Automation recreates design with adapted constraints
4. User runs build and validates
5. (Optional) User programs hardware and tests

### Command-Line Interface:
```bash
# List available application notes
./tcl_monster app-notes list

# Search application notes
./tcl_monster app-notes search "DDR4"

# Recreate application note
./tcl_monster app-notes create \
    --id AC469 \
    --board "Icicle Kit" \
    --project my_ddr4_design

# Build and validate
./tcl_monster build my_ddr4_design
```

---

## Success Metrics

- **Catalog Size:** 10+ application notes cataloged
- **Recreation Success Rate:** >80% synthesize without errors
- **Pin Mapping Accuracy:** 100% (verified against board docs)
- **Time Savings:** <10 minutes to recreate vs. hours of manual work

---

## Challenges and Mitigations

### Challenge 1: IP Core Licensing
**Issue:** Some IP cores require licenses
**Mitigation:** Document license requirements in catalog, skip cores that aren't available

### Challenge 2: Complex Pin Mapping
**Issue:** DDR, PCIe require precise pin groups
**Mitigation:** Board templates include pre-validated pin groups

### Challenge 3: Device Compatibility
**Issue:** Not all designs port to all devices
**Mitigation:** Catalog specifies compatible device families

---

## Recommended Next Steps

1. **Build catalog** of 3-5 simple application notes
2. **Implement parser** for Libero project files
3. **Create board templates** for MPF300 Eval Kit and Icicle Kit
4. **Test recreation** of simplest application note (e.g., UART)
5. **Iterate** on more complex designs

---

**Maintained by:** TCL Monster Project | **Last Updated:** 2025-10-22
