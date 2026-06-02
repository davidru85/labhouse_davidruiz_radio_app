import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/usecases/cancel_search_use_case.dart';
import 'package:radio_app/domain/usecases/load_popular_stations_use_case.dart';
import 'package:radio_app/domain/usecases/search_stations_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';
import 'package:stream_transform/stream_transform.dart';

/// Events for [StationsBloc].
sealed class StationsEvent extends Equatable {
  /// Creates a stations event.
  const StationsEvent();

  @override
  List<Object?> get props => [];
}

/// The search query changed (debounced; min 3 chars; empty -> popular).
final class StationsSearchChanged extends StationsEvent {
  /// Creates a search-changed event.
  const StationsSearchChanged(this.query);

  /// The raw query text.
  final String query;

  @override
  List<Object?> get props => [query];
}

/// The country filter changed.
final class StationsCountryFilterChanged extends StationsEvent {
  /// Creates a country-filter-changed event.
  const StationsCountryFilterChanged(this.countryCode);

  /// The selected ISO country code, or `null` to clear.
  final String? countryCode;

  @override
  List<Object?> get props => [countryCode];
}

/// The tag filter changed.
final class StationsTagFilterChanged extends StationsEvent {
  /// Creates a tag-filter-changed event.
  const StationsTagFilterChanged(this.tag);

  /// The selected tag, or `null` to clear.
  final String? tag;

  @override
  List<Object?> get props => [tag];
}

/// Requests the next page of results.
final class StationsLoadMoreRequested extends StationsEvent {
  /// Creates a load-more-requested event.
  const StationsLoadMoreRequested();
}

/// Lifecycle status of [StationsState].
enum StationsStatus {
  /// No query has run yet.
  initial,

  /// A query is in flight.
  loading,

  /// Results are available.
  success,

  /// The last query failed.
  failure,
}

/// State for [StationsBloc].
final class StationsState extends Equatable {
  /// Creates a stations state.
  const StationsState({
    this.status = StationsStatus.initial,
    this.stations = const [],
    this.hasReachedMax = false,
    this.query = '',
    this.countryCode,
    this.tag,
    this.failure,
  });

  /// Current lifecycle status.
  final StationsStatus status;

  /// Loaded stations, deduplicated by `stationUuid`.
  final List<RadioStation> stations;

  /// Whether pagination has reached the end (per ADR-0031).
  final bool hasReachedMax;

  /// Active query text.
  final String query;

  /// Active country filter.
  final String? countryCode;

  /// Active tag filter.
  final String? tag;

  /// The failure for [StationsStatus.failure].
  final Failure? failure;

  @override
  List<Object?> get props => [
    status,
    stations,
    hasReachedMax,
    query,
    countryCode,
    tag,
    failure,
  ];
}

/// Manages station search, filtering and pagination
/// (per ADR-0014 / ADR-0031).
class StationsBloc extends Bloc<StationsEvent, StationsState> {
  /// Creates the stations bloc over its use cases. [maxStations] caps the
  /// cumulative result count (`STATIONS_MAX_LIMIT`, per ADR-0031) and is
  /// supplied from `config/app.json` by the composition root.
  StationsBloc(
    this._search,
    this._loadPopular,
    this._cancelSearch, {
    this.maxStations = defaultMaxStations,
  }) : super(const StationsState()) {
    on<StationsSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(_debounceDuration).switchMap(mapper),
    );
    on<StationsCountryFilterChanged>(_onCountryFilterChanged);
    on<StationsTagFilterChanged>(_onTagFilterChanged);
    on<StationsLoadMoreRequested>(_onLoadMoreRequested);
  }

  /// Maximum stations requested per page (`DEFAULT_STATIONS_PAGE_LIMIT`).
  static const int pageSize = 30;

  /// Default cumulative cap (`STATIONS_MAX_LIMIT` in `config/app.json`).
  static const int defaultMaxStations = 100;

  /// Minimum query length before a remote search fires (per ADR-0014).
  static const int minQueryLength = 3;

  static const Duration _debounceDuration = Duration(milliseconds: 350);

  /// Cumulative result cap before pagination stops (per ADR-0031).
  final int maxStations;

  final SearchStationsUseCase _search;
  final LoadPopularStationsUseCase _loadPopular;
  final CancelSearchUseCase _cancelSearch;

  Future<void> _onSearchChanged(
    StationsSearchChanged event,
    Emitter<StationsState> emit,
  ) async {
    // Validate the trimmed input: whitespace-only collapses to popular and
    // trailing whitespace is not propagated to the remote query (per ADR-0014).
    final query = event.query.trim();
    if (query.isNotEmpty && query.length < minQueryLength) {
      return;
    }
    await _cancelSearch(const NoParams());
    await _runQuery(emit, query: query, countryCode: null, tag: null);
  }

  Future<void> _onCountryFilterChanged(
    StationsCountryFilterChanged event,
    Emitter<StationsState> emit,
  ) async {
    await _cancelSearch(const NoParams());
    await _runQuery(
      emit,
      query: state.query,
      countryCode: event.countryCode,
      tag: state.tag,
    );
  }

  Future<void> _onTagFilterChanged(
    StationsTagFilterChanged event,
    Emitter<StationsState> emit,
  ) async {
    await _cancelSearch(const NoParams());
    await _runQuery(
      emit,
      query: state.query,
      countryCode: state.countryCode,
      tag: event.tag,
    );
  }

  Future<void> _onLoadMoreRequested(
    StationsLoadMoreRequested event,
    Emitter<StationsState> emit,
  ) async {
    if (state.status != StationsStatus.success || state.hasReachedMax) {
      return;
    }
    final result = await _fetch(
      query: state.query,
      countryCode: state.countryCode,
      tag: state.tag,
      offset: state.stations.length,
    );
    switch (result) {
      case Success<List<RadioStation>, Failure>(:final value):
        emit(
          _successState(
            _dedup([...state.stations, ...value]),
            value.length,
            query: state.query,
            countryCode: state.countryCode,
            tag: state.tag,
          ),
        );
      case FailureResult<List<RadioStation>, Failure>(:final failure):
        emit(
          StationsState(
            status: StationsStatus.failure,
            stations: state.stations,
            hasReachedMax: state.hasReachedMax,
            query: state.query,
            countryCode: state.countryCode,
            tag: state.tag,
            failure: failure,
          ),
        );
    }
  }

  Future<void> _runQuery(
    Emitter<StationsState> emit, {
    required String query,
    required String? countryCode,
    required String? tag,
  }) async {
    emit(
      StationsState(
        status: StationsStatus.loading,
        query: query,
        countryCode: countryCode,
        tag: tag,
      ),
    );
    final result = await _fetch(
      query: query,
      countryCode: countryCode,
      tag: tag,
      offset: 0,
    );
    switch (result) {
      case Success<List<RadioStation>, Failure>(:final value):
        emit(
          _successState(
            _dedup(value),
            value.length,
            query: query,
            countryCode: countryCode,
            tag: tag,
          ),
        );
      case FailureResult<List<RadioStation>, Failure>(:final failure):
        emit(
          StationsState(
            status: StationsStatus.failure,
            query: query,
            countryCode: countryCode,
            tag: tag,
            failure: failure,
          ),
        );
    }
  }

  /// Builds a success state, truncating to [maxStations] and flagging
  /// `hasReachedMax` when the page was short or the cap was reached
  /// (per ADR-0031). [rawPageLength] is the size of the just-fetched page.
  StationsState _successState(
    List<RadioStation> stations,
    int rawPageLength, {
    required String query,
    required String? countryCode,
    required String? tag,
  }) {
    final capped = stations.length > maxStations
        ? stations.sublist(0, maxStations)
        : stations;
    return StationsState(
      status: StationsStatus.success,
      stations: capped,
      hasReachedMax: rawPageLength < pageSize || capped.length >= maxStations,
      query: query,
      countryCode: countryCode,
      tag: tag,
    );
  }

  Future<Result<List<RadioStation>, Failure>> _fetch({
    required String query,
    required String? countryCode,
    required String? tag,
    required int offset,
  }) {
    final isPopular = query.isEmpty && countryCode == null && tag == null;
    // `limit` is left at the params' default page size, which equals
    // [pageSize] (the value used for the hasReachedMax boundary below).
    if (isPopular) {
      return _loadPopular(LoadPopularStationsParams(offset: offset));
    }
    return _search(
      SearchStationsParams(
        query: query.isEmpty ? null : query,
        countryCode: countryCode,
        tag: tag,
        offset: offset,
      ),
    );
  }

  List<RadioStation> _dedup(List<RadioStation> stations) {
    final seen = <String>{};
    final result = <RadioStation>[];
    for (final station in stations) {
      if (seen.add(station.stationUuid)) {
        result.add(station);
      }
    }
    return result;
  }

  @override
  Future<void> close() async {
    // Explicit cancellation of in-flight search on disposal (per ADR-0014).
    // Cancellation is best-effort: its Result is intentionally ignored so a
    // cancel failure never blocks teardown.
    await _cancelSearch(const NoParams());
    return super.close();
  }
}
