#!/usr/bin/env bash
set -euo pipefail

AAB_PATH="${1:-build/app/outputs/bundle/release/app-release.aab}"
APK_PATH="${2:-build/app/outputs/flutter-apk/app-release.apk}"

echo "[1/3] AAB alignment check"
if command -v bundletool >/dev/null 2>&1; then
  bundletool dump config --bundle="$AAB_PATH" | grep alignment || true
else
  echo "bundletool bulunamadi. Kurun ve tekrar deneyin."
fi

echo "[2/3] APK zipalign (16 KB) check"
if command -v zipalign >/dev/null 2>&1; then
  zipalign -c -P 16 -v 4 "$APK_PATH"
else
  echo "zipalign bulunamadi. Android Build-Tools yukleyin."
fi

echo "[3/3] Device page size check"
if command -v adb >/dev/null 2>&1; then
  adb shell getconf PAGE_SIZE || true
else
  echo "adb bulunamadi. Android Platform-Tools yukleyin."
fi

