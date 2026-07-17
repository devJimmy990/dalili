import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

/// Maps the user's real-world (meters) progress along the current segment
/// onto a pixel position on the library's static map image.
///
/// This is intentionally kept separate from [NavigationPositionEngine] /
/// [NavigationProjectionEngine]: those two work in real-world meters and
/// drive the actual navigation logic (progress %, arrival detection,
/// on-route correction). This engine does none of that — it only answers
/// "given how far along this segment the user already is, where should
/// the dot sit on the picture?". It reads the same progress fraction but
/// interpolates it between the segment's two nodes' `imageX`/`imageY`
/// instead of their real-world `x`/`y`.
class NavigationImagePositionEngine {
  const NavigationImagePositionEngine();

  /// Returns the pixel position for the user's current progress, or null
  /// if either end of the current segment hasn't been calibrated with
  /// image coordinates yet (see [NodeModel.hasImagePosition]).
  ImagePosition? calculate({required NavigationSessionModel session}) {
    final segment = session.currentSegment;

    if (!segment.from.hasImagePosition || !segment.to.hasImagePosition) {
      return null;
    }

    final t = session.progress.progress(segment);

    final x = _lerp(segment.from.imageX!, segment.to.imageX!, t);
    final y = _lerp(segment.from.imageY!, segment.to.imageY!, t);

    return ImagePosition(x: x, y: y);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class ImagePosition {
  const ImagePosition({required this.x, required this.y});

  final double x;
  final double y;
}
