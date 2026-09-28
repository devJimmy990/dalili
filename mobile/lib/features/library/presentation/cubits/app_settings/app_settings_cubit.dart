import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppSettingsCubit extends HydratedCubit<AppSettingsState> {
  AppSettingsCubit() : super(AppSettingsState(locale: _detectDeviceLocale()));

  static Locale _detectDeviceLocale() {
    final lang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return lang == 'ar' ? const Locale('ar') : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    final preserved = state.copyWith(locale: locale);
    // Wipe all persisted cubit data so every feature reloads from the API
    // with the new language. AppSettingsCubit re-persists immediately on emit.
    await HydratedBloc.storage.clear();
    emit(preserved);
  }

  void markOnboardingComplete() =>
      emit(state.copyWith(hasSeenOnboarding: true));

  @override
  AppSettingsState? fromJson(Map<String, dynamic> json) => AppSettingsState(
    locale: Locale(json['locale'] as String? ?? 'ar'),
    hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
  );

  @override
  Map<String, dynamic>? toJson(AppSettingsState state) => {
    'locale': state.locale.languageCode,
    'hasSeenOnboarding': state.hasSeenOnboarding,
  };
}
