# BeagleV-Fire LED Blink - Standalone FPGA Project
# Simple LED blinker for MPFS025T PolarFire SoC
# Does NOT include full MSS/HSS - fabric only

set project_name "beaglev_led_blink"
set project_dir "C:/tcl_monster/beaglev_fire_demo/$project_name"

# Device configuration for BeagleV-Fire
set family "PolarFireSoC"
set die "MPFS025T"
set package "FCVG484"
set speed "-1"
set die_voltage "1.0"

puts "========================================="
puts "BeagleV-Fire LED Blink Project Creation"
puts "========================================="
puts "Project: $project_name"
puts "Device:  $die $package"
puts "========================================="

# Create project
puts "\n\[INFO\] Creating project..."
new_project \
    -location $project_dir \
    -name $project_name \
    -project_description "BeagleV-Fire LED Blink Demo" \
    -block_mode 0 \
    -standalone_peripheral_initialization 0 \
    -hdl {VERILOG} \
    -family $family \
    -die $die \
    -package $package \
    -speed $speed \
    -die_voltage $die_voltage \
    -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
    -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
    -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} \
    -adv_options {RESTRICTPROBEPINS:1} \
    -adv_options {RESTRICTSPIPINS:0} \
    -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
    -adv_options {TEMPR:EXT} \
    -adv_options {VCCI_1.2_VOLTR:EXT} \
    -adv_options {VCCI_1.5_VOLTR:EXT} \
    -adv_options {VCCI_1.8_VOLTR:EXT} \
    -adv_options {VCCI_2.5_VOLTR:EXT} \
    -adv_options {VCCI_3.3_VOLTR:EXT} \
    -adv_options {VOLTR:EXT}

# Add LED blinker Verilog source
puts "\n\[INFO\] Adding HDL sources..."
set hdl_path "C:/tcl_monster/hdl/beaglev_fire"

if {[file exists "$hdl_path/led_blinker_fabric.v"]} {
    import_files \
        -library {work} \
        -hdl_source "$hdl_path/led_blinker_fabric.v"
    puts "\[INFO\] Added led_blinker_fabric.v"
} else {
    puts "\[ERROR\] Cannot find led_blinker_fabric.v at $hdl_path"
    exit 1
}

# Build design hierarchy
puts "\n\[INFO\] Building design hierarchy..."
build_design_hierarchy

# Set root module
puts "\n\[INFO\] Setting root module..."
set_root -module {led_blinker_fabric::work}

# Add constraints
puts "\n\[INFO\] Adding constraints..."
set constraint_path "C:/tcl_monster/constraint"

# Add I/O pin constraints (PDC)
if {[file exists "$constraint_path/beaglev_fire_led_blink.pdc"]} {
    create_links \
        -io_pdc "$constraint_path/beaglev_fire_led_blink.pdc"
    puts "\[INFO\] Added beaglev_fire_led_blink.pdc"
} else {
    puts "\[ERROR\] Cannot find beaglev_fire_led_blink.pdc at $constraint_path"
    exit 1
}

# Add timing constraints (SDC)
if {[file exists "$constraint_path/beaglev_fire_led_blink.sdc"]} {
    create_links \
        -sdc "$constraint_path/beaglev_fire_led_blink.sdc"
    puts "\[INFO\] Added beaglev_fire_led_blink.sdc"
} else {
    puts "\[WARN\] Cannot find beaglev_fire_led_blink.sdc at $constraint_path"
}

# Save project
puts "\n\[INFO\] Saving project..."
save_project

puts "\n========================================="
puts "Project created successfully!"
puts "Location: $project_dir"
puts "========================================="
puts "\nNext steps:"
puts "1. Run SYNTHESIZE"
puts "2. Run PLACEROUTE"
puts "3. Generate bitstream"
puts "========================================="
