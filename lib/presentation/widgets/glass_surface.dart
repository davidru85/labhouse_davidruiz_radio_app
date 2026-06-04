import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';

/// A glassmorphic surface: a backdrop blur behind a translucent, hairline
/// bordered, rounded panel (DESIGN.md §Effects / "Precision Glass").
///
/// Used for the brand's "Atmospheric Depth" chrome — the mini-player, the tab
/// bar, and (via [GlassSurface.panel]) the full-player glass panel. The blur is
/// rendered with a [BackdropFilter] so the content behind shows through the
/// translucent [color]; a 1px [AppColors.glassStroke] border defines the edge.
class GlassSurface extends StatelessWidget {
  /// Creates a glass surface with the default bar/card blur (20px).
  const GlassSurface({
    required this.child,
    this.blurSigma = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.padding,
    super.key,
  });

  /// Creates the denser full-player glass panel (40px blur).
  const GlassSurface.panel({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.padding,
    super.key,
  }) : blurSigma = 40;

  /// The content rendered on top of the glass.
  final Widget child;

  /// The gaussian blur applied to the backdrop, in logical pixels.
  ///
  /// Defaults to 20 for bars and cards; [GlassSurface.panel] raises it to 40.
  final double blurSigma;

  /// The rounded shape the surface is clipped to.
  final BorderRadius borderRadius;

  /// The translucent fill drawn over the blurred backdrop.
  ///
  /// Defaults to a translucent [AppColors.surfaceElevated] so the blurred
  /// content shows through.
  final Color? color;

  /// Optional inner padding around [child].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? AppColors.surfaceElevated.withValues(alpha: 0.7);
    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.glassStroke),
          ),
          child: content,
        ),
      ),
    );
  }
}
