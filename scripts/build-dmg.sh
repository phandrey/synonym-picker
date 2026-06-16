#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="SynonymPicker"
VOLUME_NAME="Synonym Picker"
APP_BUNDLE="dist/${APP_NAME}.app"
DMG_ROOT=".build/dmg-root-$(date +%Y%m%d%H%M%S)"
DMG_PATH="dist/${APP_NAME}.dmg"

./scripts/build-app.sh

mkdir -p "${DMG_ROOT}"
ditto "${APP_BUNDLE}" "${DMG_ROOT}/${APP_NAME}.app"
ln -s /Applications "${DMG_ROOT}/Applications"
cp "Packaging/DMG-README.txt" "${DMG_ROOT}/Read Me.txt"

hdiutil create \
  -volname "${VOLUME_NAME}" \
  -srcfolder "${DMG_ROOT}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

hdiutil verify "${DMG_PATH}"

echo "Built ${DMG_PATH}"
