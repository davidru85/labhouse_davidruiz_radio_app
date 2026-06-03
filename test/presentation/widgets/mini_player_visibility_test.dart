import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
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
  group('MiniPlayerWidget visibility animation (sub-task 9.6)', () {
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

    testWidgets('wraps its content in an AnimatedSize so visibility changes '
        'animate', (tester) async {
      seed(RadioPlayerPlaying(_station('Jazz FM'), null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedSize), findsOneWidget);
    });

    testWidgets('collapses to zero height when idle, keeping the animated '
        'wrapper mounted', (tester) async {
      seed(const RadioPlayerInitial());

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      // The animation wrapper stays in the tree...
      expect(find.byType(AnimatedSize), findsOneWidget);
      // ...but collapses so no player content occupies space.
      final size = tester.getSize(find.byType(MiniPlayerWidget));
      expect(size.height, 0);
    });
  });
}
