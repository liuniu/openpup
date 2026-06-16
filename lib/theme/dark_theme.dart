import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkOpenPupTheme {
  DarkOpenPupTheme._();

  static ThemeData build() {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF1D9E75),
      secondary: const Color(0xFFBA7517),
      surface: const Color(0xFF0F172A),
      error: const Color(0xFFE55555),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFFE2E8F0),
      onError: const Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),

      extensions: const <ThemeExtension<dynamic>>[
        OpenPupColors(
          // Backgrounds
          backgroundPrimary: Color(0xFF0F172A),
          backgroundSecondary: Color(0xFF1E293B),
          backgroundTertiary: Color(0xFF334155),
          // Text
          textPrimary: Color(0xFFE2E8F0),
          textSecondary: Color(0xFF94A3B8),
          textTertiary: Color(0xFF64748B),
          textDanger: Color(0xFFE55555),
          textSuccess: Color(0xFF1D9E75),
          textWarning: Color(0xFFEEAA33),
          // Borders
          borderPrimary: Color(0xFF475569),
          borderSecondary: Color(0xFF334155),
          borderTertiary: Color(0xFF1E293B),
          // Semantic
          accent: Color(0xFF1D9E75),
          link: Color(0xFF378ADD),
          tagBg: Color(0x331D9E75),
        ),
      ],

      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',

      // ── Typography ────────────────────────────────────────────────────
      textTheme: const TextTheme(
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        bodyMedium: TextStyle(fontSize: 13, color: Color(0xFFE2E8F0)),
        bodyLarge: TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
        labelSmall: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        labelMedium: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),

      // ── Input / TextField ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D9E75), width: 1),
        ),
        fillColor: const Color(0xFF1E293B),
        filled: true,
      ),

      // ── Card ──────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155), width: 0.5),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E293B),
        thickness: 0.5,
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF475569), width: 0.5),
        ),
      ),
    );
  }
}
