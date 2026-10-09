import 'dart:async';

import 'package:dalili/core/services/compass/compass_service.dart';
import 'package:dalili/core/services/compass/flutter_compass_service.dart';
import 'package:dalili/core/services/distance_estimator_service.dart';
import 'package:dalili/core/services/pedometer_step_counter_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service.dart';
import 'package:dalili/core/services/step_counter_service.dart';
import 'package:dalili/core/utils/angle_utils.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigationSensorServiceImpl implements NavigationSensorService {
  // Typed as the interfaces, not the concrete sensors, so a test can drive
  // the pipeline with fakes instead of real hardware.
  NavigationSensorServiceImpl({
    CompassService? compassService,
    StepCounterService? stepCounterService,
    DistanceEstimatorService? distanceEstimator,
    this.strideLength,
  }) : _compass = compassService ?? FlutterCompassService(),
       _steps = stepCounterService ?? PedometerStepCounterService(),
       _distanceEstimator =
           distanceEstimator ?? const DistanceEstimatorService();

  final CompassService _compass;
  final StepCounterService _steps;

  /// Metres per step for this walker, read once per trip so a height
  /// entered in settings takes effect on the next trip without restarting
  /// the app. Null keeps whatever estimator was injected.
  final double Function()? strideLength;

  DistanceEstimatorService _distanceEstimator;

  final StreamController<NavigationLocationUpdateModel> _controller =
      StreamController.broadcast();

  StreamSubscription<double>? _headingSubscription;
  StreamSubscription? _stepSubscription;

  double _heading = 0;

  /// When the last heading-only update was published, for throttling.
  DateTime? _lastHeadingEmit;

  /// The compass fires as fast as the magnetometer samples — tens of times
  /// a second — and each reading used to run the whole engine pipeline
  /// (projection, route correction, decision) while the camera was also
  /// running. Readings are still all recorded in [_heading]; only the
  /// *published* updates are rationed, and a step always publishes
  /// immediately regardless.
  static const Duration _headingInterval = Duration(milliseconds: 120);

  /// Degrees of change that publish an update before [_headingInterval] is
  /// up, so a deliberate turn still feels instant.
  static const double _headingEpsilon = 2;

  @override
  Stream<NavigationLocationUpdateModel> get updates => _controller.stream;

  @override
  Future<bool> start() async {
    // Tear down anything still running first. Without this a second
    // start() — the AR screen's "retry" after a denied permission — would
    // overwrite the subscription fields while the old subscriptions stayed
    // alive, so every step got counted once per leaked listener and the
    // walked distance ran away from the user.
    await stop();

    final granted = await _requestPermissions();

    if (!granted) {
      debugPrint(
        "debug - Navigation sensors NOT started: required permissions denied "
        "(activityRecognition / location). Pedometer and/or compass will "
        "silently produce no events until these are granted.",
      );
      return false;
    }

    await startSensors();
    return true;
  }

  /// Subscribes to the sensors and begins reporting. Split out of [start]
  /// so a test can exercise the real wiring — the permission request above
  /// has no platform behind it outside a running app.
  @visibleForTesting
  Future<void> startSensors() async {
    await stop();

    // Stale heading from the previous trip would otherwise steer the first
    // few frames of this one, until the first compass reading lands.
    _heading = 0;
    _lastHeadingEmit = null;

    final stride = strideLength?.call();
    if (stride != null) {
      _distanceEstimator = DistanceEstimatorService(stepLength: stride);
      debugPrint("debug - Stride for this trip: ${stride.toStringAsFixed(2)}m");
    }

    await _compass.start();
    await _steps.start();

    _headingSubscription = _compass.heading.listen((value) {
      final turned = AngleUtils.normalizeDegrees(value - _heading).abs();
      _heading = value;

      // A heading-only update keeps the arrow following the phone as the
      // user turns in place; walkedDistance is 0, so position and progress
      // are untouched either way.
      final now = DateTime.now();
      final last = _lastHeadingEmit;
      final due =
          last == null ||
          now.difference(last) >= _headingInterval ||
          turned >= _headingEpsilon;

      if (!due) return;

      _lastHeadingEmit = now;
      _controller.add(
        NavigationLocationUpdateModel(
          heading: _heading,
          walkedDistance: 0,
          timestamp: now,
        ),
      );
    });

    _stepSubscription = _steps.steps.listen(
      (step) {
        debugPrint("debug - Step received: ${step.newSteps}");

        final distance = _distanceEstimator.estimate(step.newSteps);
        debugPrint(
          "debug - Navigation Update => heading=$_heading distance=$distance",
        );

        _controller.add(
          NavigationLocationUpdateModel(
            heading: _heading,
            walkedDistance: distance,
            timestamp: DateTime.now(),
          ),
        );
      },
      onError: (Object error) {
        // A device without a step-counter sensor (or an emulator) reports
        // an error here. Heading updates keep flowing, so navigation stays
        // usable; an unhandled error would just crash the zone.
        debugPrint("debug - Step counter unavailable: $error");
      },
    );
  }

  //==========================================================
  // Permissions
  //==========================================================

  /// Requests the permissions required for step counting (Android 10+
  /// needs runtime ACTIVITY_RECOGNITION) and heading updates (iOS needs
  /// location authorization for CLLocationManager-based heading).
  ///
  /// Returns true if navigation can proceed. Location is only required
  /// on iOS, so it's requested but not blocking on other platforms.
  Future<bool> _requestPermissions() async {
    final activityStatus = await Permission.activityRecognition.request();

    if (!activityStatus.isGranted) {
      debugPrint(
        "debug - activityRecognition permission not granted: $activityStatus",
      );
      return false;
    }

    // Needed on iOS for compass heading; harmless to request on Android too
    // since the app already declares fine/coarse location in the manifest.
    await Permission.locationWhenInUse.request();

    // Battery optimization can throttle the step counter and compass while
    // the user walks with the screen dimmed. Asked once, and never blocking:
    // declining only risks slower sensor updates, not a failed navigation.
    if (defaultTargetPlatform == TargetPlatform.android &&
        !await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    return true;
  }

  @override
  Future<void> stop() async {
    await _headingSubscription?.cancel();
    _headingSubscription = null;

    await _stepSubscription?.cancel();
    _stepSubscription = null;

    await _compass.stop();
    await _steps.stop();
  }

  @override
  void dispose() {
    _headingSubscription?.cancel();
    _stepSubscription?.cancel();

    _compass.dispose();
    _steps.dispose();

    _controller.close();
  }
}
