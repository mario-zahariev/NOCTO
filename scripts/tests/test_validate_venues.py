import contextlib
import copy
import importlib.util
import io
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("validator", ROOT / "scripts/validate_venues_json.py")
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class VenueValidationTests(unittest.TestCase):
    def setUp(self):
        self.entry = json.loads((ROOT / "venues.json").read_text())[0]

    def assert_invalid(self, **changes):
        entry = copy.deepcopy(self.entry)
        entry.update(changes)
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            validator.validate_entry(entry, 0)

    def test_boolean_coordinates_are_not_numbers(self):
        self.assert_invalid(latitude=True)
        self.assert_invalid(longitude=False)

    def test_nonfinite_and_out_of_range_coordinates(self):
        for value in [float("nan"), float("inf"), -91, 91]:
            self.assert_invalid(latitude=value)

    def test_invalid_hours(self):
        for hours in ["22:00--04:00", "24:00-04:00", "22:60-04:00", "22:00", ""]:
            self.assert_invalid(workingHours=hours)

    def test_empty_description_is_rejected(self):
        self.assert_invalid(description="  ")

    def test_valid_overnight_hours(self):
        self.entry["workingHours"] = "22:00-04:00"
        validator.validate_entry(self.entry, 0)

    def test_duplicate_ids_are_rejected_case_insensitively(self):
        import tempfile
        data = [dict(self.entry, id=self.entry["id"].upper()), dict(self.entry, id=self.entry["id"].lower())] * 5
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "venues.json"
            path.write_text(json.dumps(data))
            original = validator.VENUES_PATH
            try:
                validator.VENUES_PATH = path
                with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                    validator.main()
            finally:
                validator.VENUES_PATH = original


if __name__ == "__main__":
    unittest.main()
