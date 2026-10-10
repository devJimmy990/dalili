import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/services/shared_camera_lock.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:dalili/features/library/presentation/screens/main_layout.dart';
import 'package:dalili/features/library/presentation/screens/navigation/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android-only "AR-style" walking guide: a live camera feed with a
/// direction arrow overlaid on top, rotated to always point the way the
/// user needs to turn right now.
///
/// This is NOT a 3D-anchored AR experience (no ARCore session, no plane
/// detection, no world-locked markers) — it's a heading-relative compass
/// overlay on a camera feed, driven by the same live
/// [NavigationCubit]/[NavigationEngine] pipeline that already powers the
/// map screen. It reuses `state.decision.angleDifference`: 0° means "the
/// destination is straight ahead of wherever the phone is currently
/// pointed", positive/negative means "turn that many degrees left/right".
class ArNavigationScreen extends StatefulWidget {
  const ArNavigationScreen({
    super.key,
    this.destinationName,
    this.destinationShelfLabel,
  });

  /// The section being walked to ("قسم كهربية"), shown in the side panel.
  final String? destinationName;

  /// The shelf inside that section ("الرف 34"), when the trip started from a
  /// book. A destination picked from the list has no shelf to show.
  final String? destinationShelfLabel;

  @override
  State<ArNavigationScreen> createState() => _ArNavigationScreenState();
}

class _ArNavigationScreenState extends State<ArNavigationScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _errorMessage;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    setState(() {
      _initializing = true;
      _errorMessage = null;
    });

    // The QR scanner screen (a different plugin, `mobile_scanner`) may
    // still be in the middle of releasing its hold on the physical
    // camera — that screen sits between every "pick a destination" and
    // this one, so this wait matters on essentially every entry, not
    // just re-entry after a previous AR session. See SharedCameraLock.
    await SharedCameraLock.awaitRelease();

    final status = await Permission.camera.request();

    if (!status.isGranted) {
      setState(() {
        _initializing = false;
        _errorMessage = AppLocalizations.navCameraPermissionRequired;
      });
      return;
    }

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _errorMessage = AppLocalizations.navNoCameraFound;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        _release(controller);
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _initializing = false;
        _errorMessage = AppLocalizations.navCameraStartError(e.toString());
      });
    }
  }

  // Camera resources must be released when the app is backgrounded and
  // re-acquired on resume, otherwise the preview freezes/crashes on
  // Android when the user switches apps mid-navigation.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  /// Releases the camera without tearing down the whole screen — used
  /// whenever another camera-consuming screen is about to open *on top*
  /// of this one (mid-route QR re-scan) or the app is backgrounded. The
  /// mid-route case is easy to miss: pushing [QRScannerScreen] over this
  /// screen does NOT call [dispose] (this screen is only covered, not
  /// popped), so without this, ArNavigationScreen's `camera` session and
  /// QRScannerScreen's `mobile_scanner` session both hold the physical
  /// camera at once — Android allows only one owner, and the loser comes
  /// up frozen on its last frame with no exception thrown. See
  /// [SharedCameraLock].
  void _pauseCamera() {
    final controller = _controller;

    if (controller == null) return;

    _controller = null;
    setState(() => _initializing = true);
    _release(controller);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      _release(controller);
    }
    super.dispose();
  }

  /// Disposes [controller] without blocking the caller (awaiting a real
  /// native `dispose()` synchronously from an exit action previously hung
  /// the UI — see git history) and records the release on
  /// [SharedCameraLock] so whichever screen opens the camera next — this
  /// one again, or the QR scanner's `mobile_scanner` session — waits for
  /// the hardware to actually be free first, instead of racing this
  /// teardown. pausePreview() was tried instead of a real dispose here,
  /// but it only stops the preview stream; the `camera` plugin keeps
  /// imageCapture/imageAnalysis use cases bound underneath, so the
  /// physical device stays reserved and the *other* plugin's camera
  /// freezes instead.
  void _release(CameraController controller) {
    final future = controller.dispose();
    SharedCameraLock.pendingRelease = future;
    unawaited(future);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    // Screen is intentionally locked: leaving mid-navigation is a
    // meaningful action (cancels the whole trip), not an accidental
    // back-swipe. canPop:false intercepts both the system back gesture
    // and the AppBar's back button, routing both through the same
    // confirmation below.
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      _confirmExit(context);
    },
    child: Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        title: Text(AppLocalizations.navArNavigationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: AppLocalizations.navScanQrTooltip,
            onPressed: () => _rescanQr(context),
          ),
        ],
      ),
      body: _buildBody(),
    ),
  );

  /// Asks "are you sure?" before leaving. Confirming cancels the whole
  /// navigation (as if the user were starting over), not just closing
  /// this screen — a half-cancelled state (screen gone, sensors still
  /// running) would be worse than either fully continuing or fully
  /// stopping.
  Future<void> _confirmExit(BuildContext context) async {
    final cubit = context.read<NavigationCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.navCancelNavigationTitle),
        content: Text(AppLocalizations.navCancelNavigationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.navKeepGoing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.navCancelTrip),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Release the camera the moment the user commits to leaving,
      // instead of waiting for dispose() — which Flutter only calls once
      // the pop *transition animation* finishes. Without this, a user
      // fast enough to pick a new destination before that animation ends
      // can start a fresh QRScannerScreen while this screen's camera
      // session is technically still alive, racing it for the hardware.
      _pauseCamera();
      await cubit.stopNavigation();
      if (context.mounted) MainLayout.goHome(context);
    }
  }

  /// Lets the user re-scan a QR code mid-route to correct their position
  /// — useful if dead reckoning has drifted, or they took a wrong turn.
  Future<void> _rescanQr(BuildContext context) async {
    final cubit = context.read<NavigationCubit>();
    final map = cubit.state.map;

    if (map == null) return;

    // QRScannerScreen is pushed *on top of* this screen, not in place of
    // it — this screen is only covered, never popped/disposed, so its
    // camera must be released explicitly here or it fights
    // QRScannerScreen's mobile_scanner session for the hardware. See
    // _pauseCamera.
    _pauseCamera();

    final nodeId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(mode: QRScanMode.relocate, map: map),
      ),
    );

    if (!context.mounted) return;

    // Reacquire the camera regardless of whether the re-scan succeeded or
    // was cancelled — this screen is visible again either way and needs
    // a live preview, not the frozen last frame from before the pause.
    await _setupCamera();

    if (nodeId == null || !context.mounted) return;

    await cubit.updateCurrentPosition(nodeId);
  }

  Widget _buildBody() {
    if (_initializing) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.secondary),
      );
    }

    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _setupCamera);
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.secondary),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
            // Sensors (compass/pedometer) failed to start — most commonly
            // a denied motion/location permission. The session itself is
            // still valid (that's why this screen was pushed at all), so
            // show an actionable error instead of a frozen camera feed
            // with an arrow that will never move.
            if (state.error != null) {
              return _ErrorView(
                message: state.error!,
                onRetry: () => context.read<NavigationCubit>().retrySensors(),
              );
            }

            return _ArOverlay(
              state: state,
              destinationName: widget.destinationName,
              destinationShelfLabel: widget.destinationShelfLabel,
              onArrivedDone: () => _handleArrivedDone(context),
            );
          },
        ),
      ],
    );
  }

  /// Same reasoning as [_confirmExit]: release the camera and fully reset
  /// the cubit the moment the user commits to leaving (tapping "Done" on
  /// arrival), instead of leaving it to dispose() — which only runs once
  /// the pop transition finishes, and previously left this path skipping
  /// the cubit reset entirely (only [_confirmExit] called
  /// stopNavigation()).
  Future<void> _handleArrivedDone(BuildContext context) async {
    final cubit = context.read<NavigationCubit>();
    _pauseCamera();
    await cubit.stopNavigation();
    if (context.mounted) MainLayout.goHome(context);
  }
}

//==============================================================
// Overlay
//==============================================================

class _ArOverlay extends StatelessWidget {
  const _ArOverlay({
    required this.state,
    required this.onArrivedDone,
    this.destinationName,
    this.destinationShelfLabel,
  });

  final NavigationState state;
  final String? destinationName;
  final String? destinationShelfLabel;
  final VoidCallback onArrivedDone;

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final decision = state.decision;
    final arrived = session?.status == NavigationStatus.arrived;

    return SafeArea(
      child: Column(
        children: [
          if (decision != null && session != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _InstructionCard(message: decision.message),
            ),
          // Physically on the right in both languages, over the shelves
          // the visitor is heading for, as in the design.
          if (session != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _DestinationPanel(
                  name: destinationName,
                  shelfLabel: destinationShelfLabel,
                  remainingMeters: session.progress.remainingDistance,
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: arrived
                ? _ArrivedCard(onDone: onArrivedDone)
                : decision != null
                ? _DirectionArrow(angleDegrees: decision.angleDifference)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: context.cameraPanel,
      border: Border.all(color: context.colors.outlineVariant),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: TextStyle(
            color: context.colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

/// Where the visitor is going and how far is left: two stacked cards on the
/// right edge. The first names the section and, when the trip began from a
/// book, the shelf it is on; the second counts down the distance.
class _DestinationPanel extends StatelessWidget {
  const _DestinationPanel({
    required this.name,
    required this.shelfLabel,
    required this.remainingMeters,
  });

  final String? name;
  final String? shelfLabel;
  final double remainingMeters;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final hasName = name != null && name!.isNotEmpty;

    // Wide enough for the longest section name ("قسم علوم أساسية") on three
    // lines, and still narrow enough to leave the camera feed usable.
    Widget card(List<Widget> children) => Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: context.cameraPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasName || shelfLabel != null) ...[
          card([
            if (hasName)
              Text(
                name!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            if (shelfLabel != null) ...[
              if (hasName) const SizedBox(height: 4),
              Text(
                shelfLabel!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ]),
          const SizedBox(height: 12),
        ],
        card([
          Text(
            remainingMeters.round().toString(),
            style: TextStyle(
              color: context.colors.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            AppLocalizations.navMetersUnit,
            style: TextStyle(color: theme.onSurfaceVariant, fontSize: 14),
          ),
        ]),
      ],
    );
  }
}

/// A glowing arrow rotated relative to the phone's current facing
/// direction. [angleDegrees] is `decision.angleDifference` — 0 means
/// "straight ahead of wherever the camera is currently pointed".
class _DirectionArrow extends StatelessWidget {
  const _DirectionArrow({required this.angleDegrees});

  final double angleDegrees;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angleDegrees * pi / 180,
    child: Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.cameraPanel.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: context.colors.secondary.withValues(alpha: 0.55),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.navigation_rounded,
        color: context.colors.secondary,
        size: 64,
      ),
    ),
  );
}

class _ArrivedCard extends StatelessWidget {
  const _ArrivedCard({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.cameraPanel,
      border: Border.all(color: context.colors.outlineVariant),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.navArrivedMessage,
          style: TextStyle(
            color: context.appTheme.success,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: onDone,
          child: Text(AppLocalizations.navDone),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    // Opaque background: this view is also used as an overlay on top of
    // the live CameraPreview (sensor-permission error case), where the
    // feed behind it must not show through.
    color: context.colors.surface,
    child: Center(
      // Platform exceptions can run to dozens of lines; scroll instead of
      // overflowing the screen, and cap what is shown.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: context.appTheme.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.appTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.navRetryLabel),
            ),
          ],
        ),
      ),
    ),
  );
}
