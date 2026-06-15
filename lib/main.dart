import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'bridge/rust_bridge.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Desktop window setup ───────────────────────────────────────────────
  await OpenPupBridge.initDesktopWindow();

  // ── Initialise Rust backend ────────────────────────────────────────────
  await OpenPupBridge.initApp();

  // ── Launch Flutter UI (wrapped in ProviderScope for Riverpod) ─────────
  runApp(
    ProviderScope(
      child: OpenPupApp(
        initialTheme: OpenPupTheme.darkThemeData(),
      ),
    ),
  );
}
