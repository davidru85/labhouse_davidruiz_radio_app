import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';

/// Global connectivity banner driven by [ConnectivityBloc] (per ADR-0013).
///
/// Shows a persistent "You're offline" message while the device is offline.
/// When connectivity is restored it shows a transient "Back online"
/// confirmation for two seconds and then disappears. While steadily online
/// (including the initial unknown state) it renders nothing and occupies no
/// space.
class OfflineBanner extends StatefulWidget {
  /// Creates an instance of [OfflineBanner].
  const OfflineBanner({super.key});

  /// How long the "Back online" confirmation stays visible after reconnection.
  static const Duration backOnlineDuration = Duration(seconds: 2);

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _showBackOnline = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onReconnected() {
    _timer?.cancel();
    setState(() => _showBackOnline = true);
    _timer = Timer(OfflineBanner.backOnlineDuration, () {
      if (mounted) setState(() => _showBackOnline = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) =>
          previous is ConnectivityOffline && current is ConnectivityOnline,
      listener: (context, state) => _onReconnected(),
      builder: (context, state) {
        if (state is ConnectivityOffline) {
          return _Banner(
            message: l10n.offlineBanner,
            background: theme.colorScheme.errorContainer,
            foreground: theme.colorScheme.onErrorContainer,
          );
        }
        if (_showBackOnline) {
          return _Banner(
            message: l10n.backOnlineBanner,
            background: theme.colorScheme.primaryContainer,
            foreground: theme.colorScheme.onPrimaryContainer,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// A full-width connectivity message strip.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.background,
    required this.foreground,
  });

  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
