import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/widgets/lang_selector_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key, required this.onLanguageSelected});

  final VoidCallback onLanguageSelected;

  @override
  Widget build(BuildContext context) => BlocBuilder<AppSettingsCubit, dynamic>(
    bloc: sl<AppSettingsCubit>(),
    builder: (context, settings) {
      final currentLang = sl<AppSettingsCubit>().state.locale.languageCode;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerMargin,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 72),
            const SizedBox(height: AppSpacing.stackLg),
            const Text(
              'اختر اللغة\nSelect Language',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            LangSelectorButton(
              label: 'العربية',
              flag: '🇸🇦',
              isSelected: currentLang == 'ar',
              onTap: () {
                sl<AppSettingsCubit>().setLocale(const Locale('ar'));
                onLanguageSelected();
              },
            ),
            const SizedBox(height: AppSpacing.stackMd),
            LangSelectorButton(
              label: 'English',
              flag: '🇺🇸',
              isSelected: currentLang == 'en',
              onTap: () {
                sl<AppSettingsCubit>().setLocale(const Locale('en'));
                onLanguageSelected();
              },
            ),
          ],
        ),
      );
    },
  );
}
