import 'package:dalili/features/library/data/models/navigation/step_update_model.dart';

abstract class StepCounterService {
  Stream<StepUpdateModel> get steps;

  Future<void> start();

  Future<void> stop();

  void dispose();
}
