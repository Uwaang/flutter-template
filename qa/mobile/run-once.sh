#!/usr/bin/env bash
set -uo pipefail

evidence="qa/mobile/evidence"
mkdir -p "$evidence"
apk="$(find ci-apk -type f -name '*.apk' -print -quit)"
if [[ -z "$apk" ]]; then
  echo "APK missing from downloaded artifact" | tee "$evidence/outcome.txt"
  exit 2
fi

# Inspect the emulator *before* installing the app. The previous run showed
# "Pixel Launcher isn't responding", so distinguish host/emulator health from
# the app's own startup state without disabling any app security checks.
set +e
{
  echo "sys.boot_completed: $(adb shell getprop sys.boot_completed)"
  echo "Android SDK: $(adb shell getprop ro.build.version.sdk)"
  echo "Free memory (kB):"
  adb shell cat /proc/meminfo | head -n 6
} > "$evidence/emulator-before.txt" 2>&1
adb shell input keyevent KEYCODE_HOME
sleep 3
adb shell uiautomator dump /sdcard/qa-home.xml
adb exec-out cat /sdcard/qa-home.xml > "$evidence/home-before.xml" || true
adb exec-out screencap -p > "$evidence/home-before.png" || true
adb shell dumpsys activity activities > "$evidence/activity-before.txt" || true

# Fresh Google APIs emulators can report boot_completed before the launcher
# finishes drawing. Recheck the HOME UI once, before installing our APK.
sleep 15
adb shell uiautomator dump /sdcard/qa-home-settled.xml || true
adb exec-out cat /sdcard/qa-home-settled.xml > "$evidence/home-settled.xml" || true
adb exec-out screencap -p > "$evidence/home-settled.png" || true
adb shell dumpsys activity activities > "$evidence/activity-home-settled.txt" || true

adb install -r "$apk"
result=$?
if [[ "$result" -eq 0 ]]; then
  adb shell am force-stop com.strv.flutter.template
  adb shell monkey -p com.strv.flutter.template -c android.intent.category.LAUNCHER 1

  # Keep the previous 100-second window to make consecutive runs comparable.
  result=1
  for attempt in $(seq 1 10); do
    sleep 10
    elapsed=$((attempt * 10))
    adb shell uiautomator dump /sdcard/qa-window.xml
    adb exec-out cat /sdcard/qa-window.xml > "$evidence/ui-hierarchy.xml"
    if grep -q 'Mock Sign In' "$evidence/ui-hierarchy.xml"; then
      echo "PASS: Mock Sign In visible in Android UI hierarchy (after >= ${elapsed}s)"
      result=0
      break
    fi
    echo "Not yet visible after >= ${elapsed}s; continuing startup check"
  done
  if [[ "$result" -ne 0 ]]; then
    echo "FAIL: Mock Sign In not present after >= 100s in Android UI hierarchy"
  fi
fi

adb exec-out screencap -p > "$evidence/screenshot.png" || true
adb shell dumpsys activity activities > "$evidence/activity-after.txt" || true
adb shell dumpsys meminfo com.strv.flutter.template > "$evidence/app-memory.txt" || true
adb shell dumpsys meminfo com.google.android.apps.nexuslauncher > "$evidence/launcher-memory.txt" || true
adb shell pidof com.strv.flutter.template > "$evidence/app-pid.txt" || true

# Preserve context as well as the targeted trace, including potential Android
# system_server / launcher ANR messages omitted by the previous Flutter-only filter.
adb logcat -d -v time | tail -n 5000 > "$evidence/logcat-tail.txt" || true
adb logcat -d -v time | grep -Ei 'QA_STARTUP|Flutter|Firebase|AndroidRuntime|FATAL EXCEPTION|FreeRASP|Talsec|SignIn|ANR|not responding|lmkd|lowmemorykiller|ActivityManager|ActivityTaskManager' | tail -n 1200 > "$evidence/logcat-excerpt.txt" || true

echo "result=$result" | tee "$evidence/outcome.txt"
exit "$result"
