#!/bin/bash
# BeagleV-Fire Build Environment Setup
# Source this file before building: source ./setup_beaglev_env.sh

# Libero SoC v2024.2
export LIBERO_INSTALL_DIR="/mnt/c/Microchip/Libero_SoC_v2024.2"

# SoftConsole (for HSS compilation)
export SC_INSTALL_DIR="/mnt/c/Microchip/SoftConsole-v2022.2-RISC-V-747"

# FlashPro programmer
export FPGENPROG="$LIBERO_INSTALL_DIR/Designer/bin/fpgenprog"

# License file
export LM_LICENSE_FILE="/mnt/c/Microchip/License.dat"

# Add tools to PATH
export PATH="$LIBERO_INSTALL_DIR/Designer/bin:$PATH"
export PATH="$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin:$PATH"

echo "=== BeagleV-Fire Build Environment ==="
echo "LIBERO_INSTALL_DIR: $LIBERO_INSTALL_DIR"
echo "SC_INSTALL_DIR: $SC_INSTALL_DIR"
echo "FPGENPROG: $FPGENPROG"
echo "LM_LICENSE_FILE: $LM_LICENSE_FILE"
echo ""
echo "Verifying tools..."
which libero.exe 2>/dev/null && echo "✓ Libero found" || echo "✗ Libero not found"
which riscv64-unknown-elf-gcc.exe 2>/dev/null && echo "✓ RISC-V GCC found" || echo "✗ RISC-V GCC not found"
python3 -c "import gitpython, yaml" 2>/dev/null && echo "✓ Python dependencies OK" || echo "✗ Python dependencies missing"
echo ""
echo "Environment ready for BeagleV-Fire builds!"
