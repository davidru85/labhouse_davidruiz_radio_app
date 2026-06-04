import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/utils/station_subtitle.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';
import 'package:radio_app/presentation/widgets/glass_app_bar.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

/// Browse-and-search list of radio stations.
///
/// Renders the shared [StationsBloc] state with a native Material (Android) or
/// Cupertino (iOS) presentation via [PlatformBuilder]. Search is hosted on this
/// screen (no dedicated search screen) per ADR-0014.
class StationsScreen extends StatelessWidget {
  /// Creates an instance of [StationsScreen].
  const StationsScreen({super.key});

  void _onQueryChanged(BuildContext context, String query) {
    context.read<StationsBloc>().add(StationsSearchChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuilder(
      material: _buildMaterial,
      cupertino: _buildCupertino,
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: glassAppBar(title: Text(l10n.appTitle)),
      body: _content(
        searchField: TextField(
          onChanged: (value) => _onQueryChanged(context, value),
          decoration: InputDecoration(
            hintText: l10n.stationsSearchHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        useCupertino: false,
      ),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.appTitle)),
      child: _content(
        searchField: CupertinoSearchTextField(
          placeholder: l10n.stationsSearchHint,
          onChanged: (value) => _onQueryChanged(context, value),
        ),
        useCupertino: true,
      ),
    );
  }

  /// Shared body layout: while offline, a dedicated offline message with a
  /// retry affordance (per ADR-0013); otherwise a padded [searchField] above
  /// the station list.
  Widget _content({required Widget searchField, required bool useCupertino}) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivity) {
        if (connectivity is ConnectivityOffline) {
          return _OfflineView(useCupertino: useCupertino);
        }
        return SafeArea(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: searchField),
              Expanded(child: _StationsBody(useCupertino: useCupertino)),
            ],
          ),
        );
      },
    );
  }
}

/// Offline state for the Stations (discovery) surface: a clear message plus a
/// retry affordance that re-runs the current query (per ADR-0013).
class _OfflineView extends StatelessWidget {
  const _OfflineView({required this.useCupertino});

  final bool useCupertino;

  void _retry(BuildContext context) {
    final bloc = context.read<StationsBloc>();
    bloc.add(StationsSearchChanged(bloc.state.query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                useCupertino ? CupertinoIcons.wifi_slash : Icons.wifi_off,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(l10n.stationsOfflineMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (useCupertino)
                CupertinoButton.filled(
                  onPressed: () => _retry(context),
                  child: Text(l10n.retryLabel),
                )
              else
                FilledButton(
                  onPressed: () => _retry(context),
                  child: Text(l10n.retryLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the body for the current [StationsState].
class _StationsBody extends StatelessWidget {
  const _StationsBody({required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<StationsBloc, StationsState>(
      builder: (context, state) {
        switch (state.status) {
          case StationsStatus.loading:
            return const AdaptiveProgressIndicator();
          case StationsStatus.failure:
            return Center(child: Text(l10n.genericError));
          case StationsStatus.initial:
          case StationsStatus.success:
            if (state.stations.isEmpty && state.query.isNotEmpty) {
              return Center(child: Text(l10n.stationsEmptyResults));
            }
            return ListView.builder(
              itemCount: state.stations.length,
              itemBuilder: (context, index) {
                return _StationRow(
                  station: state.stations[index],
                  useCupertino: useCupertino,
                );
              },
            );
        }
      },
    );
  }
}

/// A single station row: name plus a "tag • country" subtitle.
///
/// Renders a Material [ListTile] on Android and a [CupertinoListTile] on iOS so
/// the row uses native components on each platform (TECHNICAL_SPEC.md §9).
class _StationRow extends StatelessWidget {
  const _StationRow({required this.station, required this.useCupertino});

  final RadioStation station;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final subtitle = stationSubtitle(station, AppLocalizations.of(context));

    final title = Text(station.name, overflow: TextOverflow.ellipsis);
    final subtitleText = Text(subtitle, overflow: TextOverflow.ellipsis);

    final artwork = StationArtwork(
      station: station,
      size: 64,
      useCupertino: useCupertino,
    );

    if (useCupertino) {
      return CupertinoListTile(
        leading: artwork,
        title: title,
        subtitle: subtitleText,
        onTap: () => _play(context),
      );
    }

    return ListTile(
      leading: artwork,
      title: title,
      subtitle: subtitleText,
      onTap: () => _play(context),
    );
  }

  /// Requests playback of this row's station (play-on-tap).
  void _play(BuildContext context) {
    context.read<RadioPlayerBloc>().add(RadioPlayerPlayRequested(station));
  }
}
