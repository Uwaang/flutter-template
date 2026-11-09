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
done

adb exec-out screencap -p > "$evidence/screenshot.png" || true
adb logcat -d -v time | grep -Ei 'Flutter|Firebase|AndroidRuntime|FATAL EXCEPTION|FreeRASP|Talsec|SignIn|ANR' | tail -n 300 > "$evidence/logcat.txt" || true

if [[ "$found" -ne 1 ]]; then
  echo "FAIL: Mock Sign In not present after >= 100s" | tee "$evidence/result.txt"
  exit 1
fi
echo "PASS: Mock Sign In visible" | tee "$evidence/result.txt"
