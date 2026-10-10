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

/// The server answered 404.
///
/// A 404 is two different things: "there is no such book" — a normal outcome
/// when a barcode is not in the catalogue — and "there is no such route",
/// which means the app is talking to a server that is too old (or the wrong
/// one). Only the first may be shown as a missing book, so callers must check
/// [isBookNotFound] rather than treat every 404 alike.
class NotFoundException implements Exception {
  const NotFoundException(this.message, {this.code});
  final String message;

  /// The server's stable error code, when it sent one.
  final String? code;

  /// True only when the server said the book itself does not exist. A server
  /// that sends no code is not trusted to mean it: it cannot tell the
  /// difference, so the safe reading is "something is wrong", not "no book".
  bool get isBookNotFound => code == 'book_not_found';

  @override
  String toString() => 'NotFoundException: $message';
}
