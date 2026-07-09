import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/localization/locale_controller.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';

class _NoopAuthRepository implements AuthRepository {
  @override
  Future<AppUser> fetchCurrentUser() async {
    throw const ApiError(
      code: 'UNAUTHORIZED',
      message: 'Unauthorized',
      statusCode: 401,
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    throw ApiError.unknown('unused');
  }

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ExpoApp shows localized login shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          authRepositoryProvider.overrideWithValue(_NoopAuthRepository()),
        ],
        child: const ExpoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ExpoApp'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('Arabic locale renders Arabic login strings', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          authRepositoryProvider.overrideWithValue(_NoopAuthRepository()),
          localeControllerProvider.overrideWith(
            (ref) => LocaleController(initialLocale: const Locale('ar')),
          ),
        ],
        child: const ExpoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
  });
}
