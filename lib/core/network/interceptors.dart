import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_error_mapper.dart';
import '../../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token refresh endpoint
    if (options.path == '/auth/refresh') {
      handler.next(options);
      return;
    }

    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 errors, and skip refresh token endpoint and auth endpoints
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/auth/refresh' &&
        err.requestOptions.path != '/auth/login' &&
        err.requestOptions.path != '/auth/register' &&
        err.requestOptions.path != '/auth/forgot-password' &&
        err.requestOptions.path != '/auth/reset-password') {
      // If already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken == null) {
          await SecureStorage.clearAll();
          handler.next(err);
          _isRefreshing = false;
          _processPendingRequests(err, null);
          return;
        }

        // Try to refresh the token using a separate Dio instance to avoid circular dependency
        final refreshDio = Dio();
        refreshDio.options.baseUrl = AppConfig.apiBaseUrl;
        refreshDio.options.headers['Content-Type'] = 'application/json';

        final refreshResponse = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (refreshResponse.statusCode == 200) {
          final data = refreshResponse.data as Map<String, dynamic>;
          await SecureStorage.saveAccessToken(data['accessToken'] as String);
          await SecureStorage.saveRefreshToken(data['refreshToken'] as String);

          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${data['accessToken']}';

          final retryDio = Dio();
          retryDio.options.baseUrl = AppConfig.apiBaseUrl;
          retryDio.options.headers['Content-Type'] = 'application/json';
          retryDio.options.headers['Authorization'] =
              'Bearer ${data['accessToken']}';

          final retryResponse = await retryDio.request(
            opts.path,
            data: opts.data,
            queryParameters: opts.queryParameters,
            options: Options(method: opts.method),
          );

          handler.resolve(
            Response(
              requestOptions: opts,
              data: retryResponse.data,
              statusCode: retryResponse.statusCode,
              headers: retryResponse.headers,
            ),
          );

          // Process pending requests
          _processPendingRequests(null, data['accessToken'] as String);
        } else {
          throw Exception('Token refresh failed');
        }
      } catch (e) {
        // Refresh failed, clear tokens and fail the request
        await SecureStorage.clearAll();
        handler.next(err);
        _processPendingRequests(err, null);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  void _processPendingRequests(DioException? error, String? newToken) {
    for (final pending in _pendingRequests) {
      if (error != null) {
        pending.handler.next(error);
      } else if (newToken != null) {
        // Retry pending request with new token
        final retryDio = Dio();
        retryDio.options.baseUrl = AppConfig.apiBaseUrl;
        retryDio.options.headers['Content-Type'] = 'application/json';
        retryDio.options.headers['Authorization'] = 'Bearer $newToken';

        retryDio
            .request(
              pending.requestOptions.path,
              data: pending.requestOptions.data,
              queryParameters: pending.requestOptions.queryParameters,
              options: Options(method: pending.requestOptions.method),
            )
            .then((response) {
              pending.handler.resolve(
                Response(
                  requestOptions: pending.requestOptions,
                  data: response.data,
                  statusCode: response.statusCode,
                  headers: response.headers,
                ),
              );
            })
            .catchError((e) {
              pending.handler.next(e as DioException);
            });
      }
    }
    _pendingRequests.clear();
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.requestOptions, this.handler);
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final errorMessage = ApiErrorMapper.mapError(err);
    final modifiedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );
    handler.next(modifiedError);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      print('QUERY: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('BODY: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('ERROR MESSAGE: ${err.error}');
    handler.next(err);
  }
}
