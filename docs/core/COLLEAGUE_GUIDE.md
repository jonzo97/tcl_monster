# TCL Monster - Getting Started Guide for FAEs

**Quick Start:** Get your first FPGA design built in under 15 minutes!

**Last Updated:** 2025-10-22

---

## What is TCL Monster?

TCL Monster is a command-line automation toolkit for Microchip Libero FPGA projects. It enables:
- **Rapid project creation** - One command to set up full project
- **Automated builds** - Synthesis → place & route → bitstream without GUI
- **Design templates** - Pre-validated designs for common tasks
- **Cross-board deployment** - Adapt designs to different eval kits
- **Reproducible workflows** - Share projects with colleagues easily

**Who is this for?**
- FAEs who want to move faster than GUI workflows allow
- Engineers comfortable with command-line tools
- Teams who need reproducible, scriptable FPGA flows

---

## Prerequisites

### Required Software

1. **Microchip Libero SoC v2024.2**
   - Installation: `C:\Microchip\Libero_SoC_v2024.2\`
   - License: Ensure valid Libero license

2. **WSL2 (Windows Subsystem for Linux)**
   - Recommended distribution: Ubuntu 22.04
   - Git installed in WSL

3. **Optional: Claude Code**
   - For interactive assistance and customization
   - https://claude.com/code

### Supported Hardware

Current targets (more coming soon):
- ✅ **PolarFire MPF300 Eval Kit** (MPF300TS-FCG1152)
- 🚧 PolarFire SoC Icicle Kit (planned)
- 🚧 Igloo2 Eval Kit (planned)

---

## Installation

### Step 1: Clone Repository

```bash
cd /mnt/c  # Or your preferred location
git clone https://github.com/your-org/tcl_monster.git
cd tcl_monster
```

### Step 2: Verify Libero Path

Check that Libero is installed:
```bash
ls /mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe
```

If path is different, edit `run_libero.sh` and update `LIBERO_EXE` variable.

### Step 3: Make Scripts Executable

```bash
chmod +x run_libero.sh
```

### Step 4: Test Installation

```bash
./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
```

**Expected output:**
```
Creating Libero Project: counter_demo
Target Device: MPF300TSFCG1152
...
Project creation complete!
The Execute Script command succeeded.
```

**Success!** Project created at `libero_projects/counter_demo/`

---

## Quick Start: Build Your First Design

### Example: Counter with Rotating LEDs

**What it does:** 8 LEDs rotate in a pattern, demonstrating basic FPGA functionality

**Time:** ~5 minutes

#### 1. Create Project
```bash
./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
```

#### 2. Build Design (Synthesis + Place & Route + Bitstream)
```bash
./run_libero.sh tcl_scripts/build_design.tcl SCRIPT
```

**Build time:** ~2 minutes on typical workstation

#### 3. Find Programming File
```bash
ls libero_projects/counter_demo/designer/counter/counter.ppd
```

#### 4. Program FPGA
- Connect MPF300 Eval Kit via USB
- Use FlashPro or SmartDebug GUI to program `counter.ppd`
- *(Future: command-line programming via SmartDebug TCL)*

**Result:** LEDs should rotate in a pattern!

---

## Understanding the Project Structure

```
tcl_monster/
├── tcl_scripts/              # Automation TCL scripts
│   ├── create_project.tcl    # Project creation
│   └── build_design.tcl      # Build flow (synthesis → bitstream)
│
├── hdl/                      # HDL source files
│   └── counter.v             # Counter design example
│
├── constraint/               # Constraint files
│   └── io_constraints.pdc    # Pin mappings for MPF300 Eval Kit
│
├── docs/                     # Documentation
│   ├── ROADMAP.md            # Long-term development plan
│   ├── DESIGN_LIBRARY.md     # Catalog of available designs
│   └── ...                   # More specialized docs
│
├── examples/                 # Design examples (coming soon)
│   ├── basic/
│   ├── communication/        # UART, SPI, I2C
│   ├── advanced/             # DDR, PCIe, RISC-V
│   └── app_notes/            # Recreated Microchip app notes
│
├── templates/                # Device and board templates
│   ├── devices/              # Device-specific configs
│   └── boards/               # Board-specific pin mappings
│
├── libero_projects/          # Generated Libero projects (gitignored)
│   └── counter_demo/
│
└── run_libero.sh             # Helper script to run TCL from WSL
```

---

## Common Workflows

### Workflow 1: Create and Build a Design

```bash
# Create project
./run_libero.sh tcl_scripts/create_project.tcl SCRIPT

# Build design
./run_libero.sh tcl_scripts/build_design.tcl SCRIPT

# Check for errors
grep -i error libero_projects/counter_demo/synthesis/synlog.log
```

### Workflow 2: Modify Design and Rebuild

1. Edit HDL: `hdl/counter.v`
2. Rebuild:
   ```bash
   ./run_libero.sh tcl_scripts/build_design.tcl SCRIPT
   ```
3. Check results:
   ```bash
   ls libero_projects/counter_demo/designer/counter/*.ppd
   ```

### Workflow 3: Adapt Design to Different Board

*(Coming soon - Phase 5 of roadmap)*

```bash
./tcl_monster app-notes create \
    --id AC469 \
    --board "Icicle Kit" \
    --project ddr4_icicle
```

---

## Customizing for Your Needs

### Add Your Own Design

1. **Create HDL file:**
   ```bash
   cp hdl/counter.v hdl/my_design.v
   # Edit my_design.v
   ```

2. **Create constraints:**
   ```bash
   cp constraint/io_constraints.pdc constraint/my_design.pdc
   # Edit pin mappings for your design
   ```

3. **Update project creation script:**
   Edit `tcl_scripts/create_project.tcl`:
   ```tcl
   # Change project name
   set project_name "my_design"

   # Update HDL source
   import_files -hdl_source "$hdl_dir/my_design.v"

   # Update top module
   set_root -module {my_design::work}
   ```

4. **Build:**
   ```bash
   ./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
   ./run_libero.sh tcl_scripts/build_design.tcl SCRIPT
   ```

### Target Different Device

Edit `tcl_scripts/create_project.tcl`:
```tcl
# Change device
set device_die "MPF500TS"      # Instead of MPF300TS
set device_package "FCG1152"   # Or different package
```

---

## Troubleshooting

### Problem: "libero.exe not found"

**Solution:** Update path in `run_libero.sh`:
```bash
LIBERO_EXE="/mnt/c/YOUR/PATH/TO/libero.exe"
```

### Problem: "Project creation failed"

**Possible causes:**
1. Invalid Libero license
2. Incorrect device/package combination
3. File permissions issue

**Debug:**
```bash
# Check Libero logs
cat libero_projects/counter_demo/*.log
```

### Problem: "Synthesis errors"

**Solution:**
```bash
# Check synthesis log
cat libero_projects/counter_demo/synthesis/synlog.log | grep -i error

# Common issues:
# - HDL syntax errors
# - Missing files
# - Undefined signals
```

### Problem: "Timing violations"

**Solution:** *(Phase 1 - coming soon)*
- Add timing constraints (SDC file)
- Check critical path in timing reports
- Adjust design or relax constraints

### Problem: "I/O not placed"

**Solution:**
- Check PDC file syntax
- Verify pin names match device package
- Ensure pins are available (not dedicated)

---

## Getting Help

### Documentation
- **Quick Start:** `docs/QUICKSTART.md`
- **Full Roadmap:** `docs/ROADMAP.md`
- **Design Library:** `docs/DESIGN_LIBRARY.md`
- **Project Context:** `.claude/CLAUDE.md`

### Community (Coming Soon)
- Internal wiki: *[to be set up]*
- Slack channel: *[to be set up]*
- Email list: *[to be set up]*

### Advanced Help
- Open issue on internal Git repo
- Contact project maintainer: [your email]
- Schedule pairing session for customization

---

## Tips for Success

### 1. Start Simple
- Begin with counter example
- Validate board connectivity
- Then move to your actual design

### 2. Use Version Control
- Commit working designs
- Tag successful builds
- Branch for experiments

### 3. Document Your Patterns
- If you create a useful design, add to `examples/`
- Document pin mappings in `templates/boards/`
- Share with team!

### 4. Iterate Quickly
- Command-line workflow enables rapid iteration
- Script repetitive tasks
- Automate your specific needs

### 5. Test on Hardware Early
- Don't wait for "perfect" design
- Program hardware frequently
- Validate assumptions with real hardware

---

## What's Next?

### Current Features (Phase 0)
- ✅ Project creation
- ✅ HDL and constraint import
- ✅ Synthesis and place & route
- ✅ Bitstream generation

### Coming Soon (Phase 1)
- ⏳ Timing constraints (SDC)
- ⏳ Automated reporting
- ⏳ Multi-device templates

### Future Enhancements
- 🚀 Simulation framework (Phase 3)
- 🚀 Debugging automation (Phase 4)
- 🚀 Application note recreation (Phase 5)
- 🚀 Intelligent build agents (Phase 6)

**See `docs/ROADMAP.md` for full development plan.**

---

## Success Stories

*This section will be populated as colleagues adopt TCL Monster*

**Example:** "Reduced project setup time from 1 hour to 5 minutes!" - FAE Name

---

## Contributing

### Want to Help?
- Add your designs to `examples/`
- Create board templates for your eval kits
- Document discovered Libero tricks
- Report bugs or feature requests

### Contribution Guidelines
- Test your changes before committing
- Document new features
- Update DESIGN_LIBRARY.md for new designs
- Follow existing code style

---

## FAQ

**Q: Do I need Claude Code to use this?**
A: No! TCL Monster works standalone. Claude Code helps with customization and troubleshooting.

**Q: Does this replace Libero GUI?**
A: No, it complements it. GUI is still useful for complex IP configuration and debugging. TCL Monster excels at automation and repeatability.

**Q: Can I use this in production?**
A: Yes! Scripts generate identical results to GUI workflows. Always validate critical designs.

**Q: How do I customize for my board?**
A: Create a board template in `templates/boards/` with your pin mappings. See existing examples.

**Q: What if I hit a Libero limitation?**
A: Document it in `docs/lessons_learned/`. We'll find workarounds or use GUI for those specific tasks.

---

## Feedback

**We want to hear from you!**
- What features would help you most?
- What's confusing or unclear?
- What designs should we add to the library?

Contact: [project maintainer email]

---

**Happy FPGA development!**

*Maintained by: [Your Name/Team] | Last Updated: 2025-10-22*
