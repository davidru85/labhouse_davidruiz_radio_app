import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';

/// Persistent mini-player surfacing the active station above the shell.
///
/// Buffering is rendered distinctly from playing by adding an
/// [AdaptiveProgressIndicator] alongside the station name (per ADR-0015).
/// When the player is idle the bar collapses to zero height, animating the
/// visibility change via an always-mounted [AnimatedSize] (sub-task 9.6).
class MiniPlayerWidget extends StatelessWidget {
  /// Creates an instance of [MiniPlayerWidget].
  const MiniPlayerWidget({super.key});

  /// Duration of the show/hide collapse animation.
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      builder: (context, state) {
        return AnimatedSize(
          duration: _animationDuration,
          child: switch (state) {
            RadioPlayerBuffering(:final station) => _MiniPlayerBar(
              station: station,
              isBuffering: true,
            ),
            RadioPlayerPlaying(:final station) => _MiniPlayerBar(
              station: station,
              isBuffering: false,
            ),
            RadioPlayerPaused(:final station) => _MiniPlayerBar(
              station: station,
              isBuffering: false,
            ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

/// The visible mini-player content for an active [station].
class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({required this.station, required this.isBuffering});

  final RadioStation station;
  final bool isBuffering;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (isBuffering) ...[
              const SizedBox(
                width: 24,
                height: 24,
                child: AdaptiveProgressIndicator(),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                station.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
