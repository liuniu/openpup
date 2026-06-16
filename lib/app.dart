import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/shell/app_shell.dart';
import 'theme/app_theme.dart';

/// Root widget.
class OpenPupApp extends StatefulWidget {
  final ThemeData initialTheme;

  const OpenPupApp({super.key, required this.initialTheme});

  @override
  State<OpenPupApp> createState() => _OpenPupAppState();
}

class _OpenPupAppState extends State<OpenPupApp> {
  late ThemeMode _themeMode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _themeMode = ThemeMode.dark;
    _locale = const Locale('zh', 'CN');
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
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: AppShell(
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
        onLocaleChanged: (locale) {
          if (locale != null) setState(() => _locale = locale);
        },
      ),
    );
  }
}
