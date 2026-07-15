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
          elevation: 0,
        ),
        backgroundColor: context.colors.surface,
        body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          bloc: sl<AppSettingsCubit>(),
          builder: (context, settings) => ListView(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            children: [
              Text(AppLocalizations.language,
                  style: context.textStyles.displaySmall),
              const SizedBox(height: AppSpacing.stackMd),
              RadioGroup<Locale>(
                groupValue: settings.locale,
                onChanged: (v) {
                  if (v != null) sl<AppSettingsCubit>().setLocale(v);
                },
                child: Column(
                  children: [
                    RadioListTile<Locale>(
                      value: const Locale('ar'),
                      title: Text(AppLocalizations.arabic,
                          style: context.textStyles.bodyMedium),
                      activeColor: context.colors.secondary,
                    ),
                    RadioListTile<Locale>(
                      value: const Locale('en'),
                      title: Text(AppLocalizations.english,
                          style: context.textStyles.bodyMedium),
                      activeColor: context.colors.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text(AppLocalizations.theme,
                  style: context.textStyles.displaySmall),
              const SizedBox(height: AppSpacing.stackMd),
              RadioGroup<bool>(
                groupValue: true,
                onChanged: (_) {},
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: true,
                      title: Text(AppLocalizations.lightTheme,
                          style: context.textStyles.bodyMedium),
                      activeColor: context.colors.secondary,
                    ),
                    RadioListTile<bool>(
                      value: false,
                      title: Text(
                        '${AppLocalizations.darkTheme} — ${AppLocalizations.comingSoon}',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.appTheme.onSurfaceVariant,
                        ),
                      ),
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
