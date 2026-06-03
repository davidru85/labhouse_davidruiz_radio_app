import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

RadioStation _station(String name) => RadioStation(
  stationUuid: 'uuid-$name',
  name: name,
  streamUrl: 'https://example.com/$name',
  resolvedStreamUrl: 'https://example.com/$name/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: const [],
  country: 'Germany',
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
  group('MiniPlayerWidget (sub-task 9.5)', () {
    late _FakeRadioPlayerBloc bloc;

    setUp(() => bloc = _FakeRadioPlayerBloc());

    Widget host() => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<RadioPlayerBloc>.value(
          value: bloc,
          child: const MiniPlayerWidget(),
        ),
      ),
    );

    void seed(RadioPlayerState state) => whenListen(
      bloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: state,
    );

    testWidgets('shows the playing station name without a buffering '
        'indicator', (tester) async {
      final station = _station('Jazz FM');
      seed(RadioPlayerPlaying(station, null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.text('Jazz FM'), findsOneWidget);
      // Playing must be visually distinct from buffering: no spinner.
      expect(find.byType(AdaptiveProgressIndicator), findsNothing);
    });

    testWidgets('renders the buffering state distinctly from playing '
        '(per ADR-0015)', (tester) async {
      final station = _station('Jazz FM');
      seed(RadioPlayerBuffering(station));

      await tester.pumpWidget(host());
      await tester.pump();

      // Buffering still names the station but adds a progress indicator,
      // which playing does not show.
      expect(find.text('Jazz FM'), findsOneWidget);
      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    });

    testWidgets('renders nothing visible when the player is idle', (
      tester,
    ) async {
      seed(const RadioPlayerInitial());

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveProgressIndicator), findsNothing);
      expect(find.textContaining('FM'), findsNothing);
    });
  });
}
