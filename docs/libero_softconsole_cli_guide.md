# Libero + SoftConsole Command-Line Reference

Complete guide to running Microchip Libero SoC and SoftConsole from the command line, with WSL-specific instructions.

---

## Libero SoC Command-Line Usage

### Installation Paths

**Windows Installation:**
```
C:\Microchip\Libero_SoC_v2024.2\Designer\bin\libero.exe
```

**WSL Mount Path:**
```
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe
```

**Native WSL Installation (if installed):**
```
/opt/microchip/libero/bin/libero
```

### Execution Modes

#### 1. SCRIPT Mode (Batch Execution)
Non-interactive TCL script execution. Most common for automation.

```bash
libero.exe SCRIPT:path/to/script.tcl
```

**Example:**
```bash
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe \
    SCRIPT:/mnt/c/tcl_monster/tcl_scripts/create_project.tcl
```

**Exit Codes:**
- `0` - Success
- Non-zero - Error (check log files)

#### 2. SCRIPT_ARGS Mode (With Arguments)
Pass command-line arguments to TCL script via `$argv` variable.

```bash
libero.exe SCRIPT_ARGS:script.tcl arg1 arg2 arg3
```

**TCL Script Access:**
```tcl
set project_name [lindex $argv 0]
set device_family [lindex $argv 1]
puts "Creating project: $project_name for $device_family"
```

**Example:**
```bash
libero.exe SCRIPT_ARGS:create_project.tcl counter_demo PolarFire MPF300TS
```

#### 3. SCRIPT_HELP Mode
Display help for a TCL script (if script supports it).

```bash
libero.exe SCRIPT_HELP:script.tcl
```

#### 4. Interactive Mode
Opens Libero GUI with TCL console available.

```bash
libero.exe              # GUI only
libero.exe project.prjx # Open specific project
```

### Wrapper Script Pattern

The `run_libero.sh` wrapper simplifies usage:

```bash
#!/bin/bash
# run_libero.sh - Wrapper for Libero TCL execution

LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe"
SCRIPT_PATH="$1"
MODE="${2:-SCRIPT}"  # Default to SCRIPT mode

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: Script not found: $SCRIPT_PATH"
    exit 1
fi

# Convert WSL path to Windows path if needed
WIN_SCRIPT=$(wslpath -w "$SCRIPT_PATH" 2>/dev/null || echo "$SCRIPT_PATH")

"$LIBERO_PATH" "${MODE}:${WIN_SCRIPT}"
```

**Usage:**
```bash
./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
./run_libero.sh tcl_scripts/build_design.tcl SCRIPT
```

### Output and Logging

**Log Files Location:**
```
libero_projects/<project_name>/
├── designer/<top_module>/<top_module>.log    # Place & route
├── synthesis/<top_module>.srr                 # Synthesis report
└── <project_name>.log                         # Project log
```

**Redirect Output:**
```bash
libero.exe SCRIPT:script.tcl 2>&1 | tee build.log
```

---

## SoftConsole Command-Line Usage

### Installation Paths

**Windows Installation:**
```
C:\Microchip\SoftConsole-v2022.2-RISC-V-747\
```

**WSL Mount:**
```
/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747/
```

### RISC-V GCC Toolchain

**Compiler Path:**
```bash
/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-gcc
```

**Common Tools:**
- `riscv64-unknown-elf-gcc` - C compiler
- `riscv64-unknown-elf-g++` - C++ compiler
- `riscv64-unknown-elf-as` - Assembler
- `riscv64-unknown-elf-ld` - Linker
- `riscv64-unknown-elf-objcopy` - Binary conversion
- `riscv64-unknown-elf-objdump` - Disassembly
- `riscv64-unknown-elf-gdb` - Debugger

### Building RISC-V Projects

#### Simple Compilation
```bash
RISCV_GCC="/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-gcc"

$RISCV_GCC -march=rv32imc -mabi=ilp32 \
    -O2 -g \
    -o firmware.elf \
    main.c uart.c gpio.c \
    -T linker_script.ld
```

#### Generate Binary for FPGA
```bash
riscv64-unknown-elf-objcopy -O binary firmware.elf firmware.bin
```

#### Generate Intel Hex
```bash
riscv64-unknown-elf-objcopy -O ihex firmware.elf firmware.hex
```

#### Disassemble
```bash
riscv64-unknown-elf-objdump -D firmware.elf > firmware.dis
```

### HSS (Hart Software Services) Build

For PolarFire SoC projects:

**Build HSS from source:**
```bash
cd beaglev-fire-gateware/sources/HSS
export CROSS_COMPILE=riscv64-unknown-elf-
make BOARD=mpfs-beaglev-fire
```

**Output:**
```
Default/hss.elf
Default/hss.bin
```

### SoftConsole IDE (Command-Line)

**Launch IDE:**
```bash
/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747/eclipse/softconsole.exe
```

**Headless Build (Eclipse):**
```bash
softconsole.exe -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild \
    -data /path/to/workspace \
    -import /path/to/project \
    -build all
```

---

## WSL-Specific Considerations

### Path Translation

**WSL → Windows:**
```bash
wslpath -w /mnt/c/tcl_monster/script.tcl
# Output: C:\tcl_monster\script.tcl
```

**Windows → WSL:**
```bash
wslpath -u 'C:\Microchip\Libero_SoC_v2024.2'
# Output: /mnt/c/Microchip/Libero_SoC_v2024.2
```

**In Scripts:**
```bash
if [ -n "$WSL_DISTRO_NAME" ]; then
    # Running in WSL
    SCRIPT_WIN=$(wslpath -w "$SCRIPT_PATH")
else
    # Native Linux or Windows
    SCRIPT_WIN="$SCRIPT_PATH"
fi
```

### Performance Considerations

**File System Performance:**
- **Slow:** WSL accessing Windows filesystem (`/mnt/c/`)
- **Fast:** WSL native filesystem (`~/projects/`)

**Recommendation:**
```bash
# Clone to WSL native filesystem for better performance
cd ~
git clone https://github.com/user/tcl_monster.git
cd tcl_monster

# Run Libero on Windows but keep sources in WSL
./run_libero.sh tcl_scripts/build.tcl SCRIPT
```

### Libero WSL Native Installation

**If Libero supports WSL installation:**
```bash
# Install to /opt/microchip/libero
sudo ./libero_installer.sh

# Update PATH
export PATH="/opt/microchip/libero/bin:$PATH"

# Run directly
libero SCRIPT:script.tcl
```

### Environment Variables

**Set in WSL:**
```bash
export LIBERO_HOME="/mnt/c/Microchip/Libero_SoC_v2024.2"
export SOFTCONSOLE_HOME="/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747"
export PATH="$SOFTCONSOLE_HOME/riscv-unknown-elf-gcc/bin:$PATH"
```

**Persistent (add to `~/.bashrc`):**
```bash
echo 'export LIBERO_HOME="/mnt/c/Microchip/Libero_SoC_v2024.2"' >> ~/.bashrc
echo 'export PATH="$LIBERO_HOME/Designer/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Integration Patterns

### Complete FPGA Build Flow

```bash
#!/bin/bash
# complete_build.sh - Full FPGA build automation

set -e  # Exit on error

PROJECT_NAME="my_design"
LIBERO_SCRIPT="tcl_scripts/create_project.tcl"
BUILD_SCRIPT="tcl_scripts/build_design.tcl"

echo "=== Creating Libero Project ==="
./run_libero.sh "$LIBERO_SCRIPT" SCRIPT

echo "=== Building Design ==="
./run_libero.sh "$BUILD_SCRIPT" SCRIPT

echo "=== Build Complete ==="
ls -lh "libero_projects/$PROJECT_NAME/designer/"*/*.stp
```

### FPGA + Embedded Software Flow

```bash
#!/bin/bash
# fpga_with_firmware.sh - Build FPGA design with embedded software

# 1. Build FPGA design
echo "Building FPGA fabric..."
./run_libero.sh tcl_scripts/build_miv_design.tcl SCRIPT

# 2. Compile RISC-V firmware
echo "Compiling firmware..."
cd firmware
make clean all

# 3. Generate combined programming file
echo "Creating combined bitstream..."
./create_boot_image.sh \
    ../libero_projects/miv_demo/designer/miv_top/miv_top.stp \
    firmware.bin \
    boot_image.stp

echo "Ready to program: boot_image.stp"
```

### CI/CD Integration Example

```yaml
# .github/workflows/fpga-build.yml
name: FPGA Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Libero (if available for Linux)
        run: |
          wget https://example.com/libero-installer.sh
          chmod +x libero-installer.sh
          sudo ./libero-installer.sh --silent

      - name: Build Design
        run: |
          ./run_libero.sh tcl_scripts/create_project.tcl SCRIPT
          ./run_libero.sh tcl_scripts/build_design.tcl SCRIPT

      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: bitstream
          path: libero_projects/*/designer/*/*.stp
```

---

## Troubleshooting

### Common Issues

#### Issue: "Command not found: libero.exe"
**Solution:**
```bash
# Check path
ls -la /mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe

# Update run_libero.sh with correct path
vim run_libero.sh
```

#### Issue: Script runs but produces no output
**Solution:**
```bash
# Add explicit output to TCL script
puts "[INFO] Script starting..."
puts "[INFO] Project: $project_name"
```

#### Issue: Permission denied in WSL
**Solution:**
```bash
chmod +x run_libero.sh
chmod +x /mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe
```

#### Issue: Slow build performance from WSL
**Solution:**
- Move project to native WSL filesystem (`~/projects/`)
- Or use native WSL Libero installation if available

#### Issue: Path with spaces not recognized
**Solution:**
```bash
# Quote paths
"$LIBERO_PATH" "SCRIPT:$SCRIPT_PATH"

# Or use wslpath for proper escaping
WIN_PATH=$(wslpath -w "$SCRIPT_PATH")
```

### Debug Mode

**Enable verbose TCL output:**
```tcl
# At start of script
set_param messaging.verbose 1

# Detailed logging
set log_file [open "debug.log" w]
puts $log_file "[INFO] Starting build at [clock format [clock seconds]]"
close $log_file
```

**Run with error tracking:**
```bash
libero.exe SCRIPT:script.tcl 2>&1 | tee -a build_log.txt
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Build failed! Check build_log.txt"
    exit 1
fi
```

---

## Reference: TCL Command Categories

### Project Management
```tcl
new_project -location "./project" -name "demo" ...
open_project -file "project.prjx"
save_project
close_project
```

### Design Import
```tcl
import_files -hdl_source "design.v"
create_links -sdc "timing.sdc"
create_links -io_pdc "pins.pdc"
```

### Build Flow
```tcl
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}
```

### Programming File
```tcl
export_prog_job -job_file_name "program.job"
export_bitstream_file -file_name "bitstream" -format {SPI}
```

### Status Checking
```tcl
check_tool -name {SYNTHESIZE}
check_tool -name {PLACEROUTE}
```

---

## Additional Resources

**Official Documentation:**
- Libero TCL Command Reference (in Libero installation)
- SoftConsole User Guide
- PolarFire SoC Documentation

**Sample Scripts:**
```
/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/scripts/sample/run.tcl
```

**This Repository:**
- `tcl_scripts/` - Working examples
- `docs/` - Guides and patterns
- `.claude/CLAUDE.md` - Development notes
