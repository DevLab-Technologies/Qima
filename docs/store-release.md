# Store release runbook

How to ship Qima to the App Store and Google Play. The pipelines build, sign
and upload. Making a build public is a manual step in each store console.

| | iOS | Android |
|---|---|---|
| Workflow | `.github/workflows/testflight.yml` | `.github/workflows/play-store.yml` |
| Trigger | push tag `ios-v<version>` | push tag `android-v<version>` |
| Destination | TestFlight (internal testers) | Play **internal testing** track, as a draft |
| Build number | GitHub run number | highest versionCode on Play + 1 |
| Manual dry run | Actions → TestFlight → Run workflow (builds and signs, no upload) | Actions → Play Store → Run workflow (builds and verifies, no upload) |

`pubspec.yaml`'s `version:` is the source of truth for the version name. The
tag must match it, or the workflow fails before building.

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
4. **Provisioning profile**: developer.apple.com → Profiles → **+** → *App Store Connect*, for the bundle ID and certificate above.
   - `IOS_PROVISION_PROFILE_BASE64`: `base64 -i Qima_AppStore.mobileprovision | pbcopy`

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
V=$(grep -E '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)   # e.g. 1.1.0
git tag "ios-v$V" && git tag "android-v$V"
git push origin "ios-v$V" "android-v$V"
```

Then promote:

- **iOS**: TestFlight → add internal testers → test. Then App Store → the version → select the build → *Add for Review*.
- **Android**: Play Console → Testing → Internal testing → review the draft release → *Start rollout*. Then promote it to Production (or Closed testing first) → *Send for review*.
  - A new personal developer account must run a closed test with at least 12 testers for 14 days before production access unlocks.
  - Once the app is live, set the repository variable `PLAY_RELEASE_STATUS=completed` so internal uploads roll out without the manual step.

## 3. Store listing

The listing text lives in fastlane's standard layout, in the four app languages:

- iOS: `ios/fastlane/metadata/<locale>/` holds name, subtitle, promotional text, keywords, description, release notes and URLs.
- Android: `android/fastlane/metadata/android/<locale>/` holds title, short and full description, and `changelogs/default.txt`.

The upload lanes currently skip metadata (`skip_upload_metadata: true`), so paste
these into the consoles for the first release. Every file is within its store's
character limit.

Still needed, and not in the repo:

- **Screenshots**
  - iPhone 6.9" (1320×2868) — required
  - iPad 13" — required, because the app runs on iPad
  - Play phone — at least 2
  - Play Wear OS — only if Wear distribution is enabled
- **Play feature graphic**: 1024×500.
- **App icon**: iOS takes it from the build. Play needs a 512×512 PNG; export it from `assets/icon/app_icon.png`.

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
