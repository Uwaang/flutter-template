#!/usr/bin/env bash
set -uo pipefail

evidence="qa/mobile/evidence"
mkdir -p "$evidence"
apk="$(find ci-apk -type f -name '*.apk' -print -quit)"
if [[ -z "$apk" ]]; then
  echo "APK missing from downloaded artifact" | tee "$evidence/outcome.txt"
  exit 2
fi

set +e
adb install -r "$apk"
result=$?
if [[ "$result" -eq 0 ]]; then
  adb shell am force-stop com.strv.flutter.template
  adb shell monkey -p com.strv.flutter.template -c android.intent.category.LAUNCHER 1
  sleep 15
  adb shell uiautomator dump /sdcard/qa-window.xml
  adb exec-out cat /sdcard/qa-window.xml > "$evidence/ui-hierarchy.xml"
  if grep -q 'Mock Sign In' "$evidence/ui-hierarchy.xml"; then
    echo "PASS: Mock Sign In visible in Android UI hierarchy"
    result=0
  else
    echo "FAIL: Mock Sign In not present in Android UI hierarchy"
    result=1
  fi
fi

adb exec-out screencap -p > "$evidence/screenshot.png" || true
adb logcat -d -v time | grep -E 'Flutter|flutter|Firebase|AndroidRuntime|FATAL EXCEPTION|FreeRASP|Talsec|SignIn' | tail -n 500 > "$evidence/logcat-excerpt.txt" || true
echo "result=$result" | tee "$evidence/outcome.txt"
exit "$result"
