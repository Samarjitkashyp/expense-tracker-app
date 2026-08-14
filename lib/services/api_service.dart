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
    // If using a physical Android device, you can connect via Wi-Fi by using your PC's IP.
    // Ensure you start the backend server with: `uvicorn app.main:app --host 0.0.0.0 --reload`
    // Alternatively, connect via USB, run `adb reverse tcp:8000 tcp:8000` and use 'http://127.0.0.1:8000'.
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://192.168.0.237:8000';
      }
    } catch (_) {
      // Platform check can throw on web environments in some configurations
    }
    return 'http://127.0.0.1:8000';
  }
}
