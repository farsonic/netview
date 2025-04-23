#!/bin/bash

set -e

# Get the directory this script is in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN="/usr/local/bin"

echo "Installing netview to $TARGET_BIN..."

sudo cp "$SCRIPT_DIR/netview" "$TARGET_BIN/netview"
sudo chmod +x "$TARGET_BIN/netview"

echo "✅ netview installed globally. You can now run: netview"

