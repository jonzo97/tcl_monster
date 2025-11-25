# PolarFire Reference Design Sweep

## Local inventory (ready for meta-analysis)
- `beaglev-fire-gateware` (MPFS025T PolarFire SoC, BeagleV-Fire). Entry scripts: `sources/FPGA-design/BUILD_BVF_GATEWARE.tcl` plus modular per-option scripts under `sources/FPGA-design/script_support/components/` and Libero flow wrappers in `recipes/libero-project/*.tcl`.
- `hdl/miv_polarfire_eval/Libero_Projects` (MPF300TS PolarFire FPGA). Entry script: `PF_Eval_Kit_MIV_RV32_BaseDesign.tcl` with SmartDesign builders in `import/build_smartdesign/*.tcl` and component configs in `import/components/*.tcl`.

## High-priority downloads to pull into `ref_designs/` (need network approval or user drop-in)
- Icicle Kit Reference Design (MPFS250T, PolarFire SoC) — public GitHub `https://github.com/polarfire-soc/icicle-kit-reference-design` (TCL flow similar to BeagleV gateware; good baseline for SoC projects).
- PolarFire PCIe/DDR/Ethernet demos (MPF300/MPF500) — typically bundled with Microchip app notes (e.g., PCIe DMA, DDR3/DDR4 controller, 1G/10G Ethernet). Likely require Microchip login; user can drop ZIPs here for offline parsing.
- PolarFire transceiver loopback/HSIO examples — SERDES/CCC-focused designs often shipped as TCL-driven projects in evaluation kit packages; useful for clocking and XCVR patterns.
- Any board-specific kits you have handy (e.g., MPF300 Eval Kit variations, PolarFire Video/Imaging demos). Place each archive under `ref_designs/<design_name>/` for ingestion.

## TCL patterns observed so far (initial guidelines)
- **Argument handling and validation:** Both designs normalize/validate arguments up front (e.g., config enums, die type, flow stage) and echo selections before use.
- **Environment guards:** Version checks (`get_libero_version`), path-length checks on Windows, and die/package selection via helper procs keep builds deterministic.
- **Staged flow:** Create project → import/instantiate SmartDesign content → apply constraints/optimizations → run gated flow (`SYNTHESIZE`/`PLACE_AND_ROUTE`/`GENERATEPROGRAMMINGDATA`) with `run_verify_timing` before exports.
- **SmartDesign-first:** Components are instantiated via SmartDesign (`sd_*` builders) rather than raw HDL, avoiding hierarchy DRCs. BVF uses highly modular component scripts per optional feature (CAPE/M2/APU/SYZYGY/MIPI), while the MI-V base uses config-specific builders (CFG1/CFG2/CFG3).
- **Constraint discipline:** Constraints applied after SmartDesign build, organized per feature (BVF `script_support/constraints`, MI-V `design_optimization.tcl`). Packaging/pin options live in project creation flags.
- **Tool configuration tweaks:** Examples include downgrading memory-map DRCs to warnings (`smartdesign ... memory_map_drc_change_error_to_warning`) and pre-configuring P&R via helper procs before running tools.
- **Export hygiene:** Bitstream/programming exports follow timing verification and save points; BVF also supports multiple export targets (SPI, FlashProExpress, DirectC) and optional ELF drop-ins.

## Intake workflow for new design drops
1. Place or clone each design under `ref_designs/<name>/` (keep original structure).
2. Add a short note here with device, entry TCL, and any options the script expects.
3. We will run a quick static scan (`find <path> -name "*.tcl"`) and fold patterns into this guideline set.

