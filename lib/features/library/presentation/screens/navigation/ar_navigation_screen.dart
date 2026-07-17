import 'dart:math';

import 'package:camera/camera.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
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
  const ArNavigationScreen({super.key});

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

    final status = await Permission.camera.request();

    if (!status.isGranted) {
      setState(() {
        _initializing = false;
        _errorMessage =
            "Camera permission is required for AR navigation. Please grant "
            "it in system settings.";
      });
      return;
    }

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _errorMessage = "No camera was found on this device.";
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
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _initializing = false;
        _errorMessage = "Couldn't start the camera: $e";
      });
    }
  }

  // Camera resources must be released when the app is backgrounded and
  // re-acquired on resume, otherwise the preview freezes/crashes on
  // Android when the user switches apps mid-navigation.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: const Text("AR Navigation"),
    ),
    body: _buildBody(),
  );

  Widget _buildBody() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _setupCamera);
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) => _ArOverlay(state: state),
        ),
      ],
    );
  }
}

//==============================================================
// Overlay
//==============================================================

class _ArOverlay extends StatelessWidget {
  const _ArOverlay({required this.state});

  final NavigationState state;

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
              child: _InstructionCard(
                message: decision.message,
                remainingDistance: session.progress.remainingDistance,
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: arrived
                ? _ArrivedCard(onDone: () => Navigator.pop(context))
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
  const _InstructionCard({
    required this.message,
    required this.remainingDistance,
  });

  final String message;
  final double remainingDistance;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${remainingDistance.toStringAsFixed(1)} m remaining",
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    ),
  );
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
        color: Colors.black.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.55),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.navigation_rounded,
        color: Colors.blueAccent,
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
      color: Colors.black.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "لقد وصلت إلى وجهتك 🎉",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(onPressed: onDone, child: const Text("Done")),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    ),
  );
}
