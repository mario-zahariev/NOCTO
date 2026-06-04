#!/usr/bin/env bash
set -euo pipefail

WORKFLOWS_DIR="${WORKFLOWS_DIR:-.github/workflows}"

if [[ ! -d "$WORKFLOWS_DIR" ]]; then
  echo "error: missing workflows directory: $WORKFLOWS_DIR"
  exit 1
fi

fail=0

while IFS= read -r line; do
  file="${line%%:*}"
  rest="${line#*:}"
  line_number="${rest%%:*}"
  value="${rest#*:}"
  value="${value#*uses:}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"

  if [[ "$value" == ./* ]]; then
    continue
  fi

  if [[ ! "$value" =~ @[0-9a-f]{40}$ ]]; then
    echo "error: mutable or unpinned action reference at $file:$line_number -> $value"
    echo "hint: pin external actions to a full 40-character commit SHA."
    fail=1
  fi
done < <(grep -RInE '^[[:space:]]*uses:[[:space:]]*' "$WORKFLOWS_DIR" || true)

while IFS= read -r line; do
  file="${line%%:*}"
  rest="${line#*:}"
  line_number="${rest%%:*}"
  value="${rest#*:}"
  value="${value#*image:}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"

  if [[ ! "$value" =~ @sha256:[0-9a-f]{64}$ ]]; then
    echo "error: mutable or unpinned container image at $file:$line_number -> $value"
    echo "hint: pin container images to a sha256 digest."
    fail=1
  fi
done < <(grep -RInE '^[[:space:]]*image:[[:space:]]*' "$WORKFLOWS_DIR" || true)

if [[ "$fail" -ne 0 ]]; then
  echo "error: GitHub Actions pinning guard failed."
  exit 1
fi

echo "GitHub Actions pinning guard passed."
