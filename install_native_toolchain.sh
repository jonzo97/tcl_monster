#!/bin/bash
# Install Native Linux RISC-V Toolchain for BeagleV-Fire Development
# This resolves WSL/Windows .exe compatibility issues

echo "=========================================="
echo "Installing Native RISC-V Toolchain"
echo "=========================================="
echo ""
echo "This will install:"
echo "  - gcc-riscv64-unknown-elf (bare-metal GCC)"
echo "  - binutils-riscv64-unknown-elf (assembler, linker)"
echo "  - picolibc-riscv64-unknown-elf (embedded C library)"
echo "  - gdb-multiarch (debugging support)"
echo ""
echo "Why? Windows SoftConsole .exe tools don't work properly from WSL"
echo "Native Linux tools work seamlessly for HSS/bare-metal builds"
echo ""

read -p "Proceed with installation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled"
    exit 1
fi

echo ""
echo "Updating package lists..."
sudo apt update

echo ""
echo "Installing RISC-V toolchain packages..."
sudo apt install -y \
    gcc-riscv64-unknown-elf \
    binutils-riscv64-unknown-elf \
    picolibc-riscv64-unknown-elf \
    gdb-multiarch

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "Verifying installation..."
which riscv64-unknown-elf-gcc && riscv64-unknown-elf-gcc --version | head -1

echo ""
echo "Testing compilation..."
cat > /tmp/test_riscv.c << 'EOF'
int main(void) {
    volatile int x = 42;
    return x;
}
EOF

if riscv64-unknown-elf-gcc -c /tmp/test_riscv.c -o /tmp/test_riscv.o 2>&1; then
    echo "✓ Compilation test passed"
    file /tmp/test_riscv.o
    rm /tmp/test_riscv.c /tmp/test_riscv.o
else
    echo "✗ Compilation test failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo "1. Source environment: source setup_beaglev_env.sh"
echo "2. Test HSS build: cd beaglev-fire-gateware/sources/HSS && make BOARD=mpfs-beaglev-fire"
echo "3. See docs/complete_toolchain_setup.md for full details"
echo ""
echo "Ready for complete PolarFire SoC development!"
