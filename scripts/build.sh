#!/usr/bin/env bash
# Build script for OpenPup Flutter.
# Prerequisites: Flutter SDK 3.16+, Rust stable, cargo

set -euo pipefail

echo "=== 1. Build Rust cdylib ==="
cd rust
cargo build --release
cd ..

echo "=== 2. Generate flutter_rust_bridge bindings ==="
flutter_rust_bridge_codegen generate \
  --rust-input rust/src/lib.rs \
  --dart-output lib/bridge/generated_bridge.dart

echo "=== 3. Flutter build ==="
flutter pub get
flutter build windows  # or: macos, linux, apk, ios

echo "=== Done ==="
