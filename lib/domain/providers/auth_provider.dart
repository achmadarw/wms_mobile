import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/data/remote/auth_service.dart';
import 'package:wms_mobile/data/local/models/user_model.dart';
import 'package:wms_mobile/config/app_config.dart';

// Auth State
class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    _loadStoredAuth();
  }

  /// Load stored authentication from local storage
  Future<void> _loadStoredAuth() async {
    try {
      final authBox = AppConfig.getBox('auth_box');
      final token = authBox.get('token') as String?;
      final userJson = authBox.get('user');

      if (token != null && userJson != null) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(userJson as Map),
        );
        state = state.copyWith(
          token: token,
          user: user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load stored authentication');
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // Save to local storage
      final authBox = AppConfig.getBox('auth_box');
      await authBox.put('token', response.token);
      await authBox.put('user', response.user.toJson());

      // Update state
      state = state.copyWith(
        token: response.token,
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register user
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phone: phone,
      );

      // Save to local storage
      final authBox = AppConfig.getBox('auth_box');
      await authBox.put('token', response.token);
      await authBox.put('user', response.user.toJson());

      // Update state
      state = state.copyWith(
        token: response.token,
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final authBox = AppConfig.getBox('auth_box');
      await authBox.clear();

      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: 'Failed to logout');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Token Provider for services
final tokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

// User Provider
final userProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
