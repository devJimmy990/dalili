import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox,
                size: 48, color: context.appTheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              message ?? AppLocalizations.noResults,
              style: context.textStyles.bodyMedium
                  ?.copyWith(color: context.appTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
