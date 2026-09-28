class ServerException implements Exception {
  const ServerException(this.message);
  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// The server answered 404. Separate from [ServerException] because a
/// missing book is a normal outcome (an unknown QR code), not a failure.
class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}
