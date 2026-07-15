import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class LangSelectorButton extends StatelessWidget {
  const LangSelectorButton({
    super.key,
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.secondary
                : context.appTheme.surfaceContainerLow,
            borderRadius:
                BorderRadius.circular(context.appTheme.radiusXl),
            border: isSelected
                ? null
                : Border.all(
                    color: context.appTheme.outlineVariant, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                label,
                style: context.textStyles.displaySmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
}
