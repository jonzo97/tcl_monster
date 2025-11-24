#!/bin/bash
# BeagleV-Fire Connection Verification Script
# Checks if BeagleV-Fire is connected and ready for programming

BEAGLE_IP="192.168.7.2"
BEAGLE_USER="beagle"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║          BeagleV-Fire Connection Verification                      ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Check 1: Network connectivity
echo "[1/5] Checking network connectivity..."
if ping -c 2 -W 2 $BEAGLE_IP >/dev/null 2>&1; then
    echo "      ✓ BeagleV-Fire reachable at $BEAGLE_IP"
    NETWORK_OK=true
else
    echo "      ❌ BeagleV-Fire NOT reachable at $BEAGLE_IP"
    NETWORK_OK=false
fi
echo ""

# Check 2: SSH connectivity
echo "[2/5] Checking SSH connectivity..."
if [ "$NETWORK_OK" = true ]; then
    if ssh -o ConnectTimeout=3 -o BatchMode=yes ${BEAGLE_USER}@${BEAGLE_IP} "echo OK" >/dev/null 2>&1; then
        echo "      ✓ SSH connection successful"
        SSH_OK=true
    else
        echo "      ⚠ SSH connection failed (password may be required)"
        SSH_OK=false
    fi
else
    echo "      ⏭ Skipped (network not reachable)"
    SSH_OK=false
fi
echo ""

# Check 3: Serial connection (Windows side)
echo "[3/5] Checking serial connection (Windows)..."
if [ -f /mnt/c/Temp/beaglev_serial.log ]; then
    LAST_SERIAL=$(stat -c %y /mnt/c/Temp/beaglev_serial.log 2>/dev/null | cut -d'.' -f1)
    echo "      ✓ Serial log found: $LAST_SERIAL"
    SERIAL_OK=true
else
    echo "      ❌ Serial log not found: C:\\Temp\\beaglev_serial.log"
    SERIAL_OK=false
fi
echo ""

# Check 4: Command queue file
echo "[4/5] Checking command queue file..."
if [ -f /mnt/c/Temp/beaglev_cmd_queue.txt ]; then
    echo "      ✓ Command queue file exists"
    QUEUE_OK=true
else
    echo "      ⚠ Command queue file not found"
    echo "      Creating: C:\\Temp\\beaglev_cmd_queue.txt"
    touch /mnt/c/Temp/beaglev_cmd_queue.txt
    QUEUE_OK=true
fi
echo ""

# Check 5: Bitstream file
echo "[5/5] Checking LED blink bitstream..."
BITSTREAM="/mnt/c/tcl_monster/beaglev_fire_demo/beaglev_led_blink/designer/led_blinker_fabric/export/led_blink_bitstream.spi"
if [ -f "$BITSTREAM" ]; then
    BITSTREAM_SIZE=$(ls -lh "$BITSTREAM" | awk '{print $5}')
    echo "      ✓ Bitstream found: $BITSTREAM_SIZE"
    BITSTREAM_OK=true
else
    echo "      ❌ Bitstream not found"
    echo "      Build it with:"
    echo "        ./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT"
    echo "        ./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT"
    BITSTREAM_OK=false
fi
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                        Connection Summary                          ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

if [ "$NETWORK_OK" = true ] && [ "$SSH_OK" = true ] && [ "$BITSTREAM_OK" = true ]; then
    echo "✅ READY TO PROGRAM!"
    echo ""
    echo "Run this command to program the LED blink:"
    echo "  ./scripts/program_beaglev_led_blink.sh"
    echo ""
    exit 0
elif [ "$NETWORK_OK" = true ] && [ "$BITSTREAM_OK" = true ]; then
    echo "⚠ ALMOST READY (SSH not configured)"
    echo ""
    echo "You can still program via serial command queue:"
    echo "  ./scripts/program_beaglev_led_blink.sh"
    echo ""
    exit 0
elif [ "$SERIAL_OK" = true ] && [ "$BITSTREAM_OK" = true ]; then
    echo "⚠ READY (Serial mode only - no network)"
    echo ""
    echo "Program via serial command queue:"
    echo "  ./scripts/program_beaglev_led_blink.sh"
    echo ""
    exit 0
else
    echo "❌ NOT READY"
    echo ""
    echo "Required actions:"
    echo ""

    if [ "$BITSTREAM_OK" = false ]; then
        echo "  1. Build LED blink bitstream:"
        echo "     ./run_libero.sh tcl_scripts/beaglev_fire/led_blink_standalone.tcl SCRIPT"
        echo "     ./run_libero.sh tcl_scripts/beaglev_fire/build_led_blink.tcl SCRIPT"
        echo ""
    fi

    if [ "$NETWORK_OK" = false ] && [ "$SERIAL_OK" = false ]; then
        echo "  2. Connect BeagleV-Fire hardware:"
        echo "     - USB-C cable to BeagleV-Fire"
        echo "     - Wait 30 seconds for boot"
        echo "     - Check Windows Device Manager for COM port"
        echo ""
        echo "  3. Start serial terminal (PowerShell):"
        echo "     C:\\Temp\\serial_smart.ps1"
        echo ""
    fi

    echo "Then re-run this script to verify:"
    echo "  ./scripts/check_beaglev_connection.sh"
    echo ""

    exit 1
fi
