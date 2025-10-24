# PF_DDR4 GUI Export Instructions

**Time Required:** ~15-20 minutes (one-time only!)

**Purpose:** Export PF_DDR4 component configuration to TCL for permanent automation

---

## Step-by-Step Instructions

### 1. Open Project in Libero GUI

**From WSL terminal:**
```bash
cd /mnt/c/tcl_monster
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe PROJECT:"C:\tcl_monster\libero_projects\miv_rv32_demo\miv_rv32_demo.prjx"
```

**Or from Windows:**
- Navigate to `C:\tcl_monster\libero_projects\miv_rv32_demo\`
- Double-click `miv_rv32_demo.prjx`

---

### 2. Open IP Catalog

- **Menu:** Catalog → IP Catalog
- **Or:** Click "IP Catalog" button in toolbar

---

### 3. Add PF_DDR4 Component

**Navigate to:**
```
IP Catalog
  └── Memory Controllers
      └── PF_DDR4 (or PF_DDR3 if DDR4 not available)
```

**Click:** "Configure" or double-click PF_DDR4

---

### 4. Configure DDR Controller

**Configuration Tab:**
- **Configuration Mode:** "Preset Configuration" (easiest)
- **Board Selection:** Look for "MPF300 Evaluation Kit" or "MPF300-EVAL-KIT"
  - If available, select it (auto-configures everything!)
  - If not available, use "User Configuration" (see Manual Config below)

**Memory Tab (if using preset, these should auto-fill):**
- **Memory Type:** DDR4 (or DDR3 if available)
- **Memory Size:** 2GB
- **Data Width:** 32-bit (or 16-bit if 32 unavailable)
- **Speed Grade:** DDR4-2400 (or fastest available)

**Interface Tab:**
- **Fabric Interface:** AXI4 (required for MI-V connection)
- **AXI Address Width:** 32-bit
- **AXI Data Width:** 64-bit (matches DDR burst)

**Component Name:**
- **Name:** `PF_DDR4_C0` (keep default)

---

### 5. Generate Component

- Click "Generate" button
- Wait for generation to complete (~2-3 minutes)
- **Important:** Do NOT add to SmartDesign yet (we'll do that via TCL)
- Click "OK" or "Close"

---

### 6. Export Component to TCL

**In Design Hierarchy panel (left side):**
- Expand "component" folder
- Expand "work" folder
- Find `PF_DDR4_C0` (your new component)
- **Right-click** → "Export Component Description..."

**Export Dialog:**
- **Format:** TCL Script
- **Location:** `C:\tcl_monster\tcl_scripts\miv_components\`
- **Filename:** `PF_DDR4_C0.tcl`
- Click "Save"

---

### 7. Export Pin Constraints (Optional but Recommended)

If DDR pins were auto-assigned:

**Menu:** File → Export → Export Constraints (PDC)
- **Filename:** `C:\tcl_monster\constraint\ddr4_pins.pdc`
- **Include:** I/O Constraints only
- Click "Export"

---

### 8. Close Libero GUI

**Do NOT save project changes** (we want to test full automation)
- File → Close Project
- "Save changes?" → **No**
- Close Libero

---

## Manual Configuration (if no preset available)

If "MPF300 Evaluation Kit" preset isn't available, configure manually:

**Memory Chip:** Based on eval kit (UG0747 PDF page 14):
- **DDR4:** 4x Micron MT40A256M16GE-083E (4GB total, x32 interface)
- **DDR3:** 2x Micron MT41K256M16TW-107 (2GB total, x16 interface per chip)

**Memory Parameters (DDR4 example):**
- Organization: x16
- Density: 4Gb per chip
- Banks: 4 bank groups, 4 banks per group
- Row Address: 16 bits
- Column Address: 10 bits
- CAS Latency: 16 (for DDR4-2400)

**Timing Parameters:** Use "Auto" or refer to Micron datasheet

---

## Verification

After export, verify the TCL file exists:
```bash
ls -lh /mnt/c/tcl_monster/tcl_scripts/miv_components/PF_DDR4_C0.tcl
```

You should see a file ~5-20KB in size.

---

## Next Steps

Once exported, run:
```bash
./run_libero.sh tcl_scripts/integrate_ddr.tcl SCRIPT
```

This will automatically integrate the DDR controller into the MI-V project!

---

## Troubleshooting

**"Cannot find PF_DDR4 in catalog"**
- Try PF_DDR3 instead
- Or search for "Memory Controller" or "DDR"

**"Preset configuration not available"**
- Use "User Configuration" mode
- Refer to eval kit user guide (Section 4.1) for pin mappings

**"Generate fails with errors"**
- Check Libero license status
- Verify PolarFire device family is selected in project

**"Export option grayed out"**
- Make sure component generated successfully
- Try right-clicking directly on component name in hierarchy

---

**Questions?** Ping Claude - we'll debug together!
