import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

class OpenPupTheme {
  OpenPupTheme._();

  static ThemeData darkThemeData() => DarkOpenPupTheme.build();
  static ThemeData lightThemeData() => LightOpenPupTheme.build();
}

/// Custom theme extension for OpenPup-specific color tokens.
class OpenPupColors extends ThemeExtension<OpenPupColors> {
  final Color? backgroundPrimary;
  final Color? backgroundSecondary;
  final Color? backgroundTertiary;
  final Color? textPrimary;
  final Color? textSecondary;
  final Color? textTertiary;
  final Color? textDanger;
  final Color? textSuccess;
  final Color? textWarning;
  final Color? borderPrimary;
  final Color? borderSecondary;
  final Color? borderTertiary;
  final Color? accent;
  final Color? link;
  final Color? tagBg;

  const OpenPupColors({
    this.backgroundPrimary,
    this.backgroundSecondary,
    this.backgroundTertiary,
    this.textPrimary,
    this.textSecondary,
    this.textTertiary,
    this.textDanger,
    this.textSuccess,
    this.textWarning,
    this.borderPrimary,
    this.borderSecondary,
    this.borderTertiary,
    this.accent,
    this.link,
    this.tagBg,
  });

  @override
  OpenPupColors copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDanger,
    Color? textSuccess,
    Color? textWarning,
    Color? borderPrimary,
    Color? borderSecondary,
    Color? borderTertiary,
    Color? accent,
    Color? link,
    Color? tagBg,
  }) {
    return OpenPupColors(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDanger: textDanger ?? this.textDanger,
      textSuccess: textSuccess ?? this.textSuccess,
      textWarning: textWarning ?? this.textWarning,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderTertiary: borderTertiary ?? this.borderTertiary,
      accent: accent ?? this.accent,
      link: link ?? this.link,
      tagBg: tagBg ?? this.tagBg,
    );
  }

  @override
  OpenPupColors lerp(ThemeExtension<OpenPupColors>? other, double t) {
    if (other is! OpenPupColors) return this;
    return OpenPupColors(
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t),
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t),
      backgroundTertiary: Color.lerp(backgroundTertiary, other.backgroundTertiary, t),
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t),
      textDanger: Color.lerp(textDanger, other.textDanger, t),
      textSuccess: Color.lerp(textSuccess, other.textSuccess, t),
      textWarning: Color.lerp(textWarning, other.textWarning, t),
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t),
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t),
      borderTertiary: Color.lerp(borderTertiary, other.borderTertiary, t),
      accent: Color.lerp(accent, other.accent, t),
      link: Color.lerp(link, other.link, t),
      tagBg: Color.lerp(tagBg, other.tagBg, t),
    );
  }
}

/// Convenience getter for OpenPupColors from BuildContext.
extension OpenPupThemeContext on BuildContext {
  OpenPupColors get openpupColors => Theme.of(this).extension<OpenPupColors>()!;
}
