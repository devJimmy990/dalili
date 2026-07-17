import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

// Provides a single shared animation to all ShimmerBox descendants.
class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()?.animation;

  @override
  bool updateShouldNotify(_ShimmerScope old) => animation != old.animation;
}

/// Wrap a skeleton layout with this to drive all [ShimmerBox] children
/// with one synchronized animation.
class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ShimmerScope(animation: _ctrl, child: widget.child);
}

/// A single placeholder rectangle that sweeps a highlight gradient.
/// Must be inside a [ShimmerWidget] tree for animation.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.radius = 8.0});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final anim = _ShimmerScope.of(context);
    final base = context.appTheme.surfaceContainerLow;
    final highlight = context.appTheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: anim ?? const AlwaysStoppedAnimation(0),
      builder: (_, __) {
        final t = anim?.value ?? 0.0;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + t * 2.5, 0),
              end: Alignment(t * 2.5, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton layouts that mirror real widgets
// ---------------------------------------------------------------------------

/// Mirrors [BookCard] layout.
class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

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
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 80, height: 110, radius: context.appTheme.radiusMd),
          const SizedBox(width: AppSpacing.gutter),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16),
                SizedBox(height: 6),
                ShimmerBox(height: 12, width: 120),
                SizedBox(height: 6),
                ShimmerBox(height: 12, width: 160),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 90),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Mirrors [DepartmentTile] layout (no horizontal margin — used inside a Card).
class DepartmentTileSkeleton extends StatelessWidget {
  const DepartmentTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    margin: const EdgeInsets.symmetric(vertical: AppSpacing.stackSm / 2),
    decoration: BoxDecoration(
      color: context.appTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
    ),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd),
    child: const Row(
      children: [
        ShimmerBox(width: 40, height: 40, radius: 20),
        SizedBox(width: AppSpacing.stackMd),
        Expanded(child: ShimmerBox(height: 14)),
        SizedBox(width: AppSpacing.stackMd),
        ShimmerBox(width: 20, height: 20),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Ready-to-drop-in skeleton lists
// ---------------------------------------------------------------------------

/// Drop-in replacement for [LoadingWidget] in book list contexts.
class BookListSkeleton extends StatelessWidget {
  const BookListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) => ShimmerWidget(
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: count,
      itemBuilder: (_, __) => const BookCardSkeleton(),
    ),
  );
}

/// Drop-in replacement for [LoadingWidget] in department list context (home screen).
class DepartmentListSkeleton extends StatelessWidget {
  const DepartmentListSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) => ShimmerWidget(
    child: Padding(
      padding: const EdgeInsets.only(top: AppSpacing.stackSm),
      child: ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) => const DepartmentTileSkeleton(),
      ),
    ),
  );
}
