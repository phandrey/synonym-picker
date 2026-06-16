#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="SynonymPicker"
BUNDLE_ID="local.synonym-picker.macos"
APP_BUNDLE="dist/${APP_NAME}.app"
INSTALL_PATH="/Applications/${APP_NAME}.app"

./scripts/build-app.sh

pkill "${APP_NAME}" 2>/dev/null || true

rm -rf "${INSTALL_PATH}"
cp -R "${APP_BUNDLE}" /Applications/
xattr -dr com.apple.quarantine "${INSTALL_PATH}" 2>/dev/null || true

open "${INSTALL_PATH}"

echo "Installed ${INSTALL_PATH}"
codesign -dv "${INSTALL_PATH}" 2>&1 | sed -n '1,12p'
if codesign -dv "${INSTALL_PATH}" 2>&1 | grep -F "Signature=adhoc" >/dev/null; then
  echo "WARNING: ${INSTALL_PATH} is still ad-hoc signed."
  echo "Run ./scripts/create-local-codesign-identity.sh, then ./scripts/install-local.sh again."
fi
echo "If this is the first install after changing signing identity, click the menu bar icon, choose Permissions: Request Accessibility, and grant Accessibility again."
