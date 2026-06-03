import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

import '../../support/shell_chrome_harness.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

void main() {
  group('MiniPlayer now-playing metadata (sub-task 9.12, per ADR-0012)', () {
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

    testWidgets('shows "artist - track" when now-playing metadata is present', (
      tester,
    ) async {
      seed(
        RadioPlayerPlaying(
          buildStation('Jazz FM'),
          const NowPlayingInfo(
            raw: 'Daft Punk - Around the World',
            artist: 'Daft Punk',
            track: 'Around the World',
          ),
        ),
      );

      await tester.pumpWidget(host());
      // The Live Now dot pulses indefinitely, so settle finite animations
      // with an explicit pump rather than pumpAndSettle (which would time out).
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Daft Punk - Around the World'), findsOneWidget);
      // The station name is not the primary line while a track is known.
      expect(find.text('Jazz FM'), findsNothing);
    });

    testWidgets('falls back to the station name when metadata is absent', (
      tester,
    ) async {
      seed(RadioPlayerPlaying(buildStation('Jazz FM'), null));

      await tester.pumpWidget(host());
      // The Live Now dot pulses indefinitely, so settle finite animations
      // with an explicit pump rather than pumpAndSettle (which would time out).
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Jazz FM'), findsOneWidget);
    });
  });
}
