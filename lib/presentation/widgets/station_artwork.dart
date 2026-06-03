import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';

/// Station artwork loaded from the station favicon, with a graceful fallback.
///
/// Uses [CachedNetworkImage] (per the ADR-0018 allowlist) to fetch and cache
/// [RadioStation.favicon]. When the favicon is missing, blank, still loading,
/// or fails to load it shows a themed surface with a platform-adaptive station
/// icon instead, so a card/row/hero never renders empty (DESIGN.md §Cards/§3).
class StationArtwork extends StatelessWidget {
  /// Creates an instance of [StationArtwork].
  ///
  /// When [size] is null the artwork expands to fill its constraints (used for
  /// the favorites grid card and the full-player hero); otherwise it is a fixed
  /// square (used for list rows and the mini-player).
  const StationArtwork({
    required this.station,
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.iconSize,
    this.useCupertino = false,
    super.key,
  });

  /// The station whose [RadioStation.favicon] is rendered.
  final RadioStation station;

  /// The fixed square edge length, or null to fill the available space.
  final double? size;

  /// The rounded shape the artwork is clipped to.
  final BorderRadius borderRadius;

  /// Size of the fallback icon; defaults to the icon theme size.
  final double? iconSize;

  /// Whether to use the Cupertino fallback icon (iOS surfaces).
  final bool useCupertino;

  bool get _hasArt {
    final favicon = station.favicon;
    return favicon != null && favicon.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = _ArtworkFallback(
      useCupertino: useCupertino,
      iconSize: iconSize,
    );
    final Widget content = _hasArt
        ? CachedNetworkImage(
            imageUrl: station.favicon!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, _) => fallback,
            errorWidget: (context, _, _) => fallback,
          )
        : fallback;

    final clipped = ClipRRect(borderRadius: borderRadius, child: content);
    if (size == null) return clipped;
    return SizedBox(width: size, height: size, child: clipped);
  }
}

/// Themed placeholder shown when there is no loadable artwork.
class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({required this.useCupertino, this.iconSize});

  final bool useCupertino;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh),
      child: Center(
        child: Icon(
          useCupertino
              ? CupertinoIcons.antenna_radiowaves_left_right
              : Icons.radio,
          size: iconSize,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
