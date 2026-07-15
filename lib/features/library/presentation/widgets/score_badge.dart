import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    if (score.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius:
            BorderRadius.circular(context.appTheme.radiusFull),
      ),
      child: Text(
        score,
        style: context.textStyles.bodySmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
