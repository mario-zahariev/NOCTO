#!/usr/bin/env python3
"""Enforce line coverage for production Swift package sources, excluding tests."""
import argparse
import json
import os
from pathlib import Path


def production_files(report):
    files = {}
    for target in report.get("data", []):
        for entry in target.get("files", []):
            name = entry["filename"].replace("\\", "/")
            if "/Sources/NOCTOCore/" in name or "/NOCTO/" in name:
                files[name] = entry["summary"]["lines"]
    if not files:
        raise ValueError("Coverage report contains no production Swift sources")
    return files


def coverage_path(value):
    root = Path(__file__).resolve().parents[2]
    candidate = Path(value)
    if not candidate.is_absolute():
        candidate = root / candidate
    candidate = candidate.resolve()
    if not candidate.is_relative_to(root / ".build"):
        raise argparse.ArgumentTypeError("Coverage input must be inside this repository's .build directory")
    if candidate.suffix != ".json":
        raise argparse.ArgumentTypeError("Coverage input must be a JSON report")
    return candidate


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=coverage_path)
    parser.add_argument("--minimum", type=float, default=70)
    args = parser.parse_args()
    files = production_files(json.loads(args.report.read_text()))
    total = sum(item["count"] for item in files.values())
    covered = sum(item["covered"] for item in files.values())
    if total == 0:
        raise SystemExit("Coverage report has zero executable production lines")
    percentage = covered * 100 / total
    summary = f"Swift production line coverage: {percentage:.2f}% ({covered}/{total}); required {args.minimum:.0f}%"
    print(summary)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as output:
            output.write(f"## Swift coverage\n\n{summary}\n")
    if percentage < args.minimum:
        raise SystemExit(f"Coverage threshold failed: {summary}")


if __name__ == "__main__":
    main()
