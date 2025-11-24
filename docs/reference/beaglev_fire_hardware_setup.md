# BeagleV-Fire Hardware Setup & Embedded Development Guide

**Last Updated:** 2025-11-12
**Status:** Initial version - hardware verification and LED blink workflow
**Companion Guide:** `docs/beaglev_fire_guide.md` (FPGA/gateware development)

---

## Quick Start

**Goal:** Connect BeagleV-Fire board → Program reference design → Verify boot → Create LED blink demo

**Prerequisites:**
- BeagleV-Fire board
- USB-C cable (power + serial console)
- Computer with serial terminal (PuTTY, screen, minicom)
- Optional: FlashPro programmer, microSD card, Ethernet cable

**Time Estimate:** ~1 hour for initial setup and verification

---

## Table of Contents

1. [Hardware Setup & Connection](#hardware-setup--connection)
2. [Programming Reference Design](#programming-reference-design)
3. [Development Environment Setup](#development-environment-setup)
4. [LED Blink Demo Workflows](#led-blink-demo-workflows)
5. [Advanced Embedded Development](#advanced-embedded-development)
6. [Debugging & Troubleshooting](#debugging--troubleshooting)

---

## Hardware Setup & Connection

### Required Hardware

**Essential:**
- **BeagleV-Fire board** (MPFS025T PolarFire SoC)
- **USB-C cable** (power + USB-UART bridge)
- **Computer** (Windows/Linux/Mac with serial terminal)

**Optional:**
- **FlashPro programmer** (for JTAG programming and debugging)
- **microSD card** (4GB+ for Linux boot)
- **Ethernet cable** (for network access when running Linux)
- **M.2 E-Key Wi-Fi card** (if using default gateware with M.2 support)
- **BeagleBone capes** (robotics, comms, click boards, etc.)

### Physical Connections

#### Power Options

BeagleV-Fire can be powered via:

1. **USB-C (Recommended for initial testing)**
   - Connect USB-C cable from computer to BeagleV-Fire USB-C port
   - Provides power (USB-PD negotiation for 5V) + USB-UART bridge
   - UART console automatically available on host computer

2. **Barrel Jack (5V, 2A+)**
   - Use if USB-C power insufficient or not available
   - Separate USB-UART connection needed for console

#### UART Console Connection

**Via USB-C (Built-in USB-UART Bridge):**
1. Connect USB-C cable from computer to BeagleV-Fire
2. Board enumerates as USB serial device:
   - **Linux:** `/dev/ttyUSB0` or `/dev/ttyACM0`
   - **Windows:** `COM3`, `COM4`, etc. (check Device Manager)
   - **Mac:** `/dev/tty.usbserial-*`

3. **Serial Terminal Settings:**
   - **Baud rate:** 115200
   - **Data bits:** 8
   - **Stop bits:** 1
   - **Parity:** None
   - **Flow control:** None

**Connect with:**
```bash
# Linux - using screen
screen /dev/ttyUSB0 115200

# Linux - using minicom
minicom -D /dev/ttyUSB0 -b 115200

# Windows - using PuTTY
# Open PuTTY → Serial → COM port → Speed 115200 → Open

# Mac - using screen
screen /dev/tty.usbserial-* 115200
```

**Via External USB-UART Adapter (if barrel jack power):**
- Connect adapter to UART header on BeagleV-Fire
- **TX (adapter) → RX (board)**
- **RX (adapter) → TX (board)**
- **GND → GND**
- Same serial settings (115200 8N1)

#### Boot Mode Selection

BeagleV-Fire has boot mode switches/jumpers to select boot source:

**Boot Sources:**
1. **eNVM (embedded Non-Volatile Memory)** - Default, contains HSS bootloader
2. **SPI Flash** - External SPI flash (128Mbit on board)
3. **SD Card** - microSD slot
4. **eMMC** - Onboard 16GB eMMC
5. **JTAG** - Direct programming via FlashPro

**Typical Boot Sequence:**
1. **Power on** → MSS boots from eNVM (Hart Software Services - HSS bootloader)
2. **HSS loads** → Reads configuration, initializes MSS peripherals, DDR
3. **HSS chains** → Loads payload from SPI flash, SD card, or eMMC
4. **Payload runs** → Bare-metal application or Linux kernel

**Check boot mode switches** (refer to BeagleV-Fire schematic for exact locations)

#### Optional Connections

**FlashPro Programmer (for JTAG):**
- Connect FlashPro to JTAG header on BeagleV-Fire
- Enables FPGA programming, MSS debugging (GDB + OpenOCD), software loading
- **Critical for development:** Allows single-step debug of embedded code

**Ethernet:**
- Connect Ethernet cable to RJ45 port
- Provides network access when running Linux
- 2x Gigabit Ethernet controllers (GEM0, GEM1 in MSS)

**M.2 E-Key Wi-Fi Card:**
- Insert M.2 Wi-Fi module into socket (if using default or M.2-enabled gateware)
- Requires PCIe support in FPGA fabric
- Check `beaglev-fire-gateware/build-options/default.yaml` includes M.2

---

## Programming Reference Design

### Overview

BeagleV-Fire requires two components to boot:
1. **FPGA bitstream** - Programs the FPGA fabric + configures MSS
2. **HSS bootloader** - Stored in eNVM, initializes MSS and loads payload

**Three approaches:**

### Option A: Pre-built Bitstream (Fastest - Verify Hardware)

**Goal:** Quick hardware verification with official release.

**Steps:**

1. **Download pre-built bitstream:**
   ```bash
   # From BeagleBoard.org releases
   wget https://files.beagleboard.org/file/beagleboard-public-2021/images/beaglev-fire-gateware-[version].zip
   unzip beaglev-fire-gateware-[version].zip
   ```

2. **Program via FlashPro (if available):**
   ```bash
   # Using FlashPro command-line tool
   flashpro -file beaglev_fire_gateware.stp
   ```

3. **Program via Linux (if already running Linux on board):**
   ```bash
   # Copy bitstream to BeagleV-Fire
   scp beaglev_fire_gateware.stp root@beaglev-fire.local:/tmp/

   # SSH into board
   ssh root@beaglev-fire.local

   # Program FPGA (requires mpfs-fpga-utils)
   fpgautil -b /tmp/beaglev_fire_gateware.stp
   ```

4. **Verify boot:**
   - Open serial console (115200 baud)
   - Power cycle board or press reset
   - **Expected output:**
     ```
     HSS: Hart Software Services Boot
     HSS: Initializing DDR...
     HSS: Booting from eMMC...
     ```

### Option B: Build from Source (Python Builder)

**Goal:** Build custom configuration using official BeagleBoard.org Python builder.

**Prerequisites:**
- Python 3.x with `gitpython` and `pyyaml`
- Libero SoC v2024.2 installed
- SoftConsole (for HSS compilation)
- Environment variables set

**Environment Setup:**
```bash
# Set Microchip tool paths
export LIBERO_INSTALL_DIR="/mnt/c/Microchip/Libero_SoC_v2024.2"
export SC_INSTALL_DIR="/mnt/c/Microchip/SoftConsole-*"
export FPGENPROG="$LIBERO_INSTALL_DIR/Designer/bin/fpgenprog"
export LM_LICENSE_FILE="1702@your-license-server"  # Or path to license.dat

# Install Python dependencies
pip3 install gitpython pyyaml
```

**Build Steps:**
```bash
cd /mnt/c/tcl_monster/beaglev-fire-gateware

# Choose configuration (see build-options/)
# default.yaml       - Full design with cape + M.2 Wi-Fi
# minimal.yaml       - Linux only, no FPGA fabric
# picorv-apu.yaml    - Adds PicoRV32 RISC-V soft core
# robotics.yaml      - Robotics cape support

# Build
python3 build-bitstream.py ./build-options/default.yaml

# Wait ~30-45 minutes for complete build
# Output: bitstream/FlashProExpress/*.stp
```

**Program:**
```bash
# Using FlashPro
flashpro -file bitstream/FlashProExpress/BVF_GATEWARE.stp

# Or copy to board and program via Linux (if already running)
scp bitstream/FlashProExpress/BVF_GATEWARE.stp root@beaglev-fire.local:/tmp/
ssh root@beaglev-fire.local "fpgautil -b /tmp/BVF_GATEWARE.stp"
```

### Option C: tcl_monster Integration (Phase 2+)

**Goal:** Lightweight TCL-only build without Python dependencies.

**Status:** Phase 1 complete, Phase 2 in progress.

**Planned workflow:**
```bash
cd /mnt/c/tcl_monster

# Create project with variant from config/beaglev_fire_variants.json
./run_libero.sh tcl_scripts/beaglev_fire/create_bvf_project.tcl SCRIPT VARIANT:default

# Build
./run_libero.sh tcl_scripts/beaglev_fire/build_bvf_project.tcl SCRIPT

# Program
# (FlashPro or Linux-based programming)
```

**See:** `docs/beaglev_fire_guide.md` for Phase 2 status and plans.

---

## Development Environment Setup

### Overview

BeagleV-Fire supports multiple development approaches:

1. **Bare-metal C/C++** - Direct hardware access, minimal overhead
2. **FreeRTOS** - Real-time OS for embedded applications
3. **Linux userspace** - Applications on Linux (boot from eMMC/SD)

### SoftConsole IDE (Recommended for MSS Development)

**What it is:** Eclipse-based IDE with RISC-V GCC toolchain and debugging support.

**Installation:**
```bash
# Download from Microchip website
# https://www.microchip.com/softconsole

# Install (Windows or Linux)
# Windows: C:\Microchip\SoftConsole-*
# Linux: /opt/microsemi/softconsole

# Set path
export SC_INSTALL_DIR="/mnt/c/Microchip/SoftConsole-v2024.2"
export PATH="$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin:$PATH"
```

**Create New Project:**
1. Open SoftConsole
2. File → New → C Project
3. Select "PolarFire SoC Bare Metal" template
4. Choose board: BeagleV-Fire or MPFS Icicle Kit (similar)
5. Project includes: startup code, linker scripts, HSS integration

**Debugging:**
- Connect FlashPro to BeagleV-Fire JTAG header
- SoftConsole → Debug → Debug Configurations → OpenOCD
- Set breakpoints, single-step, inspect registers/memory

### Bare-Metal Toolchain (Command-Line)

**RISC-V GCC Cross-Compiler:**
```bash
# Using SoftConsole toolchain
export PATH="/mnt/c/Microchip/SoftConsole-v2024.2/riscv-unknown-elf-gcc/bin:$PATH"

# Test
riscv64-unknown-elf-gcc --version
# Should show: riscv64-unknown-elf-gcc (GCC) 10.2.0 or similar
```

**Minimal Bare-Metal Project Structure:**
```
my_project/
├── src/
│   ├── main.c              # Application code
│   ├── startup.S           # RISC-V startup (from SoftConsole)
│   └── system_init.c       # MSS peripheral init
├── include/
│   └── mss_gpio.h          # MSS peripheral headers
├── linker/
│   └── mpfs-lim.ld         # Linker script (LIM memory)
├── Makefile
└── README.md
```

**Example Makefile:**
```makefile
CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
CFLAGS = -march=rv64imac -mabi=lp64 -mcmodel=medany -O2
LDFLAGS = -T linker/mpfs-lim.ld -nostartfiles

SRCS = src/main.c src/startup.S src/system_init.c
OBJS = $(SRCS:.c=.o)

all: firmware.hex

firmware.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

firmware.hex: firmware.elf
	$(OBJCOPY) -O ihex $< $@

clean:
	rm -f $(OBJS) firmware.elf firmware.hex
```

### Linux Userspace Development

**Prerequisites:**
- BeagleV-Fire running Linux (booted from eMMC or SD card)
- Network access (Ethernet or Wi-Fi) for SSH

**Cross-Compilation:**
```bash
# RISC-V Linux cross-compiler
# Option 1: Use Buildroot/Yocto from BeagleBoard.org
# Option 2: Install prebuilt toolchain

# Debian/Ubuntu:
sudo apt install gcc-riscv64-linux-gnu

# Test
riscv64-linux-gnu-gcc --version
```

**Example: LED Blink via sysfs GPIO**
```bash
# SSH into BeagleV-Fire
ssh root@beaglev-fire.local

# Export GPIO (example: GPIO 4)
echo 4 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio4/direction

# Blink LED
while true; do
    echo 1 > /sys/class/gpio/gpio4/value
    sleep 0.5
    echo 0 > /sys/class/gpio/gpio4/value
    sleep 0.5
done
```

---

## LED Blink Demo Workflows

### Goal

Create a simple LED blink application to verify:
- FPGA bitstream programmed correctly
- MSS RISC-V cores running
- GPIO peripheral functional
- Development toolchain working

### User LEDs on BeagleV-Fire

**Hardware:**
- BeagleV-Fire has user-controllable LEDs connected to:
  - **Option 1:** MSS GPIO (microprocessor subsystem)
  - **Option 2:** FPGA fabric GPIO (if custom design)

**Check schematics** or reference design for exact LED connections.

**Reference design:** `beaglev-fire-gateware/sources/FPGA-design/script_support/components/BVF_RISCV_SUBSYSTEM/` defines user LED connections.

---

### Path 1: Bare-Metal LED Blink (MSS GPIO)

**Best for:** Learning bare-metal embedded programming, direct hardware access.

**Steps:**

#### 1. Create Project in SoftConsole

```c
// File: src/main.c
#include <stdint.h>
#include "mss_gpio.h"

#define LED_GPIO MSS_GPIO_4  // Example: LED on GPIO 4

void delay_ms(uint32_t ms) {
    // Approximate delay (depends on CPU frequency)
    for (volatile uint32_t i = 0; i < ms * 10000; i++);
}

int main(void) {
    // Initialize MSS GPIO
    MSS_GPIO_init();

    // Configure LED GPIO as output
    MSS_GPIO_config(LED_GPIO, MSS_GPIO_OUTPUT_MODE);

    // Blink loop
    while (1) {
        MSS_GPIO_set_output(LED_GPIO, 1);  // LED ON
        delay_ms(500);

        MSS_GPIO_set_output(LED_GPIO, 0);  // LED OFF
        delay_ms(500);
    }

    return 0;
}
```

#### 2. Build
```bash
cd my_led_project
make
# Output: firmware.hex
```

#### 3. Load to Board

**Via JTAG (FlashPro + OpenOCD):**
```bash
# Start OpenOCD
openocd -f board/microsemi-riscv.cfg

# In another terminal, use GDB
riscv64-unknown-elf-gdb firmware.elf
(gdb) target remote :3333
(gdb) load
(gdb) continue
```

**Via HSS (eMMC/SD boot):**
- Convert `.hex` to HSS payload format
- Copy to boot partition on eMMC/SD
- HSS loads and runs on boot

#### 4. Verify
- LED should blink at 1 Hz (500ms on, 500ms off)
- Use serial console to print debug messages (optional)

---

### Path 2: Modify Reference Design (HSS or Payload)

**Best for:** Quick prototyping with existing gateware.

**Steps:**

1. **Modify HSS bootloader source** (add LED blink to initialization):
   ```c
   // In HSS source: init/hss_main.c
   while (1) {
       mss_gpio_set_output(LED_GPIO, 1);
       delay(500);
       mss_gpio_set_output(LED_GPIO, 0);
       delay(500);
   }
   ```

2. **Rebuild HSS:**
   ```bash
   cd hart-software-services
   make BOARD=beaglev-fire
   # Output: hss.hex
   ```

3. **Reprogram eNVM:**
   - Use Libero to import updated `hss.hex` into eNVM
   - Regenerate programming file
   - Program board

4. **Reboot and verify**

---

### Path 3: Linux Userspace LED Blink

**Best for:** Quick testing without toolchain setup.

**Prerequisites:** BeagleV-Fire running Linux

**Steps:**

1. **SSH into board:**
   ```bash
   ssh root@beaglev-fire.local
   ```

2. **Export GPIO:**
   ```bash
   # Find LED GPIO number (check device tree or schematics)
   # Example: GPIO 4
   echo 4 > /sys/class/gpio/export
   echo out > /sys/class/gpio/gpio4/direction
   ```

3. **Blink LED (bash):**
   ```bash
   while true; do
       echo 1 > /sys/class/gpio/gpio4/value
       sleep 0.5
       echo 0 > /sys/class/gpio/gpio4/value
       sleep 0.5
   done
   ```

4. **Or Python script:**
   ```python
   import time
   import os

   GPIO_NUM = 4
   GPIO_PATH = f"/sys/class/gpio/gpio{GPIO_NUM}"

   # Export GPIO
   with open("/sys/class/gpio/export", "w") as f:
       f.write(str(GPIO_NUM))

   # Set direction
   with open(f"{GPIO_PATH}/direction", "w") as f:
       f.write("out")

   # Blink loop
   try:
       while True:
           with open(f"{GPIO_PATH}/value", "w") as f:
               f.write("1")
           time.sleep(0.5)

           with open(f"{GPIO_PATH}/value", "w") as f:
               f.write("0")
           time.sleep(0.5)
   except KeyboardInterrupt:
       # Cleanup
       with open("/sys/class/gpio/unexport", "w") as f:
           f.write(str(GPIO_NUM))
   ```

---

### Path 4: FPGA Fabric GPIO (Custom Design)

**Best for:** Learning FPGA fabric integration with MSS.

**Steps:**

1. **Create FPGA GPIO component** (Verilog):
   ```verilog
   // File: hdl/beaglev_fire/gpio_led_blinker.v
   module gpio_led_blinker (
       input wire clk,          // 50 MHz clock
       input wire rst_n,
       output reg led
   );

   reg [24:0] counter;

   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           counter <= 0;
           led <= 0;
       end else begin
           counter <= counter + 1;
           if (counter == 25_000_000) begin  // 0.5 second at 50 MHz
               led <= ~led;
               counter <= 0;
           end
       end
   end

   endmodule
   ```

2. **Integrate into SmartDesign:**
   - Add module to FPGA fabric
   - Connect `clk` to MSS FIC (Fabric Interface Controller) clock
   - Connect `rst_n` to system reset
   - Connect `led` output to top-level pin constraint

3. **Add pin constraint** (PDC file):
   ```tcl
   # File: constraint/led_blinker.pdc
   set_io led -pinname AA12 -fixed yes -DIRECTION OUTPUT
   ```

4. **Build with tcl_monster:**
   ```bash
   ./run_libero.sh tcl_scripts/beaglev_fire/create_bvf_project.tcl SCRIPT VARIANT:custom_fabric
   ./run_libero.sh tcl_scripts/beaglev_fire/build_bvf_project.tcl SCRIPT
   ```

5. **Program and verify**

---

## Advanced Embedded Development

### Peripheral Examples

Once LED blink is working, expand to other peripherals:

#### UART Serial Communication

**Use case:** Printf debugging, command interface

**Example:**
```c
#include "mss_uart.h"

int main(void) {
    MSS_UART_init(&g_mss_uart0_lo,
                  MSS_UART_115200_BAUD,
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY);

    MSS_UART_polled_tx_string(&g_mss_uart0_lo, "Hello from BeagleV-Fire!\n");

    while (1) {
        // Application logic
    }
}
```

#### Timers and Interrupts

**Use case:** Precise timing, non-blocking delays

**Example:**
```c
#include "mss_timer.h"

void timer_irq_handler(void) {
    // Toggle LED
    static uint8_t led_state = 0;
    MSS_GPIO_set_output(LED_GPIO, led_state);
    led_state = !led_state;
}

int main(void) {
    MSS_TIM1_init(MSS_TIMER_PERIODIC_MODE);
    MSS_TIM1_load_immediate(100000);  // 1 Hz at 100 MHz PCLK
    MSS_TIM1_enable_irq();
    MSS_TIM1_start();

    while (1) {
        // Main loop - timer interrupt handles LED
    }
}
```

#### I2C Sensor Interfacing

**Use case:** Temperature sensors, accelerometers, etc.

**Example:**
```c
#include "mss_i2c.h"

#define SENSOR_ADDR 0x48

uint8_t read_temperature(void) {
    uint8_t tx_buf[1] = {0x00};  // Temperature register
    uint8_t rx_buf[2];

    MSS_I2C_write(&g_mss_i2c0, SENSOR_ADDR, tx_buf, 1, MSS_I2C_RELEASE_BUS);
    MSS_I2C_read(&g_mss_i2c0, SENSOR_ADDR, rx_buf, 2, MSS_I2C_RELEASE_BUS);

    return (rx_buf[0] << 4) | (rx_buf[1] >> 4);  // 12-bit temp
}
```

#### SPI Flash / SD Card

**Use case:** Data logging, firmware updates

**Example:**
```c
#include "mss_spi.h"

void spi_flash_read(uint32_t address, uint8_t *buffer, uint32_t length) {
    uint8_t cmd[4] = {0x03, (address >> 16), (address >> 8), address};

    MSS_SPI_set_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
    MSS_SPI_transfer_block(&g_mss_spi0, cmd, 4, buffer, length);
    MSS_SPI_clear_slave_select(&g_mss_spi0, MSS_SPI_SLAVE_0);
}
```

#### Ethernet (GEM)

**Use case:** Network communication, remote control

**Example:** Use `lwIP` TCP/IP stack with MSS GEM driver.

### FreeRTOS Integration

**Steps:**
1. Download FreeRTOS for RISC-V
2. Configure `FreeRTOSConfig.h` for PolarFire SoC (625 MHz, 5 harts)
3. Create tasks for LED blink, UART, etc.
4. Build and run

**Example:**
```c
#include "FreeRTOS.h"
#include "task.h"

void vLEDTask(void *pvParameters) {
    while (1) {
        MSS_GPIO_set_output(LED_GPIO, 1);
        vTaskDelay(pdMS_TO_TICKS(500));
        MSS_GPIO_set_output(LED_GPIO, 0);
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

int main(void) {
    xTaskCreate(vLEDTask, "LED", 128, NULL, 1, NULL);
    vTaskStartScheduler();
    while (1);  // Should never reach
}
```

---

## Debugging & Troubleshooting

### UART Console Not Responding

**Symptoms:**
- No output on serial console after power-on
- Garbled characters

**Checks:**
1. **Serial settings:** 115200 baud, 8N1, no flow control
2. **USB-C connection:** Try different USB port or cable
3. **Device enumeration:** Check `/dev/ttyUSB*` (Linux) or Device Manager (Windows)
4. **Permissions:** `sudo chmod 666 /dev/ttyUSB0` (Linux)
5. **Boot mode:** Verify eNVM boot mode selected

### Boot Failures

**Symptoms:**
- No HSS output on console
- Board appears dead

**Checks:**
1. **Power:** Verify 5V power LED on
2. **eNVM programmed:** HSS bootloader must be in eNVM
3. **FPGA programmed:** Bitstream must be loaded
4. **Boot switches:** Verify correct boot mode
5. **JTAG programming:** Use FlashPro to verify eNVM contents

**Debug:**
```bash
# Use FlashPro to read eNVM
flashpro -read_envm -file envm_dump.hex

# Check if HSS present (non-zero, structured data)
hexdump -C envm_dump.hex | head
```

### Programming Failures

**FlashPro errors:**
- **"Device not found":** Check JTAG connection, power, cable
- **"Programming failed":** Try lower JTAG frequency, check voltage levels
- **"Verify failed":** May need to erase before programming

**Linux fpgautil errors:**
- **"Permission denied":** Run as root or add user to `fpga` group
- **"FPGA busy":** Another process using FPGA, reboot board

### Software Debug (GDB + OpenOCD)

**Setup:**
1. Connect FlashPro to BeagleV-Fire JTAG
2. Start OpenOCD:
   ```bash
   openocd -f board/microsemi-riscv.cfg
   ```

3. Connect GDB:
   ```bash
   riscv64-unknown-elf-gdb firmware.elf
   (gdb) target remote :3333
   (gdb) load
   (gdb) break main
   (gdb) continue
   ```

4. **Debug commands:**
   - `step` - Single-step
   - `next` - Step over function calls
   - `print variable` - Inspect variables
   - `info registers` - View CPU registers
   - `x/16x 0x80000000` - Examine memory

### Timing Violations in Custom Designs

**Symptoms:**
- Design works in simulation but fails on hardware
- Intermittent behavior, data corruption

**Solutions:**
1. **Run timing analysis:**
   ```bash
   # In Libero, after place & route
   run_tool -name {VERIFYTIMING}
   ```

2. **Check timing report:**
   - Look for negative slack
   - Identify critical paths

3. **Fixes:**
   - Add register stages (pipelining)
   - Reduce clock frequency
   - Constrain paths with SDC
   - Use faster speed grade (if available)

4. **Use Build Doctor:**
   ```bash
   python tools/diagnostics/build_doctor.py libero_projects/beaglev_fire/designer/*/
   ```

---

## Next Steps

Once LED blink is working:

### Near-term (1-2 sessions)
- **UART printf debugging** - Add console output
- **Button input** - Read GPIO input, debounce
- **PWM LED dimming** - Variable brightness
- **Temperature sensor** - I2C interfacing
- **Simple state machine** - Button-controlled LED patterns

### Medium-term (3-5 sessions)
- **FreeRTOS multitasking** - Multiple concurrent tasks
- **Ethernet connectivity** - lwIP TCP/IP stack
- **SD card data logging** - SPI/SDIO interface
- **RISC-V interrupt handling** - PLIC (Platform-Level Interrupt Controller)
- **Multi-hart programming** - Use all 5 RISC-V cores

### Long-term (10+ sessions)
- **Linux kernel module** - Custom device driver
- **FPGA accelerator** - Offload computation to fabric
- **AMP (Asymmetric Multiprocessing)** - Linux on U54, bare-metal on E51
- **Custom PCIe peripheral** - Use M.2 socket for custom hardware
- **BeagleBone cape development** - Custom cape with sensors/actuators

---

## Resources

**Official Documentation:**
- BeagleV-Fire: https://www.beagleboard.org/boards/beaglev-fire
- PolarFire SoC: https://www.microchip.com/design-centers/fpga-soc/fpga/polarfire-soc
- HSS (Hart Software Services): https://github.com/polarfire-soc/hart-software-services
- SoftConsole IDE: https://www.microchip.com/softconsole

**Development Resources:**
- PolarFire SoC Bare Metal Library: https://github.com/polarfire-soc/polarfire-soc-bare-metal-library
- PolarFire SoC Examples: https://mi-v-ecosystem.github.io/redirects/repo-polarfire-soc-bare-metal-examples
- Yocto/Linux BSP: https://github.com/beagleboard/meta-beaglev-fire

**Companion Guides:**
- `docs/beaglev_fire_guide.md` - FPGA/gateware development (Phase 1 complete)
- `docs/ROADMAP.md` - Overall tcl_monster development plan
- `PROJECT_STATE.json` - Current project status

---

**Document Version:** 1.0
**Created:** 2025-11-12
**Last Updated:** 2025-11-12
