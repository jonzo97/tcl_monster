# Hardware Platform Header Auto-Generation

Quick reference for generating `hw_platform.h` from Libero designs.

## TL;DR

```bash
./scripts/generate_hw_platform.sh project.prjx SMARTDESIGN_NAME
```

## Files Created

- `scripts/export_memory_map.tcl` - Libero TCL script
- `scripts/generate_hw_platform.py` - Parser & generator
- `scripts/generate_hw_platform.sh` - All-in-one wrapper
- `docs/hw_platform_generation.md` - Full documentation

## Quick Test

```bash
# From tcl_monster directory
./scripts/generate_hw_platform.sh \
    hdl/miv_polarfire_eval/Libero_Projects/PF_Eval_Kit_MIV_RV32_BaseDesign.prjx \
    MIV_RV32
```

See `docs/hw_platform_generation.md` for complete documentation.
