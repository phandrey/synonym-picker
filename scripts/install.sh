#!/usr/bin/env zsh
set -euo pipefail

if ! command -v swift >/dev/null 2>&1; then
  echo "Swift toolchain is required. Install Xcode Command Line Tools:"
  echo "  xcode-select --install"
  exit 1
fi

if ! command -v llama-server >/dev/null 2>&1; then
  echo "llama.cpp is required for local AI inference. Install it with:"
  echo "  brew install llama.cpp"
  echo ""
  echo "After that, run this installer again."
  exit 1
fi

./scripts/install-local.sh
