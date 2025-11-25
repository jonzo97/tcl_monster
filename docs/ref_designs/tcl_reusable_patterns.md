# TCL Reusable Patterns (from PolarFire reference corpus)

- **Flow skeleton (script.tcl pattern):** import HDL (leafs), build hierarchy, source component configs, generate SmartDesigns, set_root, save. Numbered helper scripts: `1_create_design.tcl`, `2_constrain_design.tcl`, `4_implement_design.tcl`, `5_program_design.tcl`.
- **Constraint linking:** use `create_links` + `organize_tool_files` to attach PDC/SDC to SYNTHESIZE and PLACEROUTE. Keep PDC/SDC paths Windows-style if running Libero directly.
- **Tool run gate:** run in order `run_tool -name {SYNTHESIZE}` -> `PLACEROUTE` -> `VERIFYTIMING` -> `GENERATEPROGRAMMINGDATA` -> `export_prog_job`, with `save_project` after.
- **SmartDesign hygiene:** `generate_component -component_name <SD>` then `set_root -module {<SD>::work}` and `save_project`. Re-build hierarchy before generate/set_root when adding components.
- **Component-first bias:** Prefer `create_and_configure_core` + `sd_instantiate_component`; only use `sd_instantiate_hdl_module` for small custom blocks.
- **Common prologue snippet:**
  ```tcl
  # Import custom HDL (leaf modules only)
  import_files -hdl_source {./src/hdl/foo.v}
  build_design_hierarchy

  # Source IP/component configs
  source ./src/components/PF_CCC_C0.tcl
  source ./src/components/CORERESET_PF_C0.tcl
  # ... more components ...

  # Generate SmartDesigns and set root
  source ./src/components/top.tcl
  build_design_hierarchy
  set_root -module {top::work}
  save_project
  ```
- **Constraint snippet:**
  ```tcl
  create_links -io_pdc {C:/proj/constraints/io.pdc}
  create_links -sdc    {C:/proj/constraints/timing.sdc}
  organize_tool_files -tool {SYNTHESIZE} -file {C:/proj/constraints/timing.sdc} -module {top} -input_type {constraint}
  organize_tool_files -tool {PLACEROUTE} -file {C:/proj/constraints/timing.sdc} -module {top} -input_type {constraint}
  ```
- **Export snippet:**
  ```tcl
  run_tool -name {GENERATEPROGRAMMINGDATA}
  run_tool -name {GENERATEPROGRAMMINGFILE}
  export_prog_job     -job_file_name $project_name     -export_dir $projectDir/designer/top/export     -bitstream_file_type {TRUSTED_FACILITY}
  save_project
  ```
- **Reusable timing:** call `run_tool -name {VERIFYTIMING}` before bitstream/export; many designs embed this guard.
- **IP version pinning:** Many designs carry `common.tcl` with `set <IP>ver {x.y.z}`; see `docs/ref_designs/ip_versions.md` for quick reuse.
