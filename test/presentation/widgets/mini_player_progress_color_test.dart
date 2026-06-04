import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

RadioStation _station() => const RadioStation(
  stationUuid: 'uuid',
  name: 'Jazz FM',
  streamUrl: 'https://example.com/s',
  resolvedStreamUrl: 'https://example.com/s/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: [],
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

/// Slice 4 (B2) — the Favorites progress bar uses the `primary` color
/// (DESIGN.md §Mini-Player).
void main() {
  testWidgets('the mini-player progress bar is primary-colored', (
    tester,
  ) async {
    final bloc = _FakeRadioPlayerBloc();
    whenListen(
      bloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: RadioPlayerPlaying(_station(), null),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<RadioPlayerBloc>.value(
            value: bloc,
            child: const MiniPlayerWidget(showProgress: true),
          ),
        ),
      ),
    );
    await tester.pump();

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.color, AppColors.primary);
  });
}
