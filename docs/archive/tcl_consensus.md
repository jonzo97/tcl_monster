# TCL Consensus (PolarFire Reference Designs)

Sources: unpacked `ref_designs/*` TCL files (1,549 total). RAR `mpf_dg0841_liberosocpolarfirev2p3` not extracted. Archives ignored via `.gitignore`.

## High-level patterns
- **Component-first flow:** Heavy use of `create_and_configure_core` (899/1549 files). SmartDesign flows dominate (`sd_instantiate_component` 190, `sd_connect_pins` 213, `generate_component` 217). HDL instantiation is secondary (`sd_instantiate_hdl_module` 94).
- **Five-step script topology:** Many designs use `script.tcl` with numbered helpers: `1_create_design.tcl`, `2_constrain_design.tcl`, `4_implement_design.tcl`, `5_program_design.tcl`, plus `src_components/top.tcl`.
- **Tool runs:** Synthesis/P&R/bitstream appear consistently (≈50 occurrences each of `run_tool -name SYNTHESIZE/PLACEROUTE/VERIFYTIMING/GENERATEPROGRAMMINGDATA`); `export_prog_job` seen in 50 files.
- **Constraint handling:** `organize_tool_files` (66) and `create_links` (44) show explicit linking of PDC/SDC into SYNTHESIZE/PLACEROUTE.
- **SmartDesign hygiene:** `build_design_hierarchy`, `generate_component`, and `set_root` appear ~50–70 times, aligning with our internal lessons (generate → set_root → save).
- **Top-10 motif sample (by TCL count):** mpf_an5270_v2025p1_df, mpf_an4662_df, mpf_an5454_v2024p2_df, mpf_an5021_v2025p1_df, mpf_an4597_df, mpf_dg0889_liberosoc_df, mpf_dg0757_df, mpf_an4661_v2024p1_eval_df, mpf_an5188_v2024p1_df, mpf_an5014_v2023p1_eval_df. Common traits: component-first (30–60 `create_and_configure_core` per design), SmartDesign instantiation (6–18 uses), HDL instantiation occasionally (3–8 uses), single run-tool sequence (synth/place/verify/genprog/export) per flow; organize/create_links used sparingly in some (mpf_an4662_df heavily uses them).

## Libero version coverage (also see docs/ref_designs/version_index.md)
- v2025.1 cluster: an4593/94/97, an4664, an4682, an4684_df, an4768_df, an4997, an5488, an5864_eval, an5978, an6141_df.
- v2024.1/2024.2 clusters: an4591/92, an4660/61/62/63, an5454_df, an5466, an5524_df, an5616, an5341, an5188_df, an5021_df, etc.
- Older: v2023.x (an4569, an5069, an5102, an4950, an5522_df), v2022.x (an4596, an4623, an4792, an4895, an4949), legacy v12.4/12.6 (dg0884_cxp, dg0799_eval).
- Unknowns: GUI/JB variants and the rar remain to be tagged.

## High-TCL-count designs to mine first
- mpf_an5270_v2025p1_df (97), mpf_an4662_df (94), mpf_an5454_v2024p2_df (85), mpf_an5021_v2025p1_df (85), mpf_an4597_df (73), mpf_dg0889_liberosoc_df (64), mpf_dg0757_df (61), mpf_an4661_v2024p1_eval_df (54), mpf_an5188_v2024p1_df (49), mpf_an5014_v2023p1_eval_df (49).

## Command frequency (corpus-wide)
- create_and_configure_core: 899
- smartdesign (any): 252
- generate_component: 217
- sd_connect_pins: 213
- sd_instantiate_component: 190
- sd_instantiate_hdl_module: 94
- organize_tool_files: 66, create_links: 44
- run_tool SYNTHESIZE/PLACEROUTE/VERIFYTIMING/GENERATEPROGRAMMINGDATA: ~49 each
- export_prog_job: 50, set_root: 53, build_design_hierarchy: 69

## Entry-script naming patterns (representative)
- `script.tcl` as the driver; supporting numbered scripts (`1_create_design.tcl`, `2_constrain_design.tcl`, `4_implement_design.tcl`, `5_program_design.tcl`) and `src_components/top.tcl`.
- Variant subfolders per mode/kit (e.g., an4661 Low_Power vs Normal; an4662 64b66b vs 8b10b vs PMA variants).
- Device-specific component tops: `CAM_IOD_TIP_TOP.tcl`, `IMX334_IF_TOP.tcl`, `Video_Processing_Block_TOP.tcl`, `CXP_DEVICE_TOP.tcl`, etc.

## Interim data file
- A structured index (not tracked in git) was generated during analysis; key aggregates are reflected here and in `version_index.md`. If we want a durable intermediate, we can export a JSON of `{design, libero_version, tcl_file_count, entry_candidates[]}` and keep it alongside this doc.

## Alignment with existing guidance
- Matches `docs/reference/libero_build_flow_lessons.md`: component-first SmartDesign flow; generate → set_root → save; constraints linked to both synth/P&R; avoid HDL sub-module instantiation pitfalls (minimal use of `sd_instantiate_hdl_module` in corpus).
