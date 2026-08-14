import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/expense.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthService(this._apiService) : _storage = const FlutterSecureStorage();

  Future<UserModel> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/signup',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Registration failed';
      throw Exception(message);
    }
  }

  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      // FastAPI OAuth2PasswordRequestForm expects credentials as form URLencoded / multipart form data
      final response = await _apiService.dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': username,
          'password': password,
        }),
      );
      
      final token = response.data['access_token'] as String;
      await _storage.write(key: 'jwt_token', value: token);
      return token;
    } on DioException catch (e) {
      String message;
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        message = 'Incorrect username or password.';
      } else if (e.response != null && e.response?.data is Map && e.response?.data['detail'] != null) {
        message = e.response?.data['detail'].toString() ?? 'Backend error. Please try again.';
      } else {
        message = 'Backend error. Please check connection.';
      }
      throw Exception(message);
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _apiService.dio.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Token might be invalid/expired, let's delete it
      if (e.response?.statusCode == 401) {
        await logout();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}
