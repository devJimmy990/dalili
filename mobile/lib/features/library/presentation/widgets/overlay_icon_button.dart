import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// An icon button for chrome that floats over something it cannot control — a
/// live camera feed, or a book cover.
///
/// A bare icon would have to pick one colour and then disappear on half of
/// what might be behind it. Backed by a disc in the theme's surface colour it
/// stays readable over anything, and follows the light or dark theme.
class OverlayIconButton extends StatelessWidget {
  const OverlayIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(6),
    child: IconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: context.colors.surface.withValues(alpha: 0.7),
        foregroundColor: context.colors.onSurface,
      ),
    ),
  );
}
