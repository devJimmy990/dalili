abstract class CompassService {
  Stream<double> get heading;

  Future<void> start();

  Future<void> stop();

  void dispose();
}
