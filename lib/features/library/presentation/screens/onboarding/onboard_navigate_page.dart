import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class OnboardNavigatePage extends StatelessWidget {
  const OnboardNavigatePage({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) => Padding(
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
              child: Icon(Icons.navigation,
                  size: 80, color: context.colors.secondary),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Text(
              AppLocalizations.onboardNavTitle,
              style: context.textStyles.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              AppLocalizations.onboardNavDesc,
              style: context.textStyles.bodyMedium
                  ?.copyWith(color: context.appTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackLg * 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(context.appTheme.radiusLg),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.getStarted),
              ),
            ),
          ],
        ),
      );
}
