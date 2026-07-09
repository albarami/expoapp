import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for auth tokens and a light user cache.
///
/// Never stores passwords.
abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<String?> readCurrentUserJson();
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  });
  Future<void> writeCurrentUserJson(String json);
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _currentUserKey = 'currentUser';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<String?> readCurrentUserJson() => _storage.read(key: _currentUserKey);

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<void> writeCurrentUserJson(String json) {
    return _storage.write(key: _currentUserKey, value: json);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _currentUserKey);
  }
}

/// In-memory storage for widget/unit tests.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;
  String? _currentUserJson;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<String?> readCurrentUserJson() async => _currentUserJson;

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
  }

  @override
  Future<void> writeCurrentUserJson(String json) async {
    _currentUserJson = json;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUserJson = null;
  }
}
