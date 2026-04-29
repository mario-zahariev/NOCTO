#!/usr/bin/env python3

import json
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


def validate_entry(entry: dict, index: int) -> None:
    missing = [key for key in REQUIRED_FIELDS if key not in entry]
    if missing:
        fail(f"entry #{index} missing fields: {', '.join(missing)}")

    for field, field_type in REQUIRED_FIELDS.items():
        value = entry[field]
        if not isinstance(value, field_type):
            fail(f"entry #{index} field '{field}' has invalid type: {type(value).__name__}")

    if not entry["name"].strip():
        fail(f"entry #{index} has empty 'name'")
    if not entry["imageName"].strip():
        fail(f"entry #{index} has empty 'imageName'")
    if not entry["address"].strip():
        fail(f"entry #{index} has empty 'address'")
    if not entry["workingHours"].strip():
        fail(f"entry #{index} has empty 'workingHours'")

    try:
        UUID(entry["id"])
    except ValueError as exc:
        fail(f"entry #{index} has invalid UUID in 'id': {exc}")

    if entry["type"] not in ALLOWED_TYPES:
        fail(f"entry #{index} has invalid 'type': {entry['type']}")

    lat = float(entry["latitude"])
    lng = float(entry["longitude"])
    if not (-90.0 <= lat <= 90.0):
        fail(f"entry #{index} latitude out of range: {lat}")
    if not (-180.0 <= lng <= 180.0):
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

    for idx, entry in enumerate(data):
        if not isinstance(entry, dict):
            fail(f"entry #{idx} must be an object")
        validate_entry(entry, idx)

    print(f"[venues-schema] OK: validated {len(data)} entries")


if __name__ == "__main__":
    main()
