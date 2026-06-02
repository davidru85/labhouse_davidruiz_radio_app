import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/usecases/add_to_history_use_case.dart';
import 'package:radio_app/domain/usecases/clear_history_use_case.dart';
import 'package:radio_app/domain/usecases/get_history_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Events for [HistoryBloc].
sealed class HistoryEvent extends Equatable {
  /// Creates a history event.
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the recently played history.
final class HistoryStarted extends HistoryEvent {
  /// Creates a history-started event.
  const HistoryStarted();
}

/// Adds [station] to history, then reloads.
final class HistoryStationAdded extends HistoryEvent {
  /// Creates a history-station-added event.
  const HistoryStationAdded(this.station);

  /// The station to record.
  final RadioStation station;

  @override
  List<Object?> get props => [station];
}

/// Clears the recently played history.
final class HistoryCleared extends HistoryEvent {
  /// Creates a history-cleared event.
  const HistoryCleared();
}

/// States for [HistoryBloc].
sealed class HistoryState extends Equatable {
  /// Creates a history state.
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial, idle history state.
final class HistoryInitial extends HistoryState {
  /// Creates the initial history state.
  const HistoryInitial();
}

/// History is loading.
final class HistoryLoadInProgress extends HistoryState {
  /// Creates the loading history state.
  const HistoryLoadInProgress();
}

/// History loaded successfully.
final class HistoryLoadSuccess extends HistoryState {
  /// Creates a loaded history state with [stations].
  const HistoryLoadSuccess(this.stations);

  /// The recently played stations.
  final List<RadioStation> stations;

  @override
  List<Object?> get props => [stations];
}

/// History failed to load or mutate.
final class HistoryLoadFailure extends HistoryState {
  /// Creates a failed history state with [failure].
  const HistoryLoadFailure(this.failure);

  /// The originating failure.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Manages recently played history via Hive-backed use cases (per ADR-0021).
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  /// Creates the history bloc over its use cases.
  HistoryBloc(this._getHistory, this._addToHistory, this._clearHistory)
    : super(const HistoryInitial()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryStationAdded>(_onStationAdded);
    on<HistoryCleared>(_onCleared);
  }

  final GetHistoryUseCase _getHistory;
  final AddToHistoryUseCase _addToHistory;
  final ClearHistoryUseCase _clearHistory;

  Future<void> _onStarted(HistoryStarted event, Emitter<HistoryState> emit) {
    emit(const HistoryLoadInProgress());
    return _emitHistory(emit);
  }

  Future<void> _onStationAdded(
    HistoryStationAdded event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoadInProgress());
    final result = await _addToHistory(
      AddToHistoryParams(station: event.station),
    );
    switch (result) {
      case FailureResult<void, Failure>(:final failure):
        emit(HistoryLoadFailure(failure));
      case Success<void, Failure>():
        await _emitHistory(emit);
    }
  }

  Future<void> _onCleared(
    HistoryCleared event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoadInProgress());
    final result = await _clearHistory(const NoParams());
    switch (result) {
      case FailureResult<void, Failure>(:final failure):
        emit(HistoryLoadFailure(failure));
      case Success<void, Failure>():
        await _emitHistory(emit);
    }
  }

  Future<void> _emitHistory(Emitter<HistoryState> emit) async {
    final result = await _getHistory(const NoParams());
    switch (result) {
      case Success<List<RadioStation>, Failure>(:final value):
        emit(HistoryLoadSuccess(value));
      case FailureResult<List<RadioStation>, Failure>(:final failure):
        emit(HistoryLoadFailure(failure));
    }
  }
}
