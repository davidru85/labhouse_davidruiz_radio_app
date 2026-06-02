import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/use_case.dart';
import 'package:radio_app/domain/usecases/watch_player_state_use_case.dart';

class _MockAudioPlayerRepository extends Mock
    implements AudioPlayerRepository {}

void main() {
  group('WatchPlayerStateUseCase', () {
    test('relays the repository playerStateStream', () {
      final repository = _MockAudioPlayerRepository();
      final controller = StreamController<PlayerState>();
      addTearDown(controller.close);
      when(
        () => repository.playerStateStream,
      ).thenAnswer((_) => controller.stream);
      final useCase = WatchPlayerStateUseCase(repository);

      expectLater(
        useCase(const NoParams()),
        emitsInOrder(<Matcher>[
          isA<PlayerBufferingState>(),
          isA<PlayerPlayingState>(),
        ]),
      );

      controller
        ..add(const PlayerBufferingState())
        ..add(const PlayerPlayingState());
    });
  });
}
