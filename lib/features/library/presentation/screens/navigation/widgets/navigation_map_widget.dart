import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/presentation/screens/navigation/widgets/navigation_map_painter.dart';
import 'package:flutter/material.dart';

class NavigationMapWidget extends StatelessWidget {
  const NavigationMapWidget({
    super.key,
    required this.map,
    required this.session,
  });

  final LibraryMapModel map;
  final NavigationSessionModel session;

  static const double _padding = 24;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;

      final scaleX = (width - (_padding * 2)) / map.width;
      final scaleY = (height - (_padding * 2)) / map.height;

      final scale = scaleX < scaleY ? scaleX : scaleY;

      return CustomPaint(
        size: Size(width, height),
        painter: NavigationMapPainter(
          map: map,
          session: session,
          scale: scale,
          padding: _padding,
        ),
      );
    },
  );
}
