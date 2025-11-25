# IP Recipes (DDR / XCVR / JESD / MIPI/HDMI)

Quick pointers pulled from ip_config_focus.json; see that file for params. Paths are relative to ref_designs/.

## DDR

- Actel:SystemBuilder:PF_DDR4:2.5.111 -> PF_DDR4_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_DDR4_C0.tcl)
- Microsemi:DirectCore:COREDDR_LITEAXI:2.0.101 -> COREDDR_LITEAXI_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/COREDDR_LITEAXI_C0.tcl)
- Microsemi:SolutionCore:DDR_AXI4_ARBITER_PF:2.1.0 -> DDR_AXI4_ARBITER_PF_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/DDR_AXI4_ARBITER_PF_C0.tcl)
- Microsemi:SolutionCore:DDR_Read:1.1.0 -> DDR_Read_C0 (mpf_an5021_v2025p1_df/mpf_an5021_v2025p1_df/Host/src/components/DDR_Read_C0.tcl)

## XCVR/PCS/CCC

- Actel:DirectCore:CorePCS:3.5.106 -> CorePCS_C0 (mpf_an4684_v2025p1_df/mpf_an4684_v2025p1_df/src/components/CorePCS_C0.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_0 (mpf_an4623_v2022p3_df/mpf_an4623_v2022p3_df/TCL_Scripts/src/src_components/PF_CCC_0.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_C0 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_CCC_C0.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_CCC_C0.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_C1 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_CCC_C1.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_C1 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_CCC_C1.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_C2 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_CCC_C2.tcl)
- Actel:SgCore:PF_CCC:2.2.220 -> PF_CCC_C3 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_CCC_C3.tcl)
- Actel:SgCore:PF_TX_PLL:2.0.302 -> PF_TX_PLL_C0 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_TX_PLL_C0.tcl)
- Actel:SgCore:PF_TX_PLL:2.0.302 -> PF_TX_PLL_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_TX_PLL_C0.tcl)
- Actel:SgCore:PF_TX_PLL:2.0.302 -> PF_TX_PLL_C1 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_TX_PLL_C1.tcl)
- Actel:SgCore:PF_TX_PLL:2.0.302 -> PF_TX_PLL_C1 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_TX_PLL_C1.tcl)
- Actel:SgCore:PF_XCVR_REF_CLK:1.0.103 -> PF_XCVR_REF_CLK_C0 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_XCVR_REF_CLK_C0.tcl)
- Actel:SgCore:PF_XCVR_REF_CLK:1.0.103 -> PF_XCVR_REF_CLK_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_XCVR_REF_CLK_C0.tcl)
- Actel:SgCore:PF_XCVR_REF_CLK:1.0.103 -> PF_XCVR_REF_CLK_C1 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_XCVR_REF_CLK_C1.tcl)
- Actel:SystemBuilder:PF_IOD_CDR_CCC:2.1.111 -> PF_IOD_CDR_CCC_C0 (mpf_an4623_v2022p3_df/mpf_an4623_v2022p3_df/TCL_Scripts/src/src_components/PF_IOD_CDR_CCC_C0.tcl)
- Actel:SystemBuilder:PF_XCVR_ERM:3.1.200 -> PF_XCVR_ERM_C0 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_XCVR_ERM_C0.tcl)
- Actel:SystemBuilder:PF_XCVR_ERM:3.1.200 -> PF_XCVR_ERM_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_XCVR_ERM_C0.tcl)
- Actel:SystemBuilder:PF_XCVR_ERM:3.1.200 -> PF_XCVR_ERM_C1 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/PF_XCVR_ERM_C1.tcl)
- Actel:SystemBuilder:PF_XCVR_ERM:3.1.200 -> PF_XCVR_ERM_C1 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/PF_XCVR_ERM_C1.tcl)

## JESD

- Actel:DirectCore:CoreJESD204BRX:3.4.104 -> CoreJESD204BRX_C0 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/CoreJESD204BRX_C0.tcl)
- Actel:DirectCore:CoreJESD204BTX:3.2.103 -> CoreJESD204BTX_C0 (mpf_an5014_v2023p1_eval_df/mpf_an5014_v2023p1_eval_df/script_support/components/CoreJESD204BTX_C0.tcl)

## MIPI/HDMI/DP

- Microchip:SolutionCore:HDMI_TX:5.1.0 -> HDMI_TX_C1 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/HDMI_TX_C1.tcl)
- Microchip:SolutionCore:MIPI_TRAINING_LITE:1.0.0 -> MIPI_TRAINING_LITE_C0 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/MIPI_TRAINING_LITE_C0.tcl)
- Microchip:SolutionCore:MIPI_TRAINING_LITE:1.0.0 -> MIPI_TRAINING_LITE_C1 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/MIPI_TRAINING_LITE_C1.tcl)
- Microchip:SolutionCore:MIPI_TRAINING_LITE:1.0.0 -> MIPI_TRAINING_LITE_C2 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/MIPI_TRAINING_LITE_C2.tcl)
- Microchip:SolutionCore:MIPI_TRAINING_LITE:1.0.0 -> MIPI_TRAINING_LITE_C3 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/MIPI_TRAINING_LITE_C3.tcl)
- Microchip:SolutionCore:mipicsi2rxdecoderPF:4.7.0 -> mipicsi2rxdecoderPF_C1 (mpf_dg0889_liberosoc_df/mpf_dg0889_liberosoc_df/script_support/components/mipicsi2rxdecoderPF_C1.tcl)
