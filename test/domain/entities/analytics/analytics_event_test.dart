import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/analytics/analytics_event.dart';

void main() {
  group('AnalyticsEvent', () {
    test('defines the initial sealed event catalogue from ADR-0019', () {
      final events = _analyticsEventCatalogue();

      expect(events, hasLength(9));
      expect(events, everyElement(isA<AnalyticsEvent>()));
    });

    test('uses value equality for events with matching payloads', () {
      expect(const AppOpenedEvent(), equals(const AppOpenedEvent()));
      expect(
        const ScreenViewedEvent('player'),
        equals(const ScreenViewedEvent('player')),
      );
      expect(
        const StationPlayedEvent(
          stationUuid: 'station-uuid',
          stationName: 'Radio Example',
          countryCode: 'AT',
        ),
        equals(
          const StationPlayedEvent(
            stationUuid: 'station-uuid',
            stationName: 'Radio Example',
            countryCode: 'AT',
          ),
        ),
      );
      expect(
        const StationStoppedEvent(
          stationUuid: 'station-uuid',
          durationSeconds: 90,
        ),
        equals(
          const StationStoppedEvent(
            stationUuid: 'station-uuid',
            durationSeconds: 90,
          ),
        ),
      );
      expect(
        const StationFavoritedEvent('station-uuid'),
        equals(const StationFavoritedEvent('station-uuid')),
      );
      expect(
        const StationUnfavoritedEvent('station-uuid'),
        equals(const StationUnfavoritedEvent('station-uuid')),
      );
      expect(
        const SearchPerformedEvent(queryLength: 7, resultCount: 3),
        equals(const SearchPerformedEvent(queryLength: 7, resultCount: 3)),
      );
      expect(
        const FilterAppliedEvent(filterType: 'genre', value: 'jazz'),
        equals(const FilterAppliedEvent(filterType: 'genre', value: 'jazz')),
      );
      expect(
        const PlaybackErrorEvent(
          stationUuid: 'station-uuid',
          failureType: 'CodecUnsupportedFailure',
        ),
        equals(
          const PlaybackErrorEvent(
            stationUuid: 'station-uuid',
            failureType: 'CodecUnsupportedFailure',
          ),
        ),
      );
    });

    test('keeps event payload fields strongly typed and readable', () {
      const screenViewed = ScreenViewedEvent('player');
      const stationPlayed = StationPlayedEvent(
        stationUuid: 'station-uuid',
        stationName: 'Radio Example',
        countryCode: 'NL',
      );
      const stationStopped = StationStoppedEvent(
        stationUuid: 'station-uuid',
        durationSeconds: 42,
      );
      const stationFavorited = StationFavoritedEvent('station-uuid');
      const stationUnfavorited = StationUnfavoritedEvent('station-uuid');
      const searchPerformed = SearchPerformedEvent(
        queryLength: 9,
        resultCount: 24,
      );
      const filterApplied = FilterAppliedEvent(
        filterType: 'country',
        value: 'FR',
      );
      const playbackError = PlaybackErrorEvent(
        stationUuid: 'station-uuid',
        failureType: 'MirrorFailure',
      );

      expect(screenViewed.screenName, 'player');
      expect(stationPlayed.stationUuid, 'station-uuid');
      expect(stationPlayed.stationName, 'Radio Example');
      expect(stationPlayed.countryCode, 'NL');
      expect(stationStopped.stationUuid, 'station-uuid');
      expect(stationStopped.durationSeconds, 42);
      expect(stationFavorited.stationUuid, 'station-uuid');
      expect(stationUnfavorited.stationUuid, 'station-uuid');
      expect(searchPerformed.queryLength, 9);
      expect(searchPerformed.resultCount, 24);
      expect(filterApplied.filterType, 'country');
      expect(filterApplied.value, 'FR');
      expect(playbackError.stationUuid, 'station-uuid');
      expect(playbackError.failureType, 'MirrorFailure');
    });

    test('stores search query length instead of the literal query', () {
      const event = SearchPerformedEvent(queryLength: 11, resultCount: 2);

      expect(event.queryLength, 11);
      // The equality surface MUST be exactly the length and result count;
      // pinning props structurally prevents a raw query field from ever
      // being added to the payload (ADR-0019 §"Privacy").
      expect(event.props, equals(<Object?>[11, 2]));
    });
  });
}

List<AnalyticsEvent> _analyticsEventCatalogue() {
  return const [
    AppOpenedEvent(),
    ScreenViewedEvent('stations'),
    StationPlayedEvent(
      stationUuid: 'station-uuid',
      stationName: 'Radio Example',
      countryCode: 'DE',
    ),
    StationStoppedEvent(stationUuid: 'station-uuid', durationSeconds: 42),
    StationFavoritedEvent('station-uuid'),
    StationUnfavoritedEvent('station-uuid'),
    SearchPerformedEvent(queryLength: 5, resultCount: 12),
    FilterAppliedEvent(filterType: 'country', value: 'DE'),
    PlaybackErrorEvent(
      stationUuid: 'station-uuid',
      failureType: 'StreamUnreachableFailure',
    ),
  ];
}
