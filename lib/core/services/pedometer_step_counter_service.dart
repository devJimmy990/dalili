import 'dart:async';

import 'package:dalili/core/services/step_counter_service.dart';
import 'package:dalili/features/library/data/models/navigation/step_update_model.dart';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class PedometerStepCounterService implements StepCounterService {
  StreamSubscription<StepCount>? _subscription;

  final StreamController<StepUpdateModel> _controller =
      StreamController.broadcast();

  int? _lastTotalSteps;

  @override
  Stream<StepUpdateModel> get steps => _controller.stream;

  @override
  Future<void> start() async {
    debugPrint("debug - Pedometer Started");
    await stop();

    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _controller.addError,
    );
  }

  void _onStepCount(StepCount event) {
    debugPrint("debug - Raw Steps = ${event.steps}");
    final totalSteps = event.steps;

    if (_lastTotalSteps == null) {
      _lastTotalSteps = totalSteps;

      _controller.add(StepUpdateModel(totalSteps: totalSteps, newSteps: 0));

      return;
    }

    final newSteps = totalSteps - _lastTotalSteps!;

    _lastTotalSteps = totalSteps;

    if (newSteps <= 0) {
      return;
    }
    debugPrint("debug - Steps => Total: $totalSteps , New: $newSteps");
    _controller.add(
      StepUpdateModel(totalSteps: totalSteps, newSteps: newSteps),
    );
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
