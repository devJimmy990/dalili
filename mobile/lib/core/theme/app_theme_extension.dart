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
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
  }) =>
      AppThemeExtension(
        surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
        surfaceContainer: surfaceContainer ?? this.surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
        onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
        outlineVariant: outlineVariant ?? this.outlineVariant,
        secondaryContainer: secondaryContainer ?? this.secondaryContainer,
        onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
        radiusSm: radiusSm ?? this.radiusSm,
        radiusMd: radiusMd ?? this.radiusMd,
        radiusLg: radiusLg ?? this.radiusLg,
        radiusXl: radiusXl ?? this.radiusXl,
        radiusFull: radiusFull ?? this.radiusFull,
      );

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) => this;
}

extension AppThemeX on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
