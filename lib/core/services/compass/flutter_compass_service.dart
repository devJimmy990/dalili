import 'dart:async';

import 'package:dalili/core/services/compass/compass_service.dart';
import 'package:flutter_compass/flutter_compass.dart';

class FlutterCompassService implements CompassService {
  final StreamController<double> _controller = StreamController.broadcast();

  StreamSubscription<CompassEvent>? _subscription;

  @override
  Stream<double> get heading => _controller.stream;

  @override
  Future<void> start() async {
    await stop();

    _subscription = FlutterCompass.events?.listen((event) {
      _controller.add(event.heading ?? 0);

      // debugPrint("debug - Compass => ${event.heading}");
    });
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
