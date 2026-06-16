import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'bridge/rust_bridge.dart';
import 'theme/app_theme.dart';

/// Global key for error display state
final GlobalKey<_OpenPupErrorDisplayState> _errorKey = GlobalKey<_OpenPupErrorDisplayState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Desktop-only window setup ─────────────────────────────────────────
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    try {
      await OpenPupBridge.initDesktopWindow();
    } catch (e) {
      // window_manager not available
    }
  }

  // ── Initialise Rust backend (stub for now) ────────────────────────────
  try {
    await OpenPupBridge.initApp();
  } catch (e) {
    // Silently fail - bridge stubs
  }

  // ── Global error handlers ────────────────────────────────────────────
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _errorKey.currentState?.setError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _errorKey.currentState?.setRawError(error, stack);
    return true;
  };

  // ── Launch Flutter UI ─────────────────────────────────────────────────
  runApp(
    _StartupErrorBoundary(
      key: _errorKey,
      child: ProviderScope(
        child: OpenPupApp(
          initialTheme: OpenPupTheme.darkThemeData(),
        ),
      ),
    ),
  );
}

/// Catches startup errors and displays a diagnostic screen.
class _StartupErrorBoundary extends StatefulWidget {
  final Widget child;
  const _StartupErrorBoundary({required this.child, super.key});

  @override
  State<_StartupErrorBoundary> createState() => _OpenPupErrorDisplayState();
}

class _OpenPupErrorDisplayState extends State<_StartupErrorBoundary> {
  String? _errorMessage;
  String? _errorStack;

  void setError(FlutterErrorDetails details) {
    if (!mounted) return;
    setState(() {
      _errorMessage = details.exceptionAsString();
      _errorStack = details.stack?.toString();
    });
  }

  void setRawError(Object error, StackTrace stack) {
    if (!mounted) return;
    setState(() {
      _errorMessage = error.toString();
      _errorStack = stack.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE55555), size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Startup Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFFE55555),
                        ),
                      ),
                    ),
                    if (_errorStack != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _errorStack!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
