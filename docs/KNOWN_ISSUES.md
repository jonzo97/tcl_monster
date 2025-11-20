# Known Issues

## miv_rv32_demo Project - Memory Map DRC Errors

**Issue:** All peripherals export with the same base address (`0x70000000`)

**Details:**
- Memory map export shows all peripherals at address `0x70000000`
- DRC errors in exported JSON indicate addressing conflicts:
  ```
  Error: Target 'MIV_ESS_C0_0/CoreUARTapb_0:APB_bif' with address space 0x7000_0000 - 0x6FFF_FFFF
  cannot be accessed by Initiator address space 0x7000_0000 - 0x7FFF_FFFF
  ```

**Impact:**
- Generated `hw_platform.h` has duplicate addresses
- Firmware will not work with these addresses
- Project must be fixed before use

**Root Cause:**
- SmartDesign address assignments are incorrectly configured
- Likely all peripherals assigned to same address in address editor

**Fix Required:**
1. Open project in Libero GUI
2. Open SmartDesign: `MIV_RV32_BaseDesign`
3. Fix address assignments in Address Editor
4. Ensure each peripheral has unique, non-overlapping address range
5. Re-export memory map

**Expected Addresses (example):**
```
CoreUARTapb:     0x70000000 - 0x70000FFF (4KB)
CoreTimer_C0:    0x70001000 - 0x70001FFF (4KB)
CoreTimer_C1:    0x70002000 - 0x70002FFF (4KB)
CoreGPIO:        0x70003000 - 0x70003FFF (4KB)
```

**Status:** DOCUMENTED - Test project needs proper configuration

**Workaround for Testing:**
Use an official MI-V reference design instead:
```bash
cd hdl/miv_polarfire_eval/Libero_Projects
./run_libero.sh PF_Eval_Kit_MIV_RV32_BaseDesign.tcl CFG1
# Then test toolkit on the generated project
```

Or use a project with properly configured SmartDesign addressing from the start.

---

**Date:** 2025-11-19
**Discovered During:** hw_platform.h toolkit testing
