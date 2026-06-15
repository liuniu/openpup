import 'package:flutter/material.dart';
import 'app_theme.dart';

class LightOpenPupTheme {
  LightOpenPupTheme._();

  static ThemeData build() {
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFF1D9E75),
      secondary: const Color(0xFFBA7517),
      surface: const Color(0xFFFFFFFF),
      error: const Color(0xFFD32F2F),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1E293B),
      onError: const Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),

      extensions: const <ThemeExtension<dynamic>>[
        OpenPupColors(
          backgroundPrimary: Color(0xFFFFFFFF),
          backgroundSecondary: Color(0xFFF1F5F9),
          backgroundTertiary: Color(0xFFE2E8F0),
          textPrimary: Color(0xFF1E293B),
          textSecondary: Color(0xFF64748B),
          textTertiary: Color(0xFF94A3B8),
          textDanger: Color(0xFFD32F2F),
          textSuccess: Color(0xFF1D9E75),
          textWarning: Color(0xFFEEAA33),
          borderPrimary: Color(0xFFCBD5E1),
          borderSecondary: Color(0xFFE2E8F0),
          borderTertiary: Color(0xFFF1F5F9),
          accent: Color(0xFF1D9E75),
          link: Color(0xFF2563EB),
          tagBg: Color(0x1A1D9E75),
        ),
      ],

      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',

      textTheme: const TextTheme(
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        bodyLarge: TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        labelSmall: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        labelMedium: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D9E75), width: 1),
        ),
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
      ),

      cardTheme: CardTheme(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 0.5,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 0.5),
        ),
      ),
    );
  }
}
