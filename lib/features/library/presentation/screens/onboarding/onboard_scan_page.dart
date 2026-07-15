import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class OnboardScanPage extends StatelessWidget {
  const OnboardScanPage({
    super.key,
    required this.onSkip,
    required this.onContinue,
  });

  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: context.appTheme.surfaceContainerLow,
                    borderRadius:
                        BorderRadius.circular(context.appTheme.radiusXl),
                  ),
                  child: Icon(Icons.qr_code_scanner,
                      size: 80, color: context.colors.secondary),
                ),
                const SizedBox(height: AppSpacing.stackLg),
                Text(
                  AppLocalizations.onboardScanTitle,
                  style: context.textStyles.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.stackMd),
                Text(
                  AppLocalizations.onboardScanDesc,
                  style: context.textStyles.bodyMedium?.copyWith(
                      color: context.appTheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.stackLg * 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            context.appTheme.radiusLg),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(AppLocalizations.continueBtn),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: AppSpacing.containerMargin,
            child: TextButton(
              onPressed: onSkip,
              child: Text(AppLocalizations.skip),
            ),
          ),
        ],
      );
}
