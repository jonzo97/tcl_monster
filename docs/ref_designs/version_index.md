# Reference Design Libero Version Index

Source: readme files inside `ref_designs/*` (archives ignored via `.gitignore`). Values are the first Libero version string found per design folder. JB/GUI variants likely share the same version as their matching DF unless noted otherwise.

## Versions observed
- **v2025.1:** mpf_an4593_df, mpf_an4594_df, mpf_an4597_df (1), mpf_an4664_df, mpf_an4682_df, mpf_an4684_v2025p1_df, mpf_an4768_v2025p1_df, mpf_an4997_df, mpf_an5488_df, mpf_an5864_v2025p1_eval_df, mpf_an5978_df, mpf_an6141_v2025p1_df
- **v2024.2:** mpf_an4591_df, mpf_an4660_df, mpf_an4662_df, mpf_an5524_v2024p2_df
- **v2024.1:** mpf_an4592_df, mpf_an4661_v2024p1_eval_df, mpf_an4663_v2024p1_df, mpf_an5021_v2025p1_df, mpf_an5188_v2024p1_df, mpf_an5341_v2024p1_df, mpf_an5454_v2024p2_df, mpf_an5466_df, mpf_an5616_df
- **v2023.2:** mpf_an4569_v2023p2_eval_df, mpf_an5069_v2023p2_df, mpf_an5522_v2025p1_HSB2507_df
- **v2023.1:** mpf_an4950_v2023p1_df, mpf_an5102_v2023p1_df, mpf_dg0889_liberosoc_df
- **v2022.3:** mpf_an4623_v2022p3_df, mpf_an4895_v2022p3_df, mpf_an4949_v2022p3_df
- **v2022.2:** mpf_an4596_v2022p2_df, mpf_an4792_v2022p2_df
- **v12.6:** mpf_dg0799_eval_df
- **v12.4:** mpf_dg0884_cxp_genicam_df

## Unknown / needs extraction
- breakoutboardfiles, mpf_ac468_df, mpf_an4568_v2022p1_df (1), mpf_an4576_v2025p1_df, mpf_an4576_v2025p1_jb, mpf_an4684_v2025p1_jb, mpf_an4768_v2025p1_jb, mpf_an5014_v2023p1_eval_df, mpf_an5021_v2025p1_gui, mpf_an5021_v2025p1_jb, mpf_an5188_v2024p1_gui, mpf_an5188_v2024p1_jb, mpf_an5270_v2025p1_df, mpf_an5270_v2025p1_gui, mpf_an5270_v2025p1_jb, mpf_an5454_v2024p2_jb, mpf_an5522_v2025p1_HSB2507_jb, mpf_an6141_v2025p1_jb, mpf_dg0757_df, mpf_dg0841_liberosocpolarfirev2p3 (rar not extracted), mpf_dg0843_df, mpf_dg0849_liberosoc_gui, mpf_dg0884_liberosoc_gui, mpf_dg0884_liberosoc_jb, mpf_dg0889_liberosoc_jb, mpf_dg0889_liberosoc_jb (1)

## Notes
- `.gitignore` now excludes `ref_designs/*` while allowing markdown notes.
- `mpf_dg0841_liberosocpolarfirev2p3` extracted from rar: contains GUI installer assets (no Libero readme/TCL found); version still unknown.
- Duplicates with “(1)” are duplicated downloads; treat as same design unless hashes differ.
- IP core versions parsed from available `common.tcl` files are summarized in `docs/ref_designs/ip_versions.md`.
