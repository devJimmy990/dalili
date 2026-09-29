import 'dart:async';

import 'package:dalili/core/services/compass/flutter_compass_service.dart';
import 'package:dalili/core/services/distance_estimator_service.dart';
import 'package:dalili/core/services/pedometer_step_counter_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigationSensorServiceImpl implements NavigationSensorService {
  NavigationSensorServiceImpl({
    FlutterCompassService? compassService,
    PedometerStepCounterService? stepCounterService,
    DistanceEstimatorService? distanceEstimator,
  }) : _compass = compassService ?? FlutterCompassService(),
       _steps = stepCounterService ?? PedometerStepCounterService(),
       _distanceEstimator =
           distanceEstimator ?? const DistanceEstimatorService();

  final FlutterCompassService _compass;
  final PedometerStepCounterService _steps;
  final DistanceEstimatorService _distanceEstimator;

  final StreamController<NavigationLocationUpdateModel> _controller =
      StreamController.broadcast();

  StreamSubscription<double>? _headingSubscription;
  StreamSubscription? _stepSubscription;

  double _heading = 0;

  @override
  Stream<NavigationLocationUpdateModel> get updates => _controller.stream;

  @override
  Future<bool> start() async {
    final granted = await _requestPermissions();

    if (!granted) {
      debugPrint(
        "debug - Navigation sensors NOT started: required permissions denied "
        "(activityRecognition / location). Pedometer and/or compass will "
        "silently produce no events until these are granted.",
      );
      return false;
    }

    await _compass.start();
    await _steps.start();

    _headingSubscription = _compass.heading.listen((value) {
      debugPrint("debug - Heading received: $value");
      _heading = value;

      // Emit a heading-only update immediately so the UI (arrow rotation)
      // reacts to turning in place, not only to steps. walkedDistance is 0
      // so position/progress in the engine are unaffected.
      _controller.add(
        NavigationLocationUpdateModel(
          heading: _heading,
          walkedDistance: 0,
          timestamp: DateTime.now(),
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

    return true;
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
    await _stepSubscription?.cancel();

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
