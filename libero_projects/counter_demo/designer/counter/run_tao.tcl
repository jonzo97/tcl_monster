set_device -family {PolarFire} -die {MPF300TS} -speed {-1}
read_verilog -mode system_verilog {C:\tcl_monster\libero_projects\counter_demo\hdl\counter.v}
set_top_level {counter}
map_netlist
read_sdc {C:\tcl_monster\libero_projects\counter_demo\constraint\timing_constraints.sdc}
check_constraints {C:\tcl_monster\libero_projects\counter_demo\constraint\synthesis_sdc_errors.log}
write_fdc {C:\tcl_monster\libero_projects\counter_demo\designer\counter\synthesis.fdc}
