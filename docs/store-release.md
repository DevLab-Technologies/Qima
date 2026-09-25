# Store release runbook

How to ship Qima to the App Store and Google Play. The pipelines build, sign
and upload. Making a build public is a manual step in each store console.

| | iOS | Android |
|---|---|---|
| Workflow | `.github/workflows/testflight.yml` | `.github/workflows/play-store.yml` |
| Trigger | push tag `ios-v<version>+<build>` | push tag `android-v<version>+<build>` |
| Destination | TestFlight (internal testers) | Play **internal testing** track, as a draft |
| Build number | the `+build` in `pubspec.yaml` | versionCode derived from it: `2.1.1+1` → `2010101` |
| Manual dry run | Actions → TestFlight → Run workflow (builds and signs, no upload) | Actions → Play Store → Run workflow (builds and verifies, no upload) |

`pubspec.yaml`'s `version: <name>+<build>` is the one source of truth for the
version and build on every platform (iOS, macOS, Android, Windows, Linux). The
build restarts at 1 for each new version: `2.1.1+1`, `2.1.1+2`, then `2.1.2+1`.
The tag must match it exactly, or the workflow fails before building.

- **Apple** accepts a build number again under a new version, so it restarts
  at 1. The lanes check TestFlight first and fail with the next free number
  if the build is already taken.
- **Google Play** needs `versionCode` to rise across every version, so the
  lane derives it: major, then minor, patch and build at two digits each
  (`2.1.1+1` → `2010101`). Minor, patch and build must stay below 100.

## 1. One-time setup

### Apple

1. **App record**: App Store Connect → Apps → **+** → New App.
   - Bundle ID `com.devlabtechnologies.qima`, team `ZS3A435WC2`, primary language English (U.S.).
   - The API cannot create app records.
2. **API key**: Users and Access → Integrations → App Store Connect API → **+**, role *App Manager*.
   - `ASC_KEY_ID`: the key ID
   - `ASC_ISSUER_ID`: the issuer ID shown above the key list
   - `ASC_KEY_CONTENT`: `base64 -i AuthKey_XXXX.p8 | pbcopy`
3. **Distribution certificate**: Keychain Access → export the *Apple Distribution* certificate with its private key as `.p12`.
   - `IOS_DIST_CERT_BASE64`: `base64 -i dist.p12 | pbcopy`
   - `IOS_DIST_CERT_PASSWORD`: the export password
4. **Provisioning profiles**: developer.apple.com → Profiles → **+** → *App Store Connect*, one per bundle ID, both with the certificate above. Both App IDs need the App Group `group.com.devlabtechnologies.qima`; the app's also needs iCloud (key-value storage).
   - `IOS_PROVISION_PROFILE_BASE64`: the app, `com.devlabtechnologies.qima`: `base64 -i Qima_App_Store.mobileprovision | pbcopy`
   - `IOS_WIDGET_PROVISION_PROFILE_BASE64`: the widget extension, `com.devlabtechnologies.qima.widget`: `base64 -i Qima_Widget_App_Store.mobileprovision | pbcopy`
5. **macOS**: the Apple Distribution certificate above also signs the Mac app.
   - `MAC_INSTALLER_CERT_BASE64` / `MAC_INSTALLER_CERT_PASSWORD`: a *Mac Installer Distribution* certificate exported with its private key as `.p12` (it signs the `.pkg`).
   - `MACOS_PROVISION_PROFILE_BASE64`: a *Mac App Store Connect* profile for `com.devlabtechnologies.qima`: `base64 -i Qima_Mac_App_Store.provisionprofile | pbcopy`
   - `MACOS_WIDGET_PROVISION_PROFILE_BASE64`: the same for the widget extension, `com.devlabtechnologies.qima.widget`: `base64 -i Qima_Widget_Mac_App_Store.provisionprofile | pbcopy`
   - Upload with a `macos-v<version>+<build>` tag (`.github/workflows/testflight-macos.yml`).

Check the key without uploading: `cd ios && ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_CONTENT=… bundle exec fastlane ios preflight`.

### Google

1. **App**: Play Console → Create app → name *Qima*, app, free. Package `com.devlabtechnologies.qima` is fixed by the first upload.
2. **Service account**: Google Cloud → IAM → Service accounts → create → Keys → add key (JSON).
   - Play Console → Users and permissions → invite the service-account email.
   - Grant it *Release to testing tracks* and *Release apps to production* for Qima.
   - `PLAY_SERVICE_ACCOUNT_JSON`: the full JSON file contents.
3. Signing secrets (`ANDROID_KEYSTORE_*`, `ANDROID_KEY_*`) are already configured. Keep **Play App Signing** on; the keystore in CI is the *upload* key.

Check the key without uploading: `cd android && PLAY_SERVICE_ACCOUNT_JSON="$(cat key.json)" bundle exec fastlane android preflight`.

Add all secrets under GitHub → Settings → Secrets and variables → Actions.

## 2. Ship a version

```sh
git checkout main && git pull
V=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')   # e.g. 2.1.1+1
git tag "ios-v$V" && git tag "macos-v$V" && git tag "android-v$V"
git push origin "ios-v$V" "macos-v$V" "android-v$V"
```

For another build of the same version, bump only the build (`2.1.1+1` →
`2.1.1+2`), commit, and tag again.

Then promote:

- **Listing**: run the *Store listing* workflow once per release (see §3).
- **iOS**: TestFlight → add internal testers → test. Then App Store → the version → select the build → *Add for Review*.
- **Android**: Play Console → Testing → Internal testing → review the draft release → *Start rollout*. Then promote it to Production (or Closed testing first) → *Send for review*.
  - A new personal developer account must run a closed test with at least 12 testers for 14 days before production access unlocks.
  - Once the app is live, set the repository variable `PLAY_RELEASE_STATUS=completed` so internal uploads roll out without the manual step.

## 3. Store listing

Everything the listings need is in the repo, in fastlane's standard layout:

| | App Store | Google Play |
|---|---|---|
| Text | `ios/fastlane/metadata/<locale>/` (name, subtitle, promo text, keywords, description, release notes, URLs) | `android/fastlane/metadata/android/<locale>/` (title, short and full description, `changelogs/default.txt`) |
| Screenshots | `ios/fastlane/screenshots/{en-US,ar-SA}/`: iPhone 6.9" (1320×2868) and iPad 13" (2064×2752) | `.../{en-US,ar}/images/phoneScreenshots/` |
| Graphics | App icon comes from the build | `featureGraphic.png` (1024×500, localized), `en-US/images/icon.png` (512×512) |

Text is in en, ar, es and fr. Screenshots are in English and Arabic; Spanish
and French listings fall back to the English ones.

**Upload the listing:** Actions → *Store listing* → Run workflow (choose a
store). It runs `fastlane ios metadata` / `fastlane android metadata`. These
lanes only touch listing content: they never upload a build, change a release
or submit for review. The App Store lane targets the version in `pubspec.yaml`
and creates it in App Store Connect if needed.

**Regenerate screenshots** after UI changes (needs Xcode simulators):

```sh
tool/store_screenshots.sh <iphone-6.9-udid> en captures/iphone-en
tool/store_screenshots.sh <iphone-6.9-udid> ar captures/iphone-ar
tool/store_screenshots.sh <ipad-13-udid>    en captures/ipad-en
tool/store_screenshots.sh <ipad-13-udid>    ar captures/ipad-ar
python3 tool/store_assets.py captures   # needs Pillow with libraqm
```

`integration_test/store_screenshots_test.dart` seeds a demo watchlist and
holdings and walks through the screens with live prices. The shell script
captures the simulator (with a 9:41 status bar) at each step, and
`store_assets.py` files the images into both stores' folders and draws the
feature graphics.

Not covered: Play **Wear OS** screenshots. Only opt in to Wear distribution
if you add them.

## 4. Console questionnaires

These answers follow from the [privacy policy](https://qima.devlabtechnologies.com/privacy): no accounts, no backend, no analytics, ads or tracking SDKs, and holdings kept on the device.

### App Store Connect

| Question | Answer |
|---|---|
| App Privacy → Data collection | **Data Not Collected** |
| Tracking (ATT) | No |
| Export compliance | Standard HTTPS only; `ITSAppUsesNonExemptEncryption` is already `false` in `Info.plist`, so no prompt |
| Age rating | 4+ (no objectionable content, no gambling, no unrestricted web access) |
| Primary category | Finance |
| Price | Free |
| Sign-in required for review | No (note: *"No account needed. Add an instrument with the + button; holdings are optional."*) |
| Privacy policy URL | https://qima.devlabtechnologies.com/privacy |
| Support URL | https://github.com/DevLab-Technologies/Qima/issues |

### Google Play Console

| Section | Answer |
|---|---|
| Data safety → collects or shares user data | **No**. The only network traffic is read-only requests for public market prices, with no user data attached. |
| Data safety → encrypted in transit | Yes (HTTPS) |
| Data safety → deletion request | Not applicable: no data leaves the device; uninstalling removes it |
| Ads | No ads |
| Content rating (IARC) | Reference app / utility; no violence, sexual content, gambling or user interaction → *Everyone* / PEGI 3 |
| Target audience | 18+ (financial tool; not designed for children) |
| Financial features declaration | Market data / portfolio tracking only. No trading, payments, loans, custody or crypto wallet. |
| News app | No |
| Government app | No |
| App category | Finance |
| Wear OS | The manifest declares a standalone Wear app. Opt in under *Advanced settings → Form factors* only if you provide Wear screenshots; otherwise leave it off. |
