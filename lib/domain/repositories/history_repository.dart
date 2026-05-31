import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for recently played station history.
abstract interface class HistoryRepository {
  /// Emits history list updates.
  Stream<List<RadioStation>> get historyStream;

  /// Returns the current recently played history.
  Future<Result<List<RadioStation>, Failure>> getHistory();

  /// Adds [station] to recently played history.
  Future<Result<void, Failure>> addToHistory(RadioStation station);

  /// Clears recently played history.
  Future<Result<void, Failure>> clearHistory();
}
