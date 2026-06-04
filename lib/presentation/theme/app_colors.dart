import 'package:flutter/widgets.dart';

/// Brand color tokens, transcribed verbatim from `DESIGN.md` §Design Tokens
/// (the Material 3 dark palette exported from Stitch).
///
/// These are the single source of truth for the palette; [AppColors] feeds the
/// Material and Cupertino themes in `app_theme.dart` and the semantic accents
/// (favorite/playback) and the glass stroke used by the glassmorphic surfaces.
abstract final class AppColors {
  /// App canvas background.
  static const Color background = Color(0xFF131315);

  /// Screen and base surface (`surface` / `surface-dim`).
  static const Color surface = Color(0xFF121317);

  /// Lowest elevation surface.
  static const Color surfaceContainerLowest = Color(0xFF0D0E11);

  /// Low elevation surface.
  static const Color surfaceContainerLow = Color(0xFF1A1B1F);

  /// Card surface.
  static const Color surfaceContainer = Color(0xFF1F1F21);

  /// Search fields / raised surface.
  static const Color surfaceContainerHigh = Color(0xFF2A2A2C);

  /// Highest elevation surface (`surface-variant`).
  static const Color surfaceContainerHighest = Color(0xFF343538);

  /// Mini-player elevated glass card.
  static const Color surfaceElevated = Color(0xFF2C2C2E);

  /// Bright surface.
  static const Color surfaceBright = Color(0xFF38393D);

  /// Primary background text.
  static const Color onBackground = Color(0xFFE3E2E6);

  /// Primary surface text.
  static const Color onSurface = Color(0xFFE4E2E4);

  /// Secondary text.
  static const Color onSurfaceVariant = Color(0xFFC0C6D6);

  /// Captions and inactive icons.
  static const Color outline = Color(0xFF8E909A);

  /// Dividers.
  static const Color outlineVariant = Color(0xFF43474F);

  /// Accent, play buttons, active state.
  static const Color primary = Color(0xFFD6E2FF);

  /// Content on [primary].
  static const Color onPrimary = Color(0xFF0C305F);

  /// Filled accents and gradients.
  static const Color primaryContainer = Color(0xFF3E90FF);

  /// Content on [primaryContainer].
  static const Color onPrimaryContainer = Color(0xFF355283);

  /// Secondary accent.
  static const Color secondary = Color(0xFFC2C1FF);

  /// Active navigation pill.
  static const Color secondaryContainer = Color(0xFF332DBD);

  /// Content on [secondaryContainer].
  static const Color onSecondaryContainer = Color(0xFFAEADFF);

  /// Tertiary accent (warm gold / peach).
  static const Color tertiary = Color(0xFFFFDEA7);

  /// Tertiary container.
  static const Color tertiaryContainer = Color(0xFFEDC06D);

  /// Errors.
  static const Color error = Color(0xFFFFB4AB);

  /// Error container.
  static const Color errorContainer = Color(0xFF93000A);

  /// Active favorite heart.
  static const Color favoriteActive = Color(0xFFFF2D55);

  /// "Live" / playback indicator.
  static const Color playbackAccent = Color(0xFF30D158);

  /// Hairline glass borders (`rgba(255,255,255,0.12)`).
  static const Color glassStroke = Color(0x1FFFFFFF);
}
