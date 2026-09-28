import 'package:dalili/core/constants/api_constants.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/errors/exceptions.dart';
import 'package:dalili/core/utils/app_logger.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Thin wrapper around [Dio] pointed at the Dalili REST API.
class DioClient {
  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        // The API answers 404 for an unknown id, which the data source
        // turns into `null`. Letting Dio treat it as a response instead of
        // an exception keeps that path out of the error handling.
        validateStatus: (status) => status != null && status < 500,
        headers: {'Accept': 'application/json'},
      ),
    )..interceptors.addAll([_LangInterceptor(), _LogInterceptor()]);
  }

  late final Dio dio;

  /// Base URL of the API, e.g. `https://dalili-api.onrender.com/api`.
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL']?.trim();
    if (url == null || url.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing from .env — copy .env.example and set it.',
      );
    }
    // A trailing slash would make every path double up ("//books").
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}

/// Sends the active locale with every request; the API localizes department
/// and place names, ordinal labels and error messages from it.
class _LangInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters[ApiConstants.paramLang] =
        sl<AppSettingsCubit>().state.locale.languageCode;
    handler.next(options);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'Network error ${err.requestOptions.method} '
      '${err.requestOptions.path}: ${err.message}',
    );
    handler.next(err);
  }
}

/// Reads the `{ status, data }` envelope every endpoint returns, and turns a
/// failure into the matching exception. The API already localized
/// `message`, so it is safe to show to the user.
extension ApiResponse on Response<dynamic> {
  Map<String, dynamic> get envelope {
    final body = data;
    if (body is! Map) {
      throw ServerException('Unexpected response body: ${body.runtimeType}');
    }
    return body.cast<String, dynamic>();
  }

  /// The `data` object of a successful response.
  ///
  /// Throws [NotFoundException] on 404 and [ServerException] on anything
  /// else the server rejected.
  Map<String, dynamic> get payload {
    final body = envelope;

    if (body['status'] == 'error' || (statusCode ?? 500) >= 400) {
      final message = body['message']?.toString() ?? 'HTTP $statusCode';
      if (statusCode == 404) throw NotFoundException(message);
      throw ServerException(message);
    }

    final inner = body['data'];
    return inner is Map ? inner.cast<String, dynamic>() : body;
  }
}

/// Maps Dio's transport-level failures onto the app's exceptions so the
/// repository layer only ever sees the app's own types.
Never rethrowAsAppException(DioException error) {
  final message = switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      'Connection timed out',
    DioExceptionType.connectionError => 'Cannot reach the server',
    _ => error.message ?? 'Unknown network error',
  };

  if (error.type == DioExceptionType.badResponse) {
    final body = error.response?.data;
    final serverMessage = body is Map ? body['message']?.toString() : null;
    if (error.response?.statusCode == 404) {
      throw NotFoundException(serverMessage ?? 'Not found');
    }
    throw ServerException(serverMessage ?? message);
  }

  throw NetworkException(message);
}
