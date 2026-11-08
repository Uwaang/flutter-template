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
  maestro test qa/mobile/startup.yaml
  result=$?
fi

adb exec-out screencap -p > "$evidence/screenshot.png" || true
adb logcat -d -v time | grep -E 'Flutter|flutter|Firebase|AndroidRuntime|FATAL EXCEPTION|FreeRASP|Talsec|SignIn' | tail -n 500 > "$evidence/logcat-excerpt.txt" || true
echo "result=$result" | tee "$evidence/outcome.txt"
exit "$result"
