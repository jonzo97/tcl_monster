# TCL Deep Dive (Corpus-Wide Insights)

Scope: 1,549 TCL files across 64 reference designs (ref_designs/*). Highlights actionable patterns and reusable snippets beyond the quick consensus.

## Flow scaffolding (seen in most “script.tcl” drivers)
- Standard step split: `1_create_design.tcl` (import HDL + source components), `2_constrain_design.tcl` (PDC/SDC), `4_implement_design.tcl` (synth/place/verify), `5_program_design.tcl` (bitstream/export). Some designs add `3_implement_design.tcl` or variant-specific folders (e.g., Low_Power vs Normal).
- Top-level template:
  ```tcl
  # import HDL leafs first
  import_files -hdl_source {./src/hdl/foo.v}
  build_design_hierarchy

  # source IP/component configs
  source ./src/components/PF_CCC_C0.tcl
  source ./src/components/CORERESET_PF_C0.tcl
  # ...

  # generate SDs and set root
  source ./src/components/top.tcl
  build_design_hierarchy
  set_root -module {top::work}
  save_project
  ```

## SmartDesign best practices in the wild
- Generate → set_root → save ordering is consistent. `build_design_hierarchy` is often re-run before `generate_component` and before `set_root`.
- Component-first bias: `create_and_configure_core` + `sd_instantiate_component` dominate. `sd_instantiate_hdl_module` used sparingly for custom leaf blocks (e.g., pattern/prbs generators, video glue).
- Large builds (video/HSIO) split component sourcing into logical phases (clock/reset, MSS, PHY/XCVR, video/ISP) with intermediate hierarchy rebuilds to avoid dependency issues.

## Constraint linking patterns
- Common snippet:
  ```tcl
  create_links -io_pdc {C:/path/constraints/io.pdc}
  create_links -sdc    {C:/path/constraints/timing.sdc}
  organize_tool_files -tool {SYNTHESIZE} -file {C:/path/constraints/timing.sdc} -module {top} -input_type {constraint}
  organize_tool_files -tool {PLACEROUTE} -file {C:/path/constraints/timing.sdc} -module {top} -input_type {constraint}
  ```
- Some designs add `create_links -ipxact` or multiple SDCs per variant (e.g., HSIO modes). Keep module names aligned with SmartDesign name (often `top` or block-specific).

## Tool-run gating and exports
- Flow ordering is stable: `run_tool SYNTHESIZE` → `PLACEROUTE` → `VERIFYTIMING` → `GENERATEPROGRAMMINGDATA/FILE` → `export_prog_job`.
- Timing guard: many scripts call `run_tool -name VERIFYTIMING` before bitstream/export.
- Exports: `export_prog_job` with TRUSTED_FACILITY is common; some use DirectC/FlashPro job outputs in job bundles.

## IP version pinning
- `common.tcl` per design captures IP versions (`set <IP>ver {x.y.z}`) and tool profiles. See `docs/ref_designs/ip_versions.md` for ready-to-use version blocks.
- Patterns encourage updating `common.tcl` when moving Libero versions; the flow is otherwise forward-compatible.

## Reusable snippets to lift directly
- Constraint hook (PDC+SDC) — see above.
- Tool run/export block:
  ```tcl
  run_tool -name {SYNTHESIZE}
  run_tool -name {PLACEROUTE}
  run_tool -name {VERIFYTIMING}
  run_tool -name {GENERATEPROGRAMMINGDATA}
  run_tool -name {GENERATEPROGRAMMINGFILE}
  export_prog_job \
    -job_file_name $project_name \
    -export_dir $projectDir/designer/top/export \
    -bitstream_file_type {TRUSTED_FACILITY}
  save_project
  ```
- Multi-variant flow: duplicate `script.tcl` per mode (e.g., `HW/64b66b`, `HW/8b10b`, `Low_Power/Normal`) while reusing shared component TCLs.

## Directory/layout norms
- `src/components/` for IP/SD TCLs, `src/hdl/` for custom RTL, `src/components/top.tcl` as SD aggregator. Numbered scripts live in `src/` or `TCL_Scripts/src/`.
- Job bundles and GUI artifacts live separately (JB/GUI folders); DF is the TCL-first flow.

## Observed custom-logic hotspots (good reuse candidates)
- Video/ISP pipelines (AXI4S broadcasters, DDR read/write controllers, upsamplers, histogram/gamma/Bayer, HDMI/MIPI blocks).
- HSIO/PCS/PRBS/pattern generators for SERDES bring-up.
- CPRI/Radio PHY blocks (COREFIR/COREFFT with custom glue).
- UART/Flash update helpers (ram_read_uart, AXI/APB wrappers).
These are imported as HDL leafs, then wrapped with IP in SmartDesign—preserve that pattern when reusing.

## Guidance when authoring new TCL
- Follow the numbered-step split; keep component sourcing modular by function.
- Import only leaf HDL you will instantiate directly; avoid pulling submodules that make SmartDesign treat them as non-leaf.
- Rebuild hierarchy before generate/set_root when adding blocks mid-script.
- Always link constraints into both SYNTHESIZE and PLACEROUTE.
- Save after major milestones (post-generate, post-run).

## Suggested reusable filelets
- `docs/ref_designs/tcl_reusable_patterns.md` contains drop-in code blocks (flow, constraints, export).
- `docs/ref_designs/ip_versions.md` to seed IP pinning.
- `docs/ref_designs/tcl_index.json` for quick entry points per design (entry_candidates list).
