# Hardware Platform Header Auto-Generator

**WORKING VERSION - Tested and validated!**

Auto-generate `hw_platform.h` from Libero SmartDesign memory maps.

---

## Quick Start

### Linux/WSL/Git Bash:
```bash
./generate_hw_platform.sh /path/to/project.prjx SMARTDESIGN_NAME output_dir
```

### Windows PowerShell/CMD:
```powershell
.\generate_hw_platform.bat "C:\path\to\project.prjx" "SMARTDESIGN_NAME" ".\output"
```

**Example (Linux/WSL):**
```bash
./generate_hw_platform.sh ./my_project/my_project.prjx MIV_RV32 ./output
```

**Example (Windows):**
```powershell
.\generate_hw_platform.bat "C:\Projects\my_project\my_project.prjx" "MIV_RV32" ".\output"
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

## Files Included

- `generate_hw_platform.sh` - Bash script (Linux/WSL/Git Bash)
- `generate_hw_platform.ps1` - PowerShell script (Windows native)
- `generate_hw_platform.bat` - Batch wrapper (calls PowerShell)
- `generate_hw_platform.py` - Python parser (cross-platform)
- `export_memory_map.tcl` - Libero TCL export script
- `hw_platform_generation.md` - Complete documentation
- `REQUIREMENTS.txt` - Dependency information

---

**Version:** 1.3 (Added Windows support)
**Date:** 2025-11-19

See `hw_platform_generation.md` for full documentation.
