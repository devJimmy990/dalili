import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.settings),
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    backgroundColor: context.colors.surface,
    body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
      bloc: sl<AppSettingsCubit>(),
      builder: (context, settings) => ListView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        children: [
          Text(
            AppLocalizations.navWalkingAccuracy,
            style: context.textStyles.displaySmall,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            AppLocalizations.navHeightHint,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.appTheme.onSurfaceVariant,
            ),
          ),
          _HeightSetting(settings: settings),
          const SizedBox(height: AppSpacing.stackLg),
          Text(
            AppLocalizations.language,
            style: context.textStyles.displaySmall,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          RadioGroup<String>(
            groupValue: settings.locale,
            onChanged: (v) {
              if (v != null) sl<AppSettingsCubit>().setLocale(v);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'ar',
                  title: Text(
                    AppLocalizations.arabic,
                    style: context.textStyles.bodyMedium,
                  ),
                  activeColor: context.colors.secondary,
                ),
                RadioListTile<String>(
                  value: 'en',
                  title: Text(
                    AppLocalizations.english,
                    style: context.textStyles.bodyMedium,
                  ),
                  activeColor: context.colors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),

          Text(AppLocalizations.theme, style: context.textStyles.displaySmall),
          const SizedBox(height: AppSpacing.stackMd),
          RadioGroup<AppThemeMode>(
            groupValue: sl<AppSettingsCubit>().state.themeMode,
            onChanged: (mode) {
              if (mode != null) sl<AppSettingsCubit>().setThemeMode(mode);
            },
            child: Column(
              children: [
                for (final (mode, label) in [
                  (AppThemeMode.light, AppLocalizations.lightTheme),
                  (AppThemeMode.dark, AppLocalizations.darkTheme),
                ])
                  RadioListTile<AppThemeMode>(
                    value: mode,
                    title: Text(label, style: context.textStyles.bodyMedium),
                    activeColor: context.colors.secondary,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Height in centimetres, shown with the step length it implies so the
/// effect on navigation is visible while adjusting it.
class _HeightSetting extends StatelessWidget {
  const _HeightSetting({required this.settings});

  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final height = settings.heightCm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.stackSm),
        Text(
          height == null
              ? AppLocalizations.navHeightNotSet
              : AppLocalizations.navHeightValue(
                  '$height',
                  settings.strideLength.toStringAsFixed(2),
                ),
          style: context.textStyles.bodyMedium,
        ),
        Slider(
          value: (height ?? 170).toDouble(),
          min: AppSettingsState.minHeightCm.toDouble(),
          max: AppSettingsState.maxHeightCm.toDouble(),
          divisions:
              AppSettingsState.maxHeightCm - AppSettingsState.minHeightCm,
          label: '${height ?? 170} cm',
          activeColor: context.colors.secondary,
          onChanged: (value) =>
              sl<AppSettingsCubit>().setHeightCm(value.round()),
        ),
        if (height != null)
          TextButton(
            onPressed: () => sl<AppSettingsCubit>().setHeightCm(null),
            child: Text(AppLocalizations.navHeightClear),
          ),
      ],
    );
  }
}
