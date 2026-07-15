import 'dart:convert';

import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/utils/app_logger.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  DioClient() {
    dio =
        Dio(
            BaseOptions(
              baseUrl: dotenv.env['APPS_SCRIPT_URL'] ?? '',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          )
          ..interceptors.add(_LangInterceptor())
          ..interceptors.add(_TextJsonInterceptor())
          ..interceptors.add(_ErrorInterceptor());
  }

  late final Dio dio;
}

class _LangInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final lang = sl<AppSettingsCubit>().state.locale.languageCode;
    options.queryParameters['lang'] = lang;
    handler.next(options);
  }
}

// Google Apps Script returns Content-Type: text/plain with a JSON body.
// Dio skips auto-parsing for text/plain, so data arrives as a raw String.
class _TextJsonInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.data is String) {
      try {
        response.data = jsonDecode(response.data as String);
      } catch (_) {}
    }
    handler.next(response);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('Network error: ${err.message}');
    handler.next(err);
  }
}
