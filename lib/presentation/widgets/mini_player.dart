import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/utils/now_playing_label.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';

/// Persistent mini-player surfacing the active station above the shell.
///
/// Buffering is rendered distinctly from playing by adding an
/// [AdaptiveProgressIndicator] alongside the station name (per ADR-0015).
/// When the player is idle the bar collapses to zero height, animating the
/// visibility change via an always-mounted [AnimatedSize] (sub-task 9.6).
class MiniPlayerWidget extends StatelessWidget {
  /// Creates an instance of [MiniPlayerWidget].
  ///
  /// [onTap] is invoked when the bar is tapped; the shell wires it to navigate
  /// to the full player (sub-task 9.7). When null the bar is non-interactive.
  const MiniPlayerWidget({this.onTap, super.key});

  /// Called when the visible mini-player bar is tapped.
  final VoidCallback? onTap;

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
              onTap: onTap,
            ),
            RadioPlayerPlaying(:final station, :final nowPlaying) =>
              _MiniPlayerBar(
                station: station,
                isBuffering: false,
                nowPlaying: nowPlaying,
                onTap: onTap,
              ),
            RadioPlayerPaused(:final station) => _MiniPlayerBar(
              station: station,
              isBuffering: false,
              onTap: onTap,
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
  const _MiniPlayerBar({
    required this.station,
    required this.isBuffering,
    this.nowPlaying,
    this.onTap,
  });

  final RadioStation station;
  final bool isBuffering;
  final NowPlayingInfo? nowPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tap = onTap;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Semantics(
        // Interactive widgets must expose a meaningful screen-reader label
        // (per ADR-0006 / TECHNICAL_SPEC §10). Only annotate the button role
        // when the bar is actually tappable.
        button: tap != null,
        label: tap != null
            ? AppLocalizations.of(context).miniPlayerOpenLabel
            : null,
        child: InkWell(
          onTap: tap,
          // Keep the tap target at the platform minimum touch size
          // (kMinInteractiveDimension == 48dp, ≥ the 44pt iOS minimum), per
          // ADR-0006 / TECHNICAL_SPEC §10.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
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
                      nowPlayingLabel(station, nowPlaying),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
