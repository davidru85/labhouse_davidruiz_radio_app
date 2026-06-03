import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';

class _MockStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

/// Fixture whose raw [RadioStation.country] deliberately differs from the
/// localized name resolved from [RadioStation.countryCode], so the subtitle
/// assertion proves the screen resolves country names via the ARB
/// `country_XX` keys (per ADR-0032) rather than echoing the raw API field.
RadioStation _station(String uuid, {List<String> tags = const ['Jazz']}) =>
    RadioStation(
      stationUuid: uuid,
      name: 'Station $uuid',
      streamUrl: 'https://example.com/$uuid',
      resolvedStreamUrl: 'https://example.com/$uuid/resolved',
      favicon: null,
      homepage: null,
      tags: tags.join(','),
      tagList: tags,
      country: 'Deutschland',
      countryCode: 'DE',
      language: null,
      codec: null,
      bitrate: null,
      votes: 0,
      clickCount: 0,
      lastCheckOk: true,
      isHLS: false,
    );

void main() {
  late _MockStationsBloc bloc;

  setUp(() => bloc = _MockStationsBloc());

  void stub(StationsState state) {
    when(() => bloc.state).thenReturn(state);
  }

  Widget harness({
    required TargetPlatform platform,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return MaterialApp(
      theme: ThemeData(platform: platform),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: BlocProvider<StationsBloc>.value(
          value: bloc,
          child: const StationsScreen(),
        ),
      ),
    );
  }

  /// Resolves the active localizations from the pumped [StationsScreen] so
  /// assertions check the localized value rather than raw English literals.
  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(StationsScreen)));

  group('StationsScreen', () {
    testWidgets('shows the localized app wordmark', (tester) async {
      stub(const StationsState());
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).appTitle), findsOneWidget);
    });

    testWidgets('renders a Material progress indicator while loading on '
        'Android', (tester) async {
      stub(const StationsState(status: StationsStatus.loading));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('renders a Cupertino activity indicator while loading on iOS', (
      tester,
    ) async {
      stub(const StationsState(status: StationsStatus.loading));
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders a row per station with name and resolved tag/country '
        'subtitle', (tester) async {
      stub(
        StationsState(
          status: StationsStatus.success,
          stations: [_station('a'), _station('b')],
        ),
      );
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text('Station a'), findsOneWidget);
      expect(find.text('Station b'), findsOneWidget);
      // 'Germany' is the ARB country_DE value (raw country is 'Deutschland').
      expect(find.text('Jazz • Germany'), findsNWidgets(2));
    });

    testWidgets('renders native Cupertino list tiles on iOS', (tester) async {
      stub(
        StationsState(
          status: StationsStatus.success,
          stations: [_station('a'), _station('b')],
        ),
      );
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Station a'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the localized search hint', (tester) async {
      stub(const StationsState());
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).stationsSearchHint), findsOneWidget);
    });

    testWidgets('shows the localized empty message when a query returns no '
        'results', (tester) async {
      stub(const StationsState(status: StationsStatus.success, query: 'nope'));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).stationsEmptyResults), findsOneWidget);
    });

    testWidgets('does not show the empty message for an empty query '
        '(per ADR-0029)', (tester) async {
      stub(const StationsState());
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).stationsEmptyResults), findsNothing);
    });

    testWidgets('shows the localized error message on failure', (tester) async {
      stub(const StationsState(status: StationsStatus.failure));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).genericError), findsOneWidget);
    });

    testWidgets('dispatches StationsSearchChanged as the query changes', (
      tester,
    ) async {
      stub(const StationsState());
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      await tester.enterText(find.byType(TextField), 'jazz');

      verify(() => bloc.add(const StationsSearchChanged('jazz'))).called(1);
    });

    testWidgets('renders without overflow at textScaler 2.0 '
        '(per TECHNICAL_SPEC.md §10)', (tester) async {
      stub(
        StationsState(
          status: StationsStatus.success,
          stations: [_station('a')],
        ),
      );
      await tester.pumpWidget(
        harness(
          platform: TargetPlatform.android,
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
