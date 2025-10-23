open_project -project {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter_fp\counter.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {MPF300TS} \
    -fpga {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter.map} \
    -header {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter.hdr} \
    -snvm {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter_snvm.efc} \
    -spm {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter.spm} \
    -dca {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter.dca}
export_single_ppd \
    -name {MPF300TS} \
    -file {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter.ppd}

save_project
close_project
