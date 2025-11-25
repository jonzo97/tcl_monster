# Custom HDL Highlights (Transceiver/DDR/Video Focus)

Data source: `ref_designs_hdl/` filtered to modules not clearly IP/BFM. Full mapping in `docs/ref_designs/custom_hdl_index.json`.

- **mpf_dg0757_df (10G/HSIO)** — ~98 custom modules. Notable: `BANKCTRLM/BANKCTRL_*` (bank control), `PRBS`/pattern generators/checkers, `FiFo_wrapper_Top`, `PLL` wrappers, `pattern_chk/gen`, `bit_slip_*`. Rich SERDES bring-up glue.
- **mpf_dg0799_eval_df (HSIO)** — ~52 custom modules. Similar bank control + crypto/test wrappers; HSIO glue.
- **mpf_dg0843_df (HSIO/PCIe mix)** — ~100 custom modules. Includes AHB/APB bridges, AxC control generators/checkers, loopback buffers, SERDES support.
- **mpf_an4661_v2024p1_eval_df (Transceiver variants)** — 17 custom modules. `Gate_control`, cascaded LSRAM/MACC, `pattern_chk` variants, `mult18x18`, small fabric glue.
- **mpf_an4662_df (Bit slip/PRBS)** — 14 custom modules. `PRBS_gen/chk`, `bit_slip_*`, `pattern_gen/chk`, `FabUART`.
- **mpf_an5454_v2024p2_df (JESD/DDR4/Video)** — 18 custom modules. `Arbiter_Initiator_Wr_IF`, `BYTE_ALLIGNMENT`, `DATA_RATE_GENERATOR_V1`, `PISO/SIPO`, frame counters, UPSAMPLING, CDC regs/FIFOs, packetization.
- **mpf_an5270_v2025p1_df (4K Video/MIPI/HDMI)** — 1 custom module surfaced by heuristic (`scale_read_channel_BUS_IF`); many others are IP-wrapped via components (see top-level TCL).
- **mpf_an4597_df (PCIe/DDR)** — 5 custom modules. `cmd_ctrlr`, `pattern_gen_checker`, `rst_controller`, `debounce`.

Reuse guidance:
- Harvest pattern/PRBS/bit-slip modules from mpf_an4662_df for SERDES bring-up.
- Use packetization/DDR arbitration blocks from mpf_an5454_v2024p2_df for video/DDR flows.
- For HSIO transceiver scaffolding, mine mpf_dg0757_df/mpf_dg0843_df bank/bit-slip/prbs glue.
- For small fabric glue (counters, cascaded MACC/LSRAM), mpf_an4661_v2024p1_eval_df is a lightweight source.
