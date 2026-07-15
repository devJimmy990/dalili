import 'package:dalili/core/constants/assets_manager.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 180, width: double.infinity, child: _BannerBackground());
}

class _BannerBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      return BlocSelector<AppSettingsCubit, AppSettingsState, String>(
        bloc: sl<AppSettingsCubit>(),
        selector: (state) => state.locale.languageCode,
        builder: (context, lang) => Image.asset(
          lang == 'ar'
              ? AssetsManager.assetsImagesBannerAr
              : AssetsManager.assetsImagesBannerEn,
          fit: BoxFit.fitWidth,
          errorBuilder: (_, __, ___) => _FallbackBackground(),
        ),
      );
    } catch (_) {
      return _FallbackBackground();
    }
  }
}

class _FallbackBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(color: context.colors.primary);
}
