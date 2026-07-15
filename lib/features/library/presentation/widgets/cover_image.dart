import 'package:cached_network_image/cached_network_image.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.radius,
  });

  final String url;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _CoverPlaceholder(
          width: width, height: height, radius: radius);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            _CoverPlaceholder(width: width, height: height, radius: 0),
        errorWidget: (_, __, ___) =>
            _CoverPlaceholder(width: width, height: height, radius: 0),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: width,
          height: height,
          color: context.appTheme.surfaceContainerHigh,
          child: Icon(Icons.menu_book,
              color: context.appTheme.onSurfaceVariant),
        ),
      );
}
