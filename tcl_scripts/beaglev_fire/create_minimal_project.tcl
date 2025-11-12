#
# BeagleV-Fire Minimal Project Creation Script
# Creates a basic PolarFire SoC project for the BeagleV-Fire board
#
# Device: MPFS025T-FCVG484E
# Reference: Based on BeagleV-Fire gateware repository
#

puts "\n=================================================================================="
puts "BeagleV-Fire Project Creation Script"
puts "Device: MPFS025T-FCVG484E (PolarFire SoC)"
puts "==================================================================================\n"

# Check Libero version
set libero_release [split [get_libero_version] .]
set major [lindex $libero_release 0]
set minor [lindex $libero_release 1]

puts "Detected Libero version: $major.$minor"

if {$major == 2024 && $minor == 2} {
    puts "Libero v2024.2 detected - compatible."
} elseif {$major == 2023 && $minor == 2} {
    puts "Libero v2023.2 detected - compatible."
} elseif {$major == 2024 && $minor == 1} {
    puts "Libero v2024.1 detected - compatible."
} else {
    puts "WARNING: Libero version $major.$minor may not be fully tested."
}

# Set project parameters
set project_name "beaglev_fire_demo"
set project_location "./beaglev_fire_demo"
set project_desc "BeagleV-Fire demonstration project for PolarFire SoC"

# Create the project
puts "\nCreating project: $project_name"
puts "Location: $project_location"

new_project \
    -location $project_location \
    -name $project_name \
    -project_description $project_desc \
    -block_mode 0 \
    -standalone_peripheral_initialization 0 \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1 \
    -use_relative_path 0 \
    -linked_files_root_dir_env {} \
    -hdl {VERILOG} \
    -family {PolarFireSoC} \
    -die {MPFS025T} \
    -package {FCVG484} \
    -speed {STD} \
    -die_voltage {1.05} \
    -part_range {EXT} \
    -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
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

puts "\nProject created successfully!"

# Display project information
puts "\n=================================================================================="
puts "Project Configuration:"
puts "  Name:          $project_name"
puts "  Family:        PolarFireSoC"
puts "  Device:        MPFS025T-FCVG484E"
puts "  Speed Grade:   STD (625 MHz CPU, 667 MHz for -1 speed)"
puts "  Die Voltage:   1.05V"
puts "  Temp Range:    Extended Commercial (0-100°C)"
puts "  HDL:           Verilog"
puts "==================================================================================\n"

puts "\nBeagleV-Fire Board Features:"
puts "  - 5-core RISC-V processor (4x U54 + 1x E51 monitor)"
puts "  - 23K logic elements, 68 math blocks"
puts "  - 4 SerDes lanes (12.7 Gbps)"
puts "  - 2GB LPDDR4 memory"
puts "  - 16GB eMMC storage"
puts "  - 2x Gigabit Ethernet"
puts "  - 2x PCIe Gen2 endpoints"
puts "  - USB 2.0, 5x UART, 2x SPI, 2x I2C, 2x CAN"

puts "\n=================================================================================="
puts "Next Steps:"
puts "  1. Configure MSS (Microprocessor Subsystem) using MSS Configurator"
puts "  2. Add custom FPGA fabric logic if needed"
puts "  3. Add pin constraints (PDC) for external interfaces"
puts "  4. Add timing constraints (SDC)"
puts "  5. Run synthesis and place & route"
puts "==================================================================================\n"

# Save the project
save_project
puts "\nProject saved successfully."
puts "Project file: $project_location/${project_name}.prjx"
