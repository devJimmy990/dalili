import 'dart:async';

import 'package:dalili/core/services/compass/compass_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service_impl.dart';
import 'package:dalili/core/services/step_counter_service.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/step_update_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// A sensor whose readings the test pushes by hand, and which refuses to be
/// read while stopped — exactly how the real plugins behave.
class _FakeCompass implements CompassService {
  final _controller = StreamController<double>.broadcast();
  var _running = false;

  @override
  Stream<double> get heading => _controller.stream;

  @override
  Future<void> start() async => _running = true;

  @override
  Future<void> stop() async => _running = false;

  @override
  void dispose() => _controller.close();

  void emit(double value) {
    if (_running) _controller.add(value);
  }
}

class _FakeSteps implements StepCounterService {
  final _controller = StreamController<StepUpdateModel>.broadcast();
  var _running = false;

  @override
  Stream<StepUpdateModel> get steps => _controller.stream;

  @override
  Future<void> start() async => _running = true;

  @override
  Future<void> stop() async => _running = false;

  @override
  void dispose() => _controller.close();

  void walk(int newSteps) {
    if (_running) {
      _controller.add(
        StepUpdateModel(totalSteps: newSteps, newSteps: newSteps),
      );
    }
  }
}

void main() {
  late _FakeCompass compass;
  late _FakeSteps steps;
  late NavigationSensorServiceImpl service;
  late List<NavigationLocationUpdateModel> received;
  late StreamSubscription<NavigationLocationUpdateModel> subscription;

  setUp(() {
    compass = _FakeCompass();
    steps = _FakeSteps();
    service = NavigationSensorServiceImpl(
      compassService: compass,
      stepCounterService: steps,
    );
    received = [];
    subscription = service.updates.listen(received.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await service.stop();
  });

  /// Lets the broadcast streams deliver before the assertions run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('nothing is reported after stop()', () async {
    await service.startSensors();
    await service.stop();

    compass.emit(90);
    steps.walk(5);
    await settle();

    expect(
      received,
      isEmpty,
      reason:
          'a reading delivered after stop() means a listener outlived '
          'the trip',
    );
  });

  test('restarting does not report each step twice', () async {
    await service.startSensors();
    await service.startSensors();

    steps.walk(4);
    await settle();

    final walked = received
        .map((u) => u.walkedDistance)
        .fold<double>(0, (sum, d) => sum + d);

    // Four steps at the configured stride, counted once. Before start()
    // tore the old subscriptions down, a second start left both listeners
    // alive and this came back doubled.
    expect(received.where((u) => u.walkedDistance > 0), hasLength(1));
    expect(walked, closeTo(4 * 0.75, 0.001));
  });

  test('a new trip does not inherit the previous trip’s heading', () async {
    await service.startSensors();
    compass.emit(270);
    await settle();
    expect(received.last.heading, 270);

    await service.stop();
    received.clear();

    await service.startSensors();
    steps.walk(1);
    await settle();

    expect(
      received.single.heading,
      0,
      reason:
          'the first update of a new trip must not carry the heading the '
          'walker happened to be facing when the last one ended',
    );
  });
}
