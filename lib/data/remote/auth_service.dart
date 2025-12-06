import 'package:wms_mobile/data/local/models/user_model.dart';
import 'package:wms_mobile/data/remote/api_client.dart';
import 'package:wms_mobile/config/api_config.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested token structure from API
    final tokenData = json['token'];
    final String accessToken;

    if (tokenData is Map<String, dynamic>) {
      // API returns { token: { accessToken: "...", expiresIn: ... } }
      accessToken = tokenData['accessToken'] as String;
    } else if (tokenData is String) {
      // Fallback for direct string token
      accessToken = tokenData;
    } else {
      throw Exception('Invalid token format in response');
    }

    return AuthResponse(
      token: accessToken,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthService {
  late final ApiClient _apiClient;

  AuthService() {
    _apiClient = ApiClient();
  }

  AuthService.withToken(String token) {
    _apiClient = ApiClient(token: token);
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return _apiClient.post<AuthResponse>(
      ApiConfig.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? phone,
    String? avatar,
  }) async {
    return _apiClient.post<AuthResponse>(
      ApiConfig.registerEndpoint,
      data: {
        'email': email,
        'password': password,
        'username': username,
        'fullName': fullName,
        'phone': phone,
        'avatar': avatar,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Verify token - useful for checking if stored token is still valid
  Future<UserModel> verifyToken(String token) async {
    final client = ApiClient(token: token);
    try {
      // You might need to add this endpoint to your backend
      final response = await client.get<Map<String, dynamic>>(
        '/api/auth/verify',
      );
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update token
  void updateToken(String token) {
    _apiClient.updateToken(token);
  }

  /// Clear token
  void clearToken() {
    _apiClient.clearToken();
  }
}
