#!/bin/bash
# Master Build Script for MI-V TMR System
# Runs complete flow: Project creation → SmartDesign → Build

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║         MI-V TMR System - Complete Build Flow                      ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Get absolute path to tcl_monster
TCL_MONSTER_DIR="/mnt/c/tcl_monster"
cd "$TCL_MONSTER_DIR"

# ============================================================================
# Step 1: Create Project and IP Cores
# ============================================================================

echo "[1/3] Creating project and IP cores..."
echo "  (This will take ~5-10 minutes to download and configure IP cores)"
echo ""

./run_libero.sh tcl_scripts/tmr/create_miv_tmr_project.tcl SCRIPT

echo ""
echo "✓ Project creation complete"
echo ""

# ============================================================================
# Step 2: Import HDL Top-Level and Set Hierarchy
# ============================================================================

echo "[2/3] Importing HDL top-level wrapper..."
echo "  (This will take ~1 minute)"
echo ""

./run_libero.sh tcl_scripts/tmr/create_tmr_hdl_top.tcl SCRIPT

echo ""
echo "✓ HDL top-level integration complete"
echo ""

# ============================================================================
# Step 3: Build (Synthesis + Place & Route)
# ============================================================================

echo "[3/3] Building design (synthesis + P&R)..."
echo "  ⚠️  WARNING: This will take 30-60 minutes!"
echo "  ⚠️  Synthesis: ~30-45 min for 3x MI-V cores"
echo "  ⚠️  Place & Route: ~20-30 min"
echo ""
echo "  You can monitor progress in Libero log files:"
echo "    libero_projects/tmr/miv_tmr_mpf300/*.log"
echo ""

read -p "Continue with build? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    ./run_libero.sh tcl_scripts/tmr/build_tmr_project.tcl SCRIPT

    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                  Build Complete!                                   ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Check results:"
    echo "  libero_projects/tmr/miv_tmr_mpf300/designer/impl1/*_utilization.txt"
    echo "  libero_projects/tmr/miv_tmr_mpf300/designer/impl1/*_timing_violations_report.txt"
    echo ""
else
    echo ""
    echo "Build skipped. Run manually with:"
    echo "  ./run_libero.sh tcl_scripts/tmr/build_tmr_project.tcl SCRIPT"
    echo ""
fi
