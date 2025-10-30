#!/usr/bin/env python3
"""
Build Doctor - Intelligent FPGA Build Analysis

Analyzes Libero build logs and provides intelligent recommendations
for common issues, optimizations, and best practices.

Usage:
    python build_doctor.py <project_dir>
    python build_doctor.py <project_dir> --verbose
"""

import sys
from pathlib import Path
from typing import List, Tuple
from dataclasses import dataclass

# Import log parser
from log_parser import LogParser, ParsedLog, LogLevel


@dataclass
class Recommendation:
    """Build recommendation."""
    severity: str  # INFO, WARNING, ERROR
    category: str  # Performance, Timing, Resource, Configuration
    issue: str
    impact: str
    fix: str
    reference: str = ""


class BuildDoctor:
    """Analyze FPGA builds and provide intelligent recommendations."""

    def __init__(self):
        self.recommendations: List[Recommendation] = []

    def analyze(self, log: ParsedLog) -> List[Recommendation]:
        """Analyze parsed log and generate recommendations."""
        self.recommendations = []

        # Run all analysis checks
        self._check_timing_driven(log)
        self._check_timing_constraints(log)
        self._check_resource_usage(log)
        self._check_errors_warnings(log)
        self._check_optimization_opportunities(log)

        return self.recommendations

    def _check_timing_driven(self, log: ParsedLog):
        """Check if timing-driven P&R is enabled."""
        if not log.timing_driven and log.resources.luts_used > 0:
            self.recommendations.append(Recommendation(
                severity="WARNING",
                category="Performance",
                issue="Timing-driven Place & Route is disabled",
                impact="Design may not meet timing requirements. P&R will optimize for area/routability only, not speed.",
                fix="Add timing constraints (SDC file) to enable timing-driven P&R",
                reference="See constraint/timing_constraints_template.sdc"
            ))

    def _check_timing_constraints(self, log: ParsedLog):
        """Check for timing constraints."""
        if not log.has_timing_constraints and log.resources.luts_used > 100:
            self.recommendations.append(Recommendation(
                severity="WARNING",
                category="Timing",
                issue="No timing constraints found",
                impact="Cannot verify if design meets timing requirements. Clock domains undefined.",
                fix="Create SDC file with clock definitions and I/O timing constraints",
                reference="Use: create_clock -period <ns> [get_ports CLK]"
            ))

    def _check_resource_usage(self, log: ParsedLog):
        """Check resource utilization and flag issues."""
        lut_pct = log.resources.lut_percent
        ff_pct = log.resources.ff_percent

        # Very high usage (>90%)
        if lut_pct > 90 or ff_pct > 90:
            self.recommendations.append(Recommendation(
                severity="ERROR",
                category="Resource",
                issue=f"Very high resource usage (LUT: {lut_pct:.1f}%, FF: {ff_pct:.1f}%)",
                impact="Design may not route successfully. Timing degradation likely.",
                fix="Reduce logic complexity, use block RAM for storage, optimize state machines",
                reference="Consider: (1) Pipeline long paths (2) Use DSP blocks for math (3) Reduce fanout"
            ))

        # High usage (70-90%)
        elif lut_pct > 70 or ff_pct > 70:
            self.recommendations.append(Recommendation(
                severity="WARNING",
                category="Resource",
                issue=f"High resource usage (LUT: {lut_pct:.1f}%, FF: {ff_pct:.1f}%)",
                impact="Limited headroom for future changes. Routing may become difficult.",
                fix="Monitor growth, consider optimization if adding more logic",
                reference="Target: Keep <70% for good P&R results"
            ))

        # Very low usage (<5%)
        elif lut_pct < 5 and ff_pct < 5 and log.resources.luts_used > 10:
            self.recommendations.append(Recommendation(
                severity="INFO",
                category="Resource",
                issue=f"Very low resource usage (LUT: {lut_pct:.2f}%, FF: {ff_pct:.2f}%)",
                impact="Excellent headroom for future expansion",
                fix="Consider using excess resources for: (1) Register pipelining (2) Error checking/recovery (3) Debug logic",
                reference="Plenty of room to optimize for speed vs. area"
            ))

    def _check_errors_warnings(self, log: ParsedLog):
        """Analyze errors and warnings."""
        # Critical errors
        if log.errors:
            for error in log.errors:
                self.recommendations.append(Recommendation(
                    severity="ERROR",
                    category="Build",
                    issue=f"Build error: {error.message}",
                    impact="Build failed - cannot generate bitstream",
                    fix="Review error message and fix source HDL/constraints",
                    reference=""
                ))

        # Too many warnings
        if len(log.warnings) > 10:
            self.recommendations.append(Recommendation(
                severity="WARNING",
                category="Build",
                issue=f"Large number of warnings ({len(log.warnings)})",
                impact="May indicate design issues. Important warnings can be buried.",
                fix="Review and address warnings. Use proper coding styles to reduce noise.",
                reference="Clean builds have <5 warnings typically"
            ))

    def _check_optimization_opportunities(self, log: ParsedLog):
        """Suggest optimizations based on design characteristics."""
        # If timing-driven is off and resource usage is low, suggest pipelining
        if not log.timing_driven and log.resources.lut_percent < 30:
            self.recommendations.append(Recommendation(
                severity="INFO",
                category="Optimization",
                issue="Design has headroom for performance optimization",
                impact="Could improve maximum clock frequency",
                fix="Consider adding register pipelining to long combinational paths",
                reference="Pipelining trades LUTs/FFs for higher Fmax"
            ))

        # Power-driven optimization
        if not log.power_driven and log.resources.lut_percent < 50:
            self.recommendations.append(Recommendation(
                severity="INFO",
                category="Power",
                issue="Power-driven optimization not enabled",
                impact="Design may consume more power than necessary",
                fix="Consider enabling power-driven P&R for battery-powered applications",
                reference="Enable in Project Settings > Design Flow > Power-driven"
            ))

    def print_report(self, log: ParsedLog, verbose: bool = False):
        """Print formatted analysis report."""
        print("\n" + "=" * 80)
        print(" " * 25 + "🔬 BUILD DOCTOR ANALYSIS")
        print("=" * 80)

        # Build status
        if log.has_errors:
            status = "❌ FAILED"
        elif log.warnings:
            status = "⚠️  PASSED WITH WARNINGS"
        else:
            status = "✅ PASSED"

        print(f"\nBuild Status: {status}")

        # Quick stats
        print(f"\nQuick Stats:")
        print(f"  Errors:   {len(log.errors)}")
        print(f"  Warnings: {len(log.warnings)}")
        print(f"  LUTs:     {log.resources.luts_used:,} / {log.resources.luts_total:,} ({log.resources.lut_percent:.2f}%)")
        print(f"  FFs:      {log.resources.ffs_used:,} / {log.resources.ffs_total:,} ({log.resources.ff_percent:.2f}%)")

        # Recommendations by severity
        errors = [r for r in self.recommendations if r.severity == "ERROR"]
        warnings = [r for r in self.recommendations if r.severity == "WARNING"]
        infos = [r for r in self.recommendations if r.severity == "INFO"]

        if errors:
            print(f"\n🔴 CRITICAL ISSUES ({len(errors)}):")
            for rec in errors:
                self._print_recommendation(rec, verbose)

        if warnings:
            print(f"\n⚠️  WARNINGS ({len(warnings)}):")
            for rec in warnings:
                self._print_recommendation(rec, verbose)

        if infos and verbose:
            print(f"\n💡 SUGGESTIONS ({len(infos)}):")
            for rec in infos:
                self._print_recommendation(rec, verbose)
        elif infos and not verbose:
            print(f"\n💡 {len(infos)} optimization suggestions available (use --verbose to see)")

        # Summary
        print("\n" + "-" * 80)
        print("SUMMARY:")
        if not errors and not warnings:
            print("  ✅ Build looks good! No critical issues found.")
        elif errors:
            print(f"  ❌ {len(errors)} critical issue(s) need attention")
        elif warnings:
            print(f"  ⚠️  {len(warnings)} warning(s) should be reviewed")

        if not log.timing_driven and not log.has_timing_constraints:
            print("\n  💡 TIP: Add timing constraints to enable timing analysis")

        print("=" * 80 + "\n")

    def _print_recommendation(self, rec: Recommendation, verbose: bool):
        """Print a single recommendation."""
        symbol = {"ERROR": "❌", "WARNING": "⚠️", "INFO": "💡"}[rec.severity]
        print(f"\n  {symbol} [{rec.category}] {rec.issue}")
        print(f"     Impact: {rec.impact}")
        print(f"     Fix: {rec.fix}")
        if verbose and rec.reference:
            print(f"     Reference: {rec.reference}")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python build_doctor.py <project_dir> [--verbose]")
        sys.exit(1)

    project_dir = Path(sys.argv[1])
    verbose = '--verbose' in sys.argv or '-v' in sys.argv

    if not project_dir.exists():
        print(f"ERROR: Project directory not found: {project_dir}")
        sys.exit(1)

    # Parse logs
    parser = LogParser()
    log = parser.parse_project(project_dir)

    # Analyze
    doctor = BuildDoctor()
    doctor.analyze(log)

    # Print report
    doctor.print_report(log, verbose=verbose)

    # Exit code: 0 if no critical issues, 1 if errors, 2 if warnings
    if log.has_errors or any(r.severity == "ERROR" for r in doctor.recommendations):
        sys.exit(1)
    elif log.warnings or any(r.severity == "WARNING" for r in doctor.recommendations):
        sys.exit(2)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()
