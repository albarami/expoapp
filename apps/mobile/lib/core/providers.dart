import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_repository.dart';
import 'api/api_client.dart';
import 'auth/session_controller.dart';
import 'auth/token_storage.dart';
import 'config/app_config.dart';
import 'localization/locale_controller.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

/// Shared [ApiClient]. Unauthorized handler is wired after session exists.
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(
    config: config,
    tokenStorage: storage,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(apiClientProvider));
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  final controller = SessionController(
    tokenStorage: ref.watch(tokenStorageProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
  // Wire 401 → session expiry without creating a circular provider read
  // during ApiClient construction.
  ref.read(apiClientProvider).onUnauthorized = () => controller.markExpired();
  return controller;
});

final localeControllerProvider =
    StateNotifierProvider<LocaleController, LocalePreference>((ref) {
  return LocaleController();
});
