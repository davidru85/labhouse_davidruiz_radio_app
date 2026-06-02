import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/usecases/get_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/refresh_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/toggle_favorite_use_case.dart';
import 'package:radio_app/domain/usecases/track_analytics_event_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Events for [FavoritesBloc].
sealed class FavoritesEvent extends Equatable {
  /// Creates a favorites event.
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the persisted favorites.
final class FavoritesStarted extends FavoritesEvent {
  /// Creates a favorites-started event.
  const FavoritesStarted();
}

/// Toggles [station] as a favorite, then reloads.
final class FavoriteToggled extends FavoritesEvent {
  /// Creates a favorite-toggled event.
  const FavoriteToggled(this.station);

  /// The station to toggle.
  final RadioStation station;

  @override
  List<Object?> get props => [station];
}

/// Re-synchronizes favorites with the remote, then reloads.
final class FavoritesRefreshed extends FavoritesEvent {
  /// Creates a favorites-refreshed event.
  const FavoritesRefreshed();
}

/// States for [FavoritesBloc].
sealed class FavoritesState extends Equatable {
  /// Creates a favorites state.
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial, idle favorites state.
final class FavoritesInitial extends FavoritesState {
  /// Creates the initial favorites state.
  const FavoritesInitial();
}

/// Favorites are loading.
final class FavoritesLoadInProgress extends FavoritesState {
  /// Creates the loading favorites state.
  const FavoritesLoadInProgress();
}

/// Favorites loaded successfully.
final class FavoritesLoadSuccess extends FavoritesState {
  /// Creates a loaded favorites state with [stations].
  const FavoritesLoadSuccess(this.stations);

  /// The persisted favorite stations.
  final List<RadioStation> stations;

  @override
  List<Object?> get props => [stations];
}

/// Favorites failed to load or mutate.
final class FavoritesLoadFailure extends FavoritesState {
  /// Creates a failed favorites state with [failure].
  const FavoritesLoadFailure(this.failure);

  /// The originating failure.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Manages favorite stations via use cases (per ADR-0020 / API_SPEC.md §8).
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  /// Creates the favorites bloc over its use cases.
  FavoritesBloc(
    this._getFavorites,
    this._toggleFavorite,
    this._refresh,
    this._trackAnalytics,
  ) : super(const FavoritesInitial()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoriteToggled>(_onToggled);
    on<FavoritesRefreshed>(_onRefreshed);
  }

  final GetFavoritesUseCase _getFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;
  final RefreshFavoritesUseCase _refresh;
  final TrackAnalyticsEventUseCase _trackAnalytics;

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) {
    emit(const FavoritesLoadInProgress());
    return _emitFavorites(emit);
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoadInProgress());
    final result = await _toggleFavorite(
      ToggleFavoriteParams(station: event.station),
    );
    switch (result) {
      case FailureResult<bool, Failure>(:final failure):
        emit(FavoritesLoadFailure(failure));
      case Success<bool, Failure>(:final value):
        // Fire analytics only after persistence succeeds (per ADR-0019);
        // `value` is true when the station is now favorited, false when
        // it was removed.
        unawaited(
          _trackAnalytics(
            value
                ? StationFavoritedEvent(event.station.stationUuid)
                : StationUnfavoritedEvent(event.station.stationUuid),
          ),
        );
        await _emitFavorites(emit);
    }
  }

  Future<void> _onRefreshed(
    FavoritesRefreshed event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoadInProgress());
    final result = await _refresh(const NoParams());
    switch (result) {
      case FailureResult<void, Failure>(:final failure):
        emit(FavoritesLoadFailure(failure));
      case Success<void, Failure>():
        await _emitFavorites(emit);
    }
  }

  Future<void> _emitFavorites(Emitter<FavoritesState> emit) async {
    final result = await _getFavorites(const NoParams());
    switch (result) {
      case Success<List<RadioStation>, Failure>(:final value):
        emit(FavoritesLoadSuccess(value));
      case FailureResult<List<RadioStation>, Failure>(:final failure):
        emit(FavoritesLoadFailure(failure));
    }
  }
}
