import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/utils/country_name_resolver.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/l10n/country_name_lookup.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';

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
      appBar: AppBar(title: Text(l10n.appTitle)),
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

  /// Shared body layout: a padded [searchField] above the station list.
  Widget _content({required Widget searchField, required bool useCupertino}) {
    return SafeArea(
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: searchField),
          Expanded(child: _StationsBody(useCupertino: useCupertino)),
        ],
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
            return Center(
              child: useCupertino
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator(),
            );
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
    final country = resolveCountryName(
      station.countryCode,
      countryNameLookup(AppLocalizations.of(context)),
    );
    final primaryTag = station.tagList.isNotEmpty
        ? station.tagList.first
        : null;
    final subtitle = primaryTag == null ? country : '$primaryTag • $country';

    final title = Text(station.name, overflow: TextOverflow.ellipsis);
    final subtitleText = Text(subtitle, overflow: TextOverflow.ellipsis);

    if (useCupertino) {
      return CupertinoListTile(
        leading: const Icon(CupertinoIcons.antenna_radiowaves_left_right),
        title: title,
        subtitle: subtitleText,
      );
    }

    return ListTile(
      leading: const Icon(Icons.radio),
      title: title,
      subtitle: subtitleText,
    );
  }
}
