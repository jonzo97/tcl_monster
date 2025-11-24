read_sdc -scenario "place_and_route" -netlist "optimized" -pin_separator "/" -ignore_errors {C:/tcl_monster/libero_projects/tmr/miv_tmr_mpf300/designer/TMR_TOP/place_route.sdc}
set_options -tdpr_scenario "place_and_route" 
save
set_options -analysis_scenario "place_and_route"
report -type combinational_loops -format xml {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\TMR_TOP_layout_combinational_loops.xml}
report -type slack {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\pinslacks.txt}
set coverage [report \
    -type     constraints_coverage \
    -format   xml \
    -slacks   no \
    {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\TMR_TOP_place_and_route_constraint_coverage.xml}]
set reportfile {C:\tcl_monster\libero_projects\tmr\miv_tmr_mpf300\designer\TMR_TOP\coverage_placeandroute}
set fp [open $reportfile w]
puts $fp $coverage
close $fp