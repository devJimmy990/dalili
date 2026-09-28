import 'dart:async';

import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/engines/navigation_engine.dart';
import 'package:dalili/core/engines/navigation_relocation_engine.dart';
import 'package:dalili/core/services/compass/flutter_compass_service.dart';
import 'package:dalili/core/services/navigation_start_service.dart';
import 'package:dalili/core/services/pedometer_step_counter_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service.dart';
import 'package:dalili/core/services/sensors/navigation_sensor_service_impl.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
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
        clearError: true,
        clearMap: true,
        clearSession: true,
        clearPosition: true,
        clearDecision: true,
        navigating: false,
        arrived: false,
      ),
    );

    try {
      final result = await _navigationStartService.start(
        startNodeId: startNode,
        endNodeId: endNode,
      );

      final navigation = _navigationEngine.initialize(
        session: result.session,
        map: result.map,
      );

      emit(state.copyWith(loading: false, map: result.map));

      _emitNavigationState(navigation);

      final sensorsStarted = await _navigationSensorService.start();

      if (!sensorsStarted) {
        emit(
          state.copyWith(error: AppLocalizations.navSensorPermissionError),
        );
        return;
      }

      _sensorSubscription = _navigationSensorService.updates.listen(
        _onSensorUpdate,
      );
    } catch (e) {
      // Route/session build failed — the initial emit above already
      // cleared the old session, keep it cleared here so callers checking
      // `state.session == null` (e.g. NavigationControls, to decide
      // whether to push the AR screen) see this attempt as failed rather
      // than mistaking the previous trip's leftover session for success.
      emit(
        state.copyWith(
          loading: false,
          navigating: false,
          clearSession: true,
          clearMap: true,
          clearPosition: true,
          clearDecision: true,
          error: e.toString(),
        ),
      );
    }
  }

  //==========================================================
  // Retry Sensors
  //==========================================================

  /// Retries starting the sensors after a permission failure, without
  /// recomputing the route — used by the AR screen's error state so the
  /// user can grant the permission and try again without losing their
  /// in-progress session.
  Future<void> retrySensors() async {
    if (state.session == null) return;

    emit(state.copyWith(clearError: true));

    final sensorsStarted = await _navigationSensorService.start();

    if (!sensorsStarted) {
      emit(state.copyWith(error: AppLocalizations.navSensorPermissionError));
      return;
    }

    _sensorSubscription = _navigationSensorService.updates.listen(
      _onSensorUpdate,
    );
  }

  //==========================================================
  // Sensor Update
  //==========================================================

  void _onSensorUpdate(NavigationLocationUpdateModel update) {
    debugPrint("debug - Sensor Update");
    final session = state.session;
    final map = state.map;

    if (session == null || map == null) {
      return;
    }

    //-----------------------------------------
    // Update Navigation
    //-----------------------------------------
    debugPrint(
      "debug - Heading=${update.heading}  Distance=${update.walkedDistance}",
    );
    final result = _navigationEngine.update(
      session: session,
      update: update,
      map: map,
    );

    //-----------------------------------------
    // Route Correction
    //-----------------------------------------
    // Off-route no longer freezes guidance until a manual QR rescan: the
    // engine already found the nearest routable node (see
    // NavigationCorrectionEngine), so silently re-anchor the route there
    // and recalculate the shortest path onward — same mechanism a manual
    // rescan uses, just automatic. Dead reckoning below always keeps
    // tracking real movement either way (on-route or not), so the
    // remaining distance/instructions never stall while the user is
    // walking back toward the corridor.

    final snapshot = _recoverIfOffRoute(map: map, result: result) ?? result;

    //-----------------------------------------
    // Update UI
    //-----------------------------------------

    _emitNavigationState(snapshot);

    //-----------------------------------------
    // Arrived
    //-----------------------------------------
    // Only stop the sensors here — do NOT call stopNavigation()/reset the
    // state. That would wipe session/arrived (both just emitted above) in
    // the same synchronous chain, before the UI ever gets a chance to
    // render the "arrived" state. Full reset only happens when the user
    // explicitly stops/starts a new navigation.

    if (snapshot.session.status == NavigationStatus.arrived) {
      unawaited(_stopSensors());
    }
  }

  /// Re-anchors the route on the nearest routable node and recalculates
  /// the shortest path from there to the destination, once per genuine
  /// deviation — not every tick. If the nearest node hasn't changed since
  /// the last recovery, guidance is already aimed at it; the user just
  /// hasn't reached that corridor's centerline yet, so we let dead
  /// reckoning keep tracking their real steps instead of resetting the
  /// route (and their walked progress within it) repeatedly.
  ///
  /// A manual QR rescan ([updateCurrentPosition]) is unaffected by this
  /// and always takes priority the moment it's used, since it's grounded
  /// in a scanned code rather than a distance estimate.
  NavigationStateSnapshot? _recoverIfOffRoute({
    required LibraryMapModel map,
    required NavigationStateSnapshot result,
  }) {
    final nearestNodeId = result.correction.nearestNodeId;

    if (result.correction.isOnRoute || nearestNodeId == null) {
      return null;
    }

    if (nearestNodeId == result.session.currentSegment.from.id) {
      return null;
    }

    // Rebuilding a route whose start and end node are the same produces a
    // session with zero segments (nothing to walk), which crashes the
    // very next `session.currentSegment` read. If the nearest node is the
    // destination itself, the footprint/arrival check in
    // NavigationProgressEngine already handles "reached the destination"
    // independently of route correction — leave it to that instead.
    if (nearestNodeId == result.session.route.end.id) {
      return null;
    }

    return _relocationEngine.relocate(
      map: map,
      session: result.session,
      currentNodeId: nearestNodeId,
    );
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
