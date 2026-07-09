import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

/// Localization delegates and supported locales for ExpoApp.
abstract final class AppLocalization {
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) {
      return supportedLocales.first;
    }
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return supportedLocales.first;
  }

  /// Prefer Arabic text when present; otherwise English.
  static String localizedName({
    required Locale locale,
    required String nameEn,
    String? nameAr,
  }) {
    if (locale.languageCode == 'ar' &&
        nameAr != null &&
        nameAr.trim().isNotEmpty) {
      return nameAr;
    }
    return nameEn;
  }
}
