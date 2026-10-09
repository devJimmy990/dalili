import 'dart:async';

import 'package:dalili/core/services/compass/compass_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service_impl.dart';
import 'package:dalili/core/services/step_counter_service.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/step_update_model.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _SilentCompass implements CompassService {
  final _controller = StreamController<double>.broadcast();

  @override
  Stream<double> get heading => _controller.stream;
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void dispose() => _controller.close();
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

  void walk(int n) {
    if (_running) {
      _controller.add(StepUpdateModel(totalSteps: n, newSteps: n));
    }
  }
}

void main() {
  group('stride from height', () {
    test('falls back to an average stride until a height is given', () {
      const settings = AppSettingsState(locale: 'ar');

      expect(settings.hasCalibratedStride, isFalse);
      expect(settings.strideLength, AppSettingsState.defaultStrideLength);
    });

    test('a short and a tall walker get different strides', () {
      const short = AppSettingsState(locale: 'ar', heightCm: 155);
      const tall = AppSettingsState(locale: 'ar', heightCm: 190);

      expect(short.strideLength, closeTo(0.643, 0.001));
      expect(tall.strideLength, closeTo(0.789, 0.001));

      // The gap is the whole point: over a 17 m route, assuming one stride
      // for both puts them metres apart.
      const steps = 17 / 0.75;
      final shortWalk = steps * short.strideLength;
      final tallWalk = steps * tall.strideLength;
      expect((tallWalk - shortWalk).abs(), greaterThan(3));
    });
  });

  group('the sensor service uses the configured stride', () {
    late _FakeSteps steps;
    late List<NavigationLocationUpdateModel> received;
    late StreamSubscription<NavigationLocationUpdateModel> subscription;
    late NavigationSensorServiceImpl service;

    Future<double> distanceAfterWalking(int stepCount) async {
      await service.startSensors();
      steps.walk(stepCount);
      await Future<void>.delayed(Duration.zero);
      return received
          .map((u) => u.walkedDistance)
          .fold<double>(0, (sum, d) => sum + d);
    }

    setUp(() {
      steps = _FakeSteps();
      received = [];
    });

    tearDown(() async {
      await subscription.cancel();
      await service.stop();
    });

    test('a 155 cm walker covers less ground per step', () async {
      service = NavigationSensorServiceImpl(
        compassService: _SilentCompass(),
        stepCounterService: steps,
        strideLength: () =>
            const AppSettingsState(locale: 'ar', heightCm: 155).strideLength,
      );
      subscription = service.updates.listen(received.add);

      expect(await distanceAfterWalking(10), closeTo(6.43, 0.01));
    });

    test('a 190 cm walker covers more', () async {
      service = NavigationSensorServiceImpl(
        compassService: _SilentCompass(),
        stepCounterService: steps,
        strideLength: () =>
            const AppSettingsState(locale: 'ar', heightCm: 190).strideLength,
      );
      subscription = service.updates.listen(received.add);

      expect(await distanceAfterWalking(10), closeTo(7.89, 0.01));
    });

    test(
      'the stride is re-read on every trip, not fixed at construction',
      () async {
        var heightCm = 155;
        service = NavigationSensorServiceImpl(
          compassService: _SilentCompass(),
          stepCounterService: steps,
          strideLength: () =>
              AppSettingsState(locale: 'ar', heightCm: heightCm).strideLength,
        );
        subscription = service.updates.listen(received.add);

        expect(await distanceAfterWalking(10), closeTo(6.43, 0.01));

        // The walker corrects their height in settings between trips.
        heightCm = 190;
        received.clear();
        await service.stop();

        expect(await distanceAfterWalking(10), closeTo(7.89, 0.01));
      },
    );
  });
}
