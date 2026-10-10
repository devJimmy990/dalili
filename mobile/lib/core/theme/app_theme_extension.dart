import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.accent,
    required this.onAccent,
    required this.hero,
    required this.onHero,
    required this.success,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
  });

  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  /// Solid brand blue for filled buttons, badges and selected chips, with
  /// [onAccent] text on top. `ColorScheme.secondary` is the *ink* version of
  /// the same blue (text and icons on a surface), which flips to a lighter
  /// shade in dark mode — so it cannot also be a fill behind white text.
  final Color accent;
  final Color onAccent;

  /// The deep navy panel behind the book cards, the welcome banner and the
  /// camera screens' chrome. It stays dark in both themes, with [onHero]
  /// text that is readable on it whatever sits behind.
  final Color hero;
  final Color onHero;

  /// Positive confirmation ("you have arrived"). A fixed light green would
  /// vanish on the light theme and a dark one on the dark theme, so each
  /// theme carries its own.
  final Color success;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;

  @override
  AppThemeExtension copyWith({
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? onSurfaceVariant,
    Color? outlineVariant,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? accent,
    Color? onAccent,
    Color? hero,
    Color? onHero,
    Color? success,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
  }) => AppThemeExtension(
    surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
    surfaceContainer: surfaceContainer ?? this.surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
    onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
    outlineVariant: outlineVariant ?? this.outlineVariant,
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    hero: hero ?? this.hero,
    onHero: onHero ?? this.onHero,
    success: success ?? this.success,
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusXl: radiusXl ?? this.radiusXl,
    radiusFull: radiusFull ?? this.radiusFull,
  );

  /// Blends the colors, so switching theme fades instead of snapping. The
  /// radii are shared by both themes and never change.
  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      success: Color.lerp(success, other.success, t)!,
      radiusSm: radiusSm,
      radiusMd: radiusMd,
      radiusLg: radiusLg,
      radiusXl: radiusXl,
      radiusFull: radiusFull,
    );
  }
}

extension AppThemeX on BuildContext {
  /// A panel that floats over a live camera feed: the theme's own surface,
  /// mostly opaque so its text stays readable whatever the camera happens to
  /// be pointing at — and light in the light theme, dark in the dark one.
  Color get cameraPanel =>
      Theme.of(this).colorScheme.surface.withValues(alpha: 0.92);

  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
