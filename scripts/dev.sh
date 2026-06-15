#!/usr/bin/env bash
# Dev workflow — run with hot-reload
set -euo pipefail

echo "=== Starting OpenPup Flutter (dev mode) ==="
# In dev, stub the Rust bridge — real calls will be wired later.
flutter run -d windows  # or: macos, linux, chrome
