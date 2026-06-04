import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';
import 'package:radio_app/presentation/theme/app_theme.dart';

/// Slice 2a — Dark theme + Inter font (DESIGN.md §Design Tokens, ADR-0042).
///
/// Pins the design tokens and the Material/Cupertino dark themes so the brand
/// palette and the bundled Inter family cannot silently drift.
void main() {
  group('AppColors (DESIGN.md §Color palette)', () {
    test('core tokens match the documented hex values', () {
      expect(AppColors.background, const Color(0xFF131315));
      expect(AppColors.surface, const Color(0xFF121317));
      expect(AppColors.primary, const Color(0xFFD6E2FF));
      expect(AppColors.onPrimary, const Color(0xFF0C305F));
      expect(AppColors.secondary, const Color(0xFFC2C1FF));
      expect(AppColors.onSurface, const Color(0xFFE4E2E4));
      expect(AppColors.error, const Color(0xFFFFB4AB));
    });

    test('semantic playback tokens match the documented hex values', () {
      expect(AppColors.favoriteActive, const Color(0xFFFF2D55));
      expect(AppColors.playbackAccent, const Color(0xFF30D158));
    });
  });

  group('AppTheme.dark (Material)', () {
    final theme = AppTheme.dark();

    test('is a dark Material 3 theme', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('color scheme is built from the brand tokens', () {
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.onPrimary, AppColors.onPrimary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('uses the bundled Inter font family', () {
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Inter');
      expect(theme.textTheme.titleLarge?.fontFamily, 'Inter');
    });
  });

  group('AppTheme.cupertinoDark (iOS)', () {
    final theme = AppTheme.cupertinoDark();

    test('is a dark Cupertino theme tinted with the brand primary', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.primaryColor, AppColors.primary);
    });

    test('uses the bundled Inter font family', () {
      expect(theme.textTheme.textStyle.fontFamily, 'Inter');
    });
  });
}
