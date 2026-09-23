fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios preflight

```sh
[bundle exec] fastlane ios preflight
```

Read-only: confirm the App Store Connect API key authenticates and report whether the app record already exists.

### ios setup_signing

```sh
[bundle exec] fastlane ios setup_signing
```

Import a distribution certificate (.p12) and provisioning profile (.mobileprovision) from base64 secrets into a throwaway CI keychain, then switch Runner to manual signing.

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build the release IPA and upload it to TestFlight. Requires QIMA_BUILD_NUMBER (CI passes github.run_number, or latest_testflight_build_number + 1).

### ios build_only

```sh
[bundle exec] fastlane ios build_only
```

Build and code-sign the release IPA WITHOUT uploading. Used for workflow_dispatch validation runs so a broken secret fails privately, not on a public tag.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
