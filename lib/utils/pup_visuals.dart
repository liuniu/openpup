import 'package:flutter/material.dart';

/// Pup visual helpers — replaces src/utils/pupVisuals.ts.

/// Accent color per pup key.
Color pupAccentColor(String key) {
  switch (key) {
    case 'alpha':
      return const Color(0xFF1D9E75);
    case 'dev':
      return const Color(0xFF378ADD);
    case 'writer':
      return const Color(0xFFBA7517);
    case 'ops':
      return const Color(0xFF8B5CF6);
    case 'research':
      return const Color(0xFF06B6D4);
    case 'life_admin':
      return const Color(0xFFE55555);
    default:
      return const Color(0xFF94A3B8);
  }
}

/// Pup tag badge style (background + text color).
({Color bg, Color text}) pupTagStyle(String key) {
  final accent = pupAccentColor(key);
  return (
    bg: accent.withOpacity(0.14),
    text: accent,
  );
}
