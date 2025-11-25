# Netlist Viewer TCL File
set_family -name PolarFire
top_module -name TMR_TOP
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/pkg/miv_rv32_hart_cfg_pkg.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/pkg/miv_rv32_pkg.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/hart_merged/miv_rv32_hart_merged.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/pkg/miv_rv32_subsys_pkg.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/subsys_merged/miv_rv32_subsys_merged.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/memory/miv_rv32_ram_singleport_lp_ecc.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/Microsemi/MiV/MIV_RV32/3.1.200/memory/miv_rv32_ram_singleport_lp.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/MIV_RV32_CORE_A/MIV_RV32_CORE_A_0/rtl/miv_rv32.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/MIV_RV32_CORE_A/MIV_RV32_CORE_A.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/MIV_RV32_CORE_B/MIV_RV32_CORE_B_0/rtl/miv_rv32.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/MIV_RV32_CORE_B/MIV_RV32_CORE_B.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/MIV_RV32_CORE_C/MIV_RV32_CORE_C_0/rtl/miv_rv32.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/MIV_RV32_CORE_C/MIV_RV32_CORE_C.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/hdl/tmr_functional_outputs.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/hdl/triple_voter_1bit.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/hdl/triple_voter_64bit.v}
addfile -view RTL -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/component/work/TMR_TOP/TMR_TOP.v}
addfile -view HIER -lib work -type VLOG -mode system_verilog -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/synthesis/TMR_TOP.vm}
addfile -view FLAT -lib work -type AFL -mode NONE -name {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/designer/TMR_TOP/COMPILE/TMR_TOP.afl}