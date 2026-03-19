import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage, required this.dio});

  final FlutterSecureStorage storage;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: ApiConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await storage.read(key: ApiConstants.tokenKey);
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';
          final response = await dio.fetch(opts);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // Refresh failed — clear tokens
        await storage.delete(key: ApiConstants.tokenKey);
        await storage.delete(key: ApiConstants.refreshTokenKey);
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storage.read(key: ApiConstants.refreshTokenKey);
    if (refreshToken == null) return false;

    final response = await dio.post(
      ApiConstants.authRefresh,
      data: {'refresh_token': refreshToken},
    );
    final newAccess = response.data['access_token'] as String?;
    final newRefresh = response.data['refresh_token'] as String?;
    if (newAccess == null) return false;

    await storage.write(key: ApiConstants.tokenKey, value: newAccess);
    if (newRefresh != null) {
      await storage.write(key: ApiConstants.refreshTokenKey, value: newRefresh);
    }
    return true;
  }
}
