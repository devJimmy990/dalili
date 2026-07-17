import 'dart:ui' as ui;

import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/presentation/screens/navigation/widgets/navigation_map_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavigationMapWidget extends StatefulWidget {
  const NavigationMapWidget({
    super.key,
    required this.map,
    required this.session,
    required this.mapImagePath,
  });

  final LibraryMapModel map;
  final NavigationSessionModel session;

  /// Asset path to the library's static map image (e.g.
  /// `assets/map/library_map.png`).
  final String mapImagePath;

  @override
  State<NavigationMapWidget> createState() => _NavigationMapWidgetState();
}

class _NavigationMapWidgetState extends State<NavigationMapWidget> {
  static const double _padding = 24;

  // Cache decoded images per asset path so switching maps/sessions doesn't
  // re-decode the (potentially large) background image on every rebuild.
  static final Map<String, ui.Image> _imageCache = {};

  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant NavigationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapImagePath != widget.mapImagePath) {
      _image = null;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final cached = _imageCache[widget.mapImagePath];
    if (cached != null) {
      setState(() => _image = cached);
      return;
    }

    final data = await rootBundle.load(widget.mapImagePath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();

    _imageCache[widget.mapImagePath] = frame.image;

    if (mounted) {
      setState(() => _image = frame.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    if (image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final scaleX = (width - (_padding * 2)) / widget.map.imageWidth;
        final scaleY = (height - (_padding * 2)) / widget.map.imageHeight;

        final scale = scaleX < scaleY ? scaleX : scaleY;

        return CustomPaint(
          size: Size(width, height),
          painter: NavigationMapPainter(
            map: widget.map,
            session: widget.session,
            scale: scale,
            padding: _padding,
            backgroundImage: image,
          ),
        );
      },
    );
  }
}
