#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="SynonymPicker"
APP_BUNDLE="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
SIGN_IDENTITY="${SYNONYM_PICKER_CODESIGN_IDENTITY:-SynonymPicker Local Code Signing}"
REAL_HOME="${HOME}"

mkdir -p .build/home .build/xdg-cache .build/clang-module-cache .build/swift-module-cache
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

export HOME="$PWD/.build/home"
export XDG_CACHE_HOME="$PWD/.build/xdg-cache"
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache"

SWIFTPM_FLAGS=(
  --disable-sandbox
  --cache-path .build/swiftpm-cache
  --config-path .build/swiftpm-config
  --security-path .build/swiftpm-security
  --scratch-path .build
)

SWIFTC_FLAGS=(
  -Xswiftc -module-cache-path
  -Xswiftc .build/swift-module-cache
  -Xcc -fmodules-cache-path=.build/clang-module-cache
)

swift build --product "${APP_NAME}" "${SWIFTPM_FLAGS[@]}" "${SWIFTC_FLAGS[@]}"

cp ".build/arm64-apple-macosx/debug/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"
cp "Packaging/Info.plist" "${CONTENTS_DIR}/Info.plist"
cp "Packaging/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
printf "APPL????" > "${CONTENTS_DIR}/PkgInfo"

export HOME="${REAL_HOME}"

if security find-identity -v -p codesigning | grep -F "\"${SIGN_IDENTITY}\"" >/dev/null; then
  codesign --force --deep --sign "${SIGN_IDENTITY}" "${APP_BUNDLE}"
  echo "Signed ${APP_BUNDLE} with ${SIGN_IDENTITY}"
else
  codesign --force --deep --sign - "${APP_BUNDLE}"
  echo "Signed ${APP_BUNDLE} ad-hoc; run scripts/create-local-codesign-identity.sh for stable Accessibility trust"
fi

codesign --verify --deep --strict --verbose=2 "${APP_BUNDLE}"

echo "Built ${APP_BUNDLE}"
