#!/usr/bin/env bash
# Renders the Mac App Store screenshots (2880x1800) on this Mac.
#
#   tool/mac_store_screenshots.sh <en|ar> <output-dir>
#
# Builds the app under a throwaway bundle ID for the run, so the seeded demo
# portfolio lands in its own sandbox container instead of a real Qima
# install's data (which iCloud would then sync to other devices).
set -euo pipefail

lang="${1:?en or ar}"
out="$(mkdir -p "${2:?output dir}" && cd "$2" && pwd)"
root="$(cd "$(dirname "$0")/.." && pwd)"
config="$root/macos/Runner/Configs/AppInfo.xcconfig"
project="$root/macos/Runner.xcodeproj/project.pbxproj"

cp "$config" "$config.bak"
cp "$project" "$project.bak"
trap 'mv "$config.bak" "$config"; mv "$project.bak" "$project"' EXIT
sed -i '' 's/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = com.devlabtechnologies.qima.screenshots/' "$config"
# The embedded widget's ID must stay prefixed by the app's.
sed -i '' 's/com\.devlabtechnologies\.qima\.widget;/com.devlabtechnologies.qima.screenshots.widget;/' "$project"

cd "$root"
flutter test integration_test/mac_store_screenshots_test.dart -d macos --dart-define=SCREENSHOT_LANG="$lang"

# The sandboxed app can only write inside its own container.
cp ~/Library/Containers/com.devlabtechnologies.qima.screenshots/Data/tmp/qima-store-screenshots/*.png "$out/"
ls -1 "$out"
