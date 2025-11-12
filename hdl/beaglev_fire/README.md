# BeagleV-Fire Custom HDL Sources

This directory contains custom HDL modules specific to BeagleV-Fire designs.

## Purpose

Verilog/VHDL source files for:
- Custom FPGA fabric logic
- Peripheral interfaces
- Cape connector logic
- Custom SmartDesign components

## Organization

```
hdl/beaglev_fire/
├── cape_interfaces/       # Cape connector HDL (P8/P9 headers)
├── peripherals/           # Custom peripherals (UART, SPI, GPIO, etc.)
├── accelerators/          # Hardware accelerators (SmartHLS, custom)
├── top_level/             # Top-level wrapper modules
└── testbenches/           # Simulation testbenches
```

## Integration

HDL sources are imported into Libero projects via TCL scripts:
```tcl
import_files -hdl_source "./hdl/beaglev_fire/my_module.v"
```

## Reference HDL

See `beaglev-fire-gateware/sources/FPGA-design/script_support/components/` for reference implementations from the official BeagleBoard.org design.
