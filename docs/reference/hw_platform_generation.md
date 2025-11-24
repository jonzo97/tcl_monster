# Automatic hw_platform.h Generation

**Problem:** Manually creating `hw_platform.h` for every MI-V project is tedious and error-prone.

**Solution:** Automated extraction from Libero memory map → C header file.

---

## Quick Start

**One-command workflow:**
```bash
cd /path/to/tcl_monster
./scripts/generate_hw_platform.sh \
    ./projects/my_project/my_project.prjx \
    MIV_RV32 \
    ./output
```

**Result:** `output/hw_platform.h` ready for firmware!

---

## What Gets Generated

Example output:
```c
#ifndef HW_PLATFORM_H_
#define HW_PLATFORM_H_

/*** Peripheral Base Addresses ***/
#define MIV_ESS_PLIC_BASE_ADDR                  (0x70000000UL)
#define COREUARTAPB0_BASE_ADDR                  (0x71000000UL)
#define MIV_MTIMER_BASE_ADDR                    (0x72000000UL)
#define COREGPIO_OUT_BASE_ADDR                  (0x75000000UL)
#define CORESPI_BASE_ADDR                       (0x76000000UL)

/*** System Clock ***/
#define SYS_CLK_FREQ                            50000000UL

#endif /* HW_PLATFORM_H_ */
```

---

## Manual Step-by-Step

If the all-in-one script doesn't work, run steps individually:

### Step 1: Export Memory Map from Libero

**GUI Method:**
1. Open your Libero project
2. File → Export → Memory Map Report
3. Save as `memory_map.json`

**CLI Method:**
```bash
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe \
    SCRIPT:scripts/export_memory_map.tcl \
    SCRIPT_ARGS:MIV_RV32 memory_map.json
```

### Step 2: Generate Header

```bash
python3 scripts/generate_hw_platform.py memory_map.json hw_platform.h
```

### Step 3: Integrate into Firmware

```bash
cp hw_platform.h <your-firmware-project>/boards/<board-name>/
```

---

## Requirements

### Software
- **Python 3.6+** (uses standard library only - **NO pip install needed!**)
- **Bash shell** (Git Bash on Windows, native on Linux/WSL/macOS)
- **Libero SoC v2024.x** (or compatible version)

### For MI-V Soft Processors:
- SmartDesign must have bus fabric (AXI/AHB/APB) with initiator/target connections
- Memory map export will fail if no bus connections exist

### For PolarFire SoC:
- Not needed! MSS Configurator auto-generates `fpga_design_config.h`

### Installation Check:
```bash
python3 --version  # Should show 3.6 or later
bash --version     # Any recent version
ls /mnt/c/Microchip/Libero_SoC_v*/Designer/bin/libero.exe  # Should find Libero
```

**See `scripts/REQUIREMENTS.txt` for detailed setup instructions.**

---

## What to Check After Generation

1. **System Clock Frequency**
   - Default: 50 MHz
   - Update `SYS_CLK_FREQ` based on your design

2. **Peripheral Names**
   - Verify component names match your SmartDesign
   - Names are auto-converted: `CoreUART-0` → `COREUART_0_BASE_ADDR`

3. **Address Ranges**
   - Ensure addresses match SmartDesign memory map view

4. **IRQ Mappings** (TODO)
   - Currently not extracted
   - Use `File → Export → Interrupt Map Report` for IRQs
   - Manual transcription still needed for IRQ definitions

---

## Troubleshooting

### "Could not open SmartDesign"
- **Cause:** SmartDesign name doesn't exist
- **Fix:** Check exact name in Libero Design Hierarchy

### "Failed to export memory map"
- **Cause:** No bus fabric connections in design
- **Fix:** Memory map export requires initiator/target BIF connections

### "No peripherals found in memory map"
- **Cause:** JSON export succeeded but has no connected nodes
- **Fix:** Verify bus fabric in SmartDesign has address assignments

### Python script fails
- **Cause:** Invalid JSON format or missing keys
- **Fix:** Check JSON structure matches expected format

---

## Sharing with Colleagues

Send these files from `tcl_monster/scripts/`:
1. `export_memory_map.tcl`
2. `generate_hw_platform.py`
3. `generate_hw_platform.sh` (optional, for convenience)
4. This documentation

**Usage for colleague:**
```bash
# Clone or copy scripts
git clone <tcl_monster_repo>
cd tcl_monster

# Run on their project
./scripts/generate_hw_platform.sh \
    /path/to/their/project.prjx \
    THEIR_SMARTDESIGN_NAME
```

---

## Future Enhancements

- [ ] Extract IRQ mappings from Interrupt Map Report
- [ ] Support for multiple initiators
- [ ] Validation against sample_fpga_design_config.h template
- [ ] Integration with SoftConsole project setup
- [ ] Clock frequency extraction from design
- [ ] TCL-only version (no Python dependency)

---

## Related Documentation

- [Libero Memory Map Feature](../docs/libero_memory_map.md)
- [MI-V Platform HAL](../hdl/miv_platform/miv_rv32_hal/sample_fpga_design_config.h)
- [TCL Monster Workflow](../README.md)

---

**Last Updated:** 2025-11-19
**Author:** TCL Monster toolkit
**Status:** Working prototype - tested with MI-V RV32 designs
