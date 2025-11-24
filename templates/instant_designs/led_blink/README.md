# LED Blinker - Instant FPGA Template

**Design:** Simple rotating LED pattern (binary counter visualization)
**Complexity:** Simple (~50 LUTs, ~40 FFs)
**Build Time:** ~2 minutes

---

## Description

Creates a rotating LED pattern that updates at 1 Hz. LEDs display a rotating "walking one" pattern:
- `00000001` → `00000010` → `00000100` → ... → `10000000` → `00000001`

Perfect for:
- Verifying FPGA programming
- Testing LED connections
- Quick board bring-up
- Learning basic Verilog

---

## Supported Boards

### ✅ PolarFire MPF300 Evaluation Kit (`mpf300_eval`)
- **Device:** MPF300TS-1FCG1152
- **Clock:** 50 MHz oscillator (H12)
- **Reset:** Push button (K14)
- **LEDs:** 8x on-board LEDs (N20-M14)

### ✅ BeagleV-Fire (`beaglev_fire`)
- **Device:** MPFS025T-FCVG484
- **Clock:** Cape P9[19] - 50 MHz (A10)
- **Reset:** Cape P9[20] - Active-low (A11)
- **LEDs:** Cape P8[3-10] (V22, W21, Y22, Y21, U19, V19, Y20, AA20)

---

## Resource Utilization

| Resource       | Used  | Available | Utilization |
|----------------|-------|-----------|-------------|
| LUTs           | ~48   | 299,544   | <0.02%      |
| Flip-Flops     | ~40   | 299,544   | <0.02%      |
| I/O Pins       | 10    | 696       | 1.4%        |

**Clock Domain:** Single (50 MHz)
**Timing:** Easily meets 50 MHz timing (20ns period)

---

## Usage

### Quick Start
```bash
# MPF300 Eval Kit
./create_instant_fpga.sh mpf300_eval led_blink

# BeagleV-Fire
./create_instant_fpga.sh beaglev_fire led_blink
```

### Expected Behavior
- LEDs rotate in a "walking one" pattern
- Update rate: 1 Hz (visible to human eye)
- Pattern repeats continuously
- Reset returns to initial state (`00000001`)

---

## Implementation Details

**Clock Divider:**
- Input: 50 MHz clock
- Output: 1 Hz LED update
- Divider ratio: 50,000,000:1
- Counter size: 32 bits

**LED Pattern:**
- 8-bit shift register
- Rotates left on each update
- Initial pattern: `8'b00000001`

---

## Testing

### On Hardware
1. Program FPGA with generated bitstream
2. Observe 8 LEDs
3. Should see rotating pattern at 1 Hz
4. Press reset button - pattern restarts

### Simulation (Optional)
```tcl
# ModelSim/QuestaSim
vlog hdl/led_blinker.v
vsim -c led_blinker
run 100ns
```

---

## Customization

### Change LED Update Rate
Edit `hdl/led_blinker.v`:
```verilog
parameter LED_FREQ = 2;  // Change to 2 Hz (faster)
parameter LED_FREQ = 0.5;  // Change to 0.5 Hz (slower)
```

### Different LED Pattern
Modify the rotation logic:
```verilog
// Binary counter instead of rotating pattern
led_pattern <= led_pattern + 1'b1;
```

---

## Files

- `hdl/led_blinker.v` - Main Verilog source
- `constraint/io.pdc` - Pin assignments
- `constraint/timing.sdc` - Timing constraints

---

**Created:** 2025-11-23
**Status:** ✅ Tested and working
**Boards:** mpf300_eval, beaglev_fire
