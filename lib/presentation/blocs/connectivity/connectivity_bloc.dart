import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/domain/usecases/use_case.dart';
import 'package:radio_app/domain/usecases/watch_connectivity_use_case.dart';

/// Events for [ConnectivityBloc].
sealed class ConnectivityEvent extends Equatable {
  /// Creates a connectivity event.
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

final class _ConnectivityChanged extends ConnectivityEvent {
  const _ConnectivityChanged({required this.isOnline});

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}

/// States for [ConnectivityBloc].
sealed class ConnectivityState extends Equatable {
  /// Creates a connectivity state.
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

/// Initial, unknown connectivity state.
final class ConnectivityInitial extends ConnectivityState {
  /// Creates the initial connectivity state.
  const ConnectivityInitial();
}

/// The device is online.
final class ConnectivityOnline extends ConnectivityState {
  /// Creates the online connectivity state.
  const ConnectivityOnline();
}

/// The device is offline.
final class ConnectivityOffline extends ConnectivityState {
  /// Creates the offline connectivity state.
  const ConnectivityOffline();
}

/// Tracks network connectivity changes via [WatchConnectivityUseCase]
/// (per ADR-0013).
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  /// Creates the connectivity bloc over its connectivity watcher.
  ConnectivityBloc(WatchConnectivityUseCase watchConnectivity)
    : super(const ConnectivityInitial()) {
    on<_ConnectivityChanged>(_onChanged);

    _subscription = watchConnectivity(
      const NoParams(),
    ).listen((isOnline) => add(_ConnectivityChanged(isOnline: isOnline)));
  }

  late final StreamSubscription<bool> _subscription;

  void _onChanged(_ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    emit(
      event.isOnline ? const ConnectivityOnline() : const ConnectivityOffline(),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
