import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref.watch(tokenStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);
  final session = ref.read(sessionControllerProvider.notifier);
  return ApiClient(
    config: config,
    tokenStorage: storage,
    onUnauthorized: () => session.markExpired(),
  );
});

final localeControllerProvider =
    StateNotifierProvider<LocaleController, LocalePreference>((ref) {
  return LocaleController();
});
