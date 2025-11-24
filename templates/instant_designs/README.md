# Instant FPGA - Design Templates

**Purpose:** Pre-configured design templates for the `create_instant_fpga.sh` one-command generator.

**Directory Structure:**
```
instant_designs/
├── led_blink/          # Simple LED counter/blinker
│   ├── hdl/
│   │   └── led_blinker.v
│   ├── constraint/
│   │   ├── io.pdc      # Pin assignments (board-specific portions generated)
│   │   └── timing.sdc  # Timing constraints
│   └── README.md
│
├── uart_echo/          # UART echo loopback
│   ├── hdl/
│   │   └── uart_echo.v
│   ├── constraint/
│   │   ├── io.pdc
│   │   └── timing.sdc
│   └── README.md
│
└── gpio_test/          # GPIO input/output test
    ├── hdl/
    │   └── gpio_test.v
    ├── constraint/
    │   ├── io.pdc
    │   └── timing.sdc
    └── README.md
```

## Template Requirements

Each design template must include:

1. **HDL Source** (`hdl/*.v` or `hdl/*.vhd`)
   - Self-contained (no external dependencies)
   - Parameterized where possible
   - Well-commented

2. **I/O Constraints** (`constraint/io.pdc`)
   - Pin assignments for supported boards
   - Use `# Board: <name>` comments to separate board-specific sections

3. **Timing Constraints** (`constraint/timing.sdc`)
   - Clock definitions
   - Input/output delays (if applicable)
   - Multicycle/false paths (if needed)

4. **README.md**
   - Design description
   - Resource estimate
   - Board compatibility
   - Expected behavior

## Supported Boards

- `mpf300_eval` - PolarFire MPF300 Evaluation Kit (FCG1152)
- `beaglev_fire` - BeagleV-Fire (MPFS025T, FCVG484)

## Adding New Designs

1. Create directory: `templates/instant_designs/<design_name>/`
2. Add HDL sources: `hdl/*.v`
3. Add constraints: `constraint/io.pdc`, `constraint/timing.sdc`
4. Add README.md with design info
5. Test with: `./create_instant_fpga.sh mpf300_eval <design_name>`
6. Update main script's design list

## Design Complexity Guidelines

**Simple (led_blink, gpio_test):**
- <100 LUTs
- Single clock domain
- Basic I/O only
- Build time: ~2 minutes

**Medium (uart_echo, spi_loopback):**
- 100-500 LUTs
- Single or dual clock domains
- Basic peripherals
- Build time: ~5 minutes

**Complex (ddr_test, pcie_example):**
- >500 LUTs
- Multiple clock domains
- IP core integration
- Build time: ~10-15 minutes

---

**Last Updated:** 2025-11-23
