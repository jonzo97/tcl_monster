# BeagleV-Fire LED Blink Programming Guide

**Goal:** Program custom LED blink design to BeagleV-Fire fabric and verify hardware operation

**Time Required:** ~10-15 minutes

---

## Prerequisites

- [x] LED blink bitstream built: `beaglev_fire_demo/beaglev_led_blink/designer/led_blinker_fabric/export/led_blink_bitstream.spi` (2.2MB)
- [ ] BeagleV-Fire connected via USB-C
- [ ] PowerShell serial terminal script: `C:\Temp\serial_smart.ps1`

---

## Step 1: Connect BeagleV-Fire

### Hardware Connections
1. **USB-C cable** to BeagleV-Fire (provides power + serial console)
2. Wait ~30 seconds for Linux to boot
3. Verify connection in Windows Device Manager:
   - COM port should appear (e.g., COM10)
   - Network adapter may appear (USB RNDIS/Ethernet)

### Verify Connection (Windows)
```powershell
# List COM ports
Get-WmiObject Win32_SerialPort | Select-Object DeviceID,Description

# Should show something like:
# DeviceID  Description
# --------  -----------
# COM10     USB Serial Device
```

---

## Step 2: Start Serial Terminal

### Option A: PowerShell Smart Terminal (Recommended)
```powershell
# From Windows PowerShell
cd C:\Temp
.\serial_smart.ps1
```

**Features:**
- Auto-login (username: beagle, password: temppwd)
- Command queue injection (for automation)
- Logs all output to `C:\Temp\beaglev_serial.log`

### Option B: Manual Connection
```powershell
# From WSL - check serial log
tail -f /mnt/c/Temp/beaglev_serial.log
```

Or use any serial terminal (PuTTY, Tera Term, etc.):
- **Port:** COM10 (or your detected port)
- **Baud:** 115200
- **Data:** 8N1
- **Flow Control:** None

### Login
```
BeagleV login: beagle
Password: temppwd
```

---

## Step 3: Transfer LED Blink Bitstream

### From WSL Terminal
```bash
cd /mnt/c/tcl_monster

# Copy bitstream to Windows Temp (for easy access)
cp beaglev_fire_demo/beaglev_led_blink/designer/led_blinker_fabric/export/led_blink_bitstream.spi /mnt/c/Temp/

# Transfer to BeagleV-Fire via scp
scp /mnt/c/Temp/led_blink_bitstream.spi beagle@192.168.7.2:/tmp/led_blink_bitstream.spi

# If USB networking not working, use serial file transfer (slower):
# base64 encode, send via serial, decode on board
```

### Alternative: Via Serial Console
If scp doesn't work (USB networking issues):

1. **On BeagleV-Fire serial console:**
   ```bash
   cd /tmp
   cat > led_blink_b64.txt
   # (paste base64 encoded file here - see below for encoding)
   # Press Ctrl+D when done

   base64 -d led_blink_b64.txt > led_blink_bitstream.spi
   ls -lh led_blink_bitstream.spi  # Should be ~2.2MB
   ```

2. **Encode file (from WSL):**
   ```bash
   base64 /mnt/c/Temp/led_blink_bitstream.spi > /mnt/c/Temp/led_blink_b64.txt
   # Copy contents and paste into serial terminal
   ```

---

## Step 4: Program FPGA Fabric

### Copy to Firmware Directory
```bash
# On BeagleV-Fire serial console
sudo cp /tmp/led_blink_bitstream.spi /lib/firmware/mpfs_bitstream.spi
sudo chown root:root /lib/firmware/mpfs_bitstream.spi
sudo chmod 644 /lib/firmware/mpfs_bitstream.spi

# Verify
ls -lh /lib/firmware/mpfs_bitstream.spi
```

### Run FPGA Programming Script
```bash
sudo /usr/share/microchip/gateware/update-gateware.sh
```

**Expected Output:**
```
================================================================================
|                            FPGA Gateware Update                              |
|                                                                              |
|   Please ensure that the mpfs_bitstream.spi file containing the gateware     |
|   update has been copied to directory /lib/firmware.                         |
|                                                                              |
|                 !!! This will take a couple of minutes. !!!                  |
|                                                                              |
|               Give the system a few minutes to reboot itself                 |
|                        after Linux has shutdown.                             |
|                                                                              |
================================================================================
Erased 65536 bytes from address 0x00000000 in flash
Writing mpfs_bitstream.spi to /dev/mtd0
Triggering FPGA Gateware Update (/sys/kernel/debug/fpga/microchip_exec_update)
```

### Wait for Reboot
- **Duration:** ~2-3 minutes
- Board will:
  1. Program FPGA fabric
  2. Shutdown Linux
  3. Reboot via Hart Software Services (HSS)
  4. Reload Linux with new FPGA configuration

---

## Step 5: Verify LED Blink

### Physical Verification
1. **Look at Cape Connector P8**
2. **Pin P8[3]** should have an LED connected (or probe with multimeter/scope)
3. **Expected:** 1 Hz blink (ON for 0.5s, OFF for 0.5s)

### Pin Location
- **Pin:** V22 (FPGA fabric pin)
- **Cape Connector:** P8[3]
- **Signal Name:** USER_LED_0

### If No LED Visible
**Option 1: Measure with Multimeter**
- Set to DC voltage mode
- Probe P8[3] (should toggle 0V → 3.3V at 1 Hz)

**Option 2: Measure with Oscilloscope**
- Probe P8[3]
- Should see 1 Hz square wave (3.3V amplitude)

**Option 3: Add External LED**
- LED + resistor (330Ω) from P8[3] to GND

---

## Step 6: Debugging (If LED Not Blinking)

### Check FPGA Programming Status
```bash
# After reboot, login again
ssh beagle@192.168.7.2

# Check FPGA manager status
cat /sys/class/fpga_manager/fpga0/state
# Expected: "operating" or "write complete"

cat /sys/class/fpga_manager/fpga0/status
# Expected: "0" (no errors)

# Check kernel messages
dmesg | grep -i 'fpga\|auto.*update' | tail -20
```

### Verify Bitstream Was Programmed
```bash
# Check /dev/mtd0 contents
sudo hexdump -C /dev/mtd0 | head -20
# Should show bitstream header (not all zeros)

# Check firmware file
ls -lh /lib/firmware/mpfs_bitstream.spi
# Should be ~2.2MB (not the old mpfs_dtbo.spi)
```

### Re-program If Needed
```bash
# Re-run programming script
sudo /usr/share/microchip/gateware/update-gateware.sh

# Or manually trigger update
sudo bash -c "echo 1 > /sys/kernel/debug/fpga/microchip_exec_update"
```

---

## Step 7: Record Demo Video

### What to Capture
1. **Before programming:**
   - Serial console showing programming command
   - Timestamp visible

2. **During programming:**
   - "Erased 65536 bytes..." message
   - "Writing mpfs_bitstream.spi..." message
   - "Triggering FPGA Gateware Update..." message

3. **After reboot:**
   - LED blinking on hardware
   - Close-up of P8[3] connector
   - Oscilloscope trace (if available)

4. **Proof of automation:**
   - Show the one-line command that triggered it
   - Show build reports (LUT count, timing)

### Video Length
- **Target:** 30-60 seconds
- **Format:** MP4 or MOV (for PowerPoint embedding)

### Recording Options
- **Phone camera:** Quick and easy
- **Screen recording + phone:** Show command + hardware simultaneously
- **OBS Studio:** Professional multi-source recording

---

## Automated Programming Script

For future use, create `/mnt/c/tcl_monster/scripts/program_beaglev_led_blink.sh`:

```bash
#!/bin/bash
# Automated BeagleV-Fire LED Blink Programming

set -e  # Exit on error

BITSTREAM="/mnt/c/tcl_monster/beaglev_fire_demo/beaglev_led_blink/designer/led_blinker_fabric/export/led_blink_bitstream.spi"
BEAGLE_IP="192.168.7.2"
BEAGLE_USER="beagle"

echo "=== BeagleV-Fire LED Blink Programming ==="
echo ""

# 1. Verify bitstream exists
if [ ! -f "$BITSTREAM" ]; then
    echo "ERROR: Bitstream not found: $BITSTREAM"
    exit 1
fi

echo "[1/4] Bitstream found: $(ls -lh "$BITSTREAM" | awk '{print $5}')"
echo ""

# 2. Copy to temp
echo "[2/4] Copying to Windows temp..."
cp "$BITSTREAM" /mnt/c/Temp/led_blink_bitstream.spi
echo "OK"
echo ""

# 3. Transfer to BeagleV-Fire
echo "[3/4] Transferring to BeagleV-Fire via scp..."
scp /mnt/c/Temp/led_blink_bitstream.spi ${BEAGLE_USER}@${BEAGLE_IP}:/tmp/
echo "OK"
echo ""

# 4. Program FPGA via serial command queue
echo "[4/4] Programming FPGA fabric..."
echo "sudo cp /tmp/led_blink_bitstream.spi /lib/firmware/mpfs_bitstream.spi && sudo /usr/share/microchip/gateware/update-gateware.sh" > /mnt/c/Temp/beaglev_cmd_queue.txt
echo ""
echo "Command queued for serial terminal."
echo "Board will reboot in ~2-3 minutes."
echo ""
echo "=== Programming Complete ==="
echo "1. Wait for board to reboot"
echo "2. Check LED on P8[3] (should blink at 1 Hz)"
echo "3. Record demo video!"
```

Make executable:
```bash
chmod +x /mnt/c/tcl_monster/scripts/program_beaglev_led_blink.sh
```

---

## Success Criteria

- [x] Bitstream built (2.2MB .spi file)
- [ ] BeagleV-Fire connected and accessible
- [ ] Bitstream transferred to board
- [ ] FPGA programmed successfully
- [ ] LED blinking at 1 Hz on P8[3]
- [ ] Demo video recorded (<1 min)

---

## Quick Reference

```bash
# Full workflow (one command)
./scripts/program_beaglev_led_blink.sh

# Manual steps
scp /mnt/c/Temp/led_blink_bitstream.spi beagle@192.168.7.2:/tmp/
ssh beagle@192.168.7.2
sudo cp /tmp/led_blink_bitstream.spi /lib/firmware/mpfs_bitstream.spi
sudo /usr/share/microchip/gateware/update-gateware.sh
# Wait ~2-3 min for reboot
# Verify LED on P8[3]
```

---

## Troubleshooting

**Problem:** scp fails (network unreachable)
- **Solution:** Use serial file transfer (base64 encode/decode)
- **Alternative:** Use USB mass storage mode (if supported)

**Problem:** LED not blinking after programming
- **Check:** /sys/class/fpga_manager/fpga0/state (should be "operating")
- **Check:** Pin assignment in PDC file (V22 = P8[3])
- **Check:** Bitstream actually programmed (hexdump /dev/mtd0)

**Problem:** Board won't reboot after programming
- **Solution:** Power cycle manually (unplug USB-C, wait 10s, replug)

---

**Last Updated:** 2025-11-23
**Status:** Ready to program
