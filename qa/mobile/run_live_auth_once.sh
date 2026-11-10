#!/usr/bin/env bash
# One-time Android real Auth E2E. Never print tokens or stored session values.
set -euo pipefail
package="com.strv.flutter.template"
apk="build/app/outputs/flutter-apk/app-production-profile.apk"
xml_file="$(mktemp)"
trap 'rm -f "$xml_file"' EXIT

test -f "$apk"
dump_window() {
  adb shell uiautomator dump /sdcard/qa-live.xml >/dev/null 2>&1 || true
  adb exec-out cat /sdcard/qa-live.xml > "$xml_file" 2>/dev/null || true
}
wait_for_label() {
  local label="$1"
  for i in $(seq 1 18); do
    sleep 7
    dump_window
    if grep -Fq "$label" "$xml_file"; then
      echo "PASS: '$label' visible"
      return 0
    fi
  done
  echo "FAIL: '$label' not found in Android UI" >&2
  return 1
}
tap_label() {
  local label="$1" coords
  dump_window
  coords="$(python3 - "$xml_file" "$label" <<'PY'
import re, sys
from xml.etree import ElementTree as ET
try:
    root = ET.parse(sys.argv[1]).getroot()
except (ET.ParseError, OSError):
    sys.exit(2)
label = sys.argv[2]
nodes = list(root.iter("node"))
matches = [n for n in nodes if n.get("text") == label or n.get("content-desc") == label]
if not matches:
    matches = [n for n in nodes if label in (n.get("text") or "") or label in (n.get("content-desc") or "")]
for n in matches:
    m = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", n.get("bounds", ""))
    if m:
        x1,y1,x2,y2 = map(int,m.groups())
        if x2>x1 and y2>y1:
            print(f"{(x1+x2)//2} {(y1+y2)//2}")
            sys.exit(0)
sys.exit(2)
PY
)" || { echo "FAIL: cannot tap '$label'" >&2; return 1; }
  read -r x y <<< "$coords"
  adb shell input tap "$x" "$y"
}
launch() {
  adb shell am force-stop "$package" || true
  adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1 >/dev/null
}

adb shell input keyevent KEYCODE_HOME || true
sleep 15
adb install -r "$apk"
launch
wait_for_label "Sign in Anonymously"
tap_label "Sign in Anonymously"
wait_for_label "Profile"
launch
wait_for_label "Profile"
if grep -Fq "Sign in Anonymously" "$xml_file"; then
  echo "FAIL: login did not persist after Android process restart" >&2
  exit 1
fi
tap_label "Profile"
wait_for_label "Sign out"
tap_label "Sign out"
wait_for_label "Sign in Anonymously"
launch
wait_for_label "Sign in Anonymously"
echo "PASS: Android real anonymous login, app restart persistence, sign-out, signed-out relaunch"
