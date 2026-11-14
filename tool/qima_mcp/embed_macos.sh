#!/bin/bash
# Builds qima-mcp and embeds it, signed, as
# Qima.app/Contents/Helpers/QimaMCP.app/Contents/MacOS/qima-mcp.
# Runs as a Runner build phase, after Flutter embeds its frameworks and before
# Xcode signs the app (which seals the already-signed helper).
#
# - It is a tiny app bundle, not a bare tool, because a sandboxed process
#   needs an Info.plist with a bundle id; a bare sandboxed tool traps at launch.
# - Dart's AOT runtime maps its code at launch, so under the hardened runtime
#   it needs allow-unsigned-executable-memory (allow-jit is not enough).
# - Mac App Store build (the app's entitlements have an App Group): sandboxed
#   and in the same group, where the app writes the shared copy. Any other
#   build: not sandboxed, so it reads the copy in Qima's own container
#   (macOS asks the person once).
set -euo pipefail

: "${FLUTTER_ROOT:?}" "${SRCROOT:?}" "${TARGET_BUILD_DIR:?}" "${WRAPPER_NAME:?}"

repo="$SRCROOT/.."
pkg="$repo/tool/qima_mcp"
dart="$FLUTTER_ROOT/bin/dart"
bundle="$TARGET_BUILD_DIR/$WRAPPER_NAME/Contents/Helpers/QimaMCP.app"
version="$(sed -n 's/^version: *//p' "$repo/pubspec.yaml" | head -1)"

rm -rf "$bundle"
mkdir -p "$bundle/Contents/MacOS"
(cd "$pkg" && { "$dart" pub get --offline >/dev/null 2>&1 || "$dart" pub get >/dev/null; })
"$dart" compile exe "$pkg/bin/qima_mcp.dart" -DQIMA_VERSION="$version" \
  -o "$bundle/Contents/MacOS/qima-mcp" --verbosity=error

cat > "$bundle/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>com.devlabtechnologies.qima.mcp</string>
	<key>CFBundleExecutable</key>
	<string>qima-mcp</string>
	<key>CFBundleName</key>
	<string>Qima MCP</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>${version%%+*}</string>
	<key>CFBundleVersion</key>
	<string>${version##*+}</string>
	<key>LSMinimumSystemVersion</key>
	<string>${MACOSX_DEPLOYMENT_TARGET:-10.15}</string>
	<key>LSUIElement</key>
	<true/>
</dict>
</plist>
PLIST

identity="${EXPANDED_CODE_SIGN_IDENTITY:-}"
if [ -z "$identity" ] || [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ]; then
  echo "qima-mcp: embedded unsigned (code signing is off for this build)"
  exit 0
fi

entitlements="${DERIVED_FILE_DIR:-$TARGET_TEMP_DIR}/qima-mcp.entitlements"
mkdir -p "$(dirname "$entitlements")"
app_entitlements="$SRCROOT/${CODE_SIGN_ENTITLEMENTS:-}"
sandbox=""
if [ -f "$app_entitlements" ] && grep -q "com.apple.security.application-groups" "$app_entitlements"; then
  sandbox="	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>${DEVELOPMENT_TEAM:?}.com.devlabtechnologies.qima</string>
	</array>"
fi
cat > "$entitlements" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
	<true/>
$sandbox
</dict>
</plist>
PLIST

# Notarization needs a secure timestamp; local debug builds skip the round trip.
timestamp="--timestamp=none"
if [ "$identity" != "-" ] && [ "${CONFIGURATION:-}" = "Release" ]; then timestamp="--timestamp"; fi
codesign --force --options runtime "$timestamp" \
  --entitlements "$entitlements" --sign "$identity" "$bundle"
echo "qima-mcp: embedded and signed${sandbox:+ (sandboxed, App Group)}"
