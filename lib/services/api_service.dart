import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio;
  final FlutterSecureStorage _storage;

  ApiService()
      : dio = Dio(),
        _storage = const FlutterSecureStorage() {
    dio.options.baseUrl = _getBaseUrl();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptor to automatically attach authorization header
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // If token has expired or is invalid, clean up local storage
          if (e.response?.statusCode == 401) {
            await _storage.delete(key: 'jwt_token');
          }
          return handler.next(e);
        },
      ),
    );
  }

  String _getBaseUrl() {
    // Backend is hosted on AWS Lightsail and reachable from anywhere
    // (mobile data or any Wi-Fi). Nginx reverse-proxies port 80 to the API.
    const String productionUrl = 'http://13.232.125.72';

    // For local development, uncomment the block below to use a locally-run
    // backend instead (start it with `uvicorn app.main:app --host 0.0.0.0`).
    // if (kIsWeb) return 'http://localhost:8000';
    // try {
    //   if (Platform.isAndroid) return 'http://192.168.0.237:8000';
    // } catch (_) {}
    // return 'http://127.0.0.1:8000';

    return productionUrl;
  }
}
