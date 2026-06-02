import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/usecases/load_genres_use_case.dart';

/// Events for [GenresBloc].
sealed class GenresEvent extends Equatable {
  /// Creates a genres event.
  const GenresEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the station genres for filter metadata.
final class GenresStarted extends GenresEvent {
  /// Creates a genres-started event.
  const GenresStarted();
}

/// States for [GenresBloc].
sealed class GenresState extends Equatable {
  /// Creates a genres state.
  const GenresState();

  @override
  List<Object?> get props => [];
}

/// Initial, idle genres state.
final class GenresInitial extends GenresState {
  /// Creates the initial genres state.
  const GenresInitial();
}

/// Genres are loading.
final class GenresLoadInProgress extends GenresState {
  /// Creates the loading genres state.
  const GenresLoadInProgress();
}

/// Genres loaded successfully.
final class GenresLoadSuccess extends GenresState {
  /// Creates a loaded genres state with [genres].
  const GenresLoadSuccess(this.genres);

  /// The loaded genres.
  final List<Genre> genres;

  @override
  List<Object?> get props => [genres];
}

/// Genres failed to load.
final class GenresLoadFailure extends GenresState {
  /// Creates a failed genres state with [failure].
  const GenresLoadFailure(this.failure);

  /// The originating failure.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads station genres for filter metadata via [LoadGenresUseCase].
class GenresBloc extends Bloc<GenresEvent, GenresState> {
  /// Creates the genres bloc over its use case.
  GenresBloc(this._loadGenres) : super(const GenresInitial()) {
    on<GenresStarted>(_onStarted);
  }

  final LoadGenresUseCase _loadGenres;

  Future<void> _onStarted(
    GenresStarted event,
    Emitter<GenresState> emit,
  ) async {
    emit(const GenresLoadInProgress());
    final result = await _loadGenres(const LoadGenresParams());
    switch (result) {
      case Success<List<Genre>, Failure>(:final value):
        emit(GenresLoadSuccess(value));
      case FailureResult<List<Genre>, Failure>(:final failure):
        emit(GenresLoadFailure(failure));
    }
  }
}
