/// Shared angle helpers used across the navigation engines. Extracted
/// because the "wrap a degree difference into [-180, 180]" loop was
/// independently duplicated in both NavigationInstructionService and
/// NavigationDecisionEngine — same logic, two copies, easy to fix one and
/// forget the other.
class AngleUtils {
  const AngleUtils._();

  /// Wraps [degrees] into the range (-180, 180].
  static double normalizeDegrees(double degrees) {
    var result = degrees % 360;

    if (result > 180) {
      result -= 360;
    } else if (result < -180) {
      result += 360;
    }

    return result;
  }
}
