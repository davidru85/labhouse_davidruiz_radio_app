import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';

/// Centered platform-adaptive loading indicator.
///
/// Renders a [CupertinoActivityIndicator] on iOS/macOS and a
/// [CircularProgressIndicator] elsewhere, resolved via
/// [PlatformBuilder.isCupertino].
class AdaptiveProgressIndicator extends StatelessWidget {
  /// Creates an instance of [AdaptiveProgressIndicator].
  const AdaptiveProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PlatformBuilder.isCupertino(context)
          ? const CupertinoActivityIndicator()
          : const CircularProgressIndicator(),
    );
  }
}
