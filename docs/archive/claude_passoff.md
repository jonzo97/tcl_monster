# Claude Passoff: PolarFire Reference Design Mining (TCL/HDL/IP)

Use this cheat sheet to stay aligned with the latest mining work. Keep heavyweight archives ignored; rely on the indices and summaries below.

## Key Directories (do not track archives)
- `ref_designs/` — raw drops (ignored by .gitignore except markdown).
- `ref_designs_hdl/` — extracted HDL from all designs (1,022 files). Consider ignoring if repo bloat matters; use summaries instead.

## Core Indices
- `docs/ref_designs/tcl_index.json` — per design: Libero version (if found), TCL count, entry candidates (script/top).
- `docs/ref_designs/ip_versions.md` — IP version pins from `common.tcl`.
- `docs/ref_designs/ip_config_index.json` — all `create_and_configure_core` (VLNV, component, params) per design.
- `docs/ref_designs/ip_config_focus.json` — filtered to DDR/XCVR/PCS/JESD/MIPI/HDMI/PLL/CCC cores.
- `docs/ref_designs/custom_hdl_index.json` — per target design: custom HDL modules → file paths (non-IP/BFM heuristic).

## TCL Guidance
- Reference: `docs/ref_designs/tcl_deep_dive.md` and `tcl_reusable_patterns.md`.
- Flow skeleton: `script.tcl` with numbered helpers (`1_create_design`, `2_constrain_design`, `4_implement_design`, `5_program_design`); SmartDesign components in `src/components`, aggregated by `top.tcl`.
- Constraints: `create_links` + `organize_tool_files` into both SYNTHESIZE and PLACEROUTE.
- Tool order: SYNTH → PLACE → VERIFYTIMING → GENERATEPROGRAMMINGDATA/FILE → `export_prog_job`; save after major steps.
- SmartDesign hygiene: rebuild hierarchy before `generate_component`, then `set_root -module {<sd>::work}`, save.
- Component-first bias: `create_and_configure_core` + `sd_instantiate_component`; use `sd_instantiate_hdl_module` sparingly for small leaf HDL.

## HDL Highlights (custom glue worth reusing)
- See `docs/ref_designs/custom_hdl_notes.md` and `custom_hdl_index.json`.
- SERDES/HSIO: mpf_dg0757_df, mpf_dg0843_df, mpf_dg0799_eval_df (PRBS, bit-slip, bank control, pattern gens).
- Bit-slip/PRBS: mpf_an4662_df (FabUART, bit_slip_*, pattern_gen/chk).
- Video/JESD/DDR: mpf_an5454_v2024p2_df (packetization, PISO/SIPO, DDR arbiters), mpf_an5270_v2025p1_df (4K video/MIPI/HDMI largely IP-wrapped).
- PCIe/DDR helpers: mpf_an4597_df.
- Small glue: mpf_an4661_v2024p1_eval_df (LSRAM/MACC cascades, pattern_chk variants).

## IP Configuration Pointers
- High-signal configs: use `ip_config_focus.json` to lift DDR/CCC/PLL/XCVR/JESD/MIPI/HDMI core setups.
- Version pins: use `ip_versions.md` (common.tcl).
- Full core listing: `ip_config_index.json` (includes component names and params).

## Keep in Mind
- Archives stay ignored; don’t add bulk from `ref_designs/` or `ref_designs_hdl/` unless explicitly desired.
- Use Windows paths for Libero when scripting directly; follow constraint linking patterns from `tcl_reusable_patterns.md`.
- When instantiating HDL in SmartDesign, only import leaf modules you intend to place; avoid submodule imports that break `sd_instantiate_hdl_module`.

## Quick Snippets (from tcl_reusable_patterns.md)
- Constraint hook:
  ```
  create_links -io_pdc {C:/proj/constraints/io.pdc}
  create_links -sdc    {C:/proj/constraints/timing.sdc}
  organize_tool_files -tool {SYNTHESIZE} -file {C:/proj/constraints/timing.sdc} -module {top} -input_type {constraint}
  organize_tool_files -tool {PLACEROUTE} -file {C:/proj/constraints/timing.sdc} -module {top} -input_type {constraint}
  ```
- Run/export block:
  ```
  run_tool -name {SYNTHESIZE}
  run_tool -name {PLACEROUTE}
  run_tool -name {VERIFYTIMING}
  run_tool -name {GENERATEPROGRAMMINGDATA}
  run_tool -name {GENERATEPROGRAMMINGFILE}
  export_prog_job -job_file_name $project_name -export_dir $projectDir/designer/top/export -bitstream_file_type {TRUSTED_FACILITY}
  save_project
  ```
