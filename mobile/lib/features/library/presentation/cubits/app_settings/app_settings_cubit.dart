import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppSettingsCubit extends HydratedCubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState(locale: "en"));

  Future<void> setLocale(String locale) async {
    final preserved = state.copyWith(locale: locale);
    // Wipe all persisted cubit data so every feature reloads from the API
    // with the new language. AppSettingsCubit re-persists immediately on emit.
    await HydratedBloc.storage.clear();
    emit(preserved);
  }

  /// Unlike [setLocale], nothing cached depends on the theme, so the
  /// persisted data is left alone.
  void setThemeMode(AppThemeMode mode) => emit(state.copyWith(themeMode: mode));

  /// Records the walker's height so indoor navigation can convert their
  /// steps to metres. Out-of-range values are ignored rather than clamped —
  /// they mean the input was a mistake, not an unusual person.
  void setHeightCm(int? heightCm) {
    if (heightCm == null) {
      emit(state.copyWith(clearHeight: true));
      return;
    }
    if (heightCm < AppSettingsState.minHeightCm ||
        heightCm > AppSettingsState.maxHeightCm) {
      return;
    }
    emit(state.copyWith(heightCm: heightCm));
  }

  void markOnboardingComplete() =>
      emit(state.copyWith(hasSeenOnboarding: true));

  @override
  AppSettingsState? fromJson(Map<String, dynamic> json) => AppSettingsState(
    locale: json['locale'] as String? ?? 'en',
    hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
    themeMode:
        AppThemeMode.values.asNameMap()[json['themeMode']] ?? AppThemeMode.dark,
    heightCm: json['heightCm'] as int?,
  );

  @override
  Map<String, dynamic>? toJson(AppSettingsState state) => {
    'locale': state.locale,
    'hasSeenOnboarding': state.hasSeenOnboarding,
    'themeMode': state.themeMode.name,
    'heightCm': state.heightCm,
  };
}
