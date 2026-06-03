import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

/// Full-screen now-playing view reached from the mini-player (sub-task 9.7),
/// presented as a bottom-to-top slide (sub-task 9.8).
///
/// Renders the live now-playing track/artist with a station-name fallback
/// (sub-task 9.12, per ADR-0012), a single 80dp play/pause transport control
/// (per ADR-0010 there is no volume control; per ADR-0022 no skip controls),
/// a buffering indicator, and a collapse control to dismiss the view. All
/// interactive controls expose Semantics labels (sub-task 9.13, per ADR-0006).
class FullPlayerScreen extends StatelessWidget {
  /// Creates an instance of [FullPlayerScreen].
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformBuilder(
      material: _buildMaterial,
      cupertino: _buildCupertino,
    );
  }

  Widget _buildMaterial(BuildContext context) =>
      Scaffold(body: SafeArea(child: _body(context, useCupertino: false)));

  Widget _buildCupertino(BuildContext context) => CupertinoPageScaffold(
    child: SafeArea(child: _body(context, useCupertino: true)),
  );

  Widget _body(BuildContext context, {required bool useCupertino}) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      builder: (context, state) =>
          _PlayerView(state: state, useCupertino: useCupertino),
    );
  }
}

/// The full-player layout for a given [state].
class _PlayerView extends StatelessWidget {
  const _PlayerView({required this.state, required this.useCupertino});

  final RadioPlayerState state;
  final bool useCupertino;

  RadioStation? get _station => switch (state) {
    RadioPlayerBuffering(:final station) => station,
    RadioPlayerPlaying(:final station) => station,
    RadioPlayerPaused(:final station) => station,
    RadioPlayerError(:final station) => station,
    _ => null,
  };

  NowPlayingInfo? get _nowPlaying => switch (state) {
    RadioPlayerPlaying(:final nowPlaying) => nowPlaying,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final station = _station;
    final nowPlaying = _nowPlaying;

    // The full player renders track, artist and station name as separate
    // collapsing elements (ADR-0012 §"UI projection"), so it does not reuse the
    // single-line `nowPlayingLabel` helper the mini-player uses.
    final track = nowPlaying?.track;
    final primary = (track != null && track.isNotEmpty)
        ? track
        : (station?.name ?? '');
    final artist = nowPlaying?.artist;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _TopBar(useCupertino: useCupertino, title: l10n.playerNowPlaying),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (station != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: ConstrainedBox(
                        // Hero artwork up to 320dp square (DESIGN.md §3); it
                        // shrinks via Flexible so large text never overflows.
                        constraints: const BoxConstraints(
                          maxWidth: 320,
                          maxHeight: 320,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: StationArtwork(
                            station: station,
                            borderRadius: BorderRadius.circular(24),
                            iconSize: 96,
                            useCupertino: useCupertino,
                          ),
                        ),
                      ),
                    ),
                  ),
                Text(
                  primary,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall,
                ),
                if (artist != null && artist.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    artist,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
                if (station != null && station.name != primary) ...[
                  const SizedBox(height: 8),
                  Text(
                    station.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: _Transport(state: state, useCupertino: useCupertino),
          ),
        ],
      ),
    );
  }
}

/// Top bar with a collapse control and the centered "Now Playing" title.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.useCupertino, required this.title});

  final bool useCupertino;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _ControlButton(
          icon: useCupertino ? CupertinoIcons.chevron_down : Icons.expand_more,
          label: l10n.playerCollapseLabel,
          useCupertino: useCupertino,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        // Balances the leading collapse button (one touch-target wide) so the
        // title stays centered.
        const SizedBox(width: kMinInteractiveDimension),
      ],
    );
  }
}

/// The central 80dp transport control: a progress indicator while buffering,
/// otherwise a play/pause toggle wired to [RadioPlayerBloc].
class _Transport extends StatelessWidget {
  const _Transport({required this.state, required this.useCupertino});

  final RadioPlayerState state;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state is RadioPlayerBuffering) {
      return const SizedBox(
        width: 80,
        height: 80,
        child: AdaptiveProgressIndicator(),
      );
    }

    final isPlaying = state is RadioPlayerPlaying;
    final label = isPlaying ? l10n.playerPauseLabel : l10n.playerPlayLabel;
    final icon = isPlaying
        ? (useCupertino ? CupertinoIcons.pause_solid : Icons.pause)
        : (useCupertino ? CupertinoIcons.play_arrow_solid : Icons.play_arrow);

    return _ControlButton(
      icon: icon,
      label: label,
      useCupertino: useCupertino,
      iconSize: 56,
      onPressed: () => _onPressed(context),
    );
  }

  void _onPressed(BuildContext context) {
    final bloc = context.read<RadioPlayerBloc>();
    switch (state) {
      case RadioPlayerPlaying():
        bloc.add(const RadioPlayerPauseRequested());
      case RadioPlayerPaused(:final station):
        bloc.add(RadioPlayerPlayRequested(station));
      case RadioPlayerError(:final station?):
        bloc.add(RadioPlayerPlayRequested(station));
      case _:
        break;
    }
  }
}

/// Platform-adaptive icon-only control: a Material [IconButton] on Android and
/// a [CupertinoButton] on iOS, each carrying a meaningful Semantics [label]
/// plus a [Tooltip] (per TECHNICAL_SPEC §10 / ADR-0006). Both meet the platform
/// minimum touch target.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.useCupertino,
    required this.onPressed,
    this.iconSize,
  });

  final IconData icon;
  final String label;
  final bool useCupertino;
  final VoidCallback onPressed;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final button = useCupertino
        ? CupertinoButton(
            minimumSize: const Size(44, 44),
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: Icon(icon, size: iconSize),
          )
        : IconButton(
            iconSize: iconSize ?? 24,
            onPressed: onPressed,
            icon: Icon(icon),
          );
    return Semantics(
      button: true,
      container: true,
      label: label,
      child: Tooltip(message: label, excludeFromSemantics: true, child: button),
    );
  }
}
