#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="$ROOT/build/archives/Verity.xcarchive"
EXPORT_PATH="$ROOT/build/export"
EXPORT_OPTIONS="$ROOT/docs/distribution/exportOptions.plist"
IDENTITY="${VERITY_CODE_SIGN_IDENTITY:-Developer ID Application}"

cd "$ROOT"

if ! security find-identity -p codesigning -v | grep -F "$IDENTITY" >/dev/null; then
  cat >&2 <<EOF
Missing signing identity: $IDENTITY

Install a Developer ID Application certificate, or run with:
  VERITY_CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" scripts/package_release.sh
EOF
  exit 1
fi

if ! command -v xcodegen >/dev/null; then
  echo "xcodegen is required. Install it with: brew install xcodegen" >&2
  exit 1
fi

rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
xcodegen generate

xcodebuild archive \
  -project Verity.xcodeproj \
  -scheme Verity \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  VERITY_CODE_SIGN_IDENTITY="$IDENTITY"

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -exportPath "$EXPORT_PATH" \
  VERITY_CODE_SIGN_IDENTITY="$IDENTITY"

"$ROOT/scripts/validate_distribution.sh" "$EXPORT_PATH/Verity.app"

echo "Exported: $EXPORT_PATH/Verity.app"
