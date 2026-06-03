import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/utils/station_subtitle.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

/// Active-favorite heart colour from DESIGN.md (`favorite-active`).
const _favoriteActive = Color(0xFFFF2D55);

/// Grid of the user's favorite stations.
///
/// Renders the shared [FavoritesBloc] state with a native Material (Android) or
/// Cupertino (iOS) presentation via [PlatformBuilder].
class FavoritesScreen extends StatelessWidget {
  /// Creates an instance of [FavoritesScreen].
  const FavoritesScreen({this.onExplore, super.key});

  /// Invoked when the empty-state "Explore Stations" action is tapped.
  final VoidCallback? onExplore;

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
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: _FavoritesBody(useCupertino: false, onExplore: onExplore),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.favoritesTitle)),
      child: SafeArea(
        child: _FavoritesBody(useCupertino: true, onExplore: onExplore),
      ),
    );
  }
}

/// Renders the body for the current [FavoritesState].
class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody({required this.useCupertino, this.onExplore});

  final bool useCupertino;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        switch (state) {
          case FavoritesInitial():
          case FavoritesLoadInProgress():
            return const AdaptiveProgressIndicator();
          case FavoritesLoadFailure():
            return Center(child: Text(l10n.genericError));
          case FavoritesLoadSuccess(:final stations):
            if (stations.isEmpty) {
              return _EmptyState(
                useCupertino: useCupertino,
                onExplore: onExplore,
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: stations.length,
              itemBuilder: (context, index) => _FavoriteCard(
                station: stations[index],
                useCupertino: useCupertino,
              ),
            );
        }
      },
    );
  }
}

/// Empty-favorites placeholder with an explore call to action.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.useCupertino, this.onExplore});

  final bool useCupertino;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              useCupertino ? CupertinoIcons.heart : Icons.favorite_border,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.favoritesEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(l10n.favoritesEmptyMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (useCupertino)
              CupertinoButton.filled(
                onPressed: onExplore,
                child: Text(l10n.favoritesExplore),
              )
            else
              FilledButton(
                onPressed: onExplore,
                child: Text(l10n.favoritesExplore),
              ),
          ],
        ),
      ),
    );
  }
}

/// A favorite station grid card: artwork with an overlaid favorite toggle plus
/// the station name and a "tag • country" subtitle.
class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.station, required this.useCupertino});

  final RadioStation station;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = stationSubtitle(station, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: StationArtwork(
                  station: station,
                  borderRadius: BorderRadius.circular(16),
                  useCupertino: useCupertino,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _FavoriteToggle(
                  station: station,
                  useCupertino: useCupertino,
                  label: l10n.favoritesRemoveLabel,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          station.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Adaptive favorite toggle button with an accessible label (TECHNICAL_SPEC
/// §10): Material [IconButton] with a tooltip on Android, [CupertinoButton]
/// wrapped in [Semantics] on iOS. Both meet the platform touch-target minimum.
class _FavoriteToggle extends StatelessWidget {
  const _FavoriteToggle({
    required this.station,
    required this.useCupertino,
    required this.label,
  });

  final RadioStation station;
  final bool useCupertino;
  final String label;

  void _toggle(BuildContext context) {
    context.read<FavoritesBloc>().add(FavoriteToggled(station));
  }

  @override
  Widget build(BuildContext context) {
    // A single Semantics node carries the label across both platforms (Material
    // and Cupertino merge child icon labels differently); the Tooltip is
    // excluded from semantics to avoid a duplicate label node. Each button
    // meets its touch-target minimum (48dp Material / 44pt Cupertino) per
    // TECHNICAL_SPEC §10.
    final icon = Icon(
      useCupertino ? CupertinoIcons.heart_fill : Icons.favorite,
      color: _favoriteActive,
    );
    final button = useCupertino
        ? CupertinoButton(
            minimumSize: const Size(44, 44),
            padding: EdgeInsets.zero,
            onPressed: () => _toggle(context),
            child: icon,
          )
        : IconButton(onPressed: () => _toggle(context), icon: icon);
    return Semantics(
      label: label,
      button: true,
      container: true,
      child: Tooltip(message: label, excludeFromSemantics: true, child: button),
    );
  }
}
