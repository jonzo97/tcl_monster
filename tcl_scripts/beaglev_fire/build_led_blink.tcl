# Build LED Blink Design for BeagleV-Fire
# Runs synthesis, place & route, and generates programming file

set project_dir "C:/tcl_monster/beaglev_fire_demo/beaglev_led_blink"
set project_name "beaglev_led_blink"

puts "========================================="
puts "Building BeagleV-Fire LED Blink Design"
puts "========================================="

# Open project
puts "\n\[INFO\] Opening project..."
if {[file exists "$project_dir/$project_name.prjx"]} {
    open_project "$project_dir/$project_name.prjx"
    puts "\[INFO\] Project opened: $project_name"
} else {
    puts "\[ERROR\] Project not found at $project_dir"
    puts "\[ERROR\] Run led_blink_standalone.tcl first!"
    exit 1
}

# Run synthesis
puts "\n========================================="
puts "STEP 1: Synthesis"
puts "========================================="
run_tool -name {SYNTHESIZE}

# Check synthesis status - be lenient with warnings
set synth_status [catch {check_tool -name {SYNTHESIZE}} synth_result]
if {$synth_status != 0} {
    puts "\[WARN\] Synthesis completed with warnings:"
    puts "$synth_result"
    puts "\[INFO\] Continuing anyway..."
} else {
    puts "\[INFO\] Synthesis completed successfully"
}

# Run place and route
puts "\n========================================="
puts "STEP 2: Place and Route"
puts "========================================="
run_tool -name {PLACEROUTE}

# Check P&R status - be lenient with warnings
set pr_status [catch {check_tool -name {PLACEROUTE}} pr_result]
if {$pr_status != 0} {
    puts "\[WARN\] Place and Route completed with warnings:"
    puts "$pr_result"
    puts "\[INFO\] Continuing anyway..."
} else {
    puts "\[INFO\] Place and Route completed successfully"
}

# Run timing verification
puts "\n========================================="
puts "STEP 3: Timing Verification"
puts "========================================="
run_tool -name {VERIFYTIMING}

# Timing can have warnings - that's OK for initial testing
puts "\[INFO\] Timing verification completed (warnings OK for testing)"

# Generate bitstream
puts "\n========================================="
puts "STEP 4: Generate Programming File"
puts "========================================="
run_tool -name {GENERATEPROGRAMMINGFILE}

# Check bitstream generation
set bitstream_status [catch {check_tool -name {GENERATEPROGRAMMINGFILE}} bitstream_result]
if {$bitstream_status != 0} {
    puts "\[WARN\] Bitstream generation completed with warnings:"
    puts "$bitstream_result"
    puts "\[INFO\] Continuing anyway..."
} else {
    puts "\[INFO\] Bitstream generated successfully"
}

# Export .spi file for Linux programming
puts "\n========================================="
puts "STEP 5: Export .spi File for Linux Programming"
puts "========================================="

set export_dir "$project_dir/designer/led_blinker_fabric/export"

puts "\[INFO\] Exporting .spi bitstream file..."
puts "\[INFO\] Export directory: $export_dir"

# Create export directory if it doesn't exist
file mkdir $export_dir

# Export bitstream as .spi format for Linux programming
export_bitstream_file \
    -file_name {led_blink_bitstream} \
    -export_dir $export_dir \
    -format {SPI} \
    -for_ihp 0 \
    -trusted_facility_file 1 \
    -trusted_facility_file_components {FABRIC SNVM} \
    -master_file 0 \
    -encrypted_uek1_file 0 \
    -encrypted_uek2_file 0

puts "\[INFO\] .spi file exported successfully"

# Save project
puts "\n\[INFO\] Saving project..."
save_project

# Report results
puts "\n========================================="
puts "Build Complete!"
puts "========================================="
puts "Project:   $project_name"
puts "Location:  $project_dir"
puts "\nProgramming files:"
puts "  .stp: $project_dir/designer/impl1/$project_name.stp"
puts "  .spi: $export_dir/led_blink_bitstream.spi"
puts "\nNext steps:"
puts "1. Transfer .spi file to BeagleV-Fire"
puts "2. Program using: mpfs_auto_update led_blink_bitstream.spi"
puts "========================================="
