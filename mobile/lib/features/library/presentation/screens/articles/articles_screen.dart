import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/article.dart';
import 'package:dalili/features/library/presentation/widgets/article_card.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key, required this.articles});

  final List<Article> articles;

  Future<void> _launch(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.surface,
    appBar: AppBar(
      title: Text(AppLocalizations.relatedArticles),
      backgroundColor: context.colors.surface,
      elevation: 0,
    ),
    body: articles.isEmpty
        ? EmptyWidget(message: AppLocalizations.noArticles)
        : ListView.builder(
            itemCount: articles.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (_, i) => ArticleCard(
              article: articles[i],
              onTap: () => _launch(articles[i].url),
            ),
          ),
  );
}
