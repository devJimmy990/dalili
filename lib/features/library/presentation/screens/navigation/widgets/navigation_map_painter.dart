import 'dart:math';

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
  });

  final LibraryMapModel map;
  final NavigationSessionModel session;

  final double scale;
  final double padding;

  late final Map<String, NodeModel> _nodesById = {
    for (final node in map.nodes) node.id: node,
  };

  Offset _offset(NodeModel node) =>
      Offset(padding + node.x * scale, padding + node.y * scale);

  @override
  void paint(Canvas canvas, Size size) {
    _drawEdges(canvas);
    _drawPath(canvas);
    _drawNodes(canvas);
    _drawCurrentUser(canvas);
  }

  //========================================================

  void _drawEdges(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    for (final edge in map.edges) {
      final from = _nodesById[edge.from];
      final to = _nodesById[edge.to];

      if (from == null || to == null) continue;

      canvas.drawLine(_offset(from), _offset(to), paint);
    }
  }

  //========================================================

  void _drawPath(Canvas canvas) {
    if (session.route.nodes.length < 2) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final nodes = session.route.nodes;

    for (int i = 0; i < nodes.length - 1; i++) {
      canvas.drawLine(_offset(nodes[i]), _offset(nodes[i + 1]), paint);
    }
  }

  //========================================================

  void _drawNodes(Canvas canvas) {
    for (final node in map.nodes) {
      Color color = Colors.blue;

      if (node.id == session.route.start.id) {
        color = Colors.green;
      } else if (node.id == session.route.end.id) {
        color = Colors.red;
      }

      final position = _offset(node);

      canvas.drawCircle(position, 7, Paint()..color = color);

      final textPainter = TextPainter(
        text: TextSpan(
          text: node.id,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(canvas, Offset(position.dx + 8, position.dy - 8));
    }
  }

  //========================================================

  void _drawCurrentUser(Canvas canvas) {
    final position = session.currentPosition;

    final offset = Offset(
      padding + position.x * scale,
      padding + position.y * scale,
    );

    canvas.save();

    canvas.translate(offset.dx, offset.dy);

    canvas.rotate(session.heading * pi / 180);

    final path = Path()
      ..moveTo(0, -18)
      ..lineTo(10, 12)
      ..lineTo(0, 6)
      ..lineTo(-10, 12)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.green);

    canvas.restore();
  }
  //========================================================

  @override
  bool shouldRepaint(covariant NavigationMapPainter oldDelegate) =>
      oldDelegate.session != session ||
      oldDelegate.map != map ||
      oldDelegate.scale != scale;
}
