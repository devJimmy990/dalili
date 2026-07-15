import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: context.colors.error),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              AppLocalizations.error,
              style: context.textStyles.bodyMedium
                  ?.copyWith(color: context.appTheme.onSurfaceVariant),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.retry),
              ),
          ],
        ),
      );
}
