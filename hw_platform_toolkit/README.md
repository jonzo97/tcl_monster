# Hardware Platform Header Auto-Generator

**WORKING VERSION - Tested and validated!**

Auto-generate `hw_platform.h` from Libero SmartDesign memory maps.

---

## Quick Start

### Linux/WSL/Git Bash:
```bash
./generate_hw_platform.sh /path/to/project.prjx SMARTDESIGN_NAME [output_dir] [sys_clk_freq_hz]
```

### Windows PowerShell/CMD:
```powershell
.\generate_hw_platform.bat "C:\path\to\project.prjx" "SMARTDESIGN_NAME" ".\output" [sys_clk_freq_hz]
```

**Example (Linux/WSL) - Default 50MHz clock:**
```bash
./generate_hw_platform.sh ./my_project/my_project.prjx MIV_RV32 ./output
```

**Example (Linux/WSL) - Custom 100MHz clock:**
```bash
./generate_hw_platform.sh ./my_project/my_project.prjx MIV_RV32 ./output 100000000
```

**Example (Windows) - Default 50MHz clock:**
```powershell
.\generate_hw_platform.bat "C:\Projects\my_project\my_project.prjx" "MIV_RV32" ".\output"
```

**Example (Windows) - Custom 83MHz clock:**
```powershell
.\generate_hw_platform.bat "C:\Projects\my_project\my_project.prjx" "MIV_RV32" ".\output" 83000000
```

---

## Requirements

- **Python 3.6+** (NO pip install needed!)
- **Libero SoC v2024.x**
- **Linux/WSL:** Bash shell (built-in)
- **Windows:** PowerShell (built-in on Windows 7+)

---

## Usage Notes

### Linux/WSL/Git Bash

**For paths with spaces, use quotes:**
```bash
./generate_hw_platform.sh "/path/with spaces/project.prjx" "SmartDesign" "./output"
```

**If Libero isn't auto-detected:**
```bash
export LIBERO_PATH="/mnt/c/Microchip/Libero_SoC_v2024.2/Designer/bin/Libero.exe"
./generate_hw_platform.sh project.prjx SmartDesign output
```

### Windows PowerShell/CMD

**Paths with spaces are handled automatically:**
```powershell
.\generate_hw_platform.bat "C:\Program Files\Project\project.prjx" "Design" ".\output"
```

**If Libero isn't auto-detected:**
```powershell
$env:LIBERO_PATH = "C:\Microchip\Libero_SoC_v2024.2\Designer\bin\libero.exe"
.\generate_hw_platform.bat project.prjx Design output
```

**Direct PowerShell execution:**
```powershell
.\generate_hw_platform.ps1 "C:\path\to\project.prjx" "Design" ".\output"
```

---

## Clock Frequency Configuration

The toolkit automatically configures `SYS_CLK_FREQ` in the generated `hw_platform.h`.

**Default:** 50MHz (50000000 Hz)

**Custom clock frequency:**
```bash
# Linux/WSL - 100MHz example
./generate_hw_platform.sh project.prjx MIV_RV32 ./output 100000000

# Windows - 83MHz example
.\generate_hw_platform.ps1 "project.prjx" "MIV_RV32" ".\output" 83000000
```

**Common clock frequencies:**
- 50 MHz: `50000000`
- 83 MHz: `83000000` (BeagleV-Fire default)
- 100 MHz: `100000000`
- 125 MHz: `125000000`

**Note:** The toolkit also auto-generates BAUD_VALUE definitions based on SYS_CLK_FREQ:
- `BAUD_VALUE_115200 = (SYS_CLK_FREQ / (16 * 115200)) - 1`
- `BAUD_VALUE_57600 = (SYS_CLK_FREQ / (16 * 57600)) - 1`

---

## Files Included

- `generate_hw_platform.sh` - Bash script (Linux/WSL/Git Bash)
- `generate_hw_platform.ps1` - PowerShell script (Windows native)
- `generate_hw_platform.bat` - Batch wrapper (calls PowerShell)
- `generate_hw_platform.py` - Python parser (cross-platform)
- `export_memory_map.tcl` - Libero TCL export script
- `hw_platform_generation.md` - Complete documentation
- `REQUIREMENTS.txt` - Dependency information

---

**Version:** 1.4 (Added dynamic clock frequency configuration)
**Date:** 2025-11-20

See `hw_platform_generation.md` for full documentation.
