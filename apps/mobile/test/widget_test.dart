import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/localization/locale_controller.dart';
import 'package:expoapp_mobile/core/providers.dart';

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
