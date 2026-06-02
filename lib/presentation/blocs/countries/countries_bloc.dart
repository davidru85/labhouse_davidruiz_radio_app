import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/usecases/load_countries_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Events for [CountriesBloc].
sealed class CountriesEvent extends Equatable {
  /// Creates a countries event.
  const CountriesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the station countries for filter metadata.
final class CountriesStarted extends CountriesEvent {
  /// Creates a countries-started event.
  const CountriesStarted();
}

/// States for [CountriesBloc].
sealed class CountriesState extends Equatable {
  /// Creates a countries state.
  const CountriesState();

  @override
  List<Object?> get props => [];
}

/// Initial, idle countries state.
final class CountriesInitial extends CountriesState {
  /// Creates the initial countries state.
  const CountriesInitial();
}

/// Countries are loading.
final class CountriesLoadInProgress extends CountriesState {
  /// Creates the loading countries state.
  const CountriesLoadInProgress();
}

/// Countries loaded successfully.
final class CountriesLoadSuccess extends CountriesState {
  /// Creates a loaded countries state with [countries].
  const CountriesLoadSuccess(this.countries);

  /// The loaded countries.
  final List<Country> countries;

  @override
  List<Object?> get props => [countries];
}

/// Countries failed to load.
final class CountriesLoadFailure extends CountriesState {
  /// Creates a failed countries state with [failure].
  const CountriesLoadFailure(this.failure);

  /// The originating failure.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads station countries for filter metadata via [LoadCountriesUseCase].
class CountriesBloc extends Bloc<CountriesEvent, CountriesState> {
  /// Creates the countries bloc over its use case.
  CountriesBloc(this._loadCountries) : super(const CountriesInitial()) {
    on<CountriesStarted>(_onStarted);
  }

  final LoadCountriesUseCase _loadCountries;

  Future<void> _onStarted(
    CountriesStarted event,
    Emitter<CountriesState> emit,
  ) async {
    emit(const CountriesLoadInProgress());
    final result = await _loadCountries(const NoParams());
    switch (result) {
      case Success<List<Country>, Failure>(:final value):
        emit(CountriesLoadSuccess(value));
      case FailureResult<List<Country>, Failure>(:final failure):
        emit(CountriesLoadFailure(failure));
    }
  }
}
