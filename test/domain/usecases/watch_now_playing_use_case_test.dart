import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';
import 'package:radio_app/domain/usecases/watch_now_playing_use_case.dart';

class _MockAudioPlayerRepository extends Mock
    implements AudioPlayerRepository {}

void main() {
  group('WatchNowPlayingUseCase', () {
    test('relays the repository nowPlayingStream', () {
      final repository = _MockAudioPlayerRepository();
      final controller = StreamController<NowPlayingInfo?>();
      addTearDown(controller.close);
      when(
        () => repository.nowPlayingStream,
      ).thenAnswer((_) => controller.stream);
      final useCase = WatchNowPlayingUseCase(repository);

      expectLater(
        useCase(const NoParams()),
        emitsInOrder(<Object?>[
          const NowPlayingInfo(raw: 'A - B', artist: 'A', track: 'B'),
          null,
        ]),
      );

      controller
        ..add(const NowPlayingInfo(raw: 'A - B', artist: 'A', track: 'B'))
        ..add(null);
    });
  });
}
