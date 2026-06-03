import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';
import 'package:radio_app/presentation/utils/now_playing_label.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';
import 'package:radio_app/presentation/widgets/glass_surface.dart';
import 'package:radio_app/presentation/widgets/live_now_indicator.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

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
  ///
  /// [showProgress] pins a thin playback progress bar to the bottom edge of the
  /// card; the shell enables it on the Favorites tab (DESIGN.md §Mini-Player).
  const MiniPlayerWidget({this.onTap, this.showProgress = false, super.key});

  /// Called when the visible mini-player bar is tapped.
  final VoidCallback? onTap;

  /// Whether to show the bottom playback progress bar (Favorites only).
  final bool showProgress;

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
              isLive: false,
              showProgress: showProgress,
              onTap: onTap,
            ),
            RadioPlayerPlaying(:final station, :final nowPlaying) =>
              _MiniPlayerBar(
                station: station,
                isBuffering: false,
                isLive: true,
                nowPlaying: nowPlaying,
                showProgress: showProgress,
                onTap: onTap,
              ),
            RadioPlayerPaused(:final station) => _MiniPlayerBar(
              station: station,
              isBuffering: false,
              isLive: false,
              showProgress: showProgress,
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
    required this.isLive,
    required this.showProgress,
    this.nowPlaying,
    this.onTap,
  });

  final RadioStation station;
  final bool isBuffering;
  final bool isLive;
  final bool showProgress;
  final NowPlayingInfo? nowPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tap = onTap;
    final card = GlassSurface(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      // The mini-player is a `surface-elevated/95` glass card (DESIGN.md
      // §Mini-Player) — nearly opaque so the now-playing text stays legible.
      color: AppColors.surfaceElevated.withValues(alpha: 0.95),
      child: Material(
        type: MaterialType.transparency,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    StationArtwork(
                      station: station,
                      size: 48,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      // The mini-player is Material chrome, but its
                      // sub-elements are platform-variant (like
                      // AdaptiveProgressIndicator); keep the fallback icon
                      // native on iOS too.
                      useCupertino: PlatformBuilder.isCupertino(context),
                    ),
                    const SizedBox(width: 12),
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
                    // Pulsing "Live Now" dot during active playback (DESIGN.md
                    // §Mini-Player); hidden while buffering or paused.
                    if (isLive) ...[
                      const SizedBox(width: 12),
                      const LiveNowIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!showProgress) return card;

    // A 2px playback progress bar pinned to the bottom edge of the card on the
    // Favorites screen (DESIGN.md §Mini-Player). Live radio has no seekable
    // position, so it is indeterminate.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        const SizedBox(height: 2, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}
