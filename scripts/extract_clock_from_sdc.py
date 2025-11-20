#!/usr/bin/env python3
"""
Extract system clock frequency from PF_CCC component configuration

This script searches for CCC component TCL files in a Libero project
and extracts the ACTUAL configured output frequency (not timing constraints).

Usage:
    python3 extract_clock_from_sdc.py <project_dir>

Example:
    python3 extract_clock_from_sdc.py libero_projects/miv_rv32_demo

Output:
    Prints the detected clock frequency in Hz, or 0 if not found

Note:
    Parses component TCL configuration (GL0_0_OUT_FREQ parameter) instead of
    SDC timing constraints, since SDC can be artificially tightened for
    timing closure (e.g., 60 MHz constraint for 50 MHz actual clock).
"""

import sys
import re
from pathlib import Path
import glob


def find_ccc_component_files(project_dir):
    """Find all PF_CCC component TCL configuration files in the project."""
    # Look for component TCL files, not SDC files
    patterns = [
        f"{project_dir}/component/work/PF_CCC*/PF_CCC*.tcl",
        f"{project_dir}/component/Actel/DirectCore/PF_CCC*/*/PF_CCC*.tcl",
    ]

    ccc_files = []
    for pattern in patterns:
        ccc_files.extend(glob.glob(pattern))

    return ccc_files


def parse_ccc_output_frequency(ccc_file):
    """Parse output frequency from CCC component TCL configuration.

    Looks for: "GL0_0_OUT_FREQ:<value>" in the component params
    Returns frequency in MHz, or None if not found.
    """
    try:
        with open(ccc_file, 'r') as f:
            content = f.read()

        # Match: "GL0_0_OUT_FREQ:50" (output 0 fabric clock frequency)
        # This is the ACTUAL configured frequency, not a timing constraint
        match = re.search(r'"GL0_0_OUT_FREQ:([0-9\.]+)"', content)
        if match:
            freq_mhz = float(match.group(1))
            return freq_mhz

        # Also check for GL0 (without the _0 suffix - older format)
        match = re.search(r'"GL0_OUT_FREQ:([0-9\.]+)"', content)
        if match:
            freq_mhz = float(match.group(1))
            return freq_mhz

    except Exception as e:
        print(f"WARNING: Failed to parse {ccc_file}: {e}", file=sys.stderr)

    return None


def extract_clock_frequency(project_dir):
    """Extract system clock frequency from project.

    Returns frequency in Hz, or 0 if not found.
    """
    # Find CCC component configuration files
    ccc_files = find_ccc_component_files(project_dir)

    if not ccc_files:
        print(f"WARNING: No PF_CCC component files found in {project_dir}", file=sys.stderr)
        return 0

    print(f"Found {len(ccc_files)} CCC component file(s)", file=sys.stderr)

    # Parse first CCC file
    ccc_file = ccc_files[0]
    print(f"Parsing: {ccc_file}", file=sys.stderr)

    freq_mhz = parse_ccc_output_frequency(ccc_file)

    if freq_mhz is None:
        print(f"WARNING: Could not parse output frequency from {ccc_file}", file=sys.stderr)
        return 0

    # Convert MHz to Hz
    freq_hz = int(freq_mhz * 1_000_000)

    print(f"  CCC Output Frequency: {freq_mhz} MHz ({freq_hz} Hz)", file=sys.stderr)
    print(f"  Source: Component configuration (GL0_0_OUT_FREQ parameter)", file=sys.stderr)

    return freq_hz


def main():
    if len(sys.argv) != 2:
        print("ERROR: Missing required argument", file=sys.stderr)
        print("", file=sys.stderr)
        print("Usage:", file=sys.stderr)
        print("  python3 extract_clock_from_sdc.py <project_dir>", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  python3 extract_clock_from_sdc.py libero_projects/miv_rv32_demo", file=sys.stderr)
        sys.exit(1)

    project_dir = sys.argv[1]

    if not Path(project_dir).exists():
        print(f"ERROR: Project directory not found: {project_dir}", file=sys.stderr)
        sys.exit(1)

    # Extract clock frequency
    freq_hz = extract_clock_frequency(project_dir)

    # Print to stdout (for scripting)
    print(freq_hz)

    sys.exit(0 if freq_hz > 0 else 1)


if __name__ == "__main__":
    main()
