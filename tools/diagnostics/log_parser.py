#!/usr/bin/env python3
"""
Libero Build Log Parser

Parses Synplify Pro synthesis logs and Libero Place & Route logs to extract:
- Warnings and errors
- Resource utilization
- Timing information
- Build statistics

Usage:
    python log_parser.py <log_file>
    python log_parser.py --project <project_dir>
"""

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional
from enum import Enum


class LogLevel(Enum):
    """Log message severity levels."""
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


@dataclass
class LogMessage:
    """Parsed log message."""
    level: LogLevel
    message: str
    file: Optional[str] = None
    line: Optional[int] = None
    context: str = ""


@dataclass
class ResourceUsage:
    """FPGA resource utilization."""
    luts_used: int = 0
    luts_total: int = 0
    ffs_used: int = 0
    ffs_total: int = 0
    io_used: int = 0
    io_total: int = 0
    ram_blocks_used: int = 0
    ram_blocks_total: int = 0
    math_blocks_used: int = 0
    math_blocks_total: int = 0

    @property
    def lut_percent(self) -> float:
        return (self.luts_used / self.luts_total * 100) if self.luts_total > 0 else 0.0

    @property
    def ff_percent(self) -> float:
        return (self.ffs_used / self.ffs_total * 100) if self.ffs_total > 0 else 0.0

    @property
    def io_percent(self) -> float:
        return (self.io_used / self.io_total * 100) if self.io_total > 0 else 0.0


@dataclass
class BuildMetrics:
    """Build performance metrics."""
    synthesis_time: float = 0.0
    placement_time: float = 0.0
    routing_time: float = 0.0
    total_time: float = 0.0


@dataclass
class ParsedLog:
    """Complete parsed log data."""
    messages: List[LogMessage] = field(default_factory=list)
    resources: ResourceUsage = field(default_factory=ResourceUsage)
    metrics: BuildMetrics = field(default_factory=BuildMetrics)
    timing_driven: bool = False
    power_driven: bool = False
    has_timing_constraints: bool = False

    @property
    def errors(self) -> List[LogMessage]:
        return [m for m in self.messages if m.level == LogLevel.ERROR]

    @property
    def warnings(self) -> List[LogMessage]:
        return [m for m in self.messages if m.level == LogLevel.WARNING]

    @property
    def has_errors(self) -> bool:
        return len(self.errors) > 0


class LogParser:
    """Parse Libero build logs."""

    def __init__(self):
        self.log = ParsedLog()

    def parse_synthesis_log(self, log_path: Path) -> ParsedLog:
        """Parse Synplify Pro synthesis log."""
        print(f"Parsing synthesis log: {log_path}")

        if not log_path.exists():
            print(f"  WARNING: Log file not found: {log_path}")
            return self.log

        with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Extract warnings and errors
        self._extract_synplify_messages(content)

        # Extract timing information
        self._extract_synthesis_timing(content)

        return self.log

    def parse_pr_log(self, log_path: Path) -> ParsedLog:
        """Parse Place & Route log."""
        print(f"Parsing P&R log: {log_path}")

        if not log_path.exists():
            print(f"  WARNING: Log file not found: {log_path}")
            return self.log

        with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Extract configuration
        self._extract_pr_config(content)

        # Extract resource usage
        self._extract_resource_usage(content)

        # Extract timing
        self._extract_pr_timing(content)

        # Extract messages
        self._extract_pr_messages(content)

        return self.log

    def parse_project(self, project_dir: Path) -> ParsedLog:
        """Parse all logs from a Libero project directory."""
        print(f"Parsing project: {project_dir}")

        # Synthesis logs
        syn_log = project_dir / "synthesis" / "synplify.log"
        if syn_log.exists():
            self.parse_synthesis_log(syn_log)

        # P&R logs (find designer subdirectory)
        designer_dir = project_dir / "designer"
        if designer_dir.exists():
            # Find the design directory (e.g., designer/counter/)
            design_dirs = [d for d in designer_dir.iterdir() if d.is_dir()]
            if design_dirs:
                design_dir = design_dirs[0]
                pr_log = design_dir / f"{design_dir.name}_layout_log.log"
                if pr_log.exists():
                    self.parse_pr_log(pr_log)

        return self.log

    def _extract_synplify_messages(self, content: str):
        """Extract warnings and errors from Synplify log."""
        for line in content.split('\n'):
            # Synplify errors: @E: message
            if re.match(r'@E:', line):
                self.log.messages.append(LogMessage(
                    level=LogLevel.ERROR,
                    message=line.replace('@E:', '').strip()
                ))
            # Synplify warnings: @W: message
            elif re.match(r'@W:', line):
                self.log.messages.append(LogMessage(
                    level=LogLevel.WARNING,
                    message=line.replace('@W:', '').strip()
                ))

    def _extract_synthesis_timing(self, content: str):
        """Extract synthesis timing from log."""
        # Look for "Run Time: XXh:XXm:XXs"
        match = re.search(r'Run Time:\s*(\d+)h:(\d+)m:(\d+)s', content)
        if match:
            hours, minutes, seconds = map(int, match.groups())
            self.log.metrics.synthesis_time = hours * 3600 + minutes * 60 + seconds

    def _extract_pr_config(self, content: str):
        """Extract P&R configuration settings."""
        # Check if timing-driven
        if re.search(r'Timing-driven\s*:\s*ON', content, re.IGNORECASE):
            self.log.timing_driven = True

        # Check if power-driven
        if re.search(r'Power-driven\s*:\s*ON', content, re.IGNORECASE):
            self.log.power_driven = True

        # Check for timing constraints
        if re.search(r'No timing constraint has been associated', content):
            self.log.has_timing_constraints = False
        else:
            self.log.has_timing_constraints = True

    def _extract_resource_usage(self, content: str):
        """Extract resource utilization from P&R log."""
        # Parse resource usage table:
        # +---------------+------+--------+------------+
        # | Type          | Used | Total  | Percentage |
        # +---------------+------+--------+------------+
        # | 4LUT          | 33   | 299544 | 0.01       |
        # | DFF           | 32   | 299544 | 0.01       |

        lines = content.split('\n')
        in_resource_table = False

        for line in lines:
            if 'Resource Usage' in line:
                in_resource_table = True
                continue

            if in_resource_table:
                # End of table
                if line.strip().startswith('I/O Placement') or line.strip().startswith('TBBmalloc'):
                    break

                # Parse resource line
                match = re.match(r'\|\s*([A-Za-z0-9 ]+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|', line)
                if match:
                    res_type, used, total = match.groups()
                    res_type = res_type.strip()
                    used, total = int(used), int(total)

                    if '4LUT' in res_type:
                        self.log.resources.luts_used = used
                        self.log.resources.luts_total = total
                    elif 'DFF' in res_type:
                        self.log.resources.ffs_used = used
                        self.log.resources.ffs_total = total
                    elif 'User I/O' in res_type or 'Single-ended I/O' in res_type:
                        self.log.resources.io_used = used
                        self.log.resources.io_total = total
                    elif 'SRAM' in res_type or 'RAM' in res_type:
                        self.log.resources.ram_blocks_used += used
                        self.log.resources.ram_blocks_total += total
                    elif 'Math' in res_type:
                        self.log.resources.math_blocks_used = used
                        self.log.resources.math_blocks_total = total

    def _extract_pr_timing(self, content: str):
        """Extract P&R timing from log."""
        # Placement time
        match = re.search(r'Total Elapsed Time:\s*(\d+):(\d+):(\d+)', content)
        if match:
            hours, minutes, seconds = map(int, match.groups())
            self.log.metrics.placement_time = hours * 3600 + minutes * 60 + seconds

    def _extract_pr_messages(self, content: str):
        """Extract INFO/WARNING/ERROR from P&R log."""
        for line in content.split('\n'):
            # INFO messages
            if line.strip().startswith('INFO:') or line.strip().startswith('Info:'):
                msg = line.split(':', 1)[1].strip()
                self.log.messages.append(LogMessage(
                    level=LogLevel.INFO,
                    message=msg
                ))
            # WARNING messages
            elif re.match(r'WARNING:', line, re.IGNORECASE):
                msg = line.split(':', 1)[1].strip()
                self.log.messages.append(LogMessage(
                    level=LogLevel.WARNING,
                    message=msg
                ))
            # ERROR messages
            elif re.match(r'ERROR:', line, re.IGNORECASE):
                msg = line.split(':', 1)[1].strip()
                self.log.messages.append(LogMessage(
                    level=LogLevel.ERROR,
                    message=msg
                ))


def print_summary(log: ParsedLog):
    """Print summary of parsed log."""
    print("\n" + "=" * 70)
    print("BUILD LOG SUMMARY")
    print("=" * 70)

    # Errors and warnings
    print(f"\n{'Errors:':<20} {len(log.errors)}")
    print(f"{'Warnings:':<20} {len(log.warnings)}")

    if log.errors:
        print("\nERRORS:")
        for err in log.errors:
            print(f"  ✗ {err.message}")

    if log.warnings:
        print("\nWARNINGS:")
        for warn in log.warnings[:5]:  # Show first 5
            print(f"  ⚠  {warn.message}")
        if len(log.warnings) > 5:
            print(f"  ... and {len(log.warnings) - 5} more warnings")

    # Resource usage
    print("\nRESOURCE USAGE:")
    print(f"  4LUT:  {log.resources.luts_used:,} / {log.resources.luts_total:,} ({log.resources.lut_percent:.2f}%)")
    print(f"  DFF:   {log.resources.ffs_used:,} / {log.resources.ffs_total:,} ({log.resources.ff_percent:.2f}%)")
    print(f"  I/O:   {log.resources.io_used:,} / {log.resources.io_total:,} ({log.resources.io_percent:.2f}%)")

    # Configuration
    print("\nCONFIGURATION:")
    print(f"  Timing-driven P&R: {'✓ ON' if log.timing_driven else '✗ OFF'}")
    print(f"  Power-driven P&R:  {'✓ ON' if log.power_driven else '✗ OFF'}")
    print(f"  Timing constraints: {'✓ Found' if log.has_timing_constraints else '✗ None'}")

    print("\n" + "=" * 70)


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python log_parser.py <log_file>")
        print("   or: python log_parser.py --project <project_dir>")
        sys.exit(1)

    parser = LogParser()

    if sys.argv[1] == '--project':
        if len(sys.argv) < 3:
            print("ERROR: --project requires project directory")
            sys.exit(1)
        project_dir = Path(sys.argv[2])
        log = parser.parse_project(project_dir)
    else:
        log_path = Path(sys.argv[1])

        if 'synplify' in log_path.name:
            log = parser.parse_synthesis_log(log_path)
        elif 'layout' in log_path.name:
            log = parser.parse_pr_log(log_path)
        else:
            print(f"Unknown log type: {log_path.name}")
            print("Trying generic parsing...")
            log = parser.parse_pr_log(log_path)

    print_summary(log)

    # Exit code based on errors
    sys.exit(1 if log.has_errors else 0)


if __name__ == '__main__':
    main()
