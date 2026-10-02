import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/core/utils/display.dart';
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
            if (hasText(article.authors)) ...[
              const SizedBox(height: 4),
              Text(
                article.authors!,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.appTheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (hasText(article.doi)) ...[
              const SizedBox(height: 4),
              Text(
                'DOI: ${article.doi!}',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            _DocumentFooter(article: article),
          ],
        ),
      ),
    ),
  );
}

/// What the document itself is, below a divider: year, kind and where it was
/// published. A conference paper often has no journal title and a preprint no
/// year, so each part shows only when the catalogue has it, and the whole
/// footer (divider included) disappears when none do.
class _DocumentFooter extends StatelessWidget {
  const _DocumentFooter({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final source = joinParts([article.source, article.sourceTitle]);
    final facts = [
      (AppLocalizations.year, article.year?.toString()),
      (AppLocalizations.documentType, article.type),
    ].where((f) => hasText(f.$2)).toList();

    if (facts.isEmpty && source == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: context.appTheme.outlineVariant,
          height: AppSpacing.stackMd * 2,
        ),
        if (facts.isNotEmpty)
          Wrap(
            spacing: AppSpacing.stackMd,
            runSpacing: 4,
            children: [
              for (final (label, value) in facts) _Fact(label, value!),
            ],
          ),
        if (source != null) ...[
          if (facts.isNotEmpty) const SizedBox(height: 4),
          _Fact(AppLocalizations.articleSource, source),
        ],
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: TextStyle(color: context.appTheme.onSurfaceVariant),
        ),
        TextSpan(
          text: value,
          style: TextStyle(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
    style: context.textStyles.bodySmall,
  );
}
