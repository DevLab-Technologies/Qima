#!/usr/bin/env bash
# Captures store screenshots from a booted iOS simulator.
#
#   tool/store_screenshots.sh <simulator-udid> <en|ar> <output-dir>
#
# Runs integration_test/store_screenshots_test.dart against the simulator and
# grabs a full-device PNG (status bar included) each time the test prints a
# QIMA_SCREENSHOT marker. Use an iPhone 6.9" simulator (1320x2868) and an iPad
# 13" simulator (2064x2752) to get the sizes App Store Connect requires.
set -euo pipefail

udid="${1:?simulator udid}"
lang="${2:?en or ar}"
out="${3:?output dir}"
mkdir -p "$out"

xcrun simctl bootstatus "$udid" -b >/dev/null
xcrun simctl status_bar "$udid" override --time "9:41" --dataNetwork wifi --wifiMode active \
  --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
trap 'xcrun simctl status_bar "$udid" clear' EXIT

flutter test integration_test/store_screenshots_test.dart -d "$udid" \
  --dart-define=SCREENSHOT_LANG="$lang" 2>&1 | while IFS= read -r line; do
  echo "$line"
  if [[ "$line" =~ QIMA_SCREENSHOT[[:space:]]+([A-Za-z0-9_]+) ]]; then
    xcrun simctl io "$udid" screenshot --type=png "$out/${BASH_REMATCH[1]}.png" >/dev/null 2>&1 \
      && echo ">> captured $out/${BASH_REMATCH[1]}.png"
  fi
done
exit "${PIPESTATUS[0]}"
