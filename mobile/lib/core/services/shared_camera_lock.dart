import 'dart:async';

/// Coordinates raw camera hardware access between the two independent
/// plugins that both want the device's physical back camera:
/// `camera` (used by ArNavigationScreen for the live directional overlay)
/// and `mobile_scanner` (used by QRScannerScreen). Android only allows one
/// owner of the camera device at a time, and each plugin manages its own
/// session with no awareness of the other.
///
/// Whichever screen releases the camera stores its (unawaited) release
/// future here; whichever screen opens the camera next awaits it first.
/// Without this, opening a new session can race a release that's still
/// in flight — the symptom is a frozen/black preview on whichever plugin
/// loses the race, not an exception, so it's easy to misdiagnose as a bug
/// in just one of the two screens.
class SharedCameraLock {
  SharedCameraLock._();

  static Future<void>? pendingRelease;

  /// Waits for any in-flight release, but never blocks forever. The
  /// native camera teardown call this future wraps has, on some
  /// device/plugin combinations, been observed to not resolve at all —
  /// without a timeout here, the *next* screen to open a camera would be
  /// stuck behind an infinite loading spinner with no way out. Giving up
  /// after a short wait risks a frozen first frame in that rare case,
  /// which is recoverable (the retry/rescan buttons still work) — an
  /// unrecoverable infinite spinner is not.
  static Future<void> awaitRelease() async {
    final pending = pendingRelease;

    if (pending == null) return;

    await pending.timeout(const Duration(seconds: 2), onTimeout: () {});
  }
}
