import 'package:flutter/material.dart';

/// Visual factory that renders platform-appropriate widgets.
///
/// Selects the [cupertino] builder on Apple platforms (iOS, macOS) and the
/// [material] builder everywhere else, based on `Theme.of(context).platform`.
/// This keeps presentation logic unified while letting each screen render the
/// native Material or Cupertino widget tree (see DESIGN.md, "Adaptive Design
/// Requirements").
class PlatformBuilder extends StatelessWidget {
  /// Creates an instance of [PlatformBuilder].
  const PlatformBuilder({
    required this.material,
    required this.cupertino,
    super.key,
  });

  /// Builds the Material widget tree (Android and other platforms).
  final WidgetBuilder material;

  /// Builds the Cupertino widget tree (iOS and macOS).
  final WidgetBuilder cupertino;

  /// Whether the host platform should render Cupertino widgets.
  ///
  /// Resolves from `Theme.of(context).platform` so widget tests can override
  /// the platform via [ThemeData.platform].
  static bool isCupertino(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    return isCupertino(context) ? cupertino(context) : material(context);
  }
}
