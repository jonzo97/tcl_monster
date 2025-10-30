# PF_CCC with dual outputs: 50 MHz (OUT0) + 200 MHz (OUT1)
# Based on PF_CCC_C0 but with OUT1 enabled at 200 MHz
create_and_configure_core -core_vlnv {Actel:SgCore:PF_CCC:*} -download_core -component_name {PF_CCC_DUAL} -params {\
"DLL_CLK_0_BANKCLK_EN:false"  \
"DLL_CLK_0_DEDICATED_EN:false"  \
"DLL_CLK_0_FABCLK_EN:false"  \
"DLL_CLK_1_BANKCLK_EN:false"  \
"DLL_CLK_1_DEDICATED_EN:false"  \
"DLL_CLK_1_FABCLK_EN:false"  \
"GL0_0_IS_USED:true"  \
"GL0_0_OUT_FREQ:50"  \
"GL0_0_FABCLK_USED:true"  \
"GL0_0_DIV:20"  \
"GL0_1_IS_USED:true"  \
"GL0_1_OUT_FREQ:200"  \
"GL0_1_FABCLK_USED:true"  \
"GL0_1_DIV:5"  \
"PLL_IN_FREQ_0:50"  \
"VCOFREQUENCY:1000.0"  \
"PLL_FEEDBACK_MODE_0:Post-VCO"  \
"PLL_FB_CLK_0:GL0_0"  \
"PLL_DYNAMIC_CONTROL_EN_0:true"  \
"PLL_POSTDIVIDERADDSOFTLOGIC_0:true"  \
"PLL_RESET_ON_LOCK_0:true"  \
"PLL_REFDIV_0:5"  \
"PLL_BANDWIDTH_0:2"  }
