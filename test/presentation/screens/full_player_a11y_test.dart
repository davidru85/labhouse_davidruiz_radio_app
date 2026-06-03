import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';

import '../../support/shell_chrome_harness.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

void main() {
  group('FullPlayerScreen accessibility (sub-task 9.13, per ADR-0006)', () {
    late _FakeRadioPlayerBloc playerBloc;

    setUp(() => playerBloc = _FakeRadioPlayerBloc());

    Widget host({TextScaler textScaler = TextScaler.noScaling}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<RadioPlayerBloc>.value(
        value: playerBloc,
        child: Builder(
          builder: (context) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScaler.scale(1),
            maxScaleFactor: textScaler.scale(1),
            child: const FullPlayerScreen(),
          ),
        ),
      ),
    );

    void seed(RadioPlayerState state) => whenListen(
      playerBloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: state,
    );

    testWidgets('the transport control exposes a meaningful Semantics label', (
      tester,
    ) async {
      seed(RadioPlayerPlaying(buildStation('Jazz FM'), null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp('Pause')), findsOneWidget);
    });

    testWidgets('the collapse control exposes a meaningful Semantics label', (
      tester,
    ) async {
      seed(RadioPlayerPlaying(buildStation('Jazz FM'), null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp('Collapse')), findsOneWidget);
    });

    testWidgets('does not overflow at textScaler 2.0 with long metadata', (
      tester,
    ) async {
      seed(
        RadioPlayerPlaying(
          buildStation('A Very Long Radio Station Name For Overflow Testing'),
          const NowPlayingInfo(
            raw: 'A Very Long Artist Name - A Very Long Track Title Here',
            artist: 'A Very Long Artist Name',
            track: 'A Very Long Track Title Here',
          ),
        ),
      );

      await tester.pumpWidget(host(textScaler: const TextScaler.linear(2)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
