set_defvar -name {SPEED}   -value {-1}
set_defvar -name {VOLTAGE} -value {1.0}
set_defvar -name {TEMPR}   -value {IND}
set_defvar -name {PART_RANGE}   -value {IND}
set_defvar -name {IO_DEFT_STD} -value {LVCMOS18}
set_defvar -name {PACOMP_PARPT_MAX_NET} -value {10}
set_defvar -name {PA4_GB_MAX_RCLKINT_INSERTION} -value {16}
set_defvar -name {PA4_GB_MIN_GB_FANOUT_TO_USE_RCLKINT} -value {1000}
set_defvar -name {PA4_GB_MAX_FANOUT_DATA_MOVE} -value {5000}
set_defvar -name {PA4_GB_HIGH_FANOUT_THRESHOLD} -value {5000}
set_defvar -name {PA4_GB_COUNT} -value {36}
set_defvar -name {RESTRICTPROBEPINS} -value {0}
set_defvar -name {RESTRICTSPIPINS} -value {0}
set_defvar -name {PDC_IMPORT_HARDERROR} -value {1}
set_defvar -name {PA4_IDDQ_FF_FIX} -value {1}
set_defvar -name {BLOCK_PLACEMENT_CONFLICTS} -value {ERROR}
set_defvar -name {BLOCK_ROUTING_CONFLICTS} -value {LOCK}
set_defvar -name {RTG4_MITIGATION_ON} -value {0}
set_defvar -name {USE_CONSTRAINT_FLOW} -value True
set_defvar -name {FHB_AUTO_INSTANTIATION} -value {0}
set_defvar -name {SYSTEM_CONTROLLER_SUSPEND_MODE} -value {0}

set_compile_info \
    -category {"Device Selection"} \
    -name {"Family"} \
    -value {"PolarFire"}
set_compile_info \
    -category {"Device Selection"} \
    -name {"Device"} \
    -value {"MPF300TS"}
set_compile_info \
    -category {"Device Selection"} \
    -name {"Package"} \
    -value {"FCG1152"}
set_compile_info \
    -category {"Device Selection"} \
    -name {"Speed Grade"} \
    -value {"-1"}
set_compile_info \
    -category {"Device Selection"} \
    -name {"Core Voltage"} \
    -value {"1.0V"}
set_compile_info \
    -category {"Device Selection"} \
    -name {"Part Range"} \
    -value {"IND"}
set_compile_info \
    -category {"Device Selection"} \
    -name {"Default I/O technology"} \
    -value {"LVCMOS 1.8V"}
set_compile_info \
    -category {"Source Files"} \
    -name {"Topcell"} \
    -value {"TMR_TOP"}
set_compile_info \
    -category {"Source Files"} \
    -name {"Format"} \
    -value {"Verilog"}
set_compile_info \
    -category {"Source Files"} \
    -name {"Source"} \
    -value {"C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\synthesis\TMR_TOP.vm"}
set_compile_info \
    -category {"Options"} \
    -name {"Limit the number of high fanout nets to display to"} \
    -value {"10"}
compile \
    -desdir {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP} \
    -design TMR_TOP \
    -fam PolarFire \
    -die PA5M300TS \
    -pkg fcg1152 \
    -merge_pdc 0
