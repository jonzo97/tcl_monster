new_project \
         -name {counter} \
         -location {C:\tcl_monster\libero_projects\counter_demo\designer\counter\counter_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {MPF300TS} \
         -name {MPF300TS}
enable_device \
         -name {MPF300TS} \
         -enable {TRUE}
save_project
close_project
