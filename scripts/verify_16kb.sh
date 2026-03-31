#!/usr/bin/env bash
set -euo pipefail

AAB_PATH="${1:-build/app/outputs/bundle/release/app-release.aab}"
APK_PATH="${2:-build/app/outputs/flutter-apk/app-release.apk}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

read_sdk_from_local_properties() {
  local local_props="$ROOT_DIR/android/local.properties"
  if [[ -f "$local_props" ]]; then
    local raw
    raw="$(grep -E '^sdk.dir=' "$local_props" | head -n1 | cut -d'=' -f2- || true)"
    # local.properties may escape slashes like /home/user/Android/Sdk
    raw="${raw//\\//}"
    printf '%s' "$raw"
    return 0
  fi
  return 1
}

SDK_DIR="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$SDK_DIR" ]]; then
  SDK_DIR="$(read_sdk_from_local_properties || true)"
fi

resolve_adb() {
  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi
  if [[ -n "$SDK_DIR" && -x "$SDK_DIR/platform-tools/adb" ]]; then
    printf '%s' "$SDK_DIR/platform-tools/adb"
    return 0
  fi
  return 1
}

resolve_zipalign() {
  if command -v zipalign >/dev/null 2>&1; then
    command -v zipalign
    return 0
  fi
  if [[ -n "$SDK_DIR" && -d "$SDK_DIR/build-tools" ]]; then
    local latest_bt
    latest_bt="$(ls -1 "$SDK_DIR/build-tools" 2>/dev/null | sort -V | tail -n1 || true)"
    if [[ -n "$latest_bt" && -x "$SDK_DIR/build-tools/$latest_bt/zipalign" ]]; then
      printf '%s' "$SDK_DIR/build-tools/$latest_bt/zipalign"
      return 0
    fi
  fi
  return 1
}

run_bundletool_dump() {
  if command -v bundletool >/dev/null 2>&1; then
    bundletool dump config --bundle="$AAB_PATH" | grep alignment || true
    return 0
  fi

  local bt_jar="${BUNDLETOOL_JAR:-$ROOT_DIR/tools/bundletool.jar}"
  if [[ -f "$bt_jar" ]]; then
    java -jar "$bt_jar" dump config --bundle="$AAB_PATH" | grep alignment || true
    return 0
  fi

  return 1
}

print_install_hints() {
  cat <<'EOF'
Kurulum onerisi (Linux):
1) Android cmdline-tools yukleyin (Android Studio > SDK Manager veya cmdline-tools).
2) Sonra su paketleri yukleyin:
   sdkmanager "platform-tools" "build-tools;36.0.0"
3) bundletool icin:
   - ya PATH'e `bundletool` binary ekleyin
   - ya da `tools/bundletool.jar` koyup scripti tekrar calistirin
     (alternatif: BUNDLETOOL_JAR=/tam/yol/bundletool.jar)

Ornek PATH (bash):
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/build-tools/36.0.0:$PATH"
EOF
}

echo "[1/3] AAB alignment check"
if [[ ! -f "$AAB_PATH" ]]; then
  echo "AAB bulunamadi: $AAB_PATH"
elif run_bundletool_dump; then
  :
else
  echo "bundletool bulunamadi. Kurun ve tekrar deneyin."
fi

echo "[2/3] APK zipalign (16 KB) check"
if [[ ! -f "$APK_PATH" ]]; then
  echo "APK bulunamadi: $APK_PATH"
elif ZIPALIGN_BIN="$(resolve_zipalign || true)"; [[ -n "${ZIPALIGN_BIN:-}" ]]; then
  "$ZIPALIGN_BIN" -c -P 16 -v 4 "$APK_PATH"
else
  echo "zipalign bulunamadi. Android Build-Tools yukleyin."
fi

echo "[3/3] Device page size check"
if ADB_BIN="$(resolve_adb || true)"; [[ -n "${ADB_BIN:-}" ]]; then
  "$ADB_BIN" shell getconf PAGE_SIZE || true
else
  echo "adb bulunamadi. Android Platform-Tools yukleyin."
fi

echo
print_install_hints

