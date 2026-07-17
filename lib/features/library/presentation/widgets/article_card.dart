import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/article.dart';
import 'package:dalili/features/library/presentation/widgets/score_badge.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: context.appTheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
    ),
    elevation: 1,
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.containerMargin,
      vertical: AppSpacing.stackSm / 2,
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: context.textStyles.labelLarge,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.stackSm),
                ScoreBadge(score: article.score),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              article.authors,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.appTheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${article.sourceTitle} • ${article.year}',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.appTheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (article.doi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'DOI: ${article.doi}',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
