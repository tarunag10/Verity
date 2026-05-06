# Verity macOS distribution

Verity is ready for local Xcode testing after `swift test` and `xcodebuild test`, but public distribution requires a Developer ID signed, hardened runtime build and notarization.

## Prerequisites

- Apple Developer Program membership.
- A `Developer ID Application` certificate installed in Keychain.
- `xcodegen` installed.
- For notarization, a stored `notarytool` credential profile.

## Build a signed Release app

```sh
VERITY_CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
DEVELOPMENT_TEAM="TEAMID" \
scripts/package_release.sh
```

The exported app appears at:

```text
build/export/Verity.app
```

## Notarize and staple

Create the notary profile once:

```sh
xcrun notarytool store-credentials verity-notary \
  --apple-id "you@example.com" \
  --team-id "TEAMID" \
  --password "app-specific-password"
```

Then submit:

```sh
NOTARYTOOL_PROFILE=verity-notary scripts/notarize_release.sh
```

## Validate an exported app

```sh
scripts/validate_distribution.sh build/export/Verity.app
```

## Notes

- Debug builds intentionally remain unsigned/ad-hoc for easy local testing.
- Release builds use hardened runtime and Developer ID signing.
- The MLX language and embedding models download on first use into the local Hugging Face cache. Before shipping broadly, add first-run download progress around model loading so users understand why the first answer may take time.
