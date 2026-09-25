#!/usr/bin/env bash
# Renders the Mac App Store media on this Mac, from the real app.
#
#   tool/mac_store_media.sh screenshots <en|ar> <output-dir>   2880x1800 PNGs
#   tool/mac_store_media.sh preview <output.mp4>               1920x1080 app preview
#
# Builds the app under a throwaway bundle ID for the run, so the seeded demo
# portfolio lands in its own data instead of a real Qima install's (which
# iCloud would then sync to other devices). The preview run also drops the
# sandbox so the app can stream its frames to ffmpeg.
set -euo pipefail

mode="${1:?screenshots or preview}"
root="$(cd "$(dirname "$0")/.." && pwd)"
config="$root/macos/Runner/Configs/AppInfo.xcconfig"
project="$root/macos/Runner.xcodeproj/project.pbxproj"
entitlements="$root/macos/Runner/DebugProfile.entitlements"

for file in "$config" "$project" "$entitlements"; do cp "$file" "$file.bak"; done
trap 'for file in "$config" "$project" "$entitlements"; do mv "$file.bak" "$file"; done' EXIT
sed -i '' 's/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = com.devlabtechnologies.qima.screenshots/' "$config"
# The embedded widget's ID must stay prefixed by the app's.
sed -i '' 's/com\.devlabtechnologies\.qima\.widget;/com.devlabtechnologies.qima.screenshots.widget;/' "$project"

cd "$root"
case "$mode" in
  screenshots)
    lang="${2:?en or ar}"
    out="$(mkdir -p "${3:?output dir}" && cd "$3" && pwd)"
    flutter test integration_test/mac_store_screenshots_test.dart -d macos --dart-define=SCREENSHOT_LANG="$lang"
    # The sandboxed app can only write inside its own container.
    cp ~/Library/Containers/com.devlabtechnologies.qima.screenshots/Data/tmp/qima-store-screenshots/*.png "$out/"
    ls -1 "$out"
    ;;
  preview)
    out="${2:?output .mp4}"
    out="$(mkdir -p "$(dirname "$out")" && cd "$(dirname "$out")" && pwd)/$(basename "$out")"
    /usr/libexec/PlistBuddy -c "Set :com.apple.security.app-sandbox false" "$entitlements"
    raw="${out%.*}.lossless.mp4"
    flutter test integration_test/mac_store_preview_test.dart -d macos --dart-define=PREVIEW_OUTPUT="$raw"
    # App Store Connect: H.264 High, 1920x1080, 30 fps, with a (silent) AAC track.
    ffmpeg -y -loglevel error -i "$raw" -f lavfi -i anullsrc=r=44100:cl=stereo -shortest \
      -c:v libx264 -profile:v high -pix_fmt yuv420p -preset slow -crf 16 -r 30 \
      -c:a aac -b:a 128k -movflags +faststart "$out"
    rm -f "$raw"
    ls -lh "$out"
    ;;
  *)
    echo "Unknown mode: $mode" >&2
    exit 64
    ;;
esac
