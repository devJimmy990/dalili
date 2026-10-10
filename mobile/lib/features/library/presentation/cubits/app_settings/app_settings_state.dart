import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark }

class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.locale,
    this.hasSeenOnboarding = false,
    this.themeMode = AppThemeMode.dark,
    this.heightCm,
  });

  /// Average stride for an adult, used until the walker states their height.
  static const double defaultStrideLength = 0.75;

  /// Ratio of stride length to standing height. The usual figure for adult
  /// walking, and the reason asking for height is worth it: the indoor
  /// route is dead-reckoned from step *count*, so a stride that is 20% off
  /// puts the walker metres away from where the app thinks they are.
  static const double strideToHeight = 0.415;

  static const int minHeightCm = 120;
  static const int maxHeightCm = 220;

  final String locale;
  final bool hasSeenOnboarding;

  /// The walker's standing height, if they have given it. Null means the
  /// average stride is used.
  final int? heightCm;

  /// Metres covered per step.
  double get strideLength {
    final height = heightCm;
    if (height == null) return defaultStrideLength;
    return height / 100 * strideToHeight;
  }

  bool get hasCalibratedStride => heightCm != null;

  /// Follows the phone's setting until the user picks light or dark.
  final AppThemeMode themeMode;

  AppSettingsState copyWith({
    String? locale,
    bool? hasSeenOnboarding,
    AppThemeMode? themeMode,
    int? heightCm,
    bool clearHeight = false,
  }) => AppSettingsState(
    locale: locale ?? this.locale,
    hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    themeMode: themeMode ?? this.themeMode,
    heightCm: clearHeight ? null : (heightCm ?? this.heightCm),
  );

  @override
  List<Object?> get props => [locale, hasSeenOnboarding, themeMode, heightCm];
}
