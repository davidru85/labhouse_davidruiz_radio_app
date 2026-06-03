import 'package:flutter/material.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';

/// A "Live Now" indicator: a pulsing [AppColors.playbackAccent] dot signalling
/// active playback, with an optional [label] beside it (DESIGN.md
/// §Mini-Player / §3).
///
/// The dot fades between a dimmed and a full opacity on a repeating
/// reverse cycle. Because the animation never settles, widget tests that render
/// an active player must drive frames with `pump`/`pump(Duration)` rather than
/// `pumpAndSettle` (see `app_shell_mini_progress_test.dart`).
class LiveNowIndicator extends StatefulWidget {
  /// Creates an instance of [LiveNowIndicator].
  const LiveNowIndicator({this.size = 8, this.label, super.key});

  /// Diameter of the dot in logical pixels.
  final double size;

  /// Optional text shown beside the dot (e.g. "Live").
  final String? label;

  @override
  State<LiveNowIndicator> createState() => _LiveNowIndicatorState();
}

class _LiveNowIndicatorState extends State<LiveNowIndicator>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 1200);
  static const double _minOpacity = 0.35;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: _minOpacity,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: AppColors.playbackAccent,
          shape: BoxShape.circle,
        ),
      ),
    );

    final label = widget.label;
    if (label == null) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.playbackAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
