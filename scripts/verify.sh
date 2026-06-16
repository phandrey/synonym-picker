#!/usr/bin/env zsh
set -euo pipefail

echo "verify: lint"
swift format lint --recursive Package.swift Sources Tests

mkdir -p .build/home .build/xdg-cache .build/clang-module-cache .build/swift-module-cache

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

echo "verify: typecheck"
swift build "${SWIFTPM_FLAGS[@]}" "${SWIFTC_FLAGS[@]}"

echo "verify: tests"
swift test "${SWIFTPM_FLAGS[@]}" "${SWIFTC_FLAGS[@]}"

echo "verify: app bundle"
./scripts/build-app.sh
