import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../l10n/app_localizations.dart';
import 'localization.dart';
import 'router.dart';
import 'theme.dart';

class ExpoApp extends ConsumerWidget {
  const ExpoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final localePref = ref.watch(localeControllerProvider);
    final config = ref.watch(appConfigProvider);
    final locale = localePref.locale ?? Locale(config.defaultLocale);

    return MaterialApp.router(
      onGenerateTitle: (context) {
        // Localizations may not be ready on the first frame.
        try {
          return AppLocalizations.of(context).appName;
        } on Object {
          return 'ExpoApp';
        }
      },
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: AppLocalization.supportedLocales,
      localizationsDelegates: AppLocalization.localizationsDelegates,
      localeResolutionCallback: AppLocalization.localeResolutionCallback,
      routerConfig: router,
    );
  }
}
