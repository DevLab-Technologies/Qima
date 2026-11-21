# Security Policy

## Supported versions

Only the latest release in the stores, and `main`, receive fixes. Older
versions and release branches are not maintained; update to the latest
version.

## Reporting a vulnerability

Please do not open a public issue for a security problem.

Report it by email to it@devlabtechnologies.com, or through GitHub's [private
vulnerability
reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
on this repository when the "Report a vulnerability" button is shown on its
Security tab. Include what you found, how to reproduce it, and the affected
version or commit.

You can expect an acknowledgement within a week, and an assessment with a fix
or a decision shortly after.

## Scope notes

Qima has no server and no accounts. Everything of value is the person's own
financial record on their device, so the interesting surface is:

- **Data at rest and in sync** — the book, holdings and settings stored on the
  device and, when the person turns it on, mirrored to their iCloud key-value
  storage. Anything that leaks them off the device is in scope.
- **Backups** — password-protected backup files (AES-256-GCM, key derived
  with PBKDF2). Weaknesses in how they are written or read are in scope.
- **App lock** — ways around the biometric or passcode lock, or around screen
  protection while locked.
- **Imported files and messages** — statements (PDF, CSV, XLSX), images,
  shared files and bank text messages are untrusted input. Crashes, unsafe
  parsing, or a crafted file or message that changes the book without the
  review step are in scope.
- **Bank SMS on Android** — any path by which message contents leave the
  device, or are read without the permission having been granted.
- **The AI apps helper** — the desktop helper is meant to be read-only and to
  serve only the snapshot file, with account, card and IBAN digits left out.
  Writing through it, reading other files through it, or finding those digits
  in the snapshot is in scope. See `docs/ai-apps.md`.
- **On-device model** — the Windows and Linux model file is downloaded once
  and checked against a pinned SHA-256 hash. A way to load a different file,
  or to make a model's output alter the person's own figures, is in scope.
- **Response parsing** — the price, history and FX providers parse third-party
  JSON. Crashes or unsafe handling of hostile responses are in scope.
- **Platform permissions** — misconfiguration (entitlements, app permissions,
  App Group or widget configuration) that widens the app's access beyond what
  it needs.

Out of scope: the upstream price endpoints, Hugging Face, and the operating
systems' own models and speech recognizers are third-party services; report
issues in them to their operators.
