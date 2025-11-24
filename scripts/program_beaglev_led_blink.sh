#!/bin/bash
# Automated BeagleV-Fire LED Blink Programming
# Usage: ./scripts/program_beaglev_led_blink.sh

set -e  # Exit on error

BITSTREAM="/mnt/c/tcl_monster/beaglev_fire_demo/beaglev_led_blink/designer/led_blinker_fabric/export/led_blink_bitstream.spi"
BEAGLE_IP="192.168.7.2"
BEAGLE_USER="beagle"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║     BeagleV-Fire LED Blink Programming - Automated Workflow        ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# 1. Verify bitstream exists
if [ ! -f "$BITSTREAM" ]; then
    echo "❌ ERROR: Bitstream not found: $BITSTREAM"
    echo ""
    echo "Build it first with:"
    echo "  ./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT"
    echo "  ./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT"
    exit 1
fi

BITSTREAM_SIZE=$(ls -lh "$BITSTREAM" | awk '{print $5}')
echo "[1/5] ✓ Bitstream found: $BITSTREAM_SIZE"
echo ""

# 2. Copy to temp
echo "[2/5] Copying to Windows temp directory..."
cp "$BITSTREAM" /mnt/c/Temp/led_blink_bitstream.spi
echo "      ✓ Copied to C:\\Temp\\led_blink_bitstream.spi"
echo ""

# 3. Check if BeagleV-Fire is reachable
echo "[3/5] Checking BeagleV-Fire connection..."
if ping -c 1 -W 2 $BEAGLE_IP >/dev/null 2>&1; then
    echo "      ✓ BeagleV-Fire reachable at $BEAGLE_IP"
    echo ""

    # 4. Transfer via scp
    echo "[4/5] Transferring bitstream to BeagleV-Fire via scp..."
    scp -o ConnectTimeout=5 /mnt/c/Temp/led_blink_bitstream.spi ${BEAGLE_USER}@${BEAGLE_IP}:/tmp/ 2>&1 | grep -v "Warning: Permanently added"
    echo "      ✓ Transfer complete"
    echo ""

    # 5. Program via SSH
    echo "[5/5] Programming FPGA fabric..."
    echo "      (This will take ~2-3 minutes and board will reboot)"
    echo ""

    ssh -o ConnectTimeout=5 ${BEAGLE_USER}@${BEAGLE_IP} "sudo cp /tmp/led_blink_bitstream.spi /lib/firmware/mpfs_bitstream.spi && sudo /usr/share/microchip/gateware/update-gateware.sh" 2>&1 | head -20

    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    Programming Complete!                           ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Wait ~2-3 minutes for board to reboot"
    echo "  2. Check LED on cape connector P8[3]"
    echo "  3. Expected: 1 Hz blink (ON 0.5s, OFF 0.5s)"
    echo "  4. Record demo video!"
    echo ""

else
    echo "      ⚠ BeagleV-Fire not reachable at $BEAGLE_IP"
    echo ""
    echo "Alternative: Use serial command queue method"
    echo ""

    # 4. Prepare serial command queue
    echo "[4/5] Preparing serial command queue..."
    SERIAL_CMD="sudo cp /tmp/led_blink_bitstream.spi /lib/firmware/mpfs_bitstream.spi && sudo /usr/share/microchip/gateware/update-gateware.sh"
    echo "$SERIAL_CMD" > /mnt/c/Temp/beaglev_cmd_queue.txt
    echo "      ✓ Command queued: C:\\Temp\\beaglev_cmd_queue.txt"
    echo ""

    # 5. Instructions for manual transfer
    echo "[5/5] Manual steps required:"
    echo ""
    echo "  Option A - Serial File Transfer:"
    echo "    1. Encode bitstream:"
    echo "       base64 /mnt/c/Temp/led_blink_bitstream.spi > /mnt/c/Temp/led_blink_b64.txt"
    echo ""
    echo "    2. On BeagleV-Fire serial console:"
    echo "       cd /tmp"
    echo "       cat > led_blink_b64.txt"
    echo "       <paste contents of led_blink_b64.txt>"
    echo "       <press Ctrl+D>"
    echo "       base64 -d led_blink_b64.txt > led_blink_bitstream.spi"
    echo ""
    echo "    3. Start PowerShell serial terminal (will auto-execute queued command):"
    echo "       C:\\Temp\\serial_smart.ps1"
    echo ""
    echo "  Option B - Fix USB Networking:"
    echo "    1. Check USB-C cable is connected"
    echo "    2. Wait 30s for network to come up"
    echo "    3. Re-run this script"
    echo ""

    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║            Programming Prepared (Manual Steps Required)            ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
fi

# Design info
echo "Design Information:"
echo "  Name:        LED Blink (Standalone Fabric)"
echo "  Device:      MPFS025T-FCVG484E (BeagleV-Fire)"
echo "  Resources:   48 LUTs, 27 FFs"
echo "  LED Pin:     V22 (Cape P8[3])"
echo "  Frequency:   1 Hz (ON 0.5s, OFF 0.5s)"
echo ""
