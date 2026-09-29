import 'dart:convert';
import 'dart:typed_data';

import 'package:dalili/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers each call from a scripted list: a [DioException] is thrown, a
/// status code is returned as a JSON response.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._script);

  final List<Object> _script;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final step = _script[calls < _script.length ? calls : _script.length - 1];
    calls++;
    if (step is DioException) {
      throw DioException(requestOptions: options, type: step.type);
    }
    return ResponseBody.fromString(
      jsonEncode({'status': 'success', 'data': {}}),
      step as int,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DioException _fail(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(), type: type);

Dio _dioWith(_ScriptedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(RetryInterceptor(dio));
  return dio;
}

void main() {
  setUp(() => RetryInterceptor.backoff = (_) => Duration.zero);

  test(
    'recovers when the server fails twice while waking, then answers',
    () async {
      final adapter = _ScriptedAdapter([
        _fail(DioExceptionType.connectionTimeout),
        _fail(DioExceptionType.connectionError),
        200,
      ]);

      final response = await _dioWith(adapter).get<dynamic>('/health');

      expect(response.statusCode, 200);
      expect(adapter.calls, 3);
    },
  );

  test('gives up after two retries instead of looping forever', () async {
    final adapter = _ScriptedAdapter([_fail(DioExceptionType.receiveTimeout)]);

    await expectLater(
      _dioWith(adapter).get<dynamic>('/health'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 3); // the original try + 2 retries
  });

  test('does not retry an HTTP answer such as 404', () async {
    final adapter = _ScriptedAdapter([404]);

    await expectLater(
      _dioWith(adapter).get<dynamic>('/books/nope'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
  });

  test('does not retry a POST, which may not be safe to repeat', () async {
    final adapter = _ScriptedAdapter([
      _fail(DioExceptionType.connectionTimeout),
    ]);

    await expectLater(
      _dioWith(adapter).post<dynamic>('/anything'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
  });
}
