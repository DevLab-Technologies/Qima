# Security Policy

## Supported versions

Qima is maintained on `main`. Fixes land there; there are no maintained release
branches.

## Reporting a vulnerability

Please do not open a public issue for a security problem.

Report it privately through GitHub's [private vulnerability
reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
on this repository, or by email to it@devlabtechnologies.com. Include what you
found, how to reproduce it, and the affected version or commit.

You can expect an acknowledgement within a week, and an assessment with a fix or
a decision shortly after.

## Scope notes

Qima has no server, no accounts and no credentials to steal. The interesting
surface is therefore:

- **Data handling** — holdings and watchlist data stored locally on-device
  (and, on Apple platforms, mirrored to iCloud key-value storage). Anything
  that leaks it off-device is in scope.
- **Response parsing** — the price, history and FX providers parse third-party
  JSON. Crashes or unsafe handling of hostile responses are in scope.
- **Platform permissions** — misconfiguration (network entitlements, app
  permissions, widget/App Group configuration) that widens the app's access
  beyond what it needs.

The upstream price endpoints themselves are third-party services; report issues
in them to their operators.
