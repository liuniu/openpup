/// Lightweight i18n — loads JSON locale files at runtime.
///
/// This is a minimal implementation that replaces the React 	(key, lang) pattern.
/// Switch to lutter_localizations + ARB files for production.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _strings;

  AppLocalizations(this.locale);

  /// Load the JSON locale file from assets.
  Future<void> load() async {
    final code = locale.languageCode;
    try {
      final json = await rootBundle.loadString('lib/i18n/locales/\.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      _strings = map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      // Fallback to Chinese
      final json = await rootBundle.loadString('lib/i18n/locales/zh.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      _strings = map.map((k, v) => MapEntry(k, v.toString()));
    }
  }

  /// Translate a key.
  String t(String key, [List<String>? args]) {
    String? value = _strings?[key];
    if (value == null) return key;
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        value = value.replaceAll('{}', args[i]);
      }
    }
    return value;
  }

  /// Whether this locale is Chinese.
  bool get isZh => locale.languageCode == 'zh';

  /// Shortcut accessor.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}