# BeagleV-Fire Libero Projects

This directory contains working Libero projects for BeagleV-Fire development.

## Purpose

Generated Libero projects created by tcl_monster automation scripts. Each subdirectory represents a specific design variant (e.g., custom cape configuration, APU selection, fabric modifications).

## Usage

Projects are created by:
```bash
cd /mnt/c/tcl_monster
./run_libero.sh tcl_scripts/beaglev_fire/create_project.tcl SCRIPT
```

## Structure

Each project subdirectory contains:
- `.prjx` - Libero project file
- `designer/` - Design implementation and synthesis results
- `hdl/` - HDL sources (imported from `../../hdl/beaglev_fire/`)
- `component/` - SmartDesign components
- `constraint/` - I/O and timing constraints
- `synthesis/` - Synthesis results
- `simulation/` - ModelSim/QuestaSim testbenches

## Design Variants

See `config/beaglev_fire_variants.json` for available design configurations.
