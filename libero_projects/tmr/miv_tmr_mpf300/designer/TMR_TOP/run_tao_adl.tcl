set_device -family {PolarFire} -die {MPF300TS} -speed {-1}
read_adl {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\TMR_TOP.adl}
read_afl {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\TMR_TOP.afl}
map_netlist
read_sdc {C:\tcl_monster\constraint\tmr\miv_tmr_timing.sdc}
check_constraints {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\constraint\placer_sdc_errors.log}
estimate_jitter -report {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\place_and_route_jitter_report.txt}
write_sdc -mode layout {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\place_route.sdc}
