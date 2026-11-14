import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("coverage_report", ROOT / "scripts/ci/report_coverage.py")
coverage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(coverage)


class CoverageTests(unittest.TestCase):
    def test_tests_do_not_inflate_production_coverage(self):
        report = {"data": [{"files": [
            {"filename": "/repo/Sources/NOCTOCore/Venue.swift", "summary": {"lines": {"count": 10, "covered": 7}}},
            {"filename": "/repo/Tests/NOCTOCoreTests/VenueTests.swift", "summary": {"lines": {"count": 100, "covered": 100}}},
        ]}]}
        self.assertEqual(len(coverage.production_files(report)), 1)

    def test_paths_outside_build_are_rejected(self):
        import argparse
        for path in ["/etc/passwd", ".build/../../outside.json", "README.md"]:
            with self.assertRaises(argparse.ArgumentTypeError):
                coverage.coverage_path(path)
        self.assertEqual(coverage.coverage_path(".build/coverage/report.json"), ROOT / ".build/coverage/report.json")

    def test_missing_production_data_fails_closed(self):
        with self.assertRaises(ValueError):
            coverage.production_files({"data": []})


if __name__ == "__main__":
    unittest.main()
