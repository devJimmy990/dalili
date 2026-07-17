import 'dart:async';

import 'package:dalili/core/engines/navigation_engine.dart';
import 'package:dalili/core/engines/navigation_relocation_engine.dart';
import 'package:dalili/core/services/compass/flutter_compass_service.dart';
import 'package:dalili/core/services/navigation_start_service.dart';
import 'package:dalili/core/services/pedometer_step_counter_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service_impl.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_state_snapshot.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit({
    NavigationRelocationEngine? relocationEngine,
    NavigationStartService? navigationStartService,
    NavigationSensorService? navigationSensorService,
    NavigationEngine? navigationEngine,
  }) : _relocationEngine =
           relocationEngine ?? const NavigationRelocationEngine(),
       _navigationStartService =
           navigationStartService ?? const NavigationStartService(),
       _navigationSensorService =
           navigationSensorService ??
           NavigationSensorServiceImpl(
             compassService: FlutterCompassService(),
             stepCounterService: PedometerStepCounterService(),
           ),
       _navigationEngine = navigationEngine ?? const NavigationEngine(),
       super(const NavigationState());

  final NavigationRelocationEngine _relocationEngine;
  final NavigationStartService _navigationStartService;
  final NavigationSensorService _navigationSensorService;
  final NavigationEngine _navigationEngine;

  StreamSubscription<NavigationLocationUpdateModel>? _sensorSubscription;

  //==========================================================
  // Start Navigation
  //==========================================================

  Future<void> startNavigation({
    required String startNode,
    required String endNode,
  }) async {
    await _stopSensors();

    emit(
      state.copyWith(
        loading: true,
        error: null,
        map: null,
        session: null,
        position: null,
        decision: null,
        navigating: false,
        arrived: false,
      ),
    );

    try {
      final result = await _navigationStartService.start(
        startNodeId: startNode,
        endNodeId: endNode,
      );

      final navigation = _navigationEngine.initialize(session: result.session);

      emit(state.copyWith(loading: false, map: result.map));

      _emitNavigationState(navigation);

      final sensorsStarted = await _navigationSensorService.start();

      if (!sensorsStarted) {
        emit(
          state.copyWith(
            error:
                "Motion & fitness / location permission is required for "
                "live navigation. Please grant it in system settings and "
                "try again.",
          ),
        );
        return;
      }

      _sensorSubscription = _navigationSensorService.updates.listen(
        _onSensorUpdate,
      );
    } catch (e) {
      emit(
        state.copyWith(loading: false, navigating: false, error: e.toString()),
      );
    }
  }

  //==========================================================
  // Sensor Update
  //==========================================================

  void _onSensorUpdate(NavigationLocationUpdateModel update) {
    debugPrint("debug - Sensor Update");
    final session = state.session;

    if (session == null) {
      return;
    }

    //-----------------------------------------
    // Update Navigation
    //-----------------------------------------
    debugPrint(
      "debug - Heading=${update.heading}  Distance=${update.walkedDistance}",
    );
    final result = _navigationEngine.update(session: session, update: update);

    //-----------------------------------------
    // Route Correction
    //-----------------------------------------

    if (!result.correction.isOnRoute) {
      // TODO:
      // 1- Find nearest node
      // 2- Recalculate route
      // 3- Replace session

      return;
    }

    //-----------------------------------------
    // Update UI
    //-----------------------------------------

    _emitNavigationState(result);

    //-----------------------------------------
    // Arrived
    //-----------------------------------------
    // Only stop the sensors here — do NOT call stopNavigation()/reset the
    // state. That would wipe session/arrived (both just emitted above) in
    // the same synchronous chain, before the UI ever gets a chance to
    // render the "arrived" state. Full reset only happens when the user
    // explicitly stops/starts a new navigation.

    if (result.session.status == NavigationStatus.arrived) {
      unawaited(_stopSensors());
    }
  }
  //==========================================================
  // Stop Sensors
  //==========================================================

  Future<void> _stopSensors() async {
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;

    await _navigationSensorService.stop();
  }

  //==========================================================
  // Stop Navigation
  //==========================================================

  Future<void> stopNavigation() => _resetNavigation();

  Future<void> updateCurrentPosition(String currentNodeId) async {
    final map = state.map;
    final session = state.session;

    if (map == null || session == null) {
      return;
    }

    final snapshot = _relocationEngine.relocate(
      map: map,
      session: session,
      currentNodeId: currentNodeId,
    );

    _emitNavigationState(snapshot);
  }

  // Dispose
  //==========================================================
  void _emitNavigationState(NavigationStateSnapshot snapshot) {
    emit(
      state.copyWith(
        session: snapshot.session,
        position: snapshot.position,
        decision: snapshot.decision,
        navigating: snapshot.session.status == NavigationStatus.navigating,
        arrived: snapshot.session.status == NavigationStatus.arrived,
      ),
    );
  }

  Future<void> _resetNavigation() async {
    await _stopSensors();
    emit(const NavigationState());
  }

  @override
  Future<void> close() async {
    await _resetNavigation();
    _navigationSensorService.dispose();

    return super.close();
  }
}
