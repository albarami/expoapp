import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class LocalePreference {
  const LocalePreference({this.locale});

  /// `null` means follow device / config default.
  final Locale? locale;
}

/// Persists EN/AR language preference for RTL-aware rebuilds.
class LocaleController extends StateNotifier<LocalePreference> {
  LocaleController({Locale? initialLocale})
      : super(LocalePreference(locale: initialLocale)) {
    if (initialLocale == null) {
      _load();
    }
  }

  static const _prefsKey = 'locale_code';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == 'ar' || code == 'en') {
      state = LocalePreference(locale: Locale(code!));
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = LocalePreference(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  Future<void> clear() async {
    state = const LocalePreference();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
