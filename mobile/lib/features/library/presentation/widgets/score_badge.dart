import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score});

  /// Relevance from the catalogue, 0..1. Null when the article was never
  /// scored, which is not the same as scoring zero.
  final double? score;

  @override
  Widget build(BuildContext context) {
    final score = this.score;
    if (score == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(context.appTheme.radiusFull),
      ),
      child: Text(
        // Two decimals at most, and no trailing ".0" on a whole score.
        "${(score * 100).toInt()}%",
        style: context.textStyles.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }
}
