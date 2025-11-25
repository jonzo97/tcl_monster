# HDL Extraction Summary (PolarFire Reference Designs)

- Extraction: All `.v/.sv/.vh/.vhd/.vhdl` copied from `ref_designs/*` into `ref_designs_hdl/` (1,022 files across 38 designs). Archives remain ignored; this folder is tracked unless we choose to ignore it later.
- Heavy HDL sources (top counts): mpf_dg0757_df (249), mpf_dg0799_eval_df (201), mpf_dg0843_df (185), mpf_an5616_df (36), mpf_an4661_v2024p1_eval_df (34), mpf_an5454_v2024p2_df (30), mpf_an4597_df (29), mpf_an5014_v2023p1_eval_df (28), mpf_an5270_v2025p1_df (27).
- Top module names by occurrence across all extracted HDL (likely IP wrappers/BFMs/testbenches): `testbench` (21), `BFM_MAIN` (8), `UART_IF`/`FabUART`/`CoreAPB3` family (6), `corereset_pf_tb` (6), lane master/rfd variants (4), pattern/prbs generators (3–4). Indicates many designs include built-in BFMs/testbenches alongside IP example logic.
- Most designs follow IP-centric HDL (wrappers, BFMs, example datapaths). Custom logic hotspots appear in video/CXP/HSIO designs (e.g., pattern/prbs generators, wave_gen, FiFo wrappers).
- Next steps: If needed, we can mine per-design module lists or diff against Libero IP wrappers to isolate unique custom RTL for reuse.
