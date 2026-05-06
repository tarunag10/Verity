#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-build/export/Verity.app}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing app bundle: $APP_PATH" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
codesign -dvvv --entitlements :- "$APP_PATH"
spctl -a -vv "$APP_PATH"

echo "Distribution validation completed for: $APP_PATH"
