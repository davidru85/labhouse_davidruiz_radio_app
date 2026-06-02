import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:radio_app/core/constants/hive_boxes.dart';
import 'package:radio_app/core/di/composition_root.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/hive_registrar.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await bootstrapLocalStorage();

  await setupLocator();

  runApp(const MyApp());
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
class MyApp extends StatelessWidget {
  /// Creates a new [MyApp] instance.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'RadioApp',
      home: Scaffold(body: Center(child: Text('RadioApp Shell'))),
    );
  }
}
