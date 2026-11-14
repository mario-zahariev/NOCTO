#!/usr/bin/env python3

import json
import math
import re
import sys
from pathlib import Path
from uuid import UUID


ROOT = Path(__file__).resolve().parents[1]
VENUES_PATH = ROOT / "venues.json"

ALLOWED_TYPES = {"club", "bar", "lounge", "event", "other"}
REQUIRED_FIELDS = {
    "id": str,
    "name": str,
    "imageName": str,
    "type": str,
    "description": str,
    "latitude": (int, float),
    "longitude": (int, float),
    "address": str,
    "workingHours": str,
}


def fail(message: str) -> None:
    print(f"[venues-schema] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


HOURS_PATTERN = re.compile(r"(?:[01]\d|2[0-3]):[0-5]\d-(?:[01]\d|2[0-3]):[0-5]\d", re.ASCII)


def validate_required_fields(entry: dict, index: int) -> None:
    missing = [key for key in REQUIRED_FIELDS if key not in entry]
    if missing:
        fail(f"entry #{index} missing fields: {', '.join(missing)}")

    for field, field_type in REQUIRED_FIELDS.items():
        value = entry[field]
        if isinstance(value, bool) or not isinstance(value, field_type):
            fail(f"entry #{index} field '{field}' has invalid type: {type(value).__name__}")

    for field in ("name", "imageName", "description", "address", "workingHours"):
        if not entry[field].strip():
            fail(f"entry #{index} has empty '{field}'")


def validate_entry(entry: dict, index: int) -> None:
    validate_required_fields(entry, index)
    if not HOURS_PATTERN.fullmatch(entry["workingHours"]):
        fail(f"entry #{index} 'workingHours' must be HH:mm-HH:mm")

    try:
        UUID(entry["id"])
    except ValueError as exc:
        fail(f"entry #{index} has invalid UUID in 'id': {exc}")

    if entry["type"] not in ALLOWED_TYPES:
        fail(f"entry #{index} has invalid 'type': {entry['type']}")

    lat = float(entry["latitude"])
    lng = float(entry["longitude"])
    if not math.isfinite(lat) or not (-90.0 <= lat <= 90.0):
        fail(f"entry #{index} latitude out of range: {lat}")
    if not math.isfinite(lng) or not (-180.0 <= lng <= 180.0):
        fail(f"entry #{index} longitude out of range: {lng}")


def main() -> None:
    if not VENUES_PATH.exists():
        fail(f"file not found: {VENUES_PATH}")

    try:
        data = json.loads(VENUES_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON: {exc}")

    if not isinstance(data, list):
        fail("root JSON must be an array")
    if len(data) < 10:
        fail(f"dataset too small: expected >= 10 entries, got {len(data)}")

    seen_ids = set()
    for idx, entry in enumerate(data):
        if not isinstance(entry, dict):
            fail(f"entry #{idx} must be an object")
        validate_entry(entry, idx)
        identifier = UUID(entry["id"])
        if identifier in seen_ids:
            fail(f"entry #{idx} duplicates venue id: {identifier}")
        seen_ids.add(identifier)

    print(f"[venues-schema] OK: validated {len(data)} entries")


if __name__ == "__main__":
    main()
