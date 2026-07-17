import 'dart:math';
import 'dart:ui' as ui;

import 'package:dalili/core/engines/navigation_image_position_engine.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';
import 'package:flutter/material.dart';

class NavigationMapPainter extends CustomPainter {
  NavigationMapPainter({
    required this.map,
    required this.session,
    required this.scale,
    required this.padding,
    required this.backgroundImage,
    this.imagePositionEngine = const NavigationImagePositionEngine(),
  });

  final LibraryMapModel map;
  final NavigationSessionModel session;
  final ui.Image backgroundImage;
  final NavigationImagePositionEngine imagePositionEngine;

  final double scale;
  final double padding;

  late final Map<String, NodeModel> _nodesById = {
    for (final node in map.nodes) node.id: node,
  };

  /// Converts a node's calibrated image pixel position into canvas
  /// coordinates. Returns null if the node hasn't been calibrated.
  Offset? _canvasOffset(NodeModel node) {
    if (!node.hasImagePosition) return null;
    return Offset(
      padding + node.imageX! * scale,
      padding + node.imageY! * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackgroundImage(canvas);
    _drawRoute(canvas);
    _drawCurrentUser(canvas);
  }

  //========================================================

  void _drawBackgroundImage(Canvas canvas) {
    final destRect = Rect.fromLTWH(
      padding,
      padding,
      map.imageWidth * scale,
      map.imageHeight * scale,
    );

    final srcRect = Rect.fromLTWH(
      0,
      0,
      backgroundImage.width.toDouble(),
      backgroundImage.height.toDouble(),
    );

    canvas.drawImageRect(backgroundImage, srcRect, destRect, Paint());
  }

  //========================================================
  // Highlights only the computed route on top of the (already
  // fully-illustrated) map image — not the whole graph, to avoid
  // cluttering a picture that already shows the room layout.
  //========================================================

  void _drawRoute(Canvas canvas) {
    if (session.route.nodes.length < 2) return;

    final glowPaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.35)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final nodes = session.route.nodes;

    for (int i = 0; i < nodes.length - 1; i++) {
      final from = _canvasOffset(nodes[i]);
      final to = _canvasOffset(nodes[i + 1]);

      if (from == null || to == null) continue;

      canvas.drawLine(from, to, glowPaint);
      canvas.drawLine(from, to, linePaint);
    }

    _drawEndpointMarker(canvas, nodes.first, Colors.green);
    _drawEndpointMarker(canvas, nodes.last, Colors.redAccent);
  }

  void _drawEndpointMarker(Canvas canvas, NodeModel node, Color color) {
    final offset = _canvasOffset(node);
    if (offset == null) return;

    canvas.drawCircle(offset, 9, Paint()..color = Colors.white);
    canvas.drawCircle(offset, 7, Paint()..color = color);
  }

  //========================================================

  void _drawCurrentUser(Canvas canvas) {
    final imagePosition = imagePositionEngine.calculate(session: session);

    if (imagePosition == null) return;

    final offset = Offset(
      padding + imagePosition.x * scale,
      padding + imagePosition.y * scale,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(session.heading * pi / 180);

    // Soft halo so the arrow stays visible over busy parts of the image.
    canvas.drawCircle(
      Offset.zero,
      16,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset.zero,
      16,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final path = Path()
      ..moveTo(0, -13)
      ..lineTo(8, 10)
      ..lineTo(0, 4)
      ..lineTo(-8, 10)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.blueAccent);

    canvas.restore();
  }

  //========================================================

  @override
  bool shouldRepaint(covariant NavigationMapPainter oldDelegate) =>
      oldDelegate.session != session ||
      oldDelegate.map != map ||
      oldDelegate.scale != scale ||
      oldDelegate.backgroundImage != backgroundImage;
}
