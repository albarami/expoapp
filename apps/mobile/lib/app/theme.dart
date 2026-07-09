import 'package:flutter/material.dart';

import 'theme_tokens.dart';

/// Material 3 theme for ExpoApp (enterprise, high-contrast, clean).
///
/// Skill: ui-ux-pro-max (+ flutter.csv) — ColorScheme tokens, ThemeData,
/// const-friendly widgets, 44px touch targets via shared components.
abstract final class AppTheme {
  /// Deep teal primary — professional enterprise, not purple/indigo AI default.
  static const Color _seed = Color(0xFF0F5C4C);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      primary: const Color(0xFF0F5C4C),
      secondary: const Color(0xFF1B6B93),
      surface: const Color(0xFFF7F9F8),
      error: const Color(0xFFB3261E),
    );

    return _base(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      primary: const Color(0xFF5DDBB8),
      secondary: const Color(0xFF7EC8E3),
      error: const Color(0xFFF2B8B5),
    );

    return _base(colorScheme);
  }

  static ThemeData _base(ColorScheme colorScheme) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        shape: shape,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppTouchTarget.min, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppTouchTarget.min, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.secondaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

/// Semantic status colors layered on Material scheme.
abstract final class AppStatusColors {
  static const Color success = Color(0xFF1B7F4E);
  static const Color warning = Color(0xFFB86E00);
  static const Color info = Color(0xFF1B6B93);
  static const Color danger = Color(0xFFB3261E);
}
