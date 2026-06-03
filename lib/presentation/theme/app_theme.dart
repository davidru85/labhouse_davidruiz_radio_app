import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';

/// The application's dark brand theme (DESIGN.md §Brand & Style, ADR-0042).
///
/// Provides a Material 3 dark theme for Android and a matching Cupertino dark
/// theme for iOS, both built from the [AppColors] tokens and the locally
/// bundled Inter font. Presentation stays unified; only the host widgets differ
/// per platform (see `PlatformBuilder`).
abstract final class AppTheme {
  /// The shared font family bundled in `pubspec.yaml`.
  static const String fontFamily = 'Inter';

  /// The Material dark [ColorScheme] derived from the brand tokens.
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: Color(0xFF272377),
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: Color(0xFF422C00),
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: Color(0xFF231B00),
    error: AppColors.error,
    onError: Color(0xFF690005),
    errorContainer: AppColors.errorContainer,
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceBright: AppColors.surfaceBright,
  );

  /// Builds the Material 3 dark theme for Android (and non-Apple platforms).
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
    );
  }

  /// Builds the matching Cupertino dark theme for iOS.
  static CupertinoThemeData cupertinoDark() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.surfaceElevated,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.primary,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
