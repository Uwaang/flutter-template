#!/usr/bin/env bash
set -uo pipefail

evidence="qa/mobile/evidence"
mkdir -p "$evidence"
apk="build/app/outputs/flutter-apk/app-production-profile.apk"

if [[ ! -f "$apk" ]]; then
  echo "FAIL: compiled profile APK missing" | tee "$evidence/result.txt"
  exit 2
fi

# The emulator may report boot_completed before the launcher is ready.
adb shell input keyevent KEYCODE_HOME || true
sleep 15
if ! adb install -r "$apk"; then
  echo "FAIL: APK install failed" | tee "$evidence/result.txt"
  exit 2
fi
adb shell am force-stop com.strv.flutter.template || true
adb shell monkey -p com.strv.flutter.template -c android.intent.category.LAUNCHER 1

found=0
for attempt in $(seq 1 10); do
  sleep 10
  adb shell uiautomator dump /sdcard/qa-window.xml || true
  adb exec-out cat /sdcard/qa-window.xml > "$evidence/ui-hierarchy.xml" || true
  if grep -q 'Mock Sign In' "$evidence/ui-hierarchy.xml"; then
    echo "PASS: real Android authentication screen visible (after >= $((attempt * 10))s)"
    found=1
    break
  fi

  # An Android *system* ANR dialog can cover a correctly rendered Flutter UI.
  # Only dismiss the known Pixel Launcher dialog; never dismiss app failures.
  if grep -q "Pixel Launcher isn" "$evidence/ui-hierarchy.xml"; then
    coords="$(python3 - "$evidence/ui-hierarchy.xml" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET

try:
    root = ET.parse(sys.argv[1]).getroot()
except (ET.ParseError, OSError):
    sys.exit(0)

nodes = list(root.iter("node"))
if not any(n.get("text") == "Pixel Launcher isn't responding" for n in nodes):
    sys.exit(0)
for node in nodes:
    if node.get("resource-id") == "android:id/aerr_close" and node.get("text") == "Close app":
        match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", node.get("bounds", ""))
        if match:
            x1, y1, x2, y2 = map(int, match.groups())
            print(f"{(x1 + x2) // 2} {(y1 + y2) // 2}")
        break
PY
)"
    if [[ "$coords" =~ ^[0-9]+\ [0-9]+$ ]]; then
      echo "WARN: Pixel Launcher ANR covered app UI; closing *launcher* dialog once"
      adb exec-out screencap -p > "$evidence/launcher-anr.png" || true
      read -r tap_x tap_y <<< "$coords"
      adb shell input tap "$tap_x" "$tap_y" || true
      sleep 2
      adb shell am start -n com.strv.flutter.template/.MainActivity || true
    fi
  fi
done

adb exec-out screencap -p > "$evidence/screenshot.png" || true
adb logcat -d -v time | grep -Ei 'Flutter|Firebase|AndroidRuntime|FATAL EXCEPTION|FreeRASP|Talsec|SignIn|ANR' | tail -n 300 > "$evidence/logcat.txt" || true

if [[ "$found" -ne 1 ]]; then
  echo "FAIL: Mock Sign In not present after >= 100s" | tee "$evidence/result.txt"
  exit 1
fi
echo "PASS: Mock Sign In visible" | tee "$evidence/result.txt"
