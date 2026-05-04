#!/usr/bin/env bash
set -euo pipefail

PROJECT_FILE="${PROJECT_FILE:-NOCTO.xcodeproj/project.pbxproj}"
FIREBASE_PLIST="${FIREBASE_PLIST:-NOCTO/GoogleService-Info.plist}"

if [[ ! -f "$PROJECT_FILE" ]]; then
  echo "error: missing $PROJECT_FILE"
  exit 1
fi

fail=0

check_absent() {
  local pattern="$1"
  local message="$2"
  if grep -qF "$pattern" "$PROJECT_FILE"; then
    echo "❌ $message"
    grep -nF "$pattern" "$PROJECT_FILE" || true
    fail=1
  fi
}

check_absent "firebase-ios-sdk" "Found firebase-ios-sdk reference in Xcode project."
check_absent "FirebaseAnalytics" "Found FirebaseAnalytics linkage marker in Xcode project."
check_absent "FirebaseFirestore" "Found FirebaseFirestore linkage marker in Xcode project."
check_absent "GoogleService-Info.plist in Resources" "Found GoogleService-Info.plist inside Build Resources."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "⚠️  Not inside a git working tree; skipping tracked Firebase plist check."
else
  if git ls-files --error-unmatch "$FIREBASE_PLIST" >/dev/null 2>&1; then
    echo "❌ Found tracked Firebase config plist: $FIREBASE_PLIST"
    echo "Keep only GoogleService-Info.plist.example in git; real plist files must remain local-only."
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "error: Firebase detachment guard failed."
  exit 1
fi

echo "✅ Firebase detachment guard passed."
