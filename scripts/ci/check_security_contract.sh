#!/usr/bin/env bash
set -euo pipefail

required_files=(
  ".gitleaks.toml"
  ".semgrep.yml"
  ".pre-commit-config.yaml"
  "Package.resolved"
  "SECURITY.md"
  ".github/CODEOWNERS"
  ".github/dependabot.yml"
  ".github/pull_request_template.md"
  ".github/workflows/ci.yml"
  ".github/workflows/gitleaks.yml"
  ".github/workflows/semgrep.yml"
  "scripts/ci/check_firebase_detached.sh"
  "scripts/ci/check_github_actions_pinned.sh"
  "scripts/ci/check_security_contract.sh"
)

fail=0

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "error: required security contract file is missing: $file"
    fail=1
  fi
done

if git check-ignore -q Package.resolved; then
  echo "error: Package.resolved is ignored by git; dependency lockfile must remain tracked."
  fail=1
fi

if ! grep -q 'id: gitleaks' .pre-commit-config.yaml; then
  echo "error: pre-commit config must include the gitleaks hook."
  fail=1
fi

if ! grep -q 'semgrep --config .semgrep.yml --error' .pre-commit-config.yaml; then
  echo "error: pre-commit config must include the local Semgrep security hook."
  fail=1
fi

if ! grep -q 'GITLEAKS_CONFIG: .gitleaks.toml' .github/workflows/gitleaks.yml; then
  echo "error: gitleaks workflow must use the checked-in .gitleaks.toml config."
  fail=1
fi

if ! grep -q 'semgrep scan --config .semgrep.yml --error' .github/workflows/semgrep.yml; then
  echo "error: semgrep workflow must use the checked-in .semgrep.yml config with --error."
  fail=1
fi

if ! grep -q 'check_firebase_detached.sh' .github/workflows/ci.yml; then
  echo "error: CI must keep the Firebase detachment guard."
  fail=1
fi

if ! grep -q 'swift test' .github/workflows/ci.yml; then
  echo "error: CI must keep swift test."
  fail=1
fi

if ! grep -q 'NOCTOUITests' .github/workflows/ci.yml; then
  echo "error: CI must keep the NOCTOUITests visual integrity gate."
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "error: security contract guard failed."
  exit 1
fi

echo "Security contract guard passed."
