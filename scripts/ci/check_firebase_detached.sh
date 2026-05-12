#!/usr/bin/env bash
set -euo pipefail

PROJECT_FILE="${PROJECT_FILE:-NOCTO.xcodeproj/project.pbxproj}"
PLIST_FILE="${PLIST_FILE:-NOCTO/GoogleService-Info.plist.example}"
REAL_PLIST_FILE="${REAL_PLIST_FILE:-NOCTO/GoogleService-Info.plist}"

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

if git ls-files --error-unmatch "$REAL_PLIST_FILE" >/dev/null 2>&1; then
  echo "❌ $REAL_PLIST_FILE is tracked by git."
  echo "error: the real Firebase plist must remain ignored and local-only."
  fail=1
fi

if [[ ! -f "$PLIST_FILE" ]]; then
  echo "❌ Missing $PLIST_FILE."
  fail=1
fi

check_plist_placeholder() {
  local key="$1"
  local expected="$2"
  local actual

  actual="$(/usr/libexec/PlistBuddy -c "Print :$key" "$PLIST_FILE" 2>/dev/null || true)"
  if [[ "$actual" != "$expected" ]]; then
    echo "❌ $PLIST_FILE placeholder mismatch for $key."
    echo "expected: $expected"
    echo "actual: ${actual:-<missing>}"
    fail=1
  fi
}

if [[ -f "$PLIST_FILE" ]]; then
  check_plist_placeholder "API_KEY" "REPLACE_ME"
  check_plist_placeholder "PROJECT_ID" "nocto-placeholder"
  check_plist_placeholder "GOOGLE_APP_ID" "1:000000000000:ios:placeholder"
  check_plist_placeholder "STORAGE_BUCKET" "nocto-placeholder.appspot.com"
  check_plist_placeholder "BUNDLE_ID" "com.mario.NOCTO"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "error: Firebase detachment guard failed."
  exit 1
fi

echo "✅ Firebase detachment guard passed."
