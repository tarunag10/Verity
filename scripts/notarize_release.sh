#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${1:-$ROOT/build/export/Verity.app}"
ZIP_PATH="$ROOT/build/export/Verity.zip"
PROFILE="${NOTARYTOOL_PROFILE:-}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing app bundle: $APP_PATH" >&2
  echo "Run scripts/package_release.sh first." >&2
  exit 1
fi

if [[ -z "$PROFILE" ]]; then
  cat >&2 <<'EOF'
Set NOTARYTOOL_PROFILE to a stored notarytool profile first.

Example setup:
  xcrun notarytool store-credentials verity-notary \
    --apple-id "you@example.com" \
    --team-id "TEAMID" \
    --password "app-specific-password"

Then run:
  NOTARYTOOL_PROFILE=verity-notary scripts/notarize_release.sh
EOF
  exit 1
fi

rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$APP_PATH"
"$ROOT/scripts/validate_distribution.sh" "$APP_PATH"

echo "Notarized and stapled: $APP_PATH"
