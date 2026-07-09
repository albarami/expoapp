import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../../../core/auth/app_user.dart';

/// Result of a successful `POST /auth/login`.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;
}

/// Auth API surface used by [SessionController].
abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AppUser> fetchCurrentUser();

  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email.trim(),
        'password': password,
      },
    );
    final data = response.data;
    if (data == null) {
      throw ApiError.unknown('Empty login response');
    }
    return _sessionFromJson(data);
  }

  @override
  Future<AppUser> fetchCurrentUser() async {
    final response = await _api.get<Map<String, dynamic>>('/auth/me');
    final data = response.data;
    if (data == null) {
      throw ApiError.unknown('Empty /auth/me response');
    }
    return AppUser.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _api.post<Map<String, dynamic>>('/auth/logout');
  }

  AuthSession _sessionFromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw ApiError.unknown('Login response missing user');
    }
    final accessToken = json['accessToken']?.toString();
    final refreshToken = json['refreshToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiError.unknown('Login response missing accessToken');
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
      user: AppUser.fromJson(userJson),
    );
  }
}
