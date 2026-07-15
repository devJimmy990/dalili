import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.locale,
    this.hasSeenOnboarding = false,
  });

  final Locale locale;
  final bool hasSeenOnboarding;

  AppSettingsState copyWith({Locale? locale, bool? hasSeenOnboarding}) =>
      AppSettingsState(
        locale: locale ?? this.locale,
        hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      );

  @override
  List<Object?> get props => [locale, hasSeenOnboarding];
}
