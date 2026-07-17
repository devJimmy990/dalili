import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';

abstract class NavigationSensorService {
  Stream<NavigationLocationUpdateModel> get updates;

  /// Returns true if sensors were actually started. Returns false (without
  /// throwing) if required permissions were denied — callers should surface
  /// this to the user rather than assuming navigation is now live.
  Future<bool> start();

  Future<void> stop();

  void dispose();
}
