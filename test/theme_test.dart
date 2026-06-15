import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openpup/theme/app_theme.dart';
import 'package:openpup/theme/dark_theme.dart';
import 'package:openpup/theme/light_theme.dart';

void main() {
  group('OpenPupTheme', () {
    test('dark theme uses correct brightness', () {
      final theme = DarkOpenPupTheme.build();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFF1D9E75));
    });

    test('light theme uses correct brightness', () {
      final theme = LightOpenPupTheme.build();
      expect(theme.brightness, Brightness.light);
    });

    test('both themes provide OpenPupColors extension', () {
      final darkColors = DarkOpenPupTheme.build().extension<OpenPupColors>();
      expect(darkColors, isNotNull);
      expect(darkColors!.backgroundPrimary, const Color(0xFF0F172A));

      final lightColors = LightOpenPupTheme.build().extension<OpenPupColors>();
      expect(lightColors, isNotNull);
    });
  });

  group('OpenPupColors', () {
    test('lerp works correctly', () {
      final a = OpenPupColors(backgroundPrimary: const Color(0xFF000000));
      final b = OpenPupColors(backgroundPrimary: const Color(0xFFFFFFFF));
      final c = a.lerp(b, 0.5);
      expect(c.backgroundPrimary, const Color(0xFF7F7F7F));
    });

    test('copyWith preserves unchanged fields', () {
      final colors = OpenPupColors(backgroundPrimary: const Color(0xFF0F172A));
      final copied = colors.copyWith(textPrimary: const Color(0xFFFFFFFF));
      expect(copied.backgroundPrimary, const Color(0xFF0F172A));
      expect(copied.textPrimary, const Color(0xFFFFFFFF));
      expect(copied.textSecondary, isNull);
    });
  });
}