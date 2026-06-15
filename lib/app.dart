import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bridge/rust_bridge.dart';
import 'screens/shell/app_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';

/// Root widget — handles onboarding gating.
///
/// Shows:
///   1. Loading spinner while checking onboarding state
///   2. OnboardingScreen if not completed
///   3. AppShell if completed
class OpenPupApp extends StatefulWidget {
  final ThemeData initialTheme;

  const OpenPupApp({super.key, required this.initialTheme});

  @override
  State<OpenPupApp> createState() => _OpenPupAppState();
}

class _OpenPupAppState extends State<OpenPupApp> {
  late ThemeMode _themeMode;
  late Locale _locale;
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _themeMode = ThemeMode.dark;
    _locale = const Locale('zh', 'CN');
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // TODO: call rust bridge check_onboarding_completed
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _onboardingDone = false); // fresh start → onboarding
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenPup',
      debugShowCheckedModeBanner: false,
      theme: OpenPupTheme.lightThemeData(),
      darkTheme: OpenPupTheme.darkThemeData(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    // Loading state
    if (_onboardingDone == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E293B),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'openpup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(const Color(0xFF1D9E75)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Onboarding
    if (!_onboardingDone!) {
      return OnboardingScreen(
        onComplete: () => setState(() => _onboardingDone = true),
      );
    }

    // Main app
    return AppShell(
      onThemeChanged: (mode) => setState(() => _themeMode = mode),
      onLocaleChanged: (locale) {
        if (locale != null) setState(() => _locale = locale);
      },
    );
  }
}
