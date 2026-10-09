import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF041627),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF1A2B3C),
      onPrimaryContainer: Color(0xFF8192A7),
      secondary: Color(0xFF0058BC),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF0070EB),
      onSecondaryContainer: Color(0xFFFEFCFF),
      surface: Color(0xFFF8F9FF),
      onSurface: Color(0xFF0B1C30),
      surfaceContainerHighest: Color(0xFFD3E4FE),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      outline: Color(0xFF74777D),
      outlineVariant: Color(0xFFC4C6CD),
    ),
    const AppThemeExtension(
      surfaceContainerLow: Color(0xFFEFF4FF),
      surfaceContainer: Color(0xFFE5EEFF),
      surfaceContainerHigh: Color(0xFFDCE9FF),
      onSurfaceVariant: Color(0xFF44474C),
      outlineVariant: Color(0xFFC4C6CD),
      secondaryContainer: Color(0xFF0070EB),
      onSecondaryContainer: Color(0xFFFEFCFF),
      accent: Color(0xFF0058BC),
      onAccent: Color(0xFFFFFFFF),
      hero: Color(0xFF041627),
      onHero: Color(0xFFFFFFFF),
      radiusSm: 4,
      radiusMd: 12,
      radiusLg: 16,
      radiusXl: 24,
      radiusFull: 9999,
    ),
  );

  /// The same navy-and-blue identity on a dark surface. Surfaces step up in
  /// lightness (surface → containerLow → container → containerHigh) the way
  /// the light theme steps down, so cards keep their depth. `secondary` is a
  /// lighter blue here because it is used as ink on those surfaces; filled
  /// buttons use `AppThemeExtension.accent` instead. Text pairs were chosen
  /// for at least 7:1 contrast on `surface` and the container steps.
  static ThemeData get dark => _build(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFB8C9DF),
      onPrimary: Color(0xFF041627),
      primaryContainer: Color(0xFF243A52),
      onPrimaryContainer: Color(0xFFD2E1F5),
      secondary: Color(0xFF7CB0FF),
      onSecondary: Color(0xFF00255A),
      secondaryContainer: Color(0xFF0070EB),
      onSecondaryContainer: Color(0xFFFEFCFF),
      surface: Color(0xFF0A1420),
      onSurface: Color(0xFFE3ECF8),
      surfaceContainerLowest: Color(0xFF060E18),
      surfaceContainerLow: Color(0xFF111D2C),
      surfaceContainer: Color(0xFF16253A),
      surfaceContainerHigh: Color(0xFF1D2F47),
      surfaceContainerHighest: Color(0xFF263A55),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: Color(0xFF8993A1),
      outlineVariant: Color(0xFF2C394B),
    ),
    const AppThemeExtension(
      surfaceContainerLow: Color(0xFF111D2C),
      surfaceContainer: Color(0xFF16253A),
      surfaceContainerHigh: Color(0xFF1D2F47),
      onSurfaceVariant: Color(0xFFAFBBCB),
      outlineVariant: Color(0xFF2C394B),
      secondaryContainer: Color(0xFF0070EB),
      onSecondaryContainer: Color(0xFFFEFCFF),
      accent: Color(0xFF1F6FE0),
      onAccent: Color(0xFFFFFFFF),
      hero: Color(0xFF122A42),
      onHero: Color(0xFFFFFFFF),
      radiusSm: 4,
      radiusMd: 12,
      radiusLg: 16,
      radiusXl: 24,
      radiusFull: 9999,
    ),
  );

  static ThemeData _build(ColorScheme scheme, AppThemeExtension extension) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        // Explicit so the page color is the scheme's surface in both themes.
        scaffoldBackgroundColor: scheme.surface,
        textTheme: _textTheme,
        extensions: [extension],
      );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.375,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.333,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Almarai',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.556,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Almarai',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Almarai',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.429,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Almarai',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.333,
    ),
  );
}
