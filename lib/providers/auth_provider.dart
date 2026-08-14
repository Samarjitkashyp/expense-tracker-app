import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Service providers
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthService(api);
});

// Authentication state definition
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage, // Reset error when not specified
    );
  }
}

// Authentication Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState(isLoading: true)) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authService.getMe();
      if (user != null) {
        state = AuthState(isAuthenticated: true, user: user, isLoading: false);
      } else {
        state = AuthState(isAuthenticated: false, isLoading: false);
      }
    } catch (_) {
      state = AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.login(username: username, password: password);
      final user = await _authService.getMe();
      if (user != null) {
        state = AuthState(isAuthenticated: true, user: user, isLoading: false);
        return true;
      } else {
        state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: 'Failed to retrieve profile');
        return false;
      }
    } catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.signup(username: username, email: email, password: password);
      // Automatically login after successful signup
      return await login(username, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = AuthState(isAuthenticated: false, isLoading: false);
  }
}

// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
