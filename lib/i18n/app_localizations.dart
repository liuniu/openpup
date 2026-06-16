/// Lightweight i18n — loads JSON locale files at runtime.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _strings;

  AppLocalizations(this.locale);

  Future<void> load() async {
    final code = locale.languageCode;
    try {
      final json = await rootBundle.loadString('lib/i18n/locales/\.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      _strings = map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      final json = await rootBundle.loadString('lib/i18n/locales/zh.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      _strings = map.map((k, v) => MapEntry(k, v.toString()));
    }
  }

  String t(String key, [List<String>? args]) {
    final value = _strings?[key] ?? key;
    if (args == null) return value;
    var result = value;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('{}', args[i]);
    }
    return result;
  }

  bool get isZh => locale.languageCode == 'zh';

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}