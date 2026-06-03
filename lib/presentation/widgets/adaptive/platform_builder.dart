import 'package:flutter/widgets.dart';

/// Visual factory that renders platform-appropriate widgets.
///
/// Stub implementation — intentionally incomplete to drive the RED phase.
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
  static bool isCupertino(BuildContext context) => false;

  @override
  Widget build(BuildContext context) => material(context);
}
