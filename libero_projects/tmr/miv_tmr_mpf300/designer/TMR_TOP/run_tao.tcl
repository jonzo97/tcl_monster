set_device -family {PolarFire} -die {MPF300TS} -speed {-1}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\pkg\miv_rv32_hart_cfg_pkg.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\pkg\miv_rv32_pkg.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\hart_merged\miv_rv32_hart_merged.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\pkg\miv_rv32_subsys_pkg.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\subsys_merged\miv_rv32_subsys_merged.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\memory\miv_rv32_ram_singleport_lp_ecc.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\Microsemi\MiV\MIV_RV32\3.1.200\memory\miv_rv32_ram_singleport_lp.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\MIV_RV32_CORE_A\MIV_RV32_CORE_A_0\rtl\miv_rv32.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\MIV_RV32_CORE_A\MIV_RV32_CORE_A.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\MIV_RV32_CORE_B\MIV_RV32_CORE_B_0\rtl\miv_rv32.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\MIV_RV32_CORE_B\MIV_RV32_CORE_B.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\MIV_RV32_CORE_C\MIV_RV32_CORE_C_0\rtl\miv_rv32.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\MIV_RV32_CORE_C\MIV_RV32_CORE_C.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\hdl\tmr_functional_outputs.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\hdl\triple_voter_1bit.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\hdl\triple_voter_64bit.v}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\component\work\TMR_TOP\TMR_TOP.v}
set_top_level {TMR_TOP}
map_netlist
read_sdc {C:\tcl_monster\constraint\tmr\miv_tmr_timing.sdc}
check_constraints {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\constraint\synthesis_sdc_errors.log}
write_fdc {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\synthesis.fdc}
