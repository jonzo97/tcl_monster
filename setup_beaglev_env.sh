#!/bin/bash
# Complete BeagleV-Fire Build Environment
# Supports FPGA (Windows tools) + RISC-V (Linux native tools)
# Source this file before building: source ./setup_beaglev_env.sh

# === Windows Tools (FPGA Development) ===
export LIBERO_INSTALL_DIR="/mnt/c/Microchip/Libero_SoC_v2024.2"
export SC_INSTALL_DIR="/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747"
export FPGENPROG="$LIBERO_INSTALL_DIR/Designer/bin/fpgenprog"
export LM_LICENSE_FILE="/mnt/c/Microchip/License.dat"

# Add Windows FPGA tools to PATH
export PATH="$LIBERO_INSTALL_DIR/Designer/bin:$PATH"
export PATH="$LIBERO_INSTALL_DIR/Designer/bin64:$PATH"

# === Linux Tools (RISC-V Development) ===
# Native Linux toolchain preferred for HSS/bare-metal builds
# Ubuntu provides: gcc-riscv64-unknown-elf, binutils-riscv64-unknown-elf
# Install with: sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf

# Verify native toolchain available
if command -v riscv64-unknown-elf-gcc &> /dev/null; then
    RISCV_TOOLCHAIN="native"
    RISCV_VERSION=$(riscv64-unknown-elf-gcc --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+')
else
    RISCV_TOOLCHAIN="softconsole-fallback"
    RISCV_VERSION="not-found"
    # Fallback to SoftConsole (not recommended due to WSL issues)
    export PATH="$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin:$PATH"
fi

echo "=== Complete BeagleV-Fire Build Environment ==="
echo "LIBERO_INSTALL_DIR: $LIBERO_INSTALL_DIR"
echo "FPGENPROG: $FPGENPROG"
echo "LM_LICENSE_FILE: $LM_LICENSE_FILE"
echo ""
echo "RISC-V Toolchain: $RISCV_TOOLCHAIN"
echo "RISC-V GCC Version: $RISCV_VERSION"
echo ""
echo "Verifying tools..."
which libero.exe 2>/dev/null && echo "✓ Libero found" || echo "✗ Libero not found"
which riscv64-unknown-elf-gcc 2>/dev/null && echo "✓ RISC-V GCC found" || echo "✗ RISC-V GCC not found"
python3 -c "import gitpython, yaml" 2>/dev/null && echo "✓ Python dependencies OK" || echo "✗ Python dependencies missing"
echo ""

if [ "$RISCV_TOOLCHAIN" = "native" ]; then
    echo "✓ Environment ready for complete builds (FPGA + RISC-V)!"
else
    echo "⚠ Native RISC-V toolchain not found!"
    echo "  Install with: sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf"
    echo "  Current setup will work for FPGA-only builds."
fi
