import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';

class _MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

/// Fixture whose raw [RadioStation.country] differs from the localized name
/// resolved from [RadioStation.countryCode], so the subtitle assertion proves
/// the screen resolves country names via the ARB `country_XX` keys (ADR-0032).
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
  late _MockFavoritesBloc bloc;

  setUp(() => bloc = _MockFavoritesBloc());

  void stub(FavoritesState state) {
    when(() => bloc.state).thenReturn(state);
  }

  Widget harness({
    required TargetPlatform platform,
    VoidCallback? onExplore,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return MaterialApp(
      theme: ThemeData(platform: platform),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: BlocProvider<FavoritesBloc>.value(
          value: bloc,
          child: FavoritesScreen(onExplore: onExplore),
        ),
      ),
    );
  }

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(FavoritesScreen)));

  // Scope: DESIGN.md shows a "Search your favorites" field, but FavoritesBloc
  // exposes no filter event, so local favorites search is deferred to a later
  // sub-task and is intentionally not asserted in this slice.
  group('FavoritesScreen', () {
    testWidgets('shows the localized title', (tester) async {
      stub(const FavoritesLoadSuccess([]));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).favoritesTitle), findsOneWidget);
    });

    testWidgets('renders a Material progress indicator while loading on '
        'Android', (tester) async {
      stub(const FavoritesLoadInProgress());
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('renders a Cupertino activity indicator while loading on iOS', (
      tester,
    ) async {
      stub(const FavoritesLoadInProgress());
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders a grid card per favorite with name and resolved '
        'tag/country subtitle', (tester) async {
      stub(FavoritesLoadSuccess([_station('a'), _station('b')]));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Station a'), findsOneWidget);
      expect(find.text('Station b'), findsOneWidget);
      // 'Germany' is the ARB country_DE value (raw country is 'Deutschland').
      expect(find.text('Jazz • Germany'), findsNWidgets(2));
    });

    testWidgets('shows the localized empty state with an explore action', (
      tester,
    ) async {
      stub(const FavoritesLoadSuccess([]));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).favoritesEmptyTitle), findsOneWidget);
      expect(find.text(l10nOf(tester).favoritesEmptyMessage), findsOneWidget);
      expect(find.text(l10nOf(tester).favoritesExplore), findsOneWidget);
    });

    testWidgets('invokes onExplore when the explore action is tapped', (
      tester,
    ) async {
      var explored = false;
      stub(const FavoritesLoadSuccess([]));
      await tester.pumpWidget(
        harness(
          platform: TargetPlatform.android,
          onExplore: () => explored = true,
        ),
      );

      await tester.tap(find.text(l10nOf(tester).favoritesExplore));
      await tester.pump();

      expect(explored, isTrue);
    });

    testWidgets('shows the localized error message on failure', (tester) async {
      stub(const FavoritesLoadFailure(StorageReadWriteFailure()));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      expect(find.text(l10nOf(tester).genericError), findsOneWidget);
    });

    testWidgets('dispatches FavoriteToggled when the heart is tapped', (
      tester,
    ) async {
      final station = _station('a');
      stub(FavoritesLoadSuccess([station]));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      verify(() => bloc.add(FavoriteToggled(station))).called(1);
    });

    testWidgets('renders a Cupertino favorite icon on iOS (not Material)', (
      tester,
    ) async {
      stub(FavoritesLoadSuccess([_station('a'), _station('b')]));
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      expect(find.byIcon(CupertinoIcons.heart_fill), findsNWidgets(2));
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('favorite toggle exposes a tooltip and semantic label '
        '(per TECHNICAL_SPEC.md §10)', (tester) async {
      final handle = tester.ensureSemantics();
      stub(FavoritesLoadSuccess([_station('a')]));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      final label = l10nOf(tester).favoritesRemoveLabel;
      expect(find.byTooltip(label), findsOneWidget);
      expect(find.bySemanticsLabel(label), findsOneWidget);
      handle.dispose();
    });

    testWidgets('favorite toggle meets the minimum 48dp touch target on '
        'Android (per TECHNICAL_SPEC.md §10)', (tester) async {
      stub(FavoritesLoadSuccess([_station('a')]));
      await tester.pumpWidget(harness(platform: TargetPlatform.android));

      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('Cupertino favorite toggle exposes a tooltip and semantic '
        'label on iOS (per TECHNICAL_SPEC.md §10)', (tester) async {
      final handle = tester.ensureSemantics();
      stub(FavoritesLoadSuccess([_station('a')]));
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      final label = l10nOf(tester).favoritesRemoveLabel;
      expect(find.byTooltip(label), findsOneWidget);
      expect(find.bySemanticsLabel(label), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Cupertino favorite toggle meets the minimum 44pt touch target '
        'on iOS (per TECHNICAL_SPEC.md §10)', (tester) async {
      stub(FavoritesLoadSuccess([_station('a')]));
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      final size = tester.getSize(find.byType(CupertinoButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('uses a CupertinoPageScaffold on iOS', (tester) async {
      stub(const FavoritesLoadSuccess([]));
      await tester.pumpWidget(harness(platform: TargetPlatform.iOS));

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    });

    testWidgets('renders without overflow at textScaler 2.0 '
        '(per TECHNICAL_SPEC.md §10)', (tester) async {
      stub(FavoritesLoadSuccess([_station('a'), _station('b')]));
      await tester.pumpWidget(
        harness(
          platform: TargetPlatform.android,
          textScaler: const TextScaler.linear(2),
        ),
      );

      // Assert the real grid content is present at 2.0 scale, not just that
      // nothing threw, so the check exercises the loaded layout (per B2).
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Station a'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
