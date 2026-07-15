import 'dart:async';

import 'package:dalili/core/services/compass/flutter_compass_service.dart';
import 'package:dalili/core/services/distance_estimator_service.dart';
import 'package:dalili/core/services/pedometer_step_counter_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:flutter/foundation.dart';

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
  Future<void> start() async {
    await _compass.start();
    await _steps.start();

    _headingSubscription = _compass.heading.listen((value) {
      debugPrint("debug - Heading received: $value");
      _heading = value;
    });

    _stepSubscription = _steps.steps.listen((step) {
      debugPrint("debug - Step received: ${step.newSteps}");

      final distance = _distanceEstimator.estimate(step.newSteps);
      debugPrint(
        "debug - Navigation Update => heading=$_heading distance=$distance",
      );

      debugPrint("Navigation Update => heading=$_heading distance=$distance");
      _controller.add(
        NavigationLocationUpdateModel(
          heading: _heading,
          walkedDistance: distance,
          timestamp: DateTime.now(),
        ),
      );
    });
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
