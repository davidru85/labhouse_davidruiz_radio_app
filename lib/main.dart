import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:radio_app/core/constants/hive_boxes.dart';
import 'package:radio_app/core/di/composition_root.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/hive_registrar.g.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPortraitOrientation();
  await Hive.initFlutter();
  await bootstrapLocalStorage();

  await setupLocator();

  runApp(MyApp());
}

/// Reinforces the portrait-only lock from Dart before the app builds.
///
/// The native manifests remain the source of truth (per ADR-0004); this only
/// asks the engine to keep the preferred orientation upright so any transient
/// rotation during startup is suppressed.
Future<void> lockPortraitOrientation() {
  return SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
}

/// Registers the Hive adapters and opens every box the app persists into,
/// before the composition root is built.
///
/// Box typing and type IDs follow the persistence model design (per ADR-0037),
/// adapters are registered via the Hive CE generated registrar (per ADR-0038),
/// and the `app_settings` box backs the mirror cache (per ADR-0016).
///
/// Adapter registration is guarded so repeated calls are safe.
Future<void> bootstrapLocalStorage() async {
  // `StationHiveModel` holds type ID 0 in the ADR-0037 registry, so this single
  // probe tells us whether the generated adapters are already registered.
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapters();
  }
  await Hive.openBox<StationHiveModel>(HiveBoxes.favorites);
  await Hive.openBox<StationHiveModel>(HiveBoxes.history);
  await Hive.openBox<GenreHiveModel>(HiveBoxes.genres);
  await Hive.openBox<CountryHiveModel>(HiveBoxes.countries);
  await Hive.openBox<dynamic>(HiveBoxes.appSettings);
}

/// The main application entry point widget.
///
/// Hosts the root [RadioPlayerBloc] above the router so both the shell
/// (mini-player) and the out-of-shell `/player` route share one player bloc,
/// and drives navigation through [MaterialApp.router] over [createAppRouter].
class MyApp extends StatelessWidget {
  /// Creates a new [MyApp] instance.
  ///
  /// [router] and [createPlayerBloc] are injectable seams that default to the
  /// composition root's wiring; tests override them to avoid touching the
  /// global locator.
  MyApp({
    super.key,
    GoRouter? router,
    RadioPlayerBloc Function()? createPlayerBloc,
  }) : _createPlayerBloc = createPlayerBloc ?? resolveRootPlayerBloc,
       router = router ?? createAppRouter(shellScopeBuilder: buildShellScope);

  /// The router configuration driving navigation.
  final GoRouter router;

  /// Factory for the root [RadioPlayerBloc] provided above the router.
  final RadioPlayerBloc Function() _createPlayerBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RadioPlayerBloc>(
      create: (_) => _createPlayerBloc(),
      child: MaterialApp.router(
        title: 'RadioApp',
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
        // Cupertino widgets (rendered on iOS via PlatformBuilder) read their
        // styling from the ambient CupertinoTheme, so the dark brand theme is
        // mirrored here to keep the iOS surfaces on-brand (ADR-0042).
        builder: (context, child) => CupertinoTheme(
          data: AppTheme.cupertinoDark(),
          child: child ?? const SizedBox.shrink(),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
