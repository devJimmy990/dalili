import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';

abstract class NavigationSensorService {
  Stream<NavigationLocationUpdateModel> get updates;

  Future<void> start();

  Future<void> stop();

  void dispose();
}
