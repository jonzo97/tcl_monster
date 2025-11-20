# Microsemi Tcl Script
# libero
# Date: Wed Nov 19 17:27:02 2025
# Directory C:\tcl_monster\tcl_scripts\miv_components
# File C:\tcl_monster\tcl_scripts\miv_components\exported.tcl


open_project -file {../../libero_projects/miv_rv32_demo/miv_rv32_demo.prjx} -do_backup_on_convert 1 -backup_file {../../libero_projects/miv_rv32_demo.zip} 
export_memory_map -file {../../libero_projects/miv_rv32_demo/MIV_RV32_BaseDesign_memory_map.json} -format {} -sd_name {MIV_RV32_BaseDesign} 
