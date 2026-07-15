import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.editable = false,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.controller,
  });

  final bool editable;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      hintText: AppLocalizations.searchHint,
      hintStyle: context.textStyles.bodyMedium
          ?.copyWith(color: context.appTheme.onSurfaceVariant),
      prefixIcon:
          Icon(Icons.search, color: context.appTheme.onSurfaceVariant),
      filled: true,
      fillColor: context.appTheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(context.appTheme.radiusFull),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );

    if (editable) {
      return TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: decoration,
        style: context.textStyles.bodyMedium,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          decoration: decoration,
          style: context.textStyles.bodyMedium,
        ),
      ),
    );
  }
}
