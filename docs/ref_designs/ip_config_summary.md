# IP Configuration Summary (Core-Level, Extracted)

Artifacts:
- `docs/ref_designs/ip_config_index.json` — all `create_and_configure_core` instances (core VLNV, component name, params if present) per design.
- `docs/ref_designs/ip_config_focus.json` — filtered to high-signal cores (DDR, XCVR/PCS, JESD, MIPI, HDMI, PLL/CCC).

Highlights (selected designs):
- **mpf_dg0889_liberosoc_df** (48 cores): Multiple Bayer_Interpolation, COREDDR_LITEAXI, CoreAHBLite, CoreAPB3, COREI2C, COREJTAGDEBUG, COREJESD, PF_* clock/XCVR, video ISP blocks.
- **mpf_an5014_v2023p1_eval_df** (35 cores): COREAXI4INTERCONNECT, CORECIC/FIFO/FIR, CoreJESD204B RX/TX, CoreGPIO/UART/I2C/JTAGDEBUG, PF_CCC, XCVR, DDR, etc.
- **mpf_an4684_v2025p1_df** (2 cores): CorePCS (3.5.106), dp_receiver (2.1.0) — DisplayPort RX focus.
- **mpf_an5021_v2025p1_df** (1 core): DDR_Read (1.1.0).
- **mpf_an4623_v2022p3_df** (11 cores): CoreTSE 3.2.119 (Ethernet), CoreAPB3, CORESPI/UART, CORERESET_PF, MIV_RV32, PF_CCC/INIT_MONITOR/IOD_CDR.

Use case:
- For core parameterization or version pinning, start from `ip_config_focus.json` to grab SERDES/DDR/JESD/MIPI/HDMI configs; fall back to the full index for other IP.
- Combine with `docs/ref_designs/ip_versions.md` (common.tcl version pins) when porting to a different Libero release.
